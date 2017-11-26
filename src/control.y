// Declarations
%{
#include <iostream>
#include <string>
#include <map>

#include "treenode.hpp"

extern int yylex();
static std::map<std::string, int> vars;

inline void yyerror(const char *s)
{
	std::cout << s << std::endl;
}

static TreeNode *root;
%}
 
%union{int i; std::string *s; TreeNode *node;}
 
%token<node> WHILE LPAREN RPAREN LCURLY RCURLY IF ELSE
    REPEAT SEMICOL PAUSE OUTSTRING OUTINT LCLICK
    RCLICK LRELEASE RRELEASE UP DOWN LEFT RIGHT
    PRESSKEY RELEASEKEY EQASS OR AND EQCOMP NE LT
    LE GT GE ADD SUB MUL DIV MOD OPP ININT MOUSEPOSX 
    MOUSEPOSY INSTRING STRING_T INT_T
    
%token<node> INT
%token<node> STRING
%token<node> ID

%type<node> file statement definition assignment type
	    fuint fustring reint restring
	    
%type<i> expression conjunction equality relation
	 addition term factor primary
	 
%type<s> equop relop addop mulop unaryop
	    
%start file

%%


// Translation rules

file : statement
	{
		root = $1;
	}
     ;

statement : LCURLY statement RCURLY
	{
		Symbol statement(SymbolID::statement_, SymbolType::non_terminal_);
		$$ = new TreeNode(statement);
		
		Symbol lcurly(SymbolID::lcurly_, SymbolType::terminal_);
		Symbol rcurly(SymbolID::rcurly_, SymbolType::terminal_);
		
		$1 = new TreeNode(lcurly);
		$3 = new TreeNode(rcurly);
		
		$$->addNode(*$1);
		$$->addNode(*$2);
		$$->addNode(*$3);
	} 
	  | WHILE LPAREN expression RPAREN LCURLY statement RCURLY
	  | IF LPAREN expression RPAREN LCURLY statement RCURLY
	  | IF LPAREN expression RPAREN ELSE LCURLY statement RCURLY
	  | REPEAT LPAREN expression RPAREN LCURLY statement RCURLY
	  | definition SEMICOL
	  | expression SEMICOL
	{
		;
	}
	  | assignment SEMICOL
	  | PAUSE reint SEMICOL
	  | OUTSTRING restring SEMICOL
	  | OUTINT reint SEMICOL
	  | LCLICK SEMICOL
	{
		Symbol statement(SymbolID::statement_, SymbolType::non_terminal_);
		$$ = new TreeNode(statement);
	
		Symbol lclick(SymbolID::lclick_, SymbolType::terminal_);
		Symbol semicol(SymbolID::semicol_, SymbolType::terminal_);
		
		$1 = new TreeNode(lclick);
		$2 = new TreeNode(semicol);
		
		$$->addNode(*$1);
		$$->addNode(*$2);
	}
	  | RCLICK SEMICOL
	  | LRELEASE SEMICOL
	  | RRELEASE SEMICOL
	  | UP reint SEMICOL
	  | DOWN reint SEMICOL
	  | LEFT reint SEMICOL
	  | RIGHT reint SEMICOL
	  | PRESSKEY restring SEMICOL
	  | RELEASEKEY restring SEMICOL
	  ;
	  
definition : type ID
	{
		;
	}
	   | type assignment
	{
		;
	}
	   ;

assignment : ID EQASS reint
	{
		;
	}
	   | ID EQASS fuint
	{
		;
	}
	   | ID EQASS restring
	{
		;
	}
	   | ID EQASS fustring
	{
		;
	}
	   ;
	   
type : INT_T
	{
		;
	}
     | STRING_T
	{
		;
	}
     ;
     
expression : conjunction
	{
		;
	}
	   | expression OR conjunction
	{
		;
	}
	   ;
	   
conjunction : equality 
	{
		;
	}
	    | conjunction AND equality
	{
		;
	}
	    ;
	   
equality : relation
	{
		;
	}
	 | relation equop relation
	{
		;
	}
	 ;
	 
equop : EQCOMP
	{
		;
	}
      | NE
	{
		;
	}
      ;
      
relation : addition
	{
		;
	}
	 | addition relop addition
	{
		;
	}
	 ;
	 
relop : LT
	{
		;
	}
      | LE
	{
		;
	}
      | GT
	{
		;
	}
      | GE
	{
		;
	}
      ;
      
addition : term
	{
		;
	}
	 | addition addop term
	{
		;
	}
	 ;
	 
addop : ADD
	{
		;
	}
      | SUB
	{
		;
	}
      ;
  
term : factor
	{
		;
	}
     | term mulop factor
	{
		;
	}
     ;
      
mulop : MUL
	{
		;
	}
      | DIV
	{
		;
	}
      | MOD
	{
		;
	}
      ;
      
factor : unaryop primary
	{
		;
	}
       | primary
	{
		;
	}
       ;
       
unaryop : SUB
	{
		;
	}
        | OPP
	{
		;
	}
        ;
        
primary : ID
	{
		;
	}
        | INT
	{
		;
	}
        | LPAREN expression RPAREN
	{
		;
	}
        ;
        
fuint : INSTRING
	{
		;
	}
      | MOUSEPOSX
	{
		;
	}
      | MOUSEPOSY
	{
		;
	}
      ;
      
fustring : INSTRING
	{
		;
	}
         ;
         
reint : expression
	{
		;
	}
       | ID
	{
		;
	}
	//{
	//	$$ = vars[*$1];      delete $1;
	//}
       | INT
	{
		;
	}
       ;
       
restring : STRING 
	{
		;
	}
	 | ID
	{
		;
	}
	 ;

 /*
list: stmt
    | list stmt
    ;
 
stmt: expr ','
    | expr ':'          { std::cout << $1 << std::endl; }
    ;
 
expr: INT               { $$ = $1; }
    | VAR               { $$ = vars[*$1];      delete $1; }
    | VAR '=' expr      { $$ = vars[*$1] = $3; delete $1; }
    | expr '+' expr     { $$ = $1 + $3; }
    | expr '-' expr     { $$ = $1 - $3; }
    | expr '*' expr     { $$ = $1 * $3; }
    | expr '/' expr     { $$ = $1 / $3; }
    | expr '%' expr     { $$ = $1 % $3; }
    | '+' expr  %prec BATATA    { $$ =  $2; }
    | '-' expr  %prec BATATA    { $$ = -$2; }
    | '(' expr ')'              { $$ =  $2; }
    ;
 */
%%

// Supporting routines

extern int yylex();
extern int yyparse();

int main()
{
	yyparse();
	
	std::vector<Symbol> terminals_vector;
	terminals_vector = root->DFSPreOrder();
	
	std::cout << "Parsed tree terminals:" << std::endl;
	
  	for (std::vector<Symbol>::iterator it = terminals_vector.begin() ; it != terminals_vector.end(); it++)
    		std::cout << ' ' << (int) it->symbol_ID;
  	std::cout << '\n';
}
