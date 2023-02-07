(define-module (test-import-bibtex)
  #:use-module (gloa importers bibtex)
  #:use-module (srfi srfi-64)
  #:use-module (tests utils))

(define %bibtex-filename
  "test.bib")

(define %expected-bibtex-parse
  '((authors "Kuon, Ian" "Rose, Jonathan")
    (type . "ARTICLE")
    (id . "4068926")
    (month . "Feb")
    (ISSN . "1937-4151")
    (doi . "10.1109/TCAD.2006.884574")
    (keywords . "")
    (abstract . "This paper presents experimental measurements of the differences between a 90-nm CMOS field programmable gate array (FPGA) and 90-nm CMOS standard-cell application-specific integrated circuits (ASICs) in terms of logic density, circuit speed, and power consumption for core logic. We are motivated to make these measurements to enable system designers to make better informed choices between these two media and to give insight to FPGA makers on the deficiencies to attack and, thereby, improve FPGAs. We describe the methodology by which the measurements were obtained and show that, for circuits containing only look-up table-based logic and flip-flops, the ratio of silicon area required to implement them in FPGAs and ASICs is on average 35. Modern FPGAs also contain \"hard\" blocks such as multiplier/accumulators and block memories. We find that these blocks reduce this average area gap significantly to as little as 18 for our benchmarks, and we estimate that extensive use of these hard blocks could potentially lower the gap to below five. The ratio of critical-path delay, from FPGA to ASIC, is roughly three to four with less influence from block memory and hard multipliers. The dynamic power consumption ratio is approximately 14 times and, with hard blocks, this gap generally becomes smaller")
    (pages . "203-215")
    (number . 2)
    (volume . 26)
    (year . 2007)
    (title . "Measuring the Gap Between FPGAs and ASICs")
    (journal . "IEEE Transactions on Computer-Aided Design of Integrated Circuits and Systems")))

(with-tests "import-bibtex"
  (test-equal "import-bibtex-file-to-alist"
    %expected-bibtex-parse
    (import-bibtex %bibtex-filename)))
