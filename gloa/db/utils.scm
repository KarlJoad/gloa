(define-module (gloa db utils)
  #:use-module (gloa db)
  #:use-module (gloa db search)
  #:use-module (gloa article)
  #:use-module (srfi srfi-1)
  #:export (object-present?
            article-present?
            to-id
            list->sql))

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

;; By uniqueness, we expect just one ID back
(define (to-id res)
  "Convert a SINGLE-VALUED vector to a single integer.
This is intended for converting an ID returned from a database query to
something that can be used elsewhere."
  (vector-ref res 0))

(define (list->sql lst)
  "Convert a Scheme list to a SQL list that can be used with IN operators."
  (let ((escaped-string-list (map (lambda (s)
                                    (format #f "'~a'" s))
                                  lst)))
    (string-append "(" (string-join escaped-string-list ",") ")")))
