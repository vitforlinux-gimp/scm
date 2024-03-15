;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; GIMP - The GNU Image Manipulation Program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
;
; Creates a chiseled-looking text, similar to the Lord of the Rings Logo.
; In order for the effect to look very realistic, the Ringbearer font
; should be installed on your computer.  This font is readily found on the
; web.  But, the effect looks nice with any font.
;
; Just highlight the text layer and run the script, which is found on the 
; Filters Menu > Alpha to Logo > Lord of the Rings....
;
; Script updated on October 3, 2008 to work with GIMP 2.6
; Script updated on April 24 2023 to work with GIMP 2.10.28 by Vitforlinux
;
; Better with Ringbearer medium font https://www.dafont.com/ringbearer.font or https://www.1001fonts.com/ringbearer-font.html
;
; Define the Function

;Fix code for 2.99.6 work in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

(define (script-fu-lotr299-text   image
                               drawable
                               useColor
                               desiredColor
                               blendStyle
			       addShadow
			       offsetX
			       offsetY
			       blurRadius
			       shadowColor
			       opacity
;			       keepBumpMap
        )
  
  ;Declare the Variables
	
	(let* (
        (theSelection 0)
	(bumpMapLayer 0)
	(originalLayer 0)
      (gradientType 0)
      (shadowLayer 0)
	(position 0)
          (old-fg (car (gimp-context-get-foreground)))
          (old-bg (car (gimp-context-get-background)))
      )

; Set up the script so that user settings can be reset after the script is run		

;;;;;  (gimp-context-push)
  
; Start an Undo Group so script can be undone in one step  

  (gimp-image-undo-group-start image)

; Save any active selections to a channel so script can be run on whole layers and then turn off selection

  (set! theSelection (car (gimp-selection-save image)))
  (gimp-selection-none image)

; Set the active layer

;  (gimp-image-set-active-layer image drawable)
  (cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector drawable)))
(else (gimp-image-set-active-layer image drawable))
)

; Assign the bumpMapLayer and originalLayer, add the originalLayer above the bumpMapLayer
; & add the layer name to bumpMapLayer.  Lock the transparency for both layers so that 
; fills will be added only to non-transparent areas.  Alpha to selection was tried for this
; script, but results weren't as good.  The bumpMapLayer and OriginalLayer are linked for
; later movement around the canvas if so desired.

  (set! bumpMapLayer (car (gimp-image-get-active-layer image)))
  (set! originalLayer (car (gimp-layer-copy bumpMapLayer TRUE)))
  (gimp-image-insert-layer image originalLayer 0 -1)
  (gimp-item-set-name bumpMapLayer "Bump Map Layer")

;;;  (gimp-layer-set-lock-alpha originalLayer TRUE)	;none 2.2
;;;  (gimp-layer-set-lock-alpha bumpMapLayer TRUE)	;none 2.2

     (gimp-layer-set-lock-alpha originalLayer TRUE)	;add 2.2
     (gimp-layer-set-lock-alpha bumpMapLayer TRUE)	;add 2.2

  ;(gimp-item-set-linked originalLayer TRUE)
 ; (gimp-item-set-linked bumpMapLayer TRUE)
    
; Set the foreground/background colors

  (gimp-context-set-foreground '(255 255 255))
  (gimp-context-set-background '(0 0 0))

; Assign values to the Blend Style.  See tutorial for example output of each style.  Dimple
; appears to look the best and is set as the default.  Then fill the bumpMapLayer with the
; chosen fill type

  (if (= blendStyle 0)
      (set! gradientType GRADIENT-SHAPEBURST-DIMPLED)
  )
  (if (= blendStyle 1)
      (set! gradientType GRADIENT-SHAPEBURST-ANGULAR)
  )
  (if (= blendStyle 2)
	(set! gradientType GRADIENT-SHAPEBURST-SPHERICAL)
  )
(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
(gimp-context-set-gradient-fg-bg-rgb)
  ;(gimp-edit-blend bumpMapLayer BLEND-FG-BG-RGB LAYER-MODE-NORMAL-LEGACY gradientType 100 0 REPEAT-NONE FALSE TRUE 2 0.2 TRUE 0 0 1 1)
(gimp-drawable-edit-gradient-fill bumpMapLayer gradientType 0 FALSE 1 1 TRUE 0 0 1 1)
; Run the Sharpen plugin twice to enhance chisel effect.

  ;(plug-in-sharpen 1 image bumpMapLayer 50)
  ;(plug-in-sharpen 1 image bumpMapLayer 70)	;changed
  
; Set bumpMapLayer invisible  
  (gimp-item-set-visible bumpMapLayer FALSE)
  
; Set the originalLayer as active

  ;(gimp-image-set-active-layer image originalLayer)
  (cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector originalLayer)))
(else (gimp-image-set-active-layer image originalLayer))
)

; If user decides they want to work with the existing color of the text, the text color is left
; unchanged.  Otherwise, the color selected when the script is first run is set as the foreground
; color and used to fill the originalLayer

  (if (= useColor FALSE)
      (begin
      (gimp-context-set-foreground desiredColor)
      (gimp-drawable-edit-fill originalLayer FILL-FOREGROUND)
      )
  )

  
; The bump map plugin is run using the bumpMapLayer to give the originalLayer its chiseled look
  
  (plug-in-bump-map 1 image originalLayer bumpMapLayer 135 45 5 0 0 0 0 TRUE FALSE 0)

; If the user wants to keep the bumpMapLayer for later use, it will be kept in this step.
; Otherwise, the layer is deleted.  
  
;  (if (= keepBumpMap FALSE)
      (gimp-image-remove-layer image bumpMapLayer)
;  )

; If the user wants to add a drop shadow, the parameters entered in when the script was first
; run are put into the existing GIMP drop shadow script.  

  (if (= addShadow TRUE)
      (script-fu-drop-shadow image originalLayer offsetX offsetY blurRadius shadowColor opacity TRUE)	;changed
  )
 
; Determine the position of the shadowLayer in the stack and link it 
; to the bumpMapLayer and OriginalLayer for later movement around the canvas if so desired.

;;;(set! position (car (gimp-image-get-item-position image originalLayer)))	;none 2.2
(set! shadowLayer (aref (cadr (gimp-image-get-layers image)) (+ position 1)))
;(gimp-image-set-active-layer image shadowLayer)
  (cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector shadowLayer)))
(else (gimp-image-set-active-layer image shadowLayer))
)
;(gimp-item-set-linked shadowLayer TRUE)

; The original selection is reloaded and its channel is deleted
  
  (gimp-image-select-item image 2 theSelection)
  (gimp-image-remove-channel image theSelection)

; The originalLayer is made active


  ;(gimp-image-set-active-layer image originalLayer)
    (cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector originalLayer)))
(else (gimp-image-set-active-layer image originalLayer))
)
  
; Closes the undo group

  (gimp-image-undo-group-end image)

; Tells GIMP that a change has been made
  (gimp-context-set-foreground old-fg)
  (gimp-context-set-background old-bg)
  (gimp-displays-flush)

; Resets previous user settings  
  
;;;;;(gimp-context-pop)
  )
)

; Registers the Script with the PB

(script-fu-register "script-fu-lotr299-text"
"Lord of the Rings 299...Alpha"
"Make a chiseled-looking alpha, similar to the Lord of the Rings"
"Art Wade"
"Art Wade"
"October 3, 2008"
"RGBA"
SF-IMAGE      "Image"           0
SF-DRAWABLE   "Drawable"        0
SF-TOGGLE     "Use existing text color?" FALSE
SF-COLOR      "Desired Text Color" '(213 206 95)
SF-OPTION     "Gradient Blend Style" '("Dimpled" "Angular" "Spherical")
SF-TOGGLE     "Add Drop Shadow?" TRUE
SF-ADJUSTMENT "Offset X"       '(3 0 100 1 10 0 1)
SF-ADJUSTMENT "Offset Y"       '(3 0 100 1 10 0 1)
SF-ADJUSTMENT "Blur radius"    '(5 0 100 1 10 0 1)
SF-COLOR      "Color"          '(0 0 0)
SF-ADJUSTMENT "Opacity"        '(80 0 100 1 10 0 0)
;SF-TOGGLE     "Keep Bump Map Layer?" FALSE 
)

(script-fu-menu-register "script-fu-lotr299-text" "<Image>/Script-Fu/AlphaToLogo/")
;;text
(define (script-fu-lotr299-text-text text size font justification letter-spacing line-spacing grow-text outline md color mgrad mtex blendStyle addShadow offsetX offsetY blurRadius shadowColor 
		opacity bg-md bg-color1 bggrad bgpat)
  (let* ((img (car (gimp-image-new 256 256 RGB)))

;;text
	 (text-layer (car (gimp-text-fontname img -1 0 0 text 20 TRUE size PIXELS font)))
	 	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))	
;;width height
	 (width (car (gimp-drawable-get-width text-layer)))
	 (height (car (gimp-drawable-get-height text-layer)))

	 (bg-layer 0)

         (old-fg (car (gimp-context-get-foreground)))
	 (old-bg (car (gimp-context-get-background)))
         (old-grad (car (gimp-context-get-gradient)))
         (old-pat (car (gimp-context-get-pattern)))
)
	(gimp-image-undo-disable img)
	(gimp-image-resize img (+ width offsetX) (+ height offsetY) 0 0)

;;
    (gimp-context-set-foreground color)
       	      (gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification text-layer justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing  

   ;;;;;; SHRINK/GROW text
(cond ((> grow-text 0)
	(gimp-selection-none img)
	(gimp-image-select-item img 2 text-layer)
	(gimp-selection-grow img (round grow-text))   
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none img)
	(gimp-image-select-item img 2 text-layer)
	(gimp-drawable-edit-clear text-layer)
	(gimp-selection-shrink img (- grow-text))   
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
 ))
   ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none img)
	(gimp-image-select-item img 2 text-layer)
	(gimp-selection-shrink img (round outline))   
	(gimp-drawable-edit-clear text-layer)
	(gimp-image-select-item img 2 text-layer)
 ))
(gimp-selection-none img)
    (gimp-layer-set-lock-alpha text-layer TRUE)
    (gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
    (cond((= md 1)
       (gimp-context-set-gradient mgrad)
       ;(gimp-blend text-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY 0 100 20 REPEAT-NONE FALSE 0 0 0 0 0 0 width height)
       (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
       (gimp-drawable-edit-gradient-fill text-layer 0 0 REPEAT-NONE 1 1 FALSE 0 0 width height)
					    )
       ((= md 2)
       (gimp-context-set-pattern mtex)
       (gimp-image-select-item img 2 text-layer)
       (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
       (gimp-drawable-edit-fill text-layer FILL-PATTERN)
       (gimp-selection-none img)
     ))

(script-fu-lotr299-text   img
                               text-layer
                               TRUE
                               '(0 0 0)
                               blendStyle
			       addShadow
			       offsetX
			       offsetY
			       blurRadius
			       shadowColor
			       opacity
;			       keepBumpMap
        )

      (set! width (car (gimp-image-get-width img) ) )
      (set! height (car (gimp-image-get-height img) ) )
      (set! bg-layer (car (gimp-layer-new img 10 10 RGB-IMAGE "background" 100 LAYER-MODE-NORMAL-LEGACY) ) )
      (gimp-image-insert-layer img bg-layer 0 2)
      (gimp-drawable-edit-clear bg-layer)
      (gimp-layer-resize bg-layer width height 0 0)
	(gimp-context-set-foreground bg-color1)
	(gimp-drawable-fill bg-layer FILL-FOREGROUND)
    (cond((= bg-md 1)
	(gimp-context-set-gradient bggrad)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
	;(gimp-blend bg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY 0 100 20 REPEAT-NONE FALSE 0 0 0 0 0 0 width height)
	(gimp-drawable-edit-gradient-fill bg-layer 0 20 REPEAT-NONE 1 1 FALSE 0 0 width height)
	)
	((= bg-md 2)
	(gimp-selection-all img)
	(gimp-context-set-pattern bgpat)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
	(gimp-drawable-edit-bucket-fill bg-layer FILL-PATTERN 0 0)
	(gimp-selection-none img)
	))

	(gimp-context-set-foreground old-fg)
	(gimp-context-set-background old-bg)
	(gimp-context-set-gradient old-grad)
	(gimp-context-set-pattern old-pat)

	(gimp-image-undo-enable img)
	(gimp-display-new img)
))
(script-fu-register "script-fu-lotr299-text-text"
		    "Lord of the Rings 299... Text"
		    "Make a chiseled-looking text, similar to the Lord of the Rings"
		    "Art Wade"
		    "Art Wade"
		    "October 3, 2008"
		    ""
	SF-TEXT   "Text String"		"Lord of the Rings"
	SF-ADJUSTMENT "Font Size (pixels)"	'(120 2 1000 1 10 0 1)
	SF-FONT     "Font"			"Bodoni MT"
	SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill")
	SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
	SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
      SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -40 40 1 10 0 0)
        SF-ADJUSTMENT _"Outline"          '(0 0 40 1 10 0 0)      
	SF-OPTION     "mode"               '(_"color" _"gradient" _"pattern" "gradmap")
	SF-COLOR      "Color"     	  '(213 206 95)
	SF-GRADIENT   "Gradient"           "Wood 1"
	SF-PATTERN    "Pattern"            "Burlwood"
	SF-OPTION     "Gradient Blend Style"	'("Dimpled" "Angular" "Spherical")
	SF-TOGGLE     "Add Drop Shadow?"	TRUE
	SF-ADJUSTMENT "Offset X"		'(3 0 100 1 10 0 1)
	SF-ADJUSTMENT "Offset Y"		'(3 0 100 1 10 0 1)
	SF-ADJUSTMENT "Blur radius"		'(5 0 100 1 10 0 1)
	SF-COLOR      "Color"			'(0 0 0)
	SF-ADJUSTMENT "Opacity"			'(80 0 100 1 10 0 0)
	SF-OPTION	"bg-mode"		'(_"color" _"gradient" _"pattern")
	SF-COLOR	"Background Color"	'(210 215 184)
	SF-GRADIENT	"Background Gradient"	"Crown molding"
	SF-PATTERN 	"Background Pattern"	"Crinkled Paper"
;	SF-TOGGLE     "Keep Bump Map Layer?"	FALSE 
)
(script-fu-menu-register "script-fu-lotr299-text-text" "<Image>/Script-Fu/Logos/")
