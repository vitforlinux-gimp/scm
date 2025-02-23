  (script-fu-register
            "script-fu-rainbow-text"                        ;function name
            "Rainbow text 300"                                  ;menu label
            "Creates a rainbow shadowed text Gimp 3.0 rc2+git only"              ;description
            "Vitforlinux 2 - 1 2025"                             ;author
            "copyright 1997, Michael Terry;\
              2009, the GIMP Documentation Team"        ;copyright notice
            "October 27, 1997"                          ;date created
            ""                              ;image type that the script works on
            SF-TEXT      "Text"          "Rainbow"   ;a string variable
            SF-FONT        "Font"          "Pacifico Regular"    ;a font variable
            SF-ADJUSTMENT  "Font size"     '(150 1 1000 1 10 0 0)
	     SF-COLOR       "Color"         '(255 255 255)     ;color variable
	    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
                                                        ;a spin-button
            SF-ADJUSTMENT  "Shadow Lenght"     '(5 1 1000 1 10 0 0)
           SF-COLOR       "Shadow Color 1"         '(255 0 0)     ;color variable
           SF-COLOR       "Shadow Color 2"         '(255 126 2)     ;color variable
	   SF-COLOR       "Shadow Color 3"         '(255 255 0)     ;color variable
	   SF-COLOR       "Shadow Color 4"         '(0 251 7)     ;color variable
	   SF-COLOR       "Shadow Color 5"         '(12 0 248)     ;color variable
	   SF-COLOR       "Shadow Color 6"         '(106 0 246)     ;color variable
	   SF-COLOR       "Shadow Color 7"         '(245 0 251)     ;color variable
           SF-COLOR       "Background Color"         '(75 75 75)     ;color variable
	     SF-TOGGLE  "Apply Vignette"    TRUE
	    SF-COLOR       "Vignette Color"         '(0 0 0)     ;color variable
            SF-ADJUSTMENT  "Buffer amount" '(35 0 100 1 10 1 0)
                                                        ;a slider
  )
  (script-fu-menu-register "script-fu-rainbow-text" "<Image>/File/Create/Text")
  
(define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))
  
  (define (script-fu-rainbow-text inText inFont inFontSize inTextColor
					justification
					letter-spacing
					line-spacing
					grow-text
					outline
					shadL
					shadColor1
					shadColor2
					shadColor3
					shadColor4
					shadColor5
					shadColor6
					shadColor7
					bgColor
					vignette
					vignetteColor
					inBufferAmount)
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
                      (gimp-layer-new-ng
                        theImage
                        theImageWidth
                        theImageHeight
                        RGB-IMAGE
                        "layer 1"
                        100
                        LAYER-MODE-NORMAL
                      )
                  )
        )
	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
      ) ;end of our local variables
      
          (gimp-context-push)
    (gimp-context-set-defaults)
    (gimp-context-set-paint-mode 0)
      (gimp-image-insert-layer theImage theLayer 0 0)
      (gimp-context-set-background bgColor)
      (gimp-context-set-foreground inTextColor)
      (gimp-drawable-fill theLayer FILL-BACKGROUND)
      (set! theText
      		 (if (not (defined? 'gimp-drawable-filter-new))
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
	
                    (car
                          (gimp-text-font
                          theImage theLayer
                          0 0
                          inText
                          0
                          TRUE
                          inFontSize
                          inFont)
                      ))
        )
	;; text alignment
	(gimp-text-layer-set-justification theText justification) ; Text Justification (Rev Value) 
	(gimp-text-layer-set-letter-spacing theText letter-spacing)  ; Set Letter Spacing
	(gimp-text-layer-set-line-spacing theText line-spacing)      ; Set Line Spacing


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
 					                (gimp-drawable-merge-new-filter theText "gegl:long-shadow" 0 LAYER-MODE-REPLACE 1.0
                                                                                                       "length" shadL "midpoint" 0 "midpoint-rel" 0
												       "color" shadColor1 "composition" ""
												       )
												
 					                (gimp-drawable-merge-new-filter theText "gegl:long-shadow" 0 LAYER-MODE-REPLACE 1.0
                                                                                                       "length" shadL "midpoint" 0 "midpoint-rel" 0
												       "color" shadColor2 "composition" ""
												       )
 					                (gimp-drawable-merge-new-filter theText "gegl:long-shadow" 0 LAYER-MODE-REPLACE 1.0
                                                                                                       "length" shadL "midpoint" 0 "midpoint-rel" 0
												       "color" shadColor3 "composition" ""
												       )
 					                (gimp-drawable-merge-new-filter theText "gegl:long-shadow" 0 LAYER-MODE-REPLACE 1.0
                                                                                                       "length" shadL "midpoint" 0 "midpoint-rel" 0
												       "color" shadColor4 "composition" ""
												       )
 					                (gimp-drawable-merge-new-filter theText "gegl:long-shadow" 0 LAYER-MODE-REPLACE 1.0
                                                                                                       "length" shadL "midpoint" 0 "midpoint-rel" 0
												       "color" shadColor5 "composition" ""
												       )
 					                (gimp-drawable-merge-new-filter theText "gegl:long-shadow" 0 LAYER-MODE-REPLACE 1.0
                                                                                                       "length" shadL "midpoint" 0 "midpoint-rel" 0
												       "color" shadColor6 "composition" ""
												       )
 					                (gimp-drawable-merge-new-filter theText "gegl:long-shadow" 0 LAYER-MODE-REPLACE 1.0
                                                                                                       "length" shadL "midpoint" 0 "midpoint-rel" 0
												       "color" shadColor7 "composition" ""
												       )
  (gimp-layer-resize-to-image-size theText)												       
		    (if (= vignette TRUE)
(begin
            (gimp-image-select-ellipse
            theImage
            CHANNEL-OP-REPLACE
            0
	    0
            (car (gimp-image-get-width theImage))
           (car (gimp-image-get-height theImage))
        )
	(gimp-selection-invert theImage)
    (gimp-selection-feather theImage (round (/ (car (gimp-image-get-width theImage)) 5 )))
    (gimp-context-set-opacity 50)
	(gimp-context-set-background vignetteColor)
    (gimp-drawable-edit-fill theLayer FILL-BACKGROUND)
    		(gimp-selection-none theImage)
		    (gimp-context-set-opacity 100)
))
	(gimp-context-pop)
      (gimp-display-new theImage)
      (list theImage theLayer theText)
    )
  )