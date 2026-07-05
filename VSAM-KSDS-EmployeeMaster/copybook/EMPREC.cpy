      ******************************************************************
      * COPYBOOK   : EMPREC.cpy
      * PURPOSE    : Record layout for EMPFILE - VSAM KSDS Employee
      *              Master File. Key = EMP-ID (positions 1-6).
      * REC LENGTH : 61 bytes (fixed)
      ******************************************************************
       01  EMP-RECORD.
           05  EMP-ID              PIC X(06).
           05  EMP-NAME            PIC X(25).
           05  EMP-DEPT            PIC X(10).
           05  EMP-SALARY          PIC 9(07)V99.
           05  EMP-DOJ             PIC X(10).
           05  EMP-STATUS          PIC X(01).
      *        STATUS: 'A' = ACTIVE   'I' = INACTIVE
