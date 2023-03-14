; Air Bubbles rel 0.04
; Created by Graechan with the help of tutorials from EK22 http://www.gimpchat.com/viewtopic.php?f=23&t=7520 
; and Esper at Gimp Sciece Labs http://gimp-science-labs.blogspot.de/
; You will need to install GMIC to run this Scipt minimum rel 1-5-6-0
; GMIC can be downloaded from http://sourceforge.net/projects/gmic/files/ 
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
; Rel 0.01.1 - Bugfix to 2.6 call whch left the varible threshold undeclared
; Rel 0.02 - Added Alpha-to-logo Script
; Rel 0.02.1 - Changed Gmic call to account for improvements to the 'Pack Sprites' Filter
; Rel 0.03 - Added spacing adjustment
; Rel 0.04 - changed script to function in 2.10

(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal to centre" "Diagonal from centre"))
;
; Air Bubbles include layer Procedure
(define (air-bubbles-include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.10 
          )
          (else
           (gimp-image-add-layer image newlayer (+ (car (gimp-image-get-layer-position image oldlayer)) stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end add layer procedure

(define (script-fu-air-bubbles-stars-alpha image layer
                               bkg-type 
                               pattern
                               bkg-color
							   gradient
							   gradient-type
							   reverse
							   blendir
							   bubb-type
							   spacing
							   max-size
							   min-size
							   keep-selection-in
							   conserve
							   )
							   
	(gimp-image-undo-group-start image)						  

 (let* (
        (width (car (gimp-image-width image)))
		(height (car (gimp-image-height image)))
		(original-width width)
		(original-height height)
		(area (* 1000 1000))
		(alpha (car (gimp-drawable-has-alpha layer)))
		(sel (car (gimp-selection-is-empty image)))
		(layer-name (car (gimp-drawable-get-name layer)))
		(keep-selection keep-selection-in)
		(active-gradient (car (gimp-context-get-gradient)))
		(active-fg (car (gimp-context-get-foreground)))
		(active-bg (car (gimp-context-get-background)))
		(selection-channel 0)
		(ver 2.8)
		(mask-layer 0)
		(bubble-layer 0)
		(bubbles1-layer 0)
		(brushName    "outlineBrush")
		(*newpoint* (cons-array 2 'double))
		(bubbles-selection 0)
		(highlight 0)
		(shadow 0)
		(drop-shadow 0)
		(bkg-layer 0)
		(x1 0)
		(y1 0)
		(x2 0)
		(y2 0)
        )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
	(gimp-context-set-brush (caadr (gimp-brushes-get-list "")))
	(gimp-context-push)
    (gimp-context-set-paint-method "gimp-paintbrush")
	(if (= ver 2.8) (gimp-context-set-dynamics "Dynamics Off"))
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
	(if (= alpha FALSE) (gimp-layer-add-alpha layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (begin
	(cond ((= ver 2.8) (gimp-image-select-item image 2 layer)) 
	(else (gimp-selection-layer-alpha layer))
	) ;endcond
	)
	) ;endif
	
;;;;create selection-channel (gimp-selection-load selection-channel)
    (set! selection-channel (car (gimp-selection-save image)))	
	(gimp-item-set-name selection-channel "selection-channel")
    (gimp-image-set-active-layer image layer)	
;;;;begin the script	
;;;;create the mask-layer
    (set! mask-layer (car (gimp-layer-new image width height RGBA-IMAGE "Mask" 100 0)))
	(air-bubbles-include-layer image mask-layer layer 0)	;stack 0=above 1=below
	
	(gimp-drawable-fill mask-layer 0)
	(gimp-image-select-item image 2 selection-channel)
	(gimp-edit-clear mask-layer)
	(gimp-selection-none image)
	
;;;;create the bubble-layer	
	(set! bubble-layer (car (gimp-layer-new image width height RGBA-IMAGE "Bubble" 100 0)))
	(air-bubbles-include-layer image bubble-layer mask-layer 0)	;stack 0=above 1=below	
	
;;;; define new brush for drawing operation
(cond ((= bubb-type 0) 

            (gimp-brush-new brushName)
			(gimp-brush-set-shape brushName BRUSH-GENERATED-CIRCLE)    
            (gimp-brush-set-spikes brushName 2)
            (gimp-brush-set-hardness brushName 1.00)                   
            (gimp-brush-set-aspect-ratio brushName 1.0)
            (gimp-brush-set-angle brushName 0.0)                       
            (gimp-brush-set-spacing brushName 194.0)
            (gimp-brush-set-radius brushName max-size)            
            (gimp-context-set-brush brushName)
			(if (defined? 'gimp-context-set-brush-default-size) 
	        (gimp-context-set-brush-default-size))
            (gimp-context-set-foreground '(128 128 128))
	
	(aset *newpoint* 0 (/ width 2))   ; set the paint array
	(aset *newpoint* 1 (/ height 2))	
	(gimp-paintbrush-default bubble-layer 2 *newpoint*)
	(gimp-brush-delete brushName)	
	))
(cond ((= bubb-type 1) 

(gimp-context-set-brush "2. Star")
(if (defined? 'gimp-context-set-brush-default-size) 
	        (gimp-context-set-brush-default-size))
		(gimp-context-set-brush-size 50)
            (gimp-context-set-foreground '(128 128 128))
	
	(aset *newpoint* 0 (/ width 2))   ; set the paint array
	(aset *newpoint* 1 (/ height 2))	
	(gimp-paintbrush-default bubble-layer 2 *newpoint*)
))

(cond ((= bubb-type 2) 

(gimp-context-set-brush "sphere (79)")
(if (defined? 'gimp-context-set-brush-default-size) 
	        (gimp-context-set-brush-default-size))
            (gimp-context-set-foreground '(128 128 128))
	
	(aset *newpoint* 0 (/ width 2))   ; set the paint array
	(aset *newpoint* 1 (/ height 2))	
	(gimp-paintbrush-default bubble-layer 2 *newpoint*)
))

; *******************************************Start Pack sprites	
	
			(let*
				(
					;; Matching variables
					(bubbles-layer (car (gimp-layer-copy bubble-layer TRUE)))                    
				)
		
				;; Add a layer
	(air-bubbles-include-layer image bubbles-layer bubble-layer 1)	;stack 0=above 1=below			
	
                                
                     
				;; name the layer
				(gimp-item-set-name bubbles-layer "Bubbles")
				;[G'MIC] Pack Sprites: fx_pack_sprites 5,25,3,1,7,0,512,512
                ;22-6-013[G'MIC] Pack sprites : "-gimp_pack_sprites 5,30,0,0,1,2,1,width,height,"
                ;ORIGINAL[G'MIC] Pack sprites : "-gimp_pack_sprites 5,30,0,1,2,1,width,height,"
				
				
				(gimp-progress-pulse)
				;; Render Pack sprites using G'MIC.
				(plug-in-gmic-qt 1 image bubbles-layer 3 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"fx_pack_sprites 5,"
						(number->string min-size) ","
						(number->string spacing) ",0,1,2,1,"
						(number->string width) ","
						(number->string height) ","
                                 
					)
				)		
                
                (gimp-image-remove-layer image bubble-layer)
				(gimp-drawable-set-visible mask-layer FALSE)
			    
                      
; *******************************************End Pack sprites	
	
	(cond ((= ver 2.8) (gimp-image-select-color image 2 bubbles-layer '(128 128 128)))
	(else (gimp-by-color-select bubbles-layer '(128 128 128) 15 2 TRUE FALSE 0 FALSE))
	) ;endcond
	(gimp-selection-invert image)
	(gimp-edit-clear bubbles-layer)
	(gimp-selection-invert image)

;;;;create selection-channel (gimp-selection-load bubbles-selection)
    (set! bubbles-selection (car (gimp-selection-save image)))	
	(gimp-item-set-name bubbles-selection "bubbles-selection")
    
	(gimp-selection-none image)
	
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image bubbles-selection 5 5)
	(gimp-image-set-active-layer image bubbles-layer)
	(plug-in-bump-map RUN-NONINTERACTIVE image bubbles-layer bubbles-selection 90 20 10 0 0 0 0 TRUE FALSE 0)
	
	(gimp-image-remove-channel image bubbles-selection)
	(cond ((= ver 2.8) (gimp-image-select-item image 2 bubbles-layer)) 
	(else (gimp-selection-layer-alpha bubbles-layer)))
;;;;create selection-channel (gimp-selection-load bubbles-selection)
    (set! bubbles-selection (car (gimp-selection-save image)))	
	(gimp-item-set-name bubbles-selection "bubbles-selection")
	(gimp-selection-none image)
	(gimp-image-set-active-layer image bubbles-layer)
	(plug-in-colortoalpha 1 image bubbles-layer '(128 128 128))
	(gimp-item-set-name bubbles-layer "Bubbles")
	
	(set! bubbles1-layer (car (gimp-layer-copy bubbles-layer TRUE)))
	(air-bubbles-include-layer image bubbles1-layer bubbles-layer 0)	;stack 0=above 1=below
	
	(plug-in-colortoalpha 1 image bubbles1-layer '(0 0 0))
	(gimp-item-set-name bubbles1-layer "Highlights")
	
	(plug-in-colortoalpha 1 image bubbles-layer '(255 255 255))
	(gimp-item-set-name bubbles-layer "Shadows")
	
	(set! highlight (car (gimp-layer-copy bubbles1-layer TRUE)))
	(air-bubbles-include-layer image highlight bubbles1-layer 0)	;stack 0=above 1=below
		
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image highlight 3 3)
	(gimp-curves-spline highlight 4 8 #(0 0 112 26 172 133 255 255))
	(gimp-item-set-name highlight "Highlights Tightened")
	
	(gimp-layer-set-mode bubbles-layer 21)
	(set! shadow (car (gimp-layer-copy bubbles-layer TRUE)))
	(air-bubbles-include-layer image shadow bubbles-layer 0)	;stack 0=above 1=below
	
	(gimp-invert shadow)
	
;;;;create a drop-shadow	
	(set! drop-shadow (car (gimp-layer-new image width height RGBA-IMAGE "Drop Shadow" 100 0)))
	(air-bubbles-include-layer image drop-shadow bubbles-layer 0)	;stack 0=above 1=below
	(gimp-image-select-item image 2 bubbles-selection)
	(gimp-context-set-foreground '(7 38 102))
	(gimp-edit-fill drop-shadow 0)
	(gimp-selection-none image)
	(gimp-layer-set-offsets drop-shadow 0 1)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image drop-shadow 5 5)
    (gimp-image-select-item image 2 bubbles-selection)
	(gimp-edit-clear drop-shadow)
	(gimp-selection-none image)

;;;;create the background layer    
	(cond ((not (= bkg-type 0))
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 0)))
	(air-bubbles-include-layer image bkg-layer layer 0)	;stack 0=above 1=below
;	(gimp-drawable-set-visible layer FALSE)
    )
	) ;endcond
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (or (= bkg-type 3) (= bkg-type 4)) (begin 
	(gimp-context-set-foreground active-fg)
	(gimp-context-set-background active-bg)))
	(if (= bkg-type 4) (gimp-context-set-gradient active-gradient))
	(if (= bkg-type 2) (gimp-drawable-fill bkg-layer PATTERN-FILL))		
    (if (= bkg-type 1) (gimp-drawable-fill bkg-layer BACKGROUND-FILL))	
    (if (or (= bkg-type 3) (= bkg-type 4)) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)
    (if (= blendir 0) (set! x2 width))
	(if (= blendir 1) (set! y2 height))
	(if (= blendir 2) (begin
	(set! x2 (/ width 2))
	(set! y2 (/ height 2))))
	(if (= blendir 3) (begin
	(set! x1 (/ width 2))
	(set! y1 (/ height 2))))
	(gimp-edit-blend bkg-layer CUSTOM-MODE 0 gradient-type 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE x1 y1 x2 y2)))
    
	
;;;;finish the script
    (gimp-image-select-item image 2 selection-channel)	
	(if (= conserve FALSE) (begin
    (if (> bkg-type 0) (gimp-image-remove-layer image layer))
	(set! layer (car (gimp-image-merge-down image bubbles-layer EXPAND-AS-NECESSARY)))
	(set! layer (car (gimp-image-merge-down image drop-shadow EXPAND-AS-NECESSARY)))
	(set! layer (car (gimp-image-merge-down image shadow EXPAND-AS-NECESSARY)))
	(set! layer (car (gimp-image-merge-down image bubbles1-layer EXPAND-AS-NECESSARY)))
	(set! layer (car (gimp-image-merge-down image highlight EXPAND-AS-NECESSARY)))
	(gimp-image-remove-layer image mask-layer)
	(gimp-image-remove-channel image bubbles-selection)
	(gimp-image-remove-channel image selection-channel)
	)
	) ;endif
   (gimp-item-set-name layer layer-name)
   (if (= keep-selection FALSE) (gimp-selection-none image))
   (if (and (= conserve FALSE) (= alpha FALSE)) (gimp-layer-flatten layer))	
	
;   (gimp-display-new image)
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
    


 )
 )
) 



(script-fu-register "script-fu-air-bubbles-stars-alpha"        		    
  "Air Bubbles & Stars... Alpha"
  "Uses your selection or one it can create from a 'alpha layer' to create air bubbles inside the selection"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "June 2013"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-OPTION "Background Type" '("None" "Color" "Pattern" "Gradient" "Active Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
  SF-OPTION "Bubble Type" '("Default" "Star" "Custom" )
  SF-ADJUSTMENT "Bubble Spacing" '(0 -16 16 1 1 0 0)
  SF-ADJUSTMENT "Max Bubble size (pixels/2)" '(20 1 100 1 1 0 1)
  SF-ADJUSTMENT "Min Bubble size (% of Max Size)" '(30 1 100 1 1 0 1)
  SF-TOGGLE     "Keep selection"          FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
)

(script-fu-menu-register "script-fu-air-bubbles-stars-alpha" "<Image>/Script-Fu/Alpha-to-Logo")

(define (script-fu-air-bubbles-stars-logo 
                                      text
									  letter-spacing
									  line-spacing
                                      font-in 
                                      font-size
                                      bkg-type 
                                      pattern
                                      bkg-color
									  gradient
									  gradient-type
									  reverse
									  blendir
									  bubb-type
									  spacing
									  max-size
									  min-size
									  conserve
									  )
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))         
         (border (/ font-size 4))
		 (font (if (> (string-length font-in) 0) font-in (car (gimp-context-get-font))))
         (size-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (final-width (car (gimp-drawable-width size-layer)))
         (final-height (car (gimp-drawable-height size-layer)))
		 (active-gradient (car (gimp-context-get-gradient)))
		 (active-fg (car (gimp-context-get-foreground)))
		 (active-bg (car (gimp-context-get-background)))
         (text-layer 0)
         (width 0)
         (height 0)
         (bkg-layer 0)
		 (ver 2.8)
		 (selection-channel 0)
         (mask-layer 0)
         (bubble-layer 0)
		 (bubbles1-layer 0)
		 (brushName    "outlineBrush")
		 (*newpoint* (cons-array 2 'double))
		 (bubbles-selection 0)
		 (highlight 0)
		 (shadow 0)
		 (drop-shadow 0)
		 (x1 0)
		 (y1 0)
		 (x2 0)
		 (y2 0)
         )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
	(gimp-context-set-brush (caadr (gimp-brushes-get-list "")))
    (gimp-context-push)
	(gimp-context-set-paint-method "gimp-paintbrush")
	(if (= ver 2.8) (gimp-context-set-dynamics "Dynamics Off"))
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 300 4)) TRUE 300 PIXELS font)))
	(gimp-item-set-name text-layer "Text")
;;;;adjust text 
	(gimp-text-layer-set-justification text-layer 2)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
;;;;set the new width and height	
    (set! width (car (gimp-drawable-width text-layer)))
    (set! height (car (gimp-drawable-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)

;;;;square up the Image if needed	
    ;(if (< height width) (set! height width))
	;(if (< width height) (set! width height))

;;;;set the text clolor    
    (cond ((= ver 2.8) (gimp-image-select-item image 2 text-layer)) 
	(else (gimp-selection-layer-alpha text-layer)))
	(gimp-edit-fill text-layer 0)
	
;;;;create selection-channel (gimp-selection-load selection-channel)
    (set! selection-channel (car (gimp-selection-save image)))	
	(gimp-item-set-name selection-channel "selection-channel")
    (gimp-image-set-active-layer image text-layer)	
;	(gimp-selection-none image)
    
;;;;begin the script
	
;;;;create the mask-layer
    (set! mask-layer (car (gimp-layer-new image width height RGBA-IMAGE "Mask" 100 0)))
	(air-bubbles-include-layer image mask-layer text-layer 0)	;stack 0=above 1=below
    
	(gimp-drawable-fill mask-layer 0)
	(gimp-image-select-item image 2 selection-channel)
	(gimp-edit-clear mask-layer)
	(gimp-selection-none image)
	
	
;;;;create the bubble-layer	
	(set! bubble-layer (car (gimp-layer-new image width height RGBA-IMAGE "Bubble" 100 0)))
	(air-bubbles-include-layer image bubble-layer mask-layer 0)	;stack 0=above 1=below
	
;;;; define new brush for drawing operation
(cond ((= bubb-type 0) 
            (gimp-brush-new brushName)
			(gimp-brush-set-shape brushName BRUSH-GENERATED-CIRCLE)    
            (gimp-brush-set-spikes brushName 2)
            (gimp-brush-set-hardness brushName 1.00)                   
            (gimp-brush-set-aspect-ratio brushName 1.0)
            (gimp-brush-set-angle brushName 0.0)                       
            (gimp-brush-set-spacing brushName 194.0)
            (gimp-brush-set-radius brushName max-size)            
            (gimp-context-set-brush brushName)
			(if (defined? 'gimp-context-set-brush-default-size) 
	        (gimp-context-set-brush-default-size))
            (gimp-context-set-foreground '(128 128 128))
	
	(aset *newpoint* 0 (/ width 2))   ; set the paint array
	(aset *newpoint* 1 (/ height 2))	
	(gimp-paintbrush-default bubble-layer 2 *newpoint*)
	(gimp-brush-delete brushName)
	))
(cond ((= bubb-type 1) 

(gimp-context-set-brush "2. Star")
(if (defined? 'gimp-context-set-brush-default-size) 
	        (gimp-context-set-brush-default-size))
            (gimp-context-set-foreground '(128 128 128))
	
	(aset *newpoint* 0 (/ width 2))   ; set the paint array
	(aset *newpoint* 1 (/ height 2))	
	(gimp-paintbrush-default bubble-layer 2 *newpoint*)
))

(cond ((= bubb-type 2) 

(gimp-context-set-brush "sphere (79)")
(if (defined? 'gimp-context-set-brush-default-size) 
	        (gimp-context-set-brush-default-size))
            (gimp-context-set-foreground '(128 128 128))
	
	(aset *newpoint* 0 (/ width 2))   ; set the paint array
	(aset *newpoint* 1 (/ height 2))	
	(gimp-paintbrush-default bubble-layer 2 *newpoint*)
))

; *******************************************Start Pack sprites	
	
			(let*
				(
					;; Matching variables
					(bubbles-layer (car (gimp-layer-copy bubble-layer TRUE)))                    
				)
		
				;; Add a layer
	(air-bubbles-include-layer image bubbles-layer bubble-layer 1)	;stack 0=above 1=below			
	
                                
                     
				;; name the layer
				(gimp-item-set-name bubbles-layer "Bubbles")
				;[G'MIC] Pack Sprites: fx_pack_sprites 5,25,3,1,7,0,512,512
                ;22-6-013[G'MIC] Pack sprites : "-gimp_pack_sprites 5,30,0,0,1,2,1,width,height,"
                ;ORIGINAL[G'MIC] Pack sprites : "-gimp_pack_sprites 5,30,0,1,2,1,width,height,"
                     				
				
				(gimp-progress-pulse)
				;; Render Pack sprites using G'MIC.
				(plug-in-gmic-qt 1 image bubbles-layer 3 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"fx_pack_sprites 5,"
						(number->string min-size) ","
						(number->string spacing) ",0,1,2,1,"
						(number->string width) ","
						(number->string height) ","
                                 
					)
				)		
                
                (gimp-image-remove-layer image bubble-layer)
			    
                      
; *******************************************End Pack sprites	
	
	(cond ((= ver 2.8) (gimp-image-select-color image 2 bubbles-layer '(128 128 128)))
	(else (gimp-by-color-select bubbles-layer '(128 128 128) 15 2 TRUE FALSE 0 FALSE))
	) ;endcond
	(gimp-selection-invert image)
	(gimp-edit-clear bubbles-layer)
	(gimp-selection-invert image)

;;;;create selection-channel (gimp-selection-load bubbles-selection)
    (set! bubbles-selection (car (gimp-selection-save image)))	
	(gimp-item-set-name bubbles-selection "bubbles-selection")
    
	(gimp-selection-none image)
	
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image bubbles-selection 5 5)
	(gimp-image-set-active-layer image bubbles-layer)
	(plug-in-bump-map RUN-NONINTERACTIVE image bubbles-layer bubbles-selection 90 20 10 0 0 0 0  TRUE FALSE 0)
	
	(gimp-image-remove-channel image bubbles-selection)
	(cond ((= ver 2.8) (gimp-image-select-item image 2 bubbles-layer)) 
	(else (gimp-selection-layer-alpha bubbles-layer)))
;;;;create selection-channel (gimp-selection-load bubbles-selection)
    (set! bubbles-selection (car (gimp-selection-save image)))	
	(gimp-item-set-name bubbles-selection "bubbles-selection")
	(gimp-selection-none image)
	(gimp-image-set-active-layer image bubbles-layer)
	(plug-in-colortoalpha 1 image bubbles-layer '(128 128 128))
	(gimp-item-set-name bubbles-layer "Bubbles")
	
	(set! bubbles1-layer (car (gimp-layer-copy bubbles-layer TRUE)))
	(air-bubbles-include-layer image bubbles1-layer bubbles-layer 0)	;stack 0=above 1=below
	
	(plug-in-colortoalpha 1 image bubbles1-layer '(0 0 0))
	(gimp-item-set-name bubbles1-layer "Highlights")
	
	(plug-in-colortoalpha 1 image bubbles-layer '(255 255 255))
	(gimp-item-set-name bubbles-layer "Shadows")
	
	(set! highlight (car (gimp-layer-copy bubbles1-layer TRUE)))
	(air-bubbles-include-layer image highlight bubbles1-layer 0)	;stack 0=above 1=below
		
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image highlight 3 3)
	(gimp-curves-spline highlight 4 8 #(0 0 112 26 172 133 255 255))
	(gimp-item-set-name highlight "Highlights Tightened")
	
	(gimp-layer-set-mode bubbles-layer 21)
	(set! shadow (car (gimp-layer-copy bubbles-layer TRUE)))
	(air-bubbles-include-layer image shadow bubbles-layer 0)	;stack 0=above 1=below
	
	(gimp-invert shadow)
	
;;;;create a drop-shadow	
	(set! drop-shadow (car (gimp-layer-new image width height RGBA-IMAGE "Drop Shadow" 100 0)))
	(air-bubbles-include-layer image drop-shadow bubbles-layer 0)	;stack 0=above 1=below
	(gimp-image-select-item image 2 bubbles-selection)
	(gimp-context-set-foreground '(7 38 102))
	(gimp-edit-fill drop-shadow 0)
	(gimp-selection-none image)
	(gimp-layer-set-offsets drop-shadow 0 1)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image drop-shadow 5 5)
    (gimp-image-select-item image 2 bubbles-selection)
	(gimp-edit-clear drop-shadow)
	(gimp-selection-none image)
	
	
	
	
	
	
	
	
;;;;Scale Image to it's original size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-image-scale-full image final-width final-height 2)
	(set! width (car (gimp-image-width image)))
	(set! height (car (gimp-image-height image)))
   
;;;;create the background layer    
	(cond ((not (= bkg-type 4))
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 0)))
	(air-bubbles-include-layer image bkg-layer bubbles-layer 1)	;stack 0=above 1=below
    )
	) ;endcond
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (or (= bkg-type 2) (= bkg-type 3)) (begin 
	(gimp-context-set-foreground active-fg)
	(gimp-context-set-background active-bg)))
	(if (= bkg-type 3) (gimp-context-set-gradient active-gradient))
	(if (= bkg-type 1) (gimp-drawable-fill bkg-layer PATTERN-FILL))		
    (if (= bkg-type 0) (gimp-drawable-fill bkg-layer BACKGROUND-FILL))	
    (if (or (= bkg-type 2) (= bkg-type 3)) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)
    (if (= blendir 0) (set! x2 width))
	(if (= blendir 1) (set! y2 height))
	(if (= blendir 2) (begin
	(set! x2 (/ width 2))
	(set! y2 (/ height 2))))
	(if (= blendir 3) (begin
	(set! x1 (/ width 2))
	(set! y1 (/ height 2))))
	(gimp-edit-blend bkg-layer CUSTOM-MODE 0 gradient-type 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE x1 y1 x2 y2)))
    (if (= bkg-type 4) (begin
	(gimp-image-remove-layer image mask-layer)
	(gimp-image-remove-layer image text-layer)))
	

	
    ;end	
;;;;finish the script	
	(if (= conserve FALSE) (begin
	(set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
    (gimp-item-set-name text-layer text)
	(gimp-image-remove-channel image bubbles-selection)
	(gimp-image-remove-channel image selection-channel)
	))	
	
	
	
	
	
	
	(gimp-context-pop)
	
    
    

    (gimp-display-new image)
	) ;end let pack sprites
    ) ;end let
  ) ;end define 
(script-fu-register "script-fu-air-bubbles-stars-logo"
  "Air Bubbles & Stars... Logo"
  "Create a Logo containing Air Bubbles  over a optional background choices"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "June 2013"
  ""
  SF-TEXT       "Text"    "H2O"
  SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-FONT       "Font"               "Sans Bold"
  SF-ADJUSTMENT "Font size (pixels)" '(300 6 500 1 1 0 1)
  SF-OPTION "Background Type" '("Color" "Pattern" "Gradient" "Active Gradient" "None")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
  SF-OPTION "Bubble Type" '("Default" "Star" "Custom" )
  SF-ADJUSTMENT "Bubble Spacing" '(0 -16 16 1 1 0 0)
  SF-ADJUSTMENT "Max Bubble size (pixels/2)" '(20 1 100 1 1 0 1)
  SF-ADJUSTMENT "Min Bubble size (% of Max Size)" '(30 1 100 1 1 0 1)
  SF-TOGGLE     "Keep the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-air-bubbles-stars-logo" "<Image>/Script-Fu/Logos")