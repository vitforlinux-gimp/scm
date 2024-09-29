;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;; old-style-logo.scm  -*-scheme-*-
;; draw the specified text with gradient over a background 
;; with a drop shadow and a cut side.  Majority of the code was shamelessly 
;; stolen from Spencer Kimball's basic2-logo.scm script.
;;
;;Old Style Logo based on Scanner Logo 2.10 rel 0.01
;;by vitforlinux
;;

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))
(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "QTBodiniPoster Italic")
  (define sffont "QTBodiniPoster-Italic"))


(define (script-fu-old-style-logo-299 text size font justification letter-spacing line-spacing text-color  use-second-col? text-color2 use-gradient?  text-gradient cut-color bg-color second 45deg worn shadow vignette conserve)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
	 (text-layer (car (gimp-text-fontname img -1 0 0 text 10 TRUE size PIXELS font)))
	 (width (car (gimp-drawable-get-width text-layer)))
	 (height (car (gimp-drawable-get-height text-layer)))
	 (bg-layer (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	 (cut-layer (car (gimp-layer-copy text-layer TRUE)))
	 (shadow-layer (car (gimp-layer-new img width height RGBA-IMAGE "Shadow" 100 LAYER-MODE-MULTIPLY-LEGACY)))
	 (cut-ofs (+ (/ size 100) 1))
	 (shadow-ofs (+ (/ size 50) 1))
	 (textmask)
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
   
            (if (= worn TRUE)
	(begin
   (define textmask (car (gimp-layer-create-mask text-layer ADD-MASK-WHITE)))
   (gimp-layer-add-mask text-layer textmask)

	 (plug-in-solid-noise 1 img textmask FALSE TRUE 0 1 4 4)
	 		(gimp-drawable-brightness-contrast textmask 0.5 0.5 )
			(plug-in-gauss-iir TRUE img textmask 6 TRUE TRUE)
			(gimp-drawable-invert textmask TRUE)
))



         (gimp-text-layer-set-letter-spacing cut-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification cut-layer justification) ; Text Justification 
   (gimp-text-layer-set-line-spacing cut-layer line-spacing)      ; Set Line Spacing
   
   (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
   
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
    ;(gimp-selection-feather img 7.5)
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
    
    ;lined
    (if (= second 1)
    (begin
    (gimp-image-select-item img 2 text-layer)
    (gimp-layer-set-lock-alpha text-layer FALSE)
   ; (gimp-context-set-gradient (caadr (gimp-gradients-get-list "")))
   (gimp-selection-shrink img (round (/ size 20)) )
   (gimp-drawable-edit-clear text-layer)
    (gimp-selection-grow img 1 )
    (gimp-context-set-background text-color2)
     (gimp-context-set-foreground text-color )
  ; (gimp-context-set-gradient "Da pp a sf (bordi netti)")
 ; (gimp-context-set-gradient _"FG to BG (Hardedge)")
  ;(gimp-context-set-pattern (list-ref (cadr (gimp-patterns-get-list "")) 0)) 
  ;(list-ref (cadr (gimp-gradients-get-list "")) 1)
;(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 1))
			(if (= use-second-col? FALSE)	(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
		(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 6)) 
		(gimp-context-set-gradient (car (gimp-gradient-get-by-name(list-ref (car (gimp-gradients-get-list "")) 6)))) )) 
		(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
		(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 1)) 
		(gimp-context-set-gradient (car (gimp-gradient-get-by-name(list-ref (car (gimp-gradients-get-list "")) 4)))) )))
 
  ;(gimp-context-set-gradient "Abstract 1")
 ; (gimp-context-set-paint-mode LAYER-MODE-COLOR-ERASE-LEGACY)
  (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
  (if (= 45deg TRUE)     (gimp-drawable-edit-gradient-fill text-layer 0 0 TRUE 1 0 TRUE 0 0 (round (/ size 20)) (round (/ size 20)))
    (gimp-drawable-edit-gradient-fill text-layer 0 0 TRUE 1 0 TRUE 0 0 0 (round (/ size 20))))
    ;(gimp-by-color-select text-layer text-color2 127 2 FALSE FALSE 0 FALSE)
    (gimp-layer-set-lock-alpha text-layer FALSE)
    ;(gimp-selection-invert img)
    ;(if (= use-second-col? FALSE) (gimp-drawable-edit-clear text-layer))
    
   
    ))
    ;lined slim
        (if (= second 2)
    (begin
    (gimp-image-select-item img 2 text-layer)
    
   ; (gimp-context-set-gradient (caadr (gimp-gradients-get-list "")))
   (gimp-selection-shrink img (round (/ size 33)) )
   (gimp-layer-set-lock-alpha text-layer FALSE)
   (gimp-drawable-edit-clear text-layer)
   (gimp-selection-grow img 1 )
    (gimp-context-set-background text-color2)
     (gimp-context-set-foreground text-color )
;(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 1))
			(if (= use-second-col? FALSE)	(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
		(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 6)) 
		(gimp-context-set-gradient (car (gimp-gradient-get-by-name(list-ref (car (gimp-gradients-get-list "")) 6)))) )) 
		(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
		(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 1)) 
		(gimp-context-set-gradient (car (gimp-gradient-get-by-name(list-ref (car (gimp-gradients-get-list "")) 4)))) )))
  (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
      (if (= 45deg TRUE)     (gimp-drawable-edit-gradient-fill text-layer 0 0 TRUE 1 0 TRUE 0 0 (round (/ size 33)) (round (/ size 33)))
    (gimp-drawable-edit-gradient-fill text-layer 0 0 TRUE 1 0 TRUE 0 0 0 (round (/ size 33))))
    ;(gimp-by-color-select text-layer text-color2 127 2 FALSE FALSE 0 FALSE)
    (gimp-layer-set-lock-alpha text-layer FALSE)
  ;(if (= use-second-col? FALSE) (gimp-drawable-edit-clear text-layer))
    
   
    ))
    ;light
        (if (= second 3)
    (begin
    (gimp-image-select-item img 2 text-layer)
   (gimp-selection-shrink img (round (/ size 20)) )
  ; (gimp-drawable-edit-clear text-layer)
    (gimp-context-set-background text-color)
     (gimp-context-set-foreground text-color2 )
  (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
    (gimp-layer-set-lock-alpha text-layer FALSE)
 ;(if (= use-second-col? FALSE) (gimp-drawable-edit-clear text-layer))
 ; (if (= use-second-col? TRUE) (gimp-drawable-edit-fill text-layer FILL-FOREGROUND))
    )
    )
            (if (= use-gradient? TRUE)
	(begin
	(gimp-selection-none img)
	  (gimp-layer-set-lock-alpha text-layer TRUE)
(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
	  (gimp-context-set-gradient text-gradient)
	 ; (gimp-blend text-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-RADIAL 100 20 REPEAT-NONE FALSE 0 0 0 0 0 0 width height)
	   (if (= use-second-col? TRUE) ;(gimp-by-color-select text-layer text-color 127 2 TRUE FALSE 0 FALSE)
	   (gimp-image-select-color img 2 text-layer text-color))
	   (gimp-selection-feather img 1)
	(gimp-drawable-edit-gradient-fill text-layer 2 20 REPEAT-NONE 1 0.0 FALSE 0 0 width height)
	))
	(gimp-selection-none img)
   ; (gimp-layer-set-lock-alpha text-layer FALSE)
   ; (plug-in-gauss-rle2 0 img text-layer 1 1 )
   ; (plug-in-oilify 0 img text-layer 2 1)
    (if (= vignette TRUE)
(begin
            (gimp-image-select-ellipse
            img
            CHANNEL-OP-REPLACE
            0
	    0
            (car (gimp-image-get-width img))
           (car (gimp-image-get-height img))
        )
	(gimp-selection-invert img)
    (gimp-selection-feather img (round (* size 2)))
   ; (gimp-context-set-opacity 70)
	(gimp-context-set-background '(0 0 0))
    (gimp-drawable-edit-fill bg-layer FILL-BACKGROUND)))
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

(script-fu-register "script-fu-old-style-logo-299"
		    "Old Style Logo 299"
		    "Creates a old stile logo with a gradient text, a shadow and a cut side, pseudo vignette effect"
		    "vitforlinux-gimp.github.com"
		    "Spencer Kimball, Jaroslav Benkovsky, Vitforlinux"
		    "June 2000"
		    ""
		    SF-TEXT   "Text String"      "Old Style\nLogo"
		    SF-ADJUSTMENT "Font Size (pixels)" '(100 2 1000 1 10 0 0)
		    SF-FONT     "Font"            sffont
			SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
			SF-ADJUSTMENT _"Letter Spacing"        '(5 -50 50 1 5 0 0)
                    SF-ADJUSTMENT _"Line Spacing"          '(0 -300 300 1 10 0 0)
		    SF-COLOR    "Text fill Color"       '(66 3 122)
		     SF-TOGGLE   "Use second fill color "     FALSE
		     SF-COLOR    "Second fill Color"       '(255 184 43)
                    SF-TOGGLE   "Use Gradient"     FALSE
                    SF-GRADIENT "Gradient"         "Tropical Colors"
		    SF-COLOR    "Cut Color"        '(66 3 122)
		    SF-COLOR    "Background Color" '(255 255 255)
		    SF-OPTION   "Style"     '("Default" "Lined" "Lined slim" "Light")
		    SF-TOGGLE   "Use lines 45 degrees"     FALSE
		    SF-TOGGLE   "Fake worn"     FALSE
		    SF-TOGGLE   "Use Shadow"     FALSE
		    SF-TOGGLE   "Use Vignette"     TRUE
		    SF-TOGGLE   "Merge Layers"     TRUE
		    )

(script-fu-menu-register
	"script-fu-old-style-logo-299"
	; "<Toolbox>/Xtns/Logos"
	"<Image>/File/Create/Logos"
)
; End of file old-style-logo.scm
