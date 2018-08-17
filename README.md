# The `papis-vim` package

This package provides Vim support for [Papis](https://papis.readthedocs.io/en/latest/), command-line based bibliography manager.

[Screencast](https://asciinema.org/a/VkKJJYA3RRO4bHnw7Sgkoy2ZB)

## Install 

This package depends on [fzf.vim](https://github.com/junegunn/fzf.vim).

### Using Vundle

Add these lines to the `.vimrc`:


    Plugin 'junegunn/fzf'
    Plugin 'git@github.com:papis/papis-vim.git'

## Usage

The `:Papis` command will open a search window for your bibliographic database. `Enter` command will insert citation for the selected record in the current buffer.

## Documentation

For more information, execute `:help papis` in Vim.
