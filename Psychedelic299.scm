;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Psychedelic rel 0.05
; Created by Graechan
; Fix/Update for Gimp 2.10.22 Vitforlinux
; Comments directed to http://gimpchat.com or http://gimpscripts.com
;
; License: GPLv3
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;    GNU General Public License for more details.
;
;    To view a copy of the GNU General Public License
;    visit: http://www.gnu.org/licenses/gpl.html
;
;
; ------------
;| Change Log |
; ------------ 
; Rel 0.01 - Initial Release
; Rel 0.02 - Added Adjustment for 3D height and check for 2.8 version
; Rel 0.03 - Added Alpha-to-Logo Script
; Rel 0.04 - Vitforlinux - Fix/Update for Gimp 2.10.22 - changeable text fill color
; Rel 0.05 - Vitforlinux - Fix text fill color when grow, and  more grow.
; Rel 299 - 2024-7-1 Vitforlinux - works in 2.99.19 and 2.10 also compatibility = OFF
;
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image (vector drawable)))))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sfbggrad "Full saturation spectrum CCW")
  (define sfbggrad "Full Saturation Spectrum CCW")	)
  
		(define (apply-gauss img drawable x y)(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
      (plug-in-gauss  1  img drawable x y 0)
 (plug-in-gauss  1  img drawable (* x 0.32) (* y 0.32) 0)  )))

(define (gimp-version-meets? check)
  (let ((c (map string->number (strbreakup check ".")))
        (v (map string->number (strbreakup (car (gimp-version)) "."))))
  (if (> (car v) (car c)) #t
  (if (< (car c) (car v)) #f
   (if (> (cadr v) (cadr c)) #t
   (if (< (cadr v) (cadr c)) #f
     (if (>= (caddr v) (caddr c)) #t #f)))))))
;
; include layer Procedure
(define (include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.8 
          )
          (else
           (gimp-image-add-layer image newlayer (+ (car (gimp-image-get-layer-position image oldlayer)) stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end add layer procedure
;
(define (script-fu-psychedelic299 image 
                        drawable
                        text-gradient
						mode
						bevel-size
						3d-size
                        shadow-size
						shadow-opacity
						bkg-type
						bkg-gradient
						blend-repititions
						displace-repititions
						conserve)
							   
	(cond ((not (gimp-version-meets? "2.8.0"))
    (let ((handler (car (gimp-message-get-handler))))
	(gimp-message-set-handler 0)	
	(error "You will need to Install\nGimp Version 2.8\nTo use this script")
	(gimp-message-set-handler handler)))
	(else						   
	(gimp-image-undo-group-start image)						  

 (let* (
            (width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(original-width width)
			(original-height height)
			(area (* 1000 1000))
			(paint-layer (car (gimp-layer-new image width height RGBA-IMAGE "Paint-Layer" 100 mode)))
			(alpha (car (gimp-drawable-has-alpha drawable)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (cond ((defined? 'gimp-image-get-item-position) (car (gimp-item-get-name drawable)))
		            (else (car (gimp-item-get-name drawable)))))
			(bkg-layer 0)		
			(selection-channel 0)
			(ver 2.8)
			
			(x1 0)
			(y1 0)
			(iwidth 0)
			(iheight 0)
			(isize 0)
			(cnt 0)
        )

	
	(gimp-context-push)
    (gimp-context-set-paint-method "gimp-paintbrush")
 (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))
	(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Pressure Opacity")))
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

	(if (= alpha FALSE) (gimp-layer-add-alpha drawable))
	
;;;;check that a selection was made if not make one	
	
	(if (= sel TRUE) (begin
	(cond ((= ver 2.8) (gimp-image-select-item image 2 drawable)) 
	(else (gimp-image-select-item image 2 drawable))
	) ;endcond
	)
	)
	
;;;;create selection-channel (gimp-image-select-item image 2 selection-channel)	
	(set! selection-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name selection-channel "selection-channel"))
	(else (gimp-item-set-name selection-channel "selection-channel"))
    ) ;endcond
	(gimp-image-set-active-layer image drawable)
    
	(set! x1 (cadr (gimp-drawable-mask-intersect drawable))) ;x coordinate of upper left corner of selection 
    (set! y1 (caddr (gimp-drawable-mask-intersect drawable))) ;y coordinate of upper left corner of selection 
    (set! iwidth (cadddr (gimp-drawable-mask-intersect drawable))) ;x width of the intersection
    (set! iheight (cadr (cdddr (gimp-drawable-mask-intersect drawable)))) ;y height of the intersection
	(set! isize (min iwidth iheight))
	(set! cnt (- (/ isize 30) 1))
;;;;begin the script	
	(include-layer image paint-layer drawable 0)	;stack 0=above 1=below
	(gimp-image-select-rectangle image 2 x1 y1 iwidth iheight)

    (if (= ver 2.8) (gimp-context-set-dynamics "Random Color"))
	(gimp-context-set-paint-method "gimp-paintbrush")
;	(gimp-context-set-brush "Sparks")
 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
		 (gimp-context-set-brush "Sparks")
		 (gimp-context-set-brush (car(gimp-brush-get-by-name "Sparks")))	)
	(gimp-context-set-brush-default-size)
	(gimp-context-set-gradient text-gradient)	
	(gimp-drawable-edit-stroke-selection paint-layer)
	(while (> cnt 0)
	(gimp-selection-shrink image 30)
	(if (= (car (gimp-selection-is-empty image)) FALSE) (gimp-drawable-edit-stroke-selection paint-layer))
	(set! cnt (- cnt 1))
	)
	(gimp-selection-none image)
			 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
	(gimp-drawable-curves-spline paint-layer 0 10 #(0 0 0.337254901961 0.196078431373 0.5 0.505882352941 0.674509803922 0.811764705882 1 1))
	(gimp-drawable-curves-spline paint-layer 0 #(0 0 0.337254901961 0.196078431373 0.5 0.505882352941 0.674509803922 0.811764705882 1 1)))	
	
	(set! drawable (car (gimp-image-merge-down image paint-layer EXPAND-AS-NECESSARY)))
	
	(gimp-image-select-item image 2 selection-channel)	
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear drawable)
	(gimp-selection-none image)
	
    (the-chisel image 
	            drawable 
				bevel-size ;inWidth 
				10 ;inSoften 
				1 ;inCurve 
				0 ;inPow 
				135 ;inAizmuth 
				30 ;inElevation 
				bevel-size ;inDepth 
				0 ;inMode 
				0 ;inLocation 
				0 ;inBlur 
				FALSE)
	
    ;(set! drawable (car (gimp-image-get-active-layer image)))
    	(set! drawable (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
;	(gimp-curves-spline drawable 0 10 #(0 0 86 50 128 129 172 207 255 255))	
	
	(easy-3d image drawable
                               3d-size ;3d-size
							   0 ;h-dir
							   2 ;v-dir
							   FALSE ;keep-selection-in
							   FALSE) ;conserve
    
	    	(set! drawable (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
	
    (psychedelic-shine image drawable
                shadow-size
				shadow-opacity
				FALSE ;keep-selection-in
				FALSE) ;conserve

    	(set! drawable (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
	
;;;;create the background layer
    (set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY))) 
    (include-layer image bkg-layer drawable 1)	;stack 0=above 1=below
	(cond ((= bkg-type 0)
	(technicolor-dream 
                               image
                               bkg-layer
							   bkg-gradient
							   blend-repititions
							   displace-repititions
							   FALSE) ;keep-selection
			 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
	(gimp-drawable-curves-spline bkg-layer 0 10 #(0 0 0.337254901961 0.196078431373 0.5 0.505882352941 0.674509803922 0.811764705882 1 1))
	(gimp-drawable-curves-spline bkg-layer 0 #(0 0 0.337254901961 0.196078431373 0.5 0.505882352941 0.674509803922 0.811764705882 1 1))	)
	
	)) ;endcond						   
	;end	
	

	
;;;;finish the script	
	(if (= conserve FALSE) (set! drawable (car (gimp-image-merge-down image drawable EXPAND-AS-NECESSARY))))
    (cond ((= ver 2.8) (gimp-item-set-name drawable layer-name))
	(else (gimp-item-set-name drawable layer-name))
    ) ;endcond

	(gimp-image-remove-channel image selection-channel)
	(if (and (= conserve FALSE) (= alpha FALSE)) (gimp-layer-flatten drawable))	

	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

) ;end Variables
	)) ;endCheckVersion
  ) ;endProcedure

(script-fu-register "script-fu-psychedelic299"        		    
  "Psychedelic 299 Alpha"
  "Splatters image with paint and can generate a Background of dripping paint"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "May 2014"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-GRADIENT   "Paint Splatter Gradient" "Tropical Colors"
  ;SF-ENUM "Paint Splatter LayerMode" '("LayerModeEffects" "layer-mode-hardlight-legacy")
  SF-ADJUSTMENT "Paint Splatter LayerMode" '(18 0 50 1 10 0 0)
  SF-ADJUSTMENT	"Bevel Size"			'(5 1 65 1 10 0 0)
  SF-ADJUSTMENT "3D Size" '(1 1 50 1 10 0 0)
  SF-ADJUSTMENT "Shadow Size" '(8 0 16 1 10 0 0)
  SF-ADJUSTMENT "Shadow Opacity" '(50 0 100 1 10 0 0)
  SF-OPTION "Background Type" '("Technicolor-Dream" "Transparent")
  SF-GRADIENT   "Background Effect Gradient" sfbggrad
  SF-ADJUSTMENT "Blend Repititions" '(12 0 20 1 1 0 0)
  SF-ADJUSTMENT "Displace Repititions" '(8 0 20 1 1 0 0)
  SF-TOGGLE     "Keep the Layers"   FALSE
  
)

(script-fu-menu-register "script-fu-psychedelic299" "<Image>/Script-Fu/Alpha-to-Logo")

;
(define (script-fu-psychedelic299-logo 
                        text
						justify
						letter-spacing
						line-spacing
						grow
                        font-in 
                        font-size
			text-color
						text-gradient
						mode
						bevel-size
						3d-size
                        shadow-size
						shadow-opacity
						bkg-type
						bkg-gradient
						blend-repititions
						displace-repititions
						conserve)
	
    (cond ((not (gimp-version-meets? "2.8.0"))
    (let ((handler (car (gimp-message-get-handler))))
	(gimp-message-set-handler 0)	
	(error "You will need to Install\nGimp Version 2.8\nTo use this script")
	(gimp-message-set-handler handler)))
	(else
	
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))         
         (border (/ font-size 4))
		 (font  font-in )
         (size-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (final-width (car (gimp-drawable-get-width size-layer)))
         (final-height (car (gimp-drawable-get-height size-layer)))
         (text-layer 0)
         (width 0)
         (height 0)
         (bkg-layer 0)
		 (ver 2.8)
		 (selection-channel 0)
         (aspect 0)
		 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))		 
         )

    
	(gimp-context-push)
(gimp-context-set-paint-mode 0)
	(gimp-context-set-paint-method "gimp-paintbrush")
 (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))
	(if (= ver 2.8) (gimp-context-set-dynamics "Pressure Opacity"))
	(gimp-context-set-foreground text-color) ;---------------------------------set text color here
	(gimp-context-set-background '(255 255 255))
	
;;;;adjust the size-layer
    (gimp-text-layer-set-justification size-layer justify)
	(gimp-text-layer-set-letter-spacing size-layer letter-spacing)
	(gimp-text-layer-set-line-spacing size-layer line-spacing)
    (set! final-width (car (gimp-drawable-get-width size-layer)))
    (set! final-height (car (gimp-drawable-get-height size-layer)))	

;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 200 4)) TRUE 200 PIXELS font)))
	(gimp-item-set-name text-layer "Text")
;;;;adjust text 
	(gimp-text-layer-set-justification text-layer justify)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
	(gimp-image-resize-to-layers image)
	
;;;;Expand the font if needed
    (if (> grow 0)
           (begin
    (cond ((= ver 2.8) (gimp-image-select-item image 2 text-layer)) 
	(else (gimp-image-select-item image 2 text-layer)))
    (gimp-drawable-edit-clear text-layer)
    (gimp-selection-grow image (+ grow 2))
    (gimp-context-set-foreground text-color)
    (gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
    (gimp-selection-none image)
           )
    )
;;;;set the new width and height	
    (set! width (car (gimp-drawable-get-width text-layer)))
    (set! height (car (gimp-drawable-get-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)

;;;;begin the script
	(script-fu-psychedelic299 image 
                        text-layer
                        text-gradient
						mode
						bevel-size
						3d-size
                        shadow-size
						shadow-opacity
						1 ;bkg-type
						bkg-gradient
						blend-repititions
						displace-repititions
						FALSE) ;conserve					   

	;(set! text-layer (car (gimp-image-get-active-layer image)))
	       			(set! text-layer (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
	
;;;;Scale Image to it's final size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (set! aspect (/ final-width (car (gimp-image-get-width image)))) 
    (gimp-image-scale image final-width (* (car (gimp-image-get-height image)) aspect) )
	(set! width (car (gimp-image-get-width image)))
	(set! height (car (gimp-image-get-height image)))

;;;;create the background layer
    (set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY))) 
    (include-layer image bkg-layer text-layer 1)	;stack 0=above 1=below
	(cond ((= bkg-type 0)
	(technicolor-dream 
                               image
                               bkg-layer
							   bkg-gradient
							   blend-repititions
							   displace-repititions
							   FALSE) ;keep-selection
			 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
	(gimp-drawable-curves-spline bkg-layer 0 10 #(0 0 0.337254901961 0.196078431373 0.5 0.505882352941 0.674509803922 0.811764705882 1 1))
	(gimp-drawable-curves-spline bkg-layer 0 #(0 0 0.337254901961 0.196078431373 0.5 0.505882352941 0.674509803922 0.811764705882 1 1))	
)	
	)) ;endcond						   
	;end
;(plug-in-oilify 1 image text-layer 4 0) 
	(if (= conserve FALSE) (set! text-layer (car (gimp-image-merge-down image text-layer EXPAND-AS-NECESSARY))))
	(gimp-item-set-name text-layer text)
    	

	(gimp-context-pop)	
    (gimp-display-new image)
	
    ) ;end Variables
	)) ;endCheckVersion
  ) ;endProcedure
  
(script-fu-register "script-fu-psychedelic299-logo"
  "Psychedelic 299 LOGO"
  "Splatters text with paint and can generate a Background of dripping paint"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "May 2014"
  ""
  SF-TEXT       "Text"    "Psychedelic"
  SF-OPTION "Justify" '("Centered" "Left" "Right") 
  SF-ADJUSTMENT "Letter Spacing" '(5 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Expand the Font if needed" '(0 0 12 1 1 0 1)
  SF-FONT       "Font"               "QTHoboken"
  SF-ADJUSTMENT "Font size (pixels)" '(200 6 500 1 1 0 1)
  SF-COLOR		"Text Fill Color"			'(0 0 0)
  SF-GRADIENT   "Text Paint Splatter Gradient" "Tropical Colors"
  ;SF-ENUM "Paint Splatter LayerMode" '("LayerModeEffects" "layer-mode-hardlight-legacy")
  SF-ADJUSTMENT "Paint Splatter LayerMode" '(18 0 50 1 10 0 0)
  SF-ADJUSTMENT	"Bevel Size"			'(5 1 65 1 10 0 0)
  SF-ADJUSTMENT "3D Size" '(1 1 50 1 10 0 0)
  SF-ADJUSTMENT "Shadow Size" '(8 0 16 1 10 0 0)
  SF-ADJUSTMENT "Shadow Opacity" '(50 0 100 1 10 0 0)
  SF-OPTION "Background Type" '("Technicolor-Dream" "Transparent")
  SF-GRADIENT   "Background Effect Gradient" sfbggrad
  SF-ADJUSTMENT "Blend Repititions" '(12 0 20 1 1 0 0)
  SF-ADJUSTMENT "Displace Repititions" '(8 0 20 1 1 0 0)
  SF-TOGGLE     "Keep the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-psychedelic299-logo" "<Image>/Script-Fu/Logos")
;
;
;  
;
(define (the-chisel img inLayer inWidth inSoften inCurve inPow inAizmuth inElevation inDepth inMode inLocation inBlur inKeepBump)
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
    (gimp-drawable-fill varBumpmapLayer FILL-FOREGROUND)

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
        (gimp-drawable-edit-fill varBumpmapLayer FILL-FOREGROUND) 
        (gimp-drawable-edit-fill varBumpmapLayer FILL-FOREGROUND) ; second time to blend better
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
      (gimp-drawable-edit-fill varBumpmapLayer FILL-FOREGROUND) 
      (gimp-drawable-edit-fill varBumpmapLayer FILL-FOREGROUND)  ; second time to blend better
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
    (gimp-drawable-fill varBevelLayer FILL-FOREGROUND)

	(plug-in-bump-map RUN-NONINTERACTIVE img varBevelLayer varBumpmapLayer inAizmuth inElevation inDepth 0 0 0 0 
	                  TRUE (cond ((= inMode 0) FALSE) ((= inMode 1) TRUE)) 0)
	(gimp-layer-set-mode varBevelLayer LAYER-MODE-HARDLIGHT-LEGACY)
	(gimp-layer-set-opacity varBevelLayer 80)
	
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
	  (apply-gauss img varBevelLayer inBlur inBlur)
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
	
;	(gimp-image-set-active-layer img inLayer)
	(set! inLayer (car (gimp-image-merge-down img varBevelLayer EXPAND-AS-NECESSARY))) ;edit by graechan for this script only
	
	;done
    (gimp-progress-end)
	(gimp-image-undo-group-end img)
	(gimp-displays-flush)
	(gimp-context-pop)
  )
)
;
(define (easy-3d image drawable
                               3d-size
							   h-dir
							   v-dir
							   keep-selection-in
							   conserve
							   )
							  

 (let* (
            ;(image-layer (car (gimp-image-get-active-layer image)))
	    	(image-layer (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
			(width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(alpha (car (gimp-drawable-has-alpha image-layer)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (cond ((defined? 'gimp-image-get-item-position) (car (gimp-item-get-name image-layer)))
		    (else (car (gimp-item-get-name image-layer)))))
		    (keep-selection keep-selection-in)
			(selection-channel 0)
			(innermap 0)
			(image-mask 0)
			(ver 2.8)
			(ok TRUE)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			(3d-layer 0)
			(copy-layer 0)
			(cnt 3d-size)
			(horizontal 0)
			(vertical 0)
        )

	
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (begin
	(cond ((= ver 2.8) (gimp-image-select-item image 2 image-layer)) 
	(else (gimp-image-select-item image 2 image-layer)))
	)) ;endif
	
	;;;;save the selection    
    (set! selection-channel (car (gimp-selection-save image))) ;(gimp-image-select-item image 2 selection-channel)
	(gimp-selection-none image)
	
		; creating  map (inner shape)
		(set! innermap (car (gimp-layer-new  image width height RGB-IMAGE "iMap" 100 LAYER-MODE-NORMAL-LEGACY)))
		(include-layer image innermap image-layer 1)	;stack 0=above 1=below
		(gimp-context-set-foreground '(255 255 255))
		(gimp-drawable-edit-fill innermap FILL-FOREGROUND)
		(gimp-image-select-item image 2 selection-channel)
		(gimp-selection-shrink image 3)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-drawable-edit-fill innermap FILL-FOREGROUND)
		(gimp-selection-none image)
		(apply-gauss image innermap 6 6)

;		(gimp-context-set-foreground color)
;		(gimp-drawable-edit-fill image-layer FILL-FOREGROUND)

		(plug-in-bump-map
			1
			image
			image-layer
			innermap
			135
			32
			5
			0
			0
			0
			0
			1
			1
			0)
	
		(gimp-image-select-item image 2 selection-channel)
		(gimp-selection-shrink image 2)
		(set! image-mask (car (gimp-layer-create-mask image-layer ADD-MASK-SELECTION)))
		(gimp-layer-add-mask image-layer image-mask)
		(gimp-selection-none image)
		(apply-gauss image image-mask 1 1)
		(gimp-layer-remove-mask image-layer MASK-APPLY)
		(gimp-image-remove-layer image innermap)

	
	
	
	
	
	
	
;;;;begin the 3d script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	(gimp-image-set-active-layer image image-layer)
	(set! 3d-layer (car (gimp-layer-copy image-layer TRUE)))
	(gimp-image-insert-layer image 3d-layer 0 1)

    
	(set! horizontal
			(cond 
				(( equal? h-dir 0 ) 1) ;right
				(( equal? h-dir 1 ) 0) ;neutral
				(( equal? h-dir 2 ) -1) ;left
			)
		)
		
	(set! vertical
			(cond 
				(( equal? v-dir 0 ) 1) ;bottom
				(( equal? v-dir 1 ) 0) ;neutral
				(( equal? v-dir 2 ) -1) ;top
			)
		)
		
		
    	
	(gimp-selection-none image)
     (while (> cnt 0)
	(gimp-image-set-active-layer image 3d-layer)
	(set! copy-layer (car (gimp-layer-copy 3d-layer TRUE)))
	(gimp-image-insert-layer image copy-layer 0 -1)
    (gimp-item-transform-2d 
    copy-layer          ;The affected drawable
	0            ;X coordinate of the transformation center
	0            ;Y coordinate of the transformation center
	1             ;Amount to scale in x direction
	1             ;Amount to scale in y direction
	0               ;The angle of rotation (radians)
	horizontal              ;X coordinate of where the center goes
	vertical              ;Y coordinate of where the center goes
	;0              ;Direction of transformation { TRANSFORM-FORWARD (0), TRANSFORM-BACKWARD (1) }
	;2                   ;Type of interpolation { INTERPOLATION-NONE (0), INTERPOLATION-LINEAR (1), INTERPOLATION-CUBIC (2), INTERPOLATION-LANCZOS (3) }
	;TRUE                ;This parameter is ignored, supersampling is performed based on the interpolation type (TRUE or FALSE)
	;3                   ;Maximum recursion level used for supersampling (3 is a nice value) (recursion-level >= 1)
	;0)                  ;How to clip results { TRANSFORM-RESIZE-ADJUST (0), TRANSFORM-RESIZE-CLIP (1), TRANSFORM-RESIZE-CROP (2), TRANSFORM-RESIZE-CROP-WITH-ASPECT (3) }
)	(set! 3d-layer (car (gimp-image-merge-down image copy-layer EXPAND-AS-NECESSARY)))	
	(set! cnt (- cnt 1))
	)
    (if (or (= h-dir 0) (= v-dir 0)) (gimp-drawable-brightness-contrast 3d-layer 0.314960629921 0))	
	(gimp-layer-set-offsets image-layer (cond
	                                    ((= h-dir 2) (- 0 3d-size)) 
                                        ((= h-dir 0) 3d-size)
										(else 0)) ;endcond
										(cond
	                                    ((= v-dir 2) (- 0 3d-size)) 
                                        ((= v-dir 0) 3d-size)
										(else 0)) ;endcond
										)
	
;;;;finish the script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	(if (= conserve FALSE) (begin
	(set! image-layer (car (gimp-image-merge-down image image-layer EXPAND-AS-NECESSARY)))
	(gimp-layer-resize-to-image-size image-layer)))
    (cond ((= ver 2.8) (gimp-item-set-name image-layer (string-append layer-name "-3D")))
	(else (gimp-item-set-name image-layer (string-append layer-name "-3D")))
    ) ;endcond
	(gimp-image-select-item image 2 selection-channel)
    (if (= keep-selection FALSE) (gimp-selection-none image))
	(gimp-image-remove-channel image selection-channel)
;	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten image-layer)))	
    	
    
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
    



 )
)

(define (psychedelic-shine image drawable
                              shadow-size
							  shadow-opacity
							  keep-selection-in
							  conserve)
							  

 (let* (
            ;(image-layer (car (gimp-image-get-active-layer image)))
	(image-layer (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
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
	
	(set! img-layer (car (gimp-layer-new image width height RGBA-IMAGE "img-layer" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer image img-layer 0 -1)
	(gimp-drawable-fill img-layer  FILL-BACKGROUND)
	(gimp-drawable-edit-fill img-layer FILL-FOREGROUND)
	
;;;;create channel
	(gimp-selection-save image)
;	(set! img-channel (car (gimp-image-get-active-drawable image)))	
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (set! img-channel (car (gimp-image-get-active-drawable image)))
  (set! img-channel (vector-ref (car (gimp-image-get-selected-drawables image)) 0))	)
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
	(apply-gauss image img-layer 12 12)
	(plug-in-emboss RUN-NONINTERACTIVE image img-layer 225 84 10 TRUE)	
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear img-layer)
	(gimp-selection-invert image)
	(plug-in-colortoalpha RUN-NONINTERACTIVE image img-layer '(254 254 254));;fefefe
	(apply-gauss image img-channel 15 15)
	;(plug-in-blur RUN-NONINTERACTIVE image img-layer)
	(gimp-image-set-active-layer image bkg-layer)
(plug-in-displace RUN-NONINTERACTIVE image bkg-layer 8 8 TRUE TRUE img-channel img-channel 1)
(gimp-image-remove-layer image bkg-layer)
	
;;;;create the shadow
(if (> shadow-size 0)
  (begin
	(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
    (script-fu-drop-shadow image img-layer shadow-size shadow-size shadow-size '(0 0 0) shadow-opacity FALSE)
    (script-fu-drop-shadow image (vector img-layer) shadow-size shadow-size shadow-size '(0 0 0) shadow-opacity FALSE))
    (set! tmp-layer (car (gimp-layer-new image width height RGBA-IMAGE "temp" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image tmp-layer 0 -1)
	(gimp-image-raise-item image tmp-layer)
    (gimp-image-merge-down image tmp-layer CLIP-TO-IMAGE)
;	(set! shadow-layer (car (gimp-image-get-active-drawable image)))
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
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
;
 (define (technicolor-dream 
                               image
                               layer
							   gradient
							   blend-repititions
							   displace-repititions
							   keep-selection
							   )
	
    (gimp-image-undo-group-start image)	

 (let* (
            (width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(noise (car (gimp-layer-new image width height RGBA-IMAGE "Solid Noise" 100 LAYER-MODE-NORMAL-LEGACY)))
			(sel (car (gimp-selection-is-empty image)))
			(saved-selection 0)
			(cnt blend-repititions)
			(width-box 0)
			(height-box 0)
			(ver 2.8)
			(x1 0)
		    (y1 0)
		    (x2 0)
		    (y2 0)
        )

	
	(gimp-context-push)
	(gimp-context-set-paint-method "gimp-paintbrush")
 (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))
	(if (= ver 2.8) (gimp-context-set-dynamics "Pressure Opacity"))
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
    
	(cond ((= sel TRUE) (set! keep-selection FALSE))
	(else (set! saved-selection (car (gimp-selection-save image)))
	(gimp-selection-none image)))
	
;;;;begin the script here--------------------------------------------------------------------------------------------------------	
	(gimp-layer-add-alpha layer)
	(gimp-drawable-edit-clear layer)
	(gimp-drawable-fill layer FILL-BACKGROUND)
	
	
	(gimp-context-set-gradient gradient) 
	(while (> cnt 0)
	(set! width-box (round (random width )))
	(set! height-box (round (random height)))
                    ; set the arrays
    (set! x1 width-box)    
	(set! y1 height-box)
	(set! x2 (+ width-box 5))
	(set! y2 (+ height-box 5))	
	
(gimp-context-set-paint-mode LAYER-MODE-DIFFERENCE-LEGACY)
	;(gimp-edit-blend layer BLEND-CUSTOM LAYER-MODE-DIFFERENCE-LEGACY GRADIENT-CONICAL-SYMMETRIC 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE x1 y1 x2 y2)
		(gimp-drawable-edit-gradient-fill layer GRADIENT-CONICAL-SYMMETRIC 0 0 1 0 0 x1 y1 x2 y2)
	(set! cnt (- cnt 1))
	) ;endwhile
(gimp-context-set-paint-mode 0)
	
	(cond ((= ver 2.8)                         ;insert or add the new layer
	(gimp-image-insert-layer image noise 0 1)) ;new 2.8
	(else (gimp-image-insert-layer image noise 0 1)) ;new 2.6
	) ;endcond
	
	(plug-in-solid-noise 1 image noise FALSE FALSE 1611597286 1 (/ width 100) (/ height 100))
	
	(gimp-image-set-active-layer image layer)
	(set! cnt displace-repititions)
	(while (> cnt 0)
(plug-in-displace 1 
                  image 
				  layer ;drawable 
				  0 ;amount-x Displace multiplier for X or radial direction 
				  50 ;amount-y Displace multiplier for Y or tangent (degrees) direction
					  TRUE ;do-x Displace in X or radial direction?
					  TRUE ;Displace in Y or tangent direction?
					  noise ;displace-map-x Displacement map for X or radial direction[drawable] 
					  noise ;displace-map-y Displacement map for Y or tangent direction[drawable]
					  2) ;Edge behavior { WRAP (1), SMEAR (2), BLACK (3) }
	(set! cnt (- cnt 1))
	) ;endwhile
	(gimp-image-remove-layer image noise)
	(if (= keep-selection TRUE) (gimp-image-select-item image 2 saved-selection))
	(if (= sel FALSE) (gimp-image-remove-channel image saved-selection))
	
	
	
	
	
    
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
    



 )
) 
