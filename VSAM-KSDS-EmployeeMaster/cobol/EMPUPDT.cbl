       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPUPDT.
      ******************************************************************
      * PROGRAM    : EMPUPDT
      * PURPOSE    : Reads the transaction file (EMPTRAN) SEQUENTIALLY
      *              and applies each transaction to the VSAM KSDS
      *              Employee Master (EMPFILE) using RANDOM access
      *              (READ / WRITE / REWRITE / DELETE by EMP-ID key).
      *              This is the classic "combined sequential input +
      *              random master update" batch pattern.
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPTRAN ASSIGN TO EMPTRAN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-TRAN-STATUS.

           SELECT EMPFILE ASSIGN TO EMPFILE
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS EMP-ID
               FILE STATUS IS WS-FILE-STATUS.

           SELECT RPTOUT ASSIGN TO RPTOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-RPT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPTRAN
           RECORDING MODE IS F.
       COPY TRANREC.

       FD  EMPFILE.
       COPY EMPREC.

       FD  RPTOUT
           RECORDING MODE IS F.
       01  RPT-LINE                PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-TRAN-STATUS          PIC XX     VALUE SPACES.
       01  WS-FILE-STATUS          PIC XX     VALUE SPACES.
       01  WS-RPT-STATUS           PIC XX     VALUE SPACES.
       01  WS-EOF-SW               PIC X      VALUE 'N'.
           88  END-OF-TRAN                    VALUE 'Y'.
       01  WS-COUNTERS.
           05  WS-TRAN-CNT         PIC 9(05)  VALUE ZERO.
           05  WS-ADD-OK-CNT       PIC 9(05)  VALUE ZERO.
           05  WS-ADD-ER-CNT       PIC 9(05)  VALUE ZERO.
           05  WS-UPD-OK-CNT       PIC 9(05)  VALUE ZERO.
           05  WS-UPD-ER-CNT       PIC 9(05)  VALUE ZERO.
           05  WS-DEL-OK-CNT       PIC 9(05)  VALUE ZERO.
           05  WS-DEL-ER-CNT       PIC 9(05)  VALUE ZERO.
       01  WS-MSG-LINE.
           05  WS-MSG-CODE         PIC X(10).
           05  WS-MSG-KEY          PIC X(06).
           05  FILLER              PIC X(01)  VALUE SPACE.
           05  WS-MSG-TEXT         PIC X(40).

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY 'EMPUPDT : MASTER FILE UPDATE - STARTING'
           PERFORM 1000-OPEN-FILES
           PERFORM 2000-PROCESS-UNTIL-EOF
               UNTIL END-OF-TRAN
           PERFORM 3000-CLOSE-FILES
           PERFORM 8000-PRINT-SUMMARY
           DISPLAY 'EMPUPDT : MASTER FILE UPDATE - COMPLETE'
           STOP RUN.

       1000-OPEN-FILES.
           OPEN INPUT EMPTRAN
           OPEN I-O   EMPFILE
           OPEN OUTPUT RPTOUT
           IF WS-TRAN-STATUS NOT = '00' OR WS-FILE-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING FILES. TRAN=' WS-TRAN-STATUS
                       ' MASTER=' WS-FILE-STATUS
               STOP RUN
           END-IF
           PERFORM 9000-READ-TRAN.

       2000-PROCESS-UNTIL-EOF.
           ADD 1 TO WS-TRAN-CNT
           EVALUATE TRAN-CODE
               WHEN 'A'
                   PERFORM 4000-ADD-RECORD
               WHEN 'U'
                   PERFORM 5000-UPDATE-RECORD
               WHEN 'D'
                   PERFORM 6000-DELETE-RECORD
               WHEN OTHER
                   MOVE 'BAD-CODE  ' TO WS-MSG-CODE
                   MOVE TRAN-EMP-ID  TO WS-MSG-KEY
                   MOVE 'INVALID TRANSACTION CODE' TO WS-MSG-TEXT
                   PERFORM 7000-WRITE-RPT-LINE
           END-EVALUATE
           PERFORM 9000-READ-TRAN.

      *----------------------------------------------------------------
      * RANDOM WRITE - add a brand new employee
      *----------------------------------------------------------------
       4000-ADD-RECORD.
           MOVE TRAN-EMP-ID     TO EMP-ID
           MOVE TRAN-EMP-NAME   TO EMP-NAME
           MOVE TRAN-EMP-DEPT   TO EMP-DEPT
           MOVE TRAN-EMP-SALARY TO EMP-SALARY
           MOVE TRAN-EMP-DOJ    TO EMP-DOJ
           MOVE 'A'             TO EMP-STATUS
           WRITE EMP-RECORD
           IF WS-FILE-STATUS = '00'
               ADD 1 TO WS-ADD-OK-CNT
               MOVE 'ADD-OK    ' TO WS-MSG-CODE
               MOVE TRAN-EMP-ID  TO WS-MSG-KEY
               MOVE 'EMPLOYEE ADDED'    TO WS-MSG-TEXT
           ELSE
               ADD 1 TO WS-ADD-ER-CNT
               MOVE 'ADD-FAIL  ' TO WS-MSG-CODE
               MOVE TRAN-EMP-ID  TO WS-MSG-KEY
               MOVE 'DUPLICATE KEY OR I/O ERROR' TO WS-MSG-TEXT
           END-IF
           PERFORM 7000-WRITE-RPT-LINE.

      *----------------------------------------------------------------
      * RANDOM READ then REWRITE - update an existing employee
      *----------------------------------------------------------------
       5000-UPDATE-RECORD.
           MOVE TRAN-EMP-ID TO EMP-ID
           READ EMPFILE
               INVALID KEY
                   ADD 1 TO WS-UPD-ER-CNT
                   MOVE 'UPD-FAIL  ' TO WS-MSG-CODE
                   MOVE TRAN-EMP-ID  TO WS-MSG-KEY
                   MOVE 'RECORD NOT FOUND' TO WS-MSG-TEXT
                   PERFORM 7000-WRITE-RPT-LINE
               NOT INVALID KEY
                   MOVE TRAN-EMP-NAME   TO EMP-NAME
                   MOVE TRAN-EMP-DEPT   TO EMP-DEPT
                   MOVE TRAN-EMP-SALARY TO EMP-SALARY
                   MOVE TRAN-EMP-DOJ    TO EMP-DOJ
                   REWRITE EMP-RECORD
                   IF WS-FILE-STATUS = '00'
                       ADD 1 TO WS-UPD-OK-CNT
                       MOVE 'UPD-OK    ' TO WS-MSG-CODE
                       MOVE TRAN-EMP-ID  TO WS-MSG-KEY
                       MOVE 'EMPLOYEE UPDATED' TO WS-MSG-TEXT
                   ELSE
                       ADD 1 TO WS-UPD-ER-CNT
                       MOVE 'UPD-FAIL  ' TO WS-MSG-CODE
                       MOVE TRAN-EMP-ID  TO WS-MSG-KEY
                       MOVE 'REWRITE I/O ERROR' TO WS-MSG-TEXT
                   END-IF
                   PERFORM 7000-WRITE-RPT-LINE
           END-READ.

      *----------------------------------------------------------------
      * RANDOM DELETE - remove an employee by key
      *----------------------------------------------------------------
       6000-DELETE-RECORD.
           MOVE TRAN-EMP-ID TO EMP-ID
           DELETE EMPFILE
               INVALID KEY
                   ADD 1 TO WS-DEL-ER-CNT
                   MOVE 'DEL-FAIL  ' TO WS-MSG-CODE
                   MOVE TRAN-EMP-ID  TO WS-MSG-KEY
                   MOVE 'RECORD NOT FOUND' TO WS-MSG-TEXT
               NOT INVALID KEY
                   ADD 1 TO WS-DEL-OK-CNT
                   MOVE 'DEL-OK    ' TO WS-MSG-CODE
                   MOVE TRAN-EMP-ID  TO WS-MSG-KEY
                   MOVE 'EMPLOYEE DELETED' TO WS-MSG-TEXT
           END-DELETE
           PERFORM 7000-WRITE-RPT-LINE.

       7000-WRITE-RPT-LINE.
           MOVE SPACES TO RPT-LINE
           STRING WS-MSG-CODE  DELIMITED BY SIZE
                  WS-MSG-KEY   DELIMITED BY SIZE
                  ' '          DELIMITED BY SIZE
                  WS-MSG-TEXT  DELIMITED BY SIZE
                  INTO RPT-LINE
           END-STRING
           WRITE RPT-LINE.

       8000-PRINT-SUMMARY.
           DISPLAY '----------------------------------------------'
           DISPLAY 'TRANSACTIONS READ   : ' WS-TRAN-CNT
           DISPLAY 'ADDS    SUCCESS/FAIL: ' WS-ADD-OK-CNT '/'
                                             WS-ADD-ER-CNT
           DISPLAY 'UPDATES SUCCESS/FAIL: ' WS-UPD-OK-CNT '/'
                                             WS-UPD-ER-CNT
           DISPLAY 'DELETES SUCCESS/FAIL: ' WS-DEL-OK-CNT '/'
                                             WS-DEL-ER-CNT
           DISPLAY '----------------------------------------------'.

       3000-CLOSE-FILES.
           CLOSE EMPTRAN
           CLOSE EMPFILE
           CLOSE RPTOUT.

       9000-READ-TRAN.
           READ EMPTRAN
               AT END
                   MOVE 'Y' TO WS-EOF-SW
           END-READ.
