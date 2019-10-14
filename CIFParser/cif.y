/*
  Copyright 2018-2019 Jun Narumi, All rights reserved.
*/
%{
#define YYDEBUG 0
#define YYERROR_VERBOSE 1

#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "cif.h"
#include "cif+callbacks.h"

typedef union YYSTYPE YYSTYPE;

#include "lex.yy.h"
static void yyerror (yyscan_t scanner, char const *msg );
static int isLoopTerm(yyscan_t scanner, CIFLoop loop);

%}

%define api.pure full
%lex-param { yyscan_t scanner }
%parse-param { yyscan_t scanner }

%union {
  CIFToken lexeme;
  CIFLoop loop;
}

%defines
%token    LexerError
%token    LData
%token    LLoop
%token    LSaveBegin
%token    LSaveEnd
%token    LTag
%token    LNumericFloat
%token    LNumericInteger
%token    LQuoteString
%token    LUnquoteString1
%token    LUnquoteString2
%token    LTextField
%token    LDot
%token    LQue

%type<lexeme>    LData
%type<lexeme>    LLoop
%type<lexeme>    LTag
%type<lexeme>    LNumericFloat
%type<lexeme>    LNumericInteger
%type<lexeme>    LQuoteString
%type<lexeme>    LUnquoteString1
%type<lexeme>    LUnquoteString2
%type<lexeme>    LTextField
%type<lexeme>    LDot
%type<lexeme>    LQue

//%type<dummy> CIF
//%type<dummy> DATABLOCK
%type<lexeme> DATABLOCKHEAD
//%type<dummy> DATA
%type<loop> LOOP
%type<loop> LOOPSTART
%type<loop> LOOPHEAD
%type<loop> LOOPBODY
//%type<dummy> ITEM
%type<lexeme> TAG
%type<lexeme> VALUE

%%

CIF: DATABLOCK { /* ResetLoopTag(yyget_extra(scanner)); */ }
   ;

DATABLOCK : DATABLOCKHEAD
            { BeginData(yyget_extra(scanner), $1); }
            DATABODY
            { EndData(yyget_extra(scanner)); }

DATABLOCKHEAD : LData { $$ = $1; };

DATABODY : DATABODY DATA
         | DATA

DATA : LOOP
       { EndLoop(yyget_extra(scanner)); } 
     | ITEM

LOOP : LOOPSTART
       LOOPHEAD
       { BeginLoop(yyget_extra(scanner)); }
       LOOPBODY

LOOPSTART : LLoop { }

LOOPHEAD : LOOPHEAD TAG
         {
            CIFLoopHeaderAdd(&yyget_extra(scanner)->loopHeader, $2);
         }
         | TAG
         {
            CIFLoopHeaderClear(&yyget_extra(scanner)->loopHeader);
            CIFLoopHeaderAdd(&yyget_extra(scanner)->loopHeader, $1);
         };     

LOOPBODY : LOOPBODY VALUE
         {
            $$.bodyIndex += 1;
            LoopItem(yyget_extra(scanner), $$.bodyIndex, $2);
            if (isLoopTerm(scanner, $$))
              LoopItemTerm(yyget_extra(scanner));
         }
         | VALUE
         {
            $$.bodyIndex = 0;
            LoopItem(yyget_extra(scanner), $$.bodyIndex, $1);
            if (isLoopTerm(scanner, $$))
              LoopItemTerm(yyget_extra(scanner));
         };

ITEM : TAG VALUE { Item(yyget_extra(scanner), $1, $2); };

TAG : LTag { $$ = $1; };

VALUE : LNumericFloat   { $$ = $1; }
      | LNumericInteger { $$ = $1; }
      | LQuoteString    { $$ = $1; }
      | LUnquoteString1 { $$ = $1; }
      | LUnquoteString2 { $$ = $1; }
      | LTextField      { $$ = $1; }
      | LDot            { $$ = $1; } 
      | LQue            { $$ = $1; }
      ;

%%

/* エラー表示関数 */
static void yyerror (yyscan_t scanner, char const *msg)
{
//  fprintf(stderr, "Parser Error: %s\n", msg);
  char newMsg[1024];
  sprintf(newMsg,"Parse Error at Line %i.",yyget_extra(scanner)->lineno);
  yyget_extra(scanner)->handlers->error( yyget_extra(scanner)->handlers->ctx, CIFDataInputParseError, newMsg );
}

static int headCount(yyscan_t scanner)
{
  return yyget_extra(scanner)->loopHeader.count;
}

static int isLoopTerm( yyscan_t scanner, CIFLoop loop )
{
  return loop.bodyIndex % headCount(scanner) + 1 == headCount(scanner);
}

int CIFRawParse( FILE * fp, CIFDataConsumerCallbacks *h )
{
  yyscan_t scanner;
  yyextra_t extra;
  yyextra_init(&extra,h);
//  extra.handlers = h;
  yylex_init_extra(&extra,&scanner);
  yyset_in(fp,scanner);
#ifndef YYDEBUG
  yydebug = 1;
  yyset_debug(1,scanner);
#endif
  int result = yyparse(scanner);
  yyextra_destroy(&extra);
  yylex_destroy(scanner);
    return result;
}

int CIFRawParse2( FILE * fp, CIFDataConsumerCallbacks h )
{
    return CIFRawParse(fp,&h);
}

#if PARSERMAIN

int main(int argc,char **argv)
{
#if 0
#if YYDEBUG
  yydebug = 1;
#endif
  yyscan_t scanner;
  yyextra_t extra;
  CIFDataConsumerCallbacks handlers = CIFTestHandlers;
  extra.handlers = &handlers;
  yylex_init_extra(&extra,&scanner);
  yyparse(scanner);
  yylex_destroy(scanner);
  return 0;
#else
  FILE *fp = stdin;
  if (argc > 1)
    fp = fopen(argv[1],"r");
  if (fp == NULL)
    return 1;
  CIFDataConsumerCallbacks handlers = CIFTestHandlers;
  return CIFRawParse(fp, &handlers);
#endif
}

#endif



