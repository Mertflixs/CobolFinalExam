       IDENTIFICATION DIVISION.
      *------------------------------------------------*
       PROGRAM-ID.  MAINFNL.
       AUTHOR       MERT ALASAHAN.
      *------------------------------------------------*
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INP-FILE ASSIGN TO INPFILE
                           STATUS INP-ST.
           SELECT OUT-FILE ASSIGN TO OUTFILE
                           STATUS OUT-ST.
      *-----------------------------------------------*
       DATA DIVISION.
       FILE SECTION.
       FD OUT-FILE RECORDING MODE F.
       01 OUT-REC.
           05 OUT-REC-PROC-TYPE  PIC 9.
           05 FILLER             PIC X(05) VALUE SPACES.
           05 OUT-ID-O           PIC 9(5).
           05 FILLER             PIC X(02) VALUE SPACES.
           05 OUT-DVZ-O          PIC 9(3).
           05 FILLER             PIC X(02) VALUE SPACES.
           05 OUT-RC-O           PIC 9(2).
           05 FILLER             PIC X(02) VALUE SPACES.
           05 OUT-DATA-O.
               10 OUT-WRONG-EXP  PIC X(30).
               10 OUT-NAME-FROM  PIC X(15).
               10 OUT-SNAME-FROM PIC X(15).
               10 OUT-NAME-TO    PIC X(15).
               10 OUT-SNAME-TO   PIC X(15).
      *------------------------------------------------*
       FD INP-FILE RECORDING MODE F.
       01 INP-REC.
           05 INP-PROC-TYPE      PIC X.
           05 INP-ID             PIC X(5).
           05 INP-DVZ            PIC X(3).
      *------------------------------------------------*
       WORKING-STORAGE SECTION.
       01 WS-WORK-AREA.
           05 WS-SUBFNL          PIC X(6)  VALUE 'SUBFNL'.
           05 INP-ST             PIC 99.
               88 INP-SUC                  VALUE 00 97.
               88 INP-EOF                  VALUE 10.
           05 OUT-ST             PIC 99.
               88 OUT-SUC                  VALUE 00 97.
           05 WS-SUB-AREA.
               10 WS-SUB-FUNC    PIC 9.
                   88 WS-SUB-OPEN          VALUE 1.
                   88 WS-SUB-WRITE         VALUE 2.
                   88 WS-SUB-UPDATE        VALUE 3.
                   88 WS-SUB-DELETE        VALUE 4.
                   88 WS-SUB-READ          VALUE 5.
                   88 WS-SUB-CLOSE         VALUE 9.
               10 WS-SUB-ID       PIC 9(5).
               10 WS-SUB-DVZ      PIC 9(3).
               10 WS-SUB-RC       PIC 9(2).
               10 WS-SUB-DATA     PIC X(90).
       01 WS-HEADER.
           05 FILLER              PIC X(04) VALUE 'TYPE'.
           05 FILLER              PIC X(02) VALUE SPACES.
           05 FILLER              PIC X(02) VALUE 'ID'.
           05 FILLER              PIC X(05) VALUE SPACES.
           05 FILLER              PIC X(03) VALUE 'DVZ'.
           05 FILLER              PIC X(02) VALUE SPACES.
           05 FILLER              PIC X(02) VALUE 'RC'.
           05 FILLER              PIC X(02) VALUE SPACES.
           05 FILLER              PIC X(04) VALUE 'DATA'.
      *------------------------------------------------*
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM H100-INITIALIZE.
           PERFORM H200-PROCESS UNTIL INP-EOF.
           PERFORM H900-CLOSE.
       MAIN-END. EXIT.
      *------------------------------------------------*
      *PROGRAM PREPARATION PHASE
      *------------------------------------------------*
       H100-INITIALIZE.
           OPEN INPUT INP-FILE.
           OPEN OUTPUT OUT-FILE.
           PERFORM H101-INITIALIZE-CONT.
           SET WS-SUB-OPEN TO TRUE.
           CALL WS-SUBFNL USING WS-SUB-AREA.
           MOVE WS-HEADER TO OUT-REC.
           WRITE OUT-REC.
           READ INP-FILE.
       H100-END. EXIT.
      *------------------------------------------------*
      *FILE OPEN CONTROLL
      *------------------------------------------------*
       H101-INITIALIZE-CONT.
           IF (INP-ST NOT = 0) AND (INP-ST NOT = 97)
             DISPLAY 'INP-FILE OPEN ERROR: ' INP-ST
             MOVE INP-ST TO RETURN-CODE
             PERFORM H900-CLOSE
           END-IF.

           IF (OUT-ST NOT = 0) AND (OUT-ST NOT = 97)
             DISPLAY 'OUT-FILE OPEN ERROR: ' OUT-ST
             MOVE OUT-ST TO RETURN-CODE
             PERFORM H900-CLOSE
           END-IF.
       H101-END. EXIT.
      *------------------------------------------------*
      *PROGRAM LIFE CIRCLE
      *------------------------------------------------*
       H200-PROCESS.
           PERFORM H201-PROCESS-CONT.
           CALL WS-SUBFNL USING WS-SUB-AREA.
           MOVE SPACES TO OUT-REC.
           MOVE WS-SUB-FUNC TO OUT-REC-PROC-TYPE.
           MOVE WS-SUB-ID TO OUT-ID-O.
           MOVE WS-SUB-DVZ TO OUT-DVZ-O.
           MOVE WS-SUB-RC TO OUT-RC-O.
           MOVE WS-SUB-DATA TO OUT-DATA-O.
      *    MOVE WS-SUB-AREA TO OUT-REC.
           WRITE OUT-REC.
           READ INP-FILE.
       H200-END. EXIT.
      *------------------------------------------------*
      *PROGRAM CONVERSION COMP-3 TO NUM
      *------------------------------------------------*
       H201-PROCESS-CONT.
           IF (INP-ST NOT = 0) AND (INP-ST NOT = 97)
             DISPLAY 'INP-FILE READ ERROR: ' INP-ST
             MOVE INP-ST TO RETURN-CODE
             PERFORM H900-CLOSE
           END-IF.
           COMPUTE WS-SUB-FUNC = FUNCTION NUMVAL(INP-PROC-TYPE).
           COMPUTE WS-SUB-ID = FUNCTION NUMVAL(INP-ID).
           COMPUTE WS-SUB-DVZ = FUNCTION NUMVAL(INP-DVZ).
       H201-END. EXIT.
      *------------------------------------------------*
      *PROGRAM CLOSE
      *------------------------------------------------*
       H900-CLOSE.
           IF WS-SUB-OPEN
             SET WS-SUB-CLOSE TO TRUE
             CALL WS-SUBFNL USING WS-SUB-AREA
           END-IF.
           CLOSE INP-FILE.
           CLOSE OUT-FILE.
           STOP RUN.
       H900-END. EXIT.
