-- create a temp folder
os.execute("mkdir ./tmp")
f = io.popen('find . -iname "*.wav"')
l = f:read("*a")
for line in l:gmatch("[^\r\n]+") do
	line = line:gsub("(\r\n)", "")
	-- print(line)
	fn = io.popen("basename " .. line)
	filename = fn:read("*a"):gsub("[\r\n]", "")

	print("sox " .. line .. " ./tmp/" .. filename .. " rate 22050")
	os.execute("sox " .. line .. " ./tmp/" .. filename .. " rate 22050")
	os.execute("mv ./tmp/" .. filename .. " " .. line)
end