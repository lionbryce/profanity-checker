-- microoptimizations
local lower = string.lower
local gsub = string.gsub
local find = string.find

local blacklist = {
	"axe", -- if we detect the word "axe" in your statement then it will be blocked
	"biffed", -- another example word, specifically chosen because of the double letter in the middle
	"bannned", -- an intentional typo to make sure we can automatically generated nn[n]+
}

local replacements = { -- I don't want a giant list of every possible combination that resembles "axe"
	["@"] = "a",
	["4"] = "a",
	["^"] = "a",
	["/\\"] = "a",
	["#"] = "x", -- imo this looks more like an x and yeah that's about it I guess in this example we'll let you type #xe because sometimes people to put #hashtag
	["3"] = "e", -- I could keep going but this is an example, and it's not like I'm actually worried about people putting "axe" there are far worse words
	["m"] = "n", -- one more to show a different letter that's likely to occur
}

 -- used to produce & store a pattern to turn axxxxe into axe, in this case we don't need to do this with the As or Es because aaaaaxeeee is stil axe
 -- we used a dictionary here because sometimes you'll want to turn xxx into xx or x into xx
 -- this also takes in account that if your banned for is "apps" it will replace "apppps" with "apps" but not "aps" with "apps" 
 -- because if you wanted to block "aps" and "apps" then you should just block "aps"
 -- in theory you could hardcode this by hand but making it automatic is nice
 -- stored specifically in its own table as storing them in replacements would cause issues due to inconsistent ordering on pairs
 -- structures as before = after
local letterRepeats = {}

do -- scope optimization
	local rep = string.rep
	local format = string.format

	local letterRepeatFormat = "[%s]+"
	for _,bannedWord in ipairs(blacklist) do
		if #bannedWord <= 2 then continue end -- we don't care about words that are less than 3 characters long since the first and last letters repeating won't change anything
		local lastletter = ""
		local repeatedLetterCount = 0

		for i=2,#bannedWord-1 do
			local letter = bannedWord[i]
			
			if letter == lastletter then
				repeatedLetterCount = repeatedLetterCount + 1
			else
				if repeatedLetterCount > 0 then
					local pattern = rep(lastletter,repeatedLetterCount-1) .. format(letterRepeatFormat, lastletter) -- f[f]+ or fff[f]+ perhaps
					letterRepeats[pattern] = rep(lastletter,repeatedLetterCount)
				end

				lastletter = letter
				repeatedLetterCount = 1
			end
		end

		if repeatedLetterCount > 0 then
			local pattern = rep(lastletter,repeatedLetterCount-1) .. format(letterRepeatFormat, lastletter)
			letterRepeats[pattern] = rep(lastletter,repeatedLetterCount)
		end
	end
end

function ProfanityCheck(str)
	str = lower(str) -- make it lowercase so we don't have to worry about case sensitivity
	
	for before,after in pairs(replacements) do
		str = gsub(str, before, after)
	end

	for before,after in pairs(letterRepeats) do
		str = gsub(str, before, after)
	end

	for _,word in ipairs(blacklist) do
		if find(str,word) then -- if we find a blacklisted word then return true, previous testing has show find is faster than match by a reasonable margin
			return true, word
		end
	end

	return false -- no profanity detected
end