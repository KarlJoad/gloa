(define-module (test-db)
  #:use-module (gloa db)
  #:use-module (srfi srfi-64)
  #:use-module (tests utils))

(with-tests "db-tests"
  (test-error "open-missing-db" 'sqlite-error
    (open-db "not-present.db")))
