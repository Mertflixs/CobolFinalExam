       IDENTIFICATION DIVISION.
      *------------------------------------------------*
       PROGRAM-ID. SUBFNL.
       AUTHOR.     MERT ALASAHAN.
      *------------------------------------------------*
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT IDX-FILE ASSIGN TO IDXFILE
                           ORGANIZATION INDEXED
                           ACCESS RANDOM
                           RECORD KEY IDX-KEY
                           STATUS IDX-ST.
       DATA DIVISION.
       FILE SECTION.
      *--------------------------------------------------*
      *SUB-FRAME INP IDX-FILE FILE CONTENT
      *--------------------------------------------------*
       FD IDX-FILE.
       01 IDX-REC.
           05 IDX-KEY.
               10 IDX-ID       PIC S9(5) COMP-3.
               10 IDX-DVZ      PIC S9(3) COMP.
           05 IDX-NAME         PIC X(15).
           05 IDX-SURNAME      PIC X(15).
           05 IDX-DATE         PIC S9(7) COMP-3.
           05 IDX-BALANCE      PIC S9(15) COMP-3.
       WORKING-STORAGE SECTION.
      *-------------------------------------------------*
      *SUB-FRAME PROGRAM REQUIREMENTS USED
      *--------------------------------------------------*
       01 WS-REC.
           05 I                PIC 9(2) VALUE 01.
           05 J                PIC 9(2) VALUE 01.
           05 FLAG             PIC 9    VALUE 0.
           05 IDX-ST           PIC 99.
               88 IDX-OK                VALUE 00 97.
               88 IDX-EOF               VALUE 10.
      *--------88 WS-OPEN               VALUE 'Y'.-------*
           05 WS-FUNC          PIC 9.
               88 WS-OPEN               VALUE 1.
               88 WS-WRITE              VALUE 2.
               88 WS-UPDATE             VALUE 3.
               88 WS-DELETE             VALUE 4.
               88 WS-READ               VALUE 5.
               88 WS-CLOSE              VALUE 9.
      *--------------------------------------------------*
      *SUB-FRAME INHERITANCE MAIN-FRAME
      *--------------------------------------------------*
       LINKAGE SECTION.
       01  LK-REC.
           05 LK-FUNC           PIC 9.
           05 LK-ID             PIC 9(5).
           05 LK-DVZ            PIC 9(3).
           05 LK-RC             PIC 9(2).
           05 LK-DATA.
               10 LK-WRONG-EXP  PIC X(30).
               10 LK-NAME-FROM  PIC X(15).
               10 LK-NAME-TO    PIC X(15).
               10 LK-SNAME-FROM PIC X(15).
               10 LK-SNAME-TO   PIC X(15).
      *--------------------------------------------------*
       PROCEDURE DIVISION USING LK-REC.
       0000-MAIN.
           PERFORM 1000-INITIALIZE.
       0000-END. EXIT.
      *--------------------------------------------------*
      *SUB-FRAME LIFE CIRCLE
      *--------------------------------------------------*
       1000-INITIALIZE.
           MOVE SPACES TO LK-DATA.
           MOVE LK-FUNC TO WS-FUNC.
           EVALUATE TRUE
               WHEN WS-OPEN
                    PERFORM 2000-OPEN
               WHEN WS-WRITE
                    PERFORM 3000-WRITE
               WHEN WS-UPDATE
                    PERFORM 4000-UPDATE
               WHEN WS-DELETE
                    PERFORM 5000-DELETE
               WHEN WS-READ
                    PERFORM 6000-READ
               WHEN WS-CLOSE
                    PERFORM 7000-CLOSE
               WHEN OTHER
                    MOVE 'WRONG FUNCTION CODE' TO LK-WRONG-EXP
           END-EVALUATE.
       1000-END. EXIT.
      *--------------------------------------------------*
      *PROGRAM READ AND CONTROL FUNCTION
      *--------------------------------------------------*
       1001-READ-CONT.
           MOVE LK-ID TO IDX-ID.
           MOVE LK-DVZ TO IDX-DVZ.
           READ IDX-FILE KEY IS IDX-KEY
           INVALID KEY
           STRING 'DOES NOT EXIST'
            DELIMITED BY SIZE INTO LK-WRONG-EXP
           MOVE 'NO NAME' TO LK-NAME-FROM
           MOVE 'NO SURNAME' TO LK-SNAME-FROM
           MOVE IDX-ST TO LK-RC
           GOBACK
           END-READ.
           MOVE IDX-ST TO LK-RC.
       1001-END. EXIT.
      *--------------------------------------------------*
      *SUB-FRAME OPEN FILE FUNCTION
      *--------------------------------------------------*
       2000-OPEN.
           OPEN I-O IDX-FILE.
           IF (IDX-ST NOT = 0) AND (IDX-ST NOT = 97)
               DISPLAY 'IDX-FILE OPEN ERROR : ' IDX-ST
               MOVE IDX-ST TO RETURN-CODE
               STOP RUN
           END-IF.
           GOBACK.
       2000-END. EXIT.
      *--------------------------------------------------*
      *SUB-FRAME WRITE NEW USER IN FILE FUNCTION
      *--------------------------------------------------*
       3000-WRITE.
           MOVE LK-ID TO IDX-ID.
           MOVE LK-DVZ TO IDX-DVZ.
           READ IDX-FILE KEY IS IDX-KEY
            INVALID KEY
            MOVE 1 TO FLAG
           END-READ.
           IF FLAG = 1
               MOVE 'MERT' TO IDX-NAME
               MOVE 'ALASAHAN' TO IDX-SURNAME
               MOVE 'NEW RECCORD SUCCESSFULLY' TO LK-WRONG-EXP
               MOVE ZEROES TO IDX-DATE
               MOVE ZEROES TO IDX-BALANCE
               MOVE IDX-NAME TO LK-NAME-FROM
               MOVE IDX-SURNAME TO LK-SNAME-FROM
               WRITE IDX-REC
               MOVE IDX-ST TO LK-RC
               MOVE 0 TO FLAG
           ELSE
               MOVE 'RECORD ALREADY EXISTS' TO LK-WRONG-EXP
               WRITE IDX-REC
               MOVE IDX-NAME TO LK-NAME-FROM
               MOVE IDX-SURNAME TO LK-SNAME-FROM
               MOVE IDX-ST TO LK-RC
           END-IF.
           GOBACK.
       3000-END. EXIT.
      *--------------------------------------------------*
      *SUB-FRAME USER UPDATED IN FILE FUNCTION
      *--------------------------------------------------*
       4000-UPDATE.
           PERFORM 1001-READ-CONT
           MOVE IDX-NAME TO LK-NAME-FROM
           MOVE IDX-SURNAME TO LK-SNAME-FROM
           PERFORM UNTIL I > LENGTH OF IDX-NAME
              IF IDX-NAME(I:1) NOT = SPACE
                 MOVE IDX-NAME(I:1) TO LK-NAME-TO(J:1)
                 ADD 1 TO J
              END-IF
              ADD 1 TO I
           END-PERFORM.
           IF LK-NAME-FROM = LK-NAME-TO
               MOVE 'SPACE NOT ALLOWED' TO LK-WRONG-EXP
           ELSE
               MOVE 'NAME UPDATED' TO LK-WRONG-EXP
           END-IF.
           INSPECT IDX-SURNAME REPLACING ALL 'E' BY 'I'
           INSPECT IDX-SURNAME REPLACING ALL 'A' BY 'E'
           MOVE LK-NAME-TO TO IDX-NAME
           MOVE IDX-SURNAME TO LK-SNAME-TO .
           REWRITE IDX-REC.
           GOBACK.
       4000-END. EXIT.
      *--------------------------------------------------*
      *SUB-FRAME DELETE USER IN FILE FUNCTION
      *--------------------------------------------------*
       5000-DELETE.
           PERFORM 1001-READ-CONT
           DELETE IDX-FILE.
           MOVE IDX-NAME TO LK-NAME-FROM
           MOVE IDX-SURNAME TO LK-SNAME-FROM
           MOVE 'DELETED SUCCESSFULLY' TO LK-WRONG-EXP.
           GOBACK.
       5000-END. EXIT.
      *--------------------------------------------------*
      *SUB-FRAME READ USER IN FILE FUNCTION
      *--------------------------------------------------*
       6000-READ.
           PERFORM 1001-READ-CONT
           MOVE 'READ SUCCESSFULLY' TO LK-WRONG-EXP.
           MOVE IDX-NAME TO LK-NAME-FROM
           MOVE IDX-SURNAME TO LK-SNAME-FROM
           GOBACK.
       6000-END. EXIT.
      *--------------------------------------------------*
      *SUB-FRAME CLOSE FUNCTION
      *--------------------------------------------------*
       7000-CLOSE.
           CLOSE IDX-FILE.
           MOVE 'CLOSED SUCCESSFULLY' TO LK-WRONG-EXP.
           MOVE IDX-NAME TO LK-NAME-FROM
           MOVE IDX-SURNAME TO LK-SNAME-FROM
           GOBACK.
       7000-END. EXIT.
