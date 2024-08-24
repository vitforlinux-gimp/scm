;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

; Define the function:

(define (script-fu-skywriting inText inSize inFont  justification letter-spacing line-spacing grow-text outline color foption scolor grad pat)
        ; backup the current colours and brushes so we 
        ; can restore them later
(gimp-context-push)

        ; create an image and a layer in that image
(let* (
	(buffer 30)
	(img (car (gimp-image-new 256 256 RGB))) 
	(theText (car (gimp-text-fontname img -1 buffer buffer inText (+ (/ inSize 10) 10) 1 inSize PIXELS inFont)))
	(width (car (gimp-drawable-get-width theText)))
	(height (car (gimp-drawable-get-height theText)))
	(imwidth (+ width buffer buffer))
	(imheight (+ height buffer buffer))
	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))	
      )
	      (gimp-text-layer-set-letter-spacing theText letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification theText justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing theText line-spacing)      ; Set Line Spacing    
   
   

	
	(gimp-layer-resize theText (+(car (gimp-drawable-get-width theText)) buffer buffer ) (+ (car (gimp-drawable-get-height theText)) buffer buffer ) 0 0)	;add
	(gimp-image-resize img (car (gimp-drawable-get-width theText)) (car (gimp-drawable-get-height theText)) 0 0)		;add
   ;;;;;; SHRINK/GROW text
(cond ((> grow-text 0)
	(gimp-selection-none img)
	(gimp-image-select-item img 2 theText)
	(gimp-selection-grow img (round grow-text))   
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none img)
	(gimp-image-select-item img 2 theText)
	(gimp-drawable-edit-clear theText)
	(gimp-selection-shrink img (- grow-text))   
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 ))

  ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none img)
	(gimp-image-select-item img 2 theText)
	(gimp-selection-shrink img (round outline))   
	(gimp-drawable-edit-clear theText)
	(gimp-image-select-item img 2 theText)
 ))
	
(script-fu-skywritingcore img theText inSize color foption scolor grad pat)


        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; CLEAN UP
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
(gimp-context-pop)
	(gimp-display-new img)      ; make the image appear
	(gimp-selection-none img)   ; deselect everything
	(gimp-image-clean-all img)  ; clear the UNDO buffer
)
)

; Register the function with the GIMP:

(script-fu-register
    "script-fu-skywriting"
    "Skywriting"
    "Writing with clouds"
    "My Name"
    "Copyright stuff"
    "Date"
    ""
    SF-TEXT		"Text"		"Skywriting"
    SF-ADJUSTMENT	"Font size"	'(200 2 1000 1 10 0 0)
    SF-FONT		"Font"		"Roboto Heavy"
SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
      SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -40 40 1 10 0 0)
        SF-ADJUSTMENT _"Outline"          '(0 0 40 1 10 0 0)
    SF-COLOR		"Textcolor:"	'(255 255 255)
    SF-OPTION		"Sky mode"		'(_"color" _"gradient" _"pattern")
    SF-COLOR		"Sky color:"	'(80 80 200)
    SF-GRADIENT		"Sky Gradient"	"Deep Sea"
    SF-PATTERN		"Sky Pattern"	"Blue Web"
)
(script-fu-menu-register "script-fu-skywriting"
		_"<Image>/File/Create/Logos/"
)

(define (script-fu-skywritingimg img drawable inSize color foption scolor grad pat)
        ; backup the current colours and brushes so we 
        ; can restore them later
(gimp-context-push)

(let* (
	(buffer 30)
	(width (car (gimp-drawable-get-width drawable)))
	(height (car (gimp-drawable-get-height drawable)))
	(imwidth (+ width buffer buffer))
	(imheight (+ height buffer buffer))
      )

        ; create an image and a layer in that image

(gimp-image-undo-group-start img)

	(gimp-image-resize img imwidth imheight buffer buffer)		;add
	(gimp-layer-resize drawable imwidth imheight (* 2 buffer) (* 2 buffer))	;add

(script-fu-skywritingcore img drawable inSize color foption scolor grad pat)

(gimp-image-undo-group-end img)

(gimp-context-pop)

(gimp-displays-flush)
)
)

;âÊëúâ¡çHñ{ëÃ
(define (script-fu-skywritingimgh img drawable inSize color foption scolor grad pat)
  (let* (
	(img2 (car (gimp-image-duplicate img)))
	(drawable2 (car (gimp-image-get-active-layer img2)))
	)
	(gimp-image-undo-disable img2)
	(gimp-layer-resize-to-image-size drawable2)
	(script-fu-skywritingimg img2 drawable2 inSize color foption scolor grad pat)
	(gimp-image-undo-enable img2)
	(gimp-display-new img2)
  )
)

(script-fu-register
    "script-fu-skywritingimgh"
    "Skywriting Alpha"
    "Draws a Cloud"
    "My Name"
    "Copyright stuff"
    "Date"
    "RGBA"
	SF-IMAGE	"Image"			0
	SF-DRAWABLE	"Drawable"		0
	SF-ADJUSTMENT	"Size"			'(120 2 1000 1 10 0 0)
	SF-COLOR	"Cloud color:"		'(255 255 255)
	SF-OPTION	"Sky mode"		'(_"color" _"gradient" _"pattern")
	SF-COLOR	"Sky color:"		'(80 80 200)
	SF-GRADIENT	"Sky Gradient"		"Deep Sea"
	SF-PATTERN	"Sky Pattern"		"Blue Web"
)

(script-fu-menu-register "script-fu-skywritingimgh"
		_"<Image>/Script-Fu/Alpha-to-Logo/"
)

(define (script-fu-skywritingcore img theText inSize color foption scolor grad pat)
        ; backup the current colours and brushes so we 
        ; can restore them later
(gimp-context-push)

        ; create an image and a layer in that image
(let* (
	(buffer 30)
	 (width (car (gimp-drawable-get-width theText)))
	 (height (car (gimp-drawable-get-height theText)))
	(imwidth (+ width buffer buffer))
	(imheight (+ height buffer buffer))
      )

	;(gimp-display-new img)      ; make the image appear

	(define clouds1 (car (gimp-layer-new img imwidth imheight RGBA-IMAGE "Clouds1" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer img clouds1 0 0)
	(gimp-selection-all img)
	(gimp-drawable-edit-clear clouds1)

;	(gimp-selection-all img)
;	(gimp-drawable-edit-fill theText BG-IMAGE-FILL)
;	(gimp-drawable-edit-clear theText)
	;1.2ïœçX
;	(define floatingText (car (gimp-text img theText buffer buffer inText (+ (/ inSize 12) 4) 1 inSize PIXELS "*" inFont "*" "r" "*" "*" "*" "*")))
;	(define floatingText (car (gimp-text-fontname img theText buffer buffer inText 0 1 inSize PIXELS inFont)))
;	(gimp-floating-sel-anchor floatingText)

	(define (gen-distressed-bit thr grow)
		(gimp-image-select-item img 2 theText)
		(gimp-selection-grow img grow)
;		(script-fu-distress-selection img clouds1 thr 10 4 2 1 1)	;none
		(script-fu-distress-selection img clouds1 thr (+ (* (/ inSize 700) 10) 8.4) (+ (* (/ inSize 400) 4) 3.1) (+ (* (/ inSize 700) 2) 1.657) 1 1)	;add
		;(gimp-edit-bucket-fill clouds1 FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 8 0 0 0 0)
		(gimp-context-set-opacity 8)
		(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
		(gimp-drawable-edit-fill clouds1 FILL-FOREGROUND)
	)

	(gimp-context-set-foreground color)
	(mapcar gen-distressed-bit 
		'(160 160 160 160 160 160 160 160 100 100 100 100)
		'(000 000 000 000 000 000 000 000 000 000 000 000) )
	;(gimp-image-select-item img 2 theText)
	;(gimp-bucket-fill clouds1 FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 10 0 0 0 0)
	(plug-in-gauss-rle TRUE img clouds1 6 TRUE TRUE)
	(plug-in-gauss-rle TRUE img clouds1 6 TRUE TRUE)

	(gimp-image-remove-layer img theText)
;	(gimp-layer-delete theText)		;none 2.2
	(gimp-selection-none img)
	;(define cloudText (car (gimp-image-merge-visible-layers img CLIP-TO-BOTTOM-LAYER)))

	(define bgLayer (car (gimp-layer-new img imwidth imheight RGBA-IMAGE "Blue" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer img bgLayer 0 1)
	(gimp-selection-all img)
	(gimp-context-set-foreground scolor)
	;(gimp-edit-bucket-fill bgLayer FG-BUCKET-FILL LAYER-MODE-NORMAL-LEGACY 100 0 0 0 0)
		(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
		(gimp-context-set-opacity 100)
	(gimp-drawable-edit-fill bgLayer FILL-FOREGROUND)
  (cond((= foption 1)
    (gimp-context-set-gradient grad)
   ; (gimp-edit-blend bgLayer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY 0 100 20 REPEAT-NONE FALSE FALSE 0 0 FALSE 0 0 0 height)
   				      (gimp-drawable-edit-gradient-fill bgLayer GRADIENT-LINEAR 0 0 1 0 0 0 0 0 height) ; Fill with gradient

    )
    ((= foption 2)
       (gimp-image-select-item img 2 bgLayer)
       ;(gimp-drawable-edit-clear bgLayer)
       (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
       (gimp-context-set-pattern pat)
       (gimp-drawable-edit-bucket-fill bgLayer FILL-PATTERN   100 255 )
       (gimp-selection-none img)
       )
       )
       (plug-in-autocrop 0 img bgLayer)

)
)
