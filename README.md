# VSAM KSDS Employee Master File – COBOL Batch Suite

A mainframe COBOL project simulating a real production **Employee Master
File** built on a **VSAM KSDS**, demonstrating both **sequential** and
**random access** processing patterns — the two things most candidate
portfolios skip.

## Business Scenario

An HR department maintains an Employee Master file. Three batch jobs
work against it:

| Program   | Access Mode           | What it does |
|-----------|------------------------|--------------|
| `EMPLOAD` | Sequential **WRITE**    | One-time initial load of the KSDS from a flat file |
| `EMPUPDT` | Sequential read of transactions + **RANDOM** read/write/rewrite/delete of the KSDS | Applies daily Add / Update / Delete transactions to the master |
| `EMPRPT`  | Sequential **START + READ NEXT** | Prints the full master list in key order with department subtotals and a grand total |

This mirrors the standard mainframe batch cycle: **load → update → report**.

## File Layout (EMPFILE – VSAM KSDS)

Record length 61, key = `EMP-ID` (positions 1–6):

```
05  EMP-ID              PIC X(06).     <- KEY
05  EMP-NAME            PIC X(25).
05  EMP-DEPT            PIC X(10).
05  EMP-SALARY          PIC 9(07)V99.
05  EMP-DOJ             PIC X(10).
05  EMP-STATUS          PIC X(01).
```

See `copybook/EMPREC.cpy` and `copybook/TRANREC.cpy`.

## Project Structure

```
VSAM-KSDS-EmployeeMaster/
├── copybook/
│   ├── EMPREC.cpy        Master record layout (shared by all 3 programs)
│   └── TRANREC.cpy        Transaction record layout
├── cobol/
│   ├── EMPLOAD.cbl        Initial load  (sequential WRITE)
│   ├── EMPUPDT.cbl        Add/Update/Delete (sequential in, random master I/O)
│   └── EMPRPT.cbl         Master listing (sequential START + READ NEXT, control breaks)
├── jcl/
│   ├── DEFKSDS.jcl        IDCAMS DEFINE CLUSTER for the KSDS
│   ├── COMPILE.jcl        Compile/link all 3 programs (IGYWCL)
│   ├── RUNLOAD.jcl        Run EMPLOAD
│   ├── RUNUPDT.jcl        Run EMPUPDT
│   └── RUNRPT.jcl         Run EMPRPT
├── data/
│   ├── EMPDATA.txt        Sample initial load data (10 employees)
│   └── EMPTRAN.txt        Sample transactions (2 adds, 2 updates, 1 delete, 2 deliberate errors)
```

## How to Run on a z/OS mainframe

1. Upload `copybook/*.cpy` to `YOURHLQ.COPYLIB`.
2. Upload `cobol/*.cbl` to `YOURHLQ.SOURCE`.
3. Upload `data/EMPDATA.txt` to `YOURHLQ.SEQ.EMPDATA` (LRECL=61, FB) and
   `data/EMPTRAN.txt` to `YOURHLQ.SEQ.EMPTRAN` (LRECL=69, FB).
4. Edit `YOURHLQ` / `VOLSER` placeholders in the JCL to match your environment.
5. Submit `jcl/DEFKSDS.jcl` to define the VSAM cluster.
6. Submit `jcl/COMPILE.jcl` to compile and link all three programs.
7. Submit `jcl/RUNLOAD.jcl` to load the initial 10 employees.
8. Submit `jcl/RUNUPDT.jcl` to apply the sample transactions.
9. Submit `jcl/RUNRPT.jcl` to print the final master listing (check `RPTOUT` in SDSF).

## How to Test Locally (no mainframe access)

You can compile-check the COBOL syntax locally with
[GnuCOBOL](https://gnucobol.sourceforge.io/) (`sudo apt install gnucobol`).
GnuCOBOL supports `ORGANIZATION IS INDEXED` files, which is a close
functional analog to a VSAM KSDS for demonstrating the logic (it will
not exercise real VSAM-specific JCL/IDCAMS behavior, but proves the
COBOL is syntactically correct and the I/O logic works):

```bash
cobc -x -free copybook/EMPREC.cpy   # (copybooks aren't compiled directly, just for reference)
cobc -x -I copybook cobol/EMPLOAD.cbl -o empload
cobc -x -I copybook cobol/EMPUPDT.cbl -o empupdt
cobc -x -I copybook cobol/EMPRPT.cbl  -o emprpt
```



