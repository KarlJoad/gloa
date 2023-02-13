(define-module (gloa db)
  #:use-module (sqlite3)
  #:export (open-db))

(define (open-db db-path)
  "Open the SQLite3 database at the provided DB-PATH.
If the database has not been created at DB-PATH, an error is raised.
Requires that db-path actually be an SQLite3 database."
  (sqlite-open db-path (logior SQLITE_OPEN_READWRITE)))
