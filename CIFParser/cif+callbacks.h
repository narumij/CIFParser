
#include "cif.h"
#include "CIFParser.h"

#ifndef CIFRawParserInternal_h
#define CIFRawParserInternal_h

extern const CIFLoopHeader CIFLoopHeaderZero;
extern const CIFTag CIFTagZero;
CIFTag CIFTagFromLex(CIFToken *lex);



void CIFLoopHeaderInit( CIFLoopHeader *stack );
void CIFLoopHeaderAdd( CIFLoopHeader *stack, CIFToken lex );
size_t CIFLoopHeaderCount( CIFLoopHeader *stack );
void CIFLoopHeaderClear( CIFLoopHeader *stack );
void CIFLoopHeaderTearDown( CIFLoopHeader *stack );

typedef struct yyextra_t {
    int lineno;
    int headCount;
    CIFDataConsumerCallbacks *handlers;
    CIFLoopHeader loopHeader;
} yyextra_t;

static inline void yyextra_init(yyextra_t *extra, CIFDataConsumerCallbacks *callbacks)
{
    CIFLoopHeaderInit(&extra->loopHeader);
    extra->handlers = callbacks;
}

static inline void yyextra_destroy(yyextra_t *extra)
{
    CIFLoopHeaderTearDown(&extra->loopHeader);
}

static inline void BeginData( yyextra_t *extra, CIFToken value ) {
  if (extra->handlers != NULL)
    extra->handlers->beginData( extra->handlers->ctx, value );
}
static inline void Item( yyextra_t *extra, CIFToken tag, CIFToken value ) {
  if (extra->handlers != NULL)
    extra->handlers->item( extra->handlers->ctx, CIFTagFromLex(&tag), value );
}
static inline void BeginLoop( yyextra_t *extra ) {
  if (extra->handlers != NULL)
    extra->handlers->beginLoop( extra->handlers->ctx, extra->loopHeader );
}
static inline void LoopItem( yyextra_t *extra, int index, CIFToken value ) {
  if (extra->handlers != NULL)
    extra->handlers->loopItem( extra->handlers->ctx, extra->loopHeader, index, value );
}
static inline void LoopItemTerm( yyextra_t *extra ) {
  if (extra->handlers != NULL)
    extra->handlers->loopItemTerm( extra->handlers->ctx );
}
static inline void EndLoop( yyextra_t *extra ) {
  if (extra->handlers != NULL)
    extra->handlers->endLoop( extra->handlers->ctx );
    CIFLoopHeaderClear(&extra->loopHeader);
}
static inline void EndData( yyextra_t *extra ) {
  if (extra->handlers != NULL)
    extra->handlers->endData( extra->handlers->ctx );
}

extern CIFDataConsumerCallbacks CIFTestHandlers;

#endif

