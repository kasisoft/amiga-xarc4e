EMOD        ?P        
       ? ??  xararchiverinfo      name    
   longname       8description      ?archivetype      ?id      ?defaultmode    
   ?extension     ?flags      ?        ??  xararchiverentry       packer      	type       
        ??  xarpackmode      id       
description     mode               ??  xartype      archivetype   
   defaultid     "defaultmode      $        ??  xarfiledata     chksum       flags      generation       sysid    
  filesize        
time  ?? time     crc      protection     
  validmask      compressedsize       crc32      "type       #pad      $        
??  filedata      chksum       method       version      generation       sysid    
  filesize        
time  ?? time     crc      protection               ??  time      year       month      day      hour       min      sec           >    XARIF_LOSSY    XARERR_UNKNOWN_TYPE    XARERR_INVALID_TYPE    XARWARN_DUPLICATE_ARCTYPE  ? XvXAR_OUTMEMTYPE   
? XSXAR_INBUF  ? XrXAR_GETOUTLEN    XARWARN_CRC_FAILED     XARERR_WRONG_METHOD    XARERR_NO_METHOD   ? XzXAR_PACKMETHOD      @DUMMY     XARIF_CHECKING   ? AgXAR_CURRENTTIME     XAR_VALIDTIME    XARWARN_BODY_WITHOUT_FILEDATA    XARWARN_DUPLICATE_FILEDATA      XARIF_UP_MEM      XARIF_PK_MEM   
? AjXAR_CRC32      XAR_VALIDCRC32   ? A`XAR_ARCLOCK  ?   XARIF_USES_GENERATIONS     XARERR_CANNOT_OPEN      XAR_VALIDSYSID   ? AkXAR_VALIDMASK    XARERR_INVALID_TAGS     XARERR_OPERATION_NOT_SUPPORTED     XARERR_OUTPUT_NOT_SUPPORTED    XARERR_INPUT_NOT_SUPPORTED     XARERR_ABORTED       XAR_FILENEWEST     XARWARN_INVALID_FILENOTE     XARWARN_DUPLICATE_FILENOTE   ? ATXAR_FILENOTE   ? ARXAR_TAGBASE  ? AZXAR_TIMESEC    
XARERR_INVALID_FILEINDEX   ? AeXAR_FILEINDEX    XARMAXWARN     XARERR_CANNOT_EXAMINE  ? AdXAR_NEWGENERATION  ? A^XAR_GENERATION   ? A]XAR_PROTECTION       XARIF_ENCRYPTION      XAR_VALIDGENERATION  ? AhXAR_AUTONEXTGEN    XARERR_DIFFERENT_TYPES   ? A\XAR_CRC    XARERR_ARCHIVE_CORRUPT     XARWARN_ARCHIVE_CORRUPT     XARINF_ARCHIVE_CORRUPT   ? AoXAR_MODEQUERY  ? AnXAR_ARCHIVERQUERY  ? AlXAR_ARCHIVERSQUERY     XARERR_SMALL_BUF      XAR_VALIDCRC     XARERR_INTERNAL_ERROR    XARERR_READ_ERROR    XARERR_WRITE_ERROR   
? A_XAR_ERROR     XAR_TYPEDIR  ? XcXAR_GETOUTBUF  ? XbXAR_OUTBUF   ? A[XAR_DATESTAMP  ? AVXAR_TIMEMONTH     ?XAR_FILEDELETED     ?XARFF_DELETED  ? AXXAR_TIMEHOUR   
? XpXAR_INLEN  
? XRXAR_INFH   
  XARMAXERR    XARERR_CANNOT_CREATE   
? XaXAR_OUTFH     XARINF_NOT_EXCLUSIVE      XARTYPE_ARCHIVER   ? X|XAR_PACKMODE   ? AcXAR_ARCHIVEMODE    XARERR_NO_XPK_ARCHIVE    XARERR_NO_ARCHIVE     XARINF_NEW_ARCHIVE      XMODE_NEWARCHIVE       XMODE_OLDARCHIVE   ? AbXAR_DESTARCHIVE  ? AaXAR_ARCHIVE    ? XARIF_MODES    	XARERR_FILE_NOT_FOUND     XMODE_APPEND   ? AWXAR_TIMEYEAR       XARTYPE_XPK    XARERR_SAME_SRC_AND_DST  ? ApXAR_SHOWDIRS      XARIF_UP_STREAM     XARIF_PK_STREAM    XARERR_NO_MEMORY     XARWARN_FILEDATA_WITHOUT_BODY     XAR_VALIDPROTECT       XAR_NULL_XPKID     @ XARIF_NEEDPASSWD   ? XtXAR_PASSWORD   ? XdXAR_OUTHOOK  ? XTXAR_INHOOK   ? XyXAR_PROGRESSHOOK       XARIF_UP_HOOK     XARIF_PK_HOOK  ? XsXAR_GETOUTBUFLEN   ? XqXAR_OUTBUFLEN    XARERR_MASTERLIB_TOO_OLD   
   XARMAXINF      XARERR_NO_ERR  ? AUXAR_TIMEDAY    XARERR_CANNOT_CREATE_FILE      XAR_TYPEFILE     XARERR_WRONG_OS_VERSION  ? AmXAR_ARRAYSIZE  ? AYXAR_TIMEMIN    XARERR_CANNOT_RENAME   ? X`XAR_OUTNAME  ? XQXAR_INNAME   ? AiXAR_ARCHIVENAME  ? AfXAR_NEWNAME  ? ASXAR_FILENAME      XARCUSTOM_LEVEL     XARERROR_LEVEL      XARWARNING_LEVEL      XarIsDeletedFD      &(.flags AND XARFF_DELETED) <> FALSE   
SYS_AMIGA      [ 0, 0, "A", "M" ]:CHAR  SYS_HELIOS       [ 0, 0, "H", "E" ]:CHAR  SYS_ARCHIMEDES       [ 0, 0, "A", "R" ]:CHAR  
SYS_UNIX       [ 0, 0, "U", "X" ]:CHAR  SYS_ATARI_ST       [ 0, 0, "S", "T" ]:CHAR  SYS_MACINTOSH      [ 0, 0, "M", "A" ]:CHAR  
SYS_MSDOS      [ 0, 0, "M", "S" ]:CHAR  XarIsDeleted      &XarIsDeletedFD( XarGetFileData(  ) )     