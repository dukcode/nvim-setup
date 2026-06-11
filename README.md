# nvim-setup

개인 Neovim 설정. `lazy.nvim` 기반의 모듈형 구조이며, macOS + WezTerm 환경을 가정하고 일부 IntelliJ 스타일 단축키를 포함한다.

## 요구사항

- Neovim **0.10.4+** (telescope v0.2.x 호환 요구사항)
- macOS (Cmd 키 매핑은 WezTerm 연동 가정)
- 터미널: WezTerm 권장 (Cmd+숫자 키 매핑이 의존)
- Nerd Font (예: `D2CodingLigature Nerd Font Propo`)
- `git`, `make`, C 컴파일러 (`telescope-fzf-native`, treesitter 빌드용)

## 설치

```sh
git clone <this-repo> ~/.config/nvim
nvim   # 첫 실행 시 lazy.nvim이 자동 부트스트랩되며 플러그인을 설치
```

설치 직후 treesitter 파서가 백그라운드로 받아진다. 잠시 기다리거나 `:checkhealth`로 상태 확인.

## 디렉토리 구조

```
init.lua                       # 엔트리. dukcode.core + dukcode.lazy 로드
lua/dukcode/
├── core/
│   ├── init.lua               # options + keymaps 로더
│   ├── options.lua            # vim.opt 글로벌 옵션
│   └── keymaps.lua            # 플러그인 무관 전역 키맵
├── lazy.lua                   # lazy.nvim 부트스트랩 + 플러그인 import
└── plugins/                   # 개별 플러그인 스펙 (한 파일 = 한 플러그인)
```

`plugins/` 안의 파일은 모두 `lazy.nvim` 스펙(`return { ... }`)을 반환한다. `lazy.lua`가 `{ import = "dukcode.plugins" }`로 한 번에 끌어온다.

## 핵심 커스터마이징

### Leader 키

스페이스(` `)를 leader로 사용한다 (`core/keymaps.lua`).

### 전역 옵션 (`core/options.lua`)

| 옵션 | 값 | 비고 |
|---|---|---|
| `number` / `relativenumber` | on / off | 절대 라인 번호만 표시 |
| `tabstop` / `shiftwidth` | 2 / 2 | 들여쓰기 2칸 + `expandtab` |
| `wrap` | off | 줄바꿈 비활성 |
| `ignorecase` + `smartcase` | on | 대소문자 스마트 매칭 |
| `clipboard` | `unnamedplus` 추가 | 시스템 클립보드 공유 |
| `splitright` / `splitbelow` | on | 분할 방향 직관화 |
| `termguicolors` / `signcolumn` | on / `yes` | 24bit 컬러, 사인 컬럼 고정 |

### IntelliJ 스타일 nvim-tree (`plugins/nvim-tree.lua`)

IntelliJ의 Project View 동작을 흉내낸다.

| 상황 | 키 | 동작 |
|---|---|---|
| 문서 포커스 | `Cmd+1` (= `<M-1>`) | 트리 열고 포커스. 이미 열려있으면 포커스만 |
| 트리 포커스 | `Cmd+1` | 트리 닫고 직전 문서로 포커스 |
| 트리 포커스 | `<Esc>` | 트리는 유지, 직전 창으로 포커스만 이동 |

WezTerm 측에서 `Cmd+1` → `Alt+1` 변환을 보내고, nvim은 `<M-1>`로 받는다. WezTerm 설정은 `~/.config/wezterm/wezterm.lua` 참고:

```lua
config.keys = {
  { key = '1', mods = 'CMD', action = wezterm.action.SendKey { key = '1', mods = 'ALT' } },
}
```

> 부수효과: WezTerm 기본 `Cmd+1`(첫 탭 활성화)이 가려진다. WezTerm 탭을 안 쓰는 워크플로 기준.

### nvim-treesitter `main` 브랜치

- `master`가 아닌 **`main` 브랜치**를 사용. lazy-loading은 막혀 있어 `lazy = false`.
- `setup({ highlight = ..., indent = ... })` 옵션이 사라져서 `FileType` autocmd에서 `vim.treesitter.start()` + `indentexpr` 직접 활성화.
- `incremental_selection`은 제거됨 — 필요하면 별도 매핑 필요.

### telescope `^0.2.0` 고정 (`plugins/telescope.lua`)

v0.2부터 nvim-treesitter 의존성 제거 → treesitter `main` 브랜치와 호환. Neovim 0.10.4+ 필수.

### Comment.nvim + ts-context-commentstring

`CursorHold` autocmd가 treesitter parser 없는 버퍼에서 `language_tree nil` 에러를 내서 `enable_autocmd = false`로 끄고, `Comment.nvim`의 `pre_hook`으로만 commentstring을 계산한다. (`plugins/comment.lua`)

### auto-session 동작 (`plugins/auto-sessions.lua`)

- **`auto_restore = false`** — nvim 열 때마다 자동 복원하지 않음. 산만함 방지. `<leader>wr`로 명시적 복원만.
- `suppressed_dirs`: `~`, `~/Dev/`, `~/Downloads`, `~/Documents`, `~/Desktop/`에서는 세션을 저장/복원하지 않음.
- `sessionoptions`에 `localoptions` 포함 — 복원 후 트리시터 하이라이트가 꺼지는 문제 방지.

### bufferline 기본값 (`plugins/bufferline.lua`)

`mode = "tabs"`를 제거하고 buffer 모드 기본값 사용.

### tokyonight 커스텀 팔레트 (`plugins/colorscheme.lua`)

`style = "night"` 기반에 BG/FG를 직접 오버라이드. 기본값으로 `transparent = true`.

### lualine 커스텀 테마 (`plugins/lualine.lua`)

`my_lualine_theme` 직접 정의. lazy 업데이트 카운트를 `lualine_x`에 표시.

## 키맵 요약

### 전역 (`core/keymaps.lua`)

| 키 | 동작 |
|---|---|
| `<leader>nh` | 검색 하이라이트 해제 |
| `<leader>+` / `<leader>-` | 숫자 증감 (`<C-a>` / `<C-x>`) |
| `<leader>sv` / `<leader>sh` | 창 수직/수평 분할 |
| `<leader>se` / `<leader>sx` | 분할 크기 균등화 / 현재 분할 닫기 |
| `<leader>to` / `<leader>tx` | 탭 새로 / 닫기 |
| `<leader>tn` / `<leader>tp` | 다음 / 이전 탭 |
| `<leader>tf` | 현재 버퍼를 새 탭으로 |

### nvim-tree

| 키 | 동작 |
|---|---|
| `Cmd+1` (`<M-1>`) | IntelliJ 스타일 트리 포커스 토글 |
| `<leader>ee` | 트리 토글 |
| `<leader>ef` | 현재 파일 위치로 트리 토글 |
| `<leader>ec` | 트리 접기 |
| `<leader>er` | 트리 새로고침 |
| 트리 안에서 `<Esc>` | 트리 유지, 이전 창으로 포커스 |

### Telescope

| 키 | 동작 |
|---|---|
| `<leader>ff` | 파일 검색 (find_files) |
| `<leader>fr` | 최근 파일 |
| `<leader>fs` | 라이브 grep |
| `<leader>fc` | 커서 아래 단어 grep |
| `<leader>ft` | TODO 검색 |
| 인서트 `<C-j>` / `<C-k>` | 다음 / 이전 결과 |
| 인서트 `<C-q>` | 선택 항목을 quickfix로 |

### gitsigns

| 키 | 동작 |
|---|---|
| `]h` / `[h` | 다음 / 이전 hunk |
| `<leader>hs` / `<leader>hr` | hunk stage / reset (visual 영역 지원) |
| `<leader>hS` / `<leader>hR` | 버퍼 전체 stage / reset |
| `<leader>hu` | stage 취소 |
| `<leader>hp` | hunk 미리보기 |
| `<leader>hb` / `<leader>hB` | 라인 blame / 전체 라인 blame 토글 |
| `<leader>hd` / `<leader>hD` | diff this / diff this ~ |
| `ih` (오퍼레이터/비주얼) | hunk 텍스트 오브젝트 |

### 세션 / 창

| 키 | 동작 |
|---|---|
| `<leader>wr` / `<leader>ws` | 세션 복원 / 저장 |
| `<leader>sm` | 분할 최대화 토글 (vim-maximizer) |

### TODO

| 키 | 동작 |
|---|---|
| `]t` / `[t` | 다음 / 이전 TODO |

### nvim-cmp (인서트 모드)

| 키 | 동작 |
|---|---|
| `<C-p>` / `<C-n>` | 이전 / 다음 후보 |
| `<C-b>` / `<C-f>` | 문서 스크롤 |
| `<C-Space>` | 후보 표시 |
| `<C-e>` | 닫기 |
| `<CR>` | 확정 (자동 선택 안 함) |

## 플러그인 목록

### UI / 테마

| 플러그인 | 역할 / 커스터마이징 |
|---|---|
| `folke/tokyonight.nvim` | 컬러스킴. `night` 스타일 + 커스텀 팔레트, transparent |
| `nvim-lualine/lualine.nvim` | 상태줄. `my_lualine_theme` + lazy 업데이트 카운트 |
| `akinsho/bufferline.nvim` | 버퍼라인. 기본값 (buffer 모드) |
| `goolord/alpha-nvim` | 시작 대시보드. 커스텀 헤더 + 메뉴 |
| `stevearc/dressing.nvim` | `vim.ui.select` / `vim.ui.input` UI 개선 |
| `lukas-reineke/indent-blankline.nvim` | 들여쓰기 가이드. char = `┊` |
| `nvim-tree/nvim-web-devicons` | 파일 아이콘 (다수 플러그인 의존성) |

### 탐색

| 플러그인 | 역할 / 커스터마이징 |
|---|---|
| `nvim-tree/nvim-tree.lua` | 파일 트리. IntelliJ 스타일 매핑 (`<M-1>`, `<Esc>`) |
| `nvim-telescope/telescope.nvim` | 퍼지 파인더. v0.2.x 고정, fzf-native 로드 |
| `nvim-telescope/telescope-fzf-native.nvim` | telescope 정렬 가속 |
| `folke/todo-comments.nvim` | `TODO:` / `FIX:` 등 하이라이트 + 점프 |

### 편집

| 플러그인 | 역할 / 커스터마이징 |
|---|---|
| `nvim-treesitter/nvim-treesitter` | 파싱/하이라이트. `main` 브랜치 + FileType autocmd 활성화 |
| `windwp/nvim-ts-autotag` | HTML/JSX 태그 자동 닫기 |
| `hrsh7th/nvim-cmp` | 자동완성 엔진 |
| `hrsh7th/cmp-buffer` / `cmp-path` | 버퍼/경로 소스 |
| `L3MON4D3/LuaSnip` + `saadparwaiz1/cmp_luasnip` | 스니펫 엔진/cmp 브리지 |
| `rafamadriz/friendly-snippets` | 스니펫 컬렉션 (VSCode 스타일) |
| `onsails/lspkind.nvim` | 완성 메뉴 픽토그램 |
| `windwp/nvim-autopairs` | 괄호/따옴표 자동 페어. treesitter 인식 + cmp 연동 |
| `numToStr/Comment.nvim` | 주석 토글 |
| `JoosepAlviste/nvim-ts-context-commentstring` | JSX/TSX 등 embedded 언어 commentstring. `enable_autocmd = false` |

### Git

| 플러그인 | 역할 |
|---|---|
| `lewis6991/gitsigns.nvim` | 사인 컬럼 git diff 표시 + hunk 액션 매핑 |

### 세션 / 창

| 플러그인 | 역할 / 커스터마이징 |
|---|---|
| `rmagatti/auto-session` | 세션 관리. `auto_restore = false` + `suppressed_dirs` |
| `szw/vim-maximizer` | 분할 최대화 토글 |

### 기타

| 플러그인 | 역할 |
|---|---|
| `folke/which-key.nvim` | 키 디스커버리 UI. `timeoutlen = 500` |
| `nvim-lua/plenary.nvim` | 다수 플러그인 의존성 (lua util) |

## 자주 만나는 함정

- **treesitter highlight가 안 보임** → telescope를 v0.2.x로 올렸는지 확인. v0.1.x는 nvim-treesitter `master`만 호환.
- **세션 복원 후 하이라이트 깨짐** → `sessionoptions`에 `localoptions` 포함됐는지 확인.
- **Cmd+1이 안 먹음** → WezTerm `config.keys`에 변환 매핑 들어있는지 확인. 다른 터미널을 쓴다면 매핑을 `<F13>` 등 다른 키로 바꾸고 터미널 설정에서 그 키를 보내도록 구성.
- **nvim 첫 실행 시 에러 다발** → 플러그인 설치 / treesitter 파서 빌드 중일 수 있음. `:Lazy sync` 후 재실행.
