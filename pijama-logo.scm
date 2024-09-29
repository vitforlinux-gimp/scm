; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "QTSchoolCentury Bold")
  (define sffont "QTSchoolCentury-Bold"))

		(define  (apply-drop-shadow img fond x y blur color opacity number) (begin
				(gimp-image-select-item img 2 fond)
				(gimp-selection-translate img x y)
				(gimp-selection-feather img blur)
				(gimp-context-set-foreground color)
				(gimp-context-set-opacity opacity)
				(gimp-image-select-item img 1 fond)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-context-set-opacity 100)
				(gimp-selection-none img)
			))

  (script-fu-register
            "script-fu-pijama-logo"                        ;function name
            "Pijama logo"                                  ;menu label
            "Create a logo with a pijama-style striped background"              ;description
            "Vitforlinux"                             ;author
            "copyright 2023, Vitfolinux;\
              2009, the GIMP Documentation Team"        ;copyright notice
            "July 8, 2023"                          ;date created
            ""                              ;image type that the script works on
            SF-TEXT      "Text"          "Pijama\nlogo"   ;a string variable
            SF-FONT        "Font"          sffont    ;a font variable
            SF-ADJUSTMENT  "Font size"     '(150 1 1000 1 10 0 0)
	     SF-COLOR       "Color"         '(0 193 160)     ;color variable
	     SF-COLOR       "Color 2"         '(255 255 255)     ;color variable
	     SF-OPTION     "Third Color Type"    '("Coherent" "User Choice")
	      SF-COLOR       "Color 3"         '(255 139 0)     ;color variable
	    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
                                                        ;a spin-button
							SF-GRADIENT    "Gradient"           "Abstract 3"
							SF-OPTION     "grad direction"    '("Diagonal" "Horizontal" "Vertical")
							SF-OPTION     "Background Color Type"    '("Coherent" "Gradient Color" "User Choice" "Transparent")
SF-COLOR       "Color"         '(141 105 224)     ;color variable							
            SF-ADJUSTMENT  "Buffer amount" '(35 0 100 1 10 1 0);a slider
							SF-TOGGLE   "Merge Layers"     TRUE
  )
  (script-fu-menu-register "script-fu-pijama-logo" "<Image>/File/Create/Logos")
  (define (script-fu-pijama-logo inText inFont inFontSize inTextColor inTextColor2 Third-type inTextColor3
					justification
					letter-spacing
					line-spacing
					grow-text
					outline
					base-grad
					grad-dir
					bg-type
					bg-color
					inBufferAmount
					conserve)
    (let*
      (
        ; define our local variables
        ; create a new image:
        (theImageWidth  10)
        (theImageHeight 10)
        (theImage)
        (theImage
                  (car
                      (gimp-image-new
                        theImageWidth
                        theImageHeight
                        RGB
                      )
                  )
        )
        (theText)             ;a declaration for the text
        (theBuffer)           ;create a new layer for the image
        (theLayer
                  (car
                      (gimp-layer-new
                        theImage
                        theImageWidth
                        theImageHeight
                        RGBA-IMAGE
                        "Background"
                        100
                        LAYER-MODE-NORMAL
                      )
                  )
        )
	 ; (old-fg (car (gimp-context-get-foreground)))
	 ; (old-bg (car (gimp-context-get-background)))
         ; (old-grad (car (gimp-context-get-gradient)))
	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
      ) ;end of our local variables
      	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (gimp-image-undo-group-start theImage)
      (gimp-image-insert-layer theImage theLayer 0 0)
      (gimp-context-set-background '(255 255 255) )
      (gimp-context-set-foreground inTextColor)
      (gimp-drawable-fill theLayer FILL-BACKGROUND)
      (set! theText
                    (car
                          (gimp-text-fontname
                          theImage theLayer
                          0 0
                          inText
                          0
                          TRUE
                          inFontSize PIXELS
                          inFont)
                      )
        )
	 (define bord1Layer (car(gimp-layer-new theImage 10 10 RGBA-IMAGE _"Bord 1 Layer" 100 LAYER-MODE-NORMAL-LEGACY)) )
   (gimp-image-insert-layer theImage bord1Layer 0 1) 
   	 (define bord2Layer (car(gimp-layer-new theImage 10 10 RGBA-IMAGE _"Bord 2 Layer" 100 LAYER-MODE-NORMAL-LEGACY)) )
   (gimp-image-insert-layer theImage bord2Layer 0 1) 
	;; text alignment
	(gimp-text-layer-set-justification theText justification) ; Text Justification (Rev Value) 
	(gimp-text-layer-set-letter-spacing theText letter-spacing)  ; Set Letter Spacing
	(gimp-text-layer-set-line-spacing theText line-spacing)      ; Set Line Spacing
	(gimp-context-set-paint-mode 0)


      (set! theImageWidth   (car (gimp-drawable-get-width  theText) ) )
      (set! theImageHeight  (car (gimp-drawable-get-height theText) ) )
      (set! theBuffer (* theImageHeight (/ inBufferAmount 100) ) )
      (set! theImageHeight (+ theImageHeight theBuffer theBuffer) )
      (set! theImageWidth  (+ theImageWidth  theBuffer theBuffer) )
      (gimp-image-resize theImage theImageWidth theImageHeight 0 0)
      (gimp-layer-resize theLayer theImageWidth theImageHeight 0 0)
      (gimp-layer-set-offsets theText theBuffer theBuffer)
      (gimp-floating-sel-to-layer theText)
      (gimp-layer-resize-to-image-size theText)
;;;; shrink grow text
(cond ((> grow-text 0)
	(gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-grow theImage (round grow-text))
(gimp-context-set-foreground inTextColor)	
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-drawable-edit-clear theText)
	(gimp-selection-shrink theImage (- grow-text)) 
	(gimp-context-set-foreground inTextColor)
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 ))
   ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-shrink theImage (round outline))   
	(gimp-drawable-edit-clear theText)
	(gimp-image-select-item theImage 2 theText)
 ))
; (gimp-image-resize-to-layers theImage)
;bord1
(gimp-layer-resize-to-image-size bord1Layer)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-grow theImage 11) 
	;(gimp-selection-invert theImage)
	(gimp-selection-flood theImage)
		(gimp-context-set-foreground inTextColor2)
	(gimp-drawable-edit-fill bord1Layer FILL-FOREGROUND)
;bord2	
(gimp-layer-resize-to-image-size bord2Layer)
	;(gimp-image-select-item theImage 2 bord1Layer)
	(gimp-selection-grow theImage 11) 
	;(gimp-selection-invert theImage)
	(gimp-selection-flood theImage)
		(if (= Third-type 0)(gimp-context-set-foreground inTextColor)(gimp-context-set-foreground inTextColor3))
	(gimp-drawable-edit-fill bord2Layer FILL-FOREGROUND)
	(gimp-image-raise-item theImage bord1Layer)
; shad
(gimp-selection-none theImage)
(apply-drop-shadow theImage theText 2 2 4 '(0 0 0) 70 0)
(apply-drop-shadow  theImage bord1Layer 2 2 4 '(0 0 0) 70 0)
(apply-drop-shadow  theImage bord2Layer 2 2 4 '(0 0 0) 70 0)
	 
(gimp-selection-none theImage)
(gimp-context-set-gradient base-grad)
 (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
(if (= grad-dir 0) (gimp-drawable-edit-gradient-fill theLayer 0 0 REPEAT-NONE 1 1 FALSE 0 0 90 45) )
(if (= grad-dir 1) (gimp-drawable-edit-gradient-fill theLayer 0 0 REPEAT-NONE 1 1 FALSE 0 0 0 45) )
(if (= grad-dir 2) (gimp-drawable-edit-gradient-fill theLayer 0 0 REPEAT-NONE 1 1 FALSE 0 0 90 0) )

(if (or (= bg-type 0) (= bg-type 2))(begin
 (gimp-drawable-desaturate theLayer 3)
 (gimp-drawable-posterize theLayer 3)
 (gimp-context-set-paint-mode 23);LAYER-MODE-OVERLAY
 	(if (= bg-type 2)(gimp-context-set-foreground bg-color)(gimp-context-set-foreground inTextColor))
	(gimp-drawable-edit-fill theLayer FILL-FOREGROUND)))
(if (= bg-type 1)(gimp-drawable-posterize theLayer 3))
(if (= bg-type 3) (gimp-image-remove-layer theImage theLayer ))
	(if (= conserve TRUE) (gimp-image-merge-visible-layers theImage 1))	
 
   ;  (gimp-context-set-background old-bg)
   ; (gimp-context-set-foreground old-fg)
   ; (gimp-context-set-gradient old-grad)
    	(gimp-context-pop)
    (gimp-image-undo-group-end theImage)
      (gimp-display-new theImage)
      (list theImage theLayer theText)
    )
  )