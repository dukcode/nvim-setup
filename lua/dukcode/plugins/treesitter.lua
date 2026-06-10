return {
  "nvim-treesitter/nvim-treesitter",
  -- nvim-treesitter main 브랜치는 lazy-loading을 지원하지 않는다.
  lazy = false,
  branch = "main",
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local parsers = {
      "json",
      "javascript",
      "typescript",
      "tsx",
      "yaml",
      "html",
      "css",
      "prisma",
      "markdown",
      "markdown_inline",
      "svelte",
      "graphql",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      "gitignore",
      "query",
      "vimdoc",
      "c",
      "kotlin",
    }

    -- 파서/쿼리 설치. async이고 이미 설치된 것은 no-op.
    require("nvim-treesitter").install(parsers)

    -- main 브랜치는 setup 옵션으로 highlight/indent를 켤 수 없어서
    -- FileType autocmd에서 직접 활성화해야 한다.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if not pcall(vim.treesitter.start, args.buf) then
          return
        end
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- autotag는 별도 플러그인이며 자체 setup을 호출해야 한다.
    require("nvim-ts-autotag").setup({})

    -- NOTE: 기존 incremental_selection 옵션은 nvim-treesitter main 브랜치에서
    -- 제거되었다. 필요하면 vim.treesitter API로 직접 keymap을 구현하거나
    -- 대체 플러그인을 사용하면 된다.
  end,
}
