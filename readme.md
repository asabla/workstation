# Workstation Configuration

A collection of dotfiles and configuration for setting up a development workstation. Uses GNU Stow for managing symlinks on Unix systems.

## Quick Start

```sh
# Clone the repository
git clone https://github.com/yourusername/workstation.git
cd workstation

# Run the interactive installer
./scripts/install.sh

# Or install specific applications
./scripts/install.sh nvim tmux zsh

# Or install everything
./scripts/install.sh --all
```

## Supported Platforms

| Platform | Package Manager | Stow Support |
|----------|-----------------|--------------|
| macOS    | Homebrew        | Yes          |
| Ubuntu/Debian | apt        | Yes          |
| Arch Linux | pacman/yay    | Yes          |
| Windows  | winget          | No (uses PowerShell symlinks) |

## Applications

| Application | Description | Platforms |
|-------------|-------------|-----------|
| **nvim**    | Neovim editor with Lazy.nvim plugin manager | All |
| **tmux**    | Terminal multiplexer with TPM | Unix only |
| **zsh**     | Z shell with oh-my-zsh and plugins | Unix only |
| **vscode**  | Visual Studio Code settings and keybindings | All |

## Directory Structure

```
workstation/
├── applications/           # Application configurations
│   ├── nvim/              # Neovim config → ~/.config/nvim
│   │   └── .config/nvim/
│   ├── tmux/              # tmux config → ~/.tmux.conf
│   │   └── .tmux.conf
│   ├── zsh/               # zsh config → ~/.zshrc, ~/.config/zsh/
│   │   ├── .zshrc
│   │   └── .config/zsh/
│   └── vscode/            # VSCode settings (custom symlink)
│       ├── settings.json
│       └── keybindings.json
├── scripts/
│   ├── install.sh         # Main installer with interactive menu
│   ├── lib/               # Shared library functions
│   │   ├── common.sh      # Logging, prompts, utilities
│   │   └── detect-os.sh   # OS detection
│   ├── packages/          # Package installation per OS
│   │   ├── macos.sh
│   │   ├── ubuntu.sh
│   │   ├── arch.sh
│   │   └── windows.sh
│   ├── stow/              # Symlink management
│   │   ├── stow.sh        # GNU Stow wrapper
│   │   └── symlink-windows.ps1
│   └── post-install/      # Post-installation hooks
│       ├── nvim.sh
│       ├── tmux.sh
│       ├── zsh.sh
│       └── vscode.sh
└── readme.md
```

## Usage

### Interactive Mode

Run the installer without arguments for an interactive menu:

```sh
./scripts/install.sh
```

### Command Line Options

```sh
# Show help
./scripts/install.sh --help

# Install all applications
./scripts/install.sh --all

# Install specific applications
./scripts/install.sh nvim tmux

# Skip package installation (only link configs)
./scripts/install.sh --skip-packages nvim tmux

# Skip stow/symlink step
./scripts/install.sh --skip-stow nvim

# Skip post-installation hooks
./scripts/install.sh --skip-post-install nvim

# List available applications
./scripts/install.sh --list
```

### Manual Stow Usage

You can also use the stow wrapper directly:

```sh
# Stow specific packages
./scripts/stow/stow.sh stow nvim tmux zsh

# Unstow packages
./scripts/stow/stow.sh unstow nvim

# List available packages
./scripts/stow/stow.sh list

# Adopt existing files (moves them into the repo)
./scripts/stow/stow.sh adopt nvim
```

### Windows Setup

On Windows, use PowerShell with administrator privileges:

```powershell
# Link configurations
.\scripts\stow\symlink-windows.ps1 -Command link -Packages nvim,vscode

# Unlink configurations
.\scripts\stow\symlink-windows.ps1 -Command unlink -Packages nvim

# List available packages
.\scripts\stow\symlink-windows.ps1 -Command list
```

## Post-Installation

After running the installer, you may need to:

### Neovim
- Open Neovim to complete plugin installation
- Run `:checkhealth` to verify setup
- Run `:Mason` to install LSP servers

### tmux
- Start tmux and press `prefix + I` to install plugins
- Default prefix is `Ctrl+b`

### zsh
- Restart your terminal or run `source ~/.zshrc`
- The installer will ask if you want to set zsh as your default shell

### VSCode
- Install recommended extensions manually or export your extensions:
  ```sh
  ./scripts/post-install/vscode.sh export-extensions
  ```

## Customization

### Adding a New Application

1. Create the configuration directory:
   ```sh
   mkdir -p applications/myapp/.config/myapp
   ```

2. Add your configuration files following the stow convention:
   - Files should mirror the target directory structure from `$HOME`
   - `.config/myapp/` will be linked to `~/.config/myapp/`
   - `.myapprc` will be linked to `~/.myapprc`

3. (Optional) Create post-install script:
   ```sh
   # scripts/post-install/myapp.sh
   post_install_myapp() {
     # Your post-install steps
   }
   ```

4. Add the application to `AVAILABLE_APPS` in `scripts/install.sh`

5. Add package definitions in `scripts/packages/*.sh`

### Modifying Existing Configurations

Simply edit the files in `applications/*/` and they will be reflected immediately (they're symlinked).

## Installed CLI Tools

The installer includes these common CLI tools:

- **fzf** - Fuzzy finder
- **ripgrep** - Fast grep alternative
- **fd** - Fast find alternative
- **git** - Version control
- **stow** - Symlink manager

## Troubleshooting

### Stow conflicts

If stow reports conflicts, you can either:
1. Back up and remove the existing file, then re-run stow
2. Use `--adopt` to move existing files into the repo (be careful, this overwrites repo files)

### Permission denied on Windows

Creating symlinks on Windows requires Administrator privileges. Run PowerShell as Administrator.

### zsh not in /etc/shells

If `chsh` fails, add zsh to the allowed shells:
```sh
sudo sh -c 'echo $(which zsh) >> /etc/shells'
```

### Neovim plugins not loading

Run `:Lazy sync` in Neovim to ensure all plugins are installed.

## License

MIT
