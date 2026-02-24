;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image (vector drawable)))))

(define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))
 
  		(define (remove-color2 img  fond color)(begin
		 (cond((not(defined? 'plug-in-colortoalpha))
		 		     (gimp-drawable-merge-new-filter fond "gegl:color-to-alpha" 0 LAYER-MODE-REPLACE 1.0
"color" color "transparency-threshold" 0 "opacity-threshold" 1)
		)
		(else
(plug-in-colortoalpha RUN-NONINTERACTIVE img fond color)
		))))

(define (script-fu-egg-shine image drawable
                              shadow-size
							  shadow-opacity
							  keep-selection-in
							  conserve)
							  

 (let* (
            ;(image-layer (car (gimp-image-get-active-layer image)))
	(image-layer (if (not (defined? 'gimp-drawable-filter-new))
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
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
	
	(set! img-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "img-layer" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer image img-layer 0 -1)
	(gimp-drawable-fill img-layer  FILL-BACKGROUND)
	(gimp-drawable-edit-fill img-layer FILL-FOREGROUND)
	
;;;;create channel
	(gimp-selection-save image)
;	(set! img-channel (car (gimp-image-get-active-drawable image)))	
		 (if (not (defined? 'gimp-drawable-filter-new))
        (set! img-channel (car (gimp-image-get-active-drawable image)))
  (set! img-channel (vector-ref (car (gimp-image-get-selected-drawables image)) 0))	)
	(gimp-channel-set-opacity img-channel 100)	
	(gimp-item-set-name img-channel "img-channel")
	(gimp-image-set-active-layer image img-layer)	
	(gimp-item-set-name image-layer "Original Image")
	
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 1) 

;;;;apply the image effects
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	(apply-gauss2 image img-layer 12 12)
		 (cond((not(defined? 'plug-in-emboss))
		 		     (gimp-drawable-merge-new-filter img-layer "gegl:emboss" 0 LAYER-MODE-REPLACE 1.0
"type" "emboss" "azimuth" 225 "elevation" 84 "depth" 10)
		)
		(else
	(plug-in-emboss RUN-NONINTERACTIVE image img-layer 225 84 10 TRUE)))	
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear img-layer)
	(gimp-selection-invert image)
	;(plug-in-colortoalpha RUN-NONINTERACTIVE image img-layer '(254 254 254));;fefefe
;(gimp-layer-set-mode img-layer LAYER-MODE-HARDLIGHT )
(remove-color2 image img-layer '(254 254 254))

		;(gimp-image-select-item image 2 img-layer)
		;(gimp-context-set-foreground '(254 254 254))
		;(gimp-context-set-paint-mode LAYER-MODE-COLOR-ERASE)
		;(gimp-drawable-edit-fill img-layer FILL-FOREGROUND)


	(apply-gauss2 image img-channel 15 15)
	;(plug-in-blur RUN-NONINTERACTIVE image img-layer)
	(apply-gauss2 image img-layer 4 4)
	(gimp-image-set-active-layer image bkg-layer)
	(cond((not(defined? 'plug-in-displace))
          (let* (
                 (filter (car (gimp-drawable-filter-new bkg-layer "gegl:displace" ""))))
            (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                            "amount-x" 8 "amount-y" 8 "abyss-policy" "clamp"
                                            "sampler-type" "cubic" "displace-mode" "cartesian")
            (gimp-drawable-filter-set-aux-input filter "aux" img-channel)
            (gimp-drawable-filter-set-aux-input filter "aux2" img-channel)
            (gimp-drawable-merge-filter bkg-layer filter)
          ))
        (else
(plug-in-displace RUN-NONINTERACTIVE image bkg-layer 8 8 TRUE TRUE img-channel img-channel 1)))
(gimp-image-remove-layer image bkg-layer)
	
;;;;create the shadow
(if (> shadow-size 0)
  (begin
(if (not (defined? 'gimp-drawable-filter-new))
    (script-fu-drop-shadow image img-layer shadow-size shadow-size shadow-size '(0 0 0) shadow-opacity FALSE)
    (script-fu-drop-shadow image (vector img-layer) shadow-size shadow-size shadow-size '(0 0 0) shadow-opacity FALSE))
    (set! tmp-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "temp" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image tmp-layer 0 -1)
	(gimp-image-raise-item image tmp-layer)
    (gimp-image-merge-down image tmp-layer CLIP-TO-IMAGE)
	;(set! shadow-layer (car (gimp-image-get-active-drawable image)))
		 (if (not (defined? 'gimp-drawable-filter-new))
        (set! shadow-layer (car (gimp-image-get-active-drawable image)))
  (set! shadow-layer (vector-ref (car (gimp-image-get-selected-drawables image)) 0))	)
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
            "script-fu-egg-melt-text-300"                        ;function name
            "Egg Melt 300"                                  ;menu label
            "Create an upside down egg effect on a tablecloth"              ;description
            "Vitforlinux"                             ;author
            "copyright 1997, Michael Terry;\
              2009, the GIMP Documentation Team"        ;copyright notice
            "October 10, 2023"                          ;date created
            ""                              ;image type that the script works on
            SF-TEXT      "Text"          "Egg\nMelt"   ;a string variable
            SF-FONT        "Font"          "QTVagaRound Bold"    ;a font variable
            SF-ADJUSTMENT  "Font size"     '(150 1 1000 1 10 0 0)
	     SF-COLOR       "Color"         '(255 152 0)     ;color variable
	     	     SF-COLOR       "Color2"         '(255 255 255)    ;color variable
	    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -100 100 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(0 -300 300 1 10 0 0)
SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
                                                        ;a spin-button
								SF-TOGGLE   "Text deformation"     TRUE
           	     SF-COLOR       "BG Color"         '(255 0 0)     ;color variable
	     SF-COLOR       "BG Color 2"         '(255 255 255)     ;color variable

            SF-ADJUSTMENT  "Buffer amount" '(35 0 100 1 10 1 0)
                                                        ;a slider
							SF-TOGGLE   "Merge Layers"     TRUE
  )
  
  
  
  
  (script-fu-menu-register "script-fu-egg-melt-text-300" "<Image>/File/Create/Text")
  (define (script-fu-egg-melt-text-300 inText inFont inFontSize inTextColor  inTextColor2
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
                      (gimp-layer-new-ng
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
		;(gimp-context-push)
		      (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY  )
		 (define bord1Layer (car(gimp-layer-new-ng theImage 10 10 RGBA-IMAGE _"Bord 1 Layer" 100 LAYER-MODE-NORMAL-LEGACY)) )
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
		 (if (not (defined? 'gimp-drawable-filter-new))
        (gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 1))
  (gimp-context-set-gradient (vector-ref (car (gimp-gradients-get-list ""))4))	)
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
(if (= deform TRUE)
		    (cond((not(defined? 'plug-in-ripple))
		 		     (gimp-drawable-merge-new-filter theText "gegl:ripple" 0 LAYER-MODE-REPLACE 1.0
"amplitude" 5 "period" 75 "phi" 0 "angle" 0 "sampler-type" "cubic" "wave-type" "sine" "abyss-policy" "none" "tileable" FALSE))		    
	(else
(plug-in-ripple 1 theImage theText 75 5 1 0 1 TRUE FALSE))))
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
(if (= deform TRUE)
		    (cond((not(defined? 'plug-in-ripple))
		 		     (gimp-drawable-merge-new-filter bord1Layer "gegl:ripple" 0 LAYER-MODE-REPLACE 1.0
"amplitude" 5 "period" 100 "phi" 0 "angle" 0 "sampler-type" "cubic" "wave-type" "sine" "abyss-policy" "none" "tileable" FALSE))		    
	(else
(plug-in-ripple 1 theImage bord1Layer 100 5 1 0 1 TRUE FALSE))))
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
