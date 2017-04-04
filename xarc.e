/* -- ----------------------------------------------------------------- -- *
 * -- Program.....: xarc.e                                              -- *
 * -- Author......: Daniel Kasmeroglu <raptor@cs.tu-berlin.de>          -- *
 * -- Based on....: Xarc.c from Matthias Meixner                        -- *
 * -- Description.: simple archiver                                     -- *
 * -- ----------------------------------------------------------------- -- *
 * -- History                                                           -- *
 * --                                                                   -- *
 * --   0.1 (11. August 1998) - Started with writing.                   -- *
 * --   1.0 (12. August 1998) - Completion with some additional stuff.  -- *
 * -- ----------------------------------------------------------------- -- */

/* -- ----------------------------------------------------------------- -- *
 * --                              Modules                              -- *
 * -- ----------------------------------------------------------------- -- */

MODULE 'libraries/xpkarchive',
       'libraries/xpk',
       'utility/tagitem',
       'utility/hooks',
       'tools/inithook',
       'exec/memory',
       'dos/dos'

MODULE 'lib/xpkarchive'


/* -- ----------------------------------------------------------------- -- *
 * --                             Constants                             -- *
 * -- ----------------------------------------------------------------- -- */

ENUM ARG_ARCHIVE   , -> the archive name (it doesn't matter if with or without ".xar")
     ARG_METHOD    , -> the selected method (look at "libs/compressors" and "libs/archivers")
     ARG_EXTRACT   , -> extract all or the named files
     ARG_LIST      , -> list archive contents
     ARG_NOCOMMENT , -> list without filenote
     ARG_FILES       -> the list of all files


/* -- ----------------------------------------------------------------- -- *
 * --                               Main                                -- *
 * -- ----------------------------------------------------------------- -- */

PROC main() HANDLE
DEF ma_args      : PTR TO LONG
DEF ma_path      : PTR TO CHAR
DEF ma_chunkhook : hook
DEF ma_rdargs,ma_arc

  -> do some initialisations (don't remove the next lines !!!)
  ma_arc        := NIL
  ma_rdargs     := NIL
  ma_path       := NIL
  ma_args       := [ NIL, NIL, FALSE, FALSE, FALSE, NIL ]

  -> if we're started from workbench, we will abort
  IF wbmessage <> NIL THEN Raise( "NOWB" )

  -> Yeah, dos is always funny
  ma_rdargs     := ReadArgs( {lab_Template}, ma_args, NIL )
  IF ma_rdargs = NIL THEN Raise( "ARGS" )

  -> getting memory to store the path of the archive
  ma_path := AllocVec( StrLen( ma_args[ ARG_ARCHIVE ] ) + 5, MEMF_PUBLIC )
  IF ma_path = NIL THEN Raise( "MEM" )

  -> copy the path and add extension if needed, so each archive will
  -> end with ".xar"
  StringF( ma_path, '\s', ma_args[ ARG_ARCHIVE ] )
  IF StrCmp( ma_path + StrLen( ma_path ) - 4, {lab_Extension} ) = FALSE
    StrAdd( ma_path, {lab_Extension} )
  ENDIF

  -> this should be clear for every one
  xpkarchivebase := OpenLibrary( 'xpkarchive.library', 0 )
  IF xpkarchivebase = NIL THEN Raise( "LIB" )

  -> open the archiv. do this with XMODE_APPEND so the archive will be
  -> created if it doesn't exist or it will be opened.
  -> i've renamed the constant "XAR_MODExxx" to "XMODE_xxx" because
  -> the prefix "XAR_" suggests that this is a tag-value.
  ma_arc := XarOpenArchiveA( [ XAR_ARCHIVENAME , ma_path      ,
                               XAR_ARCHIVEMODE , XMODE_APPEND ,
                               XAR_SHOWDIRS    , TRUE         ,
                               TAG_END ] )

  IF ma_arc = NIL THEN Raise( "CARC" )

  -> install the hook-function
  inithook( ma_chunkhook, {chunkfunc} )

  -> only use one of the possible functions. the order isn't important.
  IF ma_args[ ARG_LIST ] <> FALSE
    listarchive( ma_arc, ma_args[ ARG_NOCOMMENT ] )
  ELSEIF ma_args[ ARG_EXTRACT ] <> FALSE
    extractarchive( ma_arc, ma_args[ ARG_FILES ], ma_chunkhook )
  ELSE
    add2archive( ma_arc, ma_args[ ARG_FILES ], ma_chunkhook, ma_args[ ARG_METHOD ] )
  ENDIF

EXCEPT DO

  -> print the message if an exception was raised
  SELECT exception
  CASE "CARC" ; Vprintf( { lab_OpenArc       } , [ ma_args[ ARG_ARCHIVE ] ] )
  CASE "ARGS" ; Vprintf( { lab_InfoText      } , NIL                        )
  CASE "LIB"  ; Vprintf( { lab_OpenLib       } , NIL                        )
  CASE "NOWB" ; Vprintf( { lab_NoWB          } , NIL                        )
  CASE "MEM"  ; Vprintf( { lab_NoMem         } , NIL                        )
  ENDSELECT

  -> free all stuff
  IF ma_path        <> NIL THEN FreeVec         ( ma_path        )
  IF ma_arc         <> NIL THEN XarCloseArchive ( ma_arc         )
  IF xpkarchivebase <> NIL THEN CloseLibrary    ( xpkarchivebase )
  IF ma_rdargs      <> NIL THEN FreeArgs        ( ma_rdargs      )

ENDPROC


/* -- ----------------------------------------------------------------- -- *
 * --                            Procedures                             -- *
 * -- ----------------------------------------------------------------- -- */

PROC listarchive( lis_arc, lis_nocomment )
DEF lis_data         : PTR TO xarfiledata
DEF lis_list         : PTR TO LONG
DEF lis_pname    [2] : ARRAY OF LONG
DEF lis_ratiostr [6] : STRING
DEF lis_fib          : xpkfib
DEF lis_sum1,lis_sum2
DEF lis_compsize,lis_lock

  -> size of all files (uncompressed and compressed)
  lis_sum1 := 0
  lis_sum2 := 0

  Vprintf( {lab_ListHeader}, NIL )

  -> get first fileentry
  lis_lock := XarGetLock( lis_arc )
  WHILE lis_lock <> NIL

    -> get some data
    lis_data     := XarGetFileData( lis_lock )
    lis_compsize := XarGetFileSize( lis_lock )
    lis_sum1     := lis_sum1 + lis_data.filesize
    lis_sum2     := lis_sum2 + lis_compsize

    -> set up the argument-list
    lis_list := [ lis_data.filesize          ,  -> original filesize
                  lis_compsize               ,  -> size of the compressed file
                  lis_ratiostr               ,  -> the compression-ratio
                  lis_data.time.day          ,  -> should be obvious
                  lis_data.time.month        ,
                  lis_data.time.year         ,
                  lis_data.time.hour         ,
                  lis_data.time.min          ,
                  lis_data.time.sec          ,
                  lis_data.generation        ,  -> generation number
                  NIL                        ,  -> see below
                  XarGetFileName( lis_lock ) ]  -> the filename

    -> calculate ratio and convert real to string
    calcratio( lis_ratiostr, lis_data.filesize, lis_compsize )

    IF XarIsXpkArchive( lis_arc ) <> 0

      -> archive was created with an xpk-sublibrary
      XarExamine( lis_lock, lis_fib )
      lis_pname [  0 ] := lis_fib.id
      lis_pname [  1 ] := 0
      lis_list  [ 10 ] := lis_pname
    ELSE
      -> archive was created with a xar-sublibrary
      lis_list  [ 10 ] := lis_data.flags
    ENDIF

    -> print out the entry
    Vprintf( {lab_ListEntry}, lis_list )

    -> if there is a filenote, then print it out
    IF (XarGetFileNote( lis_lock ) <> NIL) AND (lis_nocomment = FALSE)
      Vprintf( '\e[2m\e[3m:\s\e[0m\n', [ XarGetFileNote( lis_lock ) ] )
    ENDIF

    -> get next fileentry
    lis_lock := XarNextLock( lis_lock )

  ENDWHILE

  -> print the whole size (compressed and uncompressed)
  calcratio( lis_ratiostr, lis_sum1, lis_sum2 )
  Vprintf( {lab_ListEnd}, [ lis_sum1, lis_sum2, lis_ratiostr ] )

ENDPROC


PROC calcratio( cal_ratiostr, cal_size, cal_compressed )
  IF cal_size = 0
    cal_size := 0.0
  ELSE
    cal_size := cal_size!
    cal_size := ! (cal_compressed!) / cal_size
    cal_size := ! 100.0 * cal_size
    cal_size := ! 100.0 - cal_size
  ENDIF
  RealF( cal_ratiostr, cal_size, 2 )
ENDPROC


PROC extractarchive( ext_arc, ext_files : PTR TO LONG, ext_chunkhook : PTR TO hook )
DEF ext_gen,ext_file

  WHILE ext_files[] <> NIL

    ext_file,ext_gen := splitname( ext_files[]++ )

    IF XarExtractFileA( [ XAR_OUTNAME      , ext_file      ,
                          XAR_FILENAME     , ext_file      ,
                          XAR_GENERATION   , ext_gen       ,
                          XAR_ARCHIVE      , ext_arc       ,
                          XAR_PROGRESSHOOK , ext_chunkhook ,
                          TAG_END ] ) <> XARERR_NO_ERR

      Vprintf( {lab_Error}, [ XarWhy( ext_arc, 0 ) ] )

    ENDIF

  ENDWHILE

ENDPROC


PROC splitname( spl_name )
DEF spl_backslash,spl_gen
DEF spl_valid

  spl_backslash := InStr( spl_name, '\\', 0 )
  IF spl_backslash <> -1
    spl_name[ spl_backslash ] := 0
    spl_gen,spl_valid := Val( spl_name + spl_backslash + 1 )
    IF spl_valid = 0 THEN spl_gen := 0
  ELSE
    spl_gen  := 0
  ENDIF

ENDPROC spl_name,spl_gen


PROC add2archive( add_arc, add_files : PTR TO LONG, add_chunkhook : PTR TO hook, add_method )
DEF add_basename,add_path
DEF add_dp,add_gen

  WHILE add_files[] <> NIL

    add_path,add_gen := splitname( add_files[]++ )
    add_dp           := InStr( add_path, ':' )
    IF add_dp <> -1
      add_basename := add_path + add_dp + 1
    ELSE
      add_basename := add_path
    ENDIF

    IF XarAddFileA( [ XPK_INNAME       , add_path      ,
                      XAR_FILENAME     , add_basename  ,
                      XAR_ARCHIVE      , add_arc       ,
                      XAR_PACKMETHOD   , add_method    ,
                      XAR_PROGRESSHOOK , add_chunkhook ,
                      XAR_GENERATION   , add_gen       ,
                      TAG_END ] ) = 0

      Vprintf( {lab_Error}, [ XarWhy( add_arc, 0 ) ] )

    ENDIF

  ENDWHILE

ENDPROC


/* -- ----------------------------------------------------------------- -- *
 * --                           Hook-Routines                           -- *
 * -- ----------------------------------------------------------------- -- */

PROC chunkfunc( chu_hook, chu_obj, chu_prog : PTR TO xpkprogress )
DEF chu_list : PTR TO LONG
DEF chu_str

  chu_list := [ chu_prog.packername ,
                chu_prog.activity   ,
                NIL                 ,
                chu_prog.cf         ,
                chu_prog.speed      ,
                chu_prog.filename   ,
                13                  ]

  IF chu_prog.type <> XPKPROG_END

    chu_str        := {lab_ChunkNotAtEnd}
    chu_list [ 2 ] := chu_prog.done
    Flush( stdout )

  ELSE

    chu_str        := {lab_ChunkAtEnd}
    chu_list [ 2 ] := Shr( chu_prog.ulen, 10 )

  ENDIF

  Vprintf( chu_str, chu_list )

ENDPROC SetSignal( 0, SIGBREAKF_CTRL_C ) AND SIGBREAKF_CTRL_C


/* -- ----------------------------------------------------------------- -- *
 * --                               Data                                -- *
 * -- ----------------------------------------------------------------- -- */

lab_Template:
CHAR 'ARCHIVE/A,M=METHOD/K,X=EXTRACT/S,L=LIST/S,N=NOCOMMENT/S,FILES/M',0

lab_Extension:
CHAR '.xar',0

lab_ListHeader:
CHAR '\e[1mOriginal Packed Ratio  Date     Time    Gen Mode Name\n',
     '-------- ------ ----- -------- -------- --- ---- ----------\e[0m\n',0

-> NOTE: you can see, that there are "C"-styled formatting codes mixed up
->       with E formatting codes. E doesn't allow to print out preceding
->       zeros or unsigned decimals. for the fact that the function "PrintF()"
->       uses "RawDoFmt()" from exec you can use these formatting codes
->       without any problem. f.e. E translates the sequence "\d[8]" to
->       "%8ld".

lab_ListEntry:
CHAR '\d[8] \d[6] \s[5] %02ld.%02ld.%02ld %02ld:%02ld:%02ld \d[3] \d[4] \s\n',0

lab_ListEnd:
CHAR '\e[1m-------- ------ -----\n\d[8] \d[6] \s[5]\e[0m\n',0

lab_InfoText:
CHAR '\nXARC ARCHIVE/A,M=METHOD/K,L=LIST/S,X=EXTRACT/S,N=NOCOMMENT/S,FILES/M\n\n',
     ' ARCHIVE/A     -> specifies the path of your archive. if the extension\n',
     '               -> ".xar" is missing, it will be added automatically.\n\n',
     ' M=METHOD/K    -> this option is required wenn archiving some data. it is\n',
     '               -> used to specify the compression method.\n\n',
     ' L=LIST/S      -> if this parameter appears, the contents of the archive\n',
     '               -> will be shown.\n\n',
     ' X=EXTRACT/S   -> this will extract the complete archive or the files\n',
     '               -> specified with the option "FILES/M"\n\n',
     ' N=NOCOMMENT/S -> this works only if the option "LIST/S" is set. it will\n',
     '               -> suppress the output of the filenotes.\n\n',
     ' FILES/M       -> enter a list of files for extracting or archieving.\n',
     '               -> you can specify the generation-number by adding the\n',
     '               -> sequence "<filename>\\<generation-number>"\n\n',
     '\e[1mPLEASE READ THE FILE "Xarc.readme" for further information.\e[0m\n',0


lab_OpenLib:
CHAR 'Can\at open "xpkarchive.library" v0+\n',0

lab_OpenArc:
CHAR 'Can\at create archive "\s"\n',0

lab_NoWB:
CHAR 'Xarc isn\at runnable from workbench !\n',0

lab_NoMem:
CHAR 'Not enough memory available !\n',0

lab_Error:
CHAR 'Error: \s\n',0

lab_ChunkNotAtEnd:
CHAR '\e[M\s[4]: \l\s[8] ( \r\d[3] %% done, \r\d[2] % CF, \r\d[6] cps ) \s\c',0

lab_ChunkAtEnd:
CHAR '\e[M\s[4]: \l\s[8] ( \r\d[4] KB, \r\d[2] % CF, \r\d[6] cps ) \s\n',0

lab_Version:
CHAR '$VER: XArc 1.0 (11.08.98) [ Daniel Kasmeroglu ]\n',0

