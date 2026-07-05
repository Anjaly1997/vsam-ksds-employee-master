//RUNRPT   JOB (ACCTNO),'EMP MASTER REPORT',CLASS=A,MSGCLASS=A,
//             NOTIFY=&SYSUID
//*----------------------------------------------------------------
//* Runs EMPRPT - sequential (START + READ NEXT) listing of EMPFILE
//* with department control breaks and a grand total.
//*----------------------------------------------------------------
//STEP010  EXEC PGM=EMPRPT
//STEPLIB  DD DSN=YOURHLQ.LOADLIB,DISP=SHR
//EMPFILE  DD DSN=YOURHLQ.VSAM.EMPFILE,DISP=SHR
//RPTOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
