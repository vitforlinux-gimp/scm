;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Plastic or Glass  rel 0.04
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
; Rel 0.02 - Added alpha script
; Rel 0.03 - Added extra background choices to both scripts, also made drop shadow an option
; Rel 0.04 - Bugfix to smooth text
; Rel 299 - Port to Gimp 2.99.8 and 2.10.30 also compatibility OFF by vitforlinux
; Rel 299b - added opacity control
; Rel 299c fixed image/layer size with letter-spacing/line-spacing>40

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))



(define (script-fu-plastic-or-glass-text 
                                      text
				      col-pat
                                      color
				      pattern
                                      font-in 
                                      font-size
				      								 justification
                                 letter-spacing
                                 line-spacing
					grow-text
					outline
														  modify
									  modify-adjust
									  Material
									  opacity
									  bkg-type 
                                      bkg-pattern
                                      bkg-color
							          gradient
							          gradient-type-in
									  border-inc
									  pre-blur
									  drop-shadow
									  conserve)
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))         
         (border (round (/ font-size (/ 10 border-inc))))
		 (font (if (> (string-length font-in) 0) font-in (car (gimp-context-get-font))))
         (size-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (final-width (car (gimp-drawable-get-width size-layer)))
         (final-height (car (gimp-drawable-get-height size-layer)))
         (text-layer 0)
         (width 0)
         (height 0)
         (bkg-layer 0)
		 (random_gradient 0)
		 (gradient-type 0)
		 (name-string 0)
		 (layer-name "Plastic or Glass")
	     (gradient-type-name 0)
		 (gradient-type-blend 0)
		 (bump-layer 0)
		 (selection-channel 0)
		 (reflection1 0)
		 (reflection2 0)
		 (reflection3 0)
		 (blur (+ (/ 350 5.8) modify-adjust))
         (tint-layer 0) 
  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))	 
         )
    (gimp-context-push)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 350 (/ 10 border-inc))) TRUE 350 PIXELS font)))
    (set! width (car (gimp-drawable-get-width text-layer)))
    (set! height (car (gimp-drawable-get-height text-layer)))  
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)
	
;;;;centre text on line
	;(gimp-text-layer-set-justification text-layer 2)
	      (gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification text-layer justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing   

;;;;square up the Image if needed	
    ;(if (< height width) (set! height width))
	;(if (< width height) (set! width height))

	
;;;; shrink grow text
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
 (gimp-image-resize-to-layers image)
 ;;;;text modify
	(if (= modify TRUE) (begin
	;(gimp-image-set-active-layer image text-layer)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image text-layer blur blur)
	(gimp-drawable-curves-spline text-layer HISTOGRAM-ALPHA 8 #(0 0 0.6196 0.0745 0.68235 0.94901 1 1))))

;;;;set the text clolor    
    (gimp-image-select-item image 2 text-layer)
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
	(gimp-layer-resize-to-image-size text-layer)
;;;;create selection-channel (gimp-image-select-item image 2 selection-channel)
    (gimp-selection-save image)
	(set! selection-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity selection-channel 100)	
	(gimp-item-set-name selection-channel "selection-channel")
    (gimp-image-set-active-layer image text-layer)	
	(gimp-selection-none image)
	
;;;;create the bump-layer
    (set! bump-layer (car (gimp-layer-copy text-layer TRUE)))
	(gimp-image-insert-layer image bump-layer -1 0)
	(gimp-item-set-name bump-layer "Bump Layer")
	(gimp-layer-flatten bump-layer)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image bump-layer pre-blur pre-blur)
	(gimp-item-set-visible bump-layer FALSE)
    
;;;;create the background layer    
	(if (> bkg-type 0) (begin
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 2)))
	(gimp-context-set-pattern bkg-pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 1) 
	(begin
	(gimp-drawable-fill bkg-layer FILL-PATTERN)
	(gimp-item-set-name bkg-layer (string-append (car (gimp-item-get-name bkg-layer)) "_pattern" "_" pattern))))		
    (if (= bkg-type 2) 
	(begin
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)	
    (gimp-item-set-name bkg-layer (string-append (car (gimp-item-get-name bkg-layer)) "_color"))))
	(if (= bkg-type 3) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)
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
	;(gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY gradient-type-blend 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
	(gimp-drawable-edit-gradient-fill bkg-layer gradient-type-blend 0 REPEAT-NONE FALSE 0.2 TRUE 0 0 width height)
	(gimp-item-set-name bkg-layer (string-append gradient "_" gradient-type-name))))
;;;;create the random gradients
	(if (= bkg-type 4)
    (begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)
	(set! random_gradient (list-ref (cadr (gimp-gradients-get-list "")) (round (random (car (gimp-gradients-get-list ""))))))
    (set! gradient-type (+ 6 (random 3)))
	(gimp-context-set-gradient random_gradient)
	;(gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY gradient-type 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
	(gimp-drawable-edit-gradient-fill bkg-layer gradient-type 0 REPEAT-NONE FALSE 0.2 TRUE 0 0 width height)
	
	(set! gradient-type-name
			(cond 
				(( equal? gradient-type 6 ) "GRADIENT-SHAPEBURST-ANGULAR")
				(( equal? gradient-type 7 ) "GRADIENT-SHAPEBURST-SPHERICAL")
				(( equal? gradient-type 8 ) "GRADIENT-SHAPEBURST-DIMPLED")))
				
	(set! name-string (string-append (car (gimp-item-get-name bkg-layer)) "- Gradient " random_gradient))
	(gimp-item-set-name bkg-layer name-string)
	;(gimp-item-set-name bkg-layer (string-append gradient "_" gradient-type-name))
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))))

;;;;prepare the text-layer
	(gimp-image-set-active-layer image text-layer)
	(gimp-drawable-colorize-hsl text-layer 180 0 70)
	(plug-in-bump-map 1 image text-layer bump-layer 250 45 50 0 0 0 0 TRUE FALSE 0)
	(gimp-layer-set-lock-alpha text-layer TRUE)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image text-layer 3 3)
	(gimp-layer-set-lock-alpha text-layer FALSE)


;;;;create the reflections	
	(set! reflection1 (car (gimp-layer-copy text-layer TRUE)))
	(gimp-image-insert-layer image reflection1 0 -1)
	(gimp-item-set-name reflection1 "Reflection1")
	(gimp-drawable-threshold reflection1 0 0 0.31372)
	(plug-in-colortoalpha 1 image reflection1 '(0 0 0))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image reflection1 15 15)
	(gimp-drawable-curves-spline reflection1 4 8 #(0 0 0.63529 0 0.69019 1 1 1))
	(gimp-layer-set-opacity reflection1 30)
	
	(set! reflection2 (car (gimp-layer-copy text-layer TRUE)))
	(gimp-image-insert-layer image reflection2 0 -1)
	(gimp-item-set-name reflection2 "Reflection2")
	(gimp-drawable-threshold reflection2 0 0.39215 0.50980)
	(plug-in-colortoalpha 1 image reflection2 '(0 0 0))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image reflection2 8 8)
	(gimp-drawable-curves-spline reflection2 4 8 #(0 0 0.73725 0 0.79607 1 1 1))
	(gimp-layer-set-opacity reflection2 60)
	
	(set! reflection3 (car (gimp-layer-copy text-layer TRUE)))
	(gimp-image-insert-layer image reflection3 0 -1)
	(gimp-item-set-name reflection3 "Reflection3")
	(gimp-drawable-threshold reflection3 0 0.78431 1)
	(plug-in-colortoalpha 1 image reflection3 '(0 0 0))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image reflection3 15 15)
	(gimp-drawable-curves-spline reflection3 4 8 #(0 0 0.63529 0 0.69019 1 1 1))
	(gimp-layer-set-opacity reflection3 70)

;;;;apply the tint	
	(gimp-image-select-item image 2 selection-channel)
	(gimp-context-set-foreground color)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	(gimp-image-set-active-layer image text-layer)
	(set! tint-layer (car (gimp-layer-new image width height RGBA-IMAGE "Tint" 100 LAYER-MODE-GRAIN-MERGE-LEGACY)))
    (gimp-image-insert-layer image tint-layer 0 -1)
    	(gimp-layer-resize-to-image-size tint-layer)
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND) ;QUI!!!
	(cond
	((= col-pat 1) 
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN))
	((= col-pat 2) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-context-set-paint-mode LAYER-MODE-LIGHTEN-ONLY-LEGACY  )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 3) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-context-set-paint-mode LAYER-MODE-OVERLAY  )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 4) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-context-set-paint-mode LAYER-MODE-MULTIPLY-LEGACY )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 5) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-drawable-desaturate tint-layer DESATURATE-LIGHTNESS)
	(gimp-context-set-paint-mode LAYER-MODE-LIGHTEN-ONLY-LEGACY  )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 6) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-drawable-desaturate tint-layer DESATURATE-LIGHTNESS)
	(gimp-context-set-paint-mode LAYER-MODE-OVERLAY  )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 7) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-drawable-desaturate tint-layer DESATURATE-LIGHTNESS)
	(gimp-context-set-paint-mode LAYER-MODE-MULTIPLY-LEGACY )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	)
	

	(gimp-selection-none image)

;;;;Scale Image to it's original size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-image-scale image final-width final-height)
	(set! width (car (gimp-image-get-width image)))
	(set! height (car (gimp-image-get-height image)))

;;;;create the glass effect	
	(if (= Material 1) (gimp-drawable-curves-spline text-layer 0 18 #(0 1 0.11764 0 0.25490 1 0.37254 0 0.49019 1 0.62745 0 0.74509 1 0.87058 0 1 1)));max
;;: change opacity text

(cond ((< opacity 100) 
(gimp-layer-set-opacity text-layer opacity )
(gimp-layer-set-opacity tint-layer opacity ))
)
	(if (= conserve FALSE) (begin
	(set! text-layer (car (gimp-image-merge-down image tint-layer EXPAND-AS-NECESSARY)))
	(gimp-drawable-hue-saturation text-layer 0 0 0 26 50)
	(gimp-image-remove-layer image bump-layer)))
	(if (= drop-shadow TRUE) (script-fu-drop-shadow image text-layer 8 8 15 '(0 0 0) (- opacity 20) FALSE))
	
	(if (= conserve FALSE) (begin
	(if (> bkg-type 0) (set! layer-name (car (gimp-item-get-name bkg-layer)))) 
	(set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
	(gimp-item-set-name text-layer layer-name)
	(if (= bkg-type 4) (begin
	(set! name-string (string-append (car (gimp-item-get-name text-layer)) "- Gradient " random_gradient))	
	(gimp-item-set-name text-layer name-string)))))
	
	(gimp-context-pop)
    (gimp-display-new image)
	
    )
  ) 
(script-fu-register "script-fu-plastic-or-glass-text"
  "Plastic or Glass Text 299"
  "Create an image with a text layer over a optional background layer"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Oct 2012"
  ""
  SF-TEXT       "Text"    "Plastic\n& Glass"
  SF-OPTION "Fill type" '("Color" "Pattern" "Pattern+Color LIGHTEN ONLY" "Pattern+Color OVERLAY" "Pattern+Color MULTIPLY" "Pattern Desaturate +Color LIGHTEN ONLY" "Pattern Desaturate+Color OVERLAY" "Pattern Desaturate+Color MULTIPLY")
  SF-COLOR      "Text Color"         '(0 0 255)
  SF-PATTERN		"Text Pattern"				"Burlwood"
  SF-FONT       "Font"               "JasmineUPC Bold"
  SF-ADJUSTMENT "Font size (pixels)" '(150 100 500 1 1 0 1)
SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 1)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 1)
SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
  SF-TOGGLE     "Modify Text"   FALSE
  SF-ADJUSTMENT "Modify Adj" '(0 -50 50 1 5 0 0)
  SF-OPTION "Material Type" '("Plastic" "Glass")
  SF-ADJUSTMENT "Opacity" '(100 20 100 1 1 1 0)
  SF-OPTION     "Background Type" '( "None" "Pattern" "Color" "Gradient" "Random Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         '(153 153 153)
  SF-GRADIENT   "Background Gradient" "Burning Transparency"
  SF-OPTION     "Gradient Shape if Bkg-type=gradient" '("GRADIENT-SHAPEBURST-ANGULAR" "GRADIENT-SHAPEBURST-SPHERICAL" "GRADIENT-SHAPEBURST-DIMPLED")
  SF-ADJUSTMENT "Border Inc." '(3 1 10 .1 1 1 0)
  SF-ADJUSTMENT "Bump Blur" '(30 20 50 1 10 0 0)
  SF-TOGGLE     "Apply Drop Shadow"   TRUE
  SF-TOGGLE     "Keep the Layers"   FALSE 
  )
(script-fu-menu-register "script-fu-plastic-or-glass-text" "<Image>/Script-Fu/Logos/")

(define (script-fu-plastic-or-glass image drawable
                               col-pat
			       color
			       pattern
							   Material
							   opacity
							   bkg-type 
                               bkg-pattern
                               bkg-color
							   gradient
							   gradient-type-in
							   pre-blur
							   drop-shadow
							   keep-selection-in
							   conserve
							   )							  

 (let* (
        (image-layer (car (gimp-image-get-active-layer image)))
		(width (car (gimp-image-get-width image)))
		(height (car (gimp-image-get-height image)))
		(alpha (car (gimp-drawable-has-alpha image-layer)))
		(sel (car (gimp-selection-is-empty image)))
		(layer-name (car (gimp-item-get-name image-layer)))
		(keep-selection keep-selection-in)
		(selection-channel 0)
		(text-layer 0)
		(bkg-layer 0)
		(random_gradient 0)
		(gradient-type 0)
		(name-string 0)
		(gradient-type-name 0)
		(gradient-type-blend 0)
		(bump-layer 0)
		(selection-channel 0)
		(reflection1 0)
		(reflection2 0)
		(reflection3 0)
        (tint-layer 0)
        )	
	
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-default-colors)
	
	(set! text-layer (car (gimp-layer-new image width height RGBA-IMAGE "Copy" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image text-layer 0 -1)
    (gimp-item-set-name text-layer "Copy Layer")	
	
	(if (= alpha FALSE) (gimp-layer-add-alpha image-layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (gimp-image-select-item image 2 image-layer))
	
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
	
;;;;create selection-channel (gimp-image-select-item image 2 selection-channel)
    (gimp-selection-save image)
	(set! selection-channel (car (gimp-image-get-active-drawable image)))	
	(gimp-channel-set-opacity selection-channel 100)	
	(gimp-item-set-name selection-channel "selection-channel")
    (gimp-image-set-active-layer image text-layer)	
	(gimp-selection-none image)	
;;;;begin the script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;;;;create the bump-layer
    (set! bump-layer (car (gimp-layer-copy text-layer TRUE)))
	(gimp-image-insert-layer image bump-layer -1 0)
	(gimp-item-set-name bump-layer "Bump Layer")
	(gimp-layer-flatten bump-layer)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image bump-layer pre-blur pre-blur)
	(gimp-item-set-visible bump-layer FALSE)	

;;;;create the background layer    
	(if (> bkg-type 0) (begin
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 2 0)))
	(gimp-context-set-pattern bkg-pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 1) 
	(begin
	(gimp-drawable-fill bkg-layer FILL-PATTERN)
	(gimp-item-set-name bkg-layer (string-append (car (gimp-item-get-name bkg-layer)) "_pattern" "_" pattern))))		
    (if (= bkg-type 2) 
	(begin
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)	
    (gimp-item-set-name bkg-layer (string-append (car (gimp-item-get-name bkg-layer)) "_color"))))
	(if (= bkg-type 3) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)
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
	(gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY gradient-type-blend 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
	(gimp-drawable-edit-gradient-fill bkg-layer gradient-type-blend 0 REPEAT-NONE FALSE 0.2 TRUE 0 0 width height)
	(gimp-item-set-name bkg-layer (string-append gradient "_" gradient-type-name))))
;;;;create the random gradients
	(if (= bkg-type 4)
    (begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)
	(set! random_gradient (list-ref (cadr (gimp-gradients-get-list "")) (round (random (car (gimp-gradients-get-list ""))))))
    (set! gradient-type (+ 6 (random 3)))
	(gimp-context-set-gradient random_gradient)
	(gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY gradient-type 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
	
	(set! gradient-type-name
			(cond 
				(( equal? gradient-type 6 ) "GRADIENT-SHAPEBURST-ANGULAR")
				(( equal? gradient-type 7 ) "GRADIENT-SHAPEBURST-SPHERICAL")
				(( equal? gradient-type 8 ) "GRADIENT-SHAPEBURST-DIMPLED")))
				
	(set! name-string (string-append (car (gimp-item-get-name bkg-layer)) "- Gradient " random_gradient "- Shape " gradient-type-name))
	(gimp-item-set-name bkg-layer name-string)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))))
	
;;;;prepare the text-layer
	(gimp-image-set-active-layer image text-layer)
	(gimp-drawable-colorize-hsl text-layer 180 0 70)
	(plug-in-bump-map 1 image text-layer bump-layer 250 45 50 0 0 0 0 TRUE FALSE 0)
	(gimp-layer-set-lock-alpha text-layer TRUE)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image text-layer 3 3)
	(gimp-layer-set-lock-alpha text-layer FALSE)	
	
;;;;create the reflections	
	(set! reflection1 (car (gimp-layer-copy text-layer TRUE)))
	(gimp-image-insert-layer image reflection1 0 -1)
	(gimp-item-set-name reflection1 "Reflection1")
	(gimp-drawable-threshold reflection1 0 0 0.31372)
	(plug-in-colortoalpha 1 image reflection1 '(0 0 0))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image reflection1 15 15)
	(gimp-drawable-curves-spline reflection1 4 8 #(0 0 0.63529 0 0.69019 1 1 1))
	(gimp-layer-set-opacity reflection1 30)
	
	(set! reflection2 (car (gimp-layer-copy text-layer TRUE)))
	(gimp-image-insert-layer image reflection2 -1 0)
	(gimp-item-set-name reflection2 "Reflection2")
	(gimp-drawable-threshold reflection2 0 0.39215 0.50980)
	(plug-in-colortoalpha 1 image reflection2 '(0 0 0))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image reflection2 8 8)
	(gimp-drawable-curves-spline reflection2 4 8 #(0 0 0.73725 0 0.79607 1 1 1))
	(gimp-layer-set-opacity reflection2 60)
	
	(set! reflection3 (car (gimp-layer-copy text-layer TRUE)))
	(gimp-image-insert-layer image reflection3 0 -1)
	(gimp-item-set-name reflection3 "Reflection3")
	(gimp-drawable-threshold reflection3 0 0.78431 1)
	(plug-in-colortoalpha 1 image reflection3 '(0 0 0))
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image reflection3 15 15)
	(gimp-drawable-curves-spline reflection3 4 8 #(0 0 0.63529 0 0.69019 1 1 1))
	(gimp-layer-set-opacity reflection3 70)	

;;;;apply the tint	
	(gimp-image-select-item image 2 selection-channel)
	(gimp-context-set-foreground color)
	(gimp-image-set-active-layer image text-layer)
	(set! tint-layer (car (gimp-layer-new image width height RGBA-IMAGE "Tint" 100 LAYER-MODE-GRAIN-MERGE-LEGACY)))
    (gimp-image-insert-layer image tint-layer 0 -1)
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
		(cond
	((= col-pat 1) 
	(gimp-context-set-pattern pattern)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN))
	((= col-pat 2) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-context-set-paint-mode LAYER-MODE-LIGHTEN-ONLY-LEGACY  )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 3) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-context-set-paint-mode LAYER-MODE-OVERLAY  )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 4) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-context-set-paint-mode LAYER-MODE-MULTIPLY-LEGACY )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 5) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-drawable-desaturate tint-layer DESATURATE-LIGHTNESS)
	(gimp-context-set-paint-mode LAYER-MODE-LIGHTEN-ONLY-LEGACY  )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 6) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-drawable-desaturate tint-layer DESATURATE-LIGHTNESS)
	(gimp-context-set-paint-mode LAYER-MODE-OVERLAY  )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	((= col-pat 7) 
	(gimp-context-set-pattern pattern)
	(gimp-drawable-edit-fill tint-layer FILL-PATTERN)
	(gimp-drawable-desaturate tint-layer DESATURATE-LIGHTNESS)
	(gimp-context-set-paint-mode LAYER-MODE-MULTIPLY-LEGACY )
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	)
	)
	(gimp-selection-none image)	

;;;;create the glass effect	
	(if (= Material 1) (gimp-drawable-curves-spline text-layer 0 18 #(0 1 0.11764 0 0.25490 1 0.37254 0 0.49019 1 0.62745 0 0.74509 1 0.87058 0 1 1)));max

;;: change opacity alpha
;(if (> 100 opacity) (gimp-message "oh no") (gimp-layer-set-opacity text-layer opacity) );max
;(cond (< opacity 99) (gimp-message "oh no2") (gimp-layer-set-opacity tint-layer opacity))
(cond ((< opacity 100) 
(gimp-layer-set-opacity text-layer opacity )
(gimp-layer-set-opacity tint-layer opacity ))
)
;;;;finish the script	
	(if (= conserve FALSE) (begin
	(set! text-layer (car (gimp-image-merge-down image tint-layer EXPAND-AS-NECESSARY)))
	(gimp-drawable-hue-saturation text-layer 0 0 0 26 50)
	(gimp-image-remove-layer image bump-layer)))
	(if (= drop-shadow TRUE) (script-fu-drop-shadow image text-layer 8 8 15 '(0 0 0) (- opacity 20) TRUE))
    (gimp-image-select-item image 2 selection-channel)	
	
	(if (= conserve FALSE) (begin
	(if (> bkg-type 0) (set! layer-name (car (gimp-item-get-name bkg-layer)))) 
	(set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
	(gimp-item-set-name text-layer layer-name)
	(if (= bkg-type 4) (begin
	(set! name-string (string-append (car (gimp-item-get-name text-layer)) "- Gradient " random_gradient "- Shape " gradient-type-name))	
	(gimp-item-set-name text-layer name-string)))))
	(if (= keep-selection FALSE) (gimp-selection-none image))
	(gimp-image-remove-channel image selection-channel)
	(if (and (= conserve FALSE) (= alpha FALSE) (gimp-layer-flatten text-layer)))	

	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(script-fu-register "script-fu-plastic-or-glass"        		    
  "Plastic or Glass alpha 299"
  "Script works from 'transparent background' or 'selection'"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Oct 2012"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
    SF-OPTION "Fill type" '("Color" "Pattern" "Pattern+Color LIGHTEN ONLY" "Pattern+Color OVERLAY" "Pattern+Color MULTIPLY" "Pattern Desaturate +Color LIGHTEN ONLY" "Pattern Desaturate+Color OVERLAY" "Pattern Desaturate+Color MULTIPLY")
  SF-COLOR      "Tint Color"         '(0 0 255)
  SF-PATTERN		"Tint Pattern"				"Burlwood"
  SF-OPTION "Material Type" '("Plastic" "Glass")
  SF-ADJUSTMENT "Opacity" '(100 20 100 1 1 1 0)
  SF-OPTION     "Background Type" '( "None" "Pattern" "Color" "Gradient" "Random Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         '(153 153 153)
  SF-GRADIENT   "Background Gradient" "Burning Transparency"
  SF-OPTION     "Gradient Shape if Bkg-type=gradient" '("GRADIENT-SHAPEBURST-ANGULAR" "GRADIENT-SHAPEBURST-SPHERICAL" "GRADIENT-SHAPEBURST-DIMPLED")
  SF-ADJUSTMENT "Bump Blur" '(30 10 100 1 10 0 0)
  SF-TOGGLE     "Apply Drop Shadow"   TRUE
  SF-TOGGLE     "Keep selection"          FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
)

(script-fu-menu-register "script-fu-plastic-or-glass" "<Image>/Script-Fu/Alpha-to-Logo/")
