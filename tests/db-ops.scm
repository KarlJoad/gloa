(define-module (test-db-ops)
  #:use-module (gloa db)
  #:use-module (gloa db add)
  #:use-module (gloa db remove)
  #:use-module (gloa db search)
  #:use-module (gloa article)
  #:use-module (srfi srfi-64)
  #:use-module (srfi srfi-1)
  #:use-module (tests utils))

(define %test-database-path "test.db")

(define (remove-test-db db)
  "Remove database file as cleanup when done using the testing database.
If the file does not exist, then an exception is raised."
  (delete-file %test-database-path))

(define %test-article-simple
  (make-article "Test title" '("Last1, First1" "First2 Last2")))

(define %test-article-real
  (let ((article-alist ((@ (gloa importers bibtex) import-bibtex) "tests/test.bib")))
    (make-article (assoc-ref article-alist 'title)
                  (assoc-ref article-alist 'authors))))

(with-tests "db-ops"
  (test-group-with-cleanup "db-ops"
    (test-assert "add-to-db"
      (begin
        (init-db %test-database-path)
        (add-to-db %test-database-path %test-article-simple "")))

    (test-equal "search-db-by-title, entry exists"
      (find-article-by-title %test-database-path (article-title %test-article-simple))
      %test-article-simple)

    (test-error "remove-from-db, remove author (orphaned)" &no-sql-match-exception
      (begin
        (remove-from-db %test-database-path %test-article-simple)
        (find-article-by-title %test-database-path (article-title %test-article-simple))))

    (remove-test-db %test-database-path)))
