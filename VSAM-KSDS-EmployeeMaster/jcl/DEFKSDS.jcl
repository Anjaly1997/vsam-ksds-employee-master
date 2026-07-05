//DEFKSDS  JOB (ACCTNO),'DEFINE VSAM KSDS',CLASS=A,MSGCLASS=A,
//             NOTIFY=&SYSUID
//*----------------------------------------------------------------
//* Defines the Employee Master VSAM KSDS cluster used by
//* EMPLOAD / EMPUPDT / EMPRPT.
//* Replace YOURHLQ and VOLSER with values for your environment.
//*----------------------------------------------------------------
//STEP010  EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
    DELETE (YOURHLQ.VSAM.EMPFILE) CLUSTER PURGE
    SET MAXCC = 0

    DEFINE CLUSTER (NAME(YOURHLQ.VSAM.EMPFILE)    -
           INDEXED                                -
           KEYS(6 0)                              -
           RECORDSIZE(61 61)                      -
           FREESPACE(10 10)                       -
           VOLUMES(VOLSER)                        -
           TRACKS(5 2)                            -
           SHAREOPTIONS(2 3) )                    -
           DATA  (NAME(YOURHLQ.VSAM.EMPFILE.DATA)) -
           INDEX (NAME(YOURHLQ.VSAM.EMPFILE.INDX))

    PRINT INFILE(EMPFILE) COUNT(1)
/*
