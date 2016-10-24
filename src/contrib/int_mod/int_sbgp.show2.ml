% FILE		: int_sbgp.show.ml					%
%									%
% DESCRIPTION   : This file gives a history of the development of the	%
%		  fact that every subgroup of the integers is closed	%
%		  under multiplication by an arbitrary integer, and	%
%		  the fact that every subgroup is cyclic.		%
%									%
%									%
% AUTHOR	: E. L. Gunter						%
% DATE		: 89.7.27						%
%									%
%-----------------------------------------------------------------------%

load_theory `int_sbgp`;;

load_library `group`;;
load_library `integer`;;

include_theory `int_sbgp`;;

set_goal([],"!H. SUBGROUP((\N.T),$plus)H ==> !m p. H p ==> H (m times p)");;

expand (GEN_TAC THEN DISCH_TAC);;

expand (FIRST_ASSUM \thm. (STRIP_ASSUME_TAC
     (PURE_ONCE_REWRITE_RULE [SUBGROUP_DEF] thm)));;

expand INT_CASES_TAC;;

% goal 1 -- Case corresponding to nat. nums. %

expand INDUCT_TAC;;

% goal 1.1 -- Zero case %

expand ((REPEAT STRIP_TAC) THEN
  (REWRITE_TAC[TIMES_ZERO;(UNDISCH (SPEC_ALL INT_SBGP_ZERO))]));;

% goal 1.2 -- Inductive step %

expand (GEN_TAC THEN DISCH_TAC THEN RES_TAC);;

expand (PURE_REWRITE_TAC[ADD1;(SYM (SPEC_ALL NUM_ADD_IS_INT_ADD))]);;

expand (PURE_REWRITE_TAC[RIGHT_PLUS_DISTRIB;TIMES_IDENTITY]);;

expand GROUP_ELT_TAC;;

% goal 2 -- Case corresponding to the negatives of nat. nums. %

expand ((REPEAT STRIP_TAC) THEN
  (PURE_ONCE_REWRITE_TAC[TIMES_neg]) THEN
  (MATCH_MP_IMP_TAC (UNDISCH (SPEC_ALL INT_SBGP_neg))));;

expand (NEW_MATCH_ACCEPT_TAC (UNDISCH (SPEC_ALL
    (ASSUME "!n1 p. H p ==> H((INT n1) times p)"))));;


let INT_SBGP_TIMES_CLOSED = prove_thm(`INT_SBGP_TIMES_CLOSED`,
"!H. SUBGROUP((\N.T),$plus)H ==> !m p. H p ==> H (m times p)",
(GEN_TAC THEN DISCH_TAC THEN
 (FIRST_ASSUM \thm.(STRIP_ASSUME_TAC
   (PURE_ONCE_REWRITE_RULE[SUBGROUP_DEF] thm))) THEN
 INT_CASES_TAC THENL
 [(INDUCT_TAC THENL
   [((REPEAT STRIP_TAC) THEN
     (REWRITE_TAC[TIMES_ZERO;(UNDISCH (SPEC_ALL INT_SBGP_ZERO))]));
    (GEN_TAC THEN DISCH_TAC THEN RES_TAC THEN
     (PURE_REWRITE_TAC[ADD1;(SYM (SPEC_ALL NUM_ADD_IS_INT_ADD))]) THEN
     (PURE_REWRITE_TAC[RIGHT_PLUS_DISTRIB;TIMES_IDENTITY]) THEN
     GROUP_ELT_TAC)]);
  ((REPEAT STRIP_TAC) THEN
   (PURE_ONCE_REWRITE_TAC[TIMES_neg]) THEN
   (MATCH_MP_IMP_TAC (UNDISCH (SPEC_ALL INT_SBGP_neg))) THEN
   (NEW_MATCH_ACCEPT_TAC (UNDISCH (SPEC_ALL
     (ASSUME "!n1 p. H p ==> H((INT n1) times p)")))))]));;


set_goal([],"!H. SUBGROUP((\N.T),$plus)H ==> ? n.(H = int_mult_set (INT n))");;

expand (GEN_TAC THEN DISCH_TAC THEN
 (FIRST_ASSUM
  \thm.(STRIP_ASSUME_TAC
    (PURE_ONCE_REWRITE_RULE[SUBGROUP_DEF] thm))));;

expand ((PURE_ONCE_REWRITE_TAC [INT_MULT_SET_DEF]) THEN
 (ASM_CASES_TAC "!m1. (H m1) ==> (m1 = (INT 0))"));;

% goal 1 -- H contained in {0} implies H cyclic. %

expand (EXISTS_TAC "0");;

expand ((EXT_TAC "m1:integer") THEN BETA_TAC);;

expand (REWRITE_TAC [TIMES_ZERO]);;

expand (GEN_TAC THEN EQ_TAC);;

% goal 1.1 -- H contained in {0}. %

expand (FIRST_ASSUM (\thm.(ACCEPT_TAC (SPEC_ALL thm))));;

% goal 1.2 -- {0} coantained in H. %

expand (DISCH_TAC THEN
  (ASM_REWRITE_TAC [(UNDISCH (SPEC_ALL INT_SBGP_ZERO))]));;

% goal 2 -- H not contained in {0} implies H cyclic. %

expand (INT_MIN_TAC "\N. (POS N /\ H N)");;

% goal 2.1 -- MIN is minumum positive element in H ==>
   H is cyclic, gen. by MIN %

expand (POP_ASSUM STRIP_ASSUME_TAC);;

expand (SUPPOSE_TAC "?n. (INT n) = MIN");;

% goal 2.1.1 --  MIN corresponds to an integer ==> H is sbgp gen by MIN. %

expand (POP_ASSUM STRIP_ASSUME_TAC);;

expand (EXISTS_TAC "n:num");;

expand (POP_ASSUM \thm. PURE_ONCE_REWRITE_TAC [thm]);;

expand ((EXT_TAC "m:integer") THEN BETA_TAC THEN
 GEN_TAC THEN EQ_TAC);;

% goal 2.1.1.1 -- H contained in subgroup generated by MIN. %

expand ((SPEC_TAC ("m:integer","N:integer")) THEN
 SIMPLE_INT_CASES_TAC);;

% goal 2.1.1.1.1 -- N a positive element of H ==> N a multiple of MIN. %

expand (REPEAT STRIP_TAC);;

expand (INT_MAX_TAC "\X.~(NEG(N minus (X times MIN)))");;

% goal 2.1.1.1.1.1 -- MAX is the maximun number of times MIN can be subtracted
   from N ==> N a multiple of MIN. %

expand (EXISTS_TAC "MAX:integer");;

expand ((MATCH_MP_IMP_TAC
   (SPEC "neg (MAX times MIN)" PLUS_RIGHT_CANCELLATION)) THEN
 (PURE_REWRITE_TAC [PLUS_INV_LEMMA;(SYM (SPEC_ALL MINUS_DEF))]));;

expand (DISJ_CASES_TAC (CONJUNCT1
   (SPEC "N minus (MAX times MIN)" TRICHOTOMY)));;

% goal 2.1.1.1.1.1.1 -- POS(N minus (MAX times MIN)) ==>
   N minus (MAX times MIN) = INT 0. %

expand (SUPPOSE_TAC "(N minus (MAX times MIN)) below MIN");;

% goal 2.1.1.1.1.1.1.1 -- N minus (MAX times MIN)) below MIN ==>
   N minus (MAX times MIN) = INT 0. %

expand (SUPPOSE_TAC "(H (N minus (MAX times MIN))):bool");;

% goal 2.1.1.1.1.1.1.1.1 -- N minus (MAX times MIN) in H ==>
   N minus (MAX times MIN) = INT 0. %

expand (RES_TAC THEN RES_TAC);;

% goal 2.1.1.1.1.1.1.1.2 -- N minus (MAX times MIN) in H. %

expand (PURE_ONCE_REWRITE_TAC [MINUS_DEF]);;

expand (GROUP_TAC [INT_SBGP_neg;INT_SBGP_TIMES_CLOSED]);;

% goal 2.1.1.1.1.1.1.2 -- N minus (MAX times MIN)) below MIN %

expand (PURE_ONCE_REWRITE_TAC [BELOW_DEF]);;

expand ((NEW_SUBST1_TAC 
   (SYM (SPEC "MIN minus (N minus (MAX times MIN))"
     PLUS_INV_INV_LEMMA))) THEN
 (PURE_ONCE_REWRITE_TAC [(SYM (SPEC_ALL(NEG_DEF)))]));;

expand (PURE_REWRITE_TAC
    [MINUS_DEF;
     (SYM (SPEC_ALL (PLUS_DIST_INV_LEMMA)));
     PLUS_INV_INV_LEMMA]);;

expand ((INT_RIGHT_ASSOC_TAC
    "(N plus (neg (MAX times MIN))) plus (neg MIN)") THEN
 (PURE_REWRITE_TAC
    [(SYM neg_PLUS_DISTRIB);(SYM (SPEC_ALL MINUS_DEF))]));;

expand (PURE_ONCE_REWRITE_TAC
   [(PURE_ONCE_REWRITE_RULE [TIMES_IDENTITY] (SYM
     (SPECL ["MAX:integer";"INT 1";"MIN:integer"]
       RIGHT_PLUS_DISTRIB)))]);;

expand (MATCH_MP_IMP_TAC (ONCE_REWRITE_RULE []
   (ASSUME "!N'.MAX below N' ==>~~NEG (N minus (N' times MIN))")));;

expand ((SUBST_MATCH_TAC
   (PURE_ONCE_REWRITE_RULE [COMM_PLUS]
     (SPECL ["A:integer";"B:integer";"neg MAX"]
       PLUS_BELOW_TRANSL))) THEN
 (PURE_REWRITE_TAC
    [(SYM (SPEC_ALL PLUS_GROUP_ASSOC));
     PLUS_INV_LEMMA;
     (SYM (SPEC_ALL NUM_LESS_IS_INT_BELOW));
     PLUS_ID_LEMMA]));;

expand ((CONV_TAC (DEPTH_CONV num_CONV)) THEN
 (ACCEPT_TAC (theorem `prim_rec` `LESS_0_0`)));;

% goal 2.1.1.1.1.1.2 -- NEG(N minus (MAX times MIN)) /\ 
   N minus (MAX times MIN) = INT 0 ==> N minus (MAX times MIN) = INT 0. %

expand ((POP_ASSUM DISJ_CASES_TAC) THENL
 [RES_TAC;(FIRST_ASSUM ACCEPT_TAC)]);;

% goal 2.1.1.1.1.2 --  The set of times MIN can be subtracted from N with
   a non-negative result is not empty. %

expand ((EXISTS_TAC "INT 0") THEN 
 (PURE_REWRITE_TAC
   [MINUS_DEF;TIMES_ZERO;PLUS_INV_ID_LEMMA;PLUS_ID_LEMMA]));;

expand (ACCEPT_TAC (REWRITE_RULE [(ASSUME "POS N")]
   (CONJUNCT1 (CONJUNCT2 (SPEC "N:integer" TRICHOTOMY)))));;

% goal 2.1.1.1.1.3 --  The set of times MIN can be subtracted from N with
   a non-negative result has an upper bound. %

expand (EXISTS_TAC "N:integer");;

expand ((REWRITE_TAC
   [NEG_DEF;
    MINUS_DEF;
    (SYM (SPEC_ALL PLUS_DIST_INV_LEMMA));
    PLUS_INV_INV_LEMMA]) THEN
 (PURE_REWRITE_TAC[(SYM (SPEC_ALL MINUS_DEF));
    (SYM (SPEC_ALL BELOW_DEF))]));;

expand ((STRIP_ASSUME_TAC
   (PURE_ONCE_REWRITE_RULE [POS_DEF] (ASSUME "POS MIN"))) THEN
 (PURE_ONCE_ASM_REWRITE_TAC[]));;

expand ((DISJ_CASES_TAC (SPEC "n:num" LESS_0_CASES)) THENL
 [(POP_ASSUM \thm. (ASM_REWRITE_TAC
    [(SYM thm);(SYM (num_CONV "1"));TIMES_IDENTITY]));
  ALL_TAC]);;

expand ((REPEAT STRIP_TAC) THEN
 (MP_IMP_TAC
   (SPECL ["N:integer";"N':integer";"N' times (INT(SUC n))"]
    TRANSIT)) THEN
 (ASM_REWRITE_TAC []));;

expand ((PURE_REWRITE_TAC
   [ADD1; (SYM (SPEC_ALL NUM_ADD_IS_INT_ADD));
    LEFT_PLUS_DISTRIB; TIMES_IDENTITY]) THEN
 (NEW_SUBST1_TAC
   (SPECL ["N':integer";"(N' times (INT n)) plus N'";"neg N'"]
    PLUS_BELOW_TRANSL)) THEN
 (PURE_REWRITE_TAC [PLUS_GROUP_ASSOC;PLUS_INV_LEMMA;PLUS_ID_LEMMA]));;

expand ((NEW_SUBST1_TAC 
   (SYM (CONJUNCT1 (SPEC "N':integer" TIMES_ZERO)))) THEN
 (NEW_SUBST1_TAC
   (SYM (UNDISCH (SPECL ["N':integer"; "INT 0"; "INT n"]
     POS_MULT_PRES_BELOW)))));;

% goal 2.1.1.1.1.3.1 -- N' is positive ==> INT 0 below INT n %

expand (ASM_REWRITE_TAC [(SYM (SPEC_ALL (NUM_LESS_IS_INT_BELOW)))]);;

% goal 2.1.1.1.1.3.2 -- N' is positive.  (N' is bigger than upper bound.) %

expand ((PURE_ONCE_REWRITE_TAC [POS_IS_ZERO_BELOW]) THEN
 (MP_IMP_TAC (SPECL ["INT 0";"N:integer";"N':integer"] TRANSIT)) THEN
 (ASM_REWRITE_TAC[(SYM (SPEC_ALL POS_IS_ZERO_BELOW))]));;

% goal 2.1.1.1.2 -- N a negative element of H ==> N a multiple of MIN. %

expand ((PURE_ONCE_REWRITE_TAC [NEG_DEF]) THEN
 (REPEAT STRIP_TAC) THEN
 (NEW_SUBST1_TAC (SYM (SPEC "N:integer" PLUS_INV_INV_LEMMA))));;

expand (STRIP_ASSUME_TAC (MP
   (UNDISCH (SPEC "neg N"
     (ASSUME "!N. POS N ==> H N ==> (?p. N = p times MIN)")))
   (UNDISCH (SPEC "N:integer" (UNDISCH
     (SPEC "H:integer -> bool" INT_SBGP_neg))))));;

expand ((EXISTS_TAC "neg p") THEN (ASM_REWRITE_TAC [TIMES_neg]));;

% goal 2.1.1.1.3 -- N = INT 0 ==> N a multiple of MIN. %

expand (DISCH_TAC THEN (EXISTS_TAC "INT 0") THEN
 (REWRITE_TAC [TIMES_ZERO]));;

% goal 2.1.1.2 -- Every multiple of MIN is contained in H. %

expand (STRIP_TAC THEN (ASM_REWRITE_TAC []) THEN
 (NEW_MATCH_ACCEPT_TAC
   (UNDISCH (SPEC_ALL (UNDISCH (SPEC_ALL INT_SBGP_TIMES_CLOSED))))));;

% goal 2.1.2 -- MIN corresponds to an integer. %

expand (STRIP_ASSUME_TAC
   (PURE_ONCE_REWRITE_RULE [POS_DEF] (ASSUME "POS MIN")));;

expand ((EXISTS_TAC "SUC n") THEN (ASM_REWRITE_TAC []));;

% goal 2.2 -- The set of positive elements of H is non-empty. %

expand (POP_ASSUM \thm. STRIP_ASSUME_TAC 
   (REWRITE_RULE [IMP_DISJ_THM;DE_MORGAN_THM]
     (CONV_RULE NOT_FORALL_CONV thm)));;

expand ((DISJ_CASES_TAC
   (CONJUNCT1 (SPEC "m1:integer" TRICHOTOMY))) THENL
 [((EXISTS_TAC "m1:integer") THEN (ASM_REWRITE_TAC []));
  ((POP_ASSUM DISJ_CASES_TAC) THENL
   [ALL_TAC; RES_TAC])]);;

expand ((EXISTS_TAC "neg m1") THEN
 (ASM_REWRITE_TAC
   [(SYM (SPEC_ALL NEG_DEF));
    (UNDISCH (SPEC "m1:integer"
      (UNDISCH (SPEC_ALL INT_SBGP_neg))))]));;

% goal 2.3 -- The set of positive elements of H has a lower bound. %

expand (EXISTS_TAC "INT 0");;

expand (PURE_ONCE_REWRITE_TAC [(SYM (SPEC_ALL NEG_IS_BELOW_ZERO))]);;

expand (GEN_TAC THEN DISCH_TAC THEN
 (REWRITE_TAC
   [(REWRITE_RULE[(ASSUME "NEG N")]
   (CONJUNCT1 (CONJUNCT2 (SPEC "N:integer" TRICHOTOMY))))]));;


let INT_SBGP_CYCLIC = prove_thm(`INT_SBGP_CYCLIC`,
"!H. SUBGROUP((\N.T),$plus)H ==> ? n.(H = int_mult_set (INT n))",
(GEN_TAC THEN DISCH_TAC THEN
 (FIRST_ASSUM
   \thm.(STRIP_ASSUME_TAC
     (PURE_ONCE_REWRITE_RULE[SUBGROUP_DEF] thm))) THEN
 (PURE_ONCE_REWRITE_TAC [INT_MULT_SET_DEF]) THEN
 (ASM_CASES_TAC "!m1. (H m1) ==> (m1 = (INT 0))") THENL
 [((EXISTS_TAC "0") THEN
   (EXT_TAC "m1:integer") THEN BETA_TAC THEN
   (REWRITE_TAC [TIMES_ZERO]) THEN
   GEN_TAC THEN EQ_TAC THENL
   [(FIRST_ASSUM (\thm.(ACCEPT_TAC (SPEC_ALL thm))));
    (DISCH_TAC THEN
     (ASM_REWRITE_TAC [(UNDISCH (SPEC_ALL INT_SBGP_ZERO))]))]);
  ((INT_MIN_TAC "\N. (POS N /\ H N)") THENL
   [((POP_ASSUM STRIP_ASSUME_TAC) THEN
     (SUPPOSE_TAC "?n. (INT n) = MIN") THENL
     [((POP_ASSUM STRIP_ASSUME_TAC) THEN
       (EXISTS_TAC "n:num") THEN
       (POP_ASSUM \thm. PURE_ONCE_REWRITE_TAC [thm]) THEN
       (EXT_TAC "m:integer") THEN BETA_TAC THEN
       GEN_TAC THEN EQ_TAC THENL
       [((SPEC_TAC ("m:integer","N:integer")) THEN
         SIMPLE_INT_CASES_TAC THENL
         [((REPEAT STRIP_TAC) THEN
           (INT_MAX_TAC "\X.~(NEG(N minus (X times MIN)))") THENL
           [((EXISTS_TAC "MAX:integer") THEN
             (MATCH_MP_IMP_TAC
               (SPEC "neg (MAX times MIN)" PLUS_RIGHT_CANCELLATION)) THEN
             (PURE_REWRITE_TAC
               [PLUS_INV_LEMMA;(SYM (SPEC_ALL MINUS_DEF))]) THEN
             (DISJ_CASES_TAC (CONJUNCT1
               (SPEC "N minus (MAX times MIN)" TRICHOTOMY))) THENL
             [((SUPPOSE_TAC "(N minus (MAX times MIN)) below MIN") THENL
               [((SUPPOSE_TAC "(H (N minus (MAX times MIN))):bool") THENL
                 [(RES_TAC THEN RES_TAC);
                  ((PURE_ONCE_REWRITE_TAC [MINUS_DEF]) THEN
                   (GROUP_TAC [INT_SBGP_neg;INT_SBGP_TIMES_CLOSED]))]);
                ((PURE_ONCE_REWRITE_TAC [BELOW_DEF]) THEN
                 (NEW_SUBST1_TAC 
                   (SYM (SPEC "MIN minus (N minus (MAX times MIN))"
                     PLUS_INV_INV_LEMMA))) THEN
                 (PURE_ONCE_REWRITE_TAC [(SYM (SPEC_ALL(NEG_DEF)))]) THEN
                 (PURE_REWRITE_TAC
                    [MINUS_DEF;
                     (SYM (SPEC_ALL (PLUS_DIST_INV_LEMMA)));
                     PLUS_INV_INV_LEMMA]) THEN
                 (INT_RIGHT_ASSOC_TAC
                   "(N plus (neg (MAX times MIN))) plus (neg MIN)") THEN
                 (PURE_REWRITE_TAC
                    [(SYM neg_PLUS_DISTRIB);(SYM (SPEC_ALL MINUS_DEF))]) THEN
                 (PURE_ONCE_REWRITE_TAC
                   [(PURE_ONCE_REWRITE_RULE [TIMES_IDENTITY] (SYM
                     (SPECL ["MAX:integer";"INT 1";"MIN:integer"]
                       RIGHT_PLUS_DISTRIB)))]) THEN
                 (MATCH_MP_IMP_TAC (ONCE_REWRITE_RULE []
                   (ASSUME
                     "!N'.MAX below N' ==>
                       ~~NEG (N minus (N' times MIN))"))) THEN
                 (SUBST_MATCH_TAC
                   (PURE_ONCE_REWRITE_RULE [COMM_PLUS]
                     (SPECL ["A:integer";"B:integer";"neg MAX"]
                       PLUS_BELOW_TRANSL))) THEN
                 (PURE_REWRITE_TAC
                    [(SYM (SPEC_ALL PLUS_GROUP_ASSOC));
                     PLUS_INV_LEMMA;
                     (SYM (SPEC_ALL NUM_LESS_IS_INT_BELOW));
                     PLUS_ID_LEMMA]) THEN
                 (CONV_TAC (DEPTH_CONV num_CONV)) THEN
                 (ACCEPT_TAC (theorem `prim_rec` `LESS_0_0`)))]);
              ((POP_ASSUM DISJ_CASES_TAC) THENL
               [RES_TAC;(FIRST_ASSUM ACCEPT_TAC)])]);
            ((EXISTS_TAC "INT 0") THEN 
             (PURE_REWRITE_TAC
               [MINUS_DEF;TIMES_ZERO;PLUS_INV_ID_LEMMA;PLUS_ID_LEMMA]) THEN
             (ACCEPT_TAC (REWRITE_RULE [(ASSUME "POS N")]
               (CONJUNCT1 (CONJUNCT2 (SPEC "N:integer" TRICHOTOMY))))));
            ((EXISTS_TAC "N:integer") THEN
             (REWRITE_TAC
               [NEG_DEF;
                MINUS_DEF;
                (SYM (SPEC_ALL PLUS_DIST_INV_LEMMA));
                PLUS_INV_INV_LEMMA]) THEN
             (PURE_REWRITE_TAC[(SYM (SPEC_ALL MINUS_DEF));
                (SYM (SPEC_ALL BELOW_DEF))]) THEN
             (STRIP_ASSUME_TAC
               (PURE_ONCE_REWRITE_RULE [POS_DEF] (ASSUME "POS MIN"))) THEN
             (PURE_ONCE_ASM_REWRITE_TAC[]) THEN
             ((DISJ_CASES_TAC (SPEC "n:num" LESS_0_CASES)) THENL
              [(POP_ASSUM \thm. (ASM_REWRITE_TAC
                 [(SYM thm);(SYM (num_CONV "1"));TIMES_IDENTITY]));
               ALL_TAC]) THEN
             (REPEAT STRIP_TAC) THEN
             (MP_IMP_TAC
               (SPECL ["N:integer";"N':integer";"N' times (INT(SUC n))"]
                TRANSIT)) THEN
             (ASM_REWRITE_TAC []) THEN
             (PURE_REWRITE_TAC
               [ADD1; (SYM (SPEC_ALL NUM_ADD_IS_INT_ADD));
                LEFT_PLUS_DISTRIB; TIMES_IDENTITY]) THEN
             (NEW_SUBST1_TAC
               (SPECL ["N':integer";"(N' times (INT n)) plus N'";"neg N'"]
                 PLUS_BELOW_TRANSL)) THEN
             (PURE_REWRITE_TAC
               [PLUS_GROUP_ASSOC;PLUS_INV_LEMMA;PLUS_ID_LEMMA]) THEN
             (NEW_SUBST1_TAC 
              (SYM (CONJUNCT1 (SPEC "N':integer" TIMES_ZERO)))) THEN
             (NEW_SUBST1_TAC
               (SYM (UNDISCH (SPECL ["N':integer"; "INT 0"; "INT n"]
                 POS_MULT_PRES_BELOW)))) THENL
             [(ASM_REWRITE_TAC [(SYM (SPEC_ALL (NUM_LESS_IS_INT_BELOW)))]);
              ((PURE_ONCE_REWRITE_TAC [POS_IS_ZERO_BELOW]) THEN
               (MP_IMP_TAC
                 (SPECL ["INT 0";"N:integer";"N':integer"] TRANSIT)) THEN
               (ASM_REWRITE_TAC[(SYM (SPEC_ALL POS_IS_ZERO_BELOW))]))])]);
          ((PURE_ONCE_REWRITE_TAC [NEG_DEF]) THEN
           (REPEAT STRIP_TAC) THEN
           (NEW_SUBST1_TAC (SYM (SPEC "N:integer" PLUS_INV_INV_LEMMA))) THEN
           (STRIP_ASSUME_TAC (MP
             (UNDISCH (SPEC "neg N"
               (ASSUME "!N. POS N ==> H N ==> (?p. N = p times MIN)")))
             (UNDISCH (SPEC "N:integer" (UNDISCH
               (SPEC "H:integer -> bool" INT_SBGP_neg)))))) THEN
           (EXISTS_TAC "neg p") THEN (ASM_REWRITE_TAC [TIMES_neg]));
          (DISCH_TAC THEN (EXISTS_TAC "INT 0") THEN
           (REWRITE_TAC [TIMES_ZERO]))]);
        (STRIP_TAC THEN (ASM_REWRITE_TAC []) THEN
         (NEW_MATCH_ACCEPT_TAC
           (UNDISCH (SPEC_ALL (UNDISCH (SPEC_ALL INT_SBGP_TIMES_CLOSED))))))]);
      ((STRIP_ASSUME_TAC
         (PURE_ONCE_REWRITE_RULE [POS_DEF] (ASSUME "POS MIN"))) THEN
       (EXISTS_TAC "SUC n") THEN (ASM_REWRITE_TAC []))]);
    ((POP_ASSUM \thm. STRIP_ASSUME_TAC 
       (REWRITE_RULE [IMP_DISJ_THM;DE_MORGAN_THM]
         (CONV_RULE NOT_FORALL_CONV thm))) THEN
     ((DISJ_CASES_TAC
        (CONJUNCT1 (SPEC "m1:integer" TRICHOTOMY))) THENL
      [((EXISTS_TAC "m1:integer") THEN (ASM_REWRITE_TAC []));
       ((POP_ASSUM DISJ_CASES_TAC) THENL
        [ALL_TAC; RES_TAC])]) THEN
     (EXISTS_TAC "neg m1") THEN
     (ASM_REWRITE_TAC
       [(SYM (SPEC_ALL NEG_DEF));
        (UNDISCH (SPEC "m1:integer"
          (UNDISCH (SPEC_ALL INT_SBGP_neg))))]));
    ((EXISTS_TAC "INT 0") THEN
     (PURE_ONCE_REWRITE_TAC [(SYM (SPEC_ALL NEG_IS_BELOW_ZERO))]) THEN
     GEN_TAC THEN DISCH_TAC THEN
     (REWRITE_TAC
       [(REWRITE_RULE[(ASSUME "NEG N")]
        (CONJUNCT1 (CONJUNCT2 (SPEC "N:integer" TRICHOTOMY))))]))])]));;
