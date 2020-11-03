{ config, pkgs, ... }:
let
  nix-processmgmt = import ./nix-processmgmt/tools {};
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (self: super: {
        dwm = super.dwm.override {
          patches = [ ./dwm-config-1.0.10.patch ];
        };
      })
      (self: super: {
        aws-google-auth = super.aws-google-auth.override {
          withU2F = true;
        };
      })
    ];
  };

  home.packages = with pkgs; [
    # nix tools
    nix-processmgmt.common
    nix-processmgmt.systemd
    # database tools
    pgcli
    pgloader
    postgresql
    # network tools
    dnsutils
    openvpn
    update-systemd-resolved
    # misc tools
    xdg_utils
    xsettingsd
    sshpass
    dos2unix
    bc
    xfce.thunar
    openssl
    unzip
    direnv
    silver-searcher
    ncdu
    rofi-pass
    libnotify
    pavucontrol
    dmidecode
    restic
    # programming tools
    gitAndTools.git-trim
    go
    modd
    heroku
    shfmt
    nodejs
    jdk11
    python38Full
    gnumake
    gcc
    docker-compose
    # devops tools
    terraform_0_12
    packer
    minikube
    fluxctl
    kustomize
    kubernetes-helm
    kubectl
    kubectx
    awscli
    doctl
    aws-google-auth
    awslogs
    # window manager
    dwm
    # office tools
    zathura
    remmina
    feh
    #libreoffice-fresh
    # web browsers
    #google-chrome
    chromium
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      aws = {
        disabled = true;
      };
      python = {
        disabled = true;
      };
      terraform = {
        disabled = true;
      };
      nix-shell = {
        disabled = true;
      };
      package = {
        disabled = true;
      };
    };
  };

  programs.htop.enable = true;

  programs.obs-studio = {
    enable = true;
  };

  programs.autorandr.enable = true;

  programs.password-store.enable = true;

  programs.gpg.enable = true;

  #programs.firefox = {
  #  enable = true;
  #};

  programs.git = {
    enable = true;
    userName = "Julio Arias";
    userEmail = "jarias@users.noreply.github.com";
    extraConfig = {
      color = {
        diff   = "auto";
        status = "auto";
        branch = "auto";
        ui     = true;
      };
      core = {
        editor   = "nvim";
        autocrlf = "input";
      };
      apply = {
        whitespace = "nowarn";
      };
      help = {
        autocorrect = 1;
      };
      status = {
        submodule = 1;
      };
      push = {
        default = "current";
      };
      "filter \"media\"" = {
        clean  = "git-media-clean %f";
        smudge = "git-media-smudge %f";
      };
      credential = {
        helper = "cache";
      };
      "filter \"lfs\"" = {
        clean    = "git-lfs clean %f";
        smudge   = "git-lfs smudge %f";
        required = true;
      };
      "diff \"ansible-vault\"" = {
        textconv      = "ansible-vault view";
        # Do not cache the vault contents
        cachetextconv = false;
      };
    };
    aliases = {
      undo           = "reset --soft HEAD^";
      ammend         = "commit --amend -C HEAD";
      credit         = "commit --amend --author \"$1 <$2>\" -C HEAD";
      st             = "status -sb";
      co             = "checkout";
      cm             = "commit";
      # Log display from screencast, with train tracks.
      l              = "log --graph --pretty=format':%C(yellow)%h%Cblue%d%Creset %s %C(white) %an, %ar%Creset'";
      # Alternate log display from Scott Chacon
      lol            = "log --pretty=oneline --abbrev-commit --graph --decorate";
      # Other useful aliases:
      unstage        = "reset HEAD";
      staged         = "diff --cached";
      unstaged       = "diff";
      current-branch = "!git symbolic-ref -q HEAD | sed -e 's|^refs/heads/||'";
      # Usage: git track origin/feature-123-login-form
      track          = "checkout -t";
    };
  };

  programs.fzf = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    localVariables = {
      CDPATH = "$HOME/Projects";
    };
    sessionVariables = {
      EDITOR = "vim";
      PATH   = "$PATH:$HOME/.poetry/bin";
    };
    shellAliases = {
      # Docker
      dc        = "docker rm $(docker ps -aq)";
      dci       = "docker rmi $(docker images -q -f dangling=true)";
      # Kubectl
      k         = "kubectl";
      kgp       = "kubectl get pod";
      kdp       = "kubectl describe pod";
      kgs       = "kubectl get svc";
      kds       = "kubectl describe svc";
      kgi       = "kubectl get ingress";
      kdi       = "kubectl describe ingress";
      kl        = "kubectl logs";
      kctx      = "kubectx";
      kns       = "kubens";
      tf        = "~/.local/bin/terraform";
      tfp       = "~/.local/bin/terraform plan -out plan.out";
      tfa       = "~/.local/bin/terraform apply plan.out";
      # Network
      ipe       = "curl ipinfo.io/ip";
      # Date/Time
      timestamp = "date +%s";
      # Git
      gup       = "git pull --rebase";
      gl        = "git l";
      gp        = "git push -u";
      # Misc
      reload    = "source ~/.zshrc";
      ".."      = "cd ..";
      ls        = "ls -G --color=auto";
      a         = "ls -A";
      la        = "ls -A -l -G";
      c         = "clear";
      cdd       = "cd -";
      cl        = "clear; l";
      cls       = "clear; ls";
      h         = "history";
      "l."      = "ls -d .[^.]*";
      l         = "ls -lhGt";
      ll        = "ls -lh";
      lt        = "ls -lt";
      md        = "mkdir -p";
      e         = "exit";
    };
    initExtra = ''
      unsetopt menu_complete   # do not autoselect the first completion entry
      unsetopt flowcontrol
      setopt auto_menu         # show completion menu on successive tab press
      setopt complete_in_word
      setopt always_to_end

      # autocompletion with an arrow-key driven interface
      zstyle ':completion:*:*:*:*:*' menu select

      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

      zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

      # Don't complete uninteresting users
      zstyle ':completion:*:*:*:users' ignored-patterns \
              adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
              clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
              gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
              ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
              named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
              operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
              rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
              usbmux uucp vcsa wwwrun xfs '_*'

      zstyle '*' single-ignored show

      # Automatically update PATH entries
      zstyle ':completion:*' rehash true

      # Keep directories and files separated
      zstyle ':completion:*' list-dirs-first true

      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down

      # bind P and N for EMACS mode
      bindkey -M emacs '^P' history-substring-search-up
      bindkey -M emacs '^N' history-substring-search-down

      # bind k and j for VI mode
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down

      bindkey "''${terminfo[khome]}" beginning-of-line
      bindkey "''${terminfo[kend]}" end-of-line
      bindkey "\e[3~" delete-char
      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line
      eval "$(direnv hook zsh)"

      function randp() {
        < /dev/urandom tr -dc A-Z-a-z-0-9 | head -c''${1:-32}
      }
    '';
    plugins = [
      {
        name = "zsh-history-substring-search";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-history-substring-search";
          rev = "v1.0.2";
          sha256 = "0y8va5kc2ram38hbk2cibkk64ffrabfv1sh4xm7pjspsba9n5p1y";
        };
      }
    ];
  };

  programs.rofi = {
    enable = true;
    theme = "dracula";
    extraConfig = ''
      rofi.drun-display-format: {name}
    '';
  };

  programs.jq.enable = true;

  programs.neovim = {
    enable       = true;
    vimAlias     = true;
    vimdiffAlias = true;
    withNodeJs   = true;
    withPython   = true;
    withPython3  = true;
    withRuby     = true;
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code";
    };
    settings = {
      "include"              = "dracula.conf";
      "font_size"            = "14.0";
      "background_opacity"   = "0.95";
      "enable_audio_bell"    = "no";
      "visual_bell_duration" = "0.1";
    };
    keybindings = {
      "ctrl+shift+z" = "kitten zoom_toggle.py";
    };
  };

  services.lorri.enable = true;

  services.udiskie.enable = true;

  services.screen-locker = {
    enable = true;
    lockCmd = "/run/wrappers/bin/slock";
  };

  services.picom = {
    enable = true;
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        format               = "<b>%s</b>\\n%b";
        sort                 = "yes";
        indicate_hidden      = "yes";
        alignment            = "left";
        bounce_freq          = 0;
        show_age_threshold   = 60;
        word_wrap            = "yes";
        ignore_newline       = "no";
        geometry             = "300x5-30+20";
        title                = "Dunst";
        class                = "Dunst";
        shrink               = "no";
        transparency         = 5;
        idle_threshold       = 120;
        monitor              = 0;
        follow               = "mouse";
        stack_duplicates     = true;
        hide_duplicate_count = false;
        sticky_history       = "yes";
        history_length       = 20;
        show_indicators      = "yes";
        line_height          = 0;
        notification_height  = 0;
        separator_height     = 2;
        padding              = 8;
        horizontal_padding   = 8;
        separator_color      = "frame";
        startup_notification = false;
        icon_position        = "left";
        always_run_script    = true;
        frame_with           = 3;
        frame_color          = "#aaaaaa";
      };
      urgency_low = {
        background  = "#2F343F";
        foreground  = "#cccccc";
        frame_color = "#252730";
        timeout     = 10;
      };
      urgency_normal = {
        background  = "#2F343F";
        foreground  = "#cccccc";
        frame_color = "#252730";
      };
      urgency_critical = {
        background  = "#900000";
        foreground  = "#ffffff";
        frame_color = "#ff0000";
        timeout     = 0;
      };
    };
  };

  services.flameshot.enable = true;

  services.dwm-status = {
    enable = true;
    order = ["network" "time" "battery"];
    extraConfig = {
      separator = "  ";
      network = {
        template = "  {ESSID}";
      };
      battery = {
        charging    = "";
        discharging = "";
      };
      time = {
        format = "%A %e %b %Y %r";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  services.password-store-sync.enable = true;

  xresources = {
    extraConfig = ''
      Xft.autohint: 0
      Xft.lcdfilter: lcddefault
      Xft.hintstyle: hintslight
      Xft.hinting: 1
      Xft.antialias: 1
      Xft.rgba: rgb
    '';
  };

  xsession = {
    enable = true;
    windowManager.command = "dwm";
    scriptPath = ".hm-xsession";
    initExtra = ''
      feh --bg-scale ~/Pictures/ponyo002.jpg
      autorandr -c
      xsettingsd &
    '';
    importedVariables = [
      "_JAVA_AWT_WM_NONREPARENTING"
      "XDG_DESKTOP_PORTAL_DIR"
      "PATH"
    ];
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name    = "Vanilla-DMZ";
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = null;
      name    = "Dracula";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name    = "Papirus";
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
  };

  home.file.".profile".text = ''
    export _JAVA_AWT_WM_NONREPARENTING=1
  '';

  home.file.".xsettingsd".text = "";

  xdg.configFile."nvim/coc-settings.json".text = ''
    {
      "coc.preferences.formatOnSaveFiletypes": [
        "typescriptreact",
        "typescript.tsx",
        "typescript",
        "javascript",
        "go",
        "json",
        "svelte"
      ],
      "prettier.eslintIntegration": true,
      "languageserver": {
        "terraform": {
          "command": "terraform-ls",
          "args": ["serve"],
          "filetypes": ["terraform", "tf"],
          "initializationOptions": {},
          "settings": {}
        }
      }
    }
  '';

  xdg.configFile."pgcli/config".text = ''
    [main]

    keyring = False
  '';

  xdg.configFile."nvim/init.vim".text = ''
    call plug#begin('~/.local/share/nvim/plugged')

    Plug 'evanleck/vim-svelte', {'branch': 'main'}
    Plug 'editorconfig/editorconfig-vim'
    Plug 'leafgarland/typescript-vim'
    Plug 'scrooloose/nerdtree'
    Plug 'fatih/vim-go'
    Plug 'jodosha/vim-godebug'
    Plug 'tpope/vim-git'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-repeat'
    Plug 'Lokaltog/vim-easymotion'
    Plug 'bronson/vim-trailing-whitespace'
    Plug 'terryma/vim-multiple-cursors'
    Plug 'hashivim/vim-terraform'
    Plug 'pangloss/vim-javascript'
    Plug 'SirVer/ultisnips'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'mileszs/ack.vim'
    Plug 'dracula/vim', { 'as': 'dracula' }
    Plug 'itchyny/lightline.vim'
    Plug 'majutsushi/tagbar'
    Plug 'vim-scripts/yaml.vim'
    Plug 'gabrielelana/vim-markdown'
    Plug 'junegunn/vim-easy-align'
    Plug 'modille/groovy.vim'
    Plug 'lepture/vim-jinja'
    Plug 'udalov/kotlin-vim'
    Plug 'towolf/vim-helm'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'HerringtonDarkholme/yats.vim'
    Plug 'maxmellon/vim-jsx-pretty'
    Plug 'pedrohdz/vim-yaml-folds'
    Plug 'pearofducks/ansible-vim'
    Plug 'LnL7/vim-nix'

    call plug#end()

    syntax on
    colorscheme dracula
    set foldlevelstart=99
    set backupcopy=yes
    set autoread
    set noshowmode
    set textwidth=0
    set wrapmargin=0
    set colorcolumn=+1
    set encoding=utf-8
    set nowrap
    set tabstop=2
    set shiftwidth=2
    set expandtab
    set list
    set listchars=""
    set listchars=tab:▸\ ,eol:¬
    set listchars+=trail:.
    set listchars+=extends:>
    set listchars+=precedes:<
    set completeopt-=preview
    set noswapfile
    set completeopt+=noinsert
    set completeopt+=noselect
    set hlsearch
    set ignorecase
    set smartcase
    set mouse=a
    set relativenumber
    set updatetime=300
    set cmdheight=2
    set shortmess+=c
    set signcolumn=yes

    hi Normal guibg=NONE ctermbg=NONE

    let mapleader=','
    let maplocalleader=';'
    nmap <leader>fef :normal! gg=G``<CR>
    nmap <leader>h :set hlsearch!<CR>

    autocmd TermOpen * if &buftype == 'terminal' | :set nolist | endif

    " Remember last location in file, but not for commit messages.
    " see :help last-position-jump
    au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
          \| exe "normal! g`\"" | endif

    " Deoplete
    let g:deoplete#enable_at_startup = 1

    " NERDTree stuff
    map <leader>n :NERDTreeToggle<CR>
    let NERDTreeShowHidden=1

    " jsx
    let g:jsx_ext_required = 0

    " ack
    let g:ackprg = 'ag --nogroup --nocolor --column'

    " Lightline
    let g:lightline = {
          \ 'colorscheme': 'dracula',
          \ 'active': {
          \   'left': [ [ 'mode', 'paste' ],
          \             [ 'gitbranch', 'readonly', 'relativepath', 'modified' ] ]
          \ },
          \ 'component_function': {
          \   'gitbranch': 'fugitive#head'
          \ },
          \ }

    map <leader>b :Buffers<cr>
    map <leader>f :Files<cr>
    map <leader>g :GFiles<cr>
    map <leader>t :Tags<cr>

    map <leader><leader>t :TagbarToggle<CR>

    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap ga <Plug>(EasyAlign)

    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap ga <Plug>(EasyAlign)

    " coc.nvim

    " Use tab for trigger completion with characters ahead and navigate.
    " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
    " other plugin before putting this into your config.
    inoremap <silent><expr> <TAB>
          \ pumvisible() ? "\<C-n>" :
          \ <SID>check_back_space() ? "\<TAB>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Use <c-space> to trigger completion.
    inoremap <silent><expr> <c-space> coc#refresh()

    " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
    " position. Coc only does snippet and additional edit on confirm.
    " <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
    if exists('*complete_info')
      inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
    else
      inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
    endif

    " Use `[g` and `]g` to navigate diagnostics
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Use K to show documentation in preview window.
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      else
        call CocAction('doHover')
      endif
    endfunction

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)

    " Formatting selected code.
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    augroup mygroup
      autocmd!
      " Setup formatexpr specified filetype(s).
      autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
      " Update signature help on jump placeholder.
      autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end

    " Applying codeAction to the selected region.
    " Example: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)

    " Remap keys for applying codeAction to the current line.
    nmap <leader>ac  <Plug>(coc-codeaction)
    " Apply AutoFix to problem on the current line.
    nmap <leader>qf  <Plug>(coc-fix-current)

    " Introduce function text object
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    xmap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap if <Plug>(coc-funcobj-i)
    omap af <Plug>(coc-funcobj-a)

    " Use <TAB> for selections ranges.
    " NOTE: Requires 'textDocument/selectionRange' support from the language server.
    " coc-tsserver, coc-python are the examples of servers that support it.
    nmap <silent> <TAB> <Plug>(coc-range-select)
    xmap <silent> <TAB> <Plug>(coc-range-select)

    " Add `:Format` command to format current buffer.
    command! -nargs=0 Format :call CocAction('format')

    " Add `:Fold` command to fold current buffer.
    command! -nargs=? Fold :call     CocAction('fold', <f-args>)

    " Add `:OR` command for organize imports of the current buffer.
    command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

    " Mappings using CoCList:
    " Show all diagnostics.
    nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
    " Manage extensions.
    nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
    " Show commands.
    nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
    " Find symbol of current document.
    nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
    " Search workspace symbols.
    nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
    " Do default action for next item.
    nnoremap <silent> <space>j  :<C-u>CocNext<CR>
    " Do default action for previous item.
    nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
    " Resume latest coc list.
    nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

    let g:terraform_fmt_on_save=1
  '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.03";
}
