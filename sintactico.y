%define parse.error verbose
%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int yylex();
  extern FILE* yyin;
  int yyerror(char *s);

  int filas = 1;
  int cols = 0;

  char delimiter = ',';
  int max_files = -1;

  int first_col = 1;

  void set_atr(char *s);

%}

%union {
    char *str;
    struct {
        char **str_array;
        int n_elem;
    } str_array;
};

%token<str> APERTURA_M_ATR
%token APERTURA_M_SIMPLE
%token CIERRE_M

%token APERTURA_F
%token APERTURA_V
%token<str> TEXTO
%token CIERRE_V
%token CIERRE_F

%token APERTURA_C
%token CIERRE_C

%type<str> val
%type<str_array> vals

%%
start : apertura_m columnas filas cierre_m | apertura_m cierre_m {yyerror("Matriz vacia");};

columnas : columna | columnas columna;

filas : fila | filas fila;

columna : APERTURA_C TEXTO CIERRE_C {
    if(first_col) {
        first_col = 0;
        printf("%s", $2);
    } else {
        printf("%c%s", delimiter, $2);
    }

    cols++;
};

val : APERTURA_V TEXTO CIERRE_V  {
    strcpy($$, $2);
};

vals : val {
    $$.str_array = malloc(sizeof(char*));
    $$.str_array[0] = $1;
    $$.n_elem = 1;
} | vals val {
    $$.str_array = realloc($1.str_array, sizeof(char*) * $1.n_elem);
    $$.str_array[$1.n_elem] = $2;
    $$.n_elem = $1.n_elem + 1;
};

fila : APERTURA_F vals CIERRE_F {
    printf("\n");
    for(int i = 0; i < $2.n_elem; i++) {
        if(i == 0) {
            printf("%s", $2.str_array[i]);
        } else {
            printf("%c%s", delimiter, $2.str_array[i]);
        }
    }

    for(int i = 0; i < cols - $2.n_elem - 1; i++) {
        printf("%c", delimiter);
    }

    filas++;
};

cierre_m : CIERRE_M;

apertura_m : apertura_m_simple | apertura_m_atr;

apertura_m_simple : APERTURA_M_SIMPLE;

apertura_m_atr : APERTURA_M_ATR {
    printf("Apertura atributo %s\n", $1);
    set_atr($1);
};

%%

//Pillar N y/o delimiter de s y guardarlos donde toca, delimiter, max_files
void set_atr(char *s) {

}

int yyerror(char *s) {
    fprintf(stderr, "Error: %s\n",  s);
    exit(EXIT_FAILURE);
}

int main(int argc, char **argv) {
    yyin = fopen(argv[1], "r");
    yyparse();

    if(max_files > -1) {
        if(filas > max_files) printf("El nombre de files es mes gran al esperat, %i > %i", filas, max_files);
        if(filas < max_files) printf("El nombre de files es mes petit al esperat, %i < %i", filas, max_files);
        if(filas == max_files) printf("El nombre de files es l'esperat");
    }

    printf("\n\nNum cols: %i", cols);
    printf("\nNum filas: %i\n", filas);
    return 1;
}
