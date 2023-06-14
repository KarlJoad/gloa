(define-module (gloa db utils)
  #:use-module (gloa db)
  #:use-module (gloa db search)
  #:use-module (gloa article)
  #:export (object-present?
            article-present?
            vector->article))

(define (object-present? db-path table-name col-filter search-param)
  "Attempt to find SEARCH-PARAM in TABLE-NAME at the database in DB-PATH. Return
@code{#t} if there are any matches. Otherwise, return @code{#f}."
  (not (zero?
        (length
         (with-db db-path
           (query* (format #f "SELECT * FROM ~a WHERE ~a = :thing"
                           table-name
                           col-filter)
                   (thing search-param)))))))

(define (article-present? db-path article)
  "Determine if ARTICLE is already present in the database at DB-PATH."
  (not (equal? 0
               (length
                (find-article db-path article)))))

(define (vector->article vec)
  "Convert a vector representing a row from the returned SQLite query to an
article object."
  (let ((article-id (vector-ref vec 0)) ;; Drop the ID of the entry
        (article-title (vector-ref vec 1))
        (authors-list (deserialize-article-authors (vector-ref vec 2))))
    (make-article article-title authors-list)))
