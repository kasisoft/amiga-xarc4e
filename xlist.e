/* -- ----------------------------------------------------------------- -- *
 * -- Program.....: XList.e                                             -- *
 * -- Author......: Daniel Kasmeroglu <raptor@cs.tu-berlin.de>          -- *
 * -- Original....: Matthias Meixner                                    -- *
 * -- Description.: Lists all available packer including types          -- *
 * -- ----------------------------------------------------------------- -- *
 * -- History                                                           -- *
 * --                                                                   -- *
 * --   0.1 (14. August 1998) - Started with writing.                   -- *
 * --   1.0 (14. August 1998) - Program is complete and works without   -- *
 * --                           problems.                               -- *
 * --                                                                   -- *
 * -- ----------------------------------------------------------------- -- */


/* -- ----------------------------------------------------------------- -- *
 * --                              Modules                              -- *
 * -- ----------------------------------------------------------------- -- */

MODULE 'libraries/xpkarchive',
       'utility/tagitem'

MODULE 'lib/xpkarchive'


/* -- ----------------------------------------------------------------- -- *
 * --                               Main                                -- *
 * -- ----------------------------------------------------------------- -- */

PROC main()
DEF ma_list [ 100 ] : ARRAY OF  xararchiverentry
DEF ma_i,ma_numpackers

  xpkarchivebase := OpenLibrary( 'xpkarchive.library', 2 )
  IF xpkarchivebase <> NIL

    -> getting the list of available packer
    ma_numpackers := XarQueryA( [ XAR_ARCHIVERSQUERY , ma_list ,
                                  XAR_ARRAYSIZE      , 100     ,
                                  TAG_END ] )

    -> run through all methods and print out their type
    FOR ma_i := 0 TO ma_numpackers - 1
      Vprintf( '%03ld. \l\s[8] : \s\n', [ ma_i, ma_list[ ma_i ].packer, IF ma_list[ ma_i ].type = XARTYPE_XPK THEN 'XPK' ELSE 'XAR' ] )
    ENDFOR

    CloseLibrary( xpkarchivebase )

  ELSE
    Vprintf( 'Can\at open "xpkarchive.library" v2+\n', NIL )
  ENDIF
ENDPROC

