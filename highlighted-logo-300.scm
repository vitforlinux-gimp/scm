; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

		 (if (not (defined? 'gimp-drawable-filter-new))
        (define sffont "QTVagaRound Bold")
  (define sffont "QTVagaRound-Bold"))
  
  (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))
  
  		(define (remove-color2 img  fond color)(begin
		 (cond((not(defined? 'plug-in-colortoalpha))
		 		     (gimp-drawable-merge-new-filter fond "gegl:color-to-alpha" 0 LAYER-MODE-REPLACE 1.0
"color" color "transparency-threshold" 0 "opacity-threshold" 1)
		)
		(else
(plug-in-colortoalpha RUN-NONINTERACTIVE img fond color)
		))))
  
  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))
  
  (script-fu-register
            "script-fu-highlighted-logo-300"                        ;function name
            "HighLighted LOGO 300"                                  ;menu label
            "Creates a simple text box, sized to fit\
              around the user's choice of text,\
              font, font size, and color."              ;description
            "Michael Terry"                             ;author
            "copyright 1997, Michael Terry;\
              2009, the GIMP Documentation Team"        ;copyright notice
            "October 27, 1997"                          ;date created
            ""                              ;image type that the script works on
            SF-TEXT      "Text"          "HighLighted\nLogo"   ;a string variable
            SF-FONT        "Font"          sffont    ;a font variable
            SF-ADJUSTMENT  "Font size"     '(150 1 1000 1 10 0 0)
	     SF-COLOR       "Color"         '(255 0 0)     ;color variable
	    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0);a spin-button
  SF-ADJUSTMENT "Highlight Dist fr Edge"    '(6 0 10 1 1 0 0)
           SF-COLOR       "BG Color"         '(255 255 255)     ;color variable
            SF-ADJUSTMENT  "Buffer amount" '(35 0 100 1 10 1 0)
                                                        ;a slider
  )
  (script-fu-menu-register "script-fu-highlighted-logo-300" "<Image>/File/Create/Text")
  (define (script-fu-highlighted-logo-300 inText inFont inFontSize inTextColor
					justification
					letter-spacing
					line-spacing
					grow-text
					outline
					hl-dist
					bgcolor
					inBufferAmount)
    (let*
      (
        ; define our local variables
        ; create a new image:
        (theImageWidth  10)
        (theImageHeight 10)
	(highlight-channel 0)
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
				(highlight	(car (gimp-layer-new-ng theImage theImageWidth theImageHeight RGBA-IMAGE "Highlight" 100 LAYER-MODE-NORMAL-LEGACY)))
				(highlight-channel (car (gimp-layer-new-ng theImage theImageWidth theImageHeight RGBA-IMAGE "Highlight-chan" 100 LAYER-MODE-NORMAL-LEGACY)))

	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
      ) ;end of our local variables
      (gimp-image-insert-layer theImage theLayer 0 0)
	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
      (gimp-context-set-background bgcolor )
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
	;(gimp-image-select-item theImage 2 theText)
	
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
 ;;;;create the highlight
	(gimp-image-select-item theImage 2  theText)
			      (gimp-image-insert-layer theImage highlight 0 0)

		(gimp-item-set-name highlight "HighLight")
		(gimp-layer-resize-to-image-size highlight)

	(gimp-selection-shrink theImage hl-dist)
	(gimp-selection-feather theImage 2)
	(gimp-context-set-foreground '(128 128 128))
	(gimp-drawable-edit-fill highlight FILL-FOREGROUND)
	
;;;;create highlight-channel (gimp-image-select-item image 2  highlight-channel)	
	;(set! highlight-channel (car (gimp-selection-save theImage)))

	;(gimp-item-set-name highlight-channel "highlight-channel")
		;(include-layer theImage highlight-channel theLayer 0)	;stack 0=above 1=below
		      (gimp-image-insert-layer theImage highlight-channel 0 0)
		      		(gimp-layer-resize-to-image-size highlight-channel)
		      (set! highlight-channel (car (gimp-selection-save theImage)))

		;(gimp-layer-resize-to-image-size highlight-channel)

	(gimp-selection-none theImage)
	(apply-gauss2 theImage highlight 5 5)
	;(gimp-image-set-active-layer image highlight)
	;
	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new highlight "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 135 "elevation" 15 "depth" 10
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 1.0
                                      "compensate" TRUE "invert" FALSE "type" "linear"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" highlight-channel)
      (gimp-drawable-merge-filter highlight filter)
    ))
    (else
    (plug-in-bump-map RUN-NONINTERACTIVE theImage highlight highlight-channel 135 15 10 0 0 0 1 TRUE FALSE 0))) ;{LINEAR(0),SPHERICAL(1),SINUSOIDAL(2)}
	;(plug-in-colortoalpha RUN-NONINTERACTIVE theImage highlight '(128 128 128))
	(remove-color2 theImage highlight '(128 128 128))
		;(apply-gauss2 theImage highlight 1.5 1.5)
		;(gimp-image-remove-layer theImage highlight-channel)

      (gimp-context-pop)
      (gimp-display-new theImage)
      (list theImage theLayer theText)
    )
  )
