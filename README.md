# HOL88

This repository features the port of the famous HOL88 interactive theorem
proving system (last release of the HOL family which requires just a Common
Lisp system as a prerequisite) to Steel Bank Common Lisp ([1]).

A major incentive for porting to SBCL was performance. According to the
bundled benchmark (in src/contrib/benchmark), the SBCL port performs faster
than a GCL-based installation by a factor of about 9, which makes the port
rather useful for practical applications.

[1] http://www.sbcl.org/
