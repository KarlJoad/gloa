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
  (define trimming-character-set (char-set-union char-set:whitespace char-set:punctuation))
  (define (split-tag-string s) (string-split s #\=))
  (define (create-tag-pair tag-as-string)
    (cons (string->symbol (car tag-as-string))
          (string-trim (string-trim (cadr tag-as-string) trimming-character-set))))
  (with-input-from-port file-port
    (lambda ()
      ;; Use let* because reading must be properly sequenced
      (let* ((article-type (string-trim-both (read-delimited "{") trimming-character-set))
             (article-id   (string-trim-both (read-line) trimming-character-set))
             (tags-list    (read-bibtex-body)))
        ;; Convert list of tags to alist. Map tag -> entry
        `((type . ,article-type)
          (id . ,article-id)
          ,@(map (lambda (s) (create-tag-pair (split-tag-string s)))
             ;; Remove leading/trailing whitespace and trailing punctuation
             (map (lambda (s) (string-trim-both s trimming-character-set)) tags-list)))))))

(define (read-bibtex-body)
  "Read the body of tags for a BibTeX entry, returning a list of strings.
Each LINE of the BibTeX tag body is turned into one element of the list."
  (let ((tags-list '())
        (tag-line  (read-line)))
    (while (not (eof-object? tag-line))
      (set! tags-list (cons tag-line tags-list))
      (set! tag-line (read-line)))
    tags-list))
