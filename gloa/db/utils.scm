(define-module (gloa db utils)
  #:use-module (gloa db)
  #:use-module (gloa article)
  #:export (article-present?
            vector->article))

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

(define (vector->article vec)
  "Convert a vector representing a row from the returned SQLite query to an
article object."
  (let ((article-id (vector-ref vec 0)) ;; Drop the ID of the entry
        (article-title (vector-ref vec 1))
        (authors-list (deserialize-article-authors (vector-ref vec 2))))
    (make-article article-title authors-list)))
