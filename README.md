# pUrl
PUrl 1.0 (c) 2019 Mauricio Fragoso
Parallel URL utility for retrieving files like hell from web servers

Usage: purl <TextFileWithUrls>                                                                                                                                                                                                                  The file must contain one line per url, and the filename where to save it.

http://www.google.com,google.htm
http://www.yahoo.com,yahoo.htm

======================================================================

This is a multithreaded 64bit program used to retrieve multiple urls at once.

Instead of retreiving the files in a serial way, it requests all files simultaneously in order to get the best performance.
  
Internally, the code uses HTTP GET requests using windows internal library object WinHttp.WinHttpRequest.5.1

This version was compiled with harbour using Viktor Szakats fork 3.4 found at:

https://github.com/vszakats/hb/releases

You just need to unzip it to c:\ and will create folder \hb34

Next, set your path to include c:\hb34\bin

Then you may compile using compile.bat batch file.

