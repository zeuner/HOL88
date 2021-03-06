/************************************************************************/
/*	Copyright 1988 by Chuck Musciano and Harris Corporation		*/
/*									*/
/*	Permission to use, copy, modify, and distribute this software	*/
/*	and its documentation for any purpose and without fee is	*/
/*	hereby granted, provided that the above copyright notice	*/
/*	appear in all copies and that both that copyright notice and	*/
/*	this permission notice appear in supporting documentation, and	*/
/*	that the name of Chuck Musciano and Harris Corporation not be	*/
/*	used in advertising or publicity pertaining to distribution	*/
/*	of the software without specific, written prior permission.	*/
/*	Chuck Musciano and Harris Corporation make no representations	*/
/*	about the suitability of this software for any purpose.  It is	*/
/*	provided "as is" without express or implied warranty.		*/
/************************************************************************/


%{

#include	<stdio.h>
#include	<ctype.h>

#include	"tooltool.h"

PUBLIC	Menu	ttymenu_proc();

PRIVATE	int	line_count = 1;
PRIVATE	int	curr_key, curr_key_set;
PRIVATE	g_ptr	curr_gadget = NULL;
PRIVATE	d_ptr	curr_window = NULL;
PRIVATE	char	ungetc = -1;

%}

%start	tool_spec

%union	{a_ptr		aval;
	 int		ival;
	 char		*cpval;
	 cv_ptr		cvval;
	 e_ptr		eval;
	 g_ptr		gval;
	 l_ptr		lval;
	 Menu		mval;
	 Menu_item	mival;
	 double		rval;
	}

%token	<cpval>	ICON_STRING ID STRING
%token	<ival>	INTEGER
%token	<rval>	REAL
%token	<ival>	L2 L3 L4 L5 L6 L7 L8 L9 L10 F1 F2 F3 F4 F5 F6 F7 F8 F9 R1 R2 R3 R4 R5 R6 R7 R8 R9 R10 R11 R12 R13 R14 R15

%token		AND ASSIGN_AND ASSIGN_DIVIDE ASSIGN_MINUS ASSIGN_MODULO ASSIGN_OR ASSIGN_PLUS
%token		ASSIGN_TIMES ASSIGN_XOR ASSIGNMENT COLON COMMA COMPLEMENT DECREMENT DIVIDE EQUAL
%token		GREATER GREATER_EQUAL INCREMENT LBRACE LBRACK LEFT_SHIFT LESS LESS_EQUAL
%token		LOGICAL_AND LOGICAL_NOT LOGICAL_OR LPAREN MINUS MODULO NOT_EQUAL OR PLUS
%token		QUESTION RBRACE RBRACK RIGHT_SHIFT RPAREN SEMICOLON TIMES XOR

%token		ACTION ALIGN APPLICATION AT BASE BEEP BOTTOM BREAK BUTTON BY CENTER
%token		CHARACTERS CHOICE CLOSE COMPLETION CONTINUE CONTROL CURRENT CYCLE DIALOG DISABLE
%token		DISPLAY ELSE END_BUTTON END_CHOICE END_DIALOG END_GADGETS END_KEY END_KEYS
%token		END_LABEL END_MENU END_MOUSE END_SLIDER END_TEXT EXIT FONT FOR
%token		FUNCTION_KEYS GADGETS HORIZONTAL ICON IF IGNORE INITIAL INITIALIZE
%token		KEY KEYS LABEL LEFT MARK MAXIMUM MENU META MIDDLE MINIMUM MOUSE
%token		NOMARK NORMAL NORMAL_KEYS NOTHING OFF ON OPEN PIXELS POPUP
%token		PROPORTIONAL RAGGED RANGE REMOVE RETAIN RIGHT SEND SHIFT SIZE
%token		SLIDER TEXT TIMER TOP TRIGGER TTYMENU VALUE VERTICAL WHILE WIDTH

%type	<aval>	action action_list open close initialize timer
%type	<ival>	size_unit shifts key_name button_name align
%type	<cpval>	label font icon optional_name
%type	<cvval>	choice_list
%type	<eval>	array_ref expr factor optional_expr
%type	<gval>	gadgets gadget_list gadget button_gadget choice_gadget
		label_gadget menu_gadget slider_gadget text_gadget
%type	<lval>	icon_label
%type	<mval>	menu menu_value
%type	<mival>	menu_entry

%left	ACTION
%left	ELSE
%left	EXPR
%left	SEMICOLON
%left	ARRAY_REF

%right	ASSIGNMENT ASSIGN_AND ASSIGN_DIVIDE ASSIGN_MINUS ASSIGN_MODULO ASSIGN_OR ASSIGN_PLUS ASSIGN_TIMES ASSIGN_XOR
%left	COMMA
%right	QUESTION COLON
%left	LOGICAL_OR
%left	LOGICAL_AND
%left	OR
%left	XOR
%left	AND
%left	EQUAL NOT_EQUAL
%left	LESS LESS_EQUAL GREATER GREATER_EQUAL
%left	LEFT_SHIFT RIGHT_SHIFT
%left	PLUS MINUS
%left	TIMES DIVIDE MODULO
%right	DECREMENT INCREMENT UMINUS COMPLEMENT LOGICAL_NOT
%left	LPAREN RPAREN

%%

tool_spec	:	APPLICATION STRING
					{ curr_window = tt_base_window; }
			appl_attr gadgets dialogs keys mouse
					{ tt_application = $2;
					  tt_base_window->gadgets = $5;
					  tt_base_window->is_base_frame = TRUE;
					}
		;

appl_attr	:	empty
		|	appl_attr size
		|	appl_attr position
		|	appl_attr icon
					{ if (tt_icon == NULL)
					     tt_icon = $2;
					  else
					     yyerror("Conflicting application icon specifications");
					}
		|	appl_attr label
					{ if (curr_window->label == NULL)
					     curr_window->label = $2;
					  else
					     yyerror("Conflicting window label specifications");
					}
		|	appl_attr font
					{ if (tt_a_font == tt_default_font)
					     tt_a_font = tt_open_font($2);
					  else
					     yyerror("Conflicting application font specifications");
					}
		|	appl_attr open
					{ if (curr_window->open_action == NULL)
					     curr_window->open_action = $2;
					  else
					     yyerror("Conflicting window opening strings");
					}
		|	appl_attr close
					{ if (curr_window->close_action == NULL)
					     curr_window->close_action = $2;
					  else
					     yyerror("Conflicting window closing strings");
					}
		|	appl_attr initialize
					{ if (tt_initial_action == NULL)
					     tt_initial_action = $2;
					  else
					     yyerror("Conflicting initial command strings");
					}
		|	appl_attr timer
					{ if (tt_timer_action == NULL)
					     tt_timer_action = $2;
					  else
					     yyerror("Conflicting timer command strings");
					}
		;

size		:	SIZE INTEGER BY INTEGER size_unit
					{ curr_window->rows = $2;
					  curr_window->columns = $4;
					  curr_window->is_chars = $5;
					}
		;

position	:	AT INTEGER INTEGER
					{ curr_window->win_x = $2;
					  curr_window->win_y = $3;
					}
		;

size_unit	:	CHARACTERS
					{ $$ = TRUE; }
		|	PIXELS
					{ $$ = FALSE; }
		;

icon		:	ICON STRING
					{ $$ = $2; }
		;

label		:	LABEL STRING
					{ $$ = $2; }
		;

font		:	FONT STRING
					{ $$ = $2; }
		;

open		:	OPEN action
					{ $$ = $2; }
		;

close		:	CLOSE action
					{ $$ = $2; }
		;

initialize	:	INITIALIZE action
					{ $$ = $2; }
		;

timer		:	TIMER action
					{ $$ = $2; }
		;

gadgets		:	empty
					{ $$ = (g_ptr) 0; }
		|	GADGETS gadget_attr gadget_list END_GADGETS
					{ if (curr_window->gadget_pos == G_NOPOS)
					     curr_window->gadget_pos = G_TOP;
					  $$ = $3;
					}
		;

gadget_attr	:	empty
		|	gadget_attr TOP
					{ if (curr_window->gadget_pos == G_NOPOS)
					     curr_window->gadget_pos = G_TOP;
					  else
					     yyerror("Conflicting gadget position specified");
					}
		|	gadget_attr BOTTOM
					{ if (curr_window->gadget_pos == G_NOPOS)
					     curr_window->gadget_pos = G_BOTTOM;
					  else
					     yyerror("Conflicting gadget position specified");
					}
		|	gadget_attr LEFT
					{ if (curr_window->gadget_pos == G_NOPOS)
					     curr_window->gadget_pos = G_LEFT;
					  else
					     yyerror("Conflicting gadget position specified");
					}
		|	gadget_attr RIGHT
					{ if (curr_window->gadget_pos == G_NOPOS)
					     curr_window->gadget_pos = G_RIGHT;
					  else
					     yyerror("Conflicting gadget position specified");
					}
		|	gadget_attr PROPORTIONAL
					{ curr_window->proportional = TRUE; }
		|	gadget_attr RAGGED
					{ curr_window->justified = FALSE; }
		|	gadget_attr font
					{ if (curr_window->g_font == tt_default_font)
					     curr_window->g_font = tt_open_font($2);
					  else
					     yyerror("Conflicting gadget font specified");
					}
		|	gadget_attr align
					{ if (curr_window->g_align == NO_ALIGN)
					     curr_window->g_align = $2;
					  else
					     yyerror("Conflicting gadget alignment specified");
					}
		;

align		:	ALIGN LEFT
					{ $$ = ALIGN_TOP; }
		|	ALIGN CENTER
					{ $$ = ALIGN_MIDDLE; }
		|	ALIGN RIGHT
					{ $$ = ALIGN_BOTTOM; }
		|	ALIGN TOP
					{ $$ = ALIGN_TOP; }
		|	ALIGN MIDDLE
					{ $$ = ALIGN_MIDDLE; }
		|	ALIGN BOTTOM
					{ $$ = ALIGN_BOTTOM; }
		;

gadget_list	:	empty
					{ $$ = NULL; }
		|	gadget_list gadget
					{ g_ptr	g;
					  
					  if ($1 == NULL)
					     $$ = $2;
					  else {
					     for (g = $1; g->next; g = g->next)
					        ;
					     g->next = $2;
					     $$ = $1;
					     }
					}
		;

gadget		:	button_gadget
		|	choice_gadget
		|	label_gadget
		|	menu_gadget
		|	slider_gadget
		|	text_gadget
		;

button_gadget	:	BUTTON optional_name
					{ int	i;
					  s_ptr	s;

					  curr_gadget = (g_ptr) safe_malloc(sizeof(g_data));
					  curr_gadget->kind = GADGET_BUTTON;
					  curr_gadget->name = NULL;
					  curr_gadget->image = NULL;
					  curr_gadget->x = -1;
					  curr_gadget->next = NULL;
					  for (i = 0; i < MAX_SHIFT_SETS; i++) {
					     curr_gadget->u.but.label[i] = NULL;
					     curr_gadget->u.but.action[i] = NULL;
					     }
					  if ($2 != NULL) {
					     s = tt_find_symbol($2);
					     if (s->kind != SYMBOL_SYMBOL)
					        yyerror("Duplicate name: %s", s->name);
					     s->kind = SYMBOL_GADGET;
					     s->gadget = curr_gadget;
					     }
					}
			gadget_position value_list value_item END_BUTTON
					{ if (curr_gadget->u.but.label[0] == NULL)
					     yyerror("Every button must have a \"normal\" action");
					  $$ = curr_gadget;
					}
		;

value_list	:	empty
		|	value_list value_item
		;

value_item	:	shifts icon_label action
					{ if (curr_gadget->u.but.label[$1] != NULL)
					     yyerror("Duplicate button action");
					  curr_gadget->u.but.label[$1] = $2;
					  curr_gadget->u.but.action[$1] = $3;
					}
		;

shifts		:	empty
					{ $$ = S_NORMAL; }
		|	shifts NORMAL
					{ $$ = $1 | S_NORMAL; }
		|	shifts SHIFT
					{ $$ = $1 | S_SHIFT; }
		|	shifts CONTROL
					{ $$ = $1 | S_CONTROL; }
		|	shifts META
					{ $$ = $1 | S_META; }
		;

choice_gadget	:	CHOICE optional_name
					{ s_ptr	s;

					  curr_gadget = (g_ptr) safe_malloc(sizeof(g_data));
					  curr_gadget->kind = GADGET_CHOICE;
					  curr_gadget->name = $2;
					  curr_gadget->image = NULL;
					  curr_gadget->x = -1;
					  curr_gadget->next = NULL;
					  curr_gadget->u.cho.label = NULL;
					  curr_gadget->u.cho.mode = CHOICE_CURRENT;
					  curr_gadget->u.cho.mark = tt_default_mark;
					  curr_gadget->u.cho.nomark = tt_default_nomark;
					  curr_gadget->u.cho.value = NULL;
					  if ($2 != NULL) {
					     s = tt_find_symbol($2);
					     if (s->kind != SYMBOL_SYMBOL)
					        yyerror("Duplicate name: %s", s->name);
					     s->kind = SYMBOL_GADGET;
					     s->gadget = curr_gadget;
					     }
					}
			choice_attr choice_list END_CHOICE
					{ curr_gadget->u.cho.value = $5;
					  if (curr_gadget->u.cho.mode == CHOICE_CYCLE)
					     if (curr_gadget->u.cho.mark == tt_default_mark)
					        curr_gadget->u.cho.mark = curr_gadget->u.cho.nomark = tt_default_cycle;
					     else
					        curr_gadget->u.cho.nomark = curr_gadget->u.cho.mark;
					  $$ = curr_gadget;
					}
		;

choice_attr	:	empty
		|	choice_attr DISPLAY CURRENT
					{ curr_gadget->u.cho.mode = CHOICE_CURRENT; }
		|	choice_attr DISPLAY CYCLE
					{ curr_gadget->u.cho.mode = CHOICE_CYCLE; }
		|	choice_attr DISPLAY HORIZONTAL
					{ curr_gadget->u.cho.mode = CHOICE_HORIZONTAL; }
		|	choice_attr DISPLAY VERTICAL
					{ curr_gadget->u.cho.mode = CHOICE_VERTICAL; }
		|	choice_attr MARK icon_label
					{ curr_gadget->u.cho.mark = $3; }
		|	choice_attr NOMARK icon_label
					{ curr_gadget->u.cho.nomark = $3; }
		|	choice_attr LABEL icon_label
					{ curr_gadget->u.cho.label = $3; }
		|	choice_attr AT INTEGER INTEGER
					{ curr_gadget->x = $3;
					  curr_gadget->y = $4;
					}
		;

choice_list	:	empty
					{ $$ = NULL; }
		|	choice_list icon_label action
					{ cv_ptr curr, head;
					
					  curr = (cv_ptr) safe_malloc(sizeof(cv_data));
					  curr->label = $2;
					  curr->action = $3;
					  curr->next = NULL;
					  if ($1 == NULL)
					     $$ = curr;
					  else {
					     for (head = $1; head->next; head = head->next)
					        ;
					     head->next = curr;
					     $$ = $1;
					     }
					}
		;

label_gadget	:	LABEL optional_name
					{ s_ptr	s;

					  curr_gadget = (g_ptr) safe_malloc(sizeof(g_data));
					  curr_gadget->kind = GADGET_LABEL;
					  curr_gadget->name = NULL;
					  curr_gadget->image = NULL;
					  curr_gadget->x = -1;
					  curr_gadget->next = NULL;
					  if ($2 != NULL) {
					     s = tt_find_symbol($2);
					     if (s->kind != SYMBOL_SYMBOL)
					        yyerror("Duplicate name: %s", s->name);
					     s->kind = SYMBOL_GADGET;
					     s->gadget = curr_gadget;
					     }
					}
			gadget_position icon_label END_LABEL
					{ curr_gadget->u.lab.label = $5;
					  $$ = curr_gadget;
					}
		;

menu_gadget	:	MENU optional_name
					{ s_ptr	s;

					  curr_gadget = (g_ptr) safe_malloc(sizeof(g_data));
					  curr_gadget->kind = GADGET_MENU;
					  curr_gadget->name = NULL;
					  curr_gadget->image = NULL;
					  curr_gadget->x = -1;
					  curr_gadget->next = NULL;
					  if ($2 != NULL) {
					     s = tt_find_symbol($2);
					     if (s->kind != SYMBOL_SYMBOL)
					        yyerror("Duplicate name: %s", s->name);
					     s->kind = SYMBOL_GADGET;
					     s->gadget = curr_gadget;
					     }
					}
			gadget_position icon_label menu_value END_MENU
					{ curr_gadget->u.men.label = $5;
					  curr_gadget->u.men.menu = $6;
					  $$ = curr_gadget;
					}
		;

menu		:	MENU menu_value END_MENU
					{ $$ = $2; }
		|	TTYMENU
					{ $$ = menu_create(MENU_GEN_PROC, ttymenu_proc, 0); }
		;

menu_value	:	menu_entry
					{ $$ = menu_create(MENU_APPEND_ITEM, $1, 0); }
		|	menu_value menu_entry
					{ 
					  menu_set($1, MENU_APPEND_ITEM, $2, 0);
					  $$ = $1;
					}
		;

menu_entry	:	icon_label action
					{
					  if ($1->is_icon)
					     $$ = menu_create_item(MENU_IMAGE_ITEM, $1->image, $2, 0);
					  else
					     $$ = menu_create_item(MENU_STRING_ITEM, $1->label, $2, MENU_FONT, $1->font, 0);
					}
		|	icon_label menu
					{
					  if ($1->is_icon)
					     $$ = menu_create_item(MENU_PULLRIGHT_IMAGE, $1->image, $2, 0);
					  else
					     $$ = menu_create_item(MENU_PULLRIGHT_ITEM, $1->label, $2, MENU_FONT, $1->font, 0);
					}
		;

slider_gadget	:	SLIDER optional_name
					{ s_ptr	s;
					
					  curr_gadget = (g_ptr) safe_malloc(sizeof(g_data));
					  curr_gadget->kind = GADGET_SLIDER;
					  curr_gadget->name = $2;
					  curr_gadget->image = NULL;
					  curr_gadget->x = -1;
					  curr_gadget->next = NULL;
					  curr_gadget->u.sli.label = NULL;
					  curr_gadget->u.sli.minimum = 0;
					  curr_gadget->u.sli.maximum = 100;
					  curr_gadget->u.sli.initial = 0;
					  curr_gadget->u.sli.value = TRUE;
					  curr_gadget->u.sli.range = TRUE;
					  curr_gadget->u.sli.width = 100;
					  curr_gadget->u.sli.action = NULL;
					  curr_gadget->u.sli.font = curr_window->g_font;
					  if ($2 != NULL) {
					     s = tt_find_symbol($2);
					     if (s->kind != SYMBOL_SYMBOL)
					        yyerror("Duplicate name: %s", s->name);
					     s->kind = SYMBOL_GADGET;
					     s->gadget = curr_gadget;
					     }
					}
			slider_attr END_SLIDER
					{
					  if (curr_gadget->u.sli.minimum > curr_gadget->u.sli.maximum)
					     yyerror("Slider maximum must exceed slider minimum");
					  if (curr_gadget->u.sli.initial < curr_gadget->u.sli.minimum ||
					      curr_gadget->u.sli.initial > curr_gadget->u.sli.maximum)
					     yyerror("Slider initial value must in the range [minimum, maximum]");
					  $$ = curr_gadget;
					}
		;

slider_attr	:	empty
		|	slider_attr ACTION action
					{ curr_gadget->u.sli.action = $3; }
		|	slider_attr FONT STRING
					{ curr_gadget->u.sli.font = tt_open_font($3); }
		|	slider_attr INITIAL INTEGER
					{ curr_gadget->u.sli.initial = $3; }
		|	slider_attr LABEL icon_label
					{ curr_gadget->u.sli.label = $3; }
		|	slider_attr MAXIMUM INTEGER
					{ curr_gadget->u.sli.maximum = $3; }
		|	slider_attr MINIMUM INTEGER
					{ curr_gadget->u.sli.minimum = $3; }
		|	slider_attr RANGE OFF
					{ curr_gadget->u.sli.range = FALSE; }
		|	slider_attr RANGE ON
					{ curr_gadget->u.sli.range = TRUE; }
		|	slider_attr VALUE OFF
					{ curr_gadget->u.sli.value = FALSE; }
		|	slider_attr VALUE ON
					{ curr_gadget->u.sli.value = TRUE; }
		|	slider_attr WIDTH INTEGER
					{ curr_gadget->u.sli.width = $3; }
		|	slider_attr AT INTEGER INTEGER
					{ curr_gadget->x = $3;
					  curr_gadget->y = $4;
					}
		;

text_gadget	:	TEXT optional_name
					{ s_ptr	s;

					  curr_gadget = (g_ptr) safe_malloc(sizeof(g_data));
					  curr_gadget->kind = GADGET_TEXT;
					  curr_gadget->name = $2;
					  curr_gadget->image = NULL;
					  curr_gadget->x = -1;
					  curr_gadget->next = NULL;
					  curr_gadget->u.tex.label = NULL;
					  curr_gadget->u.tex.trigger = "\n\r";
					  curr_gadget->u.tex.completion = "";
					  curr_gadget->u.tex.ignore = tt_expand_ranges("\001-\037");
					  curr_gadget->u.tex.display_len = 80;
					  curr_gadget->u.tex.retain_len = 256;
					  curr_gadget->u.tex.action = NULL;
					  curr_gadget->u.tex.font = curr_window->g_font;
					  curr_window->text_items_exist = TRUE;
					  if ($2 != NULL) {
					     s = tt_find_symbol($2);
					     if (s->kind != SYMBOL_SYMBOL)
					        yyerror("Duplicate name: %s", s->name);
					     s->kind = SYMBOL_GADGET;
					     s->gadget = curr_gadget;
					     }
					}
			text_attr END_TEXT
					{ $$ = curr_gadget; }
		;

text_attr	:	empty
		|	text_attr ACTION action
					{ curr_gadget->u.tex.action = $3; }
		|	text_attr AT INTEGER INTEGER
					{ curr_gadget->x = $3;
					  curr_gadget->y = $4;
					}
		|	text_attr COMPLETION STRING
					{ curr_gadget->u.tex.completion = tt_expand_ranges($3); }
		|	text_attr DISPLAY INTEGER
					{ curr_gadget->u.tex.display_len = $3; }
		|	text_attr FONT STRING
					{ curr_gadget->u.tex.font = tt_open_font($3); }
		|	text_attr IGNORE STRING
					{ curr_gadget->u.tex.ignore = tt_expand_ranges($3); }
		|	text_attr LABEL icon_label
					{ curr_gadget->u.tex.label = $3; }
		|	text_attr RETAIN INTEGER
					{ curr_gadget->u.tex.retain_len = $3; }
		|	text_attr TRIGGER STRING
					{ curr_gadget->u.tex.trigger = tt_expand_ranges($3); }
		;

icon_label	:	STRING
					{ $$ = tt_make_label(FALSE, $1, curr_window->g_font, NULL); }
		|	STRING COLON STRING
					{ $$ = tt_make_label(FALSE, $1, tt_open_font($3), NULL); }
		|	ICON_STRING
					{ $$ = tt_make_label(TRUE, NULL, NULL, tt_load_icon($1)); }
		;

optional_name	:	empty
					{ $$ = NULL; }
		|	ID
					{ $$ = $1; }
		;

gadget_position	:	empty
		|	AT INTEGER INTEGER
					{ curr_gadget->x = $2;
					  curr_gadget->y = $3;
					}
		;

action		:	SEMICOLON
					{ $$ = NULL; }
		|	BEEP SEMICOLON
					{ $$ = tt_make_action(BEEP_OP); }
		|	BREAK SEMICOLON
					{ $$ = tt_make_action(BREAK_OP); }
		|	CLOSE %prec ACTION
					{ $$ = tt_make_action(CLOSE_OP); }
		|	CLOSE SEMICOLON
					{ $$ = tt_make_action(CLOSE_OP); }
		|	CONTINUE SEMICOLON
					{ $$ = tt_make_action(CONTINUE_OP); }
		|	DISPLAY ID SEMICOLON
					{ $$ = tt_make_action(DISPLAY_OP, tt_make_expr(E_SYMBOL, tt_find_symbol($2))); }
		|	EXIT %prec ACTION
					{ $$ = tt_make_action(EXIT_OP); }
		|	EXIT SEMICOLON
					{ $$ = tt_make_action(EXIT_OP); }
		|	expr %prec EXPR
					{ $$ = tt_make_action(($1->op == E_STRING)? SEND_OP : EXPR_OP, $1); }
		|	expr SEMICOLON %prec EXPR
					{ $$ = tt_make_action(($1->op == E_STRING)? SEND_OP : EXPR_OP, $1); }
		|	FOR LPAREN optional_expr SEMICOLON optional_expr SEMICOLON optional_expr RPAREN action
					{ $$ = tt_make_action(FOR_OP, $3, $5, $7, $9); }
		|	IF LPAREN expr RPAREN action %prec ACTION
					{ $$ = tt_make_action(IF_OP, $3, $5, NULL); }
		|	IF LPAREN expr RPAREN action ELSE action %prec ELSE
					{ $$ = tt_make_action(IF_OP, $3, $5, $7); }
		|	LBRACE action_list RBRACE
					{ $$ = $2; }
		|	NOTHING SEMICOLON
					{ $$ = NULL; }
		|	OPEN SEMICOLON
					{ $$ = tt_make_action(OPEN_OP); }
		|	POPUP ID SEMICOLON
					{ $$ = tt_make_action(POPUP_OP, tt_make_expr(E_SYMBOL, tt_find_symbol($2))); }
		|	REMOVE ID SEMICOLON
					{ $$ = tt_make_action(REMOVE_OP, tt_make_expr(E_SYMBOL, tt_find_symbol($2))); }
		|	SEND expr SEMICOLON %prec EXPR
					{ $$ = tt_make_action(SEND_OP, $2); }
		|	WHILE LPAREN expr RPAREN action
					{ $$ = tt_make_action(WHILE_OP, $3, $5); }
		;

action_list	:	empty
					{ $$ = NULL; }
		|	action action_list
					{ a_ptr	a;

					  if ($1 == NULL)
					     $$ = $2;
					  else {
					     for (a = $1; a->next != NULL; a = a->next)
					        ;
					     a->next = $2;
					     $$ = $1;
					     }
					}
		;

optional_expr	:	empty
					{ $$ = NULL; }
		|	expr
		;

expr		:	factor
		|	array_ref ASSIGNMENT expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGNMENT, $1, $3);
					}
		|	array_ref ASSIGN_AND expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGN_AND, $1, $3);
					}
		|	array_ref ASSIGN_DIVIDE expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGN_DIVIDE, $1, $3);
					}
		|	array_ref ASSIGN_MINUS expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGN_MINUS, $1, $3);
					}
		|	array_ref ASSIGN_MODULO expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGN_MODULO, $1, $3);
					}
		|	array_ref ASSIGN_OR expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGN_OR, $1, $3);
					}
		|	array_ref ASSIGN_PLUS expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGN_PLUS, $1, $3);
					}
		|	array_ref ASSIGN_TIMES expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGN_TIMES, $1, $3);
					}
		|	array_ref ASSIGN_XOR expr
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot assign to an intrinsic function");
					  $$ = tt_make_expr(E_ASSIGN_XOR, $1, $3);
					}
		|	LPAREN expr RPAREN
					{ $$ = tt_make_expr(E_PAREN, $2); }
		|	expr PLUS expr
					{ $$ = tt_make_expr(E_PLUS, $1, $3); }
		|	expr MINUS expr
					{ $$ = tt_make_expr(E_MINUS, $1, $3); }
		|	expr TIMES expr
					{ $$ = tt_make_expr(E_TIMES, $1, $3); }
		|	expr DIVIDE expr
					{ $$ = tt_make_expr(E_DIVIDE, $1, $3); }
		|	expr MODULO expr
					{ $$ = tt_make_expr(E_MODULO, $1, $3); }
		|	expr AND expr
					{ $$ = tt_make_expr(E_AND, $1, $3); }
		|	expr OR expr
					{ $$ = tt_make_expr(E_OR, $1, $3); }
		|	expr XOR expr
					{ $$ = tt_make_expr(E_XOR, $1, $3); }
		|	expr LOGICAL_AND expr
					{ $$ = tt_make_expr(E_LOGICAL_AND, $1, $3); }
		|	expr LOGICAL_OR expr
					{ $$ = tt_make_expr(E_LOGICAL_OR, $1, $3); }
		|	expr LEFT_SHIFT expr
					{ $$ = tt_make_expr(E_LEFT_SHIFT, $1, $3); }
		|	expr RIGHT_SHIFT expr
					{ $$ = tt_make_expr(E_RIGHT_SHIFT, $1, $3); }
		|	expr LESS expr
					{ $$ = tt_make_expr(E_LESS, $1, $3); }
		|	expr LESS_EQUAL expr
					{ $$ = tt_make_expr(E_LESS_EQUAL, $1, $3); }
		|	expr EQUAL expr
					{ $$ = tt_make_expr(E_EQUAL, $1, $3); }
		|	expr GREATER_EQUAL expr
					{ $$ = tt_make_expr(E_GREATER_EQUAL, $1, $3); }
		|	expr GREATER expr
					{ $$ = tt_make_expr(E_GREATER, $1, $3); }
		|	expr NOT_EQUAL expr
					{ $$ = tt_make_expr(E_NOT_EQUAL, $1, $3); }
		|	expr COMMA expr
					{ $$ = tt_make_expr(E_COMMA, $1, $3); }
		|	MINUS expr %prec UMINUS
					{ $$ = tt_make_expr(E_UMINUS, $2); }
		|	COMPLEMENT expr
					{ $$ = tt_make_expr(E_COMPLEMENT, $2); }
		|	LOGICAL_NOT expr
					{ $$ = tt_make_expr(E_LOGICAL_NOT, $2); }
		|	DECREMENT array_ref
					{ if ($2->op == E_FUNC_ID)
					     yyerror("cannot decrement an intrinsic function");
					  $$ = tt_make_expr(E_PREDECREMENT, $2);
					}
		|	INCREMENT array_ref
					{ if ($2->op == E_FUNC_ID)
					     yyerror("cannot increment an intrinsic function");
					  $$ = tt_make_expr(E_PREINCREMENT, $2);
					}
		|	array_ref DECREMENT
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot decrement an intrinsic function");
					  $$ = tt_make_expr(E_POSTDECREMENT, $1);
					}
		|	array_ref INCREMENT
					{ if ($1->op == E_FUNC_ID)
					     yyerror("cannot increment an intrinsic function");
					  $$ = tt_make_expr(E_POSTINCREMENT, $1);
					}
		|	expr QUESTION expr COLON expr
					{ $$ = tt_make_expr(E_QUESTION, $1, $3, $5); }
		;

factor		:	array_ref %prec ARRAY_REF
		|	STRING
					{ $$ = tt_make_expr(E_STRING, $1); }
		|	INTEGER
					{ double temp;

					  temp = (double) $1;
					  $$ = tt_make_expr(E_NUMBER, &temp);
					}
		|	REAL
					{ $$ = tt_make_expr(E_NUMBER, &($1)); }
		;

array_ref	:	ID %prec ARRAY_REF
					{ $$ = tt_make_expr(E_SYMBOL, tt_find_symbol($1)); }
		|	ID LPAREN optional_expr RPAREN %prec LPAREN
					{ f_ptr	func;

					  if ((func = tt_is_function($1)) == NULL)
					     yyerror("'%s' is not a valid function name", $1);
					  $$ = tt_make_expr(E_FUNC_ID, func, $3);
					}
		|	array_ref LBRACK expr RBRACK
					{ $$ = tt_make_expr(E_ARRAY_REF, $1, $3); }
		;

dialogs		:	empty
		|	dialogs dialog_box
		;

dialog_box	:	DIALOG ID
					{ s_ptr	s;
					  
					  curr_window = tt_make_base_window();
					  curr_window->next = tt_base_window->next;
					  tt_base_window->next = curr_window;
					  s = tt_find_symbol($2);
					  if (s->kind == SYMBOL_SYMBOL)
					     s->kind = SYMBOL_DIALOG;
					  else if (s->kind == SYMBOL_GADGET)
					     yyerror("%s: name is already in use as a gadget", $2);
					  else if (s->dialog != NULL)
					     yyerror("%s: name is already in use as a dialog box", $2);
					  s->dialog = curr_window;
					  curr_window->is_open = FALSE;
					}
			dialog_attr gadgets END_DIALOG
					{ curr_window->gadgets = $5; }
		;

dialog_attr	:	empty
		|	dialog_attr size
		|	dialog_attr position
		|	dialog_attr label
					{ if (curr_window->label == NULL)
					     curr_window->label = $2;
					  else
					     yyerror("Conflicting window label specifications");
					}
		|	dialog_attr open
					{ if (curr_window->open_action == NULL)
					     curr_window->open_action = $2;
					  else
					     yyerror("Conflicting window opening strings");
					}
		|	dialog_attr close
					{ if (curr_window->close_action == NULL)
					     curr_window->close_action = $2;
					  else
					     yyerror("Conflicting window closing strings");
					}
		;


keys		:	empty
		|	KEYS key_attr key_list END_KEYS
		;

key_attr	:	empty
		|	key_attr DISABLE NORMAL_KEYS
					{ tt_normal_off = TRUE; }
		|	key_attr DISABLE FUNCTION_KEYS
					{ tt_function_off = TRUE; }
		;

key_list	:	empty
		|	key_list key_entry
		;

key_entry	:	KEY key_name
					{ if ($2 >= L2 && $2 <= L10) {
					     curr_key_set = LEFT_KEY_SET;
					     curr_key = $2 - L2 + 1;
					     }
					  else if ($2 >= F1 && $2 <= F9) {
					     curr_key_set = TOP_KEY_SET;
					     curr_key = $2 - F1;
					     }
					  else {
					     curr_key_set = RIGHT_KEY_SET;
					     curr_key = $2 - R1;
					     }
					}
			key_value_list END_KEY
		;

key_name	:	L2 | L3 | L4 | L5 | L6 | L7 | L8 | L9 | L10
		|	F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9 
		|	R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9 | R10 | R11 | R12 | R13 | R14 | R15
		;

key_value_list	:	key_value_entry
		|	key_value_list key_value_entry
		;

key_value_entry	:	shifts action
					{ tt_func_keys[curr_key_set][curr_key][$1] = $2; }
		;

mouse		:	empty
		|	MOUSE mouse_attr mouse_list END_MOUSE
		;

mouse_attr	:	empty
		|	BASE INTEGER size_unit
					{ tt_mouse_base = $2;
					  tt_mouse_chars = $3;
					}
		;

mouse_list	:	empty
		|	mouse_list mouse_entry
		;

mouse_entry	:	BUTTON button_name
					{ curr_key = $2; }
			mouse_values END_BUTTON
		;

button_name	:	LEFT
					{ $$ = MOUSE_LEFT; }
		|	MIDDLE
					{ $$ = MOUSE_CENTER; }
		|	RIGHT
					{ $$ = MOUSE_RIGHT; }
		;

mouse_values	:	empty
		|	mouse_values mouse_value
		;

mouse_value	:	shifts action
					{ tt_mouse[curr_key][$1].defined = MOUSE_STRING;
					  tt_mouse[curr_key][$1].action = $2;
					}
		|	shifts menu
					{ tt_mouse[curr_key][$1].defined = MOUSE_MENU;
					  tt_mouse[curr_key][$1].menu = $2;
					}
		;

empty		: ;

%%

PRIVATE	yyerror(s1, s2, s3, s4, s5, s6, s7)

char	*s1, *s2, *s3, *s4, *s5, *s6, *s7;

{
	fprintf(stderr, "%s: line %d: ", tt_curr_file, line_count - ((ungetc == '\n')? 1 : 0));
	fprintf(stderr, s1, s2, s3, s4, s5, s6, s7);
	if (strcmp(s1, "syntax error") == 0)
	   print_last_token();
	fprintf(stderr, "\n");
	yyclearin;
	tt_errors_occured++;
}

#include "lex.c"

