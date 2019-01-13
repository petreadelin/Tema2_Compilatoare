%{
	#include "y.tab.h"

%}

%%
"+"				{ yylloc.first_column++; return '+'; }
"-"				{ yylloc.first_column++; return '-'; }
"*"				{ yylloc.first_column++; return '*'; }
"DIV"				{ yylloc.first_column+=3; return TOK_DIV; }
"("				{ yylloc.first_column++; return '('; }
")"				{ yylloc.first_column++; return ')'; }
";"				{ yylloc.first_column++; return ';'; }
":"				{ yylloc.first_column++; return ':'; }
":="				{ yylloc.first_column+=2; return TOK_ASSIGN; }
","				{ yylloc.first_column++; return ','; }



0|[1-9][0-9]*	{ yylloc.first_column+=strlen(yytext);
return TOK_INT; }

"VAR"		{ yylloc.first_column+=3; return TOK_VAR; }
"PROGRAM"	{ yylloc.first_column+=6; return TOK_PROGRAM; }
"BEGIN"		{ yylloc.first_column+=5; return TOK_BEGIN; }
"END"		{ yylloc.first_column+=3; return TOK_END; }
"INTEGER"	{ yylloc.first_column+=7; return TOK_INTEGER; }
"READ"		{ yylloc.first_column+=4; return TOK_READ; }
"WRITE"		{ yylloc.first_column+=5; return TOK_WRITE; }
"FOR"		{ yylloc.first_column+=3; return TOK_FOR; }
"DO"		{ yylloc.first_column+=2; return TOK_DO; }
"TO"		{ yylloc.first_column+=2; return TOK_TO; }
\t
[ ]
[a-zA-Z_][a-zA-Z0-9_]* {  yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext); return TOK_ID;}
\r\n			{ yylloc.first_line++; }
\n				{ yylloc.first_line++; }
.				{ throw yytext; }

%%
