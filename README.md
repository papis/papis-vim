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

The `:PapisView` command will open the pdf file of the citation currently under your cursor with the same pdf-reader used by papis. 
This currently only works when using whoosh as backend for the papis database. Add the following to your `config` file of papis:

    database-backend = whoosh
    whoosh-schema-fields = ['ref']

The second is needed to enable whoosh for searches through the ref field.


Add the following to your `tex.vim` file for useful keyboard shortcuts:

    nnoremap <buffer> <localleader>pc :Papis<cr>
    nnoremap <buffer> <localleader>pv :PapisView<cr>

## Documentation

For more information, execute `:help papis` in Vim.
