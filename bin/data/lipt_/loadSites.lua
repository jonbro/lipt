--[[
The Socket Library from
http://www.tecgraf.puc-rio.br/~diego/professional/luasocket/
Implements socket based clients and servers in Lua.

There are other protocol handlers available within the
library (for protocols like http) but here is a low level
example.

]]

-- client = socket.connect("www.wellho.net",80)
-- client:send("GET /web2/picfeeder.php HTTP/1.0\r\n")
-- client:send("host: www.wellho.net\r\n\r\n")
local ltn12 = require("ltn12")

client = socket.connect("jonbro.tk",80)
client:send("GET /robots.txt HTTP/1.0\r\n\r\n")

while true do
        s, status, partial = client:receive(1024)
        print (s or partial)
        if status == "closed" then break end
end
client:close()

--[[ Replace the client:receive with a function call to
receive and do a client:setttimeout(0) in there if you
want a none-blocking read.  You can then use a coroutine
to ensure that your client code is not blocking the rest
of your application ]]

--[[ --------------- Sample Output ---------------

[trainee@easterton u116]$ lua webclient
HTTP/1.1 200 OK
Date: Sat, 28 Jun 2008 14:07:19 GMT
Server: Apache/1.3.33 (Darwin) PHP/4.3.10
Last-Modified: Wed, 19 Jan 2005 11:22:03 GMT
ETag: "2a5c95-179-41ee42db"
Accept-Ranges: bytes
Content-Length: 377
Connection: close
Content-Type: text/plain

#
#  robots.txt file for www.wellho.net and www.wellho.co.uk
#
#  we encourage robots to visit and index all documents
#  but not any executable scripts.
#
#  Most recent update - January 2005
#  Do not index unique.html if you find it; it's a file of
#  words that occur only once on the site and may be typos
#
User-agent:  *
Disallow: /cgi-bin/
Disallow: /net/unique.html

[trainee@easterton u116]$

]]
