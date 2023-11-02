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

;; TODO: Make this a GOOPS class? Then the constructor takes in the alist from
;; an importer meta-class?
(define-record-type <article>
  (%make-article title authors path)
  article?
  (title article-title)
  (authors article-authors)
  (path article-path))

(define* (make-article title authors #:optional (path ""))
  (%make-article title authors path))

(define (serialize-article-authors author-list)
  (string-join author-list " and "))

(define (deserialize-article-authors author-string)
  (string-split-substring author-string " and "))
