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
            (tags-list    (read-bibtex-body)))))))

(define (read-bibtex-body)
  "Read the body of tags for a BibTeX entry, returning a list of strings.
Each LINE of the BibTeX tag body is turned into one element of the list."
  (let ((tags-list '())
        (tag-line  (read-line)))
    (while (not (eof-object? tag-line))
      (set! tags-list (cons tag-line tags-list))
      (set! tag-line (read-line)))
    tags-list))
