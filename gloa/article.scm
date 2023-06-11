(define-module (gloa article)
  #:use-module (gloa utils)
  #:use-module (srfi srfi-9) ; Records
  #:export (article
            make-article
            article?
            article-title
            article-authors
            serialize-article-authors
            deserialize-article-authors))

(define-record-type <article>
  (make-article title authors)
  article?
  (title article-title)
  (authors article-authors))

(define (serialize-article-authors author-list)
  (string-join author-list " and "))

(define (deserialize-article-authors author-string)
  (string-split-substring author-string " and "))
