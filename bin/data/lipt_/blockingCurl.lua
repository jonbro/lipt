toExecute = [[
  print("inside thread")
require("cURL")

print("starting upload!")

c = cURL.easy_init()

c:setopt_url("http://plbtest.heroku.com/")
postdata = {  
   -- post file from filesystem
   image = {file=blud.bundle_root ..  "/namcap/assets/cute.png",
     type="image/png"},
   -- post file from data variable
  }
  print("inside thread")
c:post(postdata)
print(c:perform())
print("completed")
]]

async = bludAsycCurl()
async:process(toExecute)
isComplete = false
-- while not isComplete do
-- 	isComplete = async:isComplete();
-- end


print("completed upload")
