(define-module (gloa importers bibtex)
  #:use-module (ice-9 rdelim)
  #:export (import-bibtex))

(define (import-bibtex filename)
  "Import a BibTeX file to GLoA by parsing the file into an alist, which is
returned."
  (call-with-input-file filename
    parse-bibtex))

(define (parse-bibtex file-port)
  "Parse an opened file into an alist."
  (with-input-from-port file-port
    (lambda ()
      (let ((article-type (read-delimited "{"))
            (article-id   (read-line))
            (tags-list    '())
            (tag-line     ""))
        (set! tag-line (read-line))
        (while (not (eof-object? tag-line))
          (display (string-append tag-line "\n"))
          (set! tags-list (cons tag-line tags-list))
          (set! tag-line (read-line)))))))
