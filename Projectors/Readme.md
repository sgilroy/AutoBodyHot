Note that I originally tried to implement this script using plink, but I was unable to get it to work consistently. The problem may be due to timing issues. That is, I suspect that the command was being sent to the projector too soon after connecting and thus the command was being ignored. I don't know of a good way to use plink to wait for a certain response from the server and then send a command. As a workaround, I tried using the AutoHotKey commands Send and SendRaw to send the commands to the plink window after connecting, but this did not seem to help.

Reference:
http://www.autohotkey.com/forum/topic55958.html
http://jerrymannel.com/blog/2008/11/11/telnet-scripting-tool-aka-tst10exe/
http://www.autohotkey.com/forum/topic55958.html
http://pjlink.jbmia.or.jp/english/
http://pjlink.jbmia.or.jp/english/data/PJLink%20Specifications100.pdf
http://the.earth.li/~sgtatham/putty/0.58/htmldoc/Chapter7.html
http://www.autohotkey.com/forum/topic48726.html
http://www.autohotkey.com/forum/topic36168.html
http://the.earth.li/~sgtatham/putty/0.62/htmldoc/

Scott Gilroy
February 15, 2012