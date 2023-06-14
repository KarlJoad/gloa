(define-module (gloa db utils)
  #:use-module (gloa db)
  #:use-module (gloa db search)
  #:use-module (gloa article)
  #:use-module (srfi srfi-1)
  #:export (object-present?
            article-present?
            vector->article
            to-id))

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
  (and (object-present? db-path "documents" "title" (article-title article))
       (every (lambda (b) (eq? b #t))
               (map (lambda (author)
                      (object-present? db-path "authors" "name" author))
                    (article-authors article)))
       ;; FIXME: Also check the link table to make sure proper links exist.
       ;; (object-present? db-path "documents_author_link" "id")
       ))

(define (vector->article vec)
  "Convert a vector representing a row from the returned SQLite query to an
article object."
  (let ((article-id (vector-ref vec 0)) ;; Drop the ID of the entry
        (article-title (vector-ref vec 1))
        (authors-list (deserialize-article-authors (vector-ref vec 2))))
    (make-article article-title authors-list)))

;; By uniqueness, we expect just one ID back
(define (to-id res)
  "Convert a SINGLE-VALUED vector to a single integer.
This is intended for converting an ID returned from a database query to
something that can be used elsewhere."
  (vector-ref res 0))
