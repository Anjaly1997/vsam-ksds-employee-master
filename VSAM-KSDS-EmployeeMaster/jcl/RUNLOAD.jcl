//RUNLOAD  JOB (ACCTNO),'LOAD EMP MASTER',CLASS=A,MSGCLASS=A,
//             NOTIFY=&SYSUID
//*----------------------------------------------------------------
//* Runs EMPLOAD - loads EMPDATA (sequential) into EMPFILE (KSDS).
//*----------------------------------------------------------------
//STEP010  EXEC PGM=EMPLOAD
//STEPLIB  DD DSN=YOURHLQ.LOADLIB,DISP=SHR
//EMPDATA  DD DSN=YOURHLQ.SEQ.EMPDATA,DISP=SHR
//EMPFILE  DD DSN=YOURHLQ.VSAM.EMPFILE,DISP=SHR
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
