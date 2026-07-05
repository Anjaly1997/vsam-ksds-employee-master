       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPRPT.
      ******************************************************************
      * PROGRAM    : EMPRPT
      * PURPOSE    : Produces a formatted Employee Master listing by
      *              reading the VSAM KSDS (EMPFILE) purely SEQUENTIALLY
      *              (START + READ NEXT) in ascending key order, with a
      *              control break on EMP-DEPT (department subtotals)
      *              and a grand total at the end.
      ******************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EMPFILE ASSIGN TO EMPFILE
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS EMP-ID
               FILE STATUS IS WS-FILE-STATUS.

           SELECT RPTOUT ASSIGN TO RPTOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-RPT-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  EMPFILE.
       COPY EMPREC.

       FD  RPTOUT
           RECORDING MODE IS F.
       01  RPT-LINE                PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS          PIC XX     VALUE SPACES.
       01  WS-RPT-STATUS           PIC XX     VALUE SPACES.
       01  WS-EOF-SW               PIC X      VALUE 'N'.
           88  END-OF-FILE                    VALUE 'Y'.
       01  WS-FIRST-REC-SW         PIC X      VALUE 'Y'.
           88  FIRST-RECORD                   VALUE 'Y'.
       01  WS-PREV-DEPT            PIC X(10)  VALUE SPACES.
       01  WS-LINE-CNT             PIC 9(03)  VALUE ZERO.
       01  WS-PAGE-CNT             PIC 9(03)  VALUE ZERO.
       01  WS-DEPT-TOTAL           PIC 9(09)V99 VALUE ZERO.
       01  WS-DEPT-COUNT           PIC 9(05)  VALUE ZERO.
       01  WS-GRAND-TOTAL          PIC 9(09)V99 VALUE ZERO.
       01  WS-GRAND-COUNT          PIC 9(05)  VALUE ZERO.

       01  WS-HDR-1.
           05  FILLER              PIC X(20)  VALUE 'EMPLOYEE MASTER LIST'.
           05  FILLER              PIC X(10)  VALUE SPACES.
           05  FILLER              PIC X(05)  VALUE 'PAGE '.
           05  WS-HDR-PAGE         PIC ZZ9.
       01  WS-HDR-2.
           05  FILLER              PIC X(06)  VALUE 'EMP-ID'.
           05  FILLER              PIC X(02)  VALUE SPACES.
           05  FILLER              PIC X(25)  VALUE 'NAME'.
           05  FILLER              PIC X(10)  VALUE 'DEPT'.
           05  FILLER              PIC X(12)  VALUE 'SALARY'.
           05  FILLER              PIC X(10)  VALUE 'DOJ'.

       01  WS-DETAIL-LINE.
           05  WS-D-ID             PIC X(06).
           05  FILLER              PIC X(02)  VALUE SPACES.
           05  WS-D-NAME           PIC X(25).
           05  WS-D-DEPT           PIC X(10).
           05  WS-D-SALARY         PIC ZZZ,ZZZ,ZZ9.99.
           05  FILLER              PIC X(02)  VALUE SPACES.
           05  WS-D-DOJ            PIC X(10).

       01  WS-DEPT-TOTAL-LINE.
           05  FILLER              PIC X(20)  VALUE
               '  ** DEPT TOTAL **  '.
           05  WS-DT-DEPT          PIC X(10).
           05  FILLER              PIC X(02)  VALUE SPACES.
           05  WS-DT-COUNT         PIC ZZ9.
           05  FILLER              PIC X(10)  VALUE ' EMPLOYEES'.
           05  FILLER              PIC X(02)  VALUE SPACES.
           05  WS-DT-SALARY        PIC ZZZ,ZZZ,ZZ9.99.

       01  WS-GRAND-TOTAL-LINE.
           05  FILLER              PIC X(20)  VALUE
               '** GRAND TOTAL **   '.
           05  WS-GT-COUNT         PIC ZZ9.
           05  FILLER              PIC X(10)  VALUE ' EMPLOYEES'.
           05  FILLER              PIC X(02)  VALUE SPACES.
           05  WS-GT-SALARY        PIC ZZZ,ZZZ,ZZ9.99.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY 'EMPRPT : EMPLOYEE MASTER REPORT - STARTING'
           PERFORM 1000-OPEN-FILES
           PERFORM 2000-PROCESS-UNTIL-EOF
               UNTIL END-OF-FILE
           IF NOT FIRST-RECORD
               PERFORM 5000-PRINT-DEPT-TOTAL
           END-IF
           PERFORM 6000-PRINT-GRAND-TOTAL
           PERFORM 3000-CLOSE-FILES
           DISPLAY 'EMPRPT : EMPLOYEE MASTER REPORT - COMPLETE'
           STOP RUN.

       1000-OPEN-FILES.
           OPEN INPUT EMPFILE
           OPEN OUTPUT RPTOUT
           IF WS-FILE-STATUS NOT = '00'
               DISPLAY 'ERROR OPENING EMPFILE. STATUS=' WS-FILE-STATUS
               STOP RUN
           END-IF
      * START at the beginning of the file, then READ NEXT
           MOVE LOW-VALUES TO EMP-ID
           START EMPFILE KEY IS NOT LESS THAN EMP-ID
               INVALID KEY
                   MOVE 'Y' TO WS-EOF-SW
           END-START
           IF NOT END-OF-FILE
               PERFORM 9000-READ-NEXT
           END-IF.

       2000-PROCESS-UNTIL-EOF.
           IF FIRST-RECORD
               MOVE EMP-DEPT TO WS-PREV-DEPT
               MOVE 'N' TO WS-FIRST-REC-SW
           END-IF

           IF EMP-DEPT NOT = WS-PREV-DEPT
               PERFORM 5000-PRINT-DEPT-TOTAL
               MOVE EMP-DEPT TO WS-PREV-DEPT
           END-IF

           PERFORM 4000-PRINT-DETAIL

           ADD EMP-SALARY TO WS-DEPT-TOTAL, WS-GRAND-TOTAL
           ADD 1 TO WS-DEPT-COUNT, WS-GRAND-COUNT

           PERFORM 9000-READ-NEXT.

       4000-PRINT-DETAIL.
           IF WS-LINE-CNT = 0
               PERFORM 4500-PRINT-HEADERS
           END-IF
           MOVE EMP-ID     TO WS-D-ID
           MOVE EMP-NAME   TO WS-D-NAME
           MOVE EMP-DEPT   TO WS-D-DEPT
           MOVE EMP-SALARY TO WS-D-SALARY
           MOVE EMP-DOJ    TO WS-D-DOJ
           WRITE RPT-LINE FROM WS-DETAIL-LINE
           ADD 1 TO WS-LINE-CNT
           IF WS-LINE-CNT > 50
               MOVE 0 TO WS-LINE-CNT
           END-IF.

       4500-PRINT-HEADERS.
           ADD 1 TO WS-PAGE-CNT
           MOVE WS-PAGE-CNT TO WS-HDR-PAGE
           WRITE RPT-LINE FROM WS-HDR-1
           MOVE SPACES TO RPT-LINE
           WRITE RPT-LINE
           WRITE RPT-LINE FROM WS-HDR-2.

       5000-PRINT-DEPT-TOTAL.
           MOVE WS-PREV-DEPT   TO WS-DT-DEPT
           MOVE WS-DEPT-COUNT  TO WS-DT-COUNT
           MOVE WS-DEPT-TOTAL  TO WS-DT-SALARY
           MOVE SPACES TO RPT-LINE
           WRITE RPT-LINE
           WRITE RPT-LINE FROM WS-DEPT-TOTAL-LINE
           MOVE ZERO TO WS-DEPT-TOTAL, WS-DEPT-COUNT.

       6000-PRINT-GRAND-TOTAL.
           MOVE WS-GRAND-COUNT  TO WS-GT-COUNT
           MOVE WS-GRAND-TOTAL  TO WS-GT-SALARY
           MOVE SPACES TO RPT-LINE
           WRITE RPT-LINE
           WRITE RPT-LINE FROM WS-GRAND-TOTAL-LINE.

       3000-CLOSE-FILES.
           CLOSE EMPFILE
           CLOSE RPTOUT.

       9000-READ-NEXT.
           READ EMPFILE NEXT RECORD
               AT END
                   MOVE 'Y' TO WS-EOF-SW
           END-READ.
