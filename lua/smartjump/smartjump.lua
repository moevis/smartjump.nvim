local conf = require("telescope.config").values
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")

local themes = require('telescope.themes')
local local_opt = { 
  telescope = {
    prompt_title = "Go To File",
  },
  -- or require("telescope.themes").get_dropdown()/get_ivy()/get_cursor()
  theme = nil,
}

local function selectFileUI(items, opts)
	pickers.new(opts, {
		finder = finders.new_table({
			results = items,
      theme = local_opt.themes,
			entry_maker = function(entry)
				return {
					value = entry.path,
					display = entry.path,
					ordinal = entry.path,
					path = entry.path,
					lnum = entry.lnum,
					col = entry.col,
				}
			end,
		}),
		previewer = conf.grep_previewer(opts),
		attach_mappings = function()
			action_set.select:enhance({
				post = function()
					local selection = action_state.get_selected_entry()
					if selection.lnum then
						vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
					end
				end,
			})
			return true
		end,
		sorter = conf.generic_sorter(opts),
	}):find()
end

local function split(s, delimiter)
	local result = {}
	for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

local function fileExist(name)
	local cursor = io.open(name, "r")
	if cursor == nil then
		return false
	end
	io.close(cursor)
	return true
end


function ListFilesUnderCursor(opt)
	if opt == nil then
		opt = {}
	end
	local file = vim.fn.expand("<cfile>")
	if #file == 0 then
		vim.notify("no file under cursor")
		return
	end

	local line = vim.api.nvim_get_current_line()
	local _, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

	local char_in_filename = {}
	for i = 1, #file do
		char_in_filename[file:sub(i, i)] = true
	end

	local end_file_position = cursor_col
	for i = cursor_col, #line do
		end_file_position = i
		if not char_in_filename[line:sub(i, i)] then
			break
		end
	end

	line = line:sub(end_file_position)

	local row, col
	-- try to extract row and col

	-- pattern main.c:row:col
	local _row, _col = string.match(line, "^:(%d+):(%d+)")
	if _row and _col then
		row = tonumber(_row)
		col = tonumber(_col)
	end

	-- pattern main.c:row
	if not row then
		_row = string.match(line, "^:(%d+)")
		if _row then
			row = tonumber(_row)
			col = tonumber(_col)
		end
	end

	-- pattern (quickfix) main.c|111 col 222|
	if not row then
		_row, _col = string.match(line, "|(%d+) col (%d+)|")
		if _row and _col then
			row = tonumber(_row)
			col = tonumber(_col)
		end
	end

	local options = {}
	local optionMap = {}

	if fileExist(file) then
		table.insert(options, { path = file, lnum = row, col = col })
	end

	if string.sub(file, 1, 1) == "/" then
		file = file.sub(file, 2)
	end

	if #vim.o.path == 0 then
		vim.notify("no path defined")
		return
	end

	local folders = split(vim.o.path, ",")
	for _, folder in ipairs(folders) do
		if #folder > 0 then
			if string.sub(folder, -1) ~= "/" then
				folder = folder .. "/"
			end
			local fullpath = vim.fn.simplify(folder .. file)
			if optionMap[fullpath] then
				goto continue
			end
			if fileExist(fullpath) then
				table.insert(options, { path = fullpath, lnum = row, col = col })
				optionMap[fullpath] = true
			end
		end
		::continue::
	end

	if #options == 0 then
		vim.notify("no file found in current paths: " .. vim.o.path)
		return
	end

	opt = vim.tbl_extend("force", local_opt.telescope, opt)

	if _row then
		if _col then
			opt.prompt_title = opt.prompt_title .. " (line " .. _row .. ", col " .. _col .. ") "
		else
			opt.prompt_title = opt.prompt_title .. " (line " .. _row .. ") "
		end
	end

	selectFileUI(options, opt)
end

-- vim.keymap.set("n", "gl", ":lua ListFilesUnderCursor()<cr>", nil)
--

local function setup(opt)
	local_opt = vim.tbl_extend("force", local_opt, opt)
end

return {
	ListFilesUnderCursor = ListFilesUnderCursor,
  setup = setup,
}
