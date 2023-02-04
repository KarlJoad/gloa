(define-module (gloa importers bibtex)
  #:export (import-bibtex))

(define (import-bibtex filename)
  "Import a BibTeX file to GLoA by parsing the file into an alist, which is
returned."
  (call-with-input-file filename
    parse-bibtex))

(define (parse-bibtex file-port)
  "Parse an opened file into an alist."
  (display (string-append (symbol->string (procedure-name parse-bibtex)) " is unimplemented!\n"))
  (throw 'not-implemented))
