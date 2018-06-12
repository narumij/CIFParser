%{
// Copyright (c) 2016 zenithgear inc. All rights reserved.

#include <stdio.h>
#include <assert.h>
#include "Lexer.h"

#if !CIF_LEXER_LOG
#define TOKEN(TAG) { IssueLexeme(yyscanner,TAG,yytext,yyleng); }
#else
#define TOKEN(TAG) { printf("token(%s)\n",#TAG); ECHO; printf("\n"); }
#endif

%}

%option reentrant noyywrap yylineno

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


data_     [Dd][Aa][Tt][Aa][\_]{nonBlankChar}+
savebegin [Ss][Aa][Vv][Ee][\_]{nonBlankChar}+
saveend   [Ss][Aa][Vv][Ee][\_]
loop_     ^({sp}|{ht})*[Ll][Oo][Oo][Pp][\_]{whiteSpace}


%x cd_loop
%x cd_looptag
%x cd_loopvalue
%x cd_tag
%x cd_tageol

%%

<*>"#"[^\n]*$   ;
<*>"#"[^\n]*   ;

{data_}           {TOKEN(LData_);}
{savebegin}        TOKEN(LSaveBegin)
{saveend}        TOKEN(LSaveEnd)

{tag}             {BEGIN(cd_tag);TOKEN(LTag);}
{loop_}           {BEGIN(cd_loop);TOKEN(LLoop_);}

<cd_loop>{tag}       {BEGIN(cd_looptag);TOKEN(LTag);}
<cd_looptag>{tag}    TOKEN(LTag)
<cd_loopvalue>{tag}   {BEGIN(cd_tag);TOKEN(LTag)}
<cd_loopvalue>{loop_} {BEGIN(cd_loop);TOKEN(LLoop_);}

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
<cd_tag,cd_tageol>{unquoteString1}             {BEGIN(INITIAL);TOKEN(LUnquoteString1);}
<cd_tageol>{semiColonTextFiled}               {BEGIN(INITIAL);TOKEN(LTextField);}





({eol}|{sp}|{ht})                             ;

<<EOF>> {TOKEN(LEOF);yyterminate();}

. { printf("**** Tokenize Error at line %d,column %d (%s) %d ****\n",cifget_lineno(yyscanner),cifget_column(yyscanner),yytext,yy_flex_debug);TOKEN(LexerError);yyterminate(); }

%%

//. { printf("**** Tokenize Error at line %d,column %d (%s) %d ****\n",cifget_lineno(yyscanner),cifget_column(yyscanner),yytext,yy_flex_debug); assert( 0 && "Tokenize Error Occur" );TOKEN1(LEXER_ERROR); }

#if 0
#if 1
int main ( int argc, char * argv[] )
{
    FILE *fp = NULL;
    yyscan_t scanner;
    CIFParseExtra extra;
    ciflex_init_extra( &extra, &scanner );

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
int main ( int argc, char * argv[] )
{
yyscan_t scanner;
CIFParseExtra extra;
ciflex_init_extra( &extra, &scanner );yylex ( scanner );
yylex_destroy( scanner );
return 0;
}
#endif
#endif

