%{
  #include <stdio.h>
  #include <stdlib.h>
  extern int yylex();
  int yyerror(char *s);
%}

%token a
%token b

%%

S: /* empty */
   | a S b
;

%%

int yyerror(char *s) {
  fprintf(stderr, "Not in L\n");
  exit(EXIT_FAILURE);
}

int main(int argc, char **argv) {
  yyparse();
  fprintf(stdout, "It is in L\n");
}
