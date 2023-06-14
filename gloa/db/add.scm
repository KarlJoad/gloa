(define-module (gloa db add)
  #:use-module (gloa db)
  #:use-module (gloa db utils)
  #:use-module (gloa article)
  #:export (add-to-db))

;; TODO: Make generic. Have <article> type contain information about how to
;; serialize to the database's schema. Perhaps use GOOPS?
(define (add-to-db db-path article-info article-pdf-path)
  "Add ARTICLE-INFO metadata to the database at DB-PATH, noting the article PDF's
path."
  (if (article-present? db-path article-info)
      ;; FIXME: Convert these formats into logging statements
      (format #t "~s already present in database. Not adding!~%"
              (article-title article-info))
      (begin
        (format #t "~s not in database. Adding!~%" (article-title article-info))
        (with-db db-path
          (query* "INSERT INTO documents (title, authors) VALUES(:title, :authors)"
                  (title (article-title article-info))
                  (authors (serialize-article-authors article-info)))))))
