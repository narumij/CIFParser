#include <stdlib.h>
#include <string.h>
#include <assert.h>

//#include "cif.h"
#include "cif+callbacks.h"
//#include "CIFParserAPI.h"
#include "Debug.h"

#define USE_TAG_COPY 1

const CIFLoopHeader CIFLoopHeaderZero = { .list = NULL, .capacity = 0, .count = 0 };
const CIFTag CIFTagZero = { .text = NULL, .len = 0 };

CIFTag CIFTagFromLex(CIFToken *lex) {
  CIFTag tag;
  tag.text = lex->text;
  tag.len = lex->len;
  return tag;
}

void CIFTagClear(CIFTag *tag)
{
#if USE_TAG_COPY
    if (tag->text != NULL)
    {
        FREE((void*)tag->text,0);
    }
#endif
    tag->text = NULL;
    tag->len = 0;
}

void CIFTagCopy(CIFTag *tag, CIFToken *lex)
{
#if USE_TAG_COPY
    CIFTagClear(tag);
    char *buffer = MALLOC(lex->len+1,0);
    buffer[lex->len] = 0;
    sprintf(buffer,"%.*s",lex->len,lex->text);
    tag->text = buffer;
#else
    tag->text = lex->text;
#endif
    tag->len = lex->len;
}

void CIFLoopHeaderInit( CIFLoopHeader *loopHeader )
{
    *loopHeader = CIFLoopHeaderZero;
}

static void IncreaseCapacity( CIFLoopHeader *xs ) {
    int newCapacity = xs->capacity == 0 ? 8 : xs->capacity * 2;
    CIFTag *newList = MALLOC(newCapacity * sizeof(CIFTag),1);
    for (int i = 0; i < newCapacity; ++i ) {
        newList[i] = i < xs->count ? xs->list[i] : CIFTagZero;
    }
    xs->list = newList;
    xs->capacity = newCapacity;
}

void CIFLoopHeaderAdd( CIFLoopHeader *stack, CIFToken lex ) {
    if ( stack->capacity <= (stack->count + 1) )
        IncreaseCapacity(stack);
    CIFTagCopy(&stack->list[stack->count],&lex);
    stack->count += 1;
}

size_t CIFLoopHeaderCount( CIFLoopHeader *stack ) {
    return stack->count;
}

void CIFLoopHeaderClear( CIFLoopHeader *stack ) {
    stack->count = 0;
}

const char *CIFLoopHeaderGetText( CIFLoopHeader *stack, int idx ) {
    return stack->list[idx].text;
}

size_t CIFLoopHeaderGetLen( CIFLoopHeader *stack, int idx ) {
    return stack->list[idx].len;
}

void CIFLoopHeaderTearDown( CIFLoopHeader *stack )
{
    for (int i = 0; i < stack->capacity; ++i ) {
        CIFTagClear(&stack->list[i]);
    }
    FREE(stack->list,1);
    stack->capacity = 0;
    stack->count = 0;
}

CIFDataConsumerCallbacks CIFDataConsumerCallbacksNull = {
   .ctx = NULL,
   .beginData = NULL,
   .item = NULL,
   .beginLoop = NULL,
   .loopItem = NULL,
   .loopItemTerm = NULL,
   .endLoop = NULL,
   .endData = NULL
   };



static void (CIFTestHandlerBeginData)( void* ctx, CIFToken value )
{
  printf("[]beginData (%.*s)\n",value.len,value.text);
}
static void (CIFTestHandlerItem)( void *ctx, CIFTag tag, CIFToken value )
{
  printf("[]item (%.*s - %.*s)\n",tag.len,tag.text,value.len,value.text);
}
static void (CIFTestHandlerBeginLoop)( void *ctx, CIFLoopHeader header )
{
  printf("[]beginLoop\n");
}
static void (CIFTestHandlerLoopItem)( void *ctx, CIFLoopHeader header, size_t itemIndex, CIFToken value )
{
   int i = (int)itemIndex % header.count;
  printf("[]loopItem (%zu:%i, %.*s - %.*s)\n",itemIndex,i,header.list[i].len,header.list[i].text,value.len,value.text);
}
static void (CIFTestHandlerLoopItemTerm)( void *ctx )
{
  printf("[]loopItemTerm\n");
}
static void (CIFTestHandlerEndLoop)( void *ctx )
{
  printf("[]endLoop\n");
}
static void (CIFTestHandlerEndData)( void *ctx )
{
  printf("[]endData\n");
}

static void (CIFTestHandlerError)(void *ctx, CIFDataInputError errorState, const char *msg  )
{
   fprintf(stderr,">>>> %s (CODE:%d)\n",msg,errorState);
}

CIFDataConsumerCallbacks CIFTestHandlers = {
   .ctx = NULL,
   .beginData = CIFTestHandlerBeginData,
   .item = CIFTestHandlerItem,
   .beginLoop = CIFTestHandlerBeginLoop,
   .loopItem = CIFTestHandlerLoopItem,
   .loopItemTerm = CIFTestHandlerLoopItemTerm,
   .endLoop = CIFTestHandlerEndLoop,
   .endData = CIFTestHandlerEndData,
   .error = CIFTestHandlerError
};

