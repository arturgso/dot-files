-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
--
vim.o.relativenumber = true

lvim.plugins = {
  { "Mofiqul/dracula.nvim" },
  { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
  { 'wakatime/vim-wakatime', lazy = false },
  {"nvim-lua/plenary.nvim", lazy = true},
{
    "CopilotC-Nvim/CopilotChat.nvim",
    dependecies = {
            "nvim-lua/plenary.nvim",
      "github/copilot.vim",
    },
    opts = {
      
    },
  },
  {
    "johnseth97/codex.nvim",
    lazy = true,
    cmd = { "Codex", "CodexToggle" },
    keys = {
      {
        "<leader>tt",
        function() require("codex").toggle() end,
        desc = "Toggle Codex popup",
      },
      opts = {
        keymaps = {
          toggle = nil,
          quit = "<C-c>",
        },
        border = "rounded",
        width = 0.8,
        height = 0.8,
        model = nil,
        autoinstall = true,
      },
      config = function(_, opts)
        require("codex").setup(opts)
      end,
    }
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufRead",
    config = function()
      require("rainbow-delimiters.setup").setup {
        strategy = {
          [''] = require('rainbow-delimiters.strategy.global'),
          vim = require('rainbow-delimiters.strategy.local'),
        },
        query = {
          [''] = 'rainbow-delimiters',
          lua = 'rainbow-blocks',
        },
        highlight = {
          'RainbowDelimiterRed',
          'RainbowDelimiterYellow',
          'RainbowDelimiterBlue',
          'RainbowDelimiterOrange',
          'RainbowDelimiterGreen',
          'RainbowDelimiterViolet',
          'RainbowDelimiterCyan',
        },
      }
    end,
  },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require('neoscroll').setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
          '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil,       -- Default easing function
        pre_hook = nil,              -- Function to run before the scrolling animation starts
        post_hook = nil,             -- Function to run after the scrolling animation ends
      })
    end
  },
  {
    "folke/persistence.nvim",
    lazy = true,          -- carrega de forma preguiçosa
    event = "BufReadPre", -- inicia o salvamento de sessão apenas ao abrir um arquivo
    config = function()
      require("persistence").setup {
        dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"),
        options = { "buffers", "curdir", "tabpages", "winsize" },
      }
    end,
  },
}

lvim.colorscheme = "moonfly"
lvim.format_on_save.enabled = false

lvim.builtin.treesitter.ensure_installed = {
  "html", "lua", "javascript", "typescript", "vue", "css", "json", "yaml", "markdown", "bash", "python", "go", "ruby",
  "rust",
}
lvim.builtin.treesitter.highlight.enabled = true

lvim.builtin.which_key.mappings["S"] = {
  name = "Session",
  c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
  l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
  Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
}

lvim.keys.normal_mode["<leader>nf"] = {
  function()
    local current_dir = vim.fn.expand("%:p:h")
    local new_file = vim.fn.input("Novo arquivo em " .. current_dir .. "/: ", "")
    if new_file ~= "" then
      vim.cmd("edit " .. current_dir .. "/" .. new_file)
    else
      print("Criação cancelada.")
    end
  end,
  desc = "Criar novo arquivo no diretório atual"
}

lvim.keys.normal_mode["<leader>jc"] = {
  function()
    local current_dir = vim.fn.expand("%:p:h")
    local class_name = vim.fn.input("Nome da classe: ", "")

    if class_name == "" then
      print("Criação cancelada.")
      return
    end

    -- Caminho completo do novo arquivo
    local file_path = current_dir .. "/" .. class_name .. ".java"

    -- Extrai o caminho a partir de src/main/java/
    local relative_path = string.match(current_dir, "src/[a-z]+/java/(.*)")
    local package_name = ""
    if relative_path then
      package_name = string.gsub(relative_path, "/", ".")
    end

    -- Cria diretórios, se necessário
    vim.fn.mkdir(current_dir, "p")

    -- Conteúdo padrão do arquivo Java
    local lines = {}
    if package_name ~= "" then
      table.insert(lines, "package " .. package_name .. ";")
      table.insert(lines, "")
    end
    table.insert(lines, "public class " .. class_name .. " {")
    table.insert(lines, "")
    table.insert(lines, "    // TODO: Implement class logic")
    table.insert(lines, "}")

    -- Escreve o arquivo e abre no editor
    vim.fn.writefile(lines, file_path)
    vim.cmd("edit " .. file_path)
  end,
  desc = "Criar nova classe Java com package automático"
}

-- lvim.transparent_window = true
