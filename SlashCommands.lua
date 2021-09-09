if GogoWatch == nil then GogoWatch = {} end
if GogoWatch.SlashCommands == nil then
    GogoWatch.SlashCommands = {}
    SLASH_GOGOWATCH1 = '/gogowatch'
    SlashCmdList['GOGOWATCH'] = function(arg)
        local fn = GogoWatch.SlashCommands[arg]
        if type(fn) == "function" then
            fn()
        end
    end
end