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
		struct table *next;
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
%type <type> Expression LogicalORExpr LogicalANDExpr ComparisonExpr AdditionExpr MultiplicationExpr UnaryExpr PrimaryExpr Operand Literal IndexExpr

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : StatementList
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
				insert_symbol($<id>2, "array", $<type>3);
				isArray = 0;
			} else {
				insert_symbol($<id>2, $<type>3, "-");
			}
		}
	| VAR IDENT Type
		{ 
			if (isArray) {
				insert_symbol($<id>2, "array", $<type>3);
				isArray = 0;
			} else {
				insert_symbol($<id>2, $<type>3, "-");
			}
		}
;

ExpressionStmt: Expression;
Expression
	: LogicalORExpr { $$ = $1; }
;
LogicalORExpr
	: LogicalANDExpr LogicalOROp LogicalANDExpr
		{ printf("%s\n", $<operator>2); $$ = "bool"; }
	| LogicalANDExpr
		{ $$ = $1; }
;
LogicalANDExpr
	: ComparisonExpr LogicalANDOp ComparisonExpr
		{ printf("%s\n", $<operator>2); $$ = "bool"; }
	| ComparisonExpr
		{ $$ = $1; }
;
ComparisonExpr
	: AdditionExpr ComparisonOp AdditionExpr
		{ printf("%s\n", $<operator>2); $$ = "bool"; }
	| AdditionExpr
		{ $$ = $1; }
;
AdditionExpr
	: MultiplicationExpr AdditionOp MultiplicationExpr
		{ $$ = $1; printf("%s\n", $<operator>2); }
	| AdditionExpr AdditionOp MultiplicationExpr
		{ $$ = $1; printf("%s\n", $<operator>2); }
	| MultiplicationExpr
		{ $$ = $1; }
;
MultiplicationExpr
	: UnaryExpr MultiplicationOp UnaryExpr
		{ $$ = $1; printf("%s\n", $<operator>2); }
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
					if (strcmp($3, "int32") == 0) {
						printf("I");
					} else {
						printf("F");
					}
					printf(" to ");
					if (strcmp($1, "int32") == 0) {
						printf("I");
					} else {
						printf("F");
					}
					printf("\n");
				};

AssignmentStmt: Expression AssignOp Expression
				{ printf("%s\n", $<operator>2); };
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
	: FOR Condition Block
	| FOR  ForClause Block
;
Condition: Expression;
ForClause: InitStmt ';' Condition ';' PostStmt;
InitStmt: SimpleStmt;
PostStmt: PostStmt;

PrintStmt
	: PRINT '(' Expression ')'		{ printf("PRINT %s\n", $<type>3); }
	| PRINTLN '(' Expression ')'	{ printf("PRINTLN %s\n", $<type>3); }
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
		{ $$ = "int32"; printf("INT_LIT %d\n", $<i_val>1); }
	| FLOAT_LIT
		{ $$ = "float32"; printf("FLOAT_LIT %.6f\n", $<f_val>1); }
	| TRUE
		{ $$ = "bool"; printf("TRUE\n"); }
	| FALSE
		{ $$ = "bool"; printf("FALSE\n"); }
	| '"' STRING_LIT '"'
		{ $$ = "string"; printf("STRING_LIT %s\n", $<s_val>2); }
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
	global->next = NULL;
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
	head->next = newTable;
	newTable->scope = ++scope;
	newTable->length = 0;
	newTable->head = NULL;
	newTable->prev = head;
	newTable->next = NULL;
	head = newTable;
}

static void insert_symbol(char *id, char *type, char *elementType) {
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
	struct data *findData = head->head;
	while (findData) {
		if (strcmp(findData->name, id) == 0) {
			printf("IDENT (name=%s, address=%d)\n",
					findData->name, findData->address);
			break;
		}
		findData = findData->next;
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
