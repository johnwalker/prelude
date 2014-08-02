(require 'bind-key)

(bind-keys
 ("C-c n" . indent-and-cleanup-buffer)
 ("C-x m" . magit-status)
 ("C-." . delete-other-windows)
 ("C-o" . other-frame)
 ("M-o" . other-window)
 ("C-x C-b" . ibuffer)
 ("C-x k" . kill-this-buffer))

(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(setq cider-show-error-buffer 'except-in-repl)

(require 'clj-refactor)

(require 'org-page)
(require 'ox-publish)
(require 'htmlize)
(setq org-html-htmlize-output-type 'inline-css)
(setq org-html-validation-link nil)

(setq org-publish-project-alist
      '(("blog" :components ("orgblog" "images"
                             "feed-clojure" "feed-blog" "other"
                             "js"
                             ))
        ("orgblog"
         :auto-sitemap nil
         :author "John Walker"
         :sitemap-title "John's Blog"
         :auto-postamble nil
         :htmlized-source t
         :base-directory "~/documents/blorg"
         :base-extension "org"
         :export-author-info t
         :export-creator-info nil
         :sitemap-sort-files anti-chronologically
         :publishing-directory "~/documents/blog"
         :publishing-function my-org-publish-org-to-html
         :with-drawers t
         :with-special-strings t
         ;; :publishing-function my-org-publish-org-to-html
         :exclude "~/documents/blorg/css feed.org feed-clojure.org"
         :recursive t
         :headline-levels 5
         ;;       :html-preamble
         ;;       "
         ;;       <nav>
         ;;           <a class=\"loc\" href=\"/\">johnwalker.github.io</a>
         ;;           <a class=\"loc\" href=\"https://github.com/johnwalker\">github</a>
         ;;           <a class=\"loc\" href=\"https://twitter.com/johnwalker301\">twitter</a>
         ;;       </nav>
         ;; </div>"
         :section-numbers nil
         :html-head-include-default-style t
         :description "A dude blogs"
         :html-head-include-scripts nil
         ;;       :html-head-extra
         ;;       "
         ;; <link rel=\"alternate\" type=\"application/rss+xml\"
         ;;                 href=\"http://johnwalker.github.io\"
         ;;                 title=\"RSS feed for johnwalker.github.io\">"
         :with-toc nil)
        ("feed-clojure"
         :base-directory "~/documents/blorg"
         :base-extension "org"
         :author "John Walker"
         :webmaster "john.lou.walker@gmail.com"
         :publishing-directory "~/documents/blog"
         :publishing-function org-rss-publish-to-rss
         :html-link-home "http://johnwalker.github.io/"
         :html-link-use-abs-url t
         :author "John Walker"
         :with-author "John Walker"
         :exclude ".*"
         :include ("feed-clojure.org"))
        ("feed-blog"
         :base-directory "~/documents/blorg"
         :base-extension "org"
         :author "John Walker"
         :webmaster "john.lou.walker@gmail.com"
         :with-author "John Walker"
         :publishing-directory "~/documents/blog"
         :publishing-function org-rss-publish-to-rss
         :html-link-home "http://johnwalker.github.io/"
         :html-link-use-abs-url t
         :exclude ".*"
         :include ("feed.org"))
        ("images"
         :author "John Walker"
         :base-directory "~/documents/blorg/images"
         :base-extension "jpg\\|gif\\|png"
         :exclude "~/development/blog/css"
         :publishing-directory "~/documents/blog/images"
         :publishing-function org-publish-attachment)
        ("other"
         :author "John Walker"
         :base-directory "~/documents/blorg/css"
         :base-extension "css"
         :publishing-directory "~/documents/blog/css"
         :publishing-function org-publish-attachment)
        ("js"
         :author "John Walker"
         :base-directory "~/documents/blorg/js"
         :base-extension "js"
         :publishing-directory "~/documents/blog/js"
         :publishing-function org-publish-attachment)))

(defun my-org-html-postamble (plist)
  ;; (concat (format "<p class=\"postamble\">Last update : %s </p>" (format-time-string "%Y %B %d"))
  ;;         "
  ;; <footer>

  ;; </footer>")
  )

(setq org-html-postamble 'my-org-html-postamble)

(defun org-html-template (contents info)
  "Return complete document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   (when (and (not (org-html-html5-p info)) (org-html-xhtml-p info))
     (let ((decl (or (and (stringp org-html-xml-declaration)
                          org-html-xml-declaration)
                     (cdr (assoc (plist-get info :html-extension)
                                 org-html-xml-declaration))
                     (cdr (assoc "html" org-html-xml-declaration))

                     "")))
       (when (not (or (eq nil decl) (string= "" decl)))
         (format "%s\n"
                 (format decl
                         (or (and org-html-coding-system
                                  (fboundp 'coding-system-get)
                                  (coding-system-get org-html-coding-system 'mime-charset))
                             "iso-8859-1"))))))
   (org-html-doctype info)
   "\n"
   (concat "<html"
           (when (org-html-xhtml-p info)
             (format
              " xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"%s\" xml:lang=\"%s\""
              (plist-get info :language) (plist-get info :language)))
           ">\n")
   "<head>\n"
   (org-html--build-meta-info info)
   (org-html--build-head info)
   (org-html--build-mathjax-config info)
   "</head>\n"
   "<body>\n"
   (let ((link-up (org-trim (plist-get info :html-link-up)))
         (link-home (org-trim (plist-get info :html-link-home))))
     (unless (and (string= link-up "") (string= link-home ""))
       (format org-html-home/up-format
               (or link-up link-home)
               (or link-home link-up))))
   (org-html--build-pre/postamble 'preamble info)
   (format "<%s id=\"%s\">\n"
           (nth 1 (assq 'content org-html-divs))
           (nth 2 (assq 'content org-html-divs)))
   ;; "<a href=\"#skip\" class=\"offscreen\">Skip Content</a> "
   contents
   (format "</%s>\n"
           (nth 1 (assq 'content org-html-divs)))
   ;; Postamble.
   (org-html--build-pre/postamble 'postamble info)
   ;; Closing document.
   "</body>\n</html>"))

(defun my-org-publish-org-to-html (plist filename pub-dir)
  (org-publish-org-to 'html filename
                      (concat "." (or (plist-get plist :html-extension)
                                      org-html-extension "html"))
                      plist pub-dir))

(require 'ob)
(require 'ob-clojure)

(setq org-babel-clojure-backend 'cider)

;; (use-package ox-rss)
(setq org-export-htmlize-output-type 'css)

;; fontify code in code blocks
(setq org-src-fontify-natively t)
(require 'babel)
(setq org-ditaa-jar-path "~/toolbox/ditaa0_9.jar")
(setq org-plantuml-jar-path "~/toolbox/plantuml.jar")
(setq org-babel-results-keyword "results")
(setq org-export-latex-listings t)

(org-babel-do-load-languages
 (quote org-babel-load-languages)
 (quote ((emacs-lisp . t)
         (dot . t)
         (ditaa . t)
         (java . t)
         (gnuplot . t)
         (lisp . t)
         (clojure . t)
         (sh . t)
         (org . t))))
(setq org-confirm-babel-evaluate nil)
(setq org-export-babel-evaluate nil)
(add-to-list 'org-src-lang-modes (quote ("plantuml" . fundamental)))
(setq org-src-tab-acts-natively t)

(add-to-list 'org-latex-packages-alist '("" "minted"))
(setq org-latex-listings 'minted)

;; (require 'tex)
;; (use-package ox-latex
;;   :defer t
;;   :config (progn
;;          (setq latex-run-command "pdflatex")
;;          (TeX-global-PDF-mode t)
;;          (setq TeX-PDF-mode t)
;;          (setq TeX-auto-save t)
;;          (setq TeX-parse-self t)
;;          (setq-default TeX-master nil)
;;          (add-hook 'LaTeX-mode-hook 'visual-line-mode)
;;          (add-hook 'LaTeX-mode-hook 'flyspell-mode)
;;          (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
;;          (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
;;          (setq reftex-plug-into-AUCTeX t)
;;          (setq org-latex-pdf-process
;;                '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
;;                  "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
;;                  "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))))

(global-set-key (kbd "M-<f2>") 'org-agenda)

(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/git/org/refile.org")
               "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
              ("n" "note" entry (file "~/git/org/refile.org")
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
              ("j" "journal" entry (file+datetree "~/git/org/diary.org.gpg")
               "* %?\n%U\n" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry (file "~/git/org/refile.org")
               "* TODO Review %c\n%U\n" :immediate-finish t)
              ("h" "habit" entry (file "~/git/org/refile.org")
               "* TODO %?\n%U\n%a\nSCHEDULED: %(format-time-string \"<%Y-%m-%d %a .+1d/3d>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: TODO\n:END:\n"))))

(if (boundp 'org-user-agenda-files)
    (setq org-agenda-files org-user-agenda-files)
  (setq org-agenda-files (quote ("~/git/org"))))

(setq org-agenda-compact-blocks t)

(setq org-agenda-custom-commands
      '(("n" "notes" tags "NOTE"
         ((org-agenda-overriding-header "notes")
          (org-tags-match-list-sublevels t)))
        ("h" "habits" tags-todo "STYLE=\"habit\""
         ((org-agenda-overriding-header "habits")
          (org-agenda-sorting-strategy
           '(todo-state-down effort-up category-keep))))
        (" " "agenda"
         ((agenda "" nil)
          (tags "REFILE"
                ((org-agenda-overriding-header "Tasks to Refile")
                 (org-tags-match-list-sublevels nil))))
         nil)))

(org-clock-persistence-insinuate)
(setq org-clock-history-length 23)
(setq org-clock-in-resume t)
(setq org-clock-into-drawer t)
(setq org-clock-out-remove-zero-time-clocks t)
(setq org-clock-out-when-done t)
(setq org-clock-persist t)
(setq org-clock-persist-query-resume nil)
(setq org-clock-auto-clock-resolution 'when-no-clock-is-running)
(setq org-clock-report-include-clocking-task t)

(setq org-time-stamp-rounding-minutes '(1 1))

(setq org-agenda-clock-consistency-checks
      (quote (:max-duration "4:00"
                            :min-duration 0
                            :max-gap 0
                            :gap-ok-around ("4:00"))))

(setq org-global-properties  '(("Effort_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")
                               ("STYLE_ALL" . "habit")))

(setq org-agenda-log-mode-items '(closed state))

(setq org-agenda-clockreport-parameter-plist
      (quote (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))

(setq bh/keep-clock-running nil)

(defun bh/clock-in-to-next (kw)
  "Switch a task from TODO to NEXT when clocking in.
Skips capture tasks, projects, and subprojects.
Switch projects and subprojects from NEXT back to TODO"
  (when (not (and (boundp 'org-capture-mode) org-capture-mode))
    (cond
     ((and (member (org-get-todo-state) (list "TODO"))
           (bh/is-task-p))
      "NEXT")
     ((and (member (org-get-todo-state) (list "NEXT"))
           (bh/is-project-p))
      "TODO"))))

(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))

(defun bh/punch-in (arg)
  "Start continuous clocking and set the default task to the
selected task.  If no task is selected set the Organization task
as the default task."
  (interactive "p")
  (setq bh/keep-clock-running t)
  (if (equal major-mode 'org-agenda-mode)
      ;;
      ;; We're in the agenda
      ;;
      (let* ((marker (org-get-at-bol 'org-hd-marker))
             (tags (org-with-point-at marker (org-get-tags-at))))
        (if (and (eq arg 4) tags)
            (org-agenda-clock-in '(16))
          (bh/clock-in-organization-task-as-default)))
    ;;
    ;; We are not in the agenda
    ;;
    (save-restriction
      (widen)
      ;; Find the tags on the current task
      (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
          (org-clock-in '(16))
        (bh/clock-in-organization-task-as-default)))))

(defun bh/punch-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-remove-restriction-lock))

(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun bh/clock-in-parent-task ()
  "Move point to the parent (project) task if any and clock in"
  (let ((parent-task))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (not parent-task) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (if parent-task
            (org-with-point-at parent-task
              (org-clock-in))
          (when bh/keep-clock-running
            (bh/clock-in-default-task)))))))

(defvar bh/organization-task-id "eb155a82-92b2-4f25-a3c6-0304591af2f9")

(defun bh/clock-in-organization-task-as-default ()
  (interactive)
  (org-with-point-at (org-id-find bh/organization-task-id 'marker)
    (org-clock-in '(16))))

(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (bh/clock-in-parent-task)))

(require 'org-id)
(defun bh/clock-in-task-by-id (id)
  "Clock in a task by id"
  (org-with-point-at (org-id-find id 'marker)
    (org-clock-in nil)))

(defun bh/clock-in-last-task (arg)
  "Clock in the interrupted task if there is one
Skip the default task and get the next one.
A prefix arg forces clock in of the default task."
  (interactive "p")
  (let ((clock-in-to-task
         (cond
          ((eq arg 4) org-clock-default-task)
          ((and (org-clock-is-active)
                (equal org-clock-default-task (cadr org-clock-history)))
           (caddr org-clock-history))
          ((org-clock-is-active) (cadr org-clock-history))
          ((equal org-clock-default-task (car org-clock-history)) (cadr org-clock-history))
          (t (car org-clock-history)))))
    (widen)
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)

(setq org-columns-default-format "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM")

(global-set-key (kbd "C-<f3>") 'bh/punch-in)
(global-set-key (kbd "M-<f3>") 'bh/punch-out)

(add-hook 'org-mode-hook '(lambda ()
                            ;; turn on flyspell-mode by default
                            ;; (flyspell-mode 1)
                            ;; C-TAB for expanding
                            (local-set-key (kbd "C-<tab>")
                                           'yas/expand-from-trigger-key)
                            ;; keybinding for editing source code blocks
                            (local-set-key (kbd "C-c s e")
                                           'org-edit-src-code)
                            ;; keybinding for inserting code blocks
                            (local-set-key (kbd "C-c s i")
                                           'org-insert-src-block)))

(setq op/repository-directory "~/documents/johnwalker.github.io/")
(setq op/site-domain "http://johnwalker.github.io/")
(setq op/personal-disqus-shortname "johnwalker")

(require 'projectile)
(add-hook 'clojure-mode-hook 'projectile-on)
(add-hook 'eshell-mode-hook  'projectile-on)
(add-hook 'magit-mode-hook   'projectile-on)
(add-hook 'html-mode-hook   'projectile-on)

(require 'prodigy)
(global-set-key (kbd "¶") 'prodigy)

(prodigy-define-service
  :name "personal_blog 1620"
  :command "python"
  :args '("-m" "http.server" "1620")
  :cwd "~/documents/johnwalker.github.io"
  :tags '(blog)
  :kill-signal 'sigkill
  :kill-process-buffer-on-stop t)
(defun prodigy-toggle-service (service &optional force callback)
  (let ((process (plist-get service :process)))
    (if (prodigy-service-started-p service)
        (prodigy-stop-service service force callback)
      (prodigy-start-service service callback))))
(defun prodigy-toggle (&optional force)
  (interactive "P")
  (prodigy-with-refresh
   (-each (prodigy-relevant-services) 'prodigy-toggle-service)))
(define-key prodigy-mode-map (kbd "s") 'prodigy-toggle)

(global-set-key (kbd "C-<f2>") 'org-capture)
(global-set-key (kbd "M-<f2>") 'org-agenda)
(global-set-key (kbd "M-<f1>") '(lambda () (interactive)
                                  (op/do-publication t nil t t)))

(global-set-key (kbd "C-/") 'undo-tree-visualize)

;; (sp-pair "'" nil :actions :rem)
;; (sp-pair "`" nil :actions :rem)
;; (add-hook 'lisp-mode smartparens-strict-mode)
;; (add-hook 'clojure-mode smartparens-strict-mode)
;; (add-hook 'org-mode smartparens-mode)
;; (mapc (lambda (mode)
;;         (add-hook (intern (format "%s-hook" (symbol-name mode))) 'smartparens-strict-mode))
;;       sp--lisp-modes)

;; (mapc (lambda (info)
;;         (let ((key (kbd (car info)))
;;               (function (car (cdr info))))
;;           (define-key sp-keymap key function)))
;;       '(("C-M-f" sp-forward-sexp)
;;         ("C-M-b" sp-backward-sexp)
;;         ("C-k" sp-kill-hybrid-sexp)
;;         ("C-M-d" sp-down-sexp)
;;         ("C-M-a" sp-backward-down-sexp)
;;         ("C-S-a" sp-beginning-of-sexp)
;;         ("C-S-d" sp-end-of-sexp)

;;         ("C-M-e" sp-up-sexp)

;;         ("C-M-u" sp-backward-up-sexp)
;;         ("C-M-t" sp-transpose-sexp)

;;         ("C-M-n" sp-next-sexp)
;;         ("C-M-p" sp-previous-sexp)

;;         ("C-M-w" sp-copy-sexp)

;;         ("M-<delete>" sp-unwrap-sexp)
;;         ("M-S-<backspace>" sp-backward-kill-symbol)

;;         ("C-<right>" sp-forward-slurp-sexp)
;;         ("C-<left>" sp-forward-barf-sexp)

;;         ("C-M-<right>" sp-backward-barf-sexp)
;;         ("M-D" sp-splice-sexp)
;;         ("M-k" sp-splice-sexp-killing-around)
;;         ("C-M-<delete>" sp-splice-sexp-killing-forward)
;;         ("C-M-<backspace>" sp-splice-sexp-killing-backward)
;;         ("C-S-<backspace>" sp-splice-sexp-killing-around)

;;         ("C-]" sp-select-next-thing-exchange)
;;         ("C-<left_bracket>" sp-select-previous-thing)
;;         ("C-M-]" sp-select-next-thing)

;;         ("M-F" sp-forward-symbol)
;;         ("M-B" sp-backward-symbol)))
;; (define-key emacs-lisp-mode-map (kbd ")") 'sp-up-sexp)

(global-set-key (kbd "C-c n") 'indent-and-cleanup-buffer)

(require 'use-package)
(setq backup-directory-alist `(("." . "~/.saves")))

(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
      backup-directory-alist `((".*" . ,temporary-file-directory)))

(setq cider-popup-stacktraces t)
(setq cider-auto-select-error-buffer t)
(setq nrepl-hide-special-buffers nil)
(setq cider-repl-result-prefix "---> ")

(defun setup-ui ()
  "Activates UI customizations."
  (interactive)
  (blink-cursor-mode 0)
  (fset 'yes-or-no-p 'y-or-n-p)
  (if (daemonp)
      (add-hook 'after-make-frame-functions
                (lambda (frame)
                  (scroll-bar-mode 0)))
    (scroll-bar-mode 0))
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (set-default 'truncate-lines t)
  (electric-indent-mode 1)
  (setq echo-keystrokes 0.01)
  (setq frame-title-format '("%f - " user-real-login-name "@" system-name))
  (setq inhibit-startup-screen t)
  (scroll-bar-mode 0)
  (global-auto-revert-mode 1)

  (setq linum-format " %d ")
  (setq show-paren-delay 0)
  (setq truncate-partial-width-windows t)
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (setq show-help-function nil)
  (which-function-mode t)
  (setq confirm-nonexistent-file-or-buffer nil))

(setup-ui)

(setq default-frame-alist '((font-backend . "xft")
                            (font . "Fantasque Sans Mono-10")
                            (vertical-scroll-bars . 0)
                            (menu-bar-lines . 0)
                            (tool-bar-lines . 0)))



(global-rainbow-delimiters-mode)
(setq recentf-max-menu-items 300)
(add-hook 'cider-repl-mode-hook 'subword-mode)
(add-hook 'clojure-mode-hook 'subword-mode)

(setq byte-compile-warnings '(not nresolved
                                  free-vars
                                  callargs
                                  redefine
                                  obsolete
                                  noruntime
                                  cl-functions
                                  interactive-only))

(setq inferior-lisp-program "sbcl")

(defvar tex-compile-commands
  '(("pdflatex --interaction=nonstopmode %f")))

(setq x-select-enable-clipboard t)

(whole-line-or-region-mode +1)

(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc)

;; (use-package helm-swoop
;;   :commands helm-swoop
;;   :init
;;   (bind-key "C-s" 'helm-swoop)
;;   :config (progn (setq helm-swoop-font-size-change: nil)
;;               (setq helm-swoop-pre-input-function (lambda ()
;;                                                     "Pre input function. Utilize region and at point symbol"
;;                                                     ""))))

(setq slime-lisp-implementations '(("sbcl" ("sbcl" "--dynamic-space-size" "2048"))))

(global-set-key (kbd "C-<tab>") 'list-command-history)
(global-set-key (kbd "C-x C-r") 'helm-recentf)
(global-set-key (kbd "C-c h") 'helm-mini)
(recentf-mode 1)

(global-set-key (kbd "<f1>") 'eshell)
(global-set-key (kbd "C-z") 'zop-to-char)

(global-set-key (kbd "C-x g") 'ag)
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; (require 'shm)
;; (add-hook 'haskell-mode-hook 'structured-haskell-mode)


(ido-mode 1)
(ido-everywhere 1)

(setq ido-use-faces nil)

(require 'clj-refactor)
(add-hook 'clojure-mode-hook (lambda ()
                               (clj-refactor-mode 1)
                               (cljr-add-keybindings-with-prefix "C-c C-a")
                               ))

;; (add-hook 'clojure-mode-hook 'yas/minor-mode-on)

;; (require 'yasnippet)
;; (yas/load-directory "~/.emacs.d/snippets")

(defun push-mark-no-activate ()
  (interactive)
  (push-mark (point) t nil)
  (message "Pushed mark to ring"))

(defun jump-to-mark ()
  (interactive)
  (set-mark-command 1))

(global-set-key (kbd "C-+") 'push-mark-no-activate)
(global-set-key (kbd "M-+") 'jump-to-mark)
(global-set-key (kbd "C-c y") 'browse-kill-ring)
;; (global-set-key (kbd "C-r") 'er/expand-region)
;; (setq-default line-spacing 0)

;; (require 'cider)
;; (require 'cider-macroexpansion)
;; (add-hook 'cider-mode-hook 'cider-macroexpansion-minor-mode)
(global-set-key (kbd "C-h C-m") 'discover-my-major)

;; (require 'latex)

(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e/")
(require 'mu4e)

(setq mu4e-maildir "~/Maildir/john.lou.walker")

(setq mu4e-drafts-folder "/[Gmail].Drafts")
(setq mu4e-sent-folder   "/[Gmail].Sent Mail")
(setq mu4e-trash-folder  "/[Gmail].Trash")

;; don't save message to Sent Messages, Gmail/IMAP takes care of this
(setq mu4e-sent-messages-behavior 'delete)

;; setup some handy shortcuts
;; you can quickly switch to your Inbox -- press ``ji''
;; then, when you want archive some messages, move them to
;; the 'All Mail' folder by pressing ``ma''.

(setq mu4e-maildir-shortcuts
      '( ("/INBOX"               . ?i)
         ("/[Gmail].Sent Mail"   . ?s)
         ("/[Gmail].Trash"       . ?t)
         ("/[Gmail].All Mail"    . ?a)))

;; allow for updating mail using 'U' in the main view:
(setq mu4e-get-mail-command "offlineimap")

;; something about ourselves
(setq
 user-mail-address "john.lou.walker@gmail.com"
 user-full-name  "John L. Walker"
 mu4e-compose-signature
 (concat
  "John L. Walker\n"
  "http://johnwalker.github.io\n"))

(require 'smtpmail)

;; alternatively, for emacs-24 you can use:
(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-stream-type 'starttls
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)

;; don't keep message buffers around
(setq message-kill-buffer-on-exit t)

;; (require 'workgroups2)

;; (setq wg-prefix-key (kbd "s-s"))
;; (setq wg-default-session-file "~/.emacs.d/.emacs_workgroups")

;; (global-set-key (kbd "s-s s-r")     'wg-reload-session)
;; (global-set-key (kbd "s-s s-s") 'wg-save-session)
;; (global-set-key (kbd "s-s s-w") 'wg-switch-to-workgroup)
;; (global-set-key (kbd "s-s s-p")         'wg-switch-to-previous-workgroup)
;; (workgroups-mode 1)

(require 'cl)
(defun save-frame-configuration ()
  (interactive)
  (let
      ((fs)(f))
    (setq fs (loop for c in (cdr (current-frame-configuration))
                   collect (progn
                             (setq f (cadr c))
                             (reduce (lambda (acc a) (if (find (symbol-name (car a)) '("top" "left" "width" "height") :test 'equal) (cons a acc) acc)) f :initial-value 'nil)
                             )))
    ;; fs contains a list of attribs for each frame
    (save-window-excursion
      (find-file "~/.e_last_frame_config.el")
      (erase-buffer)
      (print (cons 'version 1) (current-buffer))
      (print fs (current-buffer))
      (save-buffer))))

(defun load-frame-configuration ()

  "load the last saved frame configuration, if it exists"
  (interactive)
  (let
      ((v) (fs))
    (if (file-exists-p "~/.e_last_frame_config.el")
        (save-window-excursion
          (find-file "~/.e_last_frame_config.el")
          (beginning-of-buffer)
          (setq v (read (current-buffer)))
          (if (not (and (equal 'version (car v)) (= 1 (cdr v))))
              (error "version %i not understood" (cdr v)))
          (setq fs (read (current-buffer)))
          (loop for f in fs do
                (make-frame f)))
      (message "~/.e_last_frame_config.el not found. not loaded"))))



(global-set-key (kbd "s-SPC") 'rectangle-mark-mode)

(global-set-key (kbd "C-<up>") 'scroll-up-line)
(global-set-key (kbd "C-<down>") 'scroll-down-line)

(add-hook 'after-make-frame-functions
          '(lambda (frame)
             (modify-frame-parameters frame
                                      '((vertical-scroll-bars . nil)
                                        (horizontal-scroll-bars . nil)))))

(horizontal-scroll-bar-mode -1)
(scroll-bar-mode -1)

(set-frame-parameter (selected-frame) 'alpha '(85 50))

(require 'register-channel)
(register-channel-mode 1)
