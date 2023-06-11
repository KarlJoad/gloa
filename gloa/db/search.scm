(define-module (gloa db search)
  #:use-module (gloa db)
  #:use-module (gloa db utils)
  #:use-module (gloa article)
  #:export (find-article))

(define (find-article db-path article)
  "Attempt to find ARTICLE. If the article does not exist, return #f."
  (with-db db-path
    (query* (lambda (entry) (vector->article entry))
            "SELECT * FROM documents WHERE title = :title AND authors = :authors"
            (title (article-title article))
            (authors (serialize-article-authors article)))))
