#ifndef _UMLUSECASE_H
#define _UMLUSECASE_H


#include "UmlBaseUseCase.h"


class FileOut;

// This class manages 'use case'
//
// You can modify it as you want (except the constructor)
class UmlUseCase : public UmlBaseUseCase
{
public:
    UmlUseCase(void * id, const WrapperStr & n) : UmlBaseUseCase(id, n) {};

    virtual void write(FileOut & out);

};

#endif
