INSTRUCTIONS:
- note that online has been removed from the game, and you will have to recode the functionality back 

- install love2d onto your commandline

* if your on windows and you installed the love2d installer, it should be in cmd already
* to test, open cmd and type love

- cd to this directory

* itll vary depending on ur device, your on ur own with this
* cd is how you go from directory to directory within cmd/commandline

- run "love ."

youll have a server running, but at what cost? it wont run on anything
but ur own device. heres the tricky part

- open a text editor of sorts (notepad works but itll be kinda hard)

* i recommend visual studio code and the lua plugin if ur on pc

- go into main.lua

- check out the comments i left to make shit easier

* unless you know what ur doing, DO NOT touch anything other than sock.newServer

- did u port forward? if not, do that, port forward to any udp port and change the
- part on the end of sock.newServer to the port you forwarded

- run the server again and share with friends! your welcome!