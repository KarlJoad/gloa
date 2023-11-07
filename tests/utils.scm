(define-module (tests utils)
  #:use-module (srfi srfi-64)
  #:export (with-tests
            test-database-path))

;; Taken from Haunt commit 4848354
;; https://git.dthompson.us/haunt.git/tree/tests/utils.scm?id=4848354e9be7c4f444ef44a586560f71f50a8673

(define-syntax-rule (with-tests name body ...)
  (begin
    (test-begin name)
    body ...
    (exit (zero? (test-runner-fail-count (test-end))))))

(define (test-database-path)
  "When called, return a fairly-unique path for a database.
This is @emph{not} a particularly random path, but should be good enough for
small tests."
  ;; FIXME: tmpnam is NOT assured to return a unique path!
  ;; (guile) File System "A loop can try again with another name if the file
  ;; exists (error ‘EEXIST’)."
  (string-append (tmpnam) ".db"))
