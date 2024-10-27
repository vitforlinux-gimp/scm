; Wire Text rel 0.03
; Created by Graechan
;
;    Created from this video tutorial at http://www.youtube.com/watch?v=N-3YuZlZn7Q&feature=related
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
; Rel 0.02 - Added multi-line text with justification and spacing
;            Changed ellipse to circular bkg to fit multi-line text
;            Added choice to add bkg to image only
; Rel oo3 - Replaced the ellipse shape
; Rel 004 / 299 update code for gimp 2.99 and 2.10 compat off

;ここはTosi様のscript-fuを使用しました。
;http://www.geocities.jp/gimproject/scripts/layers-view-delete.html

(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))


(define (apply-wire-art-299-chrome-logo-effect img
                                  logo-layer
                                  offsets
                                  bg-color)
  (let* (
        (offx1 (* offsets 0.4))
        (offy1 (* offsets 0.3))
        (offx2 (* offsets (- 0.4)))
        (offy2 (* offsets (- 0.3)))
        (feather (* offsets 0.5))
        (width (car (gimp-drawable-get-width logo-layer)))
        (height (car (gimp-drawable-get-height logo-layer)))
        (layer1 (car (gimp-layer-new img width height RGBA-IMAGE "Layer 1" 100 LAYER-MODE-DIFFERENCE-LEGACY)))
        (layer2 (car (gimp-layer-new img width height RGBA-IMAGE "Layer 2" 100 LAYER-MODE-DIFFERENCE-LEGACY)))
        (layer3 (car (gimp-layer-new img width height RGBA-IMAGE "Layer 3" 100 LAYER-MODE-NORMAL-LEGACY)))
        (shadow (car (gimp-layer-new img width height RGBA-IMAGE "Drop Shadow" 100 LAYER-MODE-NORMAL-LEGACY)))
        (background (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
        (layer-mask (car (gimp-layer-create-mask layer1 ADD-MASK-BLACK)))
        )

    (gimp-context-push)
    (gimp-context-set-defaults)
    (gimp-context-set-paint-mode 0)

    (script-fu-util-image-resize-from-layer img logo-layer)
    (script-fu-util-image-add-layers img layer1 layer2 layer3 shadow background)
    (gimp-context-set-background '(255 255 255))
    (gimp-selection-none img)
    (gimp-drawable-edit-fill layer1 FILL-BACKGROUND)
    (gimp-drawable-edit-fill layer2 FILL-BACKGROUND)
    (gimp-drawable-edit-fill layer3 FILL-BACKGROUND)
    (gimp-drawable-edit-clear shadow)
    (gimp-image-select-item img CHANNEL-OP-REPLACE logo-layer)
    (gimp-item-set-visible logo-layer FALSE)
    (gimp-item-set-visible shadow FALSE)
    (gimp-item-set-visible background FALSE)
    (gimp-context-set-background '(0 0 0))
    (gimp-drawable-edit-fill layer1 FILL-BACKGROUND)
    (gimp-selection-translate img offx1 offy1)
    (gimp-selection-feather img feather)
    (gimp-drawable-edit-fill layer2 FILL-BACKGROUND)
    (gimp-selection-translate img (* 2 offx2) (* 2 offy2))
    (gimp-drawable-edit-fill layer3 FILL-BACKGROUND)
    (gimp-selection-none img)
    (set! layer1 (car (gimp-image-merge-visible-layers img CLIP-TO-IMAGE)))
    ; if the original image contained more than one visible layer:
    (while (> (car (gimp-image-get-item-position img layer1))
              (car (gimp-image-get-item-position img shadow)))
      (gimp-image-raise-item img layer1)
    )
    (gimp-drawable-invert layer1 FALSE)
    (gimp-layer-add-mask layer1 layer-mask)
    (gimp-image-select-item img CHANNEL-OP-REPLACE logo-layer)
    (gimp-context-set-background '(255 255 255))
    (gimp-selection-feather img feather)
    (gimp-drawable-edit-fill layer-mask FILL-BACKGROUND)
    (gimp-context-set-background '(0 0 0))
    (gimp-selection-translate img offx1 offy1)
    (gimp-drawable-edit-fill shadow FILL-BACKGROUND); qui
    (gimp-selection-none img)
    (gimp-context-set-background bg-color)
    (gimp-drawable-edit-fill background FILL-BACKGROUND)
    (gimp-item-set-visible shadow TRUE)
    (gimp-item-set-visible background TRUE)
    (gimp-item-set-name layer1 (car (gimp-item-get-name logo-layer)))
    (gimp-image-remove-layer img logo-layer)

    (gimp-context-pop)
  )
)

(define (script-fu-layers-view-none image drawable)
 (let* ((layers (gimp-image-get-layers image))
	    (number-layers (car layers))
	    (layer-array (cadr layers))
	    (layer-count 0)
	    (layer))
    (set! layer-count 0)
    (while (< layer-count number-layers)
           (set! layer (vector-ref layer-array layer-count))
           (gimp-item-set-visible layer FALSE)
           (set! layer-count (+ layer-count 1)))
))
(define (script-fu-layers-view-current-only image drawable)
    (script-fu-layers-view-none image drawable)
    (if (not (= 0 (car (gimp-item-id-is-layer drawable))))
        (gimp-item-set-visible drawable TRUE))
)
(define (script-fu-layers-delete-hidden image drawable)
 (let* ((layers (gimp-image-get-layers image))
	    (number-layers (car layers))
	    (layer-array (cadr layers))
	    (layer-count 0)
	    (layer))
    (gimp-image-undo-group-start image)
    (set! layer-count 0)
    (while (< layer-count number-layers)
           (set! layer (vector-ref layer-array layer-count))
           (if (= (car (gimp-item-get-visible layer)) FALSE)
               (gimp-image-remove-layer image layer))
           (set! layer-count (+ layer-count 1)))
    (gimp-image-undo-group-end image)
    (gimp-displays-flush)))

(define (script-fu-wire-art-299-text text
				just
				lspace
				space 
				font-in 
				font-size 
				grow
				shape 
				grid-type
				glid-size
				grid-wire-size
				wire-size 
				metal 
				metal-text 
				tint-color 
				bkg-color 
				bkg-crop)
                                 
  (let* (
         (img-width 250)
	 (img-height 250)
	 (width img-width)
         (height img-height)
         (image (car (gimp-image-new img-width img-height RGB)))
         (border (/ font-size 3))
		 (font font-in)
         (text-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (text-width (car (gimp-drawable-get-width text-layer)))
         (text-height (car (gimp-drawable-get-height text-layer)))
	 (old-fg (car (gimp-context-get-foreground)))
         (old-bg (car (gimp-context-get-background)))
         )

	(gimp-image-undo-disable image)

    (gimp-context-push)
 (gimp-context-set-paint-mode 0)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))    
    
;;;;position the text lines
;;;;;	(if (= just 0) (gimp-text-layer-set-justification text-layer 2))	;none 2.4
	;change 2.4

    (if (= just 0) (gimp-text-layer-set-justification text-layer 2))			;change 2.4
    (if (= just 1) (gimp-text-layer-set-justification text-layer 0))
    (if (= just 2) (gimp-text-layer-set-justification text-layer 1))


;;;;;	(gimp-text-layer-set-letter-spacing text-layer (/ font-size 12))	;none 2.4
	(gimp-text-layer-set-line-spacing text-layer space)			;none 2.4
	(gimp-text-layer-set-letter-spacing text-layer lspace)			;none 2.4
;;;;;	(gimp-text-layer-set-letter-spacing text-layer (/ font-size 12))	;none 2.4
	(set! text-width (car (gimp-drawable-get-width text-layer)))
    (set! text-height (car (gimp-drawable-get-height text-layer)))
(gimp-context-set-paint-mode 0)
(script-fu-wire-art-299-textcore image img-width img-height text-layer text-width text-height
				grow
				shape 
				grid-type
				glid-size
				grid-wire-size
				wire-size 
				metal 
				metal-text 
				tint-color 
				bkg-color 
				bkg-crop)

    (gimp-context-set-foreground old-fg)
    (gimp-context-set-background old-bg)
    (gimp-context-pop)

	(gimp-image-undo-enable image)

    (gimp-display-new image)
	
    )
  )
  
(script-fu-register "script-fu-wire-art-299-text"
  "Wire Art Text 299"
  "Creates text made fom wire"
  "Graechan"
  "Graechan"
  "June 2012"
  ""
  SF-TEXT	"Text"			"Wire\nArt\nText" 
  SF-OPTION	"Justification"		'("Centre" "Left" "Right")
  SF-ADJUSTMENT	"Letter Spacing (pixels)"	'(0 -100 100 1 10 0 0)
  SF-ADJUSTMENT	"Line Spacing (pixels)"	'(0 -100 100 1 10 0 0)
  SF-FONT	"Font"			"QTArnieB"
  SF-ADJUSTMENT	"Font size (pixels)"	'(180 6 1000 1 1 0 0)
  SF-ADJUSTMENT	"Expand / Shrink the Font if needed"	'(3 -20 20 1 1 0 0)
  SF-OPTION	"Image Shape"		'("Rectangular" "Ellipse" "Circular")
  SF-OPTION	"Grid Type"			'("Squared" "Exagonal" "None" "Randomized")
  SF-ADJUSTMENT	"Grid Size (pixels)"	'(16 3 500 1 1 0 0)
   SF-ADJUSTMENT	"Grid Wire Size (pixels)"	'(3 1 15 1 1 0 0)
  SF-ADJUSTMENT	"Wire Size (pixels)"	'(5 1 25 1 1 0 0)
  SF-OPTION	"Metal Plating Type"	'("Chrome" "Gold" "Silver" "Copper" "Bronze" "Colored Tint")
  SF-TOGGLE	"Plate the Text only"	FALSE
  SF-COLOR	"Tint Color"		'(0 0 255)
;;;  SF-COLOR	"Background color"	"lightgrey"		;none 2.4
  SF-COLOR	"Background color"	'(180 180 180)		;change 2.4
  SF-TOGGLE	"Bacground to Image only"	FALSE  
  )
    (script-fu-menu-register
	"script-fu-wire-art-299-text"
	"<Image>/Script-Fu/Logos/"
)

(define (script-fu-wire-art-299-textimg img t-layer
				grow
				shape 
				grid-type
				glid-size
				grid-wire-size
				wire-size 
				metal 
				metal-text 
				tint-color 
				bkg-color 
				bkg-crop)

  (let* (
         (img-width 250)
	 (img-height 250)
	 (width img-width)
         (height img-height)
         (text-width (car (gimp-drawable-get-width t-layer)))
         (text-height (car (gimp-drawable-get-height t-layer)))
	 (old-fg (car (gimp-context-get-foreground)))
         (old-bg (car (gimp-context-get-background)))
         )
(gimp-context-set-paint-mode 0)
(script-fu-wire-art-299-textcore img img-width img-height t-layer text-width text-height
				grow
				shape 
				grid-type
				glid-size
				grid-wire-size
				wire-size 
				metal 
				metal-text 
				tint-color 
				bkg-color 
				bkg-crop)
    (gimp-context-set-foreground old-fg)
    (gimp-context-set-background old-bg)
)
)

;画像加工本体
(define (script-fu-wire-art-299-textimgh img t-layer
				grow
				shape 
				grid-type
				glid-size
				grid-wire-size
				wire-size 
				metal 
				metal-text 
				tint-color 
				bkg-color 
				bkg-crop)
  (let* (
	(img2 (car (gimp-image-duplicate img)))
	(drawable2 7) ; qui!!!
	)
	
	(gimp-image-undo-disable img2)
	(set! drawable2 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
				 (car (gimp-image-get-active-drawable img2))
				(vector-ref (car (gimp-image-get-selected-drawables img2)) 0)
				))
	(script-fu-layers-view-current-only img2 drawable2)	;Tosi様のscript-fuより
	(script-fu-layers-delete-hidden img2 drawable2)		;Tosi様のscript-fuより

	(script-fu-wire-art-299-textimg img2 drawable2
				grow
				shape 
				grid-type
				glid-size
				grid-wire-size
				wire-size 
				metal 
				metal-text 
				tint-color 
				bkg-color 
				bkg-crop)

	(gimp-image-undo-enable img2)
	(gimp-display-new img2)
  )
)

(script-fu-register "script-fu-wire-art-299-textimgh"
  "Wire Art Image 299"
  "Creates text made fom wire"
  "Graechan"
  "Graechan"
  "June 2012"
  ""
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-ADJUSTMENT	"Expand/Shrink if needed"	'(3 0 20 1 1 0 1)
  SF-OPTION	"Image Shape"		'("Rectangular" "Ellipse" "Circular")
  SF-OPTION	"Grid Type"			'("Squared" "Exagonal" "None" "Randomized")
  SF-ADJUSTMENT	"Grid Size (pixels)"	'(16 3 500 1 1 0 0)
  SF-ADJUSTMENT	"Grid Wire Size (pixels)"	'(3 1 15 1 1 0 0)
  SF-ADJUSTMENT	"Wire Size (pixels)"	'(5 1 25 1 1 0 0)
  SF-OPTION	"Metal Plating Type"	'("Chrome" "Gold" "Silver" "Copper" "Bronze" "Colored Tint")
  SF-TOGGLE	"Plate the Text only"	FALSE
  SF-COLOR	"Tint Color"		'(0 0 255)
;;;  SF-COLOR	"Background color"	"lightgrey"		;none 2.4
  SF-COLOR	"Background color"	'(180 180 180)		;change 2.4
  SF-TOGGLE	"Background to Image only"	FALSE  
  )
  (script-fu-menu-register
	"script-fu-wire-art-299-textimgh"
	"<Image>/Script-Fu/Alpha-to-Logo/"
)

(define (script-fu-wire-art-299-textcore image img-width img-height text-layer text-width text-height
				grow
				shape 
				grid-type
				glid-size
				grid-wire-size
				wire-size 
				metal 
				metal-text 
				tint-color 
				bkg-color 
				bkg-crop)
(let* (	(bkg-layer 0)
	(selection-channel 0)
	(img-channel 0)
         (tint-layer 0)
	 (width img-width)			;add
         (height img-height)			;add
         (offx 0)			;add 2.4
         (offy 0)			;add 2.4
	)

;;;;set the new Image size
(gimp-context-set-paint-mode 0)
	(if (> text-width img-width) (set! width text-width))
    (if (> text-height img-height) (set! height text-height))

;;;;square up the Image if needed
	(if (= shape 2) 
	(begin
    (if (< height width) (set! height width))
	(if (< width height) (set! width height))))
	
;;;;resize the image	
	(gimp-image-resize image width height 0 0)

;;;;centre the text layer	
    (set! offx (/ (- width text-width) 2))
    (set! offy (/ (- height text-height) 2))
    (gimp-layer-set-offsets text-layer offx offy)

;;;;Expand the font if needed
    (if (> grow 0)
           (begin
    (gimp-image-select-item image 2  text-layer)
    (gimp-drawable-edit-clear text-layer)
    (gimp-selection-grow image grow)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
    (gimp-selection-none image)
           )
    )	
        (if (< grow 0)
           (begin
    (gimp-image-select-item image 2  text-layer)
    (gimp-drawable-edit-clear text-layer)
    (gimp-selection-shrink image (- grow))
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
    (gimp-selection-none image)
           )
    )
 
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer image bkg-layer 0 1)
	(gimp-drawable-edit-clear bkg-layer)			;add 2.4
	
	;(if (> shape 0) (gimp-ellipse-select image 0 0 (- width 5) (- height 5) 2 TRUE FALSE 0))
	(if (> shape 0) (gimp-image-select-ellipse image 2 0 0 (- width 5) (- height 5)))
	(if (= shape 0) 
	(begin
	(gimp-selection-all image)
	(gimp-selection-shrink image 10)
	(script-fu-selection-rounded-rectangle image bkg-layer 50 FALSE)
	)
	)

;;;;create channel
	(gimp-selection-save image)
	;(set! selection-channel (car (gimp-image-get-active-drawable image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! selection-channel (vector-ref (car (gimp-image-get-selected-drawables image)) 0))	)
(else (set! selection-channel (car (gimp-image-get-active-drawable image)))
	)	)
	(gimp-channel-set-opacity selection-channel 100)	
	(gimp-item-set-name selection-channel "Shape Selection")
	;(gimp-image-set-active-layer image bkg-layer)
	(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image (vector bkg-layer)))
(else (gimp-image-set-active-layer image bkg-layer))
) 
	
	(gimp-drawable-edit-fill bkg-layer FILL-FOREGROUND)
	(gimp-selection-shrink image wire-size)
	(gimp-drawable-edit-clear bkg-layer)
	
	;(if (= TRUE grid-type) (plug-in-grid 1 image bkg-layer 2 glid-size 8 '(0 0 0) 255 2 glid-size 8 '(0 0 0) 255 0 2 6 '(0 0 0) 255))
	(if (= 0 grid-type) (plug-in-mosaic 1 image bkg-layer glid-size 1 grid-wire-size 1 0 135 0 1 0 0 0 1 ))
	(if (= 1 grid-type) (plug-in-mosaic 1 image bkg-layer glid-size 1 grid-wire-size 1 0 135 0 1 0 1 0 1 ))
	(if (= 3 grid-type) (plug-in-mosaic 1 image bkg-layer glid-size 1 grid-wire-size 0.5 0 135 0 1 0 1 0 1 ))
	(gimp-image-select-item image 2  text-layer)
;;;;create channel
	(gimp-selection-save image)
	;(set! img-channel (car (gimp-image-get-active-drawable image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! img-channel (vector-ref (car (gimp-image-get-selected-drawables image)) 0))	)
(else (set! img-channel (car (gimp-image-get-active-drawable image)))
	)	)
	(gimp-channel-set-opacity img-channel 100)	
	(gimp-item-set-name img-channel "img-channel")
	;(gimp-image-set-active-layer image text-layer)
	(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image (vector text-layer)))
(else (gimp-image-set-active-layer image text-layer))
) 	
    (gimp-selection-shrink image wire-size)
	(set! text-layer (car (gimp-image-merge-down image text-layer EXPAND-AS-NECESSARY)))
	(gimp-item-set-name text-layer "Wire Text")
	(gimp-drawable-edit-clear text-layer)
    (gimp-selection-none image)

	;(script-fu-chrome-logo-alpha image text-layer 10 bkg-color)
	(apply-wire-art-299-chrome-logo-effect image text-layer 10 bkg-color)
	
	
	
	(if (= metal 1) (gimp-context-set-foreground '(255 215 0)));gold 	
    (if (= metal 2) (gimp-context-set-foreground '(192 192 192)));silver	
    (if (= metal 3) (gimp-context-set-foreground '(250 180 150)));copper
    (if (= metal 4) (gimp-context-set-foreground '(166 125 61)));bronze
    (if (= metal 5) (gimp-context-set-foreground tint-color));colored tint
    (if (> metal 0)
    (begin 
	(set! tint-layer (car (gimp-layer-new image width height RGBA-IMAGE "Tint" 100 LAYER-MODE-MULTIPLY-LEGACY)))
    (gimp-image-insert-layer image tint-layer 0 -1)
    (if (= metal-text TRUE) (gimp-image-select-item image 2  img-channel))	
	(gimp-drawable-edit-fill tint-layer FILL-FOREGROUND)
	(set! text-layer (car (gimp-image-merge-down image tint-layer CLIP-TO-IMAGE)))
	(if (< metal 5) (gimp-drawable-brightness-contrast text-layer 0.25 0.25))
	(gimp-selection-none image)
	)
	)
	(if (= metal 0)
    (begin 
	(set! tint-layer (car (gimp-layer-new image width height RGBA-IMAGE "Tint" 100 LAYER-MODE-MULTIPLY-LEGACY)))
    (gimp-image-insert-layer image tint-layer 0 -1)
    (gimp-drawable-edit-clear tint-layer)				;add 2.4
	(set! text-layer (car (gimp-image-merge-down image tint-layer CLIP-TO-IMAGE)))
	)
	)
	(set! text-layer (car (gimp-image-merge-down image text-layer EXPAND-AS-NECESSARY)))
	(gimp-item-set-name text-layer "Wire Text")
	
	(plug-in-autocrop 1 image text-layer)
	
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Tint" 100 LAYER-MODE-MULTIPLY-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 1)
    (gimp-drawable-edit-clear bkg-layer)				;add 2.4
	(set! bkg-layer (car (gimp-image-merge-down image bkg-layer CLIP-TO-IMAGE)))
	
	(if (= bkg-crop TRUE)
	(begin
	(gimp-image-select-item image 2  selection-channel)
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear bkg-layer)
    (gimp-selection-none image)))
	(gimp-image-select-item image 2  img-channel)
	(gimp-context-set-foreground bkg-color)
    (gimp-drawable-edit-fill bkg-layer FILL-FOREGROUND)
    (gimp-selection-none image)
)
)


