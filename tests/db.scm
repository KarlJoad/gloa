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

(define testing-db-conn (make-parameter #f))

(with-tests "db-tests"
  (test-error "open-missing-db" 'sqlite-error
    (open-db "not-present.db"))

  (test-group-with-cleanup "create-db"
    (test-assert "create-db"
      (begin (testing-db-conn ((@@ (gloa db) create-db) %testing-database-path))
             (testing-db-conn)))
    (cleanup-test-db (testing-db-conn)))

  (test-group-with-cleanup "db-operations"
    (test-assert "init-db"
      (begin
        (testing-db-conn (init-db %testing-database-path))
        (testing-db-conn)))

    (cleanup-test-db (testing-db-conn))))
