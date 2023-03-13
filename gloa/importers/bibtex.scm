(define-module (gloa importers bibtex)
  #:use-module (ice-9 peg)
  #:use-module (ice-9 rdelim)
  #:use-module (ice-9 textual-ports)
  #:use-module (srfi srfi-1)
  #:declarative? #t
  #:export (import-bibtex))

(define %tags-with-numbers
  '(number volume year))

;; Newlines can be \n or \r\n, depending on the underlying encoding of the file.
;; This definition of newline allows for either to be recognized.
(define-peg-pattern NL none (or "\n" "\r\n"))
(define-peg-pattern WS none (or NL " "))

;; A tag is a BibTeX value of the form tagName={tagVal}, or tagName=tagVal, or
;; tagName="tagVal"
(define-peg-pattern tag all (and tag-name tag-equals tag-value))

;; A tag's name is only letters, "[a-zA-Z]+". Hold onto the tag-name field too.
(define-peg-pattern tag-name all (* (or (range #\a #\z) (range #\A #\Z))))

(define-peg-pattern tag-equals none "=")
(define-peg-pattern tag-value-delimiters none (or "{" "}"))

;; A tag's value is letters, numbers, punctuation, anything, but there must be
;; at least one character delimited by the tag value's delimiter characters
(define-peg-pattern tag-value all (or tag-value-braces tag-value-quotes))
(define-peg-pattern tag-value-braces body (and (ignore tag-value-delimiters)
                                              (* (and (not-followed-by tag-value-delimiters) peg-any))
                                              (ignore tag-value-delimiters)))
(define-peg-pattern tag-value-quotes body (and (ignore "\"")
                                              (* (and (not-followed-by "\"") peg-any))
                                              (ignore "\"")))

;; Multiple tags for a single record are separated by commas. The none removes
;; the matched character, which we do not want anyways.
(define-peg-pattern tag-separator none ",")

;; Match on either multiple tags with commas between them, or a single tag.
(define-peg-pattern tags body (+ (and (* WS) tag tag-separator (* WS))))

(define-peg-pattern entry-type all (* (or (range #\a #\z) (range #\A #\Z))))
(define-peg-pattern entry-id all (* (or (range #\a #\z) (range #\A #\Z) (range #\0 #\9)
                                        "-" "_" "/" ".")))
(define-peg-pattern entry all (and (ignore "@") entry-type (ignore "{") entry-id (ignore ",") (? NL)
                                   tags
                                   (ignore "}")))

;; A BibTeX file may be composed of multiple entries, and we parse until we reach
;; the end of the file with the not-followed-by-clause. See the passwd example
;; in (guile) PEG Tutorial for a more in-depth explanation.
(define-peg-pattern entries body (and (* entry) (not-followed-by peg-any)))

(define (import-bibtex filename)
  "Import a BibTeX file to GLoA by parsing the file into an alist, which is
returned."
  ;; (with-input-from-file filename thunk) could work here too
  (let ((bibtex-info (call-with-input-file filename parse-bibtex)))
    ;; TODO: Maybe convert dates too? Relevant Guile info manual sections.
    ;; (guile) Time
    ;; (guile) SRFI-19 Date
    ;; Usually the exact day is not important, only year and month.
    (organize-authors (convert-fields bibtex-info))))

(define (organize-authors bibtex-alist)
  "Split up and organize authors in BIBTEX-ALIST."
  (define author-delimiter " and ")
  (define (split-authors authors-string)
    "Split the AUTHORS-STRING into a list of strings of author names"
    (let ((start 0)
          (end (string-length authors-string))
          (split-idx (string-contains-ci authors-string author-delimiter))
          (authors-list '()))
      ;; Continue building up the list
      (while split-idx
        (set! authors-list (cons (substring/copy authors-string start split-idx) authors-list))
        (set! start (+ split-idx (string-length author-delimiter)))
        (set! split-idx (string-contains-ci authors-string author-delimiter start end)))
      ;; On last author or an article with just one author
      (set! authors-list (cons (substring/copy authors-string start end) authors-list))
      ;; Reverse and return the final list, as we cons-d later authors to the front
      (reverse authors-list)))
  ;; Make a copy of the original alist, so this update is not done in-place
  (let ((unmodified-tags (list-copy bibtex-alist))
        (authors-string (assoc-ref bibtex-alist 'author)))
    ;; Remove old author string and use new authors list
    (assoc-set! (assoc-remove! unmodified-tags 'author)
                'authors (split-authors authors-string))))

(define (convert-fields bibtex-alist)
  (define (check-field field-pair matching-list)
    "Check if the FIELD-PAIR (tag . val) has a tag in MATCHING-LIST."
    (let ((tag (car field-pair))
          (val (cdr field-pair)))
      (find (lambda (v) (eq? tag v)) matching-list)))
  (define (convert-tag tag-pair convert-fn)
    "Convert TAG-PAIR's value's type using CONVERT-FN."
    (let ((tag (car tag-pair))
          (val (cdr tag-pair)))
      (cons tag (convert-fn val))))
  (map (lambda (tag)
         (cond
          ((check-field tag %tags-with-numbers)
           (convert-tag tag string->number))
          (else tag)))
       bibtex-alist))

(define (parse-bibtex file-port)
  "Parse an opened file into an alist."
  (let ((file-contents (call-with-port file-port get-string-all)))
    (peg:tree (match-pattern entries file-contents))))

(define (read-bibtex-body)
  "Read the body of tags for a BibTeX entry, returning a list of strings.
Each LINE of the BibTeX tag body is turned into one element of the list."
  (let ((tags-list '())
        (tag-line  (read-line)))
    (while (not (eof-object? tag-line))
      (set! tags-list (cons tag-line tags-list))
      (set! tag-line (read-line)))
    tags-list))
