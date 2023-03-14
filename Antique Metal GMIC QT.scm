;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Antique Metal rel 0.03
; Created by Graechan
; You will need to install GMIC to run this Scipt
; GMIC can be downloaded from http://sourceforge.net/projects/gmic/files/
;    Thanks to Draconian for his Antique-metal tutorial
;    that I followed to write this script. 
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
; Rel 0.02 - Added text options Justify, Letter Spacing, Line Spacing and option controls for 'Drop Shadow' 'Grunge' 'Vignette' 'Frame'
; Rel 0.03 - Bugfix for typo in script
; 

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))

(define (script-fu-antique-metal-gmic-qt-logo 
                                      text
									  justify
									  letter-spacing
									  line-spacing
                                      font-in 
                                      font-size
									  grow
									  ds-apply
									  ds-offset							         
							          ds-blur
									  opacity
									  bev-width
							          depth
									  metal
									  apply-grunge
									  grunge-color
							          grunge-opacity
									  apply-vignette
									  apply-frame
									  vig-size
									  frame-in
									  conserve)
									  
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))
         (border (/ font-size 4))
		 (font (if (> (string-length font-in) 0) font-in (car (gimp-context-get-font))))
         (text-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
		 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))
         (width (car (gimp-drawable-get-width text-layer)))
         (height (car (gimp-drawable-get-height text-layer)))
         (text-channel 0)
         (bkg-layer 0)		 
		 (inner-shadow 0)
		 (inner-glow 0)
		 (inner-shadow-mask 0)
		 (inner-glow-mask 0)
		 (overlay-mode 0)
		 (add-shadow TRUE)
		 (add-canvas TRUE)
		 (add-mottling TRUE)
		 (nominal-burn-size 30)
		 (inner-bevel-layer 0)
		 (azimuth 135)
		 (elevation 35)
		 (postblur 3.0)
		 (texture-layer 0)
		 (red (car grunge-color))	
         (green (cadr grunge-color))
		 (blue (caddr grunge-color))
		 (frame-layer 0)
		 (frame frame-in)         
         )
		 
    (gimp-context-push)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
;;;;adjust text 
	(gimp-text-layer-set-justification text-layer justify)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
	
    (gimp-image-resize-to-layers image)

;;;;set the text clolor    
    (gimp-context-set-foreground '(0 0 0))
	(gimp-image-select-item image 2 text-layer)
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
	
;;;;Expand the font if needed
    (if (> grow 0)
           (begin
    (gimp-image-select-item image 2 text-layer)
    (gimp-drawable-edit-clear text-layer)
    (gimp-selection-grow image grow)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill text-layer FILL-FOREGROUND)))
    (gimp-selection-none image)
	(gimp-display-new image)
	(gimp-image-undo-group-start image)
	(script-fu-antique-metal-gmic-qt-alpha image 
	                               text-layer metal 
								   ds-apply 
								   ds-offset 
								   ds-blur 
								   opacity 
								   bev-width 
								   depth 
								   apply-grunge 
								   grunge-color 
								   grunge-opacity
								   apply-vignette
								   apply-frame
								   vig-size 
								   frame 
								   FALSE 
								   conserve)
    (gimp-image-undo-group-end image)	
    (gimp-context-pop)
	
    )
  )
  
(script-fu-register "script-fu-antique-metal-gmic-qt-logo"
  "Antique Metal GMIC QT Logo"
  "Antque metal logo with optional metal types"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Aug 2012"
  ""
  SF-TEXT       "Text"    "Antique\nMetal QT"
  SF-OPTION "Justify" '("Centered" "Left" "Right") 
  SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-FONT       "Font"               "JasmineUPC Bold"
  SF-ADJUSTMENT "Font size (pixels)" '(350 100 1000 1 10 0 1)
  SF-ADJUSTMENT "Expand the Font if needed" '(0 0 10 1 1 0 1)
  SF-TOGGLE     "Apply Drop Shadow"   TRUE
  SF-ADJUSTMENT "Drop shadow offset"    '(10 0 100 1 10 0 1)  
  SF-ADJUSTMENT "Drop shadow blur radius" '(30 0 255 1 10 0 1)
  SF-ADJUSTMENT "Inner Shadow and Glow Opacity" '(70 0 100 1 10 0 0)
  SF-ADJUSTMENT "Bevel Width" '(10 1 100 1 10 0 0)
  SF-ADJUSTMENT "Bevel Depth" '(3 1 60 1 10 0 0)
  SF-OPTION "Metal Finish Type" '("Iron" "Gold" "Silver" "Copper" "Bronze" "Brass")
  SF-TOGGLE     "Apply Grunge background"   TRUE
  SF-COLOR      "Background Grunge Color"         '(153 153 184)
  SF-ADJUSTMENT "Background Grunge Darkness" '(70 0 100 1 10 0 0)
  SF-TOGGLE     "Apply Vignette"   TRUE
  SF-TOGGLE     "Apply Frame"   TRUE
  SF-ADJUSTMENT "Background Vignette Size" '(5 0 50 1 5 0 0)  
  SF-ADJUSTMENT "Frame Size" '(5 0 10 .1 5 1 0)
  SF-TOGGLE     "Keep the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-antique-metal-gmic-qt-logo" "<Image>/Script-Fu/Logos")
  
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (script-fu-antique-metal-gmic-qt-alpha image drawable
                                      metal
									  ds-apply
									  ds-offset
							          ds-blur
									  opacity
									  bev-width
							          depth
									  apply-grunge
									  grunge-color
							          grunge-opacity
									  apply-vignette
									  apply-frame
									  vig-size
									  frame-in
									  keep-selection-in
									  conserve)							  

 (let* (
         (image-layer (car (gimp-image-get-active-layer image)))
		 (width (car (gimp-image-width image)))
		 (height (car (gimp-image-height image)))
		 (alpha (car (gimp-drawable-has-alpha image-layer)))
		 (sel (car (gimp-selection-is-empty image)))
		 (layer-name (car (gimp-item-get-name image-layer)))
		 (keep-selection keep-selection-in)
		 (text "Antique Metal")
		 (selection-channel 0)
         (bkg-layer 0)
		 (inner-shadow 0)
		 (inner-glow 0)
		 (inner-shadow-mask 0)
		 (inner-glow-mask 0)
		 (overlay-mode 0)
		 (add-shadow TRUE)
		 (add-canvas TRUE)
		 (add-mottling TRUE)
		 (nominal-burn-size 30)
		 (inner-bevel-layer 0)
		 (azimuth 135)
		 (elevation 35)
		 (postblur 3.0)
		 (texture-layer 0)
		 (red (car grunge-color))	
         (green (cadr grunge-color))
		 (blue (caddr grunge-color))
		 (frame-layer 0)
		 (frame frame-in)
		 (offset-x 0)
		 (offset-y 0)
		 (offsets 0)
		 (metal-layer 0)
        )	
	
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (gimp-image-select-item image 2 image-layer))

	(gimp-selection-invert image)
	(gimp-drawable-edit-clear image-layer)
	(gimp-selection-invert image)

;;;;create selection-channel
    (gimp-selection-save image)
	(set! selection-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity selection-channel 100)	
	(gimp-item-set-name selection-channel "selection-channel")
    (gimp-image-set-active-layer image image-layer)	
	(gimp-selection-none image)
	
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 1)
	    	
	(if (= apply-grunge TRUE) 
	(begin
	(the-antique-metal-background image bkg-layer grunge-color grunge-opacity)	
	(set! bkg-layer (car (gimp-image-get-active-layer image)))                                              
	(set! bkg-layer (car (gimp-image-merge-down image bkg-layer EXPAND-AS-NECESSARY)))
	(gimp-item-set-name bkg-layer "Background")))
			
;;;;fill image with grey	
	(gimp-image-select-item image 2 selection-channel)
	(gimp-context-set-foreground '(123 123 123))
	(gimp-drawable-edit-fill image-layer FILL-FOREGROUND)
	(set! width (car (gimp-image-width image)))
	(set! height (car (gimp-image-height image)))
	(gimp-selection-none image)
	(gimp-layer-resize-to-image-size bkg-layer)
	(gimp-layer-resize-to-image-size image-layer)
			
;;;;create inner-shadow and inner-glow layers    
	(set! inner-shadow (car (gimp-layer-copy image-layer TRUE)))
	(gimp-image-insert-layer image inner-shadow 0 -1)
	(gimp-item-set-name inner-shadow "Inner shadow")
	(gimp-layer-set-mode inner-shadow LAYER-MODE-MULTIPLY-LEGACY)
	(gimp-layer-set-opacity inner-shadow opacity)
	
	(set! inner-glow (car (gimp-layer-copy image-layer TRUE)))
	(gimp-image-insert-layer image inner-glow 0 -1)
	(gimp-item-set-name inner-glow "Inner glow")
	(gimp-layer-set-mode inner-glow LAYER-MODE-MULTIPLY-LEGACY)
	(gimp-layer-set-opacity inner-glow opacity)

;;;;create the inner shadow
	(gimp-image-set-active-layer image inner-shadow)
    (gimp-item-set-visible inner-shadow TRUE)	
	
	(set! inner-shadow-mask (car (gimp-layer-create-mask inner-shadow  ADD-MASK-ALPHA)))
	(gimp-layer-add-mask inner-shadow inner-shadow-mask)
	(gimp-layer-set-edit-mask inner-shadow FALSE)	
	
	(gimp-image-select-item image 2 selection-channel)
	(gimp-selection-shrink image (* bev-width 1.5))
	(gimp-selection-invert image)
	(gimp-context-set-foreground '(99 78 56))
(gimp-context-set-opacity opacity)
(gimp-drawable-edit-bucket-fill inner-shadow  FILL-FOREGROUND  0 0)
(gimp-selection-none image)
	(plug-in-gauss-rle RUN-NONINTERACTIVE image inner-shadow (* bev-width 3) TRUE TRUE)

;;;;create the inner glow
	(gimp-image-set-active-layer image inner-glow)
    (gimp-item-set-visible inner-glow TRUE)
	(gimp-image-select-item image 2 selection-channel)
	(gimp-drawable-edit-clear inner-glow)
	
	(set! inner-glow-mask (car (gimp-layer-create-mask inner-glow ADD-MASK-SELECTION)))
	(gimp-layer-add-mask inner-glow inner-glow-mask)
	(gimp-layer-set-edit-mask inner-glow FALSE)
	
	(gimp-selection-shrink image bev-width)
	(gimp-selection-invert image)
	(gimp-context-set-foreground '(120 100 80))
(gimp-context-set-opacity opacity)
(gimp-drawable-edit-bucket-fill inner-glow FILL-FOREGROUND  0 0)
(gimp-selection-none image)
	(plug-in-gauss-rle RUN-NONINTERACTIVE image inner-glow (* bev-width 2) TRUE TRUE)
    (gimp-image-raise-item-to-top image bkg-layer)
    (set! image-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
	(if (= apply-grunge FALSE) (begin
	(gimp-image-select-item image 2 selection-channel)
	(gimp-selection-translate image -3 -2)
    (gimp-selection-invert image)
	(gimp-drawable-edit-clear image-layer)
	(gimp-selection-none image)))
	(gimp-item-set-name image-layer text)

;;;;Add new layer with Bevel
    (gimp-image-select-item image 2 selection-channel)
    (set! inner-bevel-layer (car (gimp-layer-new image width height RGBA-IMAGE "Inner bevel" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image inner-bevel-layer 0 -1)
    (gimp-image-set-active-layer image inner-bevel-layer)    
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(255 255 255))
	(gimp-drawable-edit-fill inner-bevel-layer FILL-FOREGROUND)    
    (gimp-selection-shrink image 1)
    (gimp-selection-feather image bev-width)
    (gimp-selection-shrink image (- (/ bev-width 2) 1))
    (gimp-drawable-edit-fill inner-bevel-layer FILL-BACKGROUND)
    (gimp-selection-all image)
    (if (= ds-apply TRUE) (gimp-drawable-invert inner-bevel-layer TRUE))
    (plug-in-emboss RUN-NONINTERACTIVE image inner-bevel-layer azimuth elevation depth 1);Emboss

;;;;gloss the bevel-layer    
     (gimp-drawable-curves-spline inner-bevel-layer 0 18 #(0 0 0.12549 0.619608 0.243137 0.117647 0.376471 0.87451 0.494118 0.376471 0.623529 1 0.741176 0.627451 0.870588 1 1 1
))  
     (plug-in-gauss-rle RUN-NONINTERACTIVE image inner-bevel-layer postblur 1 1)
	 
;;;;Clean up the layers
    
	(gimp-image-select-item image 2 selection-channel)
    (gimp-selection-invert image)
	(gimp-drawable-edit-clear inner-bevel-layer)
	
;;;;create the texture-layer
    (set! texture-layer (car (gimp-layer-new image width height RGBA-IMAGE "Texture" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image texture-layer 0 -1)
    (gimp-image-select-item image 2 selection-channel)
	(gimp-context-set-foreground '(123 123 123))
	(gimp-drawable-edit-fill texture-layer FILL-FOREGROUND)


;;;QUI!!!
;;;; Render Whirl drawing using G'MIC.
				(plug-in-gmic-qt 1 image texture-layer 1 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"-fx_draw_whirl 78.4"))

	(plug-in-mblur 1 image texture-layer 0 4 90 (/ width 2) (/ height 2))
	(gimp-drawable-curves-spline texture-layer 0 18 #(0 1 0.121569 0 0.243137 1 0.356863 0 0.498039 1 0.623529 0 0.745098 1 0.87451 0 1 1))
	(plug-in-unsharp-mask 1 image texture-layer 10 1 0)
    (gimp-selection-none image)
	;(gimp-image-remove-channel image selection-channel)
	(plug-in-bump-map 1 image inner-bevel-layer texture-layer 135 45 5 0 0 0 0 TRUE FALSE 2)
	(gimp-image-remove-layer image texture-layer)
	(gimp-drawable-color-balance inner-bevel-layer 0 TRUE 40 0 0);shadows
	(gimp-image-select-item image 2 selection-channel)
	(gimp-selection-translate image -3 -2)
    (gimp-selection-invert image)
	(gimp-drawable-edit-clear inner-bevel-layer)
	(gimp-selection-none image)
	(if (= ds-apply TRUE) (script-fu-drop-shadow  image inner-bevel-layer ds-offset ds-offset 30 '(0 0 0) 100 FALSE))
    (set! image-layer (car (gimp-image-merge-visible-layers image 1)))
	(gimp-item-set-name image-layer text)
	
	(script-fu-addborder image image-layer 1 1 grunge-color 0)
	(set! image-layer (car (gimp-image-merge-visible-layers image 1)))
	(gimp-item-set-name image-layer text)
	
;;;;set the different metal types
	(set! metal-layer (car (gimp-layer-new image width height RGBA-IMAGE "Plating" 80 COLOR-MODE)))
    (gimp-image-insert-layer image metal-layer 0 -1)
	(gimp-image-select-item image 2 selection-channel)
	(if (= metal 1) (gimp-context-set-foreground '(253 208 23)));gold
	(if (= metal 2) (begin
	(gimp-layer-set-mode metal-layer 21)
	(gimp-context-set-foreground '(192 192 192))));silver
	(if (= metal 3) (gimp-context-set-foreground '(184 115 51)));copper
    (if (= metal 4) (gimp-context-set-foreground '(140 120 83)));bronze
	(if (= metal 5) (gimp-context-set-foreground '(181 166 66)));brass
	(if (> metal 0) (gimp-drawable-edit-fill metal-layer FILL-FOREGROUND))
	(set! image-layer (car (gimp-image-merge-down image metal-layer EXPAND-AS-NECESSARY)))
	(if (> metal 0) (the-antique-metal-shine image image-layer 8 50 TRUE FALSE))
	(set! image-layer (car (gimp-image-get-active-layer image)))
    (gimp-selection-none image)	
	
	(if (= apply-vignette FALSE) (set! vig-size 0))
	(if (= apply-frame FALSE) (set! frame 0))
	(if (and (> vig-size 0) (= frame 0)) (set! frame 0.1))
	(if (> frame 0)
	(begin


;;;;QUI!!!
;;;; Render Picture Frame using G'MIC.
				(plug-in-gmic-qt 1 image image-layer 1 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"-fx_frame_painting "
						(number->string frame) ",0.4,1.5,"
						(number->string red) ","
						(number->string green) ","
						(number->string blue) ","
						(number->string vig-size) ",400,100,70.6161,6.25592,0.5,123456,1"))
    
	(set! image-layer (car (gimp-image-get-active-layer image)))
	(gimp-item-set-name image-layer text)
	
	(set! frame-layer (car (gimp-layer-new image width height RGBA-IMAGE "Frame" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image frame-layer 0 -1)
	(gimp-image-raise-item image frame-layer)
	(set! frame-layer (car (gimp-image-merge-down image frame-layer EXPAND-AS-NECESSARY)))
	)
	)
	
	(if (and (> vig-size 0) (= apply-frame FALSE)) (gimp-item-set-name frame-layer "Vignette"))
    (if (= apply-frame TRUE) (gimp-item-set-name frame-layer "Frame"))
	(if (and (> vig-size 0) (= apply-frame TRUE)) (gimp-item-set-name frame-layer "Frame with Vignette"))
;	(if (= frame-in 0) (plug-in-autocrop 1 image image-layer))
	
	(gimp-image-set-active-layer image image-layer)
	(plug-in-autocrop-layer 1 image image-layer)
	(set! offset-x (car (gimp-drawable-get-offsets image-layer)))
	(set! offset-y (cadr (gimp-drawable-get-offsets image-layer)))
	(gimp-drawable-offset selection-channel TRUE 0 offset-x offset-y)
		
;;;;scale image to its original size and re-load selection
	(gimp-image-scale image width height)
	(gimp-image-select-item image 2 selection-channel)


;	(if (or (> vig-size 0) (> frame-in 0)) (gimp-image-lower-item image image-layer))

;;;;finish the script	
	(if (= conserve FALSE) 
	(begin
	(if (or (> vig-size 0) (= apply-frame TRUE)) (set! image-layer (car (gimp-image-merge-down image frame-layer EXPAND-AS-NECESSARY))))))
    (gimp-item-set-name image-layer text)
    (if (= keep-selection FALSE) (gimp-selection-none image))
	(if (= conserve FALSE) (gimp-image-remove-channel image selection-channel))
	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten image-layer)))
	
    (gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
	
 )
)
    
(script-fu-register "script-fu-antique-metal-gmic-qt-alpha"        		    
  "Antique Metal GMIC QT Alpha"
  "create antique metal finish on a alpha image"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Aug 2012"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-OPTION "Metal Finish Type" '("Iron" "Gold" "Silver" "Copper" "Bronze" "Brass")
  SF-TOGGLE     "Apply Drop Shadow"   TRUE
  SF-ADJUSTMENT "Drop shadow offset"    '(10 0 100 1 10 0 1)
  SF-ADJUSTMENT "Drop shadow blur radius" '(30 0 255 1 10 0 1)
  SF-ADJUSTMENT "Inner Shadow and Glow Opacity" '(70 0 100 1 10 0 0)
  SF-ADJUSTMENT "Bevel Width" '(10 1 100 1 10 0 0)
  SF-ADJUSTMENT "Bevel Depth" '(3 1 60 1 10 0 0)
  SF-TOGGLE     "Apply Grunge background"   TRUE
  SF-COLOR      "Background Grunge Color"         '(153 153 184)
  SF-ADJUSTMENT "Background Grunge Darkness" '(70 0 100 1 10 0 0)
  SF-TOGGLE     "Apply Vignette"   TRUE
  SF-TOGGLE     "Apply Frame"   TRUE
  SF-ADJUSTMENT "Background Vignette Size" '(5 0 50 1 5 0 0)
  SF-ADJUSTMENT "Frame Size" '(5 0 10 .1 5 1 0)
  SF-TOGGLE     "Keep selection"          FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
)

(script-fu-menu-register "script-fu-antique-metal-gmic-qt-alpha" "<Image>/Script-Fu/Alpha-to-Logo") 


(define (the-antique-metal-background image drawable
                               grunge-color
							   opacity)							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-width image)))
			(height (car (gimp-image-height image)))
			(paper-layer 0)
			(mottle-layer 0)
			(nominal-burn-size 30)
			(burn-size 0)
        )
	
	(set! burn-size (/ (* nominal-burn-size (max width height 1))))
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
	(set! paper-layer (car (gimp-layer-new image width height RGBA-IMAGE "Paper Layer" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer image paper-layer 0 -1)
	(gimp-context-set-background grunge-color)
    (gimp-drawable-edit-fill paper-layer FILL-BACKGROUND)
	(plug-in-apply-canvas RUN-NONINTERACTIVE image paper-layer 0 1)
	(set! mottle-layer (car (gimp-layer-new image width height RGBA-IMAGE "Mottle Layer" opacity 21)))
	(gimp-image-insert-layer image mottle-layer 0 -1)
    (plug-in-solid-noise RUN-NONINTERACTIVE image mottle-layer 0 0 (rand 65536) 1 2 2)
	(set! paper-layer (car (gimp-image-merge-down image mottle-layer CLIP-TO-IMAGE)))
	(plug-in-spread 1 image paper-layer 5 5)
    
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(define (the-antique-metal-shine image drawable
                              shadow-size
							  shadow-opacity
							  keep-selection-in
							  conserve)
							  

 (let* (
            (image-layer (car (gimp-image-get-active-layer image)))
			(width (car (gimp-image-width image)))
			(height (car (gimp-image-height image)))
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
	(set! img-channel (car (gimp-image-get-active-drawable image)))	
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
	(plug-in-blur RUN-NONINTERACTIVE image img-layer)
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
	(set! shadow-layer (car (gimp-image-get-active-drawable image)))
	(gimp-image-lower-item image shadow-layer)
	
   )
 )	

 (if (= conserve FALSE)
    (begin
	(set! img-layer (car (gimp-image-merge-down image img-layer EXPAND-AS-NECESSARY)))
	(set! img-layer (car (gimp-image-merge-down image img-layer EXPAND-AS-NECESSARY)))
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
