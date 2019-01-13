%{
	#include <stdio.h>
     #include <string.h>


# define DECL 0
# define READ 1
# define WRITE 2

	int yylex();
	void check(char*); //Functie analiza semantica
	int yyerror(const char *msg);

     int EsteCorecta = 1;

	char msg[500];
 
	int context_lista_id; //spune in care dintre #define-uri se reduce urmatorul id_list

	class TVAR
	{
	     char* nume;
	     bool defined; //VAR INITIALIZARE
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n);
	     TVAR();
	     int exists(char* n);
             void add(char* n);
             bool is_defined(char* n);
	     void define(char* n);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->defined = false;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n) //A FOST DECLARAT
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n) //DECLARARE
	 {
	   TVAR* elem = new TVAR(n);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         bool TVAR::is_defined(char* n) //A FOST INITIALIZAT
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->defined;
	     tmp = tmp->next;
	   }
	   return false;
	  }

	  void TVAR::define(char* n) //INITIALIZARE
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->defined = true;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL; //tabela de simboli
%}
%locations

%union { char* sir; }

%token TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_DIV TOK_INT TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO TOK_ASSIGN
%token <sir> TOK_ID

%start prog

%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%%


prog : TOK_PROGRAM prog_name TOK_VAR dec_list TOK_BEGIN stmt_list TOK_END
	|
	error {printf("Structura programului incorecta\n"); EsteCorecta=0;}
	;

prog_name : TOK_ID 
	;

dec_list : dec 
	|
	dec_list ';' dec
	|
	error ';' dec {printf("Declaratie invalida la linia %d\n", @1.first_line); EsteCorecta=0;}
	;

dec : id_list ':' type 
	;

id_list : TOK_ID 
	{
		check($1); 
	}
	|
	id_list ',' TOK_ID 
	{
		check($3);
	}
	;

type : TOK_INTEGER
	;

stmt_list : stmt
	|
	stmt_list ';' stmt 
	|
	error ';' stmt { printf("Instructiune invalida la linia %d\n", @2.first_line); EsteCorecta=0;}
	;

stmt : assign 
	| 
	read 
	| 
	write 
	| 
	for
	;

assign : TOK_ID TOK_ASSIGN exp {context_lista_id = READ; check($1);} //CHECK_ERR SEMANTICA
	;

exp : term 
	|
	exp '+' term
	|
	exp '-' term
	;

term : factor
	|
	term '*' factor
	|
	term TOK_DIV factor
	;

factor : TOK_ID {context_lista_id = WRITE; check($1);} //CHECK_ERR SEMANTICA
	|
	TOK_INT
	|
	'(' exp ')'
	;

read : TOK_READ '(' {context_lista_id = READ;} id_list ')' //CHECK_ERR SEMANTICA
	;

write : TOK_WRITE '(' {context_lista_id = WRITE;}  id_list ')' //CHECK_ERR SEMANTICA
	;

for : TOK_FOR index_exp TOK_DO body
	;

index_exp : TOK_ID TOK_ASSIGN exp TOK_TO exp {context_lista_id = READ; check($1);} //CHECK_ERR SEMANTICA
	;

body : stmt 
	|
	TOK_BEGIN stmt_list TOK_END
	;

///////////////////////////////////////////

%%

void check(char* x)
{
	switch(context_lista_id) 
	{
	case DECL:
		if (ts->exists(x))
		{
			sprintf(msg, "Eroare semantica la linia %d: Variabila '%s' a fost declarata anterior!", yylloc.first_line, x);
			yyerror(msg);
			EsteCorecta=0;
		}
		else
		{
			ts->add(x);
		}
		break;	
	case READ:
		if (not ts->exists(x))
		{
			sprintf(msg, "Eroare semantica la linia %d: Variabila '%s' nu a fost declarata anterior", yylloc.first_line, x);
			yyerror(msg);
			EsteCorecta=0;
		}
		else
		{
			ts->define(x);
		}
		break;	
	case WRITE:
		if (not ts->exists(x))
		{
			sprintf(msg, "Eroare semantica la linia %d: Variabila '%s' nu a fost declarata anterior", yylloc.first_line, x);
			yyerror(msg);
			EsteCorecta=0;
		}
		else if (not ts->is_defined(x))
		{
			sprintf(msg, "Eroare semantica la linia %d: Variabila '%s' nu a fost definita anterior", yylloc.first_line, x);
			yyerror(msg);
			EsteCorecta=0;
		}
		break;	
	}	
}


int yyerror(const char *msg)
{
	printf("%s\n", msg);
	EsteCorecta = 0;
	return 1;
}


int main()
{
	try{
		yyparse();
	}
	catch(char* e)
	{
		printf("Eroare lexicala la linia %d '%s' neasteptat\n", yylloc.first_line, e);
		EsteCorecta = 0;
	}
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}	

       return 0;
}
