;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; Fur rel 0.04
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
; Rel 0.02 - Changed text in gimpressionist to "Furry" instead of "furry"
; Rel 0.03 - Added option to use the existing colors and a softness setting
; Rel 0.03.3 - Bugfixes to the script
; Rel 0.04 - improved the output image appearance
; Rel 299 - Compat OFF 2.10 and works in 2.99.16
; Rel 300 - Gimp 2.10 and 3.0 rc1
 
;Fix code for 2.99.6 work in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))
;Fix code for 2.10 work in 2.99.12
;(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image 1 (vector drawable)))))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		(define (apply-gauss img drawable x y)(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
      (plug-in-gauss  1  img drawable x y 0)
 (plug-in-gauss  1  img drawable (* x 0.32) (* y 0.32) 0)  )))

(define (script-fu-furry-300-logo 
                                      img-width
                                      img-height
                                      text
					justification
									  letter-spacing
									  line-spacing
					grow-text
					outline
									  font-in 
                                      font-size
									  tint-color
									  motle-color
									  motle-size
							          motle
									  blur-radius
                                      bkg-type 
                                      pattern
                                      bkg-color
									  gradient
									  conserve)
									  
  (let* ((width img-width)
         (height img-height)
         (offx 0)
         (offy 0)
         (image (car (gimp-image-new img-width img-height RGB)))
         (border (/ font-size 3))
		 (font  font-in )
         (layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (text-width (car (gimp-drawable-get-width layer)))
         (text-height (car (gimp-drawable-get-height layer)))
		 (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
		 (final-width 0)
		 (final-height 0)
		 (bkg-layer 0))
		 
    (gimp-context-push)
    (gimp-context-set-paint-mode 0)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
;;;;Adjust the text on line
	(gimp-text-layer-set-justification layer justification)
	(gimp-text-layer-set-letter-spacing layer letter-spacing)
	(gimp-text-layer-set-line-spacing layer line-spacing)
	(set! text-width (car (gimp-drawable-get-width layer)))
    (set! text-height (car (gimp-drawable-get-height layer)))
	
;;;;set the new Image size
	(if (> text-width img-width) (set! width text-width))           
    (if (> text-height img-height) (set! height text-height))
	(set! final-width width)
	(set! final-height height)

;;;;resize the image	
	(gimp-image-resize image width height 0 0)

;;;;centre the text layer	
    (set! offx (/ (- width text-width) 2))
    (set! offy (/ (- height text-height) 2))    
    (gimp-layer-set-offsets layer offx offy)	

;;;;set the text clolor    
    (gimp-image-select-item image 2 layer)
	(gimp-drawable-edit-fill layer FILL-FOREGROUND)
	(gimp-selection-none image)
;;;;;; SHRINK/GROW text
(cond ((> grow-text 0)
	(gimp-selection-none image)
	(gimp-image-select-item image 2 layer)
	(gimp-selection-grow image (round grow-text))   
	(gimp-drawable-edit-fill layer FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none image)
	(gimp-image-select-item image 2 layer)
	(gimp-drawable-edit-clear layer)
	(gimp-selection-shrink image (- grow-text))   
	(gimp-drawable-edit-fill layer FILL-FOREGROUND)	
 ))

 ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none image)
	(gimp-image-select-item image 2 layer)
	(gimp-selection-shrink image (round outline))   
	(gimp-drawable-edit-clear layer)
	(gimp-image-select-item image 2 layer)
 ))

;;;;create the fur	
    (script-fu-furry-300 image layer 0 tint-color motle-color motle-size motle blur-radius FALSE TRUE)
;	(set! layer (car (gimp-image-get-active-layer image)))	
    	
;;;;create the background layer    
	(if (> bkg-type 0) (begin
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (if (= conserve FALSE) (begin
	(gimp-image-insert-layer image bkg-layer 0 (+ (car (gimp-image-get-item-position image layer )) 1)))
	(gimp-image-insert-layer image bkg-layer 0 (+ (car (gimp-image-get-item-position image layer )) 2)))
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 1) (gimp-drawable-fill bkg-layer FILL-PATTERN))		
    (if (= bkg-type 3) (gimp-drawable-fill bkg-layer FILL-BACKGROUND))	
    (if (= bkg-type 2) ;(gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY  GRADIENT-LINEAR 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 width height)
(gimp-drawable-edit-gradient-fill bkg-layer  GRADIENT-LINEAR 0 0 1 0 0 0 0 width height) ; Fill with gradient

)));; GRADIENT-LINEAR ; GRADIENT-CONICAL-SYMMETRIC
              
    ;(gimp-image-set-active-layer image layer)
        (cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image (vector layer)))
(else (gimp-image-set-active-layer image layer)))
	(gimp-layer-resize-to-image-size layer)
	
;;;;tidy the layers
    (if (= conserve FALSE) (gimp-image-remove-layer image layer))
    (if (and (= conserve FALSE) (> bkg-type 0)) (set! layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY))))	
	;(gimp-item-set-name (car (gimp-image-get-active-layer image)) text)
    
	(gimp-context-pop)
    (gimp-display-new image)
	
    )
  )
  
(script-fu-register "script-fu-furry-300-logo"
  "Furry 300 LOGO"
  "Create a Fur covered Logo"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "May 2013"
  ""
  SF-ADJUSTMENT "Image width (pixels)" '(250 1 1000 1 10 0 1)
  SF-ADJUSTMENT "Image height(pixels)" '(250 1 1000 1 10 0 1)
  SF-TEXT       "Text"    "Furry\nLogo"
  SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill")
  SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
  SF-ADJUSTMENT _"Outline"          '(0 0 40 1 10 0 0)
  SF-FONT       "Font"               "QTDoghausHeavy"
  SF-ADJUSTMENT "Font size (pixels)" '(350 6 500 1 1 0 1)
  SF-COLOR      "Tint color"         '(107 57 0)
  SF-COLOR      "Motle color"         '(82 43 0)
  SF-ADJUSTMENT "Motle Size" '(1 1 16 .1 1 1 0)
  SF-ADJUSTMENT "Motle Amount" '(120 0 250 1 10 0 0)
  SF-ADJUSTMENT "Softness" '(15 0 60 1 5 0 0)
  SF-OPTION "Background Type" '("None" "Pattern" "Gradient" "Color")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Gray"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-TOGGLE     "Keep the Layers"   FALSE  
  )
(script-fu-menu-register "script-fu-furry-300-logo" "<Image>/Script-Fu/Logos")


(define (script-fu-furry-300 image layer
                               fur-color
							   tint-color
							   motle-color
							   motle-size
							   motle
							   blur-radius
							   keep-selection-in
							   conserve)
	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (gimp-image-undo-group-start image)
	

 (let* (
            (width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(fur-layer 0)
			(final-width width)
			(final-height height)
			(area (* 1000 1000))
			(alpha (car (gimp-drawable-has-alpha layer)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (car (gimp-item-get-name layer)))
		    (keep-selection keep-selection-in)
			(selection 0)
			(motle-selection 0)
			
        )
		
	(gimp-context-set-default-colors)

	;;;;scale image to given area if required	
	(gimp-image-scale image 
		(max 1 (min 262144 (round (* width (sqrt (/ area (* width height)))))))
		(max 1 (min 262144 (round (* height (sqrt (/ area (* width height))))))))
	(set! width (car (gimp-image-get-width image)))
	(set! height (car (gimp-image-get-height image)))
	
	
	(if (= alpha FALSE) (gimp-layer-add-alpha layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (set! keep-selection FALSE))
	(if (= sel TRUE) (gimp-image-select-item image 2 layer))
	
	 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)	
	(script-fu-distress-selection image 
	                            layer
								  127       ;Threshold (bigger 1<-->255 smaller)
								  8         ;Spread (8 0 1000 1 10 0 1)
								  4         ;Granularity (1 is low) (4 1 25 1 10 0 1)
								  2         ;Smooth (2 1 150 1 10 0 1)
								  TRUE      ;Smooth horizontally TRUE
								  TRUE)     ;Smooth vertically TRUE
		(script-fu-distress-selection image 
	                             (vector layer )
								  0.5       ;Threshold (bigger 1<-->255 smaller)
								  8         ;Spread (8 0 1000 1 10 0 1)
								  4         ;Granularity (1 is low) (4 1 25 1 10 0 1)
								  2         ;Smooth (2 1 150 1 10 0 1)
								  TRUE      ;Smooth horizontally TRUE
								  TRUE)     ;Smooth vertically TRUE
	)
;;;;create selection-channel (gimp-image-select-item image 2 selection)    
	(set! selection (car (gimp-selection-save image)))	
    ;(gimp-image-set-active-layer image layer)	
            (cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image (vector layer)))
(else (gimp-image-set-active-layer image layer)))
	
;;;;begin the script
;;;;create the fur layer	
	(if (= fur-color 0) (begin ;use new colors
	(set! fur-layer (car (gimp-layer-new image width height RGBA-IMAGE "Fur" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer image fur-layer 0(car (gimp-image-get-item-position image layer )))
	(gimp-drawable-edit-fill fur-layer FILL-BACKGROUND)
	(gimp-image-select-item image 2 fur-layer)
	(plug-in-solid-noise RUN-NONINTERACTIVE image fur-layer 0 0 0 1 (- 17 motle-size) (- 17 motle-size))
	(gimp-drawable-threshold fur-layer 0 ( / motle 255) 1)
	(if (> motle 35) (begin
	;(gimp-by-color-select fur-layer '(0 0 0) 15 2 TRUE FALSE 0 FALSE)
	(gimp-image-select-color image 2 fur-layer '(0 0 0))
	
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)	
	(script-fu-distress-selection image 
	                             layer
								  127       ;Threshold (bigger 1<-->255 smaller)
								  8         ;Spread (8 0 1000 1 10 0 1)
								  4         ;Granularity (1 is low) (4 1 25 1 10 0 1)
								  2         ;Smooth (2 1 150 1 10 0 1)
								  TRUE      ;Smooth horizontally TRUE
								  TRUE)     ;Smooth vertically TRUE
	(gimp-selection-feather image blur-radius)
		(script-fu-distress-selection image 
	                             (vector layer )
								  0.5       ;Threshold (bigger 1<-->255 smaller)
								  8         ;Spread (8 0 1000 1 10 0 1)
								  4         ;Granularity (1 is low) (4 1 25 1 10 0 1)
								  2         ;Smooth (2 1 150 1 10 0 1)
								  TRUE      ;Smooth horizontally TRUE
								  TRUE)     ;Smooth vertically TRUE
								  )
	(gimp-selection-feather image blur-radius)
	
;;;;create motle-selection-channel (gimp-image-select-item image 2 motle-selection)    
	(set! motle-selection (car (gimp-selection-save image)))))	
    (gimp-image-select-item image 2 selection)							  
	(gimp-context-set-foreground tint-color)
	(gimp-drawable-edit-fill fur-layer FILL-FOREGROUND)
	
	(if (> motle 35) (begin
	(gimp-image-select-item image 2 motle-selection)
	(gimp-context-set-foreground motle-color)
	(gimp-drawable-edit-fill fur-layer FILL-FOREGROUND)
	(gimp-image-remove-channel image motle-selection)))
	(gimp-selection-none image)))
	
(if (= fur-color 1) (begin ;use existing colors
	(set! fur-layer (car (gimp-layer-copy layer 0)))
	(gimp-image-insert-layer image fur-layer 0 (car (gimp-image-get-item-position image layer )))
	(gimp-selection-none image)))

;;;;clean up the fur-layer ready for gimpressionist	
    (if (= sel FALSE) (begin
	(gimp-image-select-item image 2 layer)
	(gimp-selection-shrink image 1)
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear fur-layer)))
	(gimp-image-select-item image 2 selection)
	(gimp-selection-shrink image 1)
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear fur-layer)
	(gimp-selection-none image)
	
	(if (> blur-radius 0) (apply-gauss image fur-layer blur-radius blur-radius))
	 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)	
	(plug-in-gimpressionist 1 image fur-layer "Furry")
		(plug-in-gimpressionist 1 image (vector fur-layer) "Furry") )
	(gimp-image-select-item image 2 fur-layer)
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear fur-layer)
	(gimp-selection-none image)

;;;;Scale Image to it's original size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-image-scale image final-width final-height )
	(set! width (car (gimp-image-get-width image)))
	(set! height (car (gimp-image-get-height image)))

;;;;finish the script	
	(if (= conserve FALSE) (begin
	(gimp-drawable-edit-clear layer)
	(set! layer (car (gimp-image-merge-down image fur-layer EXPAND-AS-NECESSARY)))))
	;(gimp-image-set-active-layer image layer)
	        (cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image (vector layer)))
(else (gimp-image-set-active-layer image layer)))
    (gimp-item-set-name layer layer-name)
    (if (= keep-selection TRUE) (gimp-image-select-item image 2 selection))
	(gimp-image-remove-channel image selection)
	(if (and (= conserve FALSE) (= alpha FALSE)) (gimp-layer-flatten layer))	

	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(script-fu-register "script-fu-furry-300"        		    
  "Furry 300 ALPHA"
  "creates fur inside a selection or layer"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "May 2013"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-OPTION "Fur Coloring" '("New Colors" "Existing")
  SF-COLOR      "Tint color"         '(107 57 0)
  SF-COLOR      "Motle color"         '(82 43 0)
  SF-ADJUSTMENT "Motle Size" '(1 1 16 .1 1 1 0)
  SF-ADJUSTMENT "Motle Amount" '(120 0 250 1 10 0 0)
  SF-ADJUSTMENT "Softness" '(15 0 60 1 5 0 0)
  SF-TOGGLE     "Keep selection"          FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
)

(script-fu-menu-register "script-fu-furry-300" "<Image>/Script-Fu/Alpha-to-Logo")


