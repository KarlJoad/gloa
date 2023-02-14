(define-module (test-db)
  #:use-module (gloa db)
  #:use-module (srfi srfi-64)
  #:use-module (tests utils))

(define %testing-database-path "test.db")

(define (cleanup-test-db db)
  "Close DB and remove its file as cleanup when done using the testing database.
If the database pointer passed in DB is already closed, this procedure runs without
exception, deleting the database file.
If the file does not exist, then an exception is raised."
  (close-db db)
  (delete-file %testing-database-path))

(with-tests "db-tests"
  (test-error "open-missing-db" 'sqlite-error
    (open-db "not-present.db")))
