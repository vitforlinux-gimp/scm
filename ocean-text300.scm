;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove
;
; ocean-text
;
; Creates a invert semi-"adjustment layer".
;
; Alexander Melcher (a.melchers@planet.nl)
; At xMedia, The Netherlands

; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; This script is a modification by Art Wade (fencepost) of Alexander Melchar's script
; so that it will work in GIMP 2.2.  Other than moving it to a new menu location
; Xtns > Script-Fu > Logos > Ocean Text... and modifying the code so that it will work in 2.2,
; no other modifications have been made.


; Define the function
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))


(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image (vector drawable)))))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "QTHelvetCnd-Black Heavy")
  (define sffont "QTHelvetCnd-Black"))
  
  (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

(define (script-fu-ocean-text inText
	                      inFontSize
	                      inFont
			      grad-type
			      gradient
			      grad-rvs
			      bgcol
	)

	
	; Set up the script so that user settings can be reset after the script is run		

	(gimp-context-push)

	; Create the image
	(define theImage (car (gimp-image-new 256 256 RGB)))

	; Disable undoing
	(gimp-image-undo-disable theImage)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)


	(gimp-context-set-foreground '(128 128 128))
	(gimp-context-set-background bgcol)

	; Create the initial text layer and background layer
	(define textLayer (car (gimp-text-fontname theImage -1 0 0 inText
	                      (* 30 (/ inFontSize 100)) TRUE inFontSize PIXELS
	                      inFont)))
	(gimp-image-resize theImage (car (gimp-drawable-get-width textLayer))
	                   (car (gimp-drawable-get-height textLayer)) 0 0)
	(define background (car (gimp-layer-new-ng theImage
	                       (car (gimp-image-get-width theImage))
	                       (car (gimp-image-get-height theImage))
	                       1 "Background" 100 0)))

	(gimp-image-insert-layer theImage background 0 0)
	(gimp-context-set-background bgcol)
	(gimp-drawable-edit-fill background FILL-BACKGROUND)
		(gimp-context-set-background '(255 255 255))

	

	(gimp-image-lower-item-to-bottom theImage background)
	(gimp-context-set-foreground '(0 0 0))

	; Create the shadow layer
	(gimp-image-set-active-layer theImage textLayer)
	(define shadowLayer (car (gimp-layer-copy textLayer TRUE)))
	(gimp-image-insert-layer theImage shadowLayer -1 0)
	(gimp-image-lower-item theImage shadowLayer)
	;(gimp-drawable-edit-clear shadowLayer)
	(gimp-image-select-item theImage 0 textLayer)
	(define shadowBlur (* 6 (/ inFontSize 100)))
	(gimp-selection-grow theImage (/ shadowBlur 2))
	


(gimp-drawable-edit-bucket-fill shadowLayer 0 0 80 )
(gimp-selection-none theImage)
	(gimp-layer-set-lock-alpha shadowLayer FALSE)
	(if (>= shadowBlur 1.0)
	    (apply-gauss2 theImage shadowLayer shadowBlur shadowBlur)
	)	


; Add the ocean waves
	(if (= grad-type 0)(begin   (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Horizon 2")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Horizon 2" )))
				))
	(gimp-context-set-gradient gradient))
			(gimp-context-set-gradient-reverse grad-rvs)
	(gimp-image-set-active-layer theImage textLayer)
	(define waveLayer (car (gimp-layer-new-ng theImage
	                      (car (gimp-image-get-width theImage))
	                      (car (gimp-image-get-height theImage))
	                      1 inText 100 0)))
	
	(gimp-image-insert-layer theImage waveLayer -1 0)
	(gimp-image-lower-item theImage waveLayer)
	(gimp-drawable-edit-gradient-fill waveLayer 0 0 0 1 0 0 
	            (/ (car (gimp-image-get-width theImage)) 2) 0
	            (/ (car (gimp-image-get-width theImage)) 2)
                    (car (gimp-image-get-height theImage)))
		    (cond((not(defined? 'plug-in-ripple))
		 		     (gimp-drawable-merge-new-filter waveLayer "gegl:ripple" 0 LAYER-MODE-REPLACE 1.0
"amplitude" 5 "period" 100 "phi" 0 "angle" 0 "sampler-type" "cubic" "wave-type" "sine" "abyss-policy" "none" "tileable" FALSE))		    
	(else
	(plug-in-ripple 1 theImage waveLayer 100 5 1 0 1 TRUE FALSE)))
	;(plug-in-waves  1 theImage waveLayer 10 0 25 0 0)
	(apply-gauss2 theImage waveLayer 3.33334 3.33334 )
	; And make it a text
	(define waveLayerMask (car (gimp-layer-create-mask waveLayer 1)))
	(gimp-layer-add-mask waveLayer waveLayerMask)	
	(gimp-image-select-item theImage 0 textLayer)
(gimp-drawable-edit-bucket-fill waveLayerMask 1 0 100 )
(gimp-selection-none theImage)


	; Finishing touch (bevel the text layer)
	(gimp-image-set-active-layer theImage textLayer)
	(gimp-item-set-name textLayer "Bevel")
	(gimp-layer-set-mode textLayer 5)
	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new textLayer "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 225 "elevation" 20 "depth" 5
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 0.120
                                      "compensate" TRUE "invert" FALSE "type" "linear"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" textLayer)
      (gimp-drawable-merge-filter textLayer filter)
    ))
    (else
	(plug-in-bump-map 1 theImage textLayer textLayer 225 20 5 0 0 0 0.120
                          TRUE FALSE 0)))

	; Restore palette
	;(gimp-context-set-foreground '(128 128 128))
	;(gimp-context-set-background '(255 255 255))
		(gimp-context-set-background bgcol)
	(gimp-drawable-fill background FILL-BACKGROUND)

	; Display the image & re-enable undoing
	(gimp-image-undo-enable theImage)
	(gimp-image-clean-all theImage)
	(gimp-display-new theImage)
	


	; Force update
	(gimp-displays-flush)

	; Return
	(list theImage)

; Resets previous user settings  
  
(gimp-context-pop)

)

; Register script-fu-ocean-text

(script-fu-register
    "script-fu-ocean-text"
    "Ocean Text 300..."
    "Creates a text banner with an ocean wave inside."
    "Alexander Melchers; Art Wade"
    "2002, Alexander Melchers, xMedia; 2008 Art Wade; Vitforlinux 2021"
    "14th December 2002; February 22, 2008; 21 Gen 2021> 9 gen 2025 "
    ""
    SF-STRING     "Text"               "Ocean Text"
    SF-ADJUSTMENT "Font Size (pixels)" '(100 2 1000 1 0 0 1)
    SF-FONT       "Font"               sffont
      SF-OPTION "Gradient Type" '("Default" "Manual")
      SF-GRADIENT   _"Gradient"           "Horizon 2"
      		    SF-TOGGLE "Gradient Reverse" FALSE
      SF-COLOR "Background color" '(255 255 255)
)
(script-fu-menu-register
	"script-fu-ocean-text"
	; "<Toolbox>/Xtns/Logos"
	"<Image>/File/Create/Logos"
)

;gimp-selection-layer-alpha
;gimp-image-select-item
;gimp-edit-bucket-fill
;gimp-edit-blend