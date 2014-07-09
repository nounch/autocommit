# autocommit.el

`autocommit.el` automatically commits changes to a Git repository
whenver a save action happens in a buffer that has a file associated with
it and which currently has `autocommit-mode` active. The commits are stored
in the special Git directory `.autocommit`. This allows it to co-exist
alongside a usual (`.git`) main repository without depending on Git
submodules.

## Usage

1. Require it

        (require 'autocommit)

2. Enable `autocommit-mode`

        M-x autocommit-mode

## Customization

The `auc-git-directory` variable specifies the name of the Git directory to
be used for automatic commits (default value: `".autocommit"`).
