(define-module (gloa db)
  #:use-module (sqlite3)
  #:use-module (ice-9 textual-ports)
  #:export (init-db
            open-db
            close-db))

(define %GLOA_SCHEMA_FILE "data/schema.sql")

(define (init-db db-path)
  "Create a SQLite3 database with FILENAME and open for reading and writing,
returning it.
Initialize the database with the schema in %GLOA_SCHEMA_FILE."
  (define (create-db db-path)
    (sqlite-open db-path (logior SQLITE_OPEN_READWRITE SQLITE_OPEN_CREATE)))
  (let ((db (create-db db-path)))
    (sqlite-exec db (call-with-input-file %GLOA_SCHEMA_FILE get-string-all))
    db))

(define (open-db db-path)
  "Open the SQLite3 database at the provided DB-PATH.
If the database has not been created at DB-PATH, an error is raised.
Requires that db-path actually be an SQLite3 database."
  (sqlite-open db-path (logior SQLITE_OPEN_READWRITE)))

(define (close-db db)
  "Close the provided DB connection."
  (sqlite-close db))
