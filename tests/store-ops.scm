(define-module (test-store-ops)
  #:use-module (gloa config)
  #:use-module (gloa utils)
  #:use-module (gloa store)
  #:use-module (gloa store add)
  #:use-module (gloa store remove)
  #:use-module (gloa article)
  #:use-module (srfi srfi-64)
  #:use-module (tests utils))

(define %test-store-path (test-store-path))

(define %test-article-simple
  (make-article "Test title" '("Last1, First1" "First2 Last2")))
(define %test-article-simple-path
  ;; Creates a fake path for the simple article example that can be copied into
  ;; the store for testing.
  (port-filename (mkstemp "/tmp/test-article-simple-XXXXXX")))

(define (cleanup-files)
  (delete-file %test-article-simple-path)
  (delete-file-recursively (gloa-storage-directory)))

(define %test-article-real
  (let ((article-alist ((@ (gloa importers bibtex) import-bibtex) "tests/test.bib")))
    (make-article (assoc-ref article-alist 'title)
                  (assoc-ref article-alist 'authors))))

(with-tests "store-ops"
  (test-group-with-cleanup "store-ops"
    (parameterize ((gloa-storage-directory %test-store-path))
      (test-assert "create-store"
        (create-store))

      (test-assert "add-to-store"
        (begin
          (add-to-store %test-article-simple %test-article-simple-path)))

      cleanup-files)))
