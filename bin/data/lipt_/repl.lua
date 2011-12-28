numDatas = 256
	for i=0,numDatas-1 do
		if not song.phrases[i].used then
			print(i)
		end
	end
