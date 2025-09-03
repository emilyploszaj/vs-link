local m = Malachite

local breakpoints = {}

function Malachite:setBreakpoint(callback, address, segment)
	if segment == nil then
		segment = -1
	end
	table.insert(breakpoints, {callback = callback, address = address, segment = segment})
	if emu:platform() ~= C.PLATFORM.NONE then
		emu:setBreakpoint(callback, address, segment)
	end
end

local function initBreakpoints()
	m:log("Initializing callbacks")
	for _, bp in ipairs(breakpoints) do
		m:log(emu:setBreakpoint(bp.callback, bp.address, bp.segment))
	end
end

--callbacks:add("start", initBreakpoints)
