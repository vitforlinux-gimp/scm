;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
; Fix code for gimp 2.10 working in 2.99.16
(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image 1 (vector drawable)))))


(define (script-fu-egg-shine image drawable
                              shadow-size
							  shadow-opacity
							  keep-selection-in
							  conserve)
							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(sel (car (gimp-selection-is-empty image)))
			(alpha (car (gimp-drawable-has-alpha image-layer)))
			(keep-selection keep-selection-in)
			(layer-name (car (gimp-item-get-name image-layer)))
			(img-layer 0)
			(img-channel 0)
			(bkg-layer 0)
			(shadow-layer 0)
			(tmp-layer 0)
        )
		
		
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
    
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (gimp-image-select-item image 2 image-layer))
	
	(set! img-layer (car (gimp-layer-new image width height RGBA-IMAGE "img-layer" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer image img-layer 0 -1)
	(gimp-drawable-fill img-layer  FILL-BACKGROUND)
	(gimp-drawable-edit-fill img-layer FILL-FOREGROUND)
	
;;;;create channel
	(gimp-selection-save image)
	;(set! img-channel (car (gimp-image-get-active-drawable image)))
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (set! img-channel (car (gimp-image-get-active-drawable image)))
  (set! img-channel (aref (cadr (gimp-image-get-selected-drawables image)) 0))	)	
	(gimp-channel-set-opacity img-channel 100)	
	(gimp-item-set-name img-channel "img-channel")
	(gimp-image-set-active-layer image img-layer)	
	(gimp-item-set-name image-layer "Original Image")
	
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 1) 

;;;;apply the image effects
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image img-layer 12 12)
	(plug-in-emboss RUN-NONINTERACTIVE image img-layer 225 84 10 TRUE)	
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear img-layer)
	(gimp-selection-invert image)
	(plug-in-colortoalpha RUN-NONINTERACTIVE image img-layer '(254 254 254));;fefefe
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image img-channel 15 15)
	;(plug-in-blur RUN-NONINTERACTIVE image img-layer)
	(plug-in-gauss-rle2 1 image img-layer 2 2)
	(gimp-image-set-active-layer image bkg-layer)
(plug-in-displace RUN-NONINTERACTIVE image bkg-layer 8 8 TRUE TRUE img-channel img-channel 1)
(gimp-image-remove-layer image bkg-layer)
	
;;;;create the shadow
(if (> shadow-size 0)
  (begin
    (script-fu-drop-shadow image img-layer shadow-size shadow-size shadow-size '(0 0 0) shadow-opacity FALSE)
    (set! tmp-layer (car (gimp-layer-new image width height RGBA-IMAGE "temp" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image tmp-layer 0 -1)
	(gimp-image-raise-item image tmp-layer)
    (gimp-image-merge-down image tmp-layer CLIP-TO-IMAGE)
	;(set! shadow-layer (car (gimp-image-get-active-drawable image)))
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (set! shadow-layer (car (gimp-image-get-active-drawable image)))
  (set! shadow-layer  (aref (cadr (gimp-image-get-selected-drawables image)) 0))	)
	(gimp-image-lower-item image shadow-layer)
	
   )
 )	

 (if (= conserve FALSE)
    (begin
	(set! img-layer (car (gimp-image-merge-down image img-layer EXPAND-AS-NECESSARY)))
	(if (> shadow-size 0) (set! img-layer (car (gimp-image-merge-down image img-layer EXPAND-AS-NECESSARY))))
	(gimp-item-set-name img-layer layer-name)
	)
	)	

	(if (= keep-selection FALSE) (gimp-selection-none image))	
	(gimp-image-remove-channel image img-channel)
	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten img-layer)))
	
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
    ;(gimp-display-new image)
	(gimp-displays-flush)

 )
) 

(script-fu-register
            "script-fu-egg-melt-text"                        ;function name
            "Egg Melt"                                  ;menu label
            "Create an upside down egg effect on a tablecloth"              ;description
            "Vitforlinux"                             ;author
            "copyright 1997, Michael Terry;\
              2009, the GIMP Documentation Team"        ;copyright notice
            "October 10, 2023"                          ;date created
            "Create an image with Egg effect text on a tablecloth."                              ;image type that the script works on
            SF-TEXT      "Text"          "Egg\nMelt"   ;a string variable
            SF-FONT        "Font"          "Franks Thin"    ;a font variable
            SF-ADJUSTMENT  "Font size"     '(150 1 1000 1 10 0 0)
	     SF-COLOR       "Color"         '(255 152 0)     ;color variable
	     	     SF-COLOR       "Color2"         '(255 255 255)    ;color variable
	    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
                                                        ;a spin-button
								SF-TOGGLE   "Text deformation"     FALSE
           	     SF-COLOR       "BG Color"         '(255 0 0)     ;color variable
	     SF-COLOR       "BG Color 2"         '(255 255 255)     ;color variable

            SF-ADJUSTMENT  "Buffer amount" '(35 0 100 1 10 1 0)
                                                        ;a slider
							SF-TOGGLE   "Merge Layers"     TRUE
  )
  
  
  
  
  (script-fu-menu-register "script-fu-egg-melt-text" "<Image>/File/Create/Text")
  (define (script-fu-egg-melt-text inText inFont inFontSize inTextColor  inTextColor2
					justification
					letter-spacing
					line-spacing
					grow-text
					outline
					deform
					bg-color
					bg-color2
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
                        RGB-IMAGE
                        "Background"
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
		;(gimp-context-push)
		      (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY  )
		 (define bord1Layer (car(gimp-layer-new theImage 10 10 RGBA-IMAGE _"Bord 1 Layer" 100 LAYER-MODE-NORMAL-LEGACY)) )
   (gimp-image-insert-layer theImage bord1Layer 0 1)

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
; (gimp-image-resize-to-layers theImage theImage)
	(gimp-selection-none theImage)
 	(gimp-image-select-item theImage 2 theText)
	
;(gimp-selection-invert theImage)
(gimp-selection-grow theImage (round (/ inFontSize 5)))
	(gimp-selection-flood theImage)

;(gimp-image-select-item theImage 1 theText)
(gimp-layer-resize-to-image-size bord1Layer)

     (gimp-context-set-foreground inTextColor2 )
	(gimp-drawable-edit-fill bord1Layer FILL-FOREGROUND)	


;;; background
(gimp-selection-none theImage)
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 1))
  (gimp-context-set-gradient (list-ref (car (gimp-gradients-get-list "")) 1))	)
    (gimp-context-set-background bg-color2)
     (gimp-context-set-foreground bg-color )
  (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
      (gimp-drawable-edit-gradient-fill theLayer 0 0 TRUE 1 0 TRUE 0 0 0 (round (/ inFontSize 3)))
      (gimp-context-set-paint-mode LAYER-MODE-GRAIN-MERGE )
        (gimp-drawable-edit-gradient-fill theLayer 0 0 TRUE 1 0 TRUE 0 0  (round (/ inFontSize 3)) 0)
	
	;(gimp-context-pop)

     ; (gimp-display-new theImage)
      		      (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY  )
		     ; (plug-in-ripple 1 theImage theText 75 5 0 0 1 TRUE FALSE)
(if (= deform TRUE) (plug-in-ripple 1 theImage theText 75 5 1 0 1 TRUE FALSE))
		          (script-fu-egg-shine theImage theText
                (round (/ inFontSize 5))
				0
				FALSE ;keep-selection-in
				FALSE) ;conserve
				
      ;(script-fu-shine299 1 theImage theText 0 0 7 1)
      (gimp-selection-none theImage)
		      (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY  )
	(gimp-image-set-active-layer theImage bord1Layer)	
;(plug-in-ripple 1 theImage bord1Layer 100 5 0 0 1 TRUE FALSE)
(if (= deform TRUE) (plug-in-ripple 1 theImage bord1Layer 100 5 1 0 1 TRUE FALSE))
		          (script-fu-egg-shine theImage bord1Layer
                (round (/ inFontSize 30))
				20
				FALSE ;keep-selection-in
				FALSE) ;conserve
				
;(plug-in-weaves 1 theImage bord1Layer 0.5 0.5  7 100 0 1 FALSE )
       ;(script-fu-shine299 1 theImage bord1Layer 0 0 7 1)
(if (= conserve TRUE) (gimp-image-flatten theImage))
(gimp-context-pop)
(gimp-display-new theImage)
      (list theImage theLayer theText)
    )
  )
