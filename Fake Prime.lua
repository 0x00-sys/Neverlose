local ffi = require("ffi")

ffi.cdef[[
    int VirtualProtect(void*, unsigned long, unsigned long, unsigned long*);
]]

local function writeToMemory(address, value, bytes)
    local oldProtect = ffi.new("unsigned long[1]")

    ffi.C.VirtualProtect(ffi.cast("void*", address), bytes, 0x40, oldProtect)

    ffi.copy(ffi.cast("void*", address), ffi.cast("const void*", value), bytes)

    ffi.C.VirtualProtect(ffi.cast("void*", address), bytes, oldProtect[0], nil)
end

local primeStatus = utils.PatternScan("client.dll", "? ? ? ? ? 85 C0 75 07 83 F8 05 0F 94 C0 C3") or error("Pattern Invalid!")
local cfgPrimeStatus = menu.Switch("Fake Prime", "Enable", false)

local function cfgPrimeStatusCallback()
    if cfgPrimeStatus:GetBool() then
        writeToMemory(primeStatus, "\x31\xC0\xFE\xC0\xC3", 5)
    else
        writeToMemory(primeStatus, "\xA1\x38\x75\x24\x05", 5)
    end
end

cfgPrimeStatusCallback()
cfgPrimeStatus:RegisterCallback(cfgPrimeStatusCallback)

cheat.RegisterCallback("destroy", function()
    if cfgPrimeStatus:GetBool() then
        writeToMemory(primeStatus, "\xA1\x38\x75\x24\x05", 5)
    end
end)
