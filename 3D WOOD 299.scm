;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; 3D WOOD rel 0.01
; Created by Graechan from a tutorial by Chris F at http://www.gimpchat.com/viewtopic.php?f=23&t=6482
; 
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

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		(define  (apply-drop-shadow img fond x y blur color opacity number) (begin
				(gimp-image-select-item img 2 fond)
				(gimp-selection-translate img x y)
				(gimp-selection-feather img blur)
				(gimp-context-set-foreground color)
				(gimp-context-set-opacity opacity)
				(gimp-image-select-item img 1 fond)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-context-set-opacity 100)
				(gimp-selection-none img)
			))


(define (script-fu-3d-wood 
                                      text
				      justify
									  letter-spacing
									  line-spacing
									 grow-text
									  outline
									  modify
									  blur-adjust
                                      color 
                                      font-in 
                                      font-size
									  3d-height
									  texture
									  texture-pattern
									  azimuth
									  elevation
									  depth
                                      bkg-type 
                                      pattern
                                      bkg-color
									  gradient
									  conserve)
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
	 		 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))
         (bkg-layer 0)
		 (guass-layer 0)
		 (motion-layer 0)
         (noise-layer 0)
		 (blur (+ (/ 350 5.8) blur-adjust))
         )
    (gimp-context-push)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
		(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )

	
;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 350 4)) TRUE 350 PIXELS font)))
	
;;;;adjust the text on line
(gimp-text-layer-set-justification text-layer justify)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	;(gimp-text-layer-set-justification text-layer 2)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
	
	(set! width (car (gimp-drawable-get-width text-layer)))
    (set! height (car (gimp-drawable-get-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)
    
;;;;;; SHRINK/GROW text
(cond ((> grow-text 0)
	(gimp-selection-none image)
	(gimp-image-select-item image 2 text-layer)
	(gimp-selection-grow image (round grow-text))   
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none image)
	(gimp-image-select-item image 2 text-layer)
	(gimp-drawable-edit-clear text-layer)
	(gimp-selection-shrink image (- grow-text))   
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
 ))
 
  ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none image)
	(gimp-image-select-item image 2 text-layer)
	(gimp-selection-shrink image (round outline))   
	(gimp-drawable-edit-clear text-layer)
	(gimp-image-select-item image 2 text-layer)
 ))
	
;;;;text modify
	(if (= modify TRUE) (begin
	;(gimp-image-set-active-layer image text-layer)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image text-layer blur blur)
	(gimp-drawable-curves-spline text-layer HISTOGRAM-ALPHA 8 #(0 0 0.6196 0.0745 0.68235 0.94901 1 1))))

;;;;create the guass-layer
    (set! guass-layer (car (gimp-layer-copy text-layer TRUE)))
    (gimp-image-insert-layer image guass-layer 0 1)
    (gimp-item-set-name guass-layer "Guass")
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image guass-layer 40 40)
	
;;;;create the motion-layer
    (set! motion-layer (car (gimp-layer-copy text-layer TRUE)))
    (gimp-image-insert-layer image motion-layer 0 2)
    (gimp-item-set-name motion-layer "Motion")
	(plug-in-mblur 1 image motion-layer 0 3d-height 90 (/ width 2) (/ height 2))
	
;;;;create the noise-layer
	(set! noise-layer (car (gimp-layer-new image width height RGBA-IMAGE "Noise" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image noise-layer 0 3)
	(if (= texture 0) (plug-in-solid-noise 1 image noise-layer FALSE TRUE 0 1 16.0 0.6))
	(if (= texture 1) (begin
	(gimp-context-set-pattern texture-pattern)
	(gimp-drawable-fill noise-layer FILL-PATTERN)
	(gimp-drawable-desaturate noise-layer 0)))

;;;;set the text clolor    
    (gimp-context-set-foreground color)
	(gimp-image-select-item image 2 text-layer)
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
	(gimp-selection-none image)

	(plug-in-bump-map 1 image text-layer guass-layer 267.69 21.92 16 0 0 1 0.37647 TRUE FALSE 0)
	(if (= texture 0) (plug-in-bump-map 1 image text-layer noise-layer 0 21.92 3 0 0 0 0 TRUE FALSE 0))
	(if (= texture 1) (plug-in-bump-map 1 image text-layer noise-layer azimuth elevation depth 0 0 0 0 TRUE FALSE 0))
	(plug-in-bump-map 1 image text-layer motion-layer 156.92 21.92 8 0 0 0.86274 0.69411 TRUE FALSE 0)
    
;;;;Scale Image to it's original size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-image-scale image final-width final-height )
	(set! width (car (gimp-image-get-width image)))
	(set! height (car (gimp-image-get-height image)))	
	
;;;;create the background layer    
	(if (> bkg-type 0)
	(begin
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 1)))
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 1) (gimp-drawable-fill bkg-layer FILL-PATTERN))		
    (if (= bkg-type 2) (gimp-drawable-fill bkg-layer FILL-BACKGROUND))	
    (if (= bkg-type 3) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)	
	;(gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-SHAPEBURST-SPHERICAL 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height))
		(gimp-drawable-edit-gradient-fill bkg-layer GRADIENT-SHAPEBURST-SPHERICAL 0 1 1 0.0 FALSE 0 0 width height)
))
    
	(apply-drop-shadow image text-layer 8 8 15 '(0 0 0) 80 FALSE)	
;;;;resize the text-layer		
    ;(gimp-image-set-active-layer image text-layer)
	(gimp-layer-resize-to-image-size text-layer)    
	
   (if (= conserve FALSE) 
    (begin 
    (gimp-image-remove-layer image guass-layer)
	(gimp-image-remove-layer image noise-layer)
	(gimp-image-remove-layer image motion-layer)
	;(set! text-layer (car (gimp-image-merge-down image text-layer EXPAND-AS-NECESSARY)))
	(if (> bkg-type 0) (set! text-layer (car (gimp-image-merge-down image text-layer EXPAND-AS-NECESSARY))))
	))
	(gimp-item-set-name text-layer text)

	(gimp-context-pop)

    (gimp-display-new image)
    )
  ) 
(script-fu-register "script-fu-3d-wood"
  "3D WOOD 299..."
  "can Create a 3D Text with optinal wood or texture from a pattern"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Feb 2013"
  ""
  SF-TEXT       "Text"    "3D WOOD"
    SF-OPTION "Justify" '("Centered" "Left" "Right")
  SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
    SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
      SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -40 40 1 10 0 0)
  SF-ADJUSTMENT _"Outline"          '(0 0 40 1 10 0 0)
  SF-TOGGLE     "Modify Text"   FALSE
  SF-ADJUSTMENT "Modify Adj" '(0 -50 50 1 5 0 0)
  SF-COLOR      "Text color"         '(255 104 0) ;'(187 104 0)azimuth
  SF-FONT       "Font"               "Arial Heavy" 
  SF-ADJUSTMENT "Font size (pixels)" '(150 6 500 1 1 0 0)
  SF-ADJUSTMENT "3D Height" '(20 0 50 1 5 0 0)
  SF-OPTION "Texture" '("Wood" "use Pattern" "None")
  SF-PATTERN    "Texture Pattern"            "Crack"
  SF-ADJUSTMENT "Pattern Azimuth" '(135 0 360 1 10 0 0)
  SF-ADJUSTMENT "Pattern Elevation" '(45 1 90 1 5 0 0)
  SF-ADJUSTMENT "Pattern Depth" '(3 1 65 1 5 0 0)
  SF-OPTION "Background Type" '("None" "Pattern" "Color" "Gradient")
  SF-PATTERN    "Background Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         '(153 153 153)
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-TOGGLE     "Keep the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-3d-wood" "<Image>/Script-Fu/Logos")
