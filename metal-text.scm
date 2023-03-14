; Metal Text rel 0.08
; Created by Graechan
; fix 2.10.22 by vitforlinux
;
;    Thanks to Draconian for his great tutorials
;    that inspired me to write this script. 
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
; Rel 0.02 - Changed code to remove reliance on drawable Multiplication to provide 3D effect
;          - Added pixal setting for 3D height
; Rel 0.03 - Added code to use the users default font Instead of my Menu's default if their system does not have it.
;          - Thahkyou bkh1914 for the code to do this (saved me reinventing the wheel).
;          - Added choice of either of the 3 of Draconians curves, Maximum, Medium or soft to create the metalic image.
;          - Added a brightness control that effects the image.
; Rel 0.04 - Added additional Backgrounds,inluding a lomo-option and changed the text image to face different direction
; Rel 0.05 - Fixed bug when deselecting 3D Script fails "OOPS"
; Rel 0.06 - Added the Alpha Script to the file
; Rel 0.07 - Added additional settings and fixed bug in "Metal Finish Type" selection
; Rel 0.08 - Two fixes for gimp 2.10.22
;;;;

(define (script-fu-metal-alpha-to-logo image drawable
                                                     metal
									                 polish
									                 bright
									                 tint-color
									                 3d-effect
									                 pixels
													 bkg-type 
                                                     pattern
                                                     bkg-color
									                 gradient
													 gradient-type-in
													 lomo
													 lomo-size
							                         opacity
													 top
													 size
													 keep-selection-in
							                         conserve)


 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(final-width (car (gimp-image-width image)))
			(final-height (car (gimp-image-height image)))
			(width 0)
			(height 0)
			(alpha (car (gimp-drawable-has-alpha image-layer)))
			(sel (car (gimp-selection-is-empty image)))
			(layer-name (car (gimp-drawable-get-name image-layer)))			
			(img 0)
			(activeLayer 0)
			(original-layer 0)
			(img-channel 0)
			(bkg-layer 0)
			(tint-layer 0)
		    (3d-layer 0)
		    (layers pixels)
			(copy-layer 0)
			(inc -1)
		    (offx inc)
		    (offy inc)
		    (brushName    "outlineBrush")
		    (outline 4)
		    (vectors 0)
			(shadow-size 8)
		    (shadow-opacity 50)
		    (size-layer 0)
			(beam-height-in 0)
			(grunge-layer 0)
			(grunge-color bkg-color)
			(random_gradient 0)
			(gradient-type 0)
			(name-string 0)
		    (gradient-type-name 0)
		    (gradient-type-blend 0)
		    (lomo-layer 0)
			(metal-layer 0)
			(keep-selection keep-selection-in)			
        )	
	
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
	(set! original-layer (car (gimp-layer-copy image-layer TRUE)))
    (gimp-image-add-layer image original-layer 1)
	(gimp-drawable-set-name original-layer "original-layer")
	(if (= sel FALSE)
	(begin
	(gimp-selection-invert image)
    (gimp-edit-clear original-layer)
	(gimp-selection-invert image)))
	(gimp-drawable-set-visible original-layer FALSE)
	
	(gimp-image-scale-full image (* final-width 2) (* final-height 2) 2)
    (set! width (car (gimp-image-width image)))
	(set! height (car (gimp-image-height image)))
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (gimp-selection-layer-alpha image-layer))

;;;;set the image clolor to white    
    (gimp-context-set-foreground '(255 255 255))
	(gimp-edit-fill image-layer FOREGROUND-FILL)

;;;;adjust the image size
	(gimp-image-resize image (+ width (* pixels 2)) (+ height (* pixels 2)) 0 0)
	(gimp-layer-resize-to-image-size image-layer)
	(set! width (car (gimp-image-width image)))
	(set! height (car (gimp-image-height image)))
	
;;;;save the selection
	(gimp-selection-save image)
	(set! img-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity img-channel 100)	
	(gimp-drawable-set-name img-channel "img-channel")
	(gimp-selection-none image)
		
;;;;blur the img-channel
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image img-channel 10 10)
	(gimp-image-set-active-layer image image-layer)
    
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 NORMAL-MODE)))
    (gimp-image-add-layer image bkg-layer 1)
	(gimp-image-set-active-layer image image-layer)
	
;;;;;;;;;;;;;;;;Main body of Script;;;;;;;;;;	
	(gimp-selection-load img-channel)
	(gimp-edit-clear image-layer)
	(plug-in-solid-noise RUN-NONINTERACTIVE image image-layer 0 0 0 1 5 5)
	(plug-in-bump-map RUN-NONINTERACTIVE image image-layer img-channel 360 45 38 0 0 0 0 TRUE FALSE 0)
	(if (= polish 0) (gimp-curves-spline image-layer 0 18 #(0 255 30 0 65 255 95 0 125 255 160 0 190 255 222 0 255 255)));max
	(if (= polish 1) (gimp-curves-spline image-layer 0 14 #(0 0 31 193 79 30 127 255 191 94 222 255 255 185)));med
	(if (= polish 2) (gimp-curves-spline image-layer 0 14 #(0 0 32 160 94 63 127 223 190 161 222 255 255 255)));soft
	(gimp-brightness-contrast image-layer bright bright)
	(gimp-selection-invert image)
    (gimp-edit-clear image-layer)
	(gimp-selection-invert image)

 (if (= metal 1) (gimp-context-set-foreground '(255 215 0)));gold 	
 (if (= metal 2) (gimp-context-set-foreground '(192 192 192)));silver	
 (if (= metal 3) (gimp-context-set-foreground '(250 180 150)));copper
 (if (= metal 4) (gimp-context-set-foreground '(166 125 61)));bronze
 (if (= metal 5) (gimp-context-set-foreground tint-color));colored tint
 (if (> metal 0)
   (begin 
	(set! tint-layer (car (gimp-layer-new image width height RGBA-IMAGE "Tint" 100 MULTIPLY-MODE)))
    (gimp-image-add-layer image tint-layer (car (gimp-image-get-layer-position image image-layer))) 
	(gimp-edit-fill tint-layer FOREGROUND-FILL)
	(gimp-selection-invert image)
    (gimp-edit-clear tint-layer)
    (set! image-layer (car (gimp-image-merge-down image tint-layer 0)))	 
   )
 )	
	(gimp-image-set-active-layer image image-layer)
	(gimp-drawable-set-name image-layer "Image-layer")
	(gimp-selection-none image)

;;;; define new brush for drawing operation
            (gimp-brush-new brushName)
			(gimp-brush-set-shape brushName BRUSH-GENERATED-CIRCLE)    
            (gimp-brush-set-spikes brushName 2)
            (gimp-brush-set-hardness brushName 1.00)                   
            (gimp-brush-set-aspect-ratio brushName 1.0)
            (gimp-brush-set-angle brushName 0.0)                       
            (gimp-brush-set-spacing brushName 1.0)
            (gimp-brush-set-radius brushName outline)            
            (gimp-context-set-brush brushName)
			(gimp-context-set-brush-default-size)
            (gimp-context-set-foreground '(0 0 0))
 
;;;;create the 3d-layer	
 (if (= 3d-effect TRUE)
   (begin
    (gimp-image-resize image (+ width pixels) (+ height pixels) pixels pixels)
	(gimp-layer-resize-to-image-size bkg-layer)
	(gimp-layer-resize-to-image-size image-layer)
	(set! 3d-layer (car (gimp-layer-copy image-layer TRUE)))
    (gimp-image-add-layer image 3d-layer -1)
    (gimp-drawable-set-name 3d-layer "3D Layer")
	(while (> layers 0)
	(set! copy-layer (car (gimp-layer-copy image-layer TRUE)))
    (gimp-image-add-layer image copy-layer -1)
    (gimp-layer-set-offsets copy-layer offx offy)
	(if (= offx inc) 
	(begin
	(gimp-selection-layer-alpha copy-layer)
	(plug-in-sel2path 1 image copy-layer)
	(gimp-selection-none image)
	(set! vectors (car (gimp-image-get-active-vectors image)))
	(gimp-edit-stroke-vectors copy-layer vectors)
	(gimp-image-remove-vectors image vectors)))
	(set! 3d-layer (car (gimp-image-merge-down image copy-layer CLIP-TO-IMAGE)))
	(set! layers (- layers 1))
	(set! offx (+ offx inc))
	(set! offy (+ offy inc))
	)
    (gimp-layer-set-offsets 3d-layer pixels pixels)
    (gimp-image-raise-layer-to-top image image-layer)
    (set! 3d-layer (car (gimp-image-merge-down image image-layer 0)))
	(gimp-drawable-set-name 3d-layer (string-append layer-name "-3D"))
   )
 )
	(gimp-brush-delete brushName)
	    
    (gimp-displays-flush)
		

;;;;Scale Image to it's original size and apply the text Shine 
    (gimp-image-scale-full image final-width final-height 2)
	(set! width (car (gimp-image-width image)))
	(set! height (car (gimp-image-height image)))
	(set! 3d-layer (car (gimp-image-get-active-layer image)))
	(if (= 3d-effect FALSE) (gimp-drawable-set-name 3d-layer layer-name))
	(the-metal-text-shine image 3d-layer shadow-size shadow-opacity FALSE)

	;;;;fill the background layer
    (gimp-layer-resize bkg-layer (+ width (* (/ width 100) 40)) (+ height (* (/ height 100) 40)) (* (/ width 100) 20) (* (/ height 100) 20))
	(gimp-image-resize-to-layers image)
	(if (= bkg-type 0)
	(begin
	(set! 3d-layer (car (gimp-image-get-active-layer image)))
	(gimp-image-lower-layer image 3d-layer)
	(set! size-layer (car (gimp-layer-copy 3d-layer TRUE)))
    (gimp-image-add-layer image size-layer -1)
	(plug-in-autocrop-layer 1 image size-layer)
	(set! beam-height-in (car (gimp-drawable-height size-layer)))
	(gimp-image-remove-layer image size-layer)
	(gimp-drawable-set-visible 3d-layer FALSE)
	(gimp-image-set-active-layer image bkg-layer)
	(the-background-light&waves image bkg-layer beam-height-in 10 "Incandescent" TRUE 50 conserve)
	(set! bkg-layer (car (gimp-image-merge-visible-layers image 0)))
	(gimp-image-lower-layer image bkg-layer)
	(gimp-drawable-set-name bkg-layer "Light&Waves")
	(gimp-drawable-set-visible 3d-layer TRUE)))	
    
	(if (= bkg-type 1)
	(begin
    (gimp-image-set-active-layer image bkg-layer)
	(the-metal-text-grunge-bkg image bkg-layer grunge-color 100 TRUE TRUE) ;grunge-color
	(set! grunge-layer (car (gimp-image-get-active-layer image)))
	(set! bkg-layer (car (gimp-image-merge-down image grunge-layer EXPAND-AS-NECESSARY)))
	(gimp-drawable-set-name bkg-layer "Grunge")))

	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 2) 
	(begin
	(gimp-drawable-fill bkg-layer PATTERN-FILL)
	(gimp-drawable-set-name bkg-layer (string-append (car (gimp-drawable-get-name bkg-layer)) "_pattern" "_" pattern))))		
    (if (= bkg-type 3) 
	(begin
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)	
    (gimp-drawable-set-name bkg-layer (string-append (car (gimp-drawable-get-name bkg-layer)) "_color"))))
	(if (= bkg-type 4) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)
	(set! gradient-type-blend
			(cond 
				(( equal? gradient-type-in 0 ) GRADIENT-SHAPEBURST-ANGULAR)
				(( equal? gradient-type-in 1 ) GRADIENT-SHAPEBURST-SPHERICAL)
				(( equal? gradient-type-in 2 ) GRADIENT-SHAPEBURST-DIMPLED)))
	(set! gradient-type-name
			(cond 
				(( equal? gradient-type-in 0 ) "GRADIENT-SHAPEBURST-ANGULAR")
				(( equal? gradient-type-in 1 ) "GRADIENT-SHAPEBURST-SPHERICAL")
				(( equal? gradient-type-in 2 ) "GRADIENT-SHAPEBURST-DIMPLED")))			
	(gimp-edit-blend bkg-layer CUSTOM-MODE NORMAL-MODE gradient-type-blend 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
	(gimp-drawable-set-name bkg-layer (string-append gradient "_" gradient-type-name))))
;;;;create the random gradients
	(if (= bkg-type 5)
    (begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)
	(set! random_gradient (list-ref (cadr (gimp-gradients-get-list "")) (round (random (car (gimp-gradients-get-list ""))))))
    (set! gradient-type (+ 6 (random 3)))
	(gimp-context-set-gradient random_gradient)
	(gimp-edit-blend bkg-layer CUSTOM-MODE NORMAL-MODE gradient-type 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
	
	(set! gradient-type-name
			(cond 
				(( equal? gradient-type 6 ) "GRADIENT-SHAPEBURST-ANGULAR")
				(( equal? gradient-type 7 ) "GRADIENT-SHAPEBURST-SPHERICAL")
				(( equal? gradient-type 8 ) "GRADIENT-SHAPEBURST-DIMPLED")))
				
	(set! name-string (string-append (car (gimp-drawable-get-name bkg-layer)) "- Gradient " random_gradient "- Shape " gradient-type-name))
	(gimp-drawable-set-name bkg-layer name-string)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))))
    (if (= size TRUE) (gimp-image-scale-full image final-width final-height 2))
 ;;;;add the lomo to bkg
    (if (and (= lomo TRUE)  (> bkg-type 0))
	(begin
	(if (= bkg-type 6) 
    (begin 
	(gimp-context-set-background '(255 255 255))
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)))
	(gimp-selection-load img-channel)
	(gimp-image-set-active-layer image bkg-layer)
	(the-metal-text-lomo image (car (gimp-image-get-active-layer image)) lomo-size opacity FALSE TRUE)	
	(set! lomo-layer (car (gimp-image-get-active-layer image)))
	(gimp-layer-set-opacity lomo-layer opacity)
	(if (and (< bkg-type 6)  (> bkg-type 0)) (plug-in-colortoalpha 1 image lomo-layer '(255 255 255)))
	(if (= bkg-type 6) 
	(begin
	(set! bkg-layer (car (gimp-image-merge-down image lomo-layer EXPAND-AS-NECESSARY)))
	(plug-in-colortoalpha 1 image bkg-layer '(255 255 255))))	
	))	
	(gimp-image-resize-to-layers image)
    
	(if (= keep-selection TRUE) (gimp-selection-load img-channel))
	
	(if (= top TRUE) (gimp-image-raise-item-to-top image original-layer))
	(gimp-drawable-set-visible original-layer TRUE)
	
	(if (= conserve FALSE) 
    (begin 
	(set! metal-layer (car (gimp-image-merge-visible-layers image 0)))	
	(gimp-drawable-set-name metal-layer layer-name)
	(if (= 3d-effect TRUE) (gimp-drawable-set-name metal-layer (string-append layer-name "-3D")))
	(gimp-image-remove-channel image img-channel)
	))
	
    (if (= bkg-type 5)
	(begin
	(set! name-string (string-append (car (gimp-drawable-get-name metal-layer)) "- Gradient= " random_gradient "- Shape " gradient-type-name))	
	(gimp-drawable-set-name metal-layer name-string)))
	

	
	
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(script-fu-register "script-fu-metal-alpha-to-logo"        		    
                    "Metal Alpha"
                     "Rel6-Create a Metalic Image over a Background layer."
                    "Graechan"
                    "Graechan - http://gimpchat.com"
                    "Oct 2012"
                    "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-OPTION "Metal Finish Type" '("Chrome" "Gold" "Silver" "Copper" "Bronze" "Colored Tint")
  SF-OPTION "Metal Finish polish" '("Maximum" "Medium" "Soft")
  SF-ADJUSTMENT "Brightness" '(50 0 100 1 10 0 0)
  SF-COLOR      "Tint Color"         '(0 0 255)
  SF-TOGGLE     "Add a 3D Effect"   TRUE
  SF-ADJUSTMENT "3D Height (pixels)" '(30 1 100 1 10 0 0)
  SF-OPTION     "Background Type" '("Starlight" "Grunge" "Pattern" "Color" "Gradient" "Random Gradient" "None")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background and Grunge color"         '(153 153 153)
  SF-GRADIENT   "Background Gradient" "Horizon 2"
  SF-OPTION     "Gradient Shape if Bkg-type=gradient" '("GRADIENT-SHAPEBURST-ANGULAR" "GRADIENT-SHAPEBURST-SPHERICAL" "GRADIENT-SHAPEBURST-DIMPLED")
  SF-TOGGLE     "Add Lomo to Background"   FALSE
  SF-ADJUSTMENT "Lomo Size" '(0 0 200 1 10 0 0)
  SF-ADJUSTMENT "Lomo Opacity" '(80 0 100 1 10 0 0)
  SF-TOGGLE     "Place Original Image on Top"    FALSE
  SF-TOGGLE     "Keep Original Alpha or Selection Size"    FALSE
  SF-TOGGLE     "Keep selection"    FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
)

(script-fu-menu-register "script-fu-metal-alpha-to-logo" "<Image>/Script-Fu/Alpha-to-Logo/")


(define (script-fu-metal-text 
                                      text
                                      justify
									  letter-spacing
									  line-spacing									  
                                      font-in 
                                      size
									  metal
									  polish
									  bright
									  tint-color
									  3d-effect
									  pixels
                                      bkg-type 
                                      pattern
                                      bkg-color
									  gradient
									  gradient-type-in
									  lomo
									  lomo-size
							          opacity
									  conserve)
									  
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))         
         (border (/ size 3))
		 (font (if (> (string-length font-in) 0) font-in (car (gimp-context-get-font))))
         (size-layer (car (gimp-text-fontname image -1 0 0 text border TRUE size PIXELS font)))
         (final-width (car (gimp-drawable-width size-layer)))
         (final-height (car (gimp-drawable-height size-layer)))
         (text-layer 0)
         (width 0)
         (height 0)
         (bkg-layer 0)
		 (img-channel 0)
		 (tint-layer 0)
		 (metal-text-layer 0)
		 (3d-layer 0)
		 (layers pixels)
		 (copy-layer 0)
		 (inc -1)
		 (offx inc)
		 (offy inc)
		 (brushName    "outlineBrush")
		 (outline 4)
		 (vectors 0)
		 (shadow-size 8)
		 (shadow-opacity 50)
		 (beam-height-in 0)
		 (random_gradient 0)
		 (gradient-type 8)
		 (grunge-layer 0)
		 (grunge-color bkg-color)
		 (name-string 0)
		 (gradient-type-name 0)
		 (gradient-type-blend 0)
		 (lomo-layer 0)
		 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))
         )
		 
    (gimp-context-push)
;;;;Adjust the text on size-layer
	(gimp-text-layer-set-justification size-layer justify)
	(gimp-text-layer-set-letter-spacing size-layer letter-spacing)
	(gimp-text-layer-set-line-spacing size-layer line-spacing)
	(set! final-width (car (gimp-drawable-width size-layer)))
    (set! final-height (car (gimp-drawable-height size-layer)))	
	
;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 632 3)) TRUE 632 PIXELS font)))
    (gimp-text-layer-set-justification text-layer justify)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
	(set! width (car (gimp-drawable-width text-layer)))
    (set! height (car (gimp-drawable-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)

;;;;set the text clolor to white    
    (gimp-context-set-foreground '(255 255 255))
	(gimp-selection-layer-alpha text-layer)
	(gimp-edit-fill text-layer FOREGROUND-FILL)
	
;;;;save the selection
	(gimp-selection-save image)
	(set! img-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity img-channel 100)	
	(gimp-drawable-set-name img-channel "img-channel")
	(gimp-selection-none image)
	
;;;;blur the img-channel
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image img-channel 10 10)
	(gimp-image-set-active-layer image text-layer)
	          
;;;;resize the text-layer		
    (gimp-image-set-active-layer image text-layer)
	(gimp-layer-resize-to-image-size text-layer)    

;;;;;;;;;;;;Main body of Script;;;;;;;;;;
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 NORMAL-MODE)))
    (gimp-image-add-layer image bkg-layer 1)
    (gimp-image-set-active-layer image text-layer)	
	(gimp-selection-load img-channel)
	(gimp-edit-clear text-layer)
	(plug-in-solid-noise RUN-NONINTERACTIVE image text-layer 0 0 0 1 5 5)
	(plug-in-bump-map RUN-NONINTERACTIVE image text-layer img-channel 360 45 38 0 0 0 0 TRUE FALSE 0)
	(if (= polish 0) (gimp-curves-spline text-layer 0 18 #(0 255 30 0 65 255 95 0 125 255 160 0 190 255 222 0 255 255)));max
	(if (= polish 1) (gimp-curves-spline text-layer 0 14 #(0 0 31 193 79 30 127 255 191 94 222 255 255 185)));med
	(if (= polish 2) (gimp-curves-spline text-layer 0 14 #(0 0 32 160 94 63 127 223 190 161 222 255 255 255)));soft
	(gimp-brightness-contrast text-layer bright bright)
	(gimp-selection-invert image)
    (gimp-edit-clear text-layer)
	(gimp-selection-invert image)

 (if (= metal 1) (gimp-context-set-foreground '(255 215 0)));gold 	
 (if (= metal 2) (gimp-context-set-foreground '(192 192 192)));silver	
 (if (= metal 3) (gimp-context-set-foreground '(250 180 150)));copper
 (if (= metal 4) (gimp-context-set-foreground '(166 125 61)));bronze
 (if (= metal 5) (gimp-context-set-foreground tint-color));colored tint
 (if (> metal 0)
   (begin 
	(set! tint-layer (car (gimp-layer-new image width height RGBA-IMAGE "Tint" 100 MULTIPLY-MODE)))
    (gimp-image-add-layer image tint-layer (car (gimp-image-get-layer-position image text-layer))) 
	(gimp-edit-fill tint-layer FOREGROUND-FILL)
	(gimp-selection-invert image)
    (gimp-edit-clear tint-layer)
    (set! text-layer (car (gimp-image-merge-down image tint-layer CLIP-TO-IMAGE)))	 
   )
 )	
	(gimp-drawable-set-name text-layer "Text Layer")
	(gimp-selection-none image)

;;;; define new brush for drawing operation
            (gimp-brush-new brushName)
			(gimp-brush-set-shape brushName BRUSH-GENERATED-CIRCLE)    
            (gimp-brush-set-spikes brushName 2)
            (gimp-brush-set-hardness brushName 1.00)                   
            (gimp-brush-set-aspect-ratio brushName 1.0)
            (gimp-brush-set-angle brushName 0.0)                       
            (gimp-brush-set-spacing brushName 1.0)
            (gimp-brush-set-radius brushName outline)            
            (gimp-context-set-brush brushName)
			(gimp-context-set-brush-default-size)
            (gimp-context-set-foreground '(0 0 0))
 
;;;;create the 3d-layer	
 (if (= 3d-effect TRUE)
   (begin
    (set! 3d-layer (car (gimp-layer-copy text-layer TRUE)))
    (gimp-image-add-layer image 3d-layer -1)
    (gimp-drawable-set-name 3d-layer "3D Layer")
	(while (> layers 0)
	(set! copy-layer (car (gimp-layer-copy text-layer TRUE)))
    (gimp-image-add-layer image copy-layer -1)
    (gimp-layer-set-offsets copy-layer offx offy)
	(if (= offx inc) 
	(begin
	(gimp-selection-layer-alpha copy-layer)
	(plug-in-sel2path 1 image copy-layer)
	(gimp-selection-none image)
	(set! vectors (car (gimp-image-get-active-vectors image)))
	(gimp-edit-stroke-vectors copy-layer vectors)
	(gimp-image-remove-vectors image vectors)))
	(set! 3d-layer (car (gimp-image-merge-down image copy-layer CLIP-TO-IMAGE)))
	(set! layers (- layers 1))
	(set! offx (+ offx inc))
	(set! offy (+ offy inc))
	)
    (gimp-layer-set-offsets 3d-layer pixels pixels)
    (gimp-image-raise-layer-to-top image text-layer)
    (set! 3d-layer (car (gimp-image-merge-down image text-layer 0)))
	(gimp-drawable-set-name 3d-layer (string-append text "-3D"))
   )
 )
    (gimp-brush-delete brushName)
;;;;Scale Image to it's original size and apply the text Shine 
    (gimp-image-scale-full image final-width final-height 2)
	(set! width (car (gimp-image-width image)))
	(set! height (car (gimp-image-height image)))
	(set! 3d-layer (car (gimp-image-get-active-layer image)))
	(if (= 3d-effect FALSE) (gimp-drawable-set-name 3d-layer text))
	(the-metal-text-shine image 3d-layer shadow-size shadow-opacity FALSE)
	
;;;;fill the background layer
	(if (= bkg-type 0)
	(begin
	(set! 3d-layer (car (gimp-image-get-active-layer image)))
	(gimp-image-lower-layer image 3d-layer)
	(set! size-layer (car (gimp-layer-copy 3d-layer TRUE)))
    (gimp-image-add-layer image size-layer -1)
	(plug-in-autocrop-layer 1 image size-layer)
	(set! beam-height-in (car (gimp-drawable-height size-layer)))
	(gimp-image-remove-layer image size-layer)
	(gimp-drawable-set-visible 3d-layer FALSE)
	(gimp-image-set-active-layer image bkg-layer)
	(the-background-light&waves image bkg-layer beam-height-in 10 "Incandescent" TRUE 50 conserve)
	(set! bkg-layer (car (gimp-image-merge-visible-layers image 0)))
	(gimp-image-lower-layer image bkg-layer)
	(gimp-drawable-set-name bkg-layer "Light&Waves")
	(gimp-drawable-set-visible 3d-layer TRUE)))	
    
	(if (= bkg-type 1)
	(begin
    (gimp-image-set-active-layer image bkg-layer)
	(the-metal-text-grunge-bkg image bkg-layer grunge-color 100 TRUE TRUE) ;grunge-color
	(set! grunge-layer (car (gimp-image-get-active-layer image)))
	(set! bkg-layer (car (gimp-image-merge-down image grunge-layer EXPAND-AS-NECESSARY)))
	(gimp-drawable-set-name bkg-layer "Grunge")))	
	
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 2) 
	(begin
	(gimp-drawable-fill bkg-layer PATTERN-FILL)
	(gimp-drawable-set-name bkg-layer (string-append (car (gimp-drawable-get-name bkg-layer)) "_pattern" "_" pattern))))		
    (if (= bkg-type 3) 
	(begin
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)	
    (gimp-drawable-set-name bkg-layer (string-append (car (gimp-drawable-get-name bkg-layer)) "_color"))))
	(if (= bkg-type 4) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)
	(set! gradient-type-blend
			(cond 
				(( equal? gradient-type-in 0 ) GRADIENT-SHAPEBURST-ANGULAR)
				(( equal? gradient-type-in 1 ) GRADIENT-SHAPEBURST-SPHERICAL)
				(( equal? gradient-type-in 2 ) GRADIENT-SHAPEBURST-DIMPLED)))
	(set! gradient-type-name
			(cond 
				(( equal? gradient-type-in 0 ) "GRADIENT-SHAPEBURST-ANGULAR")
				(( equal? gradient-type-in 1 ) "GRADIENT-SHAPEBURST-SPHERICAL")
				(( equal? gradient-type-in 2 ) "GRADIENT-SHAPEBURST-DIMPLED")))			
	(gimp-edit-blend bkg-layer CUSTOM-MODE NORMAL-MODE gradient-type-blend 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
	(gimp-drawable-set-name bkg-layer (string-append gradient "_" gradient-type-name))))
;;;;create the random gradients
	(if (= bkg-type 5)
    (begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)
	(set! random_gradient (list-ref (cadr (gimp-gradients-get-list "")) (round (random (car (gimp-gradients-get-list ""))))))
    (set! gradient-type (+ 6 (random 3)))
	(gimp-context-set-gradient random_gradient)
	(gimp-edit-blend bkg-layer CUSTOM-MODE NORMAL-MODE gradient-type 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
	
	(set! gradient-type-name
			(cond 
				(( equal? gradient-type 6 ) "GRADIENT-SHAPEBURST-ANGULAR")
				(( equal? gradient-type 7 ) "GRADIENT-SHAPEBURST-SPHERICAL")
				(( equal? gradient-type 8 ) "GRADIENT-SHAPEBURST-DIMPLED")))
				
	(set! name-string (string-append (car (gimp-drawable-get-name bkg-layer)) "- Gradient " random_gradient "- Shape " gradient-type-name))
	(gimp-drawable-set-name bkg-layer name-string)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))))
    
 ;;;;add the lomo to bkg
    (if (and (= lomo TRUE)  (> bkg-type 0))
	(begin
	(if (= bkg-type 6) 
    (begin 
	(gimp-context-set-background '(255 255 255))
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)))
	(gimp-selection-load img-channel)
	(gimp-image-set-active-layer image bkg-layer)
	(the-metal-text-lomo image (car (gimp-image-get-active-layer image)) lomo-size opacity FALSE TRUE)	
	(set! lomo-layer (car (gimp-image-get-active-layer image)))
	(if (and (< bkg-type 6)  (> bkg-type 0)) (plug-in-colortoalpha 1 image lomo-layer '(255 255 255)))
	(if (= bkg-type 6) 
	(begin
	(set! bkg-layer (car (gimp-image-merge-down image lomo-layer EXPAND-AS-NECESSARY)))
	(plug-in-colortoalpha 1 image bkg-layer '(255 255 255))))
	))
	(gimp-image-resize-to-layers image)
    (if (= conserve FALSE) 
    (begin 
	(set! metal-text-layer (car (gimp-image-merge-visible-layers image 0)))	
	(gimp-drawable-set-name metal-text-layer text)
	(if (= 3d-effect TRUE) (gimp-drawable-set-name metal-text-layer (string-append text "-3D")))
    (if (= bkg-type 5)
	(begin
	(set! name-string (string-append (car (gimp-drawable-get-name metal-text-layer)) "- Gradient " random_gradient "- Shape " gradient-type-name))	
	(gimp-drawable-set-name metal-text-layer name-string)))))
	(gimp-image-remove-channel image img-channel)
	
	(gimp-context-pop)
	(gimp-display-new image)    
    (gimp-displays-flush)
    
    )
  )
  
(script-fu-register "script-fu-metal-text"
  "Metal Text"
  "Rel6-Create a Metalic Text over a Background layer."
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Oct 2012"
  ""
  SF-TEXT       "Text"    "Metal\nText"
  SF-OPTION "Justify" '("Centered" "Left" "Right")
  SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -500 500 1 10 0 0)
  SF-FONT       "Font"               "JasmineUPC Bold"
  SF-ADJUSTMENT "Font size (pixels)" '(350 6 500 1 1 0 1)
  SF-OPTION "Metal Finish Type" '("Chrome" "Gold" "Silver" "Copper" "Bronze" "Colored Tint")
  SF-OPTION "Metal Finish polish" '("Maximum" "Medium" "Soft")
  SF-ADJUSTMENT "Brightness" '(50 0 100 1 10 0 0)
  SF-COLOR      "Tint Color"         '(0 0 255)
  SF-TOGGLE     "Add a 3D Effect"   TRUE
  SF-ADJUSTMENT "3D Height (pixels)" '(30 1 100 1 10 0 0)
  SF-OPTION "Background Type" '("Starlight" "Grunge" "Pattern" "Color" "Gradient" "Random Gradient" "None")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background and Grunge color"        '(207 194 162)
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-OPTION "Gradient Shape if Bkg-type=gradient" '("GRADIENT-SHAPEBURST-ANGULAR" "GRADIENT-SHAPEBURST-SPHERICAL" "GRADIENT-SHAPEBURST-DIMPLED")
  SF-TOGGLE     "Add Lomo to Background"   FALSE
  SF-ADJUSTMENT "Lomo Size" '(0 0 200 1 10 0 0)
  SF-ADJUSTMENT "Lomo Opacity" '(80 0 100 1 10 0 0)
  SF-TOGGLE     "Keep the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-metal-text"
  "<Image>/Script-Fu/Logos/"
  )

(define (the-metal-text-shine image drawable
                              shadow-size
							  shadow-opacity
							  conserve)							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-width image)))
			(height (car (gimp-image-height image)))
			(sel (car (gimp-selection-is-empty image)))
			(layer-name (car (gimp-drawable-get-name image-layer)))
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
	
	(gimp-layer-add-alpha image-layer)
    (if (= sel TRUE) (gimp-selection-layer-alpha image-layer))
	(set! img-layer (car (gimp-layer-new image width height RGBA-IMAGE "img-layer" 100 NORMAL-MODE)))
	(gimp-image-add-layer image img-layer -1)
	(gimp-drawable-fill img-layer  BACKGROUND-FILL)
	(gimp-edit-fill img-layer FOREGROUND-FILL)
	
;;;;create channel
	(gimp-selection-save image)
	(set! img-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity img-channel 100)	
	(gimp-drawable-set-name img-channel "img-channel")
	(gimp-image-set-active-layer image img-layer)	
	(gimp-drawable-set-name image-layer "Original Image")
	
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 NORMAL-MODE)))
    (gimp-image-add-layer image bkg-layer 1)		

;;;;apply the image effects
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image img-layer 12 12)
	(plug-in-emboss RUN-NONINTERACTIVE image img-layer 225 84 10 TRUE)	
	(gimp-selection-invert image)
	(gimp-edit-clear img-layer)
	(gimp-selection-invert image)
	(plug-in-colortoalpha RUN-NONINTERACTIVE image img-layer '(254 254 254));;fefefe
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image img-channel 15 15)
	(plug-in-blur RUN-NONINTERACTIVE image img-layer)
	(gimp-image-set-active-layer image bkg-layer)
	(plug-in-displace RUN-NONINTERACTIVE image bkg-layer 8 8 TRUE TRUE img-channel img-channel 1)
	(gimp-image-remove-layer image bkg-layer)
	
;;;;create the shadow
(if (> shadow-size 0)
  (begin
    (script-fu-drop-shadow image img-layer shadow-size shadow-size shadow-size '(0 0 0) shadow-opacity FALSE)
    (set! tmp-layer (car (gimp-layer-new image width height RGBA-IMAGE "temp" 100 NORMAL-MODE)))
    (gimp-image-add-layer image tmp-layer -1)
	(gimp-image-raise-layer image tmp-layer)
    (gimp-image-merge-down image tmp-layer CLIP-TO-IMAGE)
	(set! shadow-layer (car (gimp-image-get-active-drawable image)))
	(gimp-image-lower-layer image shadow-layer)
	
   )
 )	

 (if (= conserve FALSE)
    (begin
	(set! img-layer (car (gimp-image-merge-down image img-layer CLIP-TO-IMAGE)))
	(set! img-layer (car (gimp-image-merge-down image img-layer CLIP-TO-IMAGE)))
	(gimp-drawable-set-name img-layer layer-name)
	)
	)
	
	(gimp-image-remove-channel image img-channel)
	(gimp-selection-none image)
	
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
    (gimp-displays-flush)

 )
)

 (define (the-background-light&waves image drawable 
                                      beam-height-in
									  blur
									  gradient
									  reverse
									  cnt-in
									  conserve
									  )
  (let* (         
         (offx 0)
         (offy 0)
         (bkg-layer (car (gimp-image-get-active-layer image)))
		 (type (car (gimp-drawable-type-with-alpha drawable)))
		 (width (car (gimp-image-width image)))
		 (height (car (gimp-image-height image)))                  
         (beam-layer (car (gimp-layer-new image width beam-height-in RGBA-IMAGE "Beam" 100 NORMAL-MODE)))         
		 (beam-width (car (gimp-drawable-width beam-layer)))
         (beam-height (car (gimp-drawable-height beam-layer)))
		 (beam-copy 0)
		 (beam-copy1 0)
		 (color-layer 0)
		 (beam-channel 0)
		 (selection-bounds 0)
		 (dust-top 0)
		 (top-height 0)
		 (dust-bot 0)
		 (bot-height 0)
		 (cnt (/ cnt-in 2))
		 (x 0)
		 (y 0)
		 (*newpoint* (cons-array 2 'double))         
         )
		 
    (gimp-context-push)
	(gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))	
    
	(gimp-image-add-layer image beam-layer -1)

	;;;;centre the beam layer	
    (set! offx (/ (- width beam-width) 2))
    (set! offy (/ (- height beam-height) 2))    
    (gimp-layer-set-offsets beam-layer offx offy)
	
;;;;set the bkg clolor    
    (gimp-edit-fill bkg-layer FOREGROUND-FILL)
		
;;;;set the beam clolor    
 	(gimp-edit-fill beam-layer BACKGROUND-FILL)
	(gimp-layer-resize-to-image-size beam-layer)
	
	(set! beam-copy (car (gimp-layer-copy beam-layer TRUE)))
	(gimp-image-add-layer image beam-copy 1)
	(gimp-drawable-set-name beam-copy "Beam-copy")
	
	(set! beam-copy1 (car (gimp-layer-copy beam-layer TRUE)))
	(gimp-image-add-layer image beam-copy1 1)
	(gimp-drawable-set-name beam-copy1 "Beam-copy#1")
	
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image beam-copy (* blur 5) (* blur 5))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image beam-copy1 (* blur 15) (* blur 15))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image beam-layer blur blur)	

    (gimp-selection-layer-alpha beam-layer)
;;;;save the selection    
	(gimp-selection-save image)
	(set! beam-channel (car (gimp-image-get-active-drawable image)));set variable (beam-channel 0)	
	(gimp-channel-set-opacity beam-channel 100)	
	(gimp-drawable-set-name beam-channel "Beam-channel")
	(set! selection-bounds (cdr (gimp-selection-bounds image)))
	(gimp-selection-none image)
    
;;;;create the beam color    
	(set! color-layer (car (gimp-layer-new image width height RGBA-IMAGE "Color" 100 MULTIPLY-MODE)))
	(gimp-image-set-active-layer image beam-layer)
    (gimp-image-add-layer image color-layer -1)
	(gimp-context-set-gradient gradient)
	(gimp-edit-blend color-layer CUSTOM-MODE NORMAL-MODE  GRADIENT-LINEAR 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE 0 (/ height 2) (* width 2) (/ height 2))
	
;;;;create the Dust-layers    
	(set! dust-top (car (gimp-layer-new image width (cadr selection-bounds) RGBA-IMAGE "Dust-Top" 100 NORMAL-MODE)))
	(gimp-image-add-layer image dust-top -1)
	(set! top-height (car (gimp-drawable-height dust-top)))
	
	(set! dust-bot (car (gimp-layer-new image width (- height (cadddr selection-bounds)) RGBA-IMAGE "Dust-Bot" 100 NORMAL-MODE)))
	(gimp-image-add-layer image dust-bot 1)
	(set! bot-height (car (gimp-drawable-height dust-bot)))
	(gimp-layer-set-offsets dust-bot 0 (cadddr selection-bounds))
	
	(gimp-context-set-brush "Sparks")
	(gimp-context-set-brush-default-size)
	(while (> cnt 0)
	(set! x (round (random width)))
	(set! y (round (random top-height)))
	(aset *newpoint* 0 x)   ; set the paint array
	(aset *newpoint* 1 y)	
	(gimp-paintbrush-default dust-top 2 *newpoint*)
	
	(set! x (round (random width)))
	(set! y (round (random bot-height)))
	(aset *newpoint* 0 x)   ; set the paint array
	(aset *newpoint* 1 y)
	(gimp-paintbrush-default dust-bot 2 *newpoint*)
	(set! cnt (- cnt 1))
	)
	(gimp-layer-resize-to-image-size dust-top)
	(gimp-layer-resize-to-image-size dust-bot)	
	(if (= conserve FALSE) (gimp-image-remove-channel image beam-channel))
	
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

    )
  )

(define (the-metal-text-grunge-bkg image drawable
                               grunge-color
							   opacity
							   keep-selection-in
							   conserve)							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-width image)))
			(height (car (gimp-image-height image)))
			(alpha (car (gimp-drawable-has-alpha image-layer)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (car (gimp-drawable-get-name image-layer)))
		    (keep-selection keep-selection-in)
			(selection-channel 0)
			(paper-layer 0)
			(mottle-layer 0)
			(bump-layer 0)
			(nominal-burn-size 30)
			(burn-size 0)
        )
	
	(set! burn-size (/ (* nominal-burn-size (max width height 1))))
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

    (if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (gimp-selection-all image)) 
	
;;;;create selection-channel
    (gimp-selection-save image)
	(set! selection-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity selection-channel 100)	
	(gimp-drawable-set-name selection-channel "selection-channel")
    (gimp-image-set-active-layer image image-layer)	
	(gimp-selection-none image)		
	
	(set! paper-layer (car (gimp-layer-new image width height RGBA-IMAGE "Paper Layer" 100 NORMAL-MODE)))
	(gimp-image-add-layer image paper-layer 1)
	(gimp-context-set-background grunge-color)
    (gimp-edit-fill paper-layer BACKGROUND-FILL)
	(plug-in-apply-canvas RUN-NONINTERACTIVE image paper-layer 0 1)
	(set! mottle-layer (car (gimp-layer-new image width height RGBA-IMAGE "Mottle Layer" opacity 21)))
	(gimp-image-add-layer image mottle-layer 1)
    (plug-in-solid-noise RUN-NONINTERACTIVE image mottle-layer 0 0 (rand 65536) 1 2 2)
    (set! paper-layer (car (gimp-image-merge-down image mottle-layer CLIP-TO-IMAGE)))
	(plug-in-spread 1 image paper-layer 5 5)
		
	(set! bump-layer (car (gimp-layer-new image width height RGBA-IMAGE "bump-layer" 100  GRAIN-EXTRACT-MODE)))
	(gimp-image-add-layer image bump-layer 1)
	(gimp-context-set-pattern "Slate")
	(gimp-drawable-fill bump-layer PATTERN-FILL)
	(plug-in-bump-map 1 image paper-layer bump-layer 135 45 3 0 0 0 0 TRUE FALSE 0)
	(gimp-image-remove-layer image bump-layer)
	
	(gimp-selection-load selection-channel)
	(gimp-selection-shrink image 10)
	(script-fu-distress-selection image 
	                              paper-layer 
								  127       ;Threshold (bigger 1<-->255 smaller)
								  8         ;Spread (8 0 1000 1 10 0 1)
								  4         ;Granularity (1 is low) (4 1 25 1 10 0 1)
								  2         ;Smooth (2 1 150 1 10 0 1)
								  TRUE      ;Smooth horizontally TRUE
								  TRUE)     ;Smooth vertically TRUE
	(gimp-selection-invert image)
	(gimp-edit-clear paper-layer)
	(gimp-edit-clear image-layer)
	(gimp-selection-none image)
	(gimp-brightness-contrast image-layer 0 30)
	
;;;;finish the script	
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	(if (= conserve FALSE) (set! image-layer (car (gimp-image-merge-down image image-layer EXPAND-AS-NECESSARY))))
    (gimp-drawable-set-name image-layer layer-name)
    (if (= keep-selection FALSE) (gimp-selection-none image))
	(gimp-image-remove-channel image selection-channel)
	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten image-layer))) 	
    
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(define (the-metal-text-lomo image drawable
                               lomo-size
							   opacity
							   keep-selection
							   conserve)							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-width image)))
			(height (car (gimp-image-height image)))
			(alpha (car (gimp-drawable-has-alpha image-layer)))
			(layer-name (car (gimp-drawable-get-name image-layer)))
			(name-string (string-append (car (gimp-drawable-get-name image-layer)) "-Vignette"))
			(sel (car (gimp-selection-is-empty image)))
			(original-selection-channel 0)			
			(vignette-layer 0)
			(copy-layer 0)
            (vig-x width)
            (vig-y height)
            (feather 120)
            			
        )
		


	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
		
	
;;;;save the original selection
    (if (= sel FALSE)
    (begin    
	(gimp-selection-save image)
	(set! original-selection-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity original-selection-channel 100)	
	(gimp-drawable-set-name original-selection-channel "Original selection")
	(gimp-selection-none image)
	(gimp-image-set-active-layer image image-layer)))

;;;;apply the vignette
    (if (> width 640) (set! vig-x 640))
	(if (> height 520) (set! vig-y 520))
	(if (< width 640) (set! feather (/ width 5.33)))
	(if (< height 520) (set! feather (/ height 4.33)))
	(set! vignette-layer (car (gimp-layer-new image vig-x vig-y  RGBA-IMAGE "Vignette" 100 HARDLIGHT-MODE )))
	(gimp-image-add-layer image vignette-layer -1)
	(gimp-ellipse-select image 0 0 vig-x vig-y 0 TRUE FALSE 10)
	(gimp-selection-shrink image lomo-size)
	(gimp-selection-feather image feather)
	(gimp-selection-invert image)	
	(gimp-image-set-active-layer image vignette-layer)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	;(gimp-image-resize image vig-x vig-y 0 0)
    ;(gimp-edit-blend vignette-layer FG-BG-RGB-MODE NORMAL-MODE GRADIENT-RADIAL 100 0 REPEAT-NONE TRUE FALSE 3 0.2 TRUE (/ vig-x 2) (/ vig-y 2) vig-x vig-y)		
	;(gimp-context-set-gradient "FG to Transparent")
	(gimp-context-set-gradient-fg-transparent)
	(gimp-edit-blend vignette-layer CUSTOM-MODE NORMAL-MODE   GRADIENT-RADIAL 100 0 REPEAT-NONE TRUE FALSE 3 0.2 TRUE (/ vig-x 2) (/ vig-y 2) vig-x vig-y)
	(gimp-selection-none image)
	(gimp-layer-scale vignette-layer width height FALSE)	
	(set! copy-layer (car (gimp-layer-copy vignette-layer TRUE)))
    (gimp-image-add-layer image copy-layer -1)
	(set! vignette-layer (car (gimp-image-merge-down image copy-layer EXPAND-AS-NECESSARY)))
	(gimp-drawable-set-name vignette-layer "Vignette")
	(gimp-layer-set-opacity vignette-layer opacity)
	
 (if (= conserve FALSE)	
    (begin
	(set! vignette-layer (car (gimp-image-merge-down image vignette-layer EXPAND-AS-NECESSARY)))
	(gimp-drawable-set-name vignette-layer name-string)))	
	;(gimp-drawable-set-name image-layer layer-name)
	(if (and (= conserve FALSE) (= alpha FALSE)) (gimp-layer-flatten vignette-layer))
    (if (and (= keep-selection TRUE) (= sel FALSE)) (gimp-selection-load original-selection-channel))
	(if (= sel FALSE)(gimp-image-remove-channel image original-selection-channel))
	
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
 )
)  