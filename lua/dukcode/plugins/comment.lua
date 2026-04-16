return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    -- CursorHold autocmd를 비활성화하여 treesitter parser가 없는 버퍼에서
    -- language_tree nil 에러가 발생하는 것을 방지한다.
    -- 대신 Comment.nvim의 pre_hook을 통해 주석 시점에만 commentstring을 계산한다.
    require("ts_context_commentstring").setup({
      enable_autocmd = false,
    })

    -- pre_hook: 주석 토글 시 ts_context_commentstring을 호출하여
    -- tsx, jsx, svelte, html 등 embedded language의 commentstring을 자동 결정한다.
    require("Comment").setup({
      pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
    })
  end,
}
