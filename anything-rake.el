;;; anything-rake.el --- Quick listing and execution of rake tasks.

;; This file is not part of Emacs

;; Copyright (C) 2011 Jose Pablo Barrantes
;; Created: 18/Dec/11
;; Version: 0.1.0

;;; Installation:

;; Put this file where you defined your `load-path` directory or just
;; add the following line to your emacs config file:

;; (load-file "/path/to/anything-rake.el")

;; Finally require it:

;; (require 'anything-rake)

;; Usage:
;; M-x anything-rake

;; There is no need to setup load-path with add-to-list if you copy
;; `anything-rake.el` to load-path directories.

;; Requirements:

;; http://www.emacswiki.org/emacs/Anything

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'anything)

;;; --------------------------------------------------------------------
;;; - Customization
;;;
(defcustom anything-rake/sh-script
  "rake_tasks_cacher.sh"
  "Path to rake shell script."
  :group 'anything-rake
  :type 'string)

;;; --------------------------------------------------------------------
;;; - Helpers
;;;
(defun find-git-repo (dir)
  "Recursively search for a .git/ directory."
  (if (string= "/" dir)
      (message "not in a git repo.")
    (if (file-exists-p (expand-file-name ".git/" dir))
        dir
      (git-show/find-git-repo (expand-file-name "../" dir)))))

(defun anything-find-rake-tasks ()
  "Rake tasks."
  (setq mode-line-format
        '(" " mode-line-buffer-identification " "
          (line-number-mode "%l") " "
          (:eval (propertize "(Rake -T Process Running) "
                             'face '((:foreground "red"))))))
  ;; TODO: remove the dot(.) parameter from the -g argument.
  ;; Since the `anything-rake/sh-script' `-g' arguments requires a
  ;; value, if `anything-pattern' is nil it will complain.
  (setq cmd (concat anything-rake/sh-script " -p %s -g %s ."))
  (prog1
      (start-process-shell-command "rake-tasks-process" nil
                                   (format cmd
                                           (find-git-repo default-directory)
                                           anything-pattern))
    (set-process-sentinel (get-process "rake-tasks-process")
                          #'(lambda (process event)
                              (when (string= event "finished\n")
                                (kill-local-variable 'mode-line-format)
                                (with-anything-window
                                  (anything-update-move-first-line)))))))

;;; --------------------------------------------------------------------
;;; - Interctive Functions
;;;
;;;###autoload
(defun anything-rake ()
  "Return a list of all the rake tasks defined in the current projects."
  (interactive)
  (setq buff-name
        (concat "*Rake tasks in: " (find-git-repo default-directory) " *"))
  (anything-other-buffer
   '((name . "Anything Rake Tasks")
     (candidates . anything-find-rake-tasks)
     (type . file)
     (requires-pattern . 0)
     (candidate-number-limit . 9999)
     (candidates-in-buffer)
     (action . (lambda (candidate)
                 (message candidate)
                 (if (string-match "\\([^\w ]+\\)" candidate)
                     (compile (message (concat anything-rake/sh-script " -e "
                                               (match-string 1 candidate))))))))
   buff-name)
  (kill-buffer buff-name))

(provide 'anything-rake)
