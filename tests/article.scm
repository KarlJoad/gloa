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

(test-begin "article-accessors")

(test-equal "article title"
  %test-title
  (article-title %test-article))

(test-equal "article authors"
  %test-authors
  (article-authors %test-article))

(test-end "article-accessors")

(test-begin "article-is-article")

(test-assert "article-is-article"
  (article? %test-article))

(test-end "article-is-article")
