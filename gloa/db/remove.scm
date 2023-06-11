(define-module (gloa db remove)
  #:use-module (gloa db)
  #:use-module (gloa db utils)
  #:use-module (gloa article)
  #:export (remove-from-db))

(define (remove-from-db db-path article)
  "Remove the ARTICLE from the database at DB-PATH."
  (with-db db-path
    (query* "DELETE FROM documents WHERE title = :title AND authors = :authors"
            (title (article-title article))
            (authors (serialize-article-authors article)))))
