-- Run headless after a fresh install: keeps Neovim open until the background
-- Mason and Treesitter installs have finished, then quits.
local TIMEOUT_MS = 15 * 60 * 1000
local POLL_MS = 5000
local IDLE_POLLS = 6

local started_at = vim.uv.now()
local last_total = -1
local idle_polls = 0

local function mason_is_busy(registry)
	for _, package in ipairs(registry.get_all_packages()) do
		if package:is_installing() then
			return true
		end
	end
	return false
end

local timer = assert(vim.uv.new_timer())
timer:start(
	POLL_MS,
	POLL_MS,
	vim.schedule_wrap(function()
		local registry = require("mason-registry")
		local mason_total = #registry.get_installed_package_names()
		local parser_total = #require("nvim-treesitter").get_installed("parsers")
		local total = mason_total + parser_total

		local busy = mason_is_busy(registry) or total ~= last_total
		idle_polls = busy and 0 or idle_polls + 1
		last_total = total

		local finished = mason_total > 0 and idle_polls >= IDLE_POLLS
		if finished or vim.uv.now() - started_at > TIMEOUT_MS then
			print(("\nMason packages: %d, parsers: %d"):format(mason_total, parser_total))
			vim.cmd("qa!")
		end
	end)
)
