-- Preview Office documents (Writer formats) by converting them to PDF with
-- LibreOffice, then rendering pages like the built-in `pdf` previewer.
--
-- The PDF is cached next to yazi's own per-file cache entry, whose name
-- includes the source file's mtime/size, so edits always get re-converted.

local M = {}

local function fail(job, s)
	ya.preview_widget(job, ui.Text.parse(tostring(s)):area(job.area):wrap(ui.Wrap.YES))
end

-- Stable path for the converted PDF of this exact file version.
local function pdf_path(job)
	local base = ya.file_cache({ file = job.file, skip = 0 })
	return base and Url(tostring(base) .. ".pdf")
end

-- Convert the source document to PDF once, atomically publishing it so
-- concurrent peek/preload jobs cannot observe a half-written file.
local function convert(job, pdf)
	local tmp = string.format("%s.lo-%d-%d", tostring(pdf), os.time(), math.random(100000, 999999))
	Command("mkdir"):arg({ "-p", tmp }):output()

	local output, err = Command("libreoffice"):arg({
		"--headless",
		"--norestore",
		"--nolockcheck",
		"-env:UserInstallation=file://" .. tmp .. "/profile",
		"--convert-to",
		"pdf",
		"--outdir",
		tmp,
		tostring(job.file.path),
	}):output()

	local produced = tmp .. "/" .. job.file.name:gsub("%.[^%.]+$", ".pdf")
	local ok = output and output.status.success and fs.cha(Url(produced))

	if ok then
		Command("mv"):arg({ "-f", produced, tostring(pdf) }):output()
	end

	Command("rm"):arg({ "-rf", tmp }):output()

	if not ok then
		return false, Err(
			"libreoffice: %s",
			output and output.stderr ~= "" and output.stderr or tostring(err or "conversion failed")
		)
	end
	return true
end

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache then
		return
	end

	local ok, err, bound = self:preload(job)
	if bound and bound > 0 then
		return ya.emit("peek", { bound - 1, only_if = job.file.url, upper_bound = true })
	elseif not ok or err then
		return fail(job, err or "failed to render preview")
	end

	ya.sleep(math.max(0, rt.preview.image_delay / 1000 + start - os.clock()))

	local _, show_err = ya.image_show(cache, job.area)
	ya.preview_widget(job, show_err)
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = ya.clamp(-1, job.units, 1)
		ya.emit("peek", { math.max(0, cx.active.preview.skip + step), only_if = job.file.url })
	end
end

function M:preload(job)
	local pdf = pdf_path(job)
	if not pdf then
		return true
	end

	if not fs.cha(pdf) then
		local ok, err = convert(job, pdf)
		if not ok then
			return true, err
		end
	end

	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	local output, err = Command("pdftoppm")
		:arg({
			"-f", tostring((job.skip or 0) + 1),
			"-l", tostring((job.skip or 0) + 1),
			"-singlefile",
			"-jpeg",
			"-jpegopt", "quality=" .. rt.preview.image_quality,
			"-r", "150",
			tostring(pdf),
			tostring(cache),
		})
		:output()

	if not output then
		return true, Err("Failed to start `pdftoppm`: %s", tostring(err))
	elseif not output.status.success then
		local pages = (job.skip or 0) > 0 and tonumber(output.stderr:match("the last page %((%d+)%)"))
		return true, Err("Failed to render PDF page, stderr: %s", output.stderr), pages
	end

	return ya.image_precache(Url(tostring(cache) .. ".jpg"), cache)
end

return M
