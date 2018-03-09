%{
  #include <stdio.h>
  #include <stdlib.h>
  void yyerror(const char *msg);
  extern int currLine;
  extern int currPos;
  FILE * yyin;
%}

%union{
  char* identToken;
  int numToken; 
}

%error-verbose
%start program_start
%left ADD SUB MULT DIV MOD
%left EQ NEQ LT GT LTE GTE
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP 
%token CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN 
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token <numToken> NUMBER
%token <identToken> IDENT

%%

program_start:
                  {printf("program_start -> epsilon\n");}
                  | function program_start {printf("program_start -> function program_start\n");}
                  ;

function:         
		  		FUNCTION IDENT SEMICOLON BEGIN_PARAMS declaration_loop END_PARAMS BEGIN_LOCALS declaration_loop END_LOCALS BEGIN_BODY statement_loop END_BODY {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declaration_loop END_PARAMS BEGIN_LOCALS declaration_loop END_LOCALS BEGIN_BODY statement_loop END_BODY\n");}
                  ;
									
declaration_loop: 
				{printf("declaration_loop -> epsilon\n");}
				| declaration SEMICOLON declaration_loop {printf("declaration_loop -> declaration SEMICOLON declaration_loop\n");}
				;
									
statement_loop:
				{printf("statement_loop -> epsilon\n");}
				| statement SEMICOLON statement_loop {printf("statement_loop -> statement SEMICOLON statement_loop\n");}
				;
									
declaration:
				identifier_loop COLON INTEGER {printf("declaration -> identifier_loop COLON INTEGER\n");}
				| identifier_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifier_loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
				;
									
identifier_loop:
				IDENT {printf("identifier_loop -> IDENT %s\n", $1);}
				| IDENT COMMA identifier_loop {printf("identifier_loop -> IDENT %s COMMA identifier_loop\n", $1);}
				;
									
statement:  
				var ASSIGN expression {printf("statement -> var ASSIGNMENT expression\n");}
				| IF bool_expr THEN statement_loop ENDIF {printf("statement -> IF bool_expr THEN statment_loop ENDIF\n");}
				| IF bool_expr THEN statement_loop ELSE statement_loop ENDIF {printf("statement -> IF bool_expr THEN statement_loop ELSE statement_loop ENDIF\n");}
				| WHILE bool_expr BEGINLOOP statement_loop ENDLOOP {printf("statement -> WHILE bool_expr BEGINLOOP statement_loop ENDLOOP\n");}
				| DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr {printf("statement -> DO BEGINLOOP statement_loop ENDLOOP WHILE bool_expr\n");}
				| FOREACH IDENT IN IDENT BEGINLOOP statement_loop ENDLOOP {printf("statement -> FOREACH IDENT IN IDENT BEGINLOOP statement_loop ENDLOOP\n");}
				| READ var var_loop {printf("statement -> READ var_loop\n");}
				| WRITE var var_loop {printf("statement -> WRITE var_loop\n");}
				| CONTINUE {printf("statement -> CONTINUE\n");}
				| RETURN expression {printf("statement -> RETURN expression\n");}
				;
                  
var_loop:
				{printf("var_loop -> epsilon\n");}
				| COMMA var var_loop {printf("var_loop -> COMMA var var_loop\n");}
				;
                  
bool_expr:
				relation_and_expr {printf("bool_expr -> relation_and_expr\n");}
				| bool_expr OR relation_and_expr {printf("bool_expr -> bool_expr OR relation_and_expr\n");}
				;
                  
relation_and_expr:
				relation_expr1 {printf("relation_and_expr -> relation_expr\n");}
				| relation_and_expr AND relation_expr1 {printf("relation_and_expr -> relation_and_expr AND relation_expr1\n");}
				;
                  
relation_expr1:
				relation_expr2 {printf("relation_expr1 -> relation_expr2\n");}
				| NOT relation_expr2 {printf("relation_expr1 -> NOT relation_expr2\n");}
				;
                  
relation_expr2:  
				expression comp expression {printf("relation_expr2 -> expression comp expression\n");}
				| TRUE {printf("relation_expr2 -> TRUE\n");}
				| FALSE {printf("relation_expr2 -> FALSE\n");}
				| L_PAREN bool_expr R_PAREN {printf("relation_expr2 -> L_PAREN bool_expr R_PAREN\n");}
				;
                  
comp:
				EQ {printf("comp -> EQ\n");}
				| NEQ {printf("comp -> NEQ\n");}
				| LT {printf("comp -> LT\n");}
				| GT {printf("comp -> GT\n");}
				| LTE {printf("comp -> LTE\n");}
				| GTE {printf("comp -> GTE\n");}
				;
                  
expression:
				multiplicative_expr expr_addon {printf("expression -> multiplicative_expr mult_addon\n");}
				;       
		  
expr_addon:
				{printf("expr_addon -> epsilon\n");}
				| SUB multiplicative_expr expr_addon {printf("expr_addon -> SUB multiplicative_expr expression expr_addon\n");}
				| ADD multiplicative_expr expr_addon {printf("expr_addon -> ADD multiplicative_expr expression expr_addon\n");}
				;
                  
multiplicative_expr: 
				term mult_addon {printf("multiplicative_expr -> term mult_addon\n");}
				;
                  
mult_addon:
				{printf("mult_addon -> epsilon\n");}
				| MOD term mult_addon {printf("mult_addon -> MOD term mult_addon\n");}
				| DIV term mult_addon {printf("mult_addon -> DIV term mult_addon\n");}
				| MULT term mult_addon {printf("mult_addon -> MULT term mult_addon\n");}
				;
                  
term: 
				sub_term {printf("term -> sub_term\n");}
				| SUB sub_term {printf("term -> SUB sub_term\n");}
 				| IDENT L_PAREN R_PAREN {printf("term -> IDENT %s L_PAREN R_PAREN\n", $1);}
				| IDENT L_PAREN expression expression_loop R_PAREN {printf("term -> IDENT %s L_PAREN expression expression_loop R_PAREN\n", $1);}
		              ;
		
expression_loop:
				{printf("expression_loop -> epsilon\n");}
				| COMMA expression expression_loop {printf("expression_loop -> COMMA expression expression_loop\n");}
				;
                  
sub_term:
				var {printf("sub_term -> var\n");}
				| NUMBER {printf("sub_term -> NUMBER %d\n", $1);}
				| L_PAREN expression R_PAREN {printf("sub_term -> L_PAREN expression R_PAREN\n");}
				;
                  
var: 
				IDENT {printf("var -> IDENT %s\n", $1);}
				| IDENT L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var -> IDENT %s L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n", $1);}
				;
                  
%%
                  
int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}

