(define-module (gloa ops add)
  #:use-module (gloa config)
  #:use-module (gloa db add)
  #:use-module (gloa store add)
  #:export (add-document))

(define (add-document article article-path)
  "Register ARTICLE with the database and copy the document from ARTICLE-PATH to
the document store."
  (begin
    (add-to-db (gloa-db-location) article article-path)
    (add-to-store article article-path)))
