(define-module (test-article-info)
  #:use-module (gloa article)
  #:use-module (srfi srfi-64)
  #:use-module (tests utils))

(define %test-title "Test title")
(define %test-authors
  '("FirstName1 LastName1"
    "FirstName2 MI. LastName2"))

(define %test-article
  (make-article %test-title %test-authors))

(with-tests "article-creation"
  (test-assert "create article"
    (make-article "Test title"
                  '("FirstName1 LastName1"
                    "FirstName2 LastName2"))))

(with-tests "article-accessors"
  (test-equal "article title"
    %test-title
    (article-title %test-article))

  (test-equal "article authors"
    %test-authors
    (article-authors %test-article)))

(with-tests "article-is-article"
  (test-assert "article-is-article"
    (article? %test-article)))
