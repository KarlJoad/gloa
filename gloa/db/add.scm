(define-module (gloa db add)
  #:use-module (gloa db)
  #:use-module (gloa article)
  #:export (add-to-db))

;; TODO: Make generic. Have <article> type contain information about how to
;; serialize to the database's schema. Perhaps use GOOPS?
(define (add-to-db db-path article-info article-pdf-path)
  "Add ARTICLE-INFO metadata to the database at DB-PATH, noting the article PDF's
path."
  (let ((serialized-article-authors (string-join (article-authors article-info) " and ")))
    (with-db db-path
      (query* "INSERT INTO documents (title, authors) VALUES(:title, :authors)"
              (title (article-title article-info))
              (authors serialized-article-authors)))))
