;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; chisel.scm
; by Rob Antonishen
; http://www.silent9.com

; Version 1.3 (20130712)

; Description
;
; creates a chisel-off edge or carved-in bevel based on  the selection, or using the current layer's alpha channel
;

; Changes
; v1.3 - complete rewrite to perform math rather than performing curves for smoother bevels
;      - Added new slider "Roundness" -1 is a quarter-circle fillet, +1 is a quarter-round, 0 is flat
;      - Old "Bevel Curve" is now "Bevel Power" and is a power function applied on top of roundness to emphasize the curve more
;      - hard light layer set to 80% on creation
;      - Post Effect Blur is only masked off outside for an inner carve/chisel, and inside for an outer carve/chisel.

; License:
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version. 
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; The GNU Public License is available at
; http://www.gnu.org/copyleft/gpl.html

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))


(define (script-fu-chisel-300 img inLayer bump-type inWidth inSoften inCurve inPow inAizmuth inElevation inDepth inMode inLocation inBlur inKeepBump)
  (let*
    (
	   (varNoSelection (car (gimp-selection-is-empty img)))
	   (inPow (- 0 inPow))
       (varSavedSelection 0)
	   (varBlurredSelection 0)
	   (varBumpmapLayer)
	   (varBevelLayer)
	   (varLoopCounter 1)
	   (varFillValue)
	   (varNumBytes 256)
	   (varAdjCurve    (cons-array varNumBytes 'byte))
	   (varLayerName (car (gimp-item-get-name inLayer)))
    )
    ;  it begins here
    (gimp-context-push)
    (gimp-image-undo-group-start img)
	 (gimp-layer-resize-to-image-size inLayer)
	;save selection or select all if no selection
	(if (= varNoSelection TRUE)
	  (if (= (car (gimp-drawable-has-alpha inLayer)) TRUE)  ;check for alpha
	    (gimp-image-select-item img 2 inLayer) ;  transfer the alpha to selection
	    (gimp-selection-all img)  ;else select the whole image
      )
	)
	(set! varSavedSelection (car (gimp-selection-save img)))
	
	(set! varBumpmapLayer (car (gimp-layer-new-from-drawable inLayer img)))
    (gimp-item-set-name varBumpmapLayer (string-append varLayerName " bumpmap"))
	(gimp-image-insert-layer img varBumpmapLayer 0 -1)
	(if (= inLocation 1) ;if outside, enlarge the layer canvas
	  (gimp-layer-resize varBumpmapLayer (+ (car (gimp-drawable-get-width inLayer)) (* 2 inWidth))
	                                   (+ (car (gimp-drawable-get-height inLayer)) (* 2 inWidth))
									   inWidth
									   inWidth)
	)
	
	;blur selection for soft chisel
	(gimp-selection-feather img inSoften)
	(set! varBlurredSelection (car (gimp-selection-save img)))
	
	;when shrinking check selection size and reset inWidth if necessary
    (when (= inLocation 0)
	  (set! varLoopCounter inWidth)
	  (gimp-selection-shrink img varLoopCounter)
	  (while (= (car (gimp-selection-is-empty img)) TRUE)
	    (set! varLoopCounter (- varLoopCounter 1))
	    (gimp-image-select-item img 2 varBlurredSelection)	
	    (gimp-selection-shrink img varLoopCounter)
	    (gimp-progress-set-text "Checking Carve Size...")
		(gimp-progress-pulse)
	  )
      (gimp-progress-set-text "")
	  (set! inWidth (min inWidth varLoopCounter))
	  (gimp-image-select-item img 2 varBlurredSelection)	
	)
	
	; create bevel in bumpmap layer black to white
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-fill varBumpmapLayer FILL-FOREGROUND) ;                              dn: chg from FILL-FOREGROUND

	(set! varLoopCounter 1)
	(while (<= varLoopCounter inWidth)
	  ;inCurve of 0 will be flat, inCurve of 1 is a quarter round, inCurve of -1 is a quarter round fillet
	  (set! varFillValue (* (expt (+ (* (- (sin (* (/ varLoopCounter inWidth) (tan 1))) (/ varLoopCounter inWidth)) inCurve) (/ varLoopCounter inWidth)) (expt 2 inPow)) 255))
	  
	  ;avoid distortion
	  (gimp-image-select-item img 2 varBlurredSelection)	
	  
	  (if (= inLocation 0)
	    (gimp-selection-shrink img (- varLoopCounter 1)) ;inside
	    (gimp-selection-grow img (- inWidth (- varLoopCounter 1))) ;outside
      )
	  
	  (gimp-context-set-foreground (list varFillValue varFillValue varFillValue)) ;shade of grey
		
	  (if (= (car (gimp-selection-is-empty img)) FALSE)
        (gimp-drawable-edit-fill varBumpmapLayer FILL-FOREGROUND) ;                              dn: chg from FILL-FOREGROUND
        (gimp-drawable-edit-fill varBumpmapLayer FILL-FOREGROUND) ; second time to blend better  dn: chg from FILL-FOREGROUND
		(set! varLoopCounter (+ inWidth 1))
      )
		
	  (set! varLoopCounter (+ varLoopCounter 1))
	)

    ;finish up with white
	(gimp-context-set-foreground (list 255 255 255)) ;white
    (gimp-image-select-item img 2 varBlurredSelection)	
	(if (= inLocation 0)
	    (gimp-selection-shrink img inWidth) ;inside
    )	
	(if (= (car (gimp-selection-is-empty img)) FALSE)
      (gimp-drawable-edit-fill varBumpmapLayer FILL-FOREGROUND) ;                                dn: chg from FILL-FOREGROUND 
      (gimp-drawable-edit-fill varBumpmapLayer FILL-FOREGROUND) ; second time to blend better    dn: chg from FILL-FOREGROUND
	)

    (gimp-selection-none img) 
	
    ;make bevel from  bumpmap
 	(set! varBevelLayer (car (gimp-layer-new-from-drawable inLayer img)))
    (gimp-item-set-name varBevelLayer (string-append varLayerName " bevel"))
	(gimp-image-insert-layer img varBevelLayer 0 -1) 
	(if (= inLocation 1) ;if outside, enlarge the layer canvas
	  (gimp-layer-resize varBevelLayer (+ (car (gimp-drawable-get-width inLayer)) (* 2 inWidth))
	                                   (+ (car (gimp-drawable-get-height inLayer)) (* 2 inWidth))
									   inWidth
									   inWidth)
	)

    (gimp-context-set-foreground '(127 127 127))
    (gimp-drawable-fill varBevelLayer FILL-FOREGROUND) ;                                  dn: chg from FILL-FOREGROUND 

	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new varBevelLayer "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" inAizmuth "elevation" inElevation "depth" inDepth
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 0
                                      "compensate" TRUE "invert" (cond ((= inMode 0) FALSE) ((= inMode 1) TRUE)) "type" (cond ((= bump-type 0) "linear" ) ((= bump-type 1) "spherical" ) ((= bump-type 2) "sinusoidal" ))
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" varBumpmapLayer)
      (gimp-drawable-merge-filter varBevelLayer filter)
    ))
    (else
	(plug-in-bump-map RUN-NONINTERACTIVE img varBevelLayer varBumpmapLayer inAizmuth inElevation inDepth 0 0 0 0 
	                  TRUE (cond ((= inMode 0) FALSE) ((= inMode 1) TRUE)) bump-type))) ;             dn: LINEAR not accepted by 2.10, set 0
	(gimp-layer-set-mode varBevelLayer LAYER-MODE-HARDLIGHT) ;                              dn: chg from HARDLIGHT-MODE
	(gimp-layer-set-opacity varBevelLayer 80)
    (if (= (car (gimp-drawable-has-alpha varBevelLayer)) FALSE)
      (gimp-layer-add-alpha varBevelLayer)
    )
	
	;delete outside the desired bevel
    (if (= inLocation 0)
	  (begin ;inside
   	    (gimp-image-select-item img 2 varSavedSelection)
		(gimp-selection-invert img)
		(if (= (car (gimp-selection-is-empty img)) FALSE)
          (gimp-drawable-edit-clear varBevelLayer)
        )
   	    (gimp-image-select-item img 2 varSavedSelection)
	    (gimp-selection-shrink img inWidth)
		(if (= (car (gimp-selection-is-empty img)) FALSE)
          (gimp-drawable-edit-clear varBevelLayer)
        )
      )		
	  (begin ;outside
   	    (gimp-image-select-item img 2 varSavedSelection)
		(if (= (car (gimp-selection-is-empty img)) FALSE)
          (gimp-drawable-edit-clear varBevelLayer)
        )
   	    (gimp-image-select-item img 2 varSavedSelection)
	    (gimp-selection-grow img inWidth)
		(gimp-selection-invert img)
		(if (= (car (gimp-selection-is-empty img)) FALSE)
          (gimp-drawable-edit-clear varBevelLayer)
        )
      )		
	)

	; blur if desired
    (when (> inBlur 0)
      (gimp-image-select-item img 2 varBlurredSelection)	
	  (if (= inLocation 1)
	    (gimp-selection-invert img)
	  )	
	  (apply-gauss2 img varBevelLayer inBlur inBlur )
	  (gimp-selection-none img) 
	)
	
	;delete bumpmap layer
	(if (= inKeepBump TRUE)
	  (gimp-item-set-visible varBumpmapLayer FALSE)
	  (gimp-image-remove-layer img varBumpmapLayer)
	)
	
    ;load initial selection back up 
	(if (= varNoSelection TRUE)
	  (gimp-selection-none img)
	  (begin
	    (gimp-image-select-item img 2 varSavedSelection)
	  )
	)

	;and delete the channels
	(gimp-image-remove-channel img varSavedSelection)
	(gimp-image-remove-channel img varBlurredSelection)
	
	;(gimp-image-set-active-layer img inLayer)
	
	;done
    (gimp-progress-end)
	(gimp-image-undo-group-end img)
	(gimp-displays-flush)
	(gimp-context-pop)
  )
)

(script-fu-register "script-fu-chisel-300"
        		    "Chisel or Carve...300"
                    "Create a Chisel-off or Carve-in Effect"
                    "Rob Antonishen"
                    "Rob Antonishen"
                    "July 2008"
                    "RGB* GRAY*"
                    SF-IMAGE      "image"      0
                    SF-DRAWABLE   "drawable"   0
		    SF-OPTION       _"Bump Curve"          '("Linear" "Spherical" "Sinusoidal")
                    SF-ADJUSTMENT "Bevel Width" '(20 2 256 1 5 0 0)
                    SF-ADJUSTMENT "Bevel Softness" '(5 0 10 1 5 0 0)
                    SF-ADJUSTMENT "Bevel Roundness" '(0 -1 1 0.1 1 1 0)
                    SF-ADJUSTMENT "Bevel Power" '(0 -2 2 0.1 1 1 0)
                    SF-ADJUSTMENT "Azimuth" '(135 0 360 1 5 0 0)
                    SF-ADJUSTMENT "Elevation" '(30 0.5 90 1 5 1 0)
                    SF-ADJUSTMENT "Depth" '(20 1 65 1 5 0 0)
                    SF-OPTION     "Mode" '("Chisel-off Edges" "Carve-in")					
                    SF-OPTION     "Location" '("Inside" "Outside")					
                    SF-ADJUSTMENT "Post Effect Blur" '(0 0 20 1 5 0 0)					
                    SF-TOGGLE     "Keep Bumpmap?" FALSE)
		    
	(script-fu-menu-register "script-fu-chisel-300" "<Image>/Filters/Decor/")
		    
