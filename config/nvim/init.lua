-- (Section 1: Options) -------------------------------------------------------
-- `:help lua-guide` or [web guide](https://neovim.io/doc/user/lua-guide.html)

do
	-- Enable faster startup by caching compiled Lua modules
	vim.loader.enable()

	--  NOTE: Must happen before plugins are loaded
	vim.g.mapleader = " "
	vim.g.maplocalleader = " m"

	-- Set to true if you have a Nerd Font installed and selected in the terminal
	vim.g.have_nerd_font = false

	-- [[ Setting options ]]
	-- See `:help vim.o` and `:help option-list`

	-- Make line numbers default
	vim.o.number = true
	vim.o.relativenumber = true

	-- Enable mouse mode, can be useful for resizing splits for example!
	vim.o.mouse = "a"

	-- Don't show the mode, since it's already in the status line
	vim.o.showmode = false

	-- Sync clipboard between OS and Neovim.
	--  Schedule the setting after `UiEnter` because it can increase startup-time.
	--  Remove this option if you want your OS clipboard to remain independent.
	--  See `:help 'clipboard'`
	-- vim.schedule(function()
	-- 	vim.o.clipboard = "unnamedplus"
	-- end)

	-- Enable break indent
	vim.o.breakindent = true

	-- Save undo history
	vim.o.undofile = true

	-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
	vim.o.ignorecase = true
	vim.o.smartcase = true

	-- Keep signcolumn on by default
	vim.o.signcolumn = "yes"

	-- Decrease update time
	vim.o.updatetime = 250

	-- Decrease mapped sequence wait time
	vim.o.timeoutlen = 300

	-- Configure how new splits should be opened
	vim.o.splitright = true
	vim.o.splitbelow = true

	-- Sets how neovim will display certain whitespace characters in the editor.
	--  See `:help 'list'`
	--  and `:help 'listchars'`
	--
	--  Notice listchars is set using `vim.opt` instead of `vim.o`.
	--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
	--   See `:help lua-options`
	--   and `:help lua-options-guide`
	vim.o.list = true
	vim.opt.listchars = { tab = "⇥ ", trail = "·", nbsp = "␣", eol = "⏎" }

	-- Preview substitutions live, as you type!
	vim.o.inccommand = "split"

	-- Show which line your cursor is on
	vim.o.cursorline = true

	-- Show a column for 80 and 120
	vim.o.colorcolumn = "80,120"

	-- Minimal number of screen lines to keep above and below the cursor.
	vim.o.scrolloff = 10

	-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
	-- instead raise a dialog asking if you wish to save the current file(s)
	-- See `:help 'confirm'`
	vim.o.confirm = true

	-- Disable the line wrapping
	vim.o.wrap = false
end

-- (Section 2: Keymaps) -------------------------------------------------------
do
	--  See `:help vim.keymap.set()`

	-- Clear highlights on search when pressing <Esc> in normal mode
	--  See `:help hlsearch`
	vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

	-- Diagnostic keymaps
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

	-- Recenter the page while scolling
	vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move up half page" })
	vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move down half page" })

	-- Easily switch between next and previous buffers
	vim.keymap.set("n", "<C-j>", ":bnext<CR>", { desc = "Next Buffer", silent = true })
	vim.keymap.set("n", "<C-k>", ":bprev<CR>", { desc = "Previous Buffer", silent = true })

	-- Easily close and force close buffers
	vim.keymap.set("n", "<leader>c", ":bdelete<CR>", { desc = "Close Buffer", silent = true })
	vim.keymap.set("n", "<leader>C", ":bdelete!<CR>", { desc = "Force Close Buffer", silent = true })

	-- Move lines that are selected in visual mode
	vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected line down" })
	vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected line up" })

	-- Allow j and k to work even with word wrap
	vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
	vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

	-- Toggle theme background
	local function toggle_background_theme()
		if vim.o.background == "light" then
			vim.cmd.colorscheme("alabastarddark")
		else
			vim.cmd.colorscheme("alabastardlight")
		end
	end
	vim.keymap.set("n", "<leader>tt", toggle_background_theme, { desc = "Toggle background theme" })

	local function toggle_line_wrap()
		if vim.opt.wrap:get() then
			vim.o.wrap = false
		else
			vim.o.wrap = true
		end
	end
	vim.keymap.set("n", "<leader>tw", toggle_line_wrap, { desc = "Toggle line wrapping" })

	-- (Basic Autocommands) -------------------------------------------------------
	--  See `:help lua-guide-autocommands`

	-- Highlight when yanking (copying) text
	--  Try it with `yap` in normal mode
	--  See `:help vim.hl.on_yank()`
	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "Highlight when yanking (copying) text",
		group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
		callback = function()
			vim.hl.on_yank()
		end,
	})
end

-- (Section 3: Plugin manager) ------------------------------------------------
-- See `:help vim.pack` and `:help vim.pack-examples`
do
	local function run_build(name, cmd, cwd)
		local result = vim.system(cmd, { cwd = cwd }):wait()
		if result.code ~= 0 then
			local stderr = result.stderr or ""
			local stdout = result.stdout or ""
			local output = stderr ~= "" and stderr or stdout
			if output == "" then
				output = "No output from build command."
			end
			vim.notify(("Build failed for %s:\n%s"):fromat(name, output), vim.log.levels.ERROR)
		end
	end

	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
				run_build(name, { "make" }, ev.data.path)
				return
			end

			if name == "LuaSnip" then
				if vim.fn.has("win32") ~= 1 and vim.fn.executable("make") == 1 then
					run_build(name, { "make", "install_jsregexp" }, ev.data.path)
				end
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				vim.cmd("TSUpdate")
				return
			end
		end,
	})
end

local function gh(repo)
	return "https://github.com/" .. repo
end

-- (Section 4: UI, core UX plugins) -------------------------------------------
do
	-- Detect tabstop and shiftwidth automatically
	vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
	require("guess-indent").setup({})

	-- Git signs in the gutter and more. See `:help gitsigns`
	vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
	require("gitsigns").setup({
		signs = {
			add = { text = "+" }, ---@diagnostic disable-line: missing-fields
			change = { text = "~" }, ---@diagnostic disable-line: missing-fields
			delete = { text = "_" }, ---@diagnostic disable-line: missing-fields
			topdelete = { text = "‾" }, ---@diagnostic disable-line: missing-fields
			changedelete = { text = "~" }, ---@diagnostic disable-line: missing-fields
		},
	})

	vim.pack.add({ gh("folke/which-key.nvim") })
	require("which-key").setup({
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },
		spec = {
			{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } }, -- Enable gitsigns recommended keymaps first
			{ "gr", group = "LSP Actions", mode = { "n" } },
		},
	})

	-- colorscheme
	vim.pack.add({ gh("mjhika/alabastard.nvim") })
	require("alabastard").setup()
	vim.cmd.colorscheme("alabastardlight")

	-- surround, autopairs, statusline, etc.
	vim.pack.add({ gh("echasnovski/mini.nvim") })

	-- Better Around/Inside textobjects
	--
	-- Examples:
	--  - va)  - [V]isually select [A]round [)]paren
	--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
	--  - ci'  - [C]hange [I]nside [']quote
	require("mini.ai").setup({
		mappings = {
			around_next = "aa",
			inside_next = "ii",
		},
		n_lines = 500,
	})

	-- Add/delete/replace surroundings (brackets, quotes, etc.)
	--
	-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
	-- - sd'   - [S]urround [D]elete [']quotes
	-- - sr)'  - [S]urround [R]eplace [)] [']
	require("mini.surround").setup()

	-- Simple and easy statusline.
	local statusline = require("mini.statusline")
	-- Set `use_icons` to true if you have a Nerd Font
	statusline.setup({ use_icons = vim.g.have_nerd_font })

	-- You can configure sections in the statusline by overriding their
	-- default behavior. For example, here we set the section for
	-- cursor location to LINE:COLUMN
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end

	-- Autopairs
	require("mini.pairs").setup({
		mappings = {
			["'"] = false,
			["`"] = false,
		},
	})

	-- Color target letters when using `f`, `t`, `F` and `T`
	vim.pack.add({ gh("deris/vim-shot-f") })
	-- require('vim-shot-f').setup()

	-- Clojure, lisp and some other REPL integrations
	vim.pack.add({
		gh("Olical/conjure"),
		gh("gpanders/nvim-parinfer"),
	})
	vim.g.parinfer_force_balance = true
	vim.g["conjure#mapping#doc_word"] = "K"
	vim.g["conjure#filetypes"] = { "clojure" }
	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("comment_config", { clear = true }),
		pattern = { "clojure" },
		callback = function()
			vim.bo.commentstring = ";; %s"
		end,
		desc = "Lisp style line comment",
	})

	vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
		group = vim.api.nvim_create_augroup("repl_is_clojure_file", { clear = true }),
		pattern = { "*.repl" },
		callback = function()
			vim.cmd([[ set ft=clojure ]])
		end,
		desc = "Associate *.repl file as a clojure filetype.",
	})
	-- require('conjure').setup()

	-- Java class decompilation
	vim.pack.add({ gh("udalov/javap-vim") })
	-- require('javap-vim').setup()

	-- tinygo support
	vim.pack.add({ gh("pcolladosoto/tinygo.nvim") })
	require("tinygo").setup({})
end

-- (Section 5: Search and Nav) ------------------------------------------------
do
	local telescope_plugins = {
		gh("nvim-lua/plenary.nvim"),
		gh("nvim-telescope/telescope.nvim"),
		gh("nvim-telescope/telescope-ui-select.nvim"),
	}
	if vim.fn.executable("make") == 1 then
		table.insert(telescope_plugins, gh("nvim-telescope/telescope-fzf-native.nvim"))
	end

	vim.pack.add(telescope_plugins)

	-- See `:help telescope` and `:help telescope.setup()`
	require("telescope").setup({
		-- You can put your default mappings / updates / etc. in here
		--  All the info you're looking for is in `:help telescope.setup()`
		--
		-- defaults = {
		--   mappings = {
		--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
		--   },
		-- },
		-- pickers = {}
		extensions = {
			["ui-select"] = { require("telescope.themes").get_dropdown() },
		},
	})

	-- Enable Telescope extensions if they are installed
	pcall(require("telescope").load_extension, "fzf")
	pcall(require("telescope").load_extension, "ui-select")

	-- See `:help telescope.builtin`
	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
	vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
	vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
	vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
	vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
	vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
	vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
	vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
	vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
	vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
	vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

	-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
	-- If you later switch picker plugins, this is where to update these mappings.
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
		callback = function(event)
			local buf = event.buf

			-- Find references for the word under your cursor.
			vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })

			-- Jump to the implementation of the word under your cursor.
			-- Useful when your language has ways of declaring types without an actual implementation.
			vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })

			-- Jump to the definition of the word under your cursor.
			-- This is where a variable was first declared, or where a function is defined, etc.
			-- To jump back, press <C-t>.
			vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })

			-- Fuzzy find all the symbols in your current document.
			-- Symbols are things like variables, functions, types, etc.
			vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Open Document Symbols" })

			-- Fuzzy find all the symbols in your current workspace.
			-- Similar to document symbols, except searches over your entire project.
			vim.keymap.set(
				"n",
				"gW",
				builtin.lsp_dynamic_workspace_symbols,
				{ buffer = buf, desc = "Open Workspace Symbols" }
			)

			-- Jump to the type of the word under your cursor.
			-- Useful when you're not sure what type a variable is and you want to see
			-- the definition of its *type*, not where it was *defined*.
			vim.keymap.set(
				"n",
				"grt",
				builtin.lsp_type_definitions,
				{ buffer = buf, desc = "[G]oto [T]ype Definition" }
			)
		end,
	})

	-- Override default behavior and theme when searching
	vim.keymap.set("n", "<leader>/", function()
		-- You can pass additional configuration to Telescope to change the theme, layout, etc.
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[/] Fuzzily search in current buffer" })

	-- It's also possible to pass additional configuration options.
	--  See `:help telescope.builtin.live_grep()` for information about particular keys
	vim.keymap.set("n", "<leader>s/", function()
		builtin.live_grep({
			grep_open_files = true,
			prompt_title = "Live Grep in Open Files",
		})
	end, { desc = "[S]earch [/] in Open Files" })

	-- Shortcut for searching your Neovim configuration files
	vim.keymap.set("n", "<leader>sn", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config"), follow = true })
	end, { desc = "[S]earch [N]eovim files" })
end

-- (Section 6: LSP) -----------------------------------------------------------
do
	-- Useful status updates for LSP.
	vim.pack.add({ gh("j-hui/fidget.nvim") })
	require("fidget").setup({})

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
		callback = function(event)
			-- NOTE: Remember that Lua is a real programming language, and as such it is possible
			-- to define small helper and utility functions so you don't have to repeat yourself.
			--
			-- In this case, we create a function that lets us more easily define mappings specific
			-- for LSP related items. It sets the mode, buffer and description for us each time.
			local map = function(keys, func, desc, mode)
				mode = mode or "n"
				vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
			end

			-- Rename the variable under your cursor.
			--  Most Language Servers support renaming across files, etc.
			map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

			-- Execute a code action, usually your cursor needs to be on top of an error
			-- or a suggestion from your LSP for this to activate.
			map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

			-- WARN: This is not Goto Definition, this is Goto Declaration.
			--  For example, in C this would take you to the header.
			map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			-- The following two autocommands are used to highlight references of the
			-- word under your cursor when your cursor rests there for a little while.
			--    See `:help CursorHold` for information about when this is executed
			--
			-- When you move your cursor, the highlights will be cleared (the second autocommand).
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			if client and client:supports_method("textDocument/documentHighlight", event.buf) then
				local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.document_highlight,
				})

				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.clear_references,
				})

				vim.api.nvim_create_autocmd("LspDetach", {
					group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
					callback = function(event2)
						vim.lsp.buf.clear_references()
						vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
					end,
				})
			end

			-- The following code creates a keymap to toggle inlay hints in your
			-- code, if the language server you are using supports them
			--
			-- This may be unwanted, since they displace some of your code
			if client and client:supports_method("textDocument/inlayHint", event.buf) then
				map("<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})

	local servers = {
		bashls = {
			-- on_init = function(client)
			--   client.server_capabilities.documentFormattingProvider = false -- Disalbe formatting (formatting is done by beautysh)
			-- end,
			-- settings = {
			--   Shell = {
			--     format = { enable = false }, -- Disable formatting (formatting is done by beautysh)
			--   },
			-- },
		},
		beautysh = {},
		clangd = {},
		["clj-kondo"] = {},
		clojure_lsp = {},
		expert = {},
		gopls = {},
		jq = {},
		zls = {},
		stylua = {}, -- Used to format Lua code

		-- Special Lua Config, as recommended by neovim help docs
		lua_ls = {
			on_init = function(client)
				client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

				if client.workspace_folders then
					local path = client.workspace_folders[1].name
					if
						path ~= vim.fn.stdpath("config")
						and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
					then
						return
					end
				end

				client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
					runtime = {
						version = "LuaJIT",
						path = { "lua/?.lua", "lua/?/init.lua" },
					},
					workspace = {
						checkThirdParty = false,
						-- NOTE: this is a lot slower and will cause issues when working on your own configuration.
						--  See https://github.com/neovim/nvim-lspconfig/issues/3189
						library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
							"${3rd}/luv/library",
							"${3rd}/busted/library",
						}),
					},
				})
			end,
			---@type lspconfig.settings.lua_ls
			settings = {
				Lua = {
					format = { enable = false }, -- Disable formatting (formatting is done by stylua)
				},
			},
		},
	}

	vim.pack.add({
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})

	-- Automatically install LSPs and related tools to stdpath for Neovim
	require("mason").setup({})

	-- Ensure the servers and tools above are installed
	--
	-- To check the current status of installed tools and/or manually install
	-- other tools, you can run
	--    :Mason
	--
	-- You can press `g?` for help in this menu.
	local ensure_installed = vim.tbl_keys(servers or {})
	vim.list_extend(ensure_installed, {
		-- You can add other tools here that you want Mason to install
	})

	require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

	for name, server in pairs(servers) do
		vim.lsp.config(name, server)
		vim.lsp.enable(name)
	end
end

-- (Section 7: Formatting) ----------------------------------------------------
do
	-- [[ Formatting ]]
	vim.pack.add({ gh("stevearc/conform.nvim") })
	require("conform").setup({
		notify_on_error = false,
		format_on_save = function(bufnr)
			-- You can specify filetypes to autoformat on save here:
			local enabled_filetypes = {
				c = true,
				clojure = true,
				elixir = true,
				go = true,
				lua = true,
			}
			if enabled_filetypes[vim.bo[bufnr].filetype] then
				return { timeout_ms = 500 }
			else
				return nil
			end
		end,
		default_format_opts = {
			lsp_format = "fallback", -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
		},
		-- You can also specify external formatters in here.
		formatters_by_ft = {
			c = { "clang_format" },
			clojure = { "clj-kondo" },
			go = { "gofmt", "goimports", "golangci-lint" },
			json = { "jq" },
			javascript = { "prettierd", "prettier", stop_after_first = true },
		},
	})

	vim.keymap.set({ "n", "v" }, "<leader>f", function()
		require("conform").format({ async = true })
	end, { desc = "[F]ormat buffer" })
end

-- (Section 8: Autocomplete and Snippets) -------------------------------------
do
	-- (Snippet engine) ---------------------------------------------------------

	-- NOTE: You can also specify plugin using a version range for its git tag.
	--  See `:help vim.version.range()` for more info
	vim.pack.add({ { src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") } })
	require("luasnip").setup({})

	-- `friendly-snippets` contains a variety of premade snippets.
	--    See the README about individual language/framework/plugin snippets:
	--    https://github.com/rafamadriz/friendly-snippets
	vim.pack.add({ gh("rafamadriz/friendly-snippets") })
	require("luasnip.loaders.from_vscode").lazy_load()

	-- (Autocomplete Engine) ----------------------------------------------------
	vim.pack.add({ { src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") } })
	require("blink.cmp").setup({
		keymap = {
			-- 'default' (recommended) for mappings similar to built-in completions
			--   <c-y> to accept ([y]es) the completion.
			--    This will auto-import if your LSP supports it.
			--    This will expand snippets if the LSP sent a snippet.
			-- 'super-tab' for tab to accept
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- For an understanding of why the 'default' preset is recommended,
			-- you will need to read `:help ins-completion`
			--
			-- No, but seriously. Please read `:help ins-completion`, it is really good!
			--
			-- All presets have the following mappings:
			-- <tab>/<s-tab>: move to right/left of your snippet expansion
			-- <c-space>: Open menu or open docs if already open
			-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
			-- <c-e>: Hide menu
			-- <c-k>: Toggle signature help
			--
			-- See `:help blink-cmp-config-keymap` for defining your own keymap
			preset = "default",
		},

		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},

		completion = {
			-- By default, you may press `<c-space>` to show the documentation.
			-- Optionally, set `auto_show = true` to show the documentation after a delay.
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},

		sources = {
			default = { "lsp", "path", "snippets" },
		},

		snippets = { preset = "luasnip" },

		-- Could use the rust implementation via `'prefer_rust_with_warning'`
		-- See `:help blink-cmp-config-fuzzy` for more information
		fuzzy = { implementation = "lua" },

		-- Shows a signature help window while you type arguments for a function
		signature = { enabled = true },
	})
end

-- (Section 9: Treesitter) ----------------------------------------------------
do
	-- (Configure Treesitter) ---------------------------------------------------
	--  Used to highlight, edit, and navigate code
	--
	--  See `:help nvim-treesitter-intro`

	-- NOTE: You can also specify a branch or a specific commit
	vim.pack.add({ { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" } })

	-- Ensure basic parsers are installed
	local parsers = {
		"bash",
		"c",
		"clojure",
		"diff",
		"elixir",
		"go",
		"html",
		"lua",
		"luadoc",
		"markdown",
		"markdown_inline",
		"query",
		"vim",
		"vimdoc",
	}
	require("nvim-treesitter").install(parsers)

	---@param buf integer
	---@param language string
	local function treesitter_try_attach(buf, language)
		-- Check if a parser exists and load it
		if not vim.treesitter.language.add(language) then
			return
		end
		-- Enable syntax highlighting and other treesitter features
		vim.treesitter.start(buf, language)

		-- Enable treesitter based folds
		-- For more info on folds see `:help folds`
		-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
		-- vim.wo.foldmethod = 'expr'

		-- Check if treesitter indentation is available for this language, and if so enable it
		-- in case there is no indent query, the indentexpr will fallback to the vim's built in one
		local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

		-- Enable treesitter based indentation
		if has_indent_query then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end

	local available_parsers = require("nvim-treesitter").get_available()
	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local buf, filetype = args.buf, args.match

			local language = vim.treesitter.language.get_lang(filetype)
			if not language then
				return
			end

			local installed_parsers = require("nvim-treesitter").get_installed("parsers")

			if vim.tbl_contains(installed_parsers, language) then
				-- Enable the parser if it is already installed
				treesitter_try_attach(buf, language)
			elseif vim.tbl_contains(available_parsers, language) then
				-- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
				require("nvim-treesitter").install(language):await(function()
					treesitter_try_attach(buf, language)
				end)
			else
				-- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
				treesitter_try_attach(buf, language)
			end
		end,
	})
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
