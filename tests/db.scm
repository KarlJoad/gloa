(define-module (test-db)
  #:use-module (gloa db)
  #:use-module (srfi srfi-64)
  #:use-module (tests utils))

(define %testing-database-path (test-database-path))

(define (cleanup-test-db db)
  "Close DB and remove its file as cleanup when done using the testing database.
If the database pointer passed in DB is already closed, this procedure runs without
exception, deleting the database file.
If the file does not exist, then an exception is raised."
  (close-db db)
  (delete-file %testing-database-path))

(define testing-db-conn (make-parameter #f))
(define second-db-connection (make-parameter #f))

(with-tests "db-create-open-close"
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

    ;; FIXME: Close the 2nd db connection after open completes
    (test-assert "open-db"
      (begin (second-db-connection (open-db %testing-database-path))
             (second-db-connection)))

    (test-assert "close-db"
      (let ((conn (open-db %testing-database-path)))
        (begin (close-db conn)
               (not ((@@ (sqlite3) db-open?) conn)))))

    ;; Closing the same connection multiple times is allowed, but does nothing
    (test-assert "close-db-multiple"
      (let ((conn (open-db %testing-database-path)))
        (begin (close-db conn)
               (close-db conn))))

    (cleanup-test-db (testing-db-conn))))
