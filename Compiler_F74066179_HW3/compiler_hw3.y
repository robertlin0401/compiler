/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();
    extern FILE *yyin;

    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }

	FILE *open() {
		return fopen("hw3.j", "a");
	}

    /* Symbol table function - you can add new function if needed. */
	struct table {
		int scope;
		int length;
		struct data *head;
		struct table *prev;
	};
	struct data {
		int index;
		char *name;
		char *type;
		int address;
		int lineno;
		char *elementType;
		struct data *next;
	};
	struct table *head;
	int scope = 0;
	int address = 0;
	int label = 0;
	int endLabel = 0;
	char *thisId = NULL;
	char *storeId = NULL;
	char *thisType = NULL;
    static void create_symbol();
    static void insert_symbol(char *, char *, char *);
	int isArray = 0;
	int isAssign = 1;
    static char *lookup_symbol(char *);
	static void assign_symbol(char *);
	static char *findType(char *);
    static void dump_symbol();
	char *getTypeWithoutLit(char *);
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
	char *id;
    int i_val;
    float f_val;
    char *s_val;
	char *type;
	char *operator;
}

/* Token without return */
%token VAR
%token TRUE FALSE
%token INC DEC
%token GEQ LEQ EQL NEQ
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token LAND LOR
%token NEWLINE
%token PRINT PRINTLN IF ELSE FOR

/* Token with return, which need to sepcify type */
%token <id> IDENT
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <type> INT FLOAT BOOL STRING

/* Nonterminal with return, which need to sepcify type */
%type <type> Type TypeName ArrayType
%type <operator> UnaryOp LogicalOROp LogicalANDOp ComparisonOp AdditionOp MultiplicationOp AssignOp
%type <type> Expression LogicalORExpr LogicalANDExpr ComparisonExpr AdditionExpr MultiplicationExpr UnaryExpr PrimaryExpr Operand Literal IndexExpr ConversionExpr Condition

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : {
		remove("hw3.j");
		FILE *file = open();
		fprintf(file, ".source hw3.j\n");
		fprintf(file, ".class public Main\n");
		fprintf(file, ".super java/lang/Object\n");
		fprintf(file, ".method public static main([Ljava/lang/String;)V\n");
		fprintf(file, ".limit stack 100  ; Define your storage size.\n");
		fprintf(file, ".limit locals 100 ; Define your local space number.\n");
		fclose(file);
	  }
	  	StatementList
	  {
		FILE *file = open();
		fprintf(file, "\treturn\n");
		fprintf(file, ".end method\n");
		fclose(file);
	  }
;

StatementList
    : StatementList Statement
    | Statement
;

Statement
	: DeclarationStmt NEWLINE
	| SimpleStmt NEWLINE
	| Block NEWLINE
	| IfStmt NEWLINE
	| ForStmt NEWLINE
	| PrintStmt NEWLINE
	| NEWLINE
;

SimpleStmt: ExpressionStmt | AssignmentStmt | IncDecStmt;

DeclarationStmt
	: VAR IDENT Type '=' Expression
		{	
			FILE *file = open();
			if (isArray) {
				char *type;
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					type = "int";
				} else {
					type = "float";
				}
				fprintf(file, "\tnewarray %s\n", type);
				fprintf(file, "\tastore %d\n", address);
				insert_symbol($<id>2, "array", getTypeWithoutLit($<type>3));
				isArray = 0;
			} else {
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					fprintf(file, "\tistore %d\n", address);
				}
				if (strcmp(getTypeWithoutLit($<type>3), "float32") == 0) {
					fprintf(file, "\tfstore %d\n", address);
				}
				if (strcmp(getTypeWithoutLit($<type>3), "string") == 0) {
					fprintf(file, "\tastore %d\n", address);
				}
				insert_symbol($<id>2, getTypeWithoutLit($<type>3), "-");
			}
			fclose(file);
		}
	| VAR IDENT Type
		{ 
			FILE *file = open();
			if (isArray) {
				char *type;
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					type = "int";
				} else {
					type = "float";
				}
				fprintf(file, "\tnewarray %s\n", type);
				fprintf(file, "\tastore %d\n", address);
				insert_symbol($<id>2, "array", getTypeWithoutLit($<type>3));
				isArray = 0;
			} else {
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					fprintf(file, "\tldc 0\n");
					fprintf(file, "\tistore %d\n", address);
				}
				if (strcmp(getTypeWithoutLit($<type>3), "float32") == 0) {
					fprintf(file, "\tldc 0.0\n");
					fprintf(file, "\tfstore %d\n", address);
				}
				if (strcmp(getTypeWithoutLit($<type>3), "string") == 0) {
					fprintf(file, "\tldc \"\"\n");
					fprintf(file, "\tastore %d\n", address);
				}
				insert_symbol($<id>2, getTypeWithoutLit($<type>3), "-");
			}
			fclose(file);
		}
;

ExpressionStmt: Expression;
Expression
	: LogicalORExpr { $$ = $1; }
;
LogicalORExpr
	: LogicalANDExpr LogicalOROp LogicalANDExpr
		{
			if (strcmp(getTypeWithoutLit($1), "bool") == 0 &&
				strcmp(getTypeWithoutLit($3), "bool") == 0) {
				$$ = "boolLit";
			} else {
				char errorMsg[256] = "";
				char *operator = $<operator>2;
				char *type;
				if (strcmp(getTypeWithoutLit($1), "bool") != 0) {
					type = getTypeWithoutLit($<type>1);
				} else {
					type = getTypeWithoutLit($<type>3);
				}
				strcat(errorMsg, "invalid operation: (operator ");
				strcat(errorMsg, operator);
				strcat(errorMsg, " not defined on ");
				strcat(errorMsg, type);
				strcat(errorMsg, ")");
				yyerror(errorMsg);
			}
			FILE *file = open();
			fprintf(file, "\tior\n");
			fclose(file);
		}
	| LogicalANDExpr
		{ $$ = $1; }
;
LogicalANDExpr
	: ComparisonExpr LogicalANDOp ComparisonExpr
		{
			if (strcmp(getTypeWithoutLit($1), "bool") == 0 &&
				strcmp(getTypeWithoutLit($3), "bool") == 0) {
				$$ = "boolLit";
			} else {
				char errorMsg[256] = "";
				char *operator = $<operator>2;
				char *type;
				if (strcmp(getTypeWithoutLit($1), "bool") != 0) {
					type = getTypeWithoutLit($<type>1);
				} else {
					type = getTypeWithoutLit($<type>3);
				}
				strcat(errorMsg, "invalid operation: (operator ");
				strcat(errorMsg, operator);
				strcat(errorMsg, " not defined on ");
				strcat(errorMsg, type);
				strcat(errorMsg, ")");
				yyerror(errorMsg);
			}
			FILE *file = open();
			fprintf(file, "\tiand\n");
			fclose(file);
		}
	| ComparisonExpr
		{ $$ = $1; }
;
ComparisonExpr
	: AdditionExpr ComparisonOp AdditionExpr
		{
			FILE *file = open();
			char *type = findType(thisId);
			if (strcmp($<operator>2, "EQL") == 0) {
				if (strcmp(type, "int32") == 0) {
					fprintf(file, "\tisub\n");
				} else {
					fprintf(file, "\tfcmpl\n");
				}
				fprintf(file, "\tifeq label%d\n", label);
			}
			if (strcmp($<operator>2, "NEQ") == 0) {
				if (strcmp(type, "int32") == 0) {
					fprintf(file, "\tisub\n");
				} else {
					fprintf(file, "\tfcmpl\n");
				}
				fprintf(file, "\tifne label%d\n", label);
			}
			if (strcmp($<operator>2, "LSS") == 0) {
				if (strcmp(type, "int32") == 0) {
					fprintf(file, "\tisub\n");
				} else {
					fprintf(file, "\tfcmpl\n");
				}
				fprintf(file, "\tiflt label%d\n", label);
			}
			if (strcmp($<operator>2, "LEQ") == 0) {
				if (strcmp(type, "int32") == 0) {
					fprintf(file, "\tisub\n");
				} else {
					fprintf(file, "\tfcmpl\n");
				}
				fprintf(file, "\tifle label%d\n", label);
			}
			if (strcmp($<operator>2, "GTR") == 0) {
				if (strcmp(type, "int32") == 0) {
					fprintf(file, "\tisub\n");
				} else {
					fprintf(file, "\tfcmpl\n");
				}
				fprintf(file, "\tifgt label%d\n", label);
			}
			if (strcmp($<operator>2, "GEQ") == 0) {
				if (strcmp(type, "int32") == 0) {
					fprintf(file, "\tisub\n");
				} else {
					fprintf(file, "\tfcmpl\n");
				}
				fprintf(file, "\tifge label%d\n", label);
			}
			fprintf(file, "\ticonst_0\n");
			fprintf(file, "\tgoto label%d\n", label+1);
			fprintf(file, "label%d:\n", label++);
			fprintf(file, "\ticonst_1\n");
			fprintf(file, "label%d:\n", label++);
			fclose(file);
			$$ = "boolLit";
		}
	| AdditionExpr
		{ $$ = $1; }
;
AdditionExpr
	: MultiplicationExpr AdditionOp MultiplicationExpr
		{
			if (strcmp(getTypeWithoutLit($1), getTypeWithoutLit($3)) == 0) {
				$$ = $1;
			} else {
				char errorMsg[256] = "";
				char *operator = $<operator>2;
				char *type1 = getTypeWithoutLit($<type>1);
				char *type2 = getTypeWithoutLit($<type>3);
				strcat(errorMsg, "invalid operation: ");
				strcat(errorMsg, operator);
				strcat(errorMsg, " (mismatched types ");
				strcat(errorMsg, type1);
				strcat(errorMsg, " and ");
				strcat(errorMsg, type2);
				strcat(errorMsg, ")");
				yyerror(errorMsg);
			}
			FILE *file = open();
			if (strcmp($<operator>2, "ADD") == 0) {
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					fprintf(file, "\tiadd\n");
				} else {
					fprintf(file, "\tfadd\n");
				}
			} else {
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					fprintf(file, "\tisub\n");
				} else {
					fprintf(file, "\tfsub\n");
				}
			}
			fclose(file);
		}
	| AdditionExpr AdditionOp MultiplicationExpr
		{
			if (strcmp(getTypeWithoutLit($1), getTypeWithoutLit($3)) == 0) {
				$$ = $1;
			} else {
				char errorMsg[256] = "";
				char *operator = $<operator>2;
				char *type1 = getTypeWithoutLit($<type>1);
				char *type2 = getTypeWithoutLit($<type>3);
				strcat(errorMsg, "invalid operation: ");
				strcat(errorMsg, operator);
				strcat(errorMsg, " (mismatched types ");
				strcat(errorMsg, type1);
				strcat(errorMsg, " and ");
				strcat(errorMsg, type2);
				strcat(errorMsg, ")");
				yyerror(errorMsg);
			}
			FILE *file = open();
			if (strcmp($<operator>2, "ADD") == 0) {
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					fprintf(file, "\tiadd\n");
				} else {
					fprintf(file, "\tfadd\n");
				}
			} else {
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					fprintf(file, "\tisub\n");
				} else {
					fprintf(file, "\tfsub\n");
				}
			}
			fclose(file);
		}
	| MultiplicationExpr
		{ $$ = $1; }
;
MultiplicationExpr
	: UnaryExpr MultiplicationOp UnaryExpr
		{
			if ((strcmp(getTypeWithoutLit($1), "float32") == 0 ||
				 strcmp(getTypeWithoutLit($3), "float32") == 0)
				&& (strcmp($2, "REM") == 0)) {
				char errorMsg[256] = "";
				char *operator = $<operator>2;
				strcat(errorMsg, "invalid operation: (operator ");
				strcat(errorMsg, operator);
				strcat(errorMsg, " not defined on float32)");
				yyerror(errorMsg);
			} else {
				$$ = $1;
			}
			FILE *file = open();
			if (strcmp($<operator>2, "MUL") == 0) {
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					fprintf(file, "\timul\n");
				} else {
					fprintf(file, "\tfmul\n");
				}
			} else if (strcmp($<operator>2, "QUO") == 0) {
				if (strcmp(getTypeWithoutLit($<type>3), "int32") == 0) {
					fprintf(file, "\tidiv\n");
				} else {
					fprintf(file, "\tfdiv\n");
				}
			} else {
				fprintf(file, "\tirem\n");
			}
			fclose(file);
		}
	| UnaryExpr
		{ $$ = $1; }
;
UnaryExpr
	: UnaryOp UnaryExpr
		{
			FILE *file = open();
			if (strcmp($<operator>1, "POS") == 0) {
				fprintf(file, "\t \n");
			}
			if (strcmp($<operator>1, "NEG") == 0) {
				if (strcmp(findType(thisId), "int32") == 0) {
					fprintf(file, "\tineg\n");
				} else {
					fprintf(file, "\tfneg\n");
				}
			}
			if (strcmp($<operator>1, "NOT") == 0) {
				fprintf(file, "\ticonst_1\n");
				fprintf(file, "\tixor\n");
			}
			fclose(file);
			$$ = $2;
		}
	| PrimaryExpr
		{ $$ = $1; }
;
PrimaryExpr
	: Operand			{ $$ = $1; }
	| IndexExpr			{ $$ = $1; }
	| ConversionExpr
;
Operand
	: Literal				{ $$ = $1; }
	| IDENT					{ $$ = lookup_symbol($<id>1); }
	| '(' Expression ')'	{ $$ = $2; }
;
IndexExpr
	: PrimaryExpr '[' Expression ']'
		{
			FILE *file = open();
			if (!isAssign)
				fprintf(file, "\t%caload\n", findType(thisId)[0]);
			fclose(file);
			$$ = $1;
		}
;
ConversionExpr: Type '(' Expression ')'
				{
					FILE *file = open();
					if (strcmp(getTypeWithoutLit($3), "int32") == 0) {
						fprintf(file, "\ti2f\n");
					} else {
						fprintf(file, "\tf2i\n");
					}
					fclose(file);
				};

AssignmentStmt:	Expression
				{
					storeId = thisId;
					isAssign = 0;
				}
				AssignOp Expression
				{
					if ($1 && $4) {
						if (strcmp($1, "int32Lit") == 0 ||
							strcmp($1, "float32Lit") == 0 ||
							strcmp($1, "boolLit") == 0 ||
							strcmp($1, "stringLit") == 0) {
							char errorMsg[256] = "";
							char *type = getTypeWithoutLit($1);
							strcat(errorMsg, "cannot assign to ");
							strcat(errorMsg, type);
							yyerror(errorMsg);
						} else	if (strcmp(getTypeWithoutLit($1),
										   getTypeWithoutLit($4)) != 0) {
							char errorMsg[256] = "";
							char *operator = $<operator>3;
							char *type1 = getTypeWithoutLit($<type>1);
							char *type2 = getTypeWithoutLit($<type>4);
							strcat(errorMsg, "invalid operation: ");
							strcat(errorMsg, operator);
							strcat(errorMsg, " (mismatched types ");
							strcat(errorMsg, type1);
							strcat(errorMsg, " and ");
							strcat(errorMsg, type2);
							strcat(errorMsg, ")");
							yyerror(errorMsg);
						}
					}
					FILE *file = open();
					if (strcmp($<operator>3, "ADD_ASSIGN") == 0) {
						fprintf(file, "\t%cadd\n", $<type>4[0]);
					}
					if (strcmp($<operator>3, "SUB_ASSIGN") == 0) {
						fprintf(file, "\t%csub\n", $<type>4[0]);
					}
					if (strcmp($<operator>3, "MUL_ASSIGN") == 0) {
						fprintf(file, "\t%cmul\n", $<type>4[0]);
					}
					if (strcmp($<operator>3, "QUO_ASSIGN") == 0) {
						fprintf(file, "\t%cdiv\n", $<type>4[0]);
					}
					if (strcmp($<operator>3, "REM_ASSIGN") == 0) {
						fprintf(file, "\t%crem\n", $<type>4[0]);
					}
					fclose(file);
					assign_symbol(storeId);
					isAssign = 1;
				}
AssignOp
	: '='			{ $$ = "ASSIGN"; }
	| ADD_ASSIGN	{ $$ = "ADD_ASSIGN"; }
	| SUB_ASSIGN	{ $$ = "SUB_ASSIGN"; }
	| MUL_ASSIGN	{ $$ = "MUL_ASSIGN"; }
	| QUO_ASSIGN	{ $$ = "QUO_ASSIGN"; }
	| REM_ASSIGN	{ $$ = "REM_ASSIGN"; }
;

IncDecStmt
	: Expression INC
		{
			FILE *file = open();
			if (strcmp(getTypeWithoutLit($<type>1), "int32") == 0) {
				fprintf(file, "\tldc 1\n");
				fprintf(file, "\tiadd\n");
			} else {
				fprintf(file, "\tldc 1.0\n");
				fprintf(file, "\tfadd\n");
			}
			fclose(file);
			assign_symbol(thisId);
		}
	| Expression DEC
		{
			FILE *file = open();
			if (strcmp(getTypeWithoutLit($<type>1), "int32") == 0) {
				fprintf(file, "\tldc 1\n");
				fprintf(file, "\tisub\n");
			} else {
				fprintf(file, "\tldc 1.0\n");
				fprintf(file, "\tfsub\n");
			}
			fclose(file);
			assign_symbol(thisId);
		}
;

Block
	: 	'{'	{ create_symbol(); }
			StatementList
		'}'	{ dump_symbol(); }
;

IfStmt
	: IfCondition Block
		{
			FILE *file = open();
			fprintf(file, "label%d:\n", label++);
			fprintf(file, "end%d:\n", endLabel++);
			fclose(file);
		}
	| IfCondition BlockElse IfStmt
	| IfCondition BlockElse Block
		{
			FILE *file = open();
			fprintf(file, "end%d:\n", endLabel++);
			fclose(file);
		}
;
IfCondition
	: IF Condition
		{
			FILE *file = open();
			fprintf(file, "\tifeq label%d\n", label);
			fclose(file);
		}
;
BlockElse
	: Block ELSE
		{
			FILE *file = open();
			fprintf(file, "\tgoto end%d\n", endLabel);
			fprintf(file, "label%d:\n", label++);
			fclose(file);
		}
;

ForStmt
	: FOR Condition Block
	| FOR ForClause Block
;
Condition
	: Expression
		{
			if (strcmp(getTypeWithoutLit($1), "bool") != 0) {
				char errorMsg[256] = "";
				char *type = getTypeWithoutLit($<type>1);
				strcat(errorMsg, "non-bool (type ");
				strcat(errorMsg, type);
				strcat(errorMsg, ") used as for condition");
				printf("error:%d: %s\n", yylineno+1, errorMsg);
			}
		}
;
ForClause: InitStmt ';' Condition ';' PostStmt
;
InitStmt: SimpleStmt;
PostStmt: SimpleStmt;

PrintStmt
	: PRINT { isAssign = 0; } '(' Expression ')'
		{
			FILE *file = open();
			if (strcmp(getTypeWithoutLit($<type>4), "bool") == 0) {
				fprintf(file, "\tifne label%d\n", label);
				fprintf(file, "\tldc \"false\"\n");
				fprintf(file, "\tgoto label%d\n", label+1);
				fprintf(file, "label%d:\n", label++);
				fprintf(file, "\tldc \"true\"\n");
				fprintf(file, "label%d:\n", label++);
			}
			fprintf(file, "\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
			fprintf(file, "\tswap\n");
			fprintf(file, "\tinvokevirtual java/io/PrintStream/print");
			if (strcmp(getTypeWithoutLit($<type>4), "int32") == 0) {
				fprintf(file, "(I)V\n");
			} else if (strcmp(getTypeWithoutLit($<type>4), "float32") == 0) {
				fprintf(file, "(F)V\n");
			} else {
				fprintf(file, "(Ljava/lang/String;)V\n");
			}
			isAssign = 1;
			fclose(file);
		}
	| PRINTLN { isAssign = 0; } '(' Expression ')'
		{
			FILE *file = open();
			if (strcmp(getTypeWithoutLit($<type>4), "bool") == 0) {
				fprintf(file, "\tifne label%d\n", label);
				fprintf(file, "\tldc \"false\"\n");
				fprintf(file, "\tgoto label%d\n", label+1);
				fprintf(file, "label%d:\n", label++);
				fprintf(file, "\tldc \"true\"\n");
				fprintf(file, "label%d:\n", label++);
			}
			fprintf(file, "\tgetstatic java/lang/System/out Ljava/io/PrintStream;\n");
			fprintf(file, "\tswap\n");
			fprintf(file, "\tinvokevirtual java/io/PrintStream/println");
			if (strcmp(getTypeWithoutLit($<type>4), "int32") == 0) {
				fprintf(file, "(I)V\n");
			} else if (strcmp(getTypeWithoutLit($<type>4), "float32") == 0) {
				fprintf(file, "(F)V\n");
			} else {
				fprintf(file, "(Ljava/lang/String;)V\n");
			}
			isAssign = 1;
			fclose(file);
		}
;

UnaryOp
	: '+'	{ $$ = "POS"; }
	| '-'	{ $$ = "NEG"; }
	| '!'	{ $$ = "NOT"; }
;
LogicalOROp: LOR	{ $$ = "LOR"; };
LogicalANDOp: LAND	{ $$ = "LAND"; };
ComparisonOp
	: EQL	{ $$ = "EQL"; }
	| NEQ	{ $$ = "NEQ"; }
	| '<'	{ $$ = "LSS"; }
	| LEQ	{ $$ = "LEQ"; }
	| '>'	{ $$ = "GTR"; }
	| GEQ	{ $$ = "GEQ"; }
;
AdditionOp
	: '+'	{ $$ = "ADD"; }
	| '-'	{ $$ = "SUB"; }
;
MultiplicationOp
	: '*'	{ $$ = "MUL"; }
	| '/'	{ $$ = "QUO"; }
	| '%'	{ $$ = "REM"; }
;
Literal
	: INT_LIT
		{
			$$ = "int32Lit";
			FILE *file = open();
			fprintf(file, "\tldc %d\n", $<i_val>1);
			fclose(file);
			thisType = "int32";
		}
	| FLOAT_LIT
		{
			$$ = "float32Lit";
			FILE *file = open();
			fprintf(file, "\tldc %.6f\n", $<f_val>1);
			fclose(file);
			thisType = "float32";
		}
	| TRUE
		{
			$$ = "boolLit";
			FILE *file = open();
			fprintf(file, "\ticonst_1\n");
			fclose(file);
			thisType = "true";
		}
	| FALSE
		{
			$$ = "boolLit";
			FILE *file = open();
			fprintf(file, "\ticonst_0\n");
			fclose(file);
			thisType = "false";
		}
	| '"' STRING_LIT '"'
		{
			$$ = "stringLit";
			FILE *file = open();
			fprintf(file, "\tldc \"%s\"\n", $<s_val>2);
			fclose(file);
			thisType = "string";
		}
;

Type
	: TypeName	{ $$ = $1; }
	| ArrayType	{ $$ = $1; }
;
TypeName
	: INT		{ $$ = "int32"; }
	| FLOAT		{ $$ = "float32"; }
	| STRING	{ $$ = "string"; }
	| BOOL		{ $$ = "bool"; }
;
ArrayType
	: '[' INT_LIT ']' TypeName
		{
			$$ = $4;
			isArray = 1;
			FILE *file = open();
			fprintf(file, "\tldc %d\n", $<i_val>2);
			fclose(file);
		}
;

%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

	struct table *global = (struct table *)malloc(sizeof(struct table));
	global->scope = scope;
	global->length = 0;
	global->head = NULL;
	global->prev = NULL;
	head = global;

    yylineno = 0;
    yyparse();

	dump_symbol();

    fclose(yyin);
    return 0;
}

static void create_symbol() {
	struct table *newTable = (struct table *)malloc(sizeof(struct table));
	newTable->scope = ++scope;
	newTable->length = 0;
	newTable->head = NULL;
	newTable->prev = head;
	head = newTable;
}

static void insert_symbol(char *id, char *type, char *elementType) {
	struct data *checkData = head->head;
	while (checkData) {
		if (strcmp(checkData->name, id) == 0) {
			char lineno[256];
			sprintf(lineno, "%d", checkData->lineno);
			char errorMsg[256] = "";
			strcat(errorMsg, id);
			strcat(errorMsg, " redeclared in this block. ");
			strcat(errorMsg, "previous declaration at line ");
			strcat(errorMsg, lineno);
			yyerror(errorMsg);
			return;
		}
		checkData = checkData->next;
	}
	struct data *newData = (struct data *)malloc(sizeof(struct data));
	newData->index = head->length;
	newData->name = id;
	newData->type = type;
	newData->address = address;
	newData->lineno = yylineno;
	newData->elementType = elementType;
	newData->next = NULL;
	head->length++;
	address++;
	struct data *lastData = head->head;
	if (lastData == NULL) {
		head->head = newData;
	} else {
		while (lastData->next) lastData = lastData->next;
		lastData->next = newData;
	}
}

static char *lookup_symbol(char *id) {
	struct table *findTable = head;
	struct data *findData;
	while (findTable) {
		findData = findTable->head;
		while (findData) {
			if (strcmp(findData->name, id) == 0) {
				FILE *file = open();
				if (strcmp(findData->type, "int32") == 0) {
					fprintf(file, "\tiload %d\n", findData->address);
				} else if (strcmp(findData->type, "float32") == 0) {
					fprintf(file, "\tfload %d\n", findData->address);
				} else if (strcmp(findData->type, "string") == 0) {
					fprintf(file, "\taload %d\n", findData->address);
				}
				if (strcmp(findData->type, "array") == 0) {
					fprintf(file, "\taload %d\n", findData->address);
				}
				fclose(file);
				break;
			}
			findData = findData->next;
		}
		if (!findData) {
			findTable = findTable->prev;
		} else {
			break;
		}
	}
	if (!findData) {
		char errorMsg[256] = "";
		strcat(errorMsg, "undefined: ");
		strcat(errorMsg, id);
		printf("error:%d: %s\n", yylineno+1, errorMsg);
		return NULL;
	}
	thisId = id;
	if (strcmp(findData->type, "array") == 0) {
		return findData->elementType;
	} else {
		return findData->type;
	}
}

static void assign_symbol(char *id) {
	struct table *findTable = head;
	struct data *findData;
	while (findTable) {
		findData = findTable->head;
		while (findData) {
			if (strcmp(findData->name, id) == 0) {
				FILE *file = open();
				if (strcmp(findData->type, "int32") == 0) {
					fprintf(file, "\tistore %d\n", findData->address);
				} else if (strcmp(findData->type, "float32") == 0) {
					fprintf(file, "\tfstore %d\n", findData->address);
				} else if (strcmp(findData->type, "string") == 0) {
					fprintf(file, "\tastore %d\n", findData->address);
				} else if (strcmp(findData->type, "array") == 0) {
					fprintf(file, "\t%castore\n", findData->elementType[0]);
					storeId = NULL;
				}
				fclose(file);
				break;
			}
			findData = findData->next;
		}
		if (!findData) {
			findTable = findTable->prev;
		} else {
			break;
		}
	}
}

static char *findType(char *id) {
	if (!id) return thisType;
	struct table *findTable = head;
	struct data *findData;
	while (findTable) {
		findData = findTable->head;
		while (findData) {
			if (strcmp(findData->name, id) == 0) {
				break;
			}
			findData = findData->next;
		}
		if (!findData) {
			findTable = findTable->prev;
		} else {
			break;
		}
	}
	if (strcmp(findData->type, "array") == 0) {
		return findData->elementType;
	} else {
		return findData->type;
	}
}

static void dump_symbol() {
	struct table *dump = head;
	struct data *target = dump->head;
	while (target) {
		struct data *temp = target->next;
		free(target);
		target = temp;
	}
	struct table *temp = head->prev;
	free(head);
	head = temp;
	--scope;
}

char *getTypeWithoutLit(char *target) {
	if (strcmp(target, "int32Lit") == 0) return "int32";
	if (strcmp(target, "float32Lit") == 0) return "float32";
	if (strcmp(target, "boolLit") == 0) return "bool";
	if (strcmp(target, "stringLit") == 0) return "string";
	return target;
}
