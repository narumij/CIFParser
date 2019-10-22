%{
// Copyright (c) 2016 zenithgear inc. All rights reserved.

#include <stdio.h>
#include <assert.h>
#include "cif.h"
#include "cif+callbacks.h"

#if !LEXERMAIN && !MAIN
//#include "cif.h"
#include "cif.tab.h"
#endif

const char *TypeName(const char* tag);
CIFTokenType CIFTokenTypeFromTokenType(int tokenType);


#if MAIN
#define TOKEN(TAG) \
{\
    int col = yyget_column(yyscanner)+1;\
    yyset_column(col,yyscanner);\
    printf("LINE:%3d COL:%2d LEN:%2d %-15s |\t",yyget_lineno(yyscanner),col,yyget_leng(yyscanner),#TAG);\
    ECHO;\
    printf("\n");\
}
#elif LEXERMAIN
#if 0
#define TOKEN(TAG) { printf("{ type=\"%s\", contents=\"",#TAG); ECHO; printf("\"}\n"); }
#else
#define TOKEN(TAG) \
{\
    int col = yyget_column(yyscanner)+1;\
    yyset_column(col,yyscanner);\
    printf("%d.%d ", yyget_lineno(yyscanner),col);\
    printf("{%s}", TypeName(#TAG));\
    printf(" (%d)", yyget_leng(yyscanner));\
    printf("\t");\
    printf("\"");\
    ECHO;\
    printf("\"");\
    printf("\t{%s}", #TAG);\
    printf("\n");\
}
#endif
#else
#define TOKEN(TAG) { yyget_extra(yyscanner)->lineno = yylineno; yylval->lexeme.tokenType = CIFTokenTypeFromTokenType(TAG); yylval->lexeme.text = yytext; yylval->lexeme.len = yyleng; return TAG; }
#endif

%}

%option reentrant yylineno
%option extra-type="struct yyextra_t *"

sp                    [ ]
ht                    [\t]
eol                   (\r\n|\n)
noteol                [^\r\n]
back_slash            [\\]
double_quote          [\"]
single_quote          [\']

basic                 [a-zA-Z0-9]
special               [\!\%\&\(\)\*\+\,\-\.\/\;\:\<\=\>\?\@\^\`\{\|\}\~]
ordinaryChar          ({basic}|{special}|{back_slash})
nonBlankChar          ({ordinaryChar}|{double_quote}|[\#\$]|{single_quote}|[\_\;\[\]])
textLeadChar          ({ordinaryChar}|{double_quote}|[\#\$]|{single_quote}|[\_]|{sp}|{ht}|[\[\]])
anyPrintChar          ({ordinaryChar}|{double_quote}|[\#\$]|{single_quote}|[\_]|{sp}|{ht}|[\;\[\]])

comments              ("#"{ordinaryChar}*{eol})+
tokenizedComments     ({sp}|{ht}|{eol})+{comments}
whiteSpace            ({sp}|{ht}|{eol}|{tokenizedComments})+

tag_old               "_"{nonBlankChar}+
tag                   "_"[^ \t\n]+

digit                 [0-9]
unsignedInteger       {digit}+
exponent              ([eE]|[eE][\+\-]){unsignedInteger}
integer               [\+\-]?{unsignedInteger}
float                 {integer}{exponent}|[\+\-]?({digit}*"."{unsignedInteger}|{digit}+"."){exponent}?
numericFloat          ({float}|{float}"("{unsignedInteger}")")
numericInteger        ({integer}|{integer}"("{unsignedInteger}")")

unquoteString1         ({ordinaryChar}|;){nonBlankChar}*
unquoteString2        ^{ordinaryChar}{nonBlankChar}*
singleQuoteString     {single_quote}{anyPrintChar}*{single_quote}
doubleQuoteString     {double_quote}[^\"]*{double_quote}
semiColonTextFiled_old    ";"{anyPrintChar}*{eol}(({textLeadChar}{anyPrintChar}*)?{eol})*";"
semiColonTextFiled    ^";"([^\;]+|[^\r^\n]";")*";"


data     [Dd][Aa][Tt][Aa][\_]{nonBlankChar}+
savebegin [Ss][Aa][Vv][Ee][\_]{nonBlankChar}+
saveend   [Ss][Aa][Vv][Ee][\_]
loop     ^({sp}|{ht})*[Ll][Oo][Oo][Pp][\_]


%x cd_loop
%x cd_looptag
%x cd_loopvalue
%x cd_tag
%x cd_tageol

%%

<*>"#"[^\n]*$   ;
<*>"#"[^\n]*   ;

{data}               {TOKEN(LData);}
{savebegin}           TOKEN(LSaveBegin)
{saveend}             TOKEN(LSaveEnd)

{tag}                 {BEGIN(cd_tag);TOKEN(LTag);}
{loop}               {BEGIN(cd_loop);TOKEN(LLoop);}

<cd_loop>{tag}        {BEGIN(cd_looptag);TOKEN(LTag);}
<cd_looptag>{tag}     TOKEN(LTag)
<cd_loopvalue>{tag}   {BEGIN(cd_tag);TOKEN(LTag)}
<cd_loopvalue>{loop} {BEGIN(cd_loop);TOKEN(LLoop);}

<cd_looptag,cd_loopvalue>{numericFloat}       {BEGIN(cd_loopvalue);TOKEN(LNumericFloat);}
<cd_looptag,cd_loopvalue>{numericInteger}     {BEGIN(cd_loopvalue);TOKEN(LNumericInteger);}
<cd_looptag,cd_loopvalue>{singleQuoteString}  {BEGIN(cd_loopvalue);TOKEN(LQuoteString);}
<cd_looptag,cd_loopvalue>{doubleQuoteString}  {BEGIN(cd_loopvalue);TOKEN(LQuoteString);}
<cd_looptag,cd_loopvalue>{semiColonTextFiled} {BEGIN(cd_loopvalue);TOKEN(LTextField);}
<cd_looptag,cd_loopvalue>[\.]                 {BEGIN(cd_loopvalue);TOKEN(LDot);}
<cd_looptag,cd_loopvalue>[\?]                 {BEGIN(cd_loopvalue);TOKEN(LQue);}
<cd_looptag,cd_loopvalue>{unquoteString2}     {BEGIN(cd_loopvalue);TOKEN(LUnquoteString2);}
<cd_looptag,cd_loopvalue>{unquoteString1}      {BEGIN(cd_loopvalue);TOKEN(LUnquoteString1);}


<cd_tag>({sp}|{ht})                           ;
<cd_tag>{eol}                                 {BEGIN(cd_tageol);}
<cd_loop>({sp}|{ht}|{eol})                    ;
<cd_looptag>({sp}|{ht}|{eol})                 ;
<cd_loopvalue>({sp}|{ht}|{eol})               ;

<cd_tag,cd_tageol>{numericFloat}              {BEGIN(INITIAL);TOKEN(LNumericFloat);}
<cd_tag,cd_tageol>{numericInteger}            {BEGIN(INITIAL);TOKEN(LNumericInteger);}
<cd_tag,cd_tageol>{singleQuoteString}         {BEGIN(INITIAL);TOKEN(LQuoteString);}
<cd_tag,cd_tageol>{doubleQuoteString}         {BEGIN(INITIAL);TOKEN(LQuoteString);}
<cd_tag,cd_tageol>[\.]                        {BEGIN(INITIAL);TOKEN(LDot);}
<cd_tag,cd_tageol>[\?]                        {BEGIN(INITIAL);TOKEN(LQue);}
<cd_tag,cd_tageol>{unquoteString2}            {BEGIN(INITIAL);TOKEN(LUnquoteString2);}
<cd_tag,cd_tageol>{unquoteString1}            {BEGIN(INITIAL);TOKEN(LUnquoteString1);}
<cd_tageol>{semiColonTextFiled}               {BEGIN(INITIAL);TOKEN(LTextField);}


({eol}|{sp}|{ht})                             ;

<INITIAL><<EOF>> { yyterminate(); }
<<EOF>> { yyterminate(); }

<INITIAL>\0 { fprintf(stderr,"NULL found.\n");yyterminate(); }
\0 { fprintf(stderr,"NULL found.\n");yyterminate(); }

. {
//     printf("**** Tokenize Error at line %d,column %d (%s) %d ****\n",yyget_lineno(yyscanner),yyget_column(yyscanner),yytext,yy_flex_debug);
    char msg[1024];
    sprintf(msg,"Tokenize Error at Line %d.(%s)",yyget_lineno(yyscanner),yytext);
    if (yyget_extra(yyscanner)->handlers->error != NULL)
    {
        yyget_extra(yyscanner)->handlers->error(
        yyget_extra(yyscanner)->handlers->ctx,
        CIFDataInputTokenizeError,
        msg);
    }
    else
    {
        printf("%s\n",msg);
    }
//     TOKEN(LexerError);
     yyterminate();
}

%%

//. { printf("**** Tokenize Error at line %d,column %d (%s) %d ****\n",cifget_lineno(yyscanner),cifget_column(yyscanner),yytext,yy_flex_debug); assert( 0 && "Tokenize Error Occur" );TOKEN1(LEXER_ERROR); }

const char *TypeName(const char* tag)
{
    if (strcmp(tag,"LData") == 0)
        return "DATA";
    if (strcmp(tag,"LLoop") == 0)
        return "LOOP";
    if (strcmp(tag,"LTag") == 0)
        return "TAG";
            if (strcmp(tag,"LNumericInteger") == 0)
        return "INT";
            if (strcmp(tag,"LNumericFloat") == 0)
        return "FLT";
            if (strcmp(tag,"LUnquoteString1") == 0)
        return "STR";
            if (strcmp(tag,"LUnquoteString2") == 0)
        return "STR";
            if (strcmp(tag,"LQuoteString") == 0)
        return "STR";
            if (strcmp(tag,"LTextField") == 0)
        return "STR";
            if (strcmp(tag,"LDot") == 0)
        return ".";
            if (strcmp(tag,"LQue") == 0)
        return "?";
    return "N/A";
}

CIFTokenType CIFTokenTypeFromTokenType(int tokenType)
{
    switch(tokenType)
    {
    case LNumericFloat:
        return CIFTokenNumericFloat;
    case LNumericInteger:
        return CIFTokenNumericInteger;
    case LQuoteString:
    case LUnquoteString1:
    case LUnquoteString2:
        return CIFTokenString;
    case LTextField:
        return CIFTokenTextField;
    case LDot:
        return CIFTokenDot;
    case LQue:
        return CIFTokenQue;
    default:
        return CIFTokenUnknown;
    }
}


#if 1
#if LEXERMAIN
#if 0
int main ( int argc, char * argv[] )
{
    FILE *fp = NULL;
    yyscan_t scanner;

    if ( argc == 2 )
    {
        fp = fopen(argv[1],"r");
        yyset_in(fp,scanner);
    }

    yyset_debug(1,scanner);

    yylex ( scanner );
    yylex_destroy ( scanner );

    if ( fp != NULL )
    {
        fclose(fp);
    }
    
    return 0;
}
#else
int main( int argc, char** argv )
{
    FILE *fp = stdin;
    if (argc > 1)
        fp = fopen(argv[1],"r");
    if (fp == NULL)
        return 1;
  yyscan_t scanner; 
  yylex_init( &scanner );
#if YYDEBUG
     yyset_debug(1,scanner);
#endif
  yyset_in(fp,scanner);
  yylex(scanner);
  yylex_destroy(scanner);
  return 0;
}
#endif
#endif
#endif
