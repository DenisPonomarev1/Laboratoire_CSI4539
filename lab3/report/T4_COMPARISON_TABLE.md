# T4 Comparison Table (C vs SPARK)

| Case | Bytes | Expected Policy | C Exit | SPARK Exit | SPARK Accepted |
| --- | ---: | --- | ---: | ---: | --- |
| 01-valid-short.txt | 8 | ACCEPT | 1 | 0 | TRUE |
| 02-valid-path.txt | 18 | ACCEPT | 1 | 0 | TRUE |
| 03-valid-boundary-100.txt | 100 | ACCEPT | 1 | 0 | TRUE |
| 04-invalid-length-101.txt | 101 | REJECT | 1 | 0 | FALSE |
| 05-invalid-format-string.txt | 6 | REJECT | 1 | 0 | FALSE |
| 06-lab1-semicolon.txt | 289 | REJECT | 139 | 0 | FALSE |
| 07-lab1-and.txt | 250 | REJECT | 139 | 0 | FALSE |
| 08-lab1-pipe.txt | 249 | REJECT | 139 | 0 | FALSE |
| 09-lab1-backtick.txt | 266 | REJECT | 139 | 0 | FALSE |
| 10-lab1-dollar.txt | 268 | REJECT | 139 | 0 | FALSE |
| 11-lab1-newline.txt | 313 | REJECT | 139 | 0 | FALSE |
| 12-lab1-path-subst.txt | 447 | REJECT | 139 | 0 | FALSE |
| 13-lab2-badfile-t3.bin | 517 | REJECT | 139 | 0 | FALSE |
