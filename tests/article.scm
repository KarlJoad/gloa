(define-module (test-article-info)
  #:use-module (gloa article)
  #:use-module (srfi srfi-64))

(test-begin "article-info")

(test-assert "create article"
  (make-article "Test title"
                '("FirstName1 LastName1"
                  "FirstName2 LastName2")))

(test-end "article-info")
