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
    static void create_symbol();
    static void insert_symbol(char *, char *, char *);
	int isArray = 0;
    static char *lookup_symbol(char *);
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
		FILE *file = fopen("hw3.j", "a");
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
		FILE *file = fopen("hw3.j", "a");
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
			if (isArray) {
				insert_symbol($<id>2, "array", getTypeWithoutLit($<type>3));
				isArray = 0;
			} else {
				insert_symbol($<id>2, getTypeWithoutLit($<type>3), "-");
			}
		}
	| VAR IDENT Type
		{ 
			if (isArray) {
				insert_symbol($<id>2, "array", getTypeWithoutLit($<type>3));
				isArray = 0;
			} else {
				insert_symbol($<id>2, getTypeWithoutLit($<type>3), "-");
			}
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
			printf("%s\n", $<operator>2);
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
			printf("%s\n", $<operator>2);
		}
	| ComparisonExpr
		{ $$ = $1; }
;
ComparisonExpr
	: AdditionExpr ComparisonOp AdditionExpr
		{ printf("%s\n", $<operator>2); $$ = "boolLit"; }
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
			printf("%s\n", $<operator>2);
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
			printf("%s\n", $<operator>2);
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
			printf("%s\n", $<operator>2);
		}
	| UnaryExpr
		{ $$ = $1; }
;
UnaryExpr
	: UnaryOp UnaryExpr
		{ $$ = $2; printf("%s\n", $<operator>1); }
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
IndexExpr: PrimaryExpr '[' Expression ']' { $$ = $1; };
ConversionExpr: Type '(' Expression ')'
				{
					if (strcmp(getTypeWithoutLit($3), "int32") == 0) {
						printf("I");
					} else {
						printf("F");
					}
					printf(" to ");
					if (strcmp(getTypeWithoutLit($1), "int32") == 0) {
						printf("I");
					} else {
						printf("F");
					}
					printf("\n");
				};

AssignmentStmt: Expression AssignOp Expression
				{
					if ($1 && $3) {
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
										   getTypeWithoutLit($3)) != 0) {
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
					}
					printf("%s\n", $<operator>2);
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
	: Expression INC		{ printf("INC\n"); }
	| Expression DEC		{ printf("DEC\n"); }
;

Block
	: 	'{'	{ create_symbol(); }
			StatementList
		'}'	{ dump_symbol(); }
;

IfStmt
	: IF Condition Block
	| IF Condition Block ELSE IfStmt
	| IF Condition Block ELSE Block
;
ForStmt
	:FOR Condition Block
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
	: PRINT '(' Expression ')'
		{ printf("PRINT %s\n", getTypeWithoutLit($<type>3)); }
	| PRINTLN '(' Expression ')'
		{ printf("PRINTLN %s\n", getTypeWithoutLit($<type>3)); }
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
		{ $$ = "int32Lit"; printf("INT_LIT %d\n", $<i_val>1); }
	| FLOAT_LIT
		{ $$ = "float32Lit"; printf("FLOAT_LIT %.6f\n", $<f_val>1); }
	| TRUE
		{ $$ = "boolLit"; printf("TRUE\n"); }
	| FALSE
		{ $$ = "boolLit"; printf("FALSE\n"); }
	| '"' STRING_LIT '"'
		{ $$ = "stringLit"; printf("STRING_LIT %s\n", $<s_val>2); }
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
ArrayType: '[' INT_LIT ']' TypeName
			{ $$ = $4; isArray = 1; printf("INT_LIT %d\n", $<i_val>2); };

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

	printf("Total lines: %d\n", yylineno);
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
    printf("> Insert {%s} into symbol table (scope level: %d)\n", id, scope);
}

static char *lookup_symbol(char *id) {
	struct table *findTable = head;
	struct data *findData;
	while (findTable) {
		findData = findTable->head;
		while (findData) {
			if (strcmp(findData->name, id) == 0) {
				printf("IDENT (name=%s, address=%d)\n",
						findData->name, findData->address);
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
	if (strcmp(findData->type, "array") == 0) {
		return findData->elementType;
	} else {
		return findData->type;
	}
}

static void dump_symbol() {
	struct table *dump = head;
    printf("> Dump symbol table (scope level: %d)\n", scope);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");
	struct data *target = dump->head;
	while (target) {
    	printf("%-10d%-10s%-10s%-10d%-10d%s\n",
        	    target->index, target->name, target->type,
				target->address, target->lineno, target->elementType);
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
