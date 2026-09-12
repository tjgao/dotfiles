local function entry()
  local yes = ya.confirm({
    pos = { "center", w = 56, h = 9 },
    title = "Quit Yazi?",
    body = ui.Text("Exit Yazi now?"):wrap(ui.Wrap.YES),
  })

  if yes then
    ya.emit("quit", {})
  end
end

return { entry = entry }
