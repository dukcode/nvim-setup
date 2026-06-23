return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")
    local api = require("nvim-tree.api")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- auto close
    vim.api.nvim_create_autocmd("BufEnter", {
      nested = true,
      callback = function()
        if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
          vim.cmd "quit"
        end
      end
    })

    -- IntelliJ 스타일 ESC: 트리 닫지 않고 직전 창으로 포커스만 이동
    local function on_attach(bufnr)
      api.config.mappings.default_on_attach(bufnr)
      vim.keymap.set("n", "<Esc>", function()
        vim.cmd("wincmd p")
      end, { buffer = bufnr, desc = "Focus previous window (keep tree open)" })
    end

    nvimtree.setup({
      on_attach = on_attach,
      view = {
        width = 35,
        relativenumber = true,
      },
      -- change folder arrow icons
      renderer = {
        group_empty = true, -- compact middle empty package
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "", -- arrow when folder is closed
              arrow_open = "", -- arrow when folder is open
            },
          },
        },
      },
      -- disable window_picker for
      -- explorer to work well with
      -- window splits
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        custom = { ".DS_store" },
      },
      git = {
        ignore = false,
      },
    })

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
    keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) -- toggle file explorer on current file
    keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
    keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer

    -- IntelliJ 스타일 cmd+1: 트리 포커스 토글
    -- 터미널이 Kitty keyboard protocol로 Cmd+1을 그대로 전달, nvim은 <D-1>로 수신.
    -- - 문서에서 누르면 트리 열고 포커스 (이미 열려있으면 포커스만)
    -- - 트리에서 누르면 트리 닫고 직전 문서로 포커스
    local function smart_tree_focus_toggle()
      if vim.bo.filetype == "NvimTree" then
        api.tree.close()
      elseif api.tree.is_visible() then
        api.tree.focus()
      else
        api.tree.open()
      end
    end
    -- <D-1>: GUI(neovide 등)에서 Cmd+1 직접 수신
    -- <M-1>: 터미널(ghostty→tmux)에서 Cmd+1을 ESC+1로 변환해 전달받는 경로
    keymap.set("n", "<D-1>", smart_tree_focus_toggle, { desc = "Toggle focus nvim-tree (IntelliJ style)" })
    keymap.set("n", "<M-1>", smart_tree_focus_toggle, { desc = "Toggle focus nvim-tree (IntelliJ style)" })
  end
}
