#include "hbextern.ch" 

FUNCTION Main(cFileUrl)

	local nPos
	local cLinea
	local nLineas
	local cUrls
	local cUrl
	local cFile
	local i
	local n

	*SetMode(25,80)
	
	CLEAR SCREEN

	if .not. File(cFileUrl)
		? "PUrl 1.0 (c) 2019 Mauricio Fragoso"
		? "Parallel URL utility for retrieving files like hell from web servers"
		?
		? "Usage: purl <TextFileWithUrls>"
		?
		? "The file must contain one line per url, and the filename where to save it."
		?
		? "http://www.google.com,google.htm"
		? "http://www.yahoo.com,yahoo.htm"
		?
		return
	endif
		
	cUrls=MemoRead(cFileUrl)
	nLineas=MLCount(cUrls,120)
	public aUrls[nLineas,2]
	for i=1 to nLineas
		cLinea=Trim(MemoLine(cUrls,240,i))
		nPos=At(",",cLinea)
		if nPos=0
			exit
		endif
		
		cURL=Left(cLinea,nPos-1)
		cFile=SubStr(cLinea,nPos+1)
		aUrls[i,1]=cUrl
		aUrls[i,2]=cFile

		if Empty(cURL)
			? "Saliendo url vacio"
			exit
		endif
		if Empty(cFile)
			? "Error no hay nombre de archivo para el url"
			exit
		endif		
		nId=hb_threadStart( @httpget(), cURL, cFile, i )

	next i
	n=Seconds()
	
	hb_threadWaitForAll()

	? "Se recuperaron "+str(nLineas,3)+" Urls en "+Str(Seconds()-n,4)+" Segundos"
	
return NIL
	

function httpget(cURL,cFile, nContador)
local oHttp,nStatus,nHandle,nSize
oHttp=http(cURL,"","","","GET")
if oHttp=NIL
	nHandle=FCreate(cFile)
	FClose(nHandle)
	return NIL
endif

nStatus=oHttp:Status
nSize=Len(oHttp:ResponseText)

do case
	case nSize<1024
		? cURL+"..."+Str(nStatus,3)+", "+AllTrim(Transform(nSize,"9,999"))+" Bytes"
	case nSize<1024*1024
		? cURL+"..."+Str(nStatus,3)+", "+AllTrim(Transform(nSize/1024,"9,999"))+" KB"
	case nSize<1024*1024*1024
		? cURL+"..."+Str(nStatus,3)+", "+AllTrim(Transform(nSize/1024/1024,"9,999"))+" MB"
endcase
		
do case
	case nStatus=200
		MemoWrit(cFile,oHttp:ResponseText)
	otherwise
		nHandle=FCreate(cFile)
		FClose(nHandle)
*		MemoWrit(cFile,"")
endcase

return NIL


FUNCTION http(Url,cData,cUsername,cPassword,cMethod)
LOCAL loHTTP
loHTTP = CREATEOBJECT("WinHttp.WinHttpRequest.5.1")
loHTTP:SetTimeouts(10000,10000,10000,10000)
loHTTP:Open(cMethod, Url , .F.)
IF .NOT. EMPTY(cUsername)
	loHTTP:SetCredentials(cUsername,cPassword, 0)
ENDIF
IF cMethod="POST"
	loHTTP:SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
ENDIF
begin sequence
	loHTTP:Send(cData)
	recover
		return NIL
	always
end

RETURN loHTTP


