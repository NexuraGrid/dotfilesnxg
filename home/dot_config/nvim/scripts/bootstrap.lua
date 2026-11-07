-- Run headless after a fresh install: keeps Neovim open until the background
-- Mason and Treesitter installs have finished, retries anything missing once,
-- and exits non-zero naming what could not be installed.
local TIMEOUT_MS = 15 * 60 * 1000
local POLL_MS = 2000
local IDLE_POLLS = 5

local started_at = vim.uv.now()
local last_total = -1
local idle_polls = 0
local retried = false

local function mason_is_busy(registry)
	for _, package in ipairs(registry.get_all_packages()) do
		if package:is_installing() then
			return true
		end
	end
	return false
end

local function missing_tools(registry)
	return vim.tbl_filter(function(name)
		return not registry.is_installed(name)
	end, vim.g.personal_mason_tools or {})
end

local function missing_parsers()
	local installed = require("nvim-treesitter").get_installed("parsers")
	return vim.tbl_filter(function(name)
		return not vim.list_contains(installed, name)
	end, vim.g.personal_parsers or {})
end

local function retry(registry, tools, parsers)
	print("\nRetrying: " .. table.concat(vim.list_extend(vim.list_slice(tools), parsers), ", "))
	for _, name in ipairs(tools) do
		registry.get_package(name):install({}, function(success, result)
			if not success then
				print(("\n%s failed: %s"):format(name, vim.inspect(result)))
			end
		end)
	end
	if #parsers > 0 then
		require("nvim-treesitter").install(parsers)
	end
end

local function finish(tools, parsers, mason_total, parser_total)
	print(("\nMason packages: %d, parsers: %d"):format(mason_total, parser_total))
	if #tools + #parsers == 0 then
		vim.cmd("qa!")
	end
	print("Missing: " .. table.concat(vim.list_extend(vim.list_slice(tools), parsers), ", "))
	vim.cmd("cquit 1")
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

		local timed_out = vim.uv.now() - started_at > TIMEOUT_MS
		if not timed_out and (mason_total == 0 or idle_polls < IDLE_POLLS) then
			return
		end

		local tools, parsers = missing_tools(registry), missing_parsers()
		if not timed_out and not retried and #tools + #parsers > 0 then
			retried = true
			idle_polls = 0
			retry(registry, tools, parsers)
			return
		end
		finish(tools, parsers, mason_total, parser_total)
	end)
)
