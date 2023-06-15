(define-module (gloa db remove)
  #:use-module (gloa db)
  #:use-module (gloa db utils)
  #:use-module (gloa article)
  #:export (remove-from-db))

;; FIXME: If something does not exist when trying to remove, this whole thing
;; fails with an "unexpected value ()" error.
(define (remove-from-db db-path article)
  "Remove the ARTICLE from the database at DB-PATH."
  (with-db db-path
    (let ((doc-id (list-ref (query* to-id "SELECT id FROM documents WHERE title = :title"
                                    (title (article-title article)))
                            0))
          (auth-ids (query* to-id
                            (format #f "SELECT id from authors WHERE name IN ~a"
                                    (list->sql (article-authors article))))))
      ;; Remove the links in the authors-documents link table
      (for-each (lambda (auth-id)
                  (with-db db-path
                    (query* "DELETE FROM documents_authors_link WHERE document_id = :docid AND author_id = :authid"
                            (docid doc-id)
                            (authid auth-id))
                    ;; Remove any orphaned authors
                    (unless (object-present? db-path "documents_authors_link" "author_id" auth-id)
                      (with-db db-path (query* "DELETE FROM authors WHERE id = :authid"
                                               (authid auth-id))))))
                auth-ids)
      ;; Remove the document itself
      (with-db db-path (query* "DELETE FROM documents WHERE title = :title"
                               (title (article-title article)))))))
