(define-module (gloa db search)
  #:use-module (gloa db)
  #:use-module (gloa db utils)
  #:use-module (gloa article)
  #:export (find-article-by-title))

;; FIXME: Harden these functions and
(define (find-article-by-title db-path article)
  "Attempt to find ARTICLE. If the article does not exist, return #f."
  (with-db db-path
    (let* ((title (article-title article))
           (doc-id (list-ref
                    (query* to-id "SELECT * FROM documents WHERE title = :title"
                            (title title))
                    0))
           (author-list
            (query* (lambda (info) (vector-ref info 0))
                    "SELECT name FROM authors WHERE id IN
(SELECT author_id FROM documents_authors_link WHERE document_id = :docid)"
                    (docid doc-id))))
      (make-article title author-list))))
