-- Helper function to read the file
local function get_ascii_art(filepath)
    local lines = {}
    -- Use stdpath("config") to find your nvim folder automatically
    local path = vim.fn.stdpath("config") .. "/" .. filepath
    local f = io.open(path, "r")
    if not f then 
        return { "File not found: " .. path } 
    end
    for line in f:lines() do
        table.insert(lines, line)
    end
    f:close()
    return lines
end

local settings = {
  header = {
    type = "text",
    oldfiles_directory = false,
    align = "center",
    fold_section = false,
    title = "Aquarium",
    margin = 5,
    -- This calls the function to grab your text file
    content = get_ascii_art("spash.txt"), 
    highlight = "Statement",
    default_color = "#89b4fa",
  },
  body = {
    type = "mapping",
    align = "center",
    content = {
      { "󰈞 Find File", "Telescope find_files", "<leader>ff" },
      { "󰊄 Recent Files", "Telescope oldfiles", "<leader>fo" },
      { "󰒓 Settings", "edit $MYVIMRC", "<leader>fc" },
      { "󰈆 Quit", "qa", "<leader>fq" },
    },
    highlight = "String",
    default_color = "#94e2d5",
  },
  options = {
    mapping_keys = true,
    cursor_column = 0.5,
    empty_lines_between_mappings = true,
    disable_statuslines = true,
    paddings = { 2, 2 },
  },
  mappings = {
    execute_command = "<CR>",
    open_file = "o",
    open_file_split = "<c-o>",
    open_section = "<TAB>",
    open_help = "?",
  },
  parts = { "header", "body" },
}

return settings
