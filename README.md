# nvim-setup

개인 Neovim 설정. `lazy.nvim` 기반 모듈형 구조이며 macOS + WezTerm 환경을 기준으로 한다.
일부 IntelliJ 스타일 단축키를 포함한다.

---

## 빠른 시작

```sh
# 1. 시스템 의존성 설치
# 주의: tree-sitter CLI는 tree-sitter-cli 패키지 (tree-sitter는 라이브러리만 설치됨)
brew install tree-sitter-cli node ripgrep fd
brew install --cask font-d2coding-ligature-nerd-font

# 2. 설정 클론
git clone https://github.com/dukcode/nvim-setup.git ~/.config/nvim

# 3. 실행 — 첫 구동 시 lazy.nvim이 자동 부트스트랩
nvim
```

WezTerm을 쓴다면 `~/.config/wezterm/wezterm.lua`에 다음 한 줄을 추가해야 `Cmd+1` 단축키가 동작한다.
[IntelliJ 스타일 단축키](#intellij-스타일-단축키) 참고.

---

## 시스템 요구사항

### 필수

| 항목 | 버전 / 비고 |
|---|---|
| Neovim | **0.10.4 이상** (telescope v0.2.x 요구) |
| OS | macOS (Cmd 키 매핑이 의존) |
| 폰트 | Nerd Font (기본값 `D2CodingLigature Nerd Font Propo`) |

### CLI 의존성

| 카테고리 | 도구 | 용도 |
|---|---|---|
| 빌드 | `git` | 플러그인 clone, gitsigns 상태 |
| 빌드 | `cc` / `make` | telescope-fzf-native, LuaSnip jsregexp, treesitter 파서 |
| 빌드 | `tree-sitter` CLI (= `tree-sitter-cli` 패키지) | treesitter `main` 브랜치 파서 빌드 (**필수**). `brew install tree-sitter`는 라이브러리만 설치하므로 CLI 부재 — `tree-sitter-cli`를 따로 설치해야 한다 |
| 빌드 | `node` | 일부 treesitter 파서(tsx, svelte 등) 생성 |
| 런타임 | `ripgrep` (`rg`) | telescope live_grep, todo-comments |
| 런타임 | `fd` | telescope find_files 가속 (선택) |

### 권장 터미널

WezTerm. `Cmd+숫자` 키 변환 매핑을 사용하려면 필수. 다른 터미널을 쓴다면
[`<M-1>`을 다른 키로 교체](#커스텀-단축키-변경)하면 된다.

---

## 디렉토리 구조

```
init.lua                       엔트리. core + lazy 로드
lua/dukcode/
├── core/
│   ├── init.lua               options + keymaps 로더
│   ├── options.lua            vim.opt 글로벌 옵션
│   └── keymaps.lua            플러그인 무관 전역 키맵
├── lazy.lua                   lazy.nvim 부트스트랩 + 플러그인 import
└── plugins/                   개별 플러그인 스펙 (한 파일 = 한 플러그인)
```

`plugins/` 안의 각 파일은 lazy.nvim 스펙(`return { ... }`)을 반환한다.
`lazy.lua`가 `{ import = "dukcode.plugins" }`로 일괄 로드한다.

---

## 키맵 치트시트

Leader 키는 **스페이스**(` `).

### IntelliJ 스타일 단축키

| 상황 | 키 | 동작 |
|---|---|---|
| 문서 포커스 | `Cmd+1` | 트리 열고 포커스 (이미 열려있으면 포커스만) |
| 트리 포커스 | `Cmd+1` | 트리 닫고 직전 문서로 포커스 |
| 트리 포커스 | `Esc` | 트리 유지, 직전 창으로 포커스만 이동 |

WezTerm이 `Cmd+1`을 `Alt+1`로 변환해서 nvim에 전달한다. WezTerm 설정:

```lua
config.keys = {
  { key = '1', mods = 'CMD', action = wezterm.action.SendKey { key = '1', mods = 'ALT' } },
}
```

부수효과: WezTerm 기본 `Cmd+1`(첫 탭 활성화)은 가려진다.

### 파일 / 탐색

| 키 | 동작 |
|---|---|
| `<leader>ff` | 파일 검색 (Telescope find_files) |
| `<leader>fr` | 최근 파일 |
| `<leader>fs` | 라이브 grep |
| `<leader>fc` | 커서 단어 grep |
| `<leader>ft` | TODO 검색 |
| `<leader>ee` | nvim-tree 토글 |
| `<leader>ef` | 현재 파일 위치로 트리 |
| `<leader>ec` | 트리 접기 |
| `<leader>er` | 트리 새로고침 |

### 창 / 탭

| 키 | 동작 |
|---|---|
| `<leader>sv` / `<leader>sh` | 창 수직 / 수평 분할 |
| `<leader>se` / `<leader>sx` | 분할 크기 균등화 / 닫기 |
| `<leader>sm` | 분할 최대화 토글 |
| `<leader>to` / `<leader>tx` | 탭 새로 / 닫기 |
| `<leader>tn` / `<leader>tp` | 다음 / 이전 탭 |
| `<leader>tf` | 현재 버퍼를 새 탭으로 |

> bufferline은 `mode = "tabs"`라 상단 탭바는 **vim tabpage**를 보여준다.
> nvim-tree에서 `<CR>`은 현재 탭의 파일을 갈아치우고, **`t`를 누르면 새 탭으로 연다** (`T`는 백그라운드 새 탭).

### Git (gitsigns)

| 키 | 동작 |
|---|---|
| `]h` / `[h` | 다음 / 이전 hunk |
| `<leader>hs` / `<leader>hr` | hunk stage / reset (visual 영역 지원) |
| `<leader>hS` / `<leader>hR` | 버퍼 전체 stage / reset |
| `<leader>hu` | stage 취소 |
| `<leader>hp` | hunk 미리보기 |
| `<leader>hb` / `<leader>hB` | 라인 blame / 전체 라인 blame 토글 |
| `<leader>hd` / `<leader>hD` | diff this / diff this ~ |
| `ih` | hunk 텍스트 오브젝트 |

### 세션 / 기타

| 키 | 동작 |
|---|---|
| `<leader>wr` / `<leader>ws` | 세션 복원 / 저장 |
| `<leader>nh` | 검색 하이라이트 해제 |
| `<leader>+` / `<leader>-` | 숫자 증감 |
| `]t` / `[t` | 다음 / 이전 TODO |

### 자동완성 (인서트 모드)

| 키 | 동작 |
|---|---|
| `<C-p>` / `<C-n>` | 이전 / 다음 후보 |
| `<C-b>` / `<C-f>` | 문서 스크롤 |
| `<C-Space>` | 후보 표시 |
| `<C-e>` | 닫기 |
| `<CR>` | 확정 (자동 선택 없음) |

### Telescope 내부

| 키 | 동작 |
|---|---|
| `<C-j>` / `<C-k>` | 다음 / 이전 결과 |
| `<C-q>` | 선택 항목을 quickfix로 |

---

## 핵심 커스터마이징

> "왜 이렇게 했는지" 위주로 정리한 메모.

### 1. nvim-treesitter `main` 브랜치

- `master`가 아닌 `main` 브랜치 사용.
- `main`은 lazy-loading 불가 → `lazy = false`.
- `setup({ highlight, indent })` 옵션 제거됨 → `FileType` autocmd에서 `vim.treesitter.start()` + `indentexpr` 직접 활성화.
- `incremental_selection`은 제거됨. 필요 시 별도 매핑 작성.

### 2. telescope `^0.2.0` 고정

- v0.2부터 nvim-treesitter 의존성 제거 → treesitter `main` 브랜치와 호환.
- Neovim **0.10.4 이상** 필수.

### 3. Comment.nvim + ts-context-commentstring

`CursorHold` autocmd가 treesitter 파서 없는 버퍼에서 `language_tree nil` 에러 발생.

→ `enable_autocmd = false`로 끄고 `Comment.nvim`의 `pre_hook`에서만 commentstring 계산.

### 4. auto-session 자동 복원 끔

- `auto_restore = false` — nvim 열 때마다 자동 복원하지 않음. `<leader>wr`로 명시적 복원만.
- `suppressed_dirs`: `~`, `~/Dev/`, `~/Downloads`, `~/Documents`, `~/Desktop/`은 세션 저장/복원 제외.
- `sessionoptions`에 `localoptions` 포함 — 복원 후 treesitter 하이라이트 꺼짐 방지.

### 5. tokyonight / lualine 팔레트

- tokyonight: `night` 스타일 + BG/FG 커스텀 + transparent.
- lualine: `my_lualine_theme` 직접 정의 + lazy 업데이트 카운트 표시.

### 6. 전역 옵션 요약 (`core/options.lua`)

| 옵션 | 값 |
|---|---|
| `number` | on (relativenumber은 off) |
| `tabstop` / `shiftwidth` | 2 / 2, `expandtab` |
| `wrap` | off |
| `ignorecase` + `smartcase` | on |
| `clipboard` | `unnamedplus` 추가 (시스템 클립보드) |
| `splitright` / `splitbelow` | on |
| `termguicolors` | on |
| `signcolumn` | `yes` (고정) |

---

## 플러그인 카탈로그

### UI / 테마

| 플러그인 | 역할 |
|---|---|
| `folke/tokyonight.nvim` | 컬러스킴. `night` + 커스텀 팔레트, transparent |
| `nvim-lualine/lualine.nvim` | 상태줄. 커스텀 테마 + lazy 업데이트 카운트 |
| `akinsho/bufferline.nvim` | 버퍼라인. `mode = "tabs"` — vim tabpage 표시 |
| `goolord/alpha-nvim` | 시작 대시보드. 커스텀 헤더/메뉴 |
| `stevearc/dressing.nvim` | `vim.ui.select` / `input` 개선 |
| `lukas-reineke/indent-blankline.nvim` | 들여쓰기 가이드 (`┊`) |
| `nvim-tree/nvim-web-devicons` | 파일 아이콘 (공통 의존성) |

### 탐색

| 플러그인 | 역할 |
|---|---|
| `nvim-tree/nvim-tree.lua` | 파일 트리. IntelliJ 스타일 매핑 |
| `nvim-telescope/telescope.nvim` | 퍼지 파인더 (v0.2.x 고정) |
| `nvim-telescope/telescope-fzf-native.nvim` | telescope 정렬 가속 |
| `folke/todo-comments.nvim` | TODO/FIX 하이라이트 + 점프 |

### 편집

| 플러그인 | 역할 |
|---|---|
| `nvim-treesitter/nvim-treesitter` | 파싱/하이라이트 (`main` 브랜치) |
| `windwp/nvim-ts-autotag` | HTML/JSX 태그 자동 닫기 |
| `hrsh7th/nvim-cmp` | 자동완성 엔진 |
| `hrsh7th/cmp-buffer` / `cmp-path` | 버퍼/경로 소스 |
| `L3MON4D3/LuaSnip` + `saadparwaiz1/cmp_luasnip` | 스니펫 엔진 / cmp 브리지 |
| `rafamadriz/friendly-snippets` | VSCode 스타일 스니펫 컬렉션 |
| `onsails/lspkind.nvim` | 자동완성 픽토그램 |
| `windwp/nvim-autopairs` | 괄호/따옴표 자동 페어 (treesitter + cmp 연동) |
| `numToStr/Comment.nvim` | 주석 토글 |
| `JoosepAlviste/nvim-ts-context-commentstring` | embedded 언어 commentstring |

### Git / 세션 / 기타

| 플러그인 | 역할 |
|---|---|
| `lewis6991/gitsigns.nvim` | 사인 컬럼 git diff + hunk 액션 |
| `rmagatti/auto-session` | 세션 관리 (자동 복원 비활성) |
| `szw/vim-maximizer` | 분할 최대화 토글 |
| `folke/which-key.nvim` | 키 디스커버리 UI |
| `nvim-lua/plenary.nvim` | 다수 플러그인 lua util 의존성 |

---

## 트러블슈팅

### Cmd+1이 안 먹어요

- WezTerm `~/.config/wezterm/wezterm.lua`에 `config.keys` 매핑이 들어 있는지 확인.
- 다른 터미널이라면 [단축키 변경](#커스텀-단축키-변경) 참고.

### treesitter 하이라이트가 안 보여요

- telescope 버전이 `^0.2.0`인지 확인. v0.1.x는 nvim-treesitter `master`만 호환.
- `:checkhealth nvim-treesitter`로 파서 설치 상태 점검.

### 세션 복원 후 하이라이트가 깨져요

`sessionoptions`에 `localoptions`가 포함됐는지 확인 (`:set sessionoptions?`).

### 첫 실행 시 에러가 쏟아져요

플러그인 설치 / treesitter 파서 빌드 중일 가능성. `:Lazy sync` 후 nvim 재실행.

### tree-sitter CLI가 없다고 나와요 (`executable not found`)

```sh
brew install tree-sitter-cli
```

**주의**: `brew install tree-sitter`는 라이브러리(`libtree-sitter`)만 설치한다 — Homebrew가
최근 `tree-sitter` formula에서 CLI를 떼서 **`tree-sitter-cli`** 라는 별도 formula로 분리했다.
nvim-treesitter `main` 브랜치는 파서를 소스에서 빌드하므로 `tree-sitter` 바이너리(CLI)가
PATH에 있어야 하며, 그 바이너리를 제공하는 패키지는 `tree-sitter-cli`다.

확인:

```sh
which tree-sitter         # /opt/homebrew/bin/tree-sitter 같은 경로가 나와야 함
tree-sitter --version     # 0.25.x 등
```

---

## 커스텀 단축키 변경

WezTerm 외 터미널을 쓴다면 `lua/dukcode/plugins/nvim-tree.lua`의 매핑을 바꾸면 된다.

```lua
keymap.set("n", "<M-1>", smart_tree_focus_toggle, { desc = "..." })
--          ^^^^^^^^ 여기를 원하는 키로 (예: "<leader>1", "<F2>")
```

GUI Neovim(Neovide 등)을 쓴다면 `<D-1>`로 바꾸면 Cmd 키를 직접 받을 수 있다.
