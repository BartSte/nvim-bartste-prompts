local class = require("prompts._class")

local Prompt = class()

function Prompt:__init(command, file)
    self.command = command
    self.file = file
    self.file_copy = vim.fn.tempname()
    self.process = nil
    self.userprompt = ''
end

return Prompt

