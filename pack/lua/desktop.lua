-- Startup helper for the TuxScreen launchers (desktop.lua).
--
-- TUX_LOGIN, TUX_START: typed on the emulated IR keyboard at 25 s and 35 s,
--   the way it was done on the real phone. If the user starts typing first (a
--   letter, digit, space or Enter going from up to down) nothing more is typed;
--   modifiers, lock keys and function keys do not count, so Alt+Tab is fine.
-- TUX_PICO=1: PicoGUI keys, done as touches on fixed points of the screen,
--   because PicoGUI 0.1 cannot open or close its menus from the keyboard:
--     F1  opens or closes Applications; with an application up, closes it
--         first (two applications at once starve PicoGUI 0.1)
--     F2  opens or closes System
--     1-7 with a menu open, picks that entry (System has 2)
--     F3  closes what is in front: a System box (answering No to Beam
--         out), an open menu, or the application window
--   Ignored while Ctrl or Alt is held (Ctrl+Alt+F2 is the text console).
-- TUX_MENU: second at which Applications is opened once, if the user has not
--   typed anything yet.
local login = os.getenv("TUX_LOGIN") or ""
local start = os.getenv("TUX_START") or ""
local pico = os.getenv("TUX_PICO") == "1"
local menu_at = tonumber(os.getenv("TUX_MENU") or "")
local nat = manager.machine.natkeyboard
local ports = manager.machine.ioport.ports

local fields = {}
for i = 0, 15 do
	for name, field in pairs(ports[":KEY" .. i].fields) do
		fields[name] = field
	end
end

-- ---------------------------------------------------------------- typing
local typing_names = {
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q",
	"R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7",
	"8", "9", "Space", "Enter", "Backspace"
}
local typing_last = {}
local user_active = false
local quiet_until = 0
local step = 0

local function user_started_typing(now)
	local posting = nat.is_posting
	if posting then
		quiet_until = now + 1
	end
	local started = false
	for _, name in ipairs(typing_names) do
		local v = fields[name].port:read() & fields[name].mask
		if typing_last[name] ~= nil and not posting and now >= quiet_until and v ~= 0 and typing_last[name] == 0 then
			started = true
		end
		typing_last[name] = v
	end
	return started
end

emu.register_periodic(function()
	if user_active or step >= 2 then
		return
	end
	local now = manager.machine.time.seconds
	if user_started_typing(now) then
		user_active = true
		return
	end
	if step == 0 and now >= 25 then
		if login ~= "" then
			nat:post(login .. "\n")
			quiet_until = now + 1
		end
		step = 1
	elseif step == 1 and now >= 35 and now >= quiet_until then
		if start ~= "" then
			nat:post(start .. "\n")
		end
		step = 2
	end
end)

-- ---------------------------------------------------------------- PicoGUI
if not pico then
	return
end

local tx = ports[":TOUCHX"].fields["Touch X"]
local ty = ports[":TOUCHY"].fields["Touch Y"]
local tb = ports[":TOUCHB"].fields["Touch"]
local BUTTON = { apps = { 38, 14 }, system = { 100, 14 } }
local ITEMS = { apps = { x = 40, n = 7 }, system = { x = 110, n = 2 } }
local BOX_CLOSE = {
	about = { 425, 297 },      -- "ok" of the About PicoGUI box
	scotty = { 336, 257 },     -- "No" of the "Beam out... Make it so?" box
}
local APP_CLOSE = { 8, 472 }   -- close box at the bottom left of an app
local APP_CLOSE_WAIT = 120     -- frames for PicoGUI to take the app down

local open = nil        -- menu we believe is open
local box = nil         -- box opened from the System menu, if any
local app = false       -- an application launched from Applications is up
local queue = {}        -- pending { x, y, wait_before } taps
local tap_frames = -1
local wait = 0
local menu_done = (menu_at == nil)
local key_last = {}

local function tap(x, y, before)
	queue[#queue + 1] = { x, y, before or 0 }
end

local function pressed(name)
	local f = fields[name]
	return (f.port:read() & f.mask) ~= 0
end

local function edge(name)
	local now_down = pressed(name)
	local was = key_last[name]
	key_last[name] = now_down
	return now_down and was == false
end

local function toggle(menu)
	tap(BUTTON[menu][1], BUTTON[menu][2])
	if open == menu then open = nil else open = menu end
end

local watched = { "F1", "F2", "F3", "1", "2", "3", "4", "5", "6", "7" }
for _, name in ipairs(watched) do key_last[name] = pressed(name) end

local function run_queue()
	if tap_frames >= 0 then
		tap_frames = tap_frames - 1
		if tap_frames < 0 then
			tx:clear_value(); ty:clear_value(); tb:clear_value()
		end
		return true
	end
	if #queue == 0 then
		return false
	end
	local t = queue[1]
	if t[3] > 0 then
		t[3] = t[3] - 1
		return true
	end
	table.remove(queue, 1)
	tx:set_value(t[1]); ty:set_value(t[2]); tb:set_value(1)
	tap_frames = 12
	return true
end

emu.register_frame_done(function()
	if run_queue() then
		for _, name in ipairs(watched) do key_last[name] = pressed(name) end
		return
	end

	if not menu_done and manager.machine.time.seconds >= menu_at then
		menu_done = true
		if not user_active then
			toggle("apps")
			return
		end
	end

	local modifier = pressed("Left Ctrl") or pressed("Right Ctrl") or pressed("Left Alt") or pressed("Right Alt")
	for _, name in ipairs(watched) do
		if edge(name) and not modifier then
			if name == "F1" then
				if app and open ~= "apps" then
					-- only one application at a time: two of them starve PicoGUI
					if open then toggle(open) end
					tap(APP_CLOSE[1], APP_CLOSE[2])
					app = false
					tap(BUTTON.apps[1], BUTTON.apps[2], APP_CLOSE_WAIT)
					open = "apps"
				else
					toggle("apps")
				end
			elseif name == "F2" then
				toggle("system")
			elseif name == "F3" then
				if box then
					tap(BOX_CLOSE[box][1], BOX_CLOSE[box][2])
					box = nil
				elseif open then
					toggle(open)
				else
					tap(APP_CLOSE[1], APP_CLOSE[2])
					app = false
				end
			elseif open then
				local n = tonumber(name)
				local item = ITEMS[open]
				if n <= item.n then
					tap(item.x, 37 + 15 * (n - 1))
					if open == "system" then
						box = (n == 1) and "about" or "scotty"
					else
						app = true
					end
					open = nil
				end
			end
		end
	end
end)
