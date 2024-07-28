Recovering from a disaster (restoring a PG instance from the dumps)


I. Ensure the new server is operational and the 
container's PGDATA folder has
    - permanent external storage mounted
    - which is adequately fast (IOPS, IO bandwidth)
    - preferably, protected by SPOF hardware failures (RAID)

II. Restore the global objects (roles, tablespaces)

This is dumped daily once, and has a simple .txt extension.

If you are using the "postgres" user/role to do the restore,
edit the globals and remove it from the dump.

Reason: the "postgres" user will be present in a fresh installation,
and the corresponding statements in the dump will fail.
Also including "DROP" statements in the dump before the "SET" is not
a solution, because current database connection's user cannot be
dropped.