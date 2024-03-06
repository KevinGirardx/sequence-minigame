local p = nil

RegisterNuiCallback('outcome', function (data, cb)
    SetNuiFocus(false, false)
    if p then
        p:resolve(data)
    end
    cb('ok')
end)

function KeySequence(cb, time, type)
    time = time or 10
    type = type or 'alphabet'
    p = promise.new()

    SendNUIMessage({
        action = 'keysequence',
        time = time * 1000,
        type = type,
    })
    SetNuiFocus(true, true)
    local result = Citizen.Await(p)
    if cb then cb(result) end
end
exports('KeySequence', KeySequence)

-- RegisterCommand('test', function ()
--     KeySequence(function (result)
--         print('result', result)
--     end, 40, 'alphabet')
-- end)