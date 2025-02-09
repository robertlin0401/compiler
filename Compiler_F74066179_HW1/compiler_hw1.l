/* Definition section */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define YY_NO_UNPUT
    #define YY_NO_INPUT

    int line_num = 0;
    int comment_num = 0;
	int aftercomment = 0;

%}

%x inccomment

/* Define regular expression label */
letter [a-zA-Z_]
digit [0-9]
id {letter}+({letter}|{digit})*
inumber {digit}+
fnumber ({digit}*\.{digit}+)
string \"({letter}|\s|\t|\n)*\"
ccommentstart \/\*
ccommentmiddle (\*[^\n\/]|[^*\n])*\n
ccommentend (\*[^\n\/]|[^*\n])*\*\/
cppcomment \/\/([^\n])*\n

/* Rules section */
%%

"("		    { printf("%-8s \t %s\n", yytext, "LPAREN"); }
")"		    { printf("%-8s \t %s\n", yytext, "RPAREN"); }
"{"	    	{ printf("%-8s \t %s\n", yytext, "LBRACE"); }
"}"		    { printf("%-8s \t %s\n", yytext, "RBRACE"); }
"["		    { printf("%-8s \t %s\n", yytext, "LBRACK"); }
"]"	    	{ printf("%-8s \t %s\n", yytext, "RBRACK"); }

";"		    { printf("%-8s \t %s\n", yytext, "SEMICOLON"); }
","		    { printf("%-8s \t %s\n", yytext, "COMMA"); }
"\""	    { printf("%-8s \t %s\n", yytext, "QUOTA"); }
"\n"	    { printf("%-8s \t %s\n", "", "NEWLINE"); line_num++;
			  if (aftercomment) { comment_num++; aftercomment = 0; } }

"+"         { printf("%-8s \t %s\n", yytext, "ADD"); }
"-"         { printf("%-8s \t %s\n", yytext, "SUB"); }
"*"         { printf("%-8s \t %s\n", yytext, "MUL"); }
"/"	    	{ printf("%-8s \t %s\n", yytext, "QUO"); }
"%"	   		{ printf("%-8s \t %s\n", yytext, "REM"); }
"++"	    { printf("%-8s \t %s\n", yytext, "INC"); }
"--"	    { printf("%-8s \t %s\n", yytext, "DEC"); }

"<"	    	{ printf("%-8s \t %s\n", yytext, "LSS"); }
">"	   		{ printf("%-8s \t %s\n", yytext, "GTR"); }
"<="	    { printf("%-8s \t %s\n", yytext, "LEQ"); }
">="	    { printf("%-8s \t %s\n", yytext, "GEQ"); }
"=="	    { printf("%-8s \t %s\n", yytext, "EQL"); }
"!="	    { printf("%-8s \t %s\n", yytext, "NEQ"); }

"="		    { printf("%-8s \t %s\n", yytext, "ASSIGN"); }
"+="	    { printf("%-8s \t %s\n", yytext, "ADD_ASSIGN"); }
"-="	    { printf("%-8s \t %s\n", yytext, "SUB_ASSIGN"); }
"*="	    { printf("%-8s \t %s\n", yytext, "MUL_ASSIGN"); }
"/="	    { printf("%-8s \t %s\n", yytext, "QUO_ASSIGN"); }
"%="	    { printf("%-8s \t %s\n", yytext, "REM_ASSIGN"); }

"&&"	    { printf("%-8s \t %s\n", yytext, "LAND"); }
"||"	    { printf("%-8s \t %s\n", yytext, "LOR"); }
"!"		    { printf("%-8s \t %s\n", yytext, "NOT"); }

"int32"     { printf("%-8s \t %s\n", yytext, "INT"); }
"float32"   { printf("%-8s \t %s\n", yytext, "FLOAT"); }
"string"    { printf("%-8s \t %s\n", yytext, "STRING"); }
"bool"      { printf("%-8s \t %s\n", yytext, "BOOL"); }

"if"	    { printf("%-8s \t %s\n", yytext, "IF"); }
"else"	    { printf("%-8s \t %s\n", yytext, "ELSE"); }
"for"	    { printf("%-8s \t %s\n", yytext, "FOR"); }

"var"       { printf("%-8s \t %s\n", yytext, "VAR"); }

"print"	    { printf("%-8s \t %s\n", yytext, "PRINT"); }
"println"   { printf("%-8s \t %s\n", yytext, "PRINTLN"); }

"true"	    { printf("%-8s \t %s\n", yytext, "TRUE"); }
"false"     { printf("%-8s \t %s\n", yytext, "FALSE"); }

{id}        { printf("%-8s \t %s\n", yytext, "IDENT"); }
{inumber}   { printf("%-8s \t %s\n", yytext, "INT_LIT"); }
{fnumber}   { printf("%-8s \t %s\n", yytext, "FLOAT_LIT"); }
{string}    { char *str = (char *)malloc(strlen(yytext) * sizeof(char));
			  strncpy(str, yytext, strlen(yytext)-1);
			  str += 1;
			  printf("%-8s \t %s\n", "\"", "QUOTA");
			  printf("%-8s \t %s\n", str, "STRING"); // will be modified in hw2
			  printf("%-8s \t %s\n", "\"", "QUOTA"); }

{ccommentstart}					{ BEGIN(inccomment); printf("%s", yytext);}
<inccomment>{ccommentmiddle}	{ char *str = (char *)malloc(strlen(yytext) * sizeof(char));
								  strncpy(str, yytext, strlen(yytext)-1);
								  printf("%s", str);
								  printf("%-8s \t %s\n", "\n", "C Comment");
								  comment_num++; line_num++; }
<inccomment>{ccommentend}		{ char *str = (char *)malloc(strlen(yytext) * sizeof(char));
								  strncpy(str, yytext, strlen(yytext)-2);
								  printf("%s", str);
								  printf("%-8s \t %s\n", "*/", "C Comment");
								  aftercomment = 1;
								  BEGIN 0; }

{cppcomment}	{ char *str = (char *)malloc(strlen(yytext) * sizeof(char));
			  	  str = strtok(yytext, "\n");
			  	  printf("%-8s \t %s\n", str, "C++ Comment");
			  	  printf("%-8s \t %s\n", "", "NEWLINE");
			  	  comment_num++;
				  line_num++; }

<<EOF>>     { if (aftercomment) comment_num++; line_num++; yyterminate(); }
.           {;}

%%

/*  C Code section */
int yywrap(void)
{
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    yylex();
    printf("\nFinish scanning,\n");
    printf("total line: %d\n", line_num);
    printf("comment line: %d\n", comment_num);
    fclose(yyin);
    return 0;
}
