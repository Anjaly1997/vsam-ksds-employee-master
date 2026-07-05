//RUNUPDT  JOB (ACCTNO),'UPDATE EMP MASTER',CLASS=A,MSGCLASS=A,
//             NOTIFY=&SYSUID
//*----------------------------------------------------------------
//* Runs EMPUPDT - applies ADD/UPDATE/DELETE transactions from
//* EMPTRAN (sequential) against EMPFILE (KSDS) using random access.
//*----------------------------------------------------------------
//STEP010  EXEC PGM=EMPUPDT
//STEPLIB  DD DSN=YOURHLQ.LOADLIB,DISP=SHR
//EMPTRAN  DD DSN=YOURHLQ.SEQ.EMPTRAN,DISP=SHR
//EMPFILE  DD DSN=YOURHLQ.VSAM.EMPFILE,DISP=SHR
//RPTOUT   DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
