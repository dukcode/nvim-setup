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
  config = function(_, opts)
    require("snacks").setup(opts)

    -- [snacks 이미지 뷰어 버그 완화]
    -- snacks는 이미지 파일을 일반 파일 버퍼(buftype="")로 연다. 변환이 필요한
    -- 이미지(jpg/heic/pdf 등)는 로딩 스피너가 nvim_buf_set_lines로 버퍼를 건드린 뒤
    -- modified=false를 복구하지 않아 버퍼가 "수정됨"으로 남고 :q! 없이 못 나간다.
    -- 또 재방문 시 낡은 버퍼/placement를 재사용하다 재렌더에 실패해 로딩만 도는데,
    -- 떠날 때 버퍼를 wipe해서 다음 조회 때 캐시된 변환 결과로 깨끗이 재-attach시킨다.
    local grp = vim.api.nvim_create_augroup("dukcode_snacks_image_fix", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = grp,
      pattern = "image",
      callback = function(ev)
        vim.bo[ev.buf].bufhidden = "wipe"
      end,
    })
    vim.api.nvim_create_autocmd("BufModifiedSet", {
      group = grp,
      callback = function(ev)
        if vim.bo[ev.buf].filetype == "image" and vim.bo[ev.buf].modified then
          vim.bo[ev.buf].modified = false
        end
      end,
    })
  end,
}
