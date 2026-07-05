# Interview Talking Points

Keep these in your back pocket — this is the kind of project that lets you
speak from real understanding instead of buzzwords.

## Elevator pitch (30 seconds)

"I built a small batch suite around a VSAM KSDS employee master file —
an initial load program that writes sequentially, a transaction update
program that reads a transaction file sequentially but updates the
master randomly by key, and a reporting program that reads the whole
file sequentially in key order with department-level control breaks. It
mirrors the load-update-report cycle you'd see in a real payroll or HR
batch system."

## Likely follow-up questions and how to answer them

**Q: What's the difference between sequential and random access on a KSDS?**
Sequential access processes records in ascending key order — good for
full-file reporting or extracts (`EMPRPT` here). Random access jumps
straight to a record by key using the index component — good for
transaction processing where you only touch a handful of specific
records out of millions (`EMPUPDT` here). VSAM also supports DYNAMIC
mode, letting one program switch between the two.

**Q: How do you handle a duplicate key on a WRITE, or a not-found key
on a READ?**
Check `FILE STATUS` after every I/O, and use the `INVALID KEY` /
`NOT INVALID KEY` phrases on `READ`, `WRITE`, `REWRITE`, and `DELETE`
against indexed files. In `EMPUPDT.cbl` a duplicate ADD or a missing
UPDATE/DELETE key is logged and counted rather than abending the job.

**Q: Why use `START` before reading sequentially?**
`START` positions the file pointer at (or after) a given key so
`READ NEXT` begins in the right place — essential if you want to begin
partway through the file, e.g., report only employees from a certain
ID onward. In `EMPRPT.cbl` we `START` at `LOW-VALUES` to guarantee we
begin at the very first record.

**Q: What's a control break and why does it matter?**
It's the classic pattern of detecting when a key field changes
(here, `EMP-DEPT`) while reading a sequential/keyed file in order, so
you can print a subtotal for the group that just ended before starting
the next one. It's everywhere in COBOL batch reporting — sales by
region, transactions by account, etc.

**Q: How would you change this to run under CICS instead of batch?**
Replace the `OPEN`/`READ`/`WRITE`/`CLOSE` verbs with `EXEC CICS`
equivalents (`READ`, `WRITE`, `REWRITE`, `DELETE`, `STARTBR`/`READNEXT`
for browsing), and the file would be defined to CICS via an FCT/RDO
file resource instead of a JCL DD statement — the VSAM KSDS itself
doesn't change.

**Q: What would you add if you had more time?**
- REDEFINES / 88-levels for more realistic status codes
- A COBOL copybook-driven error/exception table instead of DISPLAY messages
- Alternate index (AIX) on `EMP-DEPT` for direct department lookups
- DB2 comparison talking point: KSDS gives you one key path; a
  relational table with proper indexes gives you many
