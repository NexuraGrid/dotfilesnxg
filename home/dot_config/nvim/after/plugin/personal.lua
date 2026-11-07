-- Personal additions on top of the craftzdog config.
-- after/plugin runs once init.lua is done, so this file extends the upstream
-- setup without editing it and nothing upstream can overwrite these changes.

-- Key discovery: press <leader> and pause to see what is available.
vim.pack.add({ "https://github.com/folke/which-key.nvim" }, { load = true, confirm = false })
local which_key = require("which-key")
which_key.setup({ preset = "helix" })
which_key.add({
	{ "<leader>c", group = "code" },
	{ "<leader>d", group = "diff" },
	{ "<leader>g", group = "git" },
	{ "<leader>y", group = "yank path" },
})

-- Language tooling. Installed directly through the registry because
-- mason-tool-installer replaces its list on a second setup() call.
local tools = {
	"angular-language-server",
	"basedpyright",
	"blade-formatter",
	"css-lsp",
	"goimports",
	"gopls",
	"html-lsp",
	"intelephense",
	"ruff",
	"vue-language-server",
}
local registry = require("mason-registry")
registry.refresh(function()
	for _, name in ipairs(tools) do
		if not registry.is_installed(name) then
			registry.get_package(name):install()
		end
	end
end)

vim.g.personal_mason_tools = tools

-- Parsers need the tree-sitter CLI, which Mason installs on a fresh machine.
local parsers = { "blade", "gomod", "gosum", "gowork", "phpdoc", "vue" }
vim.g.personal_parsers = parsers
if vim.fn.executable("tree-sitter") == 1 then
	require("nvim-treesitter").install(parsers)
else
	vim.api.nvim_create_autocmd("User", {
		pattern = "MasonToolsUpdateCompleted",
		once = true,
		callback = function()
			require("nvim-treesitter").install(parsers)
		end,
	})
end

-- Vue types are served by vtsls through this plugin; vue_ls handles the rest.
vim.lsp.config("vtsls", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
	},
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					{
						name = "@vue/typescript-plugin",
						location = vim.fn.stdpath("data")
							.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
						languages = { "vue" },
						configNamespace = "typescript",
						enableForWorkspaceTypeScriptVersions = true,
					},
				},
			},
		},
	},
})

-- Without a root_dir callback angularls starts in every TS, TSX and HTML buffer.
vim.lsp.config("angularls", {
	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, { "angular.json", "nx.json" })
		if root then
			on_dir(root)
		end
	end,
})

vim.lsp.config("html", { filetypes = { "html", "templ", "blade" } })

-- PHP has no host formatter (PHP runs in Docker), so conform would fall back to
-- intelephense on save and rewrite code style the project never asked for.
vim.lsp.config("intelephense", { settings = { intelephense = { format = { enable = false } } } })

vim.lsp.enable({
	"angularls",
	"basedpyright",
	"gopls",
	"html",
	"intelephense",
	"ruff",
	"vue_ls",
})

-- Formatters. Web filetypes reuse the upstream oxfmt > prettierd > prettier chain.
local conform = require("conform")
local web_formatters = conform.formatters_by_ft.html
conform.formatters_by_ft.blade = { "blade-formatter" }
conform.formatters_by_ft.go = { "goimports", "gofmt" }
conform.formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
conform.formatters_by_ft.rust = { "rustfmt" }
conform.formatters_by_ft.vue = web_formatters

-- Restore standard Vim behavior.
vim.keymap.del("n", "dw") -- Upstream makes it delete backwards.
vim.keymap.del("n", "<C-m>") -- Terminals send <C-m> for Enter, so Enter was jumping.
-- <Tab> is tabnext and terminals send it for <C-i>, so jump forward needs its own key.
vim.keymap.set("n", "<M-o>", "<C-i>", { desc = "Jump forward" })
