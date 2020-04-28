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
    static void lookup_symbol(char *);
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
%type <operator> UnaryOperator BinaryOperator LogicalOp ComparativeOp ArithmeticOp

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
	: VAR IDENT Type '=' Expression	{ insert_symbol($<id>2, $<type>3, "-"); }
	| VAR IDENT Type				{ insert_symbol($<id>2, $<type>3, "-"); }
;

ExpressionStmt: Expression;
Expression: UnaryExpr | BinaryExpr;
	
BinaryExpr
	: Expression BinaryOperator Expression	{ printf("%s\n", $<operator>2); }
;
UnaryExpr
	: UnaryOperator UnaryExpr	{ printf("%s\n", $<operator>1); }
	| PrimaryExpr
;
PrimaryExpr
	: Operand
/*	| IndexExpr	*/
/*	| ConversionExpr	*/
;
Operand
	: Literal
	| IDENT					{ lookup_symbol($<id>1); }
	| '(' Expression ')' 
;
IndexExpr: PrimaryExpr '[' Expression ']';
ConversionExpr: Type '(' Expression ')';

AssignmentStmt: ;
/* Expression AssignOp Expression; */
AssignOp: '=' | '+=' | '-=' | '*=' | '/=' | '%=';

IncDecStmt
	: Expression INC		{ printf("INC\n"); }
	| Expression DEC		{ printf("DEC\n"); }
;

Block
	: '{' StatementList '}'	{ ; }
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
	: PRINT '(' Expression ')'
	| PRINTLN '(' Expression ')'
;

UnaryOperator
	: '+'	{ $$ = "POS"; }
	| '-'	{ $$ = "NEG"; }
	| '!'	{ $$ = "NOT"; }
;
BinaryOperator: LogicalOp | ComparativeOp | ArithmeticOp;
LogicalOp
	: '||'	{ $$ = "LOR"; }
	| '&&'	{ $$ = "LAND"; }
;
ComparativeOp
	: '=='	{ $$ = "EQL"; }
	| '!='	{ $$ = "NEQ"; }
	| '<'	{ $$ = "LSS"; }
	| '<='	{ $$ = "LEQ"; }
	| '>'	{ $$ = "GTR"; }
	| '>='	{ $$ = "GEQ"; }
;
ArithmeticOp
	: '+'	{ $$ = "ADD"; }
	| '-'	{ $$ = "SUB"; }
	| '*'	{ $$ = "MUL"; }
	| '/'	{ $$ = "QUO"; }
	| '%'	{ $$ = "REM"; }
;
Literal
	: INT_LIT		{ printf("INT_LIT %d\n", $<i_val>1); }
	| FLOAT_LIT		{ printf("FLOAT_LIT %.6f\n", $<f_val>1); }
	| TRUE			{ printf("TRUE\n"); }
	| FALSE			{ printf("FALSE\n"); }
	| STRING_LIT	{ printf("STRING_LIT %s\n", $<s_val>1); }
;

Type
	: TypeName	{ $$ = $1; }
	| ArrayType
;
TypeName
	: INT		{ $$ = "int32"; }
	| FLOAT		{ $$ = "float32"; }
	| STRING	{ $$ = "string"; }
	| BOOL		{ $$ = "bool"; }
;
ArrayType: "[" INT_LIT "]" TypeName

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

static void lookup_symbol(char *id) {
	struct data *findData = head->head;
	while (findData) {
		if (strcmp(findData->name, id) == 0) {
			printf("IDENT (name=%s, address=%d)\n", findData->name, findData->address);
			break;
		}
		findData = findData->next;
	}
}

static void dump_symbol() {
	struct table *dump = head;
	for (int i = 0; i < scope; ++i) {
		dump = dump->next;
	}
    printf("> Dump symbol table (scope level: %d)\n", 0);
    printf("%-10s%-10s%-10s%-10s%-10s%s\n",
           "Index", "Name", "Type", "Address", "Lineno", "Element type");
	struct data *head = dump->head;
	while (head) {
    	printf("%-10d%-10s%-10s%-10d%-10d%s\n",
        	    head->index, head->name, head->type, head->address, head->lineno, head->elementType);
		head = head->next;
	}
}
