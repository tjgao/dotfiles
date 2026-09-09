-- ~/.config/yazi/init.lua
function Linemode:size_and_mtime()
    local time = math.floor(self._file.cha.mtime or 0)
    if time == 0 then
        time = ""
    elseif os.date("%Y", time) == os.date("%Y") then
        time = os.date("%b %d %H:%M", time)
    else
        time = os.date("%b %d  %Y", time)
    end

    local size = self._file:size()
    return ui.Line(string.format("%s %s", size and ya.readable_size(size) or "-", time))
end

Status:children_add(function()
    local h = cx.active.current.hovered
    if h == nil or ya.target_family() ~= "unix" then
        return ui.Line({})
    end

    return ui.Line({
        ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
        ui.Span(":"),
        ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
        ui.Span(" "),
    })
end, 500, Status.RIGHT)

function Status:name()
    local h = self._tab.current.hovered
    if h == nil or ya.target_family() ~= "unix" then
        return ui.Line({})
    end
    local mtime = math.floor(h.cha.mtime or 0)
    if mtime == 0 then
        mtime = ""
    else
        mtime = os.date("%Y-%m-%d %H:%M", mtime)
    end
    local linked = " " .. h.name
    if h.link_to ~= nil then
        linked = linked .. " -> " .. tostring(h.link_to)
    end
    if mtime ~= "" then
        linked = linked .. " " .. mtime
    end
    return ui.Line(linked)

    -- local h = self._tab.current.hovered
    -- if not h then
    --     return ui.Line({})
    -- end
    -- local mtime = math.floor(h.cha.modified or 0)
    -- if mtime == 0 then
    --     mtime = ""
    -- else
    --     mtime = os.date("󱑃: %Y-%m-%d %H:%M(m)", mtime)
    -- end
    -- local ctime = math.floor(h.cha.created or 0)
    -- if ctime == 0 then
    --     ctime = ""
    -- else
    --     ctime = os.date(" : %Y-%m-%d %H:%M(c)", ctime)
    -- end
    -- local linked = ""
    -- if h.link_to ~= nil then
    --     linked = " -> " .. tostring(h.link_to)
    -- end
    -- if mtime ~= "" then
    --     linked = " " .. linked .. " " .. mtime
    -- end
    -- if ctime ~= "" then
    --     linked = linked .. " " .. ctime
    -- end
    -- return ui.Line(linked)
end
