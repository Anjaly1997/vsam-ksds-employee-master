      ******************************************************************
      * COPYBOOK   : TRANREC.cpy
      * PURPOSE    : Record layout for EMPTRAN - Transaction file used
      *              to Add / Update / Delete records on EMPFILE (KSDS)
      * REC LENGTH : 69 bytes (fixed)
      ******************************************************************
       01  TRAN-RECORD.
           05  TRAN-CODE           PIC X(01).
      *        'A' = ADD   'U' = UPDATE   'D' = DELETE
           05  TRAN-EMP-ID         PIC X(06).
           05  TRAN-EMP-NAME       PIC X(25).
           05  TRAN-EMP-DEPT       PIC X(10).
           05  TRAN-EMP-SALARY     PIC 9(07)V99.
           05  TRAN-EMP-DOJ        PIC X(10).
           05  FILLER              PIC X(08).
