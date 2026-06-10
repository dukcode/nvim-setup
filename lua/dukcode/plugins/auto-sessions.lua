return {
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup({
      -- 자동 세션 복원 비활성화. nvim을 열 때마다 무조건 직전 세션을
      -- 복원하면 의도치 않은 버퍼가 떠서 산만하므로, 복원은 명시적으로
      -- <leader>wr (SessionRestore)를 눌렀을 때만 한다.
      auto_restore = false,

      -- 아래 디렉토리에서 nvim을 열면 세션 저장/복원을 하지 않는다.
      -- 홈/다운로드 같은 범용 디렉토리에서 세션이 만들어지면 다른 프로젝트
      -- 세션과 섞여 관리가 어려워지기 때문.
      suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
    })

    -- 세션 복원 후 filetype/하이라이트가 정상 복구되려면 sessionoptions에
    -- 'localoptions'가 포함되어야 한다. auto-session 공식 권장값이며,
    -- 빠뜨릴 경우 복원된 버퍼에서 트리시터 하이라이트가 꺼져 보일 수 있다.
    vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

    local keymap = vim.keymap

    keymap.set("n", "<leader>wr", "<cmd>SessionRestore<CR>", { desc = "Restore session for cwd" })
    keymap.set("n", "<leader>ws", "<cmd>SessionSave<CR>", { desc = "Save session for auto session root dir" })
  end,
}
