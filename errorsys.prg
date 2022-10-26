/***
*
*	Errorsys.prg
*
*  Standard Clipper error handler
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Compile:  /m /n /w
*
*/

#include "error.ch"


// put messages to STDERR
#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)


// used below
#define NTRIM(n)		( LTrim(Str(n)) )



/***
*	ErrorSys()
*
*	Note:  automatically executes at startup
*/

proc ErrorSys()
	ErrorBlock( {|e| DefError(e)} )
return




/***
*	DefError()
*/
static func DefError(e)
local i, cMessage, aOptions, nChoice

	// by default, division by zero yields zero
	
	
	if ( e:genCode == EG_ZERODIV )
		return (0)
	end

	// for network open error, set NETERR() and subsystem default
	if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )

		NetErr(.t.)
		return (.f.)									// NOTE

	end

	// for lock error during APPEND BLANK, set NETERR() and subsystem default
	if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )

		NetErr(.t.)
		return (.f.)									// NOTE

	end

	// build error message
	cMessage := ErrorMessage(e)

	// build options array
	// aOptions := {"Break", "Quit"}
	aOptions := {"Quit"}

	if (e:canRetry)
		AAdd(aOptions, "Retry")
	end

	if (e:canDefault)
		AAdd(aOptions, "Default")
	end

	// put up alert box

	if e:osCode = -2147352567


		nChoice := 1
		while ( nChoice == 0 )

			if ( Empty(e:osCode) )
*				nChoice := Alert( cMessage, aOptions )

			else
*				nChoice := Alert( cMessage + ;
*								";(DOS Error " + NTRIM(e:osCode) + ")", ;
*								aOptions )
			end

			if ( nChoice == NIL )
				exit
			endif
		end
		
    else

		nChoice := 0
		while ( nChoice == 0 )

			if ( Empty(e:osCode) )
				nChoice := Alert( cMessage, aOptions )

			else
				nChoice := Alert( cMessage + ;
								";(DOS Error " + NTRIM(e:osCode) + ")", ;
								aOptions )
			end

			if ( nChoice == NIL )
				exit
			endif
		
		end
    endif

	if ( !Empty(nChoice) )

		// do as instructed
		if ( aOptions[nChoice] == "Break" )
			Break(e)

		elseif ( aOptions[nChoice] == "Retry" )
			return (.t.)

		elseif ( aOptions[nChoice] == "Default" )
			return (.f.)

		end

	end

	if e:osCode = -2147352567
		Break(e)
    endif
	// display message and traceback
	if ( !Empty(e:osCode) )
		cMessage += " (DOS Error " + NTRIM(e:osCode) + ") "
	end

*	? cMessage
	cError=Chr(13)+Chr(10)+"========= ERROR ========="+Chr(13)+Chr(10)
	cError=cError+dtoc(date())+" "+time()+Chr(13)+Chr(10)+cMessage+Chr(13)+Chr(10)
	i := 2
	while ( !Empty(ProcName(i)) )
*		? "Called from", Trim(ProcName(i)) + "(" + NTRIM(ProcLine(i)) + ")  "
		cError=cError+"Called from "+ Trim(ProcName(i)) + "(" + NTRIM(ProcLine(i)) + ")  "+chr(13)+chr(10)
		i++
	end
	cError=cError+"Curdir()="+CurDir()+Chr(13)+Chr(10)

    cError=cError+Chr(13)+Chr(10)+"Area Seleccionada: "+Str(select(),2)+Chr(13)+Chr(10)
	cError=cError+"Alias="+Alias()+"  "
*	cError=cError+"DBF: "+Dbf()+"  "
	cError=cError+"EOF()="+IIF(Eof(),".T.",".F.")+"  "
	cError=cError+"Recno()="+AllTrim(Str(RecNo()))+" / "+AllTrim(Str(lastrec()))+Chr(13)+Chr(10)+Chr(13)+Chr(10)
    if !Empty(IndexOrd())
		cError=cError+"IndexKey()="+IndexKey()+Chr(13)+Chr(10)
	endif
	cError=cError+"IndexOrd()="+Str(IndexOrd(),2)+Chr(13)+Chr(10)
	? "Alias: "+Alias()
	if !Empty(Alias())
		for j=1 to FCount()
			cVar=Field(j)
			xVal=&cVar
			cError=cError+cVar+"="
			do case
				case Type(cVar)="C"
					cError=cError+xVal+Chr(13)+Chr(10)
				case Type(cVar)="N"
					cError=cError+AllTrim(Str(xVal))+Chr(13)+Chr(10)
				case Type(cvar)="D"
					cError=cError+DToC(xVal)+Chr(13)+Chr(10)
				case Type(cVar)="L"
					cError=cError+".F."+Chr(13)+Chr(10)
			endcase
			
		next j
	endif
	
	cError=cError+Chr(13)+Chr(10)+"Todas las Areas:"+Chr(13)+Chr(10)
	for j=1 to 30
		Select &j
	    if !Empty(Alias())
			cError=cError+"Select="+Str(Select(),2)+"  "
			cError=cError+"Alias="+Alias()+"  "
*			cError=cError+"DBF="+Dbf()+"  "
			cError=cError+"EOF()="+IIF(Eof(),".T.",".F.")+"  "
			cError=cError+"RECNO()="+AllTrim(Str(RecNo()))+" / "+AllTrim(Str(lastrec()))+Chr(13)+Chr(10)
		endif
	next j

	cError=cError+Chr(13)+Chr(10)+cMessage+Chr(13)+Chr(10)

	i := 2
	while ( !Empty(ProcName(i)) )
*		? "Called from", Trim(ProcName(i)) + "(" + NTRIM(ProcLine(i)) + ")  "
		cError=cError+"Called from "+ Trim(ProcName(i)) + "(" + NTRIM(ProcLine(i)) + ")  "+chr(13)+chr(10)
		i++
	end

	cError=cError+"========= ERROR ========="+Chr(13)+Chr(10)
    set color to GR+/r
	? cError
	set color to

	memowrit("purl.err",cError)
	
	// give up
	ErrorLevel(1)
	QUIT

return (.f.)




/***
*	ErrorMessage()
*/
static func ErrorMessage(e)
local cMessage


	// start error message
	cMessage := if( e:severity > ES_WARNING, "Error ", "Warning " )


	// add subsystem name if available
	if ( ValType(e:subsystem) == "C" )
		cMessage += e:subsystem()
	else
		cMessage += "???"
	end


	// add subsystem's error code if available
	if ( ValType(e:subCode) == "N" )
		cMessage += ("/" + NTRIM(e:subCode))
	else
		cMessage += "/???"
	end


	// add error description if available
	if ( ValType(e:description) == "C" )
		cMessage += ("  " + e:description)
	end


	// add either filename or operation
	if ( !Empty(e:filename) )
		cMessage += (": " + e:filename)

	elseif ( !Empty(e:operation) )
		cMessage += (": " + e:operation)

	end


return (cMessage)

