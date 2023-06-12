;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;; old-style-logo.scm  -*-scheme-*-
;; draw the specified text with gradient over a background 
;; with a drop shadow and a cut side.  Majority of the code was shamelessly 
;; stolen from Spencer Kimball's basic2-logo.scm script.
;;
;;Old Style Logo based on Scanner Logo 2.10 rel 0.01
;;by vitforlinux
;;



(define (script-fu-old-style-logo text size font justification letter-spacing line-spacing text-color use-gradient? text-gradient cut-color bg-color second shadow vignette conserve)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
	 (text-layer (car (gimp-text-fontname img -1 0 0 text 10 TRUE size PIXELS font)))
	 (width (car (gimp-drawable-width text-layer)))
	 (height (car (gimp-drawable-height text-layer)))
	 (bg-layer (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	 (cut-layer (car (gimp-layer-copy text-layer TRUE)))
	 (shadow-layer (car (gimp-layer-new img width height RGBA-IMAGE "Shadow" 100 LAYER-MODE-MULTIPLY-LEGACY)))
	 (cut-ofs (+ (/ size 100) 1))
	 (shadow-ofs (+ (/ size 50) 1))
	 (old-fg (car (gimp-context-get-foreground)))
	 (old-bg (car (gimp-context-get-background)))
         (old-grad (car (gimp-context-get-gradient)))
	 			  		  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
)

    (gimp-image-undo-disable img)
    (gimp-image-resize img (+ width 50) (+ height 60) 10 30)
    (gimp-image-insert-layer img bg-layer 0 1)
    (gimp-image-insert-layer img shadow-layer 0 1)
    (gimp-image-insert-layer img cut-layer 0 1)

    (gimp-drawable-edit-clear shadow-layer)
      (gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification text-layer justification) ; Text Justification 
   (gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing


         (gimp-text-layer-set-letter-spacing cut-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification cut-layer justification) ; Text Justification 
   (gimp-text-layer-set-line-spacing cut-layer line-spacing)      ; Set Line Spacing
   
   (gimp-layer-resize-to-image-size cut-layer)
    (gimp-context-set-background cut-color)
    (gimp-layer-set-lock-alpha cut-layer TRUE)
    (gimp-drawable-edit-fill cut-layer FILL-BACKGROUND)
   (gimp-image-resize-to-layers img)
(gimp-layer-resize-to-image-size bg-layer)
    (gimp-context-set-background bg-color)
    (gimp-drawable-fill bg-layer FILL-BACKGROUND)

    (gimp-image-select-item img 2 text-layer)
    (gimp-context-set-background '(0 0 0))
    (gimp-selection-feather img 7.5)
    (gimp-layer-resize-to-image-size shadow-layer)
    (gimp-drawable-edit-fill shadow-layer FILL-BACKGROUND)
    (gimp-selection-none img)

    (gimp-context-set-background text-color)
    (gimp-layer-set-lock-alpha text-layer TRUE)
    (gimp-drawable-edit-fill text-layer FILL-BACKGROUND)




    (gimp-item-transform-translate shadow-layer shadow-ofs shadow-ofs)
    (gimp-item-transform-translate cut-layer (+ cut-ofs (round (/ size 100)) 20 ) (+ cut-ofs (round (/ size 100)) 40))
   ;(gimp-item-transform-translate cut-layer 10 10)
    (gimp-item-set-name text-layer text)
    (gimp-item-set-name cut-layer "Cut")
    
    (gimp-layer-set-lock-alpha cut-layer FALSE)
     (gimp-image-select-item img 2 text-layer)
     (gimp-drawable-edit-clear cut-layer)
     (gimp-drawable-edit-clear shadow-layer)
         (gimp-selection-none img)
      (gimp-item-transform-translate text-layer (-(round (/ size 50))) (-(round (/ size 50))))
    (gimp-item-transform-translate shadow-layer 1 1)
    (gimp-layer-resize-to-image-size cut-layer)
    (if (= second 1)
    (begin
    (gimp-image-select-item img 2 text-layer)
    
   ; (gimp-context-set-gradient (caadr (gimp-gradients-get-list "")))
   (gimp-selection-shrink img (round (/ size 20)) )
   (gimp-drawable-edit-clear text-layer)
    (gimp-context-set-background text-color)
     (gimp-context-set-foreground bg-color )
  ; (gimp-context-set-gradient "Da pp a sf (bordi netti)")
 ; (gimp-context-set-gradient _"FG to BG (Hardedge)")
  ;(gimp-context-set-pattern (list-ref (cadr (gimp-patterns-get-list "")) 0)) 
  ;(list-ref (cadr (gimp-gradients-get-list "")) 1)
(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 1))
 
  ;(gimp-context-set-gradient "Abstract 1")
 ; (gimp-context-set-paint-mode LAYER-MODE-COLOR-ERASE-LEGACY)
  (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
    (gimp-drawable-edit-gradient-fill text-layer 0 0 TRUE 1 0 TRUE 0 0 0 (round (/ size 20)))
    (gimp-by-color-select text-layer bg-color 127 2 TRUE FALSE 0 FALSE)
    (gimp-layer-set-lock-alpha text-layer FALSE)
    ;(gimp-selection-invert img)
    (gimp-drawable-edit-clear text-layer)
    

    
    )
    )
    
        (if (= second 2)
    (begin
    (gimp-image-select-item img 2 text-layer)
   (gimp-selection-shrink img (round (/ size 20)) )
   (gimp-drawable-edit-clear text-layer)
    (gimp-context-set-background text-color)
     (gimp-context-set-foreground bg-color )
  (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
    (gimp-layer-set-lock-alpha text-layer FALSE)
    (gimp-drawable-edit-clear text-layer)
    )
    )
            (if (= use-gradient? TRUE)
	(begin
	(gimp-selection-none img)
	  (gimp-layer-set-lock-alpha text-layer TRUE)
(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
	  (gimp-context-set-gradient text-gradient)
	 ; (gimp-blend text-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-RADIAL 100 20 REPEAT-NONE FALSE 0 0 0 0 0 0 width height)
	(gimp-drawable-edit-gradient-fill text-layer 2 20 REPEAT-NONE FALSE 0.0 FALSE 0 0 width height)
	))
    
    (if (= vignette TRUE)
(begin
            (gimp-image-select-ellipse
            img
            CHANNEL-OP-REPLACE
            0
	    0
            (car (gimp-image-width img))
           (car (gimp-image-height img))
        )
	(gimp-selection-invert img)
    (gimp-selection-feather img (round (* size 2)))
   ; (gimp-context-set-opacity 70)
	(gimp-context-set-background '(0 0 0))
    (gimp-edit-fill bg-layer FILL-BACKGROUND)))
(if (= shadow FALSE)
(begin
(gimp-selection-none img)
 (gimp-drawable-edit-clear shadow-layer)
 )
)
	(if (and (= conserve TRUE)) (gimp-image-flatten img))	

    (gimp-selection-none img)
    (gimp-context-set-background old-bg)
    (gimp-context-set-foreground old-fg)
    (gimp-context-set-gradient old-grad)
    (gimp-image-undo-enable img)
    (gimp-display-new img)))

(script-fu-register "script-fu-old-style-logo"
		    "Old Style Logo"
		    "Creates a old stile logo with a gradient text, a shadow and a cut side, pseudo vignette effect"
		    "vitforlinux-gimp.github.com"
		    "Spencer Kimball, Jaroslav Benkovsky, Vitforlinux"
		    "June 2000"
		    ""
		    SF-TEXT   "Text String"      "Old Style\nLogo"
		    SF-ADJUSTMENT "Font Size (pixels)" '(100 2 1000 1 10 0 0)
		    SF-FONT     "Font"             "serif bold italic"
			SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
			SF-ADJUSTMENT _"Letter Spacing"        '(5 -50 50 1 5 0 0)
                    SF-ADJUSTMENT _"Line Spacing"          '(0 -300 300 1 10 0 0)
		    SF-COLOR    "Text Color"       '(66 3 122)
                    SF-TOGGLE   "Use Gradient"     FALSE
                    SF-GRADIENT "Gradient"         "Tropical Colors"
		    SF-COLOR    "Cut Color"        '(66 3 122)
		    SF-COLOR    "Background Color" '(255 255 255)
		    SF-OPTION   "Style"     '("Default" "Lined" "Light")
		    SF-TOGGLE   "Use Shadow"     FALSE
		    SF-TOGGLE   "Use Vignette"     TRUE
		    SF-TOGGLE   "Merge Layers"     TRUE
		    )

(script-fu-menu-register
	"script-fu-old-style-logo"
	; "<Toolbox>/Xtns/Logos"
	"<Image>/File/Create/Logos"
)
; End of file old-style-logo.scm
