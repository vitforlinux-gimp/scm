;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; Wrought Iron rel 0.01
; Created by Graechan
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
; Rel 0.02 - Little fix for gimp 2.10.32
; Rel 299 - Fixes for 2.10 compatibility OFF and 2.99.19 - alpha not works good

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

;(cond ((not (defined? 'gimp-image-get-active-drawable)) (define (gimp-image-get-active-drawable image) (aref (cadr (gimp-image-get-selected-drawables image)) 0))))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sfgrad "Crown molding")
  (define sfgrad "Crown Molding")	)

;
(define (script-fu-wrought-iron-299 image drawable
                               iron-size
							   spread
							   bev-w
							   bev-d
							   brightness
							   contrast
							   outline
							   bkg-fill
							   bkg-color
							   frame
							   frame-size
							   gradient
							   keep-selection-in
							   conserve)							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(alpha (car (gimp-drawable-has-alpha image-layer)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (car (gimp-item-get-name image-layer)))
			(keep-selection keep-selection-in)
		    (selection-channel 0)
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			(age-layer 0)
			(bkg-layer 0)
        )	
	
	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (gimp-image-undo-group-start image)
	(gimp-context-set-default-colors)	
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (gimp-image-select-item  image 2  image-layer))
	
;;;;create selection-channel (gimp-selection-load selection-channel)
    (gimp-selection-save image)
	;(set! selection-channel (car (gimp-image-get-active-drawable image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! selection-channel (aref (cadr (gimp-image-get-selected-drawables image)) 0))	)
(else (set! selection-channel (car (gimp-image-get-active-drawable image)))
	)
)	
	(gimp-channel-set-opacity selection-channel 100)	
	;(gimp-item-set-name selection-channel "selection-channel")
    ;(gimp-image-set-active-layer image image-layer)
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector image-layer)))
(else (gimp-image-set-active-layer image image-layer))
)      
	
    (gimp-drawable-edit-fill image-layer FILL-FOREGROUND)
	
;;;;begin the script
    (if (= outline FALSE) (begin
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear image-layer)
	(gimp-selection-invert image)
	(gimp-selection-shrink image iron-size)
	(gimp-drawable-edit-clear image-layer)
	(gimp-image-select-item  image 2  image-layer)))
	
;;;;create the age-layer layer    
	(set! age-layer (car (gimp-layer-new image width height RGBA-IMAGE "Aging-Layer" 100 LAYER-MODE-SCREEN-LEGACY)))
    (gimp-image-insert-layer image age-layer 0 -1)
    (gimp-image-select-rectangle image 0 0 0 1 1)
	(plug-in-solid-noise 1 image age-layer FALSE FALSE 0 1 4 4)
	(plug-in-spread 1 image age-layer spread (/ spread 9))
	(plug-in-gauss-rle2 1 image age-layer 5 5)
	(plug-in-bump-map 1 image age-layer age-layer 108 83 50 0 0 0 0 TRUE FALSE 2)
	(gimp-image-select-rectangle image 1 0 0 1 1)
	(gimp-drawable-curves-spline age-layer 0 12 #(0 0 0.117647058824 0.266666666667 0.270588235294 0.2862745098 0.501960784314 0.721568627451 0.729411764706 0.737254901961 1 1))
	(set! image-layer (car (gimp-image-merge-down image age-layer 0)))
	(the-wrought-iron-beveller image image-layer 18 0 0 bev-w 0 0 135 30 bev-d 3 10 FALSE)
	(set! image-layer (car (gimp-image-merge-down image (car (gimp-image-get-active-layer image)) 0)))
	(gimp-drawable-curves-spline image-layer 0 22 #(0 0 0.0823529411765 0.541176470588 0.145098039216 0.870588235294 0.2431372549 1 0.325490196078 0.901960784314 0.41568627451 0.650980392157 0.576470588235 0.341176470588 0.678431372549 0.247058823529 0.780392156863 0.352941176471 0.874509803922 0.627450980392 1 1))
	(gimp-drawable-brightness-contrast image-layer (/ brightness 127)  (/ contrast 127))	
	
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 1)
	(gimp-context-set-background bkg-color)
	(if (= bkg-fill TRUE) (gimp-drawable-fill bkg-layer FILL-BACKGROUND))

;;;;create the frame
	(if (= frame TRUE) (begin
    (the-wrought-iron-frame image bkg-layer
                            frame-size   ;xsize
							frame-size   ;ysize
							gradient
							FALSE   ;reverse
							FALSE   ;tint
							'(169 134 41)   ;tint-color
							FALSE   ;use-pattern
							"Crack"   ;pattern
							FALSE   ;lomo
							100   ;lomo-size
							80   ;lomo-opacity
							FALSE   ;keep-selection-in
							FALSE)))   ;conserve	
	
;;;;finish the script	
	(if (= conserve FALSE) (set! image-layer (car (gimp-image-merge-down image image-layer EXPAND-AS-NECESSARY))))
    (gimp-item-set-name image-layer layer-name)
    (if (= keep-selection TRUE) (gimp-image-select-item image 2 selection-channel))
	(gimp-image-remove-channel image selection-channel)
	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten image-layer)))	
	
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(script-fu-register "script-fu-wrought-iron-299"        		    
  "Wrought Iron Alpha 299"
  "Wrought Iron can Create shapes with the texture and look of wrought-iron work with optional frame and bkg color"
  "Graechan"
  "Graechan - Vitforlinux"
  "Dec 2012 - Lug 2024"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-ADJUSTMENT "Wrought-Iron Width" '(20 1 30 1 10 0 0)
  SF-ADJUSTMENT "Pitting Amount" '(100 0 200 1 10 0 0)
  SF-ADJUSTMENT "Bevel Width" '(5 1 100 1 10 0 0)
  SF-ADJUSTMENT "Bevel Depth" '(3 1 60 1 10 0 0)
  SF-ADJUSTMENT "Brightness" '(-50 -127 127 1 10 0 0)
  SF-ADJUSTMENT "Contrast" '(30 -127 127 1 10 0 0)
  SF-TOGGLE     "Use full Image not just Outline"   FALSE
  SF-TOGGLE     "Apply Bkg-Color"    FALSE
  SF-COLOR      "Background color"         '(153 153 153)
  SF-TOGGLE     "Apply a Frame"   FALSE
  SF-ADJUSTMENT  "Frame-Size"        '(50 1 250 1 10 0 0)
  SF-GRADIENT   "Border Gradient" sfgrad
  SF-TOGGLE     "Keep selection"    FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
 )
(script-fu-menu-register "script-fu-wrought-iron-299" "<Image>/Script-Fu/Alpha-to-Logo/")

(define (script-fu-wrought-iron-299-logo 
                                      text                                       
                                      font-in 
                                      font-size
									  spread
									  bev-w
									  bev-d
									  brightness
									  contrast
									  bkg-fill
									  bkg-color
									  frame
									  frame-size
									  gradient
									  conserve)
									  
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))         
         (border (/ font-size 3))
		 (font  font-in )
         (size-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (final-width (car (gimp-drawable-get-width size-layer)))
         (final-height (car (gimp-drawable-get-height size-layer)))
         (text-layer 0)
         (width 0)
         (height 0)		 
		 (iron-size 20)
		 (outline TRUE)
		 (bkg-layer 0)         
         )
		 
    (gimp-context-push)
	(gimp-context-set-paint-mode 0)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 350 3)) TRUE 350 PIXELS font)))
    (set! width (car (gimp-drawable-get-width text-layer)))
    (set! height (car (gimp-drawable-get-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)
	
;;;;centre text on line
	(gimp-text-layer-set-justification text-layer 2)

;;;;set the text clolor
	(gimp-image-select-item  image 2  text-layer)
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)

;;;;Start the script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    (script-fu-wrought-iron-299 image 
                            text-layer
							iron-size
							spread
							bev-w
							bev-d
							brightness
							contrast
							outline
							bkg-fill
							bkg-color
							FALSE  ;frame
							frame-size
							gradient
							FALSE  ;keep-selection-in
							TRUE)  ;conserve
							
	;(set! bkg-layer (car (gimp-image-get-active-layer image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! bkg-layer (aref (cadr (gimp-image-get-selected-drawables image)) 0))	)
(else (set! bkg-layer (car (gimp-image-get-active-layer image)))
	)
)

;;;;Scale Image to it's original size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-image-scale image final-width final-height)
	(set! width (car (gimp-image-get-width image)))
	(set! height (car (gimp-image-get-height image)))
	
	(if (= frame TRUE) (begin
	(the-wrought-iron-frame image bkg-layer
                            frame-size   ;xsize
							frame-size   ;ysize
							gradient
							FALSE   ;reverse
							FALSE   ;tint
							'(169 134 41)   ;tint-color
							FALSE   ;use-pattern
							"Crack"   ;pattern
							FALSE   ;lomo
							100   ;lomo-size
							80   ;lomo-opacity
							FALSE   ;keep-selection-in
							FALSE)))   ;conserve

	(if (= conserve FALSE) (begin
	(set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
	(gimp-item-set-name text-layer text)))

	(gimp-context-pop)

    (gimp-display-new image)
    )
  ) 
(script-fu-register "script-fu-wrought-iron-299-logo"
  "Wrought Iron Logo 299"
  "Wrought Iron can Create Logos with the texture and look of wrought-iron work with optional frame and bkg color"
  "Graechan"
  "Graechan - Vitforlinux"
  "Dec 2012 - Lug 2024"
  ""
  SF-TEXT       "Text"    "Wrought Iron"
  SF-FONT       "Font"               "QTAbbie"
  SF-ADJUSTMENT "Font size (pixels)" '(150 50 600 1 10 0 1)
  SF-ADJUSTMENT "Pitting Amount" '(100 0 200 1 10 0 0)
  SF-ADJUSTMENT "Bevel Width" '(5 1 100 1 10 0 0)
  SF-ADJUSTMENT "Bevel Depth" '(3 1 60 1 10 0 0)
  SF-ADJUSTMENT "Brightness" '(-50 -127 127 1 10 0 0)
  SF-ADJUSTMENT "Contrast" '(30 -127 127 1 10 0 0)
  SF-TOGGLE     "Apply Bkg-Color"    FALSE
  SF-COLOR      "Background color"         '(153 153 153)
  SF-TOGGLE     "Apply a Frame"   FALSE
  SF-ADJUSTMENT  "Frame-Size"        '(50 1 250 1 10 0 0)
  SF-GRADIENT   "Border Gradient" sfgrad
  SF-TOGGLE     "Keep the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-wrought-iron-299-logo" "<Image>/Script-Fu/Logos/")
  
(define (the-wrought-iron-beveller image drawable
                                  layer-mode
							      bev-type
							      bev-dir
							      bev-width
							      shape
							      prenoise
							      light-angle
							      light-elevation
							      depth
							      postblur
							      gloss
							      keep-selection-in)							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(alpha (car (gimp-drawable-has-alpha image-layer)))
			(image-channel 0)
			(bevel-layer 0)
			(name 0)
			(*newpoint* (cons-array 6 'double))
		    (*newpointx1* (cons-array 16 'double))
			(y1 0)
			(y2 0)
			(y3 0)
			(y4 0)
			(y5 0)
			(y6 0)
			(keep-selection keep-selection-in)
			(selection-bounds 0)
			(bounds-x1 0)
			(bounds-y1 0)
			(bounds-x2 0)
			(bounds-y2 0)						
        )	
	
	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made if not make one	
	(if (= (car (gimp-selection-is-empty image)) TRUE) (set! keep-selection FALSE))
	(if (= (car (gimp-selection-is-empty image)) TRUE) (gimp-image-select-item  image 2  image-layer))

;;;;find the selection co-ordinates	
	(set! selection-bounds (cdr (gimp-selection-bounds image)))
	(set! bounds-x1 (car selection-bounds));x coordinate of upper left corner of selection bounds
    (set! bounds-y1 (cadr selection-bounds));y coordinate of upper left corner of selection bounds
    (set! bounds-x2 (caddr selection-bounds));x coordinate of lower right corner of selection bounds
    (set! bounds-y2 (cadddr selection-bounds));y coordinate of lower right corner of selection bounds	
;;;;This means the width of the selection can be calculated as (x2 - x1), its height as (y2 - y1).

;;;;save the selection    
	(gimp-selection-save image)
	;(set! image-channel (car (gimp-image-get-active-drawable image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! image-channel (aref (cadr (gimp-image-get-selected-drawables image)) 0))	)
(else (set! image-channel (car (gimp-image-get-active-drawable image)))
	)
)	
	(gimp-channel-set-opacity image-channel 100)	
	(gimp-item-set-name image-channel "image-channel")
	;(gimp-image-set-active-layer image image-layer) MAH!
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector image-layer)))
(else (gimp-image-set-active-layer image image-layer))
)  

	
;;;;Add new layer with Bevel
    (if (= bev-type 0) (set! name "Inner bevel"))
    (if (= bev-type 1) (set! name "Outer bevel"))
    (gimp-image-select-item image 2 image-channel)
   ; (gimp-image-set-active-layer image image-layer) 
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector image-layer)))
(else (gimp-image-set-active-layer image image-layer))
)    
    (set! bevel-layer (car (gimp-layer-new image width height RGBA-IMAGE name 100 layer-mode)))
    (gimp-image-insert-layer image bevel-layer 0 -1)
;    (gimp-image-set-active-layer image bevel-layer)
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector bevel-layer)))
(else (gimp-image-set-active-layer image bevel-layer))
) 
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(255 255 255))
	;(if (> grow 0) (gimp-selection-grow image grow));;;;Expand the selection if needed
    (gimp-drawable-fill bevel-layer FILL-FOREGROUND)    
    (gimp-selection-shrink image 1)
    (gimp-selection-feather image bev-width)
    (if (= bev-type 0) (gimp-selection-shrink image (- (/ bev-width 2) 1)))
	(if (= bev-type 1) (gimp-selection-grow image (+ (/ bev-width 2) 1)))
    (gimp-drawable-edit-fill bevel-layer FILL-BACKGROUND)
;;;;apply shape curve
    (if (or (< shape 0) (> shape 0))
	(begin
					(aset *newpoint* 0 0)    ; set the arrays
					(aset *newpoint* 1 0)
					(aset *newpoint* 2  (/(+ (/ shape 10) 127) 255))
	                (aset *newpoint* 3 (+ shape 0.5))
					(aset *newpoint* 4 1)
					(aset *newpoint* 5 1)
	(gimp-drawable-curves-spline bevel-layer 0 6 *newpoint*)
    )
    )	

    (gimp-selection-all image)
;;;;invert colours of whole layer if down                
    (if (= bev-dir 1) (gimp-invert bevel-layer))
;;;;add prenoise
    (if (> prenoise 0) (plug-in-hsv-noise 1 image bevel-layer 4 0 0 prenoise))
                        						
;;;;emboss the selection    
    (plug-in-emboss RUN-NONINTERACTIVE image bevel-layer light-angle light-elevation depth 1);Emboss

;;;;gloss the bevel-layer    
     (if (> gloss 0)
				(begin
                    (set! y1 (* 1.0 gloss))
					(set! y2 (* 3.0 gloss)) 
                    (set! y3 (* 9.6 gloss))
                    (set! y4 (* 3.2 gloss))
                    (set! y5 (* 4.0 gloss))
                    (set! y6 (* 0.4 gloss))
					
					(aset *newpointx1* 0 0)    ; set the arrays
					(aset *newpointx1* 1 0)
					(aset *newpointx1* 2 0.247058823529)
	                (aset *newpointx1* 3 (/ (+ 63 y1) 255))
					(aset *newpointx1* 4 0.372549019608)
					(aset *newpointx1* 5 (/(+ 95 y2) 255))
					(aset *newpointx1* 6 0.5)
					(aset *newpointx1* 7 (/ (- 127 y3) 255))
					(aset *newpointx1* 8 0.611764705882)
					(aset *newpointx1* 9 (/(+ 156 y4) 255))
					(aset *newpointx1* 10 0.749019607843)
					(aset *newpointx1* 11 (/(- 191 y5) 255))
					(aset *newpointx1* 12 0.874509803922)
					(aset *newpointx1* 13 (/(+ 223 y6) 255))
					(aset *newpointx1* 14 1)
					(aset *newpointx1* 15 1)
					;(0,0, 63,(63 + y1), 95,(95 + y2), 127,(127 - y3), 156,(156 + y4), 191,(191 - y5), 223,(223 + y6), 255,255)
	 
	(gimp-drawable-curves-spline bevel-layer 0 16 *newpointx1*)
	 )
	 )
	(gimp-image-select-item image 2 image-channel)  
;postblur                
	(if (> postblur 0) (plug-in-gauss-rle2 RUN-NONINTERACTIVE image bevel-layer postblur postblur))
	;(if (> postblur 0) (plug-in-gauss-rle 1 image bevel-layer postblur TRUE TRUE))
	(gimp-layer-set-lock-alpha bevel-layer FALSE)
	
;reload selection
    (gimp-image-select-item image 2 image-channel)
                
;clear excess
    (if (= bev-type 0) 
	(begin
	(gimp-selection-shrink image 1)
	(gimp-selection-invert image) 
	(gimp-drawable-edit-clear bevel-layer)
	(gimp-selection-invert image)))

	(if (= bev-type 1) 
	(begin
	(gimp-selection-shrink image 1)
	(gimp-drawable-edit-clear bevel-layer)))    
 
;;;;Clean up the layers
    (if (= keep-selection FALSE) (gimp-selection-none image))
	(gimp-image-remove-channel image image-channel)
	(if (= alpha FALSE) (gimp-layer-flatten image-layer))	
    
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
	
 )
)

(define (the-wrought-iron-frame image drawable
                               xsize
							   ysize
							   gradient
							   reverse
							   tint
							   tint-color
							   use-pattern
							   pattern
							   lomo
							   lomo-size
							   lomo-opacity
							   keep-selection-in
							   conserve)							  

 (let* (
        (image-layer (car (gimp-image-get-active-layer image)))
		(old-width (car (gimp-drawable-get-width image-layer)))
        (old-height (car (gimp-drawable-get-height image-layer)))
		(width (+ old-width (* xsize 2)))
		(height (+ old-height (* ysize 2)))
		(alpha (car (gimp-drawable-has-alpha image-layer)))
		(typeA (car (gimp-drawable-type-with-alpha image-layer)))
		(sel (car (gimp-selection-is-empty image)))
		(layer-name (car (gimp-item-get-name image-layer)))
		(keep-selection keep-selection-in)
		(original-selection-channel 0)
		(selection-channel 0)
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		(border-layer 0)
		(tint-layer 0)
		(bump-layer 0)
		(*newpoint-top* (cons-array 10 'double))
		(*newpoint-bot* (cons-array 10 'double))
		(*newpoint-left* (cons-array 10 'double))
		(*newpoint-right* (cons-array 10 'double))
        )	
	
	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (gimp-image-undo-group-start image)
	(gimp-context-set-default-colors)
    
;;;;create original-selection-channel if a selection exists (gimp-selection-load original-selection-channel)
    (if (= sel FALSE) (begin
    (gimp-selection-save image)
	;(set! original-selection-channel (car (gimp-image-get-active-drawable image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! original-selection-channel (aref (cadr (gimp-image-get-selected-drawables image)) 0))	)
(else (set! original-selection-channel (car (gimp-image-get-active-drawable image)))
	)
)	
	(gimp-channel-set-opacity original-selection-channel 100)	
	(gimp-item-set-name original-selection-channel "original-selection-channel")
;    (gimp-image-set-active-layer image image-layer)
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector image-layer)))
(else (gimp-image-set-active-layer image image-layer))
) 
	(gimp-selection-none image)))	
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;create the Image selection  
	(gimp-image-select-rectangle image 2
                        (car (gimp-drawable-get-offsets image-layer))
                        (cadr (gimp-drawable-get-offsets image-layer))
                        old-width
                        old-height
						
						)    
	
;;;;create selection-channel (gimp-selection-load selection-channel)
    (gimp-selection-save image)
	;(set! selection-channel (car (gimp-image-get-active-drawable image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! selection-channel (aref (cadr (gimp-image-get-selected-drawables image)) 0))	)
(else (set! selection-channel (car (gimp-image-get-active-drawable image)))
	)
)	
	(gimp-channel-set-opacity selection-channel 100)	
	(gimp-item-set-name selection-channel "selection-channel")
;    (gimp-image-set-active-layer image image-layer)
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector image-layer)))
(else (gimp-image-set-active-layer image image-layer))
)
	(gimp-selection-none image)
	
;;;;begin the script
	
;;;;prepare for the border
    (if (= lomo TRUE) (the-gradient-frame-vignette image image-layer lomo-size lomo-opacity FALSE FALSE))
	
	(gimp-image-resize image width height xsize ysize)
	
	(set! border-layer (car (gimp-layer-new image width height typeA "Border" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image border-layer 0 -1)
	
	(if (= tint TRUE) (begin
	(set! tint-layer (car (gimp-layer-new image width height typeA "Tint" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image tint-layer 0 1) 
	(gimp-context-set-background tint-color)
	(gimp-image-select-item image 2 selection-channel)
	(gimp-selection-invert image)
	(gimp-layer-set-mode border-layer GRAIN-MERGE-MODE)
	(gimp-drawable-edit-fill tint-layer FILL-BACKGROUND)))
;	(gimp-image-set-active-layer image border-layer)
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector border-layer)))
(else (gimp-image-set-active-layer image border-layer))
)
	
	(set! bump-layer (car (gimp-layer-new image width height typeA "Grain" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bump-layer 0 -1)
	(gimp-item-set-visible bump-layer FALSE)
	(if (= use-pattern TRUE) (begin
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill bump-layer FILL-PATTERN)
	(gimp-desaturate bump-layer)))
	(gimp-selection-none image)
	
	(aset *newpoint-top* 0 0)    ; set the top arrays
	(aset *newpoint-top* 1 0)
	(aset *newpoint-top* 2 xsize)
	(aset *newpoint-top* 3 ysize)
	(aset *newpoint-top* 4 (+ xsize old-width))
	(aset *newpoint-top* 5 ysize)
	(aset *newpoint-top* 6 width)
	(aset *newpoint-top* 7 0)
	(aset *newpoint-top* 8 0)
	(aset *newpoint-top* 9 0)

	(aset *newpoint-bot* 0 0)    ; set the bottom arrays
	(aset *newpoint-bot* 1 height)
	(aset *newpoint-bot* 2 xsize)
	(aset *newpoint-bot* 3 (+ ysize old-height))
	(aset *newpoint-bot* 4 (+ xsize old-width))
	(aset *newpoint-bot* 5 (+ ysize old-height))
	(aset *newpoint-bot* 6 width)
	(aset *newpoint-bot* 7 height)
	(aset *newpoint-bot* 8 0)
	(aset *newpoint-bot* 9 height)
	
	(aset *newpoint-left* 0 0)    ; set the left arrays
	(aset *newpoint-left* 1 0)
	(aset *newpoint-left* 2 xsize)
	(aset *newpoint-left* 3 ysize)
	(aset *newpoint-left* 4 xsize)
	(aset *newpoint-left* 5 (+ ysize old-height))
	(aset *newpoint-left* 6 0)
	(aset *newpoint-left* 7 height)
	(aset *newpoint-left* 8 0)
	(aset *newpoint-left* 9 0)
	
	(aset *newpoint-right* 0 width)    ; set the right arrays
	(aset *newpoint-right* 1 0)
	(aset *newpoint-right* 2 (+ xsize old-width))
	(aset *newpoint-right* 3 ysize)
	(aset *newpoint-right* 4 (+ xsize old-width))
	(aset *newpoint-right* 5 (+ ysize old-height))
	(aset *newpoint-right* 6 width)
	(aset *newpoint-right* 7 height)
	(aset *newpoint-right* 8 width)
	(aset *newpoint-right* 9 0)
	
	(gimp-context-set-gradient gradient)
;;;;create the top of border
	;(gimp-free-select image 10 *newpoint-top* 2 TRUE FALSE 15)
	(gimp-image-select-polygon image 2 10 *newpoint-top*)
	;(gimp-edit-blend border-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY  GRADIENT-LINEAR 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE (/ width 2) 0 (/ width 2) ysize)
	(gimp-context-set-gradient-reverse reverse)
	(gimp-drawable-edit-gradient-fill border-layer GRADIENT-LINEAR 0 0 1 0 0  (/ width 2) 0 (/ width 2) ysize) ; Fill with gradient

;;;;create the bottom of border
	;(gimp-free-select image 10 *newpoint-bot* 2 TRUE FALSE 15)
	(gimp-image-select-polygon image 2 10 *newpoint-bot*)
	;(gimp-edit-blend border-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY  GRADIENT-LINEAR 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE (/ width 2) height (/ width 2) (+ old-height ysize))
	(gimp-context-set-gradient-reverse reverse)
	(gimp-drawable-edit-gradient-fill border-layer GRADIENT-LINEAR 0 0 1 0 0  (/ width 2) height (/ width 2) (+ old-height ysize)) ; Fill with gradient
;;;;create the left of border
	;(gimp-free-select image 10 *newpoint-left* 2 TRUE FALSE 15)
	(gimp-image-select-polygon image 2 10 *newpoint-left*)
	;(gimp-edit-blend border-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY  GRADIENT-LINEAR 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE 0 (/ height 2) xsize (/ height 2))
	(gimp-context-set-gradient-reverse reverse)
	(gimp-drawable-edit-gradient-fill border-layer GRADIENT-LINEAR 0 0 1 0 0   0 (/ height 2) xsize (/ height 2)) ; Fill with gradient
;;;;create the right of border
	;(gimp-free-select image 10 *newpoint-right* 2 TRUE FALSE 15)
	(gimp-image-select-polygon image 2 10 *newpoint-right*)
	;(gimp-edit-blend border-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY  GRADIENT-LINEAR 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE width (/ height 2) (+ old-width xsize) (/ height 2))
	(gimp-context-set-gradient-reverse reverse)
	(gimp-drawable-edit-gradient-fill border-layer GRADIENT-LINEAR 0 0 1 0 0  width (/ height 2) (+ old-width xsize) (/ height 2)) ; Fill with gradient
    (gimp-selection-none image)
	
;	(gimp-image-set-active-layer image border-layer)
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector border-layer)))
(else (gimp-image-set-active-layer image border-layer))
)  
	(if (= tint TRUE) (plug-in-sample-colorize 1 image border-layer tint-layer TRUE FALSE FALSE TRUE 0 255 1.00 0 255))
	(if (= use-pattern TRUE) (plug-in-bump-map 1 image border-layer bump-layer 135 45 3 0 0 0 0 TRUE FALSE LINEAR))

;;;;finish the script	
	(if (= conserve FALSE) (begin  
    (set! border-layer (car (gimp-image-merge-down image border-layer EXPAND-AS-NECESSARY)))
	;(set! image-layer (car (gimp-image-merge-down image border-layer EXPAND-AS-NECESSARY)))
	(gimp-image-remove-layer image bump-layer)
   ; (gimp-item-set-name image-layer layer-name)
    ))
    (if (and (= sel TRUE) (= keep-selection TRUE)) (gimp-image-select-item image 2 selection-channel))
	(if (and (= sel FALSE) (= keep-selection TRUE)) (gimp-image-select-item image 2 original-selection-channel))
	(gimp-image-remove-channel image selection-channel)
	(if (= sel FALSE) (gimp-image-remove-channel image original-selection-channel))
	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten image-layer)))	
	
   	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)  
