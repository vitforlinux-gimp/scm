; Comix Text Bubble rel 0.05
; Created by Graechan
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
; Rel 0.02 - Added an additional width and height setting to accomodate long text strings
; Rel 0.03 - Changed the script to function on a active drawable and moved to Filters>Decor
; Rel 0.04 - Added extra pointer orientation options and no pointer to pointer type also a blank text box allowed for pictures 
; (just set add-width and add-height to required size)
; Rel 0.05 - Added shape hugging choice to bubble shapes, also added control for outline size 
; Rel 299 - update for Gimp 2.10.22, also compatibility OFF, and 2.99.8 by vitforlinux
; Rel 300 - update for Gimp 2.10.22, also compatibility OFF, and 3.0 rc1 by vitforlinux
;
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))
(cond ((not (defined? 'gimp-text-get-extents-fontname)) (define (gimp-text-get-extents-fontname efn1 efn2 PIXELS efn3) (gimp-text-get-extents-font efn1 efn2 efn3))))

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
  
  (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

(define (script-fu-comix-text-bubble300 image drawable
                                text-in 
                                color 
                                font-in 
                                font-size
								add-width
								add-height
								shape
							    type
							    orientation
							    outline
								outline-color
							    bubble-fill
							    bubble-color
								shadow
							    conserve
							   )
							  

 (let* (
       ; (image-layer (car (gimp-image-get-active-layer image)))
       			(image-layer (if (not (defined? 'gimp-drawable-filter-new))
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
		(offx 0)
        (offy 0)
		(text  text-in )
		(font font-in )
        (width (+ (car (gimp-text-get-extents-fontname text font-size PIXELS font)) (+ (/ font-size 2) add-width)))
		(height (+ (cadr (gimp-text-get-extents-fontname text font-size PIXELS font)) (+ (/ font-size 2) add-height)))
		(border (/ font-size 2))
		(text-layer 0)
        (text-width 0)
        (text-height 0)
        (bkg-layer 0)
		(x 0)
		
        )	
	
	(gimp-context-push)
    (gimp-image-undo-group-start image)
	(gimp-context-set-default-colors)

    (set! text-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
    (set! text-width (car (gimp-drawable-get-width text-layer)))
    (set! text-height (car (gimp-drawable-get-height text-layer)))
	(gimp-item-set-name text-layer "Comix Text")
    	
;;;;centre text on line
	(gimp-text-layer-set-justification text-layer 2)
;;;;set the new layer size
	(if (> text-width width) (set! width text-width))           
    (if (> text-height height) (set! height text-height))	

;;;;resize the image	
	;(gimp-layer-resize text-layer width height 0 0)
	(set! bkg-layer (car (gimp-layer-new-ng image width (+ height (/ height 1.85)) RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 -1 );trick
(gimp-image-lower-item image bkg-layer )

	;;;;centre the text layer	
    (set! offx (/ (- width text-width) 2))
    (set! offy (/ (- height text-height) 2))    
    (gimp-layer-set-offsets text-layer offx offy)
	;(gimp-layer-resize-to-image-size text-layer)
	(set! text-width (car (gimp-drawable-get-width text-layer)))
    (set! text-height (car (gimp-drawable-get-height text-layer)))

;;;;set the text clolor    
    (gimp-context-set-foreground color)
	(gimp-image-select-item image 2 text-layer)
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
	(gimp-selection-none image)		

;;;;begin the script	
	(set! width (car (gimp-drawable-get-width bkg-layer)))
    (set! height (car (gimp-drawable-get-height bkg-layer)))
;;;;create the speach bubble
	(if (= type 0) (begin
	(set! x (- (* width 0.5) (* width 0.2)))
	(gimp-image-select-ellipse image 2 x (* height 0.5) (* width 0.4) (* height 0.4))
	(set! x (- (* width 0.5) (* width 0.2) (* width 1 -0.1)))
	(gimp-image-select-ellipse image 1 x (* height 0.5) (* width 0.4) (* height 0.4))
	(if (or (< orientation 2) (and (> orientation 2) (< orientation 5))) (gimp-selection-translate image (* width 1 0.3) 0))))

;;;;create the thought bubble	
	(if (= type 1) (begin
	(set! x (+ (* width 0.5) (* width -0.025) (* width 1 0.3)))
    (gimp-image-select-ellipse image 2 x (* height 0.85) (* width 0.05) (* height 0.05))
    (set! x (+ (* width 0.5) (* width -0.05) (* width 1 0.2)))
    (gimp-image-select-ellipse image 0 x (* height 0.75) (* width 0.1) (* height 0.1))
    (if (or (= orientation 2) (= orientation 5)) (gimp-selection-translate image (* 1 width -0.3) 0))))   
    
	(if (< type 2) (gimp-drawable-edit-fill bkg-layer FILL-BACKGROUND))
	
;;;;create the bubble shape
	(if (= shape 0) (gimp-image-select-ellipse image 0 0 0 width (+ text-height add-height) ))
	(if (= shape 1) (gimp-image-select-rectangle image 0 0 0 width text-height))
	(if (= shape 2) (gimp-image-select-round-rectangle image 0 0 0 width text-height 50 50))
    (if (< shape 3) (begin	
;;;;create the outline
	(gimp-context-set-foreground outline-color)
	(gimp-drawable-edit-fill bkg-layer FILL-FOREGROUND)
			
;;;;create the bubble fill	
	(if (= bubble-fill TRUE) (begin
	(gimp-selection-shrink image outline)
	(gimp-context-set-background bubble-color)
	(gimp-drawable-edit-fill bkg-layer FILL-BACKGROUND)))))
	
	(gimp-selection-none image)
	
	(if (or (= orientation 0) (= orientation 3)) (gimp-item-transform-flip-simple bkg-layer 0 TRUE 0))
	(if (> orientation 2) (begin
	(gimp-item-transform-flip-simple bkg-layer 1 FALSE (/ text-height 2))
	(gimp-layer-set-offsets bkg-layer 0 0)
	(gimp-layer-set-offsets text-layer (car (gimp-drawable-get-offsets text-layer)) (- height (+ text-height (cadr (gimp-drawable-get-offsets text-layer)))))))
    
	(if (= shape 3) (begin	
	(gimp-image-select-item image 2 text-layer)
	(gimp-selection-grow image border)
	(gimp-drawable-edit-fill bkg-layer FILL-BACKGROUND)	
	(gimp-image-select-item image 2 bkg-layer)

;;;;create the outline
	(gimp-context-set-foreground outline-color)
	(gimp-drawable-edit-fill bkg-layer FILL-FOREGROUND)
			
;;;;create the bubble fill	
	(if (= bubble-fill TRUE) (begin
	(gimp-selection-shrink image outline)
	(gimp-context-set-background bubble-color)
	(gimp-drawable-edit-fill bkg-layer FILL-BACKGROUND)))
	(gimp-selection-none image)))	
	
	(if (= bubble-fill FALSE) (begin
	(gimp-image-select-item image 2 bkg-layer)
	(gimp-selection-shrink image outline)
	(if (= outline 0)  (gimp-selection-shrink image 1))
	(gimp-drawable-edit-clear bkg-layer)
	(gimp-selection-none image)))

;;;;add the drop shadow	
	(if (= shadow TRUE) (begin
	(apply-drop-shadow  image bkg-layer 8 8 15 '(0 0 0) 80 FALSE)))		
	
;;;;finish the script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
    ;(if (and(= shadow TRUE) (= conserve FALSE)) (set! bkg-layer (car (gimp-image-merge-down image bkg-layer CLIP-TO-IMAGE ))))
	(gimp-item-set-name bkg-layer "Comix Bubble")
	(if (= conserve FALSE) (begin 
	(set! text-layer (car (gimp-image-merge-down image text-layer EXPAND-AS-NECESSARY)))
    (gimp-item-set-name text-layer "Comix Text Bubble"))) 
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(script-fu-register "script-fu-comix-text-bubble300"        		    
  "Comix Text Bubble 300"
  "Creates a Text Bubble layer top-left of Image"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Oct 2012"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-TEXT       "Text"    "Comix Text Bubble"
  SF-COLOR      "Text color"         '(0 0 0)
  SF-FONT       "Font"               "QTMagicMarker Medium"
  SF-ADJUSTMENT "Font size (pixels)" '(50 10 500 1 1 0 1)
  SF-ADJUSTMENT "Additional Width (pixels)" '(0 0 1000 1 10 0 1)
  SF-ADJUSTMENT "Additional Height(pixels)" '(0 0 1000 1 10 0 1)
  SF-OPTION     "Bubble Shape" '("Ellipse" "Rectangle" "Rounded Rectangle" "Shape Hugging")
  SF-OPTION     "Ponter Type" '("Speech" "Thought" "None")
  SF-OPTION     "Pointer Orientation" '("Lower-Left" "Lower-Right" "Lower-Centre" "Upper-Left" "Upper-Right" "Upper-Centre")
  SF-ADJUSTMENT "Outline Size(pixels)" '(2 0 6 1 1 0 1)
  SF-COLOR      "Outline Color"         '(0 0 0)
  SF-TOGGLE     "Color the Bubble"   TRUE
  SF-COLOR      "Bubble Color"         '(255 255 255)
  SF-TOGGLE     "Add a Drop Shadow"   FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
)

(script-fu-menu-register "script-fu-comix-text-bubble300" "<Image>/Filters/Decor/")


