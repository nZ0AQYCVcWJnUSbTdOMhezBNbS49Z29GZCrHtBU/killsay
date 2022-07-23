_G.simulateTyping = false -- Change to false if you want to instantly chat the message.

if _G.deathMessageRan then
 return
end

_G.deathMessageRan = true

local players = game:GetService("Players")
local player = players.LocalPlayer

local replicated = game:GetService("ReplicatedStorage")
local defaultChat = replicated:WaitForChild("DefaultChatSystemChatEvents")
local sayMessage = defaultChat:WaitForChild("SayMessageRequest")

function sendMessage(text)
 sayMessage:FireServer(text, "All")
end

local phraseList = {
 "imagine dying | kodehook",
 "private, dont ask | kodehook ",
 "L | kodehook",
 "no cheats just quality of life enhancements | kodehook",
 "i dont cheat im just superior | kodehook",
 "dying is not trendy anymore | kodehook",
 "i cant believe people play legit | kodehook",
 "you just got destroyed by "..game.Players.LocalPlayer.Name.." | kodehook",
 "cant touch this | kodehook",
 "still the best | kodehook"
}

local replace = {
["($%b{})"] = function(text)
return text
end,

["($%b<>)"] = function(text)
return string.lower(text)
end,

["($%b[])"] = function(text)
return string.upper(text)
end,

["($%b^^)"] = function(text)
return text:gsub("%a", function(c)
return math.random(1, 2) == 1
and c:upper()
or c:lower()
end)
end
}

function localize(text, list)
 for pattern, callback in next, replace do
   if text:find(pattern) then
     text = text:gsub(pattern,
       function(word)
         local value = list[word:sub(3, -2)]
         
         return (callback and callback(value)) or value
       end
     )
   end
 end

 return text
end

local rng = Random.new()

function rndItem(list)
 return list[math.random(#list)]
end

function join(a, b)
 return string.format("%s %s", a, b)
end

function genPhrase(name)
 local params = {
   target = name,
 }

 local number = rng:NextInteger(1, 10)
 local phrase
 phrase = rndItem(phraseList)
 return localize(phrase, params)
end

function waitTyping(text)
 wait(1 + #text * 0.027)
end

-- You can modify this function depending on the game you are playing.
-- It should be noted that not all games process the way you kill someone the same way.
-- So it is essentially very difficult to track it across all games universally.
-- Currently, the way I have it set is the most popular, works through tags.
function hookFunction(target)  
 local character = target.Character or target.CharacterAdded:wait()
 local humanoid = character:WaitForChild("Humanoid", 5)

 local function onHealthChanged(humanoid)
   humanoid.HealthChanged:connect(function(health)
     if health <= 0 then
       local tag = humanoid:WaitForChild("creator", 2)
 
       if tag.Value == player then
         local phrase = genPhrase(target.Name)
         
         if _G.simulateTyping then
           waitTyping(phrase)
         end

         sendMessage(phrase)
       end
     end
   end)
 end

 onHealthChanged(humanoid)

 target.CharacterAdded:connect(function(character)
   character = character
   humanoid = character:WaitForChild("Humanoid", 5)

   onHealthChanged(humanoid)
 end)
end

for _, player in next, players:GetPlayers() do
 hookFunction(player)
end

players.PlayerAdded:connect(function(player)
 hookFunction(player)
end)
