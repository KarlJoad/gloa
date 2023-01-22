(define-module (tests utils)
  #:use-module (srfi srfi-64)
  #:export (with-tests))

;; Taken from Haunt commit 4848354
;; https://git.dthompson.us/haunt.git/tree/tests/utils.scm?id=4848354e9be7c4f444ef44a586560f71f50a8673

(define-syntax-rule (with-tests name body ...)
  (begin
    (test-begin name)
    body ...
    (exit (zero? (test-runner-fail-count (test-end))))))
