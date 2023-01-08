+++
title = "Neovim LSP & Go!"
date = 2021-07-30T07:14:22-05:00
draft = true
tags = ['Blog']
description = "A tutorial on Go integration with the native LSP client in Neovim."
+++

The native LSP client for Neovim was released in [version 0.5.0](https://github.com/neovim/neovim/commit/a5ac2f45ff84a688a09479f357a9909d5b914294). Since then, many lua based tools have come to replace the vim script plugins of the past. One of the largest packages, Conqueror of Commands, is now in competition with the internal Language Server Protocol of Neovim. In due time, the native LSP of Neovim will only get faster and more reliable. Users of Neovim are flocking to update their configs in an effort to be early adopters - and I'm one of those people. 

After watching many youtube videos by [TJ Devries](https://www.youtube.com/channel/UCd3dNckv1Za2coSaHGHl5aA) (core maintainer of Neovim) and his discussions about the future of LSP integration.

// TODO: follow up on this

With that being said, I decided to set out and integrate this new feature into my workflow. Since I primarly use Go, I thought it would be appropriate to test the integration of gopls with LSP.

## Prerequisites

Before getting started there's a couple pieces of software you should already have installed:
 - [Neovim 0.5.0](https://github.com/neovim/neovim/releases/tag/v0.5.0), or later 
 - [Vimplug](https://github.com/junegunn/vim-plug)
 - [go](https://golang.org/doc/install)

After installation, you should open your init.vim configuration file; this file is usually located under `${XDG_CONFIG_HOME}/nvim/init.vim`. If it doesn't exist, create it with `mkdir ${XDG_CONFIG_HOME}/nvim && touch ${XDG_CONFIG_HOME}/nvim/init.vim`. You should be able to open the newly created file with `nvim ${XDG_CONFIG_HOME}/nvim/init.vim`.

Once opened, add the necessary declarations for Vim-Plug:

```VimL
call plug#begin(stdpath('data') . '/plugged')
	" Plugs go here
call plug#end()
```

For our first plugin, we'll add [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig). This plugin gives us default configurations for multiple language server flavors — making setup that much easier. You can add the neovim/nvim-lspconfig plug between the opening and closing Vim-Plug declarations of your init.vim file:

```VimL
call plug#begin(stdpath('data') . '/plugged')
        Plug 'neovim/nvim-lspconfig'
call plug#end()
```

Save that change and type the following into the active Neovim window `:source $MYVIMRC` and `:PlugInstall`. You should see a new window appear showing the installation status for nvim-lspconfig. Once the installation finishes, close the newly created Neovim window with `q`. 

Next we'll install gopls (Go please), the official language server for the Go programming language. Insert the command

