       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPLOAD.
      ******************************************************************
      * PROGRAM    : EMPLOAD
      * PURPOSE    : One-time initial load of the VSAM KSDS Employee
      *              Master file (EMPFILE) from a sequential flat file
      *              (EMPDATA). Demonstrates SEQUENTIAL WRITE to a KSDS.
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPDATA ASSIGN TO EMPDATA
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-DATA-STATUS.

           SELECT EMPFILE ASSIGN TO EMPFILE
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS EMP-ID
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPDATA
           RECORDING MODE IS F.
       01  EMPDATA-REC             PIC X(61).

       FD  EMPFILE.
       COPY EMPREC.

       WORKING-STORAGE SECTION.
       01  WS-DATA-STATUS          PIC XX     VALUE SPACES.
       01  WS-FILE-STATUS          PIC XX     VALUE SPACES.
       01  WS-EOF-SW               PIC X      VALUE 'N'.
           88  END-OF-DATA                    VALUE 'Y'.
       01  WS-COUNTERS.
           05  WS-READ-CNT         PIC 9(05)  VALUE ZERO.
           05  WS-LOADED-CNT       PIC 9(05)  VALUE ZERO.
           05  WS-REJECT-CNT       PIC 9(05)  VALUE ZERO.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY 'EMPLOAD : INITIAL LOAD OF EMPFILE - STARTING'
           PERFORM 1000-OPEN-FILES
           PERFORM 2000-PROCESS-UNTIL-EOF
               UNTIL END-OF-DATA
           PERFORM 3000-CLOSE-FILES
           DISPLAY 'EMPLOAD : RECORDS READ    = ' WS-READ-CNT
           DISPLAY 'EMPLOAD : RECORDS LOADED  = ' WS-LOADED-CNT
           DISPLAY 'EMPLOAD : RECORDS REJECTED= ' WS-REJECT-CNT
           DISPLAY 'EMPLOAD : INITIAL LOAD OF EMPFILE - COMPLETE'
           STOP RUN.

       1000-OPEN-FILES.
           OPEN INPUT EMPDATA
           IF WS-DATA-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING EMPDATA. STATUS=' WS-DATA-STATUS
               STOP RUN
           END-IF

           OPEN OUTPUT EMPFILE
           IF WS-FILE-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING EMPFILE. STATUS=' WS-FILE-STATUS
               STOP RUN
           END-IF

           PERFORM 9000-READ-EMPDATA.

       2000-PROCESS-UNTIL-EOF.
           ADD 1 TO WS-READ-CNT
           MOVE EMPDATA-REC TO EMP-RECORD
           WRITE EMP-RECORD
           IF WS-FILE-STATUS = '00'
               ADD 1 TO WS-LOADED-CNT
           ELSE
               ADD 1 TO WS-REJECT-CNT
               DISPLAY 'WRITE FAILED FOR KEY ' EMP-ID
                       ' STATUS=' WS-FILE-STATUS
           END-IF
           PERFORM 9000-READ-EMPDATA.

       3000-CLOSE-FILES.
           CLOSE EMPDATA
           CLOSE EMPFILE.

       9000-READ-EMPDATA.
           READ EMPDATA
               AT END
                   MOVE 'Y' TO WS-EOF-SW
           END-READ.
