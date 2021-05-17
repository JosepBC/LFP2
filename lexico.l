%option noyywrap
%{
  #include "./sintactico.tab.h"
  #include <stdlib.h>
  #include <stdio.h>
  #include <string.h>
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

apertura_m_simple       <{m}>
cierre_m                <\/{m}>
atributo                {nombre_tag}+{espacio}*={espacio}*(\"{texto}*\"|'{texto}*')
apertura_m_atr          <{m}({espacio}+{atributo})+{espacio}*>
apertura_m              {apertura_m_simple}|{apertura_m_atr}

enter                   \n
%%

{apertura_m_simple} {return APERTURA_M_SIMPLE;}
{apertura_m_atr} {yylval.str = strdup(yytext); return APERTURA_M_ATR;}
{cierre_m} {return CIERRE_M;}

{apertura_f} {return APERTURA_F;}
{apertura_v} {return APERTURA_V;}
{texto} {yylval.str = strdup(yytext); return TEXTO;}
{cierre_v} {return CIERRE_V;}
{cierre_f} {return CIERRE_F;}

{apertura_c} {return APERTURA_C;}
{cierre_c} {return CIERRE_C;}
{enter} {}

%%