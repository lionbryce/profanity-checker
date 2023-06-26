-- a file of code I used to test this as I was building it
-- written in order of the highest do/end block being written most recently

do
	local examples = { -- we could run this through the whole dictionary
		"axe",
		"I'm going to #axe you a #question",
		"I'm going to axe you a question",
		"I'm going to axxxe you a question",
		"I'm going to axxxxe you a question",
		"I'm gonna get baned by axing you a question",
		"I'm gonna get banned by axxxing you a question",
		"I'm gonna get baned by axxxxeing you a question",
		"I'm gonna get baned by axxxxeing you a question",
	}

	for _,example in ipairs(examples) do
		print(ProfanityCheck(example),"-",example)
	end

	do
		local t0 = SysTime()
		for i=1,1e3 do
			for _,example in ipairs(examples) do
				ProfanityCheck(example)
			end
		end
		local t1 = SysTime()
		print("time looping through all every loop:",t1-t0)
	end

	do
		local times = {}
		for k,example in ipairs(examples) do
			local t0 = SysTime()
			for i=1,1e3 do
				ProfanityCheck(example)
			end
			local t1 = SysTime()
			times[k] = t1-t0
		end

		print("Time per example:")

		for k,v in ipairs(times) do
			print(v,"-",examples[k])
		end
	end

	-- print("cache hits:",cacheHits)
	-- print("cache misses:",cacheMisses)

	--[[ -- here's the results on my machine
		time looping through all every loop:	0.48317700000007
		Time per example:
		0.013650700000653	-	axe
		0.048180600000705	-	I'm going to #axe you a #question
		0.045768800000587	-	I'm going to axe you a question
		0.050778900000296	-	I'm going to axxxe you a question
		0.050275499999771	-	I'm going to axxxxe you a question
		0.064974700000676	-	I'm gonna get baned by axing you a question
		0.063352299999679	-	I'm gonna get banned by axxxing you a question
		0.0722480000004		-	I'm gonna get baned by axxxxeing you a question
		0.066125199999078	-	I'm gonna get baned by axxxxeing you a question
	]]

	--[[ -- here's the results on my machine with the cache
		time looping through all every loop:	0.0010505000009289
		Time per example:
		6.8200000896468e-05	-	axe
		0.00010389999988547	-	I'm going to #axe you a #question
		0.00010299999848939	-	I'm going to axe you a question
		0.00010219999967376	-	I'm going to axxxe you a question
		0.00010269999984303	-	I'm going to axxxxe you a question
		8.8599999799044e-05	-	I'm gonna get baned by axing you a question
		8.8200000391225e-05	-	I'm gonna get banned by axxxing you a question
		0.00011590000030992	-	I'm gonna get baned by axxxxeing you a question
		0.00011540000014065	-	I'm gonna get baned by axxxxeing you a question	
	]]
end

-- testing the repeats
do
	local examples = {
		"axxxxeefffff",
		"axxxxeef",
		"axe",
		"axxxe",
		"axxxxef",
		"axxxxeff",
		"axxxxefff",
	}
	for _,example in ipairs(examples) do
		print("example:",example)
		for k,v in pairs(letterRepeats) do
			print(k,v,string.gsub(example,k,v))
		end
		print("\n")
	end
end

-- perf test that I used to determine that string.gsub was faster than turning the string back into a table;
-- yes this is a bad test for a meriad of reasons, but it's good enough for me and shows how one would switch
-- from using gsub to an exploded string


local function explodeString(str)
	local tbl = {}
	for i=1,#str do
		tbl[i] = string.sub(str,i,i)
	end
	return tbl
end

do
	local t0 = SysTime()

	for i=1,1e5 do
		local example = "I'm going to axe you a question"
		example = explodeString(example)
		for k,v in ipairs(example) do
			example[k] = replacements[v] or v
		end
	end

	local t1 = SysTime()

	print("explode",t1-t0)
end

do
	local t0 = SysTime()

	for i=1,1e5 do
		local example = "I'm going to axe you a question"
		for k,v in ipairs(replacements) do
			example = string.gsub(example, k, v)
		end
	end

	local t1 = SysTime()

	print("gsub",t1-t0)
end