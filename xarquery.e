/* -- ----------------------------------------------------------------- -- *
 * -- Program.....: XarQuery.e                                          -- *
 * -- Author......: Daniel Kasmeroglu <raptor@cs.tu-berlin.de>          -- *
 * -- Original....: Matthias Meixner                                    -- *
 * -- Description.: Lists all available packer including modes          -- *
 * -- ----------------------------------------------------------------- -- *
 * -- History                                                           -- *
 * --                                                                   -- *
 * --   0.1 (14. August 1998) - Started with writing.                   -- *
 * --   1.0 (14. August 1998) - Program is complete and works without   -- *
 * --                           problems.                               -- *
 * --                                                                   -- *
 * -- ----------------------------------------------------------------- -- */


/* -- ----------------------------------------------------------------- -- *
 * --                              Options                              -- *
 * -- ----------------------------------------------------------------- -- */

OPT REG = 5       -> enable register-optimisation


/* -- ----------------------------------------------------------------- -- *
 * --                              Modules                              -- *
 * -- ----------------------------------------------------------------- -- */

MODULE 'libraries/xpkarchive',
       'libraries/xpk',
       'utility/tagitem'

MODULE 'lib/xpkarchive'


/* -- ----------------------------------------------------------------- -- *
 * --                            Procedures                             -- *
 * -- ----------------------------------------------------------------- -- */

PROC packerquery( pac_packer )
DEF pac_xpinfo        : xararchiverinfo
DEF pac_xminfo        : xpkmode
DEF pac_buffer [ 40 ] : STRING
DEF pac_mode

  -> get basical information about the packer
  pac_mode := XarQueryA( [ XAR_ARCHIVERQUERY , pac_xpinfo ,
                           XAR_PACKMETHOD    , pac_packer ,
                           TAG_END ] )

  IF pac_mode <> NIL THEN RETURN

  -> this stuff is needed, since you invalid methodnames were
  -> accepted by the "xpkarchive.library". invalid methodnames
  -> are leading to shit, so I'm checking whether the method
  -> exist's or not. Shouldn't be a problem if you have queried
  -> the "xararchiverentry" before. This is only inserted why
  -> the user can pass a method-name via the commandline.
  StringF( pac_buffer, 'libs:compressors/xpk\s.library', pac_packer )
  IF FileLength( pac_buffer ) <= 0
    StringF( pac_buffer, 'libs:archivers/xar\s.library', pac_packer )
    IF FileLength( pac_buffer ) <= 0 THEN RETURN
  ENDIF

  pac_mode := 1

  Vprintf( {lab_PackerInfo} ,
  [ pac_packer              ,
    pac_xpinfo.longname     ,
    pac_xpinfo.description  ,
    pac_xpinfo.defaultmode  ] )

  WHILE (pac_mode < 100) AND (XarQueryA( [ XAR_MODEQUERY  , pac_xminfo ,
                                           XAR_PACKMETHOD , pac_packer ,
                                           XAR_PACKMODE   , pac_mode   ,
                                           TAG_END ] ) = 0)

    -> print out the information
    Vprintf( {lab_PrintFormat} ,
    [ pac_packer               ,
      pac_mode                 ,
      pac_xminfo.upto          ,
      pac_xminfo.ratio / 10    ,
      pac_xminfo.packspeed     ,
      pac_xminfo.unpackspeed   ,
      pac_xminfo.description   ] )

    -> use the next mode
    pac_mode := pac_xminfo.upto + 1

  ENDWHILE

  Vprintf( '\n', NIL )


ENDPROC


/* -- ----------------------------------------------------------------- -- *
 * --                               Main                                -- *
 * -- ----------------------------------------------------------------- -- */

PROC main()
DEF ma_list [ 100 ] : ARRAY OF  xararchiverentry
DEF ma_args         : PTR TO LONG
DEF ma_i,ma_numpackers,ma_rdargs

  xpkarchivebase := OpenLibrary( 'xpkarchive.library', 2 )
  IF xpkarchivebase <> NIL

    ma_rdargs := ReadArgs( 'METHOD', ma_args, NIL )
    IF ma_rdargs <> NIL

      IF ma_args[0] = NIL

        -> getting the list of available packer
        ma_numpackers := XarQueryA( [ XAR_ARCHIVERSQUERY , ma_list ,
                                      XAR_ARRAYSIZE      , 100     ,
                                      TAG_END ] )

        -> run through all methods and print out their
        -> possibilities
        FOR ma_i := 0 TO ma_numpackers - 1
          packerquery( ma_list[ ma_i ] )
        ENDFOR
      ELSE
        packerquery( ma_args[0] )
      ENDIF

      FreeArgs( ma_rdargs )

    ENDIF
    CloseLibrary( xpkarchivebase )

  ELSE
    Vprintf( {lab_NoLib}, NIL )
  ENDIF
ENDPROC


/* -- ----------------------------------------------------------------- -- *
 * --                               Data                                -- *
 * -- ----------------------------------------------------------------- -- */

lab_NoLib:
CHAR 'Can\at open "xpkarchive.library" v2+\n' , 0

lab_PackerInfo:
CHAR '\n\e[1mPacker :\e[0m \s\n'                                      ,
     '\e[1mName   :\e[0m \s\n'                                        ,
     '\e[1mDescr. :\e[0m \s\n'                                        ,
     '\e[1mDefMode:\e[0m \d\e[0m\n'                                   ,
     '\e[2m                         Pack-    Unpack-\n'               ,
     'Name     Mode    Ratio   Speed     Speed    Description\n'      ,
     '------ --------  -----  --------  --------  -----------\e[0m\n' , 0

lab_PrintFormat:
CHAR '\l\s[6] \r\d[3]..\l\d[3]  \r\d[3] %%  \r\d[4] K/s  \r\d[4] K/s  \s\n' , 0

