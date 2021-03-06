%define parse.error verbose
%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int yylex();
  extern FILE* yyin;
  int yyerror(const char *s);
  FILE* csv;

  int filas = 0;
  int cols = 0;

  char delimiter = ',';
  int max_files = -1;

  int first_col = 1;

  char *csv_file = "out.csv";

  void set_atr(char *s);
  void print_val(char *s);
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
start : apertura_m columnas filas cierre_m | 
    apertura_m cierre_m {yyerror("Matriz vacia");} |
    apertura_m columnas cierre_m {printf("[WARNING]: El fichero solo contiene columnas\n");};

columnas : columna | columnas columna;

filas : fila | filas fila;

columna : APERTURA_C TEXTO CIERRE_C {
    if(first_col) {
        first_col = 0;
        print_val($2);
    } else {
        fprintf(csv, "%c", delimiter);
        print_val($2);
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
    fprintf(csv, "\n");
    if($2.n_elem > cols) printf("[WARNING]: La fila %d tiene %d valores más que columnas tiene la matriz\n", filas, $2.n_elem - cols);
    for(int i = 0; i < $2.n_elem && i < cols; i++) {
        if(i == 0) {
            print_val($2.str_array[i]);
        } else {
            fprintf(csv, "%c", delimiter);
            print_val($2.str_array[i]);
        }
    }

    for(int i = 0; i < cols - $2.n_elem; i++) fprintf(csv, "%c", delimiter);

    filas++;
};

cierre_m : CIERRE_M;

apertura_m : apertura_m_simple | apertura_m_atr;

apertura_m_simple : APERTURA_M_SIMPLE;

apertura_m_atr : APERTURA_M_ATR {
    set_atr($1);
};

%%

char* get_val(char *s) {
    char *s_cpy = (char*)calloc(sizeof(s), sizeof(char));
    strcpy(s_cpy, s);

    char *token = strtok(s_cpy, "'\"");
    for(int i = 0; token != NULL && i < 1; i++) token = strtok(NULL, "'\"");

    char *token_cpy = (char*)calloc(sizeof(token), sizeof(char));
    strcpy(token_cpy, token);
    return token_cpy;
}

void set_atr(char *s) {
    for(int i = 0; s[i] != '\0'; i++) {
        if(s[i] == '=' && s[i - 1] == 'N') max_files = atoi(get_val(&s[i]));
        if(s[i] == '=' && s[i - 1]  == 'r') delimiter = get_val(&s[i])[0];
    }

    //printf("max_files: %d\n", max_files);
    //printf("delim: %c\n", delimiter);
}

void print_val(char *s) {
    for (int i = 0;  s[i] != '\0' ; i++) {
        if(s[i] != delimiter && s[i] != ' ') fprintf(csv, "%c", s[i]);
        else if(s[i] == delimiter) {
            fprintf(csv, "$");
            printf("[WARNING]: El elemento \"%s\" contiene el separador: '%c'\n", s, delimiter);
        }
    }
}

int yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n",  s);
    exit(EXIT_FAILURE);
}

int main(int argc, char **argv) {
    yyin = fopen(argv[1], "r");
    csv = fopen(csv_file, "w");
    yyparse();

    if(max_files > -1) {
        if(filas > max_files) printf("[WARNING]: El numero de filas es mas grande que el esperado, %i > %i\n", filas, max_files);
        if(filas < max_files) printf("[WARNING]: El numero de filas es mas pequeño que el esperado, %i < %i\n", filas, max_files);
    }
    fclose(csv);
    return 1;
}
