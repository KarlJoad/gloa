(define-module (gloa db utils)
  #:use-module (gloa db)
  #:use-module (gloa article)
  #:export (article-present?))

(define (article-present? db-path article)
  "Determine if ARTICLE is already present in the database at DB-PATH."
  (let ((serialized-article-authors (serialize-article-authors
                                     (article-authors article))))
    (not (equal? 0
                 (length
                  (with-db db-path
                    (query* "SELECT * FROM documents WHERE title = :title AND authors = :authors"
                            (title (article-title article))
                            (authors serialized-article-authors))))))))
