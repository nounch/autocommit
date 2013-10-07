;;; autocommit.el --- Automatically commit on every save

;; Copyright (C) 2013  -

;; Author: - <gronpy@gronpy.gronpy>
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; ---

;;; Code:


;; Internal prefix: `auc'
;; External prefix: `autocommit'


;;=========================================================================
;; Notes:
;;=========================================================================
;;
;;-------------------------------------------------------------------------
;; Hanlding multiple repos in one directory:
;;-------------------------------------------------------------------------
;;
;;
;;   # 1.
;;   git init .
;;   mv .git .gitone  # Note: Using `git mv' is not an option
;;
;;   # 2.
;;   git init .
;;   mv .git .gittwo  # Note: Using `git mv' is not an option
;;
;;   # 3.
;;   git --git-dir=.gitone add test.txt
;;   git --git-dir=.gitone commit -m "Test"
;;
;;   # 4.
;;   git --git-dir=.gittwo add test.txt
;;   git --git-dir=.gittwo commit -m "Test"
;;
;;
;;-------------------------------------------------------------------------
;; Initializing a `.autocommit' git repository in an existing repo
;;-------------------------------------------------------------------------
;;
;; Asumption: There is already a `.git' directory for a different,
;; pre-existing repository.
;;
;;   # 1. Initialize a bare repository
;;   mkdir .autocommit
;;   cd .autocommit
;;   git init --bare  # Initialize a bare repo
;;   git config core.bare = false
;;
;;   # 2. Now the repository is usable with `--git-dir'
;;   cd ..
;;   git --git-dir=.autocommit commit --allow-empty -m 'Initial commit'
;;   git --git-dir=.autocommit status
;;   git --git-dir=.autocommit log
;;   # ...
;;
;; This method is useful since using
;; `git init --separate-git-dir=.autocommit' would create a file-system
;; agnostic symlink (a `.git' file pointing to `.autocommit') which would
;; remove any pre-existing `.git' directory. So a pre-existing repository
;; using `.git' as the git stash name would be wiped out.


;;=========================================================================
;; Code
;;=========================================================================

(defvar auc-git-directory ".autocommit"
  "Hidden directory which is to be used as the `autocommit' repository's
`.git' directory. Default value: `.autocommit'.")

(defun auc-init ()
  "Check for the presence of a "
  (unless (file-exists-p (concat (file-name-sans-extension
                                  (buffer-file-name)) auc-git-directory))
    (progn
      (make-directory auc-git-directory)
      (cd auc-git-directory)
      (shell-command "git init --bare")
      (shell-command "git config core.bare false")
      (cd "..")
      (shell-command (concat
                      "git --git-dir="
                      auc-git-directory
                      " commit --allow-empty -m \"Initial commit\"")))))

(defun auc-commit-after-save ()
  "Automatically commit a file whenever it is saved. This requires the file
to be displayed in the current buffer."
  (let* ((current-file-name (file-name-nondirectory (buffer-file-name))))
    (shell-command (concat "git --git-dir=\""
                           auc-git-directory
                           "\" add "
                           current-file-name))
    (shell-command (concat "git --git-dir=\""
                           auc-git-directory
                           "\" commit -m \"Auto-commit for file: "
                           current-file-name "\""))))

(define-minor-mode autocommit-mode
  ""
  :init-value nil
  :lighter " auc"
  :group autocommit
  (if (eq autocommit-mode t)
      (progn
        (auc-init)
        (add-hook 'after-save-hook 'auc-commit-after-save))
      (remove-hook 'after-save-hook 'auc-commit-after-save)))


(provide 'autocommit)
;;; autocommit.el ends here
