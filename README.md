# Florian's Dotfiles

This repository contains my personal configuration files, organized according to the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/) and managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

### 1. Preparation
To avoid conflicts, existing configuration files in your home directory should be moved or removed before deployment.

**Warning:** Back up any stateful data, such as your shell history, before proceeding.

```bash
# Example: removing common conflict files
rm ~/.gitconfig ~/.tmux.conf ~/.vimrc ~/.zshrc ~/.zshenv
rm -rf ~/.zsh
```

### 2. Deployment
Clone the repository and use Stow to create the necessary symlinks in your home directory.

```bash
git clone <repo-url> ~/depot/dotfiles
cd ~/depot/dotfiles
stow -t ~ .
```

## Key Features

### 🌗 Seamless Dynamic Theme Synchronization
A particular highlight of this setup is the automatic, real-time adaptation to system-wide color scheme changes (Light/Dark mode). This ensures a consistent visual experience across both GUI and CLI environments without requiring manual intervention or shell restarts.
- **Intelligent Monitoring:** A background script (`watch_theme.sh`) leverages D-Bus signals to detect theme transitions instantly.
- **Broad Integration:** Automatically synchronizes themes for [Zsh](https://www.zsh.org/) (FZF, Autosuggestions, LS_COLORS), [Bat](https://github.com/sharkdp/bat), and Gemini CLI.
- **Robust Automation:** Managed as a background process via a dedicated systemd user service (`theme-watcher.service`).

### 📂 Modern XDG Structure
Configurations are strictly separated to keep the home directory uncluttered and portable:
- **Configuration:** `~/.config/` (Vim, Zsh, Git, Tmux, Ghostty, Fzf)
- **Data:** `~/.local/share/` (Vim plugins, [Sheldon](https://sheldon.cli.rs/))
- **State:** `~/.local/state/` (Zsh history, Vim undo/info, theme synchronization state)

### ⌨️ Consolidated Vim Experience
A shared foundation for Vim, Neovim, and IdeaVim ensures a consistent workflow across different editors:
- **Shared Config:** `~/.config/vim/vimcommon` contains core settings and keybindings used by all three environments.
- **Vim:** Utilizes system-wide plugins supplemented by [minpac](https://github.com/k-takata/minpac).
- **Neovim:** Modern ecosystem management via [lazy.nvim](https://github.com/folke/lazy.nvim).
- **IdeaVim:** Seamlessly sources the common configuration within IntelliJ IDEA.

### 🏗 Flatpak Breakout Integration
For development tools running inside Flatpak containers (like IntelliJ IDEA), a universal breakout mechanism is provided:
- **Universal Bridge:** `~/.local/bin/flatpak-host-bridge.sh` uses `host-spawn` to execute commands on the host system.
- **Transparent Shims:** Symlinks (e.g., `python`, `uv`, `podman`) point to this bridge, allowing sandboxed IDEs to use host-resident tools seamlessly.
- **Native Sockets:** Includes Flatpak overrides to mount the Podman/Docker socket directly into the container for native integration.
- **Security Note:** This mechanism is a deliberate trade-off, reducing Flatpak's sandbox isolation to enable a more flexible development workflow by allowing containerized applications to interact with host system resources.

## Dependencies

- **Shell:** [Zsh](https://www.zsh.org/), [Sheldon](https://sheldon.cli.rs/), [zoxide](https://github.com/ajeetdsouza/zoxide), [Starship](https://starship.rs/), [direnv](https://direnv.net/), [fzf-tab](https://github.com/Aloxaf/fzf-tab)
- **CLI Tools:** [fzf](https://github.com/junegunn/fzf), [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), [fd](https://github.com/sharkdp/fd), [vivid](https://github.com/sharkdp/vivid), [jq](https://github.com/jqlang/jq)
- **Editors:** [Vim](https://www.vim.org/), [Neovim](https://neovim.io/), [Universal Ctags](https://ctags.io/)

## Maintenance

Update classic Vim plugins:
```vim
:PackUpdate  " Install or update plugins in ~/.local/share/vim
:PackClean   " Remove plugins no longer present in the configuration
```
