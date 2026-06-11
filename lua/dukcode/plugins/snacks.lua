return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = {
      enabled = true,
      doc = {
        -- 커서가 이미지 라인 위에 있을 때 인라인으로 띄움
        inline = true,
        float = true,
        max_width = 80,
        max_height = 40,
      },
      -- [특수] Obsidian vault 전용 resolver.
      -- 해당 vault는 "파일별 첨부 폴더" 규칙을 쓰기 때문에 ![](img.png) 같은
      -- 파일명만 적힌 src를 <md_dir>/assets/<md_stem>/img.png 로 매핑해야 한다.
      -- vault 바깥 마크다운은 nil을 반환해 snacks 기본 resolver를 그대로 쓴다.
      resolve = function(file, src)
        local OBSIDIAN_ROOT = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents")
        if not vim.startswith(file, OBSIDIAN_ROOT) then
          return nil
        end
        if src:match("^/") or src:match("^~") or src:match("^%a+://") then
          return nil
        end
        local md_dir = vim.fs.dirname(file)
        local md_stem = vim.fn.fnamemodify(file, ":t:r")
        local candidate = md_dir .. "/assets/" .. md_stem .. "/" .. src
        if vim.uv.fs_stat(candidate) then
          return candidate
        end
        return nil
      end,
    },
  },
}
