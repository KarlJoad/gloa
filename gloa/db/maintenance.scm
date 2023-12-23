(define-module (gloa db maintenance)
  #:use-module (gloa config)
  #:use-module (sqlite3)
  #:export (vacuum-db))

(define (vacuum-db)
  "Vacuum Gloa's SQLite database.
Vacuuming defragments and compacts the database file on-disk, reducing its size."
  (with-db (gloa-db-location)
    (query* "VACUUM")))
