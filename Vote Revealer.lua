menu.Text("Vote Revealer", "Thanks for using my vote revealer!")
local Enable = menu.Switch("Vote Revealer", "Enable", false, "Turn on the vote revealer.")
local Notification = menu.Switch("Vote Revealer", "Cheat Notification", false, "If the vote revealer should make notifications on votes.0")
local Chat_Combo = menu.Combo("Vote Revealer", "Chat Type", {"Disabled", "Client", "Team", "All"}, 0, "If the vote revealer should type in chat.")

local ffi = require("ffi")

local FindElement = ffi.cast("unsigned long(__thiscall*)(void*, const char*)", utils.PatternScan("client.dll", "55 8B EC 53 8B 5D 08 56 57 8B F9 33 F6 39 77 28"))
local CHudChat = FindElement(ffi.cast("unsigned long**", ffi.cast("uintptr_t", utils.PatternScan("client.dll", "B9 ? ? ? ? E8 ? ? ? ? 8B 5D 08")) + 1)[0], "CHudChat")
local FFI_ChatPrint = ffi.cast("void(__cdecl*)(int, int, int, const char*, ...)", ffi.cast("void***", CHudChat)[0][27])

local function PrintInChat(text)
    local Value = Chat_Combo:GetInt()

    if Value == 1 then
        FFI_ChatPrint(CHudChat, 0, 0, string.format("%s ", text))
    end
end

local function main(event)

    if event:GetName() == 'vote_cast' then
        if Enable:GetBool() == false then 
            return
        end

        vote = event:GetInt('vote_option')
        entityId = event:GetInt('entityid')

        local entity = g_EntityList:GetClientEntity(entityId)
        local player = entity:GetPlayer()
        local playerName = player:GetName()
        
        if vote == 0 then
            PrintInChat('\x01[\x0CNEVERLOSE\x01] \x07'..player:GetName()..' \x01voted \x01[\x04Yes\x01]')

            local Value = Chat_Combo:GetInt()

            if Value == 2 then
                g_EngineClient:ExecuteClientCmd('say_team "' ..string.format("[NEVERLOSE] %s voted [Yes]", player:GetName()).. '"')
            end

            if Value == 3 then
                g_EngineClient:ExecuteClientCmd('say "' ..string.format("[NEVERLOSE] %s voted [Yes]", player:GetName()).. '"')
            end
            
            if Notification:GetBool() then
                cheat.AddNotify("Vote Revealer", string.format("[NEVERLOSE] %s voted [Yes]", player:GetName()))
            end
        elseif vote == 1 then
            PrintInChat('\x01[\x0CNEVERLOSE\x01] \x07'..player:GetName()..' \x01voted \x01[\x07No\x01]')
            
            local Value = Chat_Combo:GetInt()

            if Value == 2 then
                g_EngineClient:ExecuteClientCmd('say_team "' ..string.format("[NEVERLOSE] %s voted [No]", player:GetName()).. '"')
            end

            if Value == 3 then
                g_EngineClient:ExecuteClientCmd('say "' ..string.format("[NEVERLOSE] %s voted [No]", player:GetName()).. '"')
            end

            if Notification:GetBool() then
                cheat.AddNotify("Vote Revealer", string.format("[NEVERLOSE] %s voted [No]", player:GetName()))
            end
        end

    end

end

cheat.RegisterCallback("events", main)
