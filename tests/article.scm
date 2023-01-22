(define-module (test-article-info)
  #:use-module (gloa article)
  #:use-module (srfi srfi-64))

(define %test-title "Test title")
(define %test-authors
  '("FirstName1 LastName1"
    "FirstName2 MI. LastName2"))

(define %test-article
  (make-article %test-title %test-authors))

(test-begin "article-creation")

(test-assert "create article"
  (make-article "Test title"
                '("FirstName1 LastName1"
                  "FirstName2 LastName2")))

(test-end "article-creation")
