# GEMINI.md

## Project Overview

This project is a Neovim configuration designed for a transparent, distraction-free coding environment with a focus on performance and built-in development tools. It uses `lazy.nvim` for plugin management and `mason.nvim` for automatic LSP server installation. The configuration is written in Lua and features extensive customization for UI, keymappings, and language support.

**Key Technologies:**

*   **Editor:** Neovim
*   **Plugin Manager:** lazy.nvim
*   **LSP:** nvim-lspconfig, mason.nvim
*   **Completion:** blink.cmp
*   **Fuzzy Finding:** Telescope, fzf-lua
*   **Formatting:** stylua (Lua), black (Python), biome (Web)
*   **Linting:** ruff (Python), eslint (Web)

## Building and Running

This is a Neovim configuration, so there is no traditional "build" process. To "run" the project, you simply need to open Neovim.

**Installation:**

1.  **Backup existing configuration:**
    ```bash
    mv ~/.config/nvim ~/.config/nvim.backup
    mv ~/.local/share/nvim ~/.local/share/nvim.backup
    ```
2.  **Clone the repository:**
    ```bash
    git clone <repository-url> ~/.config/nvim
    ```
3.  **Start Neovim:**
    ```bash
    nvim
    ```
    On the first launch, `lazy.nvim` will automatically install all the plugins. `mason.nvim` will install the specified language servers.

**Testing:**

There are no formal tests for this project. The user is expected to test the configuration by using Neovim and its various features in their daily workflow.

## Development Conventions

*   **Code Style:** The project uses `.stylua.toml` to enforce a consistent code style for Lua files. The column width is set to 100 characters, and indentation is 2 spaces.
*   **Plugin Management:** Plugins are managed through `lazy.nvim`. Plugin specifications are located in the `lua/plugins/` directory.
*   **Keymappings:** Global keymappings are defined in `lua/config/keymaps.lua`. Plugin-specific keymappings are defined in their respective plugin configuration files. The leader key is `<Space>`.
*   **LSP Configuration:** LSP servers are configured in `lua/plugins/lsp-config.lua`. `mason.nvim` is used to automatically install and manage the language servers.
*   **Custom Utilities:** Custom utility functions are located in the `lua/utils/` directory. For example, `lua/utils/highlights.lua` contains functions for manipulating highlight groups, and `lua/utils/tailwind.lua` provides Tailwind CSS support.
*   **Transparency:** The configuration is designed to be transparent. Transparency settings are configured in `lua/plugins/transparency.lua` and `lua/utils/highlights.lua`.
*   **Profiling:** The configuration includes a built-in profiling system that can be toggled with the `F1` key. The profiling results are saved to `profile.json`.
