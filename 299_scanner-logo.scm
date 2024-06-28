;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;; scanner-logo.scm  -*-scheme-*-
;; draw the specified text with gradient over a background 
;; with a drop shadow and a cut side.  Majority of the code was shamelessly 
;; stolen from Spencer Kimball's basic2-logo.scm script.
;;
;; This is a version compatible with GIMP v1.1., formerly basic3-logo.scm.
;;
;; Copyright (C) 1999 by Jaroslav Benkovsky <Edheldil@atlas.cz>
;; Original code is Copyright (C) 1998 by Spencer Kimball
;; Released under General Public License (GPL)
;;
;; Changes:
;;   - changed highlight to cut-side (changed its signum)
;;   - shadow and cut-side offsets are computed relative to text size
;;   - cut-side color and blending are parameters
;;   - changed default values :)
;;   - select gradient
;;   - adapted to GIMP 1.1
;;   - adapted to GIMP 1.1.22
;;
;; RCS: $Id: scanner-logo.scm,v 1.3 2000/06/26 01:01:47 benkovsk Exp $

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))


(define (script-fu-scanner-logo text size font text-color use-gradient? text-gradient cut-color bg-color)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
	 (text-layer (car (gimp-text-fontname img -1 0 0 text 10 TRUE size PIXELS font)))
	 (width (car (gimp-drawable-get-width text-layer)))
	 (height (car (gimp-drawable-get-height text-layer)))
	 (bg-layer (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	 (cut-layer (car (gimp-layer-copy text-layer TRUE)))
	 (shadow-layer (car (gimp-layer-new img width height RGBA-IMAGE "Shadow" 100 LAYER-MODE-MULTIPLY-LEGACY)))
	 (cut-ofs (+ (/ size 100) 1))
	 (shadow-ofs (+ (/ size 50) 1))
	 (old-fg (car (gimp-context-get-foreground)))
	 (old-bg (car (gimp-context-get-background)))
         (old-grad (car (gimp-context-get-gradient)))
)

    (gimp-image-undo-disable img)
    	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (gimp-image-resize img width height 0 0)
    (gimp-image-insert-layer img bg-layer 0 1)
    (gimp-image-insert-layer img shadow-layer 0 1)
    (gimp-image-insert-layer img cut-layer 0 1)

    (gimp-drawable-edit-clear shadow-layer)

    (gimp-context-set-background cut-color)
    (gimp-layer-set-lock-alpha cut-layer TRUE)
    (gimp-drawable-edit-fill cut-layer FILL-BACKGROUND)

    (gimp-context-set-background bg-color)
    (gimp-drawable-fill bg-layer FILL-BACKGROUND)

    (gimp-image-select-item img 2 text-layer)
    (gimp-context-set-background '(0 0 0))
    (gimp-selection-feather img 7.5)
    (gimp-drawable-edit-fill shadow-layer FILL-BACKGROUND)
    (gimp-selection-none img)

    (gimp-context-set-background text-color)
    (gimp-layer-set-lock-alpha text-layer TRUE)
    (gimp-drawable-edit-fill text-layer FILL-BACKGROUND)

    (if (= use-gradient? TRUE)
	(begin
	  (gimp-layer-set-lock-alpha text-layer TRUE)
(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
	  (gimp-context-set-gradient text-gradient)
	 ; (gimp-blend text-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-RADIAL 100 20 REPEAT-NONE FALSE 0 0 0 0 0 0 width height)
	(gimp-drawable-edit-gradient-fill text-layer 2 20 1 1 0.0 FALSE 0 0 width height)
	))

    (gimp-item-transform-translate shadow-layer shadow-ofs shadow-ofs)
    (gimp-item-transform-translate cut-layer cut-ofs cut-ofs)
    (gimp-item-set-name text-layer text)
    (gimp-item-set-name cut-layer "Cut")
    (gimp-context-set-background old-bg)
    (gimp-context-set-foreground old-fg)
    (gimp-context-set-gradient old-grad)
    (gimp-image-undo-enable img)
        	(gimp-context-pop)
    (gimp-display-new img)))

(script-fu-register "script-fu-scanner-logo"
		    "Scanner Logo"
		    "Creates a simple logo with a gradient text, a shadow and a cut side"
		    "Jaroslav Benkovsky <Edheldil@atlas.cz>"
		    "Spencer Kimball, Jaroslav Benkovsky"
		    "June 2000"
		    ""
		    SF-STRING   "Text String"      "Scanner Logo"
		    SF-ADJUSTMENT "Font Size (pixels)" '(100 2 1000 1 10 0 1)
		    SF-FONT     "Font"             "charter bold italic"
		    SF-COLOR    "Text Color"       '(66 3 122)
                    SF-TOGGLE   "Use Gradient"     TRUE
                    SF-GRADIENT "Gradient"         "Tropical Colors"
		    SF-COLOR    "Cut Color"        '(255 255 255)
		    SF-COLOR    "Background Color" '(255 255 255))

(script-fu-menu-register
	"script-fu-scanner-logo"
	; "<Toolbox>/Xtns/Logos"
	"<Image>/File/Create/Logos"
)
; End of file scanner-logo.scm
