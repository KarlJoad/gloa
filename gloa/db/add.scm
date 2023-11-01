(define-module (gloa db add)
  #:use-module (gloa db)
  #:use-module (gloa db utils)
  #:use-module (gloa article)
  #:use-module (gloa store entry)
  #:export (add-to-db))

(define (add-author db-path author)
  "Add AUTHOR to database at DB-PATH if that author does not already exist.
If that author already exists, then do nothing."
  (unless (object-present? db-path "authors" "name" author)
    (with-db db-path
      (query* "INSERT INTO authors(name) VALUES (:author)"
              (author author)))))

;; TODO: Make generic. Have <article> type contain information about how to
;; serialize to the database's schema. Perhaps use GOOPS?
(define (add-to-db db-path article-info article-pdf-path)
  "Add ARTICLE-INFO metadata to the database at DB-PATH, noting the article PDF's
path."
  (define (link-doc-author doc-id auth-id)
    (with-db db-path
      (query* "INSERT INTO documents_authors_link (author_id, document_id) VALUES (:aid, :doc)"
              (aid auth-id)
              (doc doc-id))))

  (if (article-present? db-path article-info)
      ;; FIXME: Convert these formats into logging statements
      (format #t "Document titled ~s already present in database. Not adding!~%"
              (article-title article-info))
      (begin
        (format #t "~s not in database. Adding!~%" (article-title article-info))
        (with-db db-path
          (query* "INSERT INTO documents(title, path) VALUES (:title, :path)"
                  (title (article-title article-info))
                  (path (base32-file-name article-info article-pdf-path)))
          (let ((doc-id (list-ref
                         (query* to-id "SELECT id FROM documents WHERE title = :title"
                                 (title (article-title article-info)))
                         0)))
            ;; Add each author to authors if new author. Then link doc and authors
            (for-each
             (lambda (author)
               (begin
                 (add-author db-path author)
                 (link-doc-author
                  doc-id
                  (list-ref ;; list-ref because we expect only 1 ID back anyways.
                   (with-db db-path
                     (query* to-id "SELECT id FROM authors WHERE name = :author"
                             (author author)))
                   0))))
                      (article-authors article-info)))))))
