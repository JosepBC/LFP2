%option noyywrap

%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
  int n_cols = 0;
  int n_filas = 0;
%}

f                       fila
c                       columna
v                       valor
m                       matriz

nombre_tag              separador|N
apertura_f              <fila>
apertura_c              <columna>
apertura_v              <valor>
cierre_f                <\/fila>
cierre_c                <\/columna>
cierre_v                <\/valor>

texto                   [^<>'"&\n]+
valor                   {apertura_v}{texto}{cierre_v}
valores                 {valor}*
espacio                 [" "]

m_apertura_simple       <{m}>
m_cierre                <\/{m}>
atributo                {nombre_tag}+{espacio}*={espacio}*(\"{texto}*\"|'{texto}*')
m_apertura_atr          <{m}({espacio}+{atributo})+{espacio}*>
m_apertura              {m_apertura_simple}|{m_apertura_atr}

%%
{m_apertura} {
    printf("Apertura matriz: %s\n", yytext);
}

{apertura_c}{texto}{cierre_c} {
    n_cols++;
    printf("Columna: %s\n", yytext);
}

{apertura_f}{valores}{cierre_f} {
    n_filas++;
    printf("Fila: %s\n", yytext);
}

{m_cierre} {
    printf("Cierre m: %s\n", yytext);
}
%%

int main(int argc, char **argv) {
    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return EXIT_FAILURE;
        }
    }
    yylex();
}
