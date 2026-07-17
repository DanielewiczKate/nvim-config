


--[[
local reg = require("plugins.reg-edit")
local registers = reg.read_registers();
reg.print_registers(registers)
]]--


-- Disable any custom tagfunc filtering
-- vim.o.tagfunc = ""
vim.opt.grepformat = "%f:%l:%c:%m"

vim.wo.relativenumber = true
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.wrap = true
vim.o.ignorecase = true
vim.o.number = true
vim.opt.smartcase = true
require("config.lazy")
require("abbrs")
vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
vim.keymap.set('n',               'S', '<Plug>(leap-from-window)')

-- Move cursor with Alt + hjkl
-- Using 'g' prefix ensures movement follows wrapped lines (visual lines)
vim.keymap.set("i", "<A-h>", "<Left>")
vim.keymap.set("i", "<A-j>", "<C-o>gj")
vim.keymap.set("i", "<A-k>", "<C-o>gk")
vim.keymap.set("i", "<A-l>", "<Right>")


vim.o.guifont = "Departure Mono Nerd Font Propo Regular:h12"

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    -- 1. Turn off hard wrapping (no auto-inserting new lines)
    vim.opt_local.textwidth = 0
    vim.opt_local.wrapmargin = 0

    -- 2. Enable visual wrapping
    vim.opt_local.wrap = true

    -- 3. Break lines at words, not in the middle of a word
    vim.opt_local.linebreak = true

    -- 4. Don't break lines inside a paragraph when editing midline
    -- 'l' ensures long lines are not broken in insert mode
    vim.opt_local.formatoptions:remove("t")
    
    -- 5. Keep indentation for wrapped lines (makes it look cleaner)
    vim.opt_local.breakindent = true
  end,
})

local themes = {
  "pasteldark", "tokyonight-night", "pastelnight", 
  "pastelwarm", "tokyonight-storm", "",
  "", "tokyonight-day", "pink-panic"
}

local function set_theme(idx)
  if themes[idx] then
    vim.cmd("colorscheme " .. themes[idx])
    print("Theme set to: " .. themes[idx])
  end
end

for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i , function()
    set_theme(i)
  end, { desc = "Set theme to " .. (themes[i] or i) })
end

opts = { noremap = true, silent = true }

-- Window navigation using <leader> + hjkl
vim.api.nvim_set_keymap('n', '<leader>h', '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<leader>j', '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<leader>k', '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<leader>l', '<C-w>l', opts)

-- Tab navigation
vim.api.nvim_set_keymap('n', '<leader>d', ':tabprevious<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', ':tabnext<CR>', { noremap = true, silent = true })

-- Tab Movement
vim.api.nvim_set_keymap('n', '<leader><<', ':-tabmove<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>>>', ':+tabmove<CR>', opts)

-- Tab creation and deletion
vim.api.nvim_set_keymap('n', '<leader>v', ':tabnew<CR>', { noremap = true, silent = true })   -- new tab
vim.api.nvim_set_keymap('n', '<leader>c', ':tabclose<CR>', { noremap = true, silent = true }) -- close tab


vim.api.nvim_set_keymap(
  'n',
  '<leader>yr',
  ':execute "let @" . v:register . " = expand(\'%\')" <CR>',
  opts
)



-- Create a namespace for your semi-permanent marks
local vesc_ns = vim.api.nvim_create_namespace('vesc_highlights')

-- Function to highlight the current visual selection
function Highlight_Block()
    local _, s_line, _, _ = unpack(vim.fn.getpos("'<"))
    local _, e_line, _, _ = unpack(vim.fn.getpos("'>"))
    
    -- Iterate through the selected lines
    for i = s_line - 1, e_line - 1 do
        vim.api.nvim_buf_set_extmark(0, vesc_ns, i, 0, {
            line_hl_group = 'DiffAdd', -- Uses your theme's visual selection color
            -- You can also use 'DiffAdd' (green) or 'DiffDelete' (red)
        })
    end
end

-- Function to clear all custom highlights
function Clear_Highlights()
    vim.api.nvim_buf_clear_namespace(0, vesc_ns, 0, -1)
end

-- Mappings
vim.keymap.set('v', '<leader>n', ':lua Highlight_Block()<CR>', { silent = true })
vim.keymap.set('n', '<leader>N', ':lua Clear_Highlights()<CR>', { silent = true })




 -- Show diagnostic popup on hover
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Show line diagnostics" })       

-- Jump to the NEXT error/warning
vim.keymap.set('n', '<leader>r', vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })

-- Jump to the PREVIOUS error/warning
vim.keymap.set('n', '<leader>w', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })

vim.opt.tags = "./tags;"
vim.opt.grepprg = "rg --vimgrep --smart-case"

vim.api.nvim_create_user_command('Grepsrc', function(opts)
  local tb = require('telescope.builtin')
  tb.live_grep({ search_dirs = {"src"} })
end, { nargs = "*" })

-- Toggle relative line numbers with <C-s>
vim.keymap.set("n", "<C-s>", function()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
  else
    vim.wo.relativenumber = true
  end
end, { noremap = true, silent = true })

-- Visual mode mapping: "fg" greps the current visual selection
vim.keymap.set("n", "<leader>ag", function()

  require("telescope.builtin").grep_string({""})

end, { noremap = true, silent = true, desc = "Grep normal selection" })



vim.keymap.set("n", "<leader>af", function()

  require("telescope.builtin").find_files({ })

end, { noremap = true, silent = true, desc = "Find normal selection" })

-- Visual mode mapping: "fg" greps the current visual selection
vim.keymap.set("v", "<leader>ag", function()
  -- Get the selected text
  vim.cmd('normal! "zy')
  local selection = vim.fn.getreg("z")

  require("telescope.builtin").grep_string({ search = selection })

end, { noremap = true, silent = true, desc = "Grep visual selection" })



vim.keymap.set("v", "<leader>af", function()
  -- Get the selected text
  vim.cmd('normal! "zy')
  local selection = vim.fn.getreg("z")

  require("telescope.builtin").find_files({ default_text = selection })

end, { noremap = true, silent = true, desc = "Find visual selection" })



