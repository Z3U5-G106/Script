-- StarterPlayerScripts/EnableFullChat.client.lua

local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

-- Use the modern chat system
TextChatService.ChatVersion = Enum.ChatVersion.TextChatService

-- Make sure the core Chat UI is visible
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
end)

-- Target the default general channel so the input bar works
task.spawn(function()
	local channelsFolder = TextChatService:WaitForChild("TextChannels")
	local general = channelsFolder:FindFirstChild("RBXGeneral") or channelsFolder:WaitForChild("RBXGeneral")
	if general and TextChatService.ChatInputBarConfiguration then
		TextChatService.ChatInputBarConfiguration.TargetTextChannel = general
	end
end)

-- Turn on both the floating bubbles and the chat window
task.spawn(function()
	local bubbleCfg = TextChatService:FindFirstChild("BubbleChatConfiguration") 
		or TextChatService:WaitForChild("BubbleChatConfiguration")
	if bubbleCfg then bubbleCfg.Enabled = true end
end)

task.spawn(function()
	local windowCfg = TextChatService:FindFirstChild("ChatWindowConfiguration") 
		or TextChatService:WaitForChild("ChatWindowConfiguration")
	if windowCfg then windowCfg.Enabled = true end
end)