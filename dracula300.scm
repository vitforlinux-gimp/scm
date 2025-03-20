;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove
;
; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
;
; Dracula! script  for GIMP 2.4
; Chris Gutteridge (cjg@ecs.soton.ac.uk)
; At ECS Dept, University of Southampton, England.
;
; Tags: logo
;
; Author statement:
;I've got a new script, but I've not been able to publish it due it
;network faults + firewalls...
;
;I include it here, should you find a way to publish it for me.
;I appologise for how cheesy it is.
;
;(From the creator of fuzzy-selection and camo etc...)
;
; "Dracula!" or "Cheesy Goth"
;
; --------------------------------------------------------------------
; Distributed by Gimp FX Foundry project
; --------------------------------------------------------------------
;   - Changelog -
; Updated to Gimp2.4 (11-2007) http://gimpscripts.com
; Added user selection options for all parameters
;
;
; --------------------------------------------------------------------
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define (script-fu-blood-logo300 inText inFont inFontSize justify letter-spacing line-spacing inBorder inDrip FillColor BorderColor BackgroundColor conserve)

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))
 
   (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))



    (define oldFore (car(gimp-context-get-foreground)) )
    (define oldBack (car(gimp-context-get-background)) )

    (define theImage (car(gimp-image-new 100 100 RGB)) )
    (define textLayer (car(gimp-layer-new-ng theImage 10 10 RGBA-IMAGE _"Text Layer" 100 LAYER-MODE-NORMAL-LEGACY)) )
    (define bloodLayer (car(gimp-layer-new-ng theImage 10 10 RGBA-IMAGE _"Blood Layer" 100 LAYER-MODE-NORMAL-LEGACY)) )
    (define backLayer (car(gimp-layer-new-ng theImage 10 10 RGBA-IMAGE _"Background" 100 LAYER-MODE-NORMAL-LEGACY)) )
    
   	(gimp-context-push)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
   (gimp-context-set-background BackgroundColor )
    (gimp-context-set-foreground FillColor)
   (gimp-image-insert-layer theImage backLayer 0 0)
   (gimp-image-insert-layer theImage bloodLayer 0 0) 
   (gimp-image-insert-layer theImage textLayer 0 0)
    (gimp-selection-all theImage)
    (gimp-drawable-edit-clear textLayer)
    (gimp-drawable-edit-clear bloodLayer)
    (gimp-selection-none theImage)
    	 (if (not (defined? 'gimp-drawable-filter-new))	
(define theText (car (gimp-text-fontname theImage textLayer 0 0 inText 0 TRUE inFontSize PIXELS  inFont   )))
        (define theText (car (gimp-text-font theImage textLayer 0 0 inText 0 TRUE inFontSize  inFont   ))))
    (gimp-text-layer-set-justification theText justify)
    	(gimp-text-layer-set-letter-spacing theText letter-spacing)
	(gimp-text-layer-set-line-spacing theText line-spacing)
    (define theBuffer (+ inBorder inDrip inDrip))
    (gimp-layer-set-offsets theText theBuffer theBuffer)
    (define theWidth (+ (car(gimp-drawable-get-width theText)) theBuffer theBuffer) )
    (define theHeight (+ (car(gimp-drawable-get-height theText)) theBuffer theBuffer) )
    (gimp-image-resize theImage theWidth theHeight 0 0)
    (gimp-layer-resize textLayer theWidth theHeight 0 0)
    (gimp-layer-resize bloodLayer theWidth theHeight 0 0)
    (gimp-layer-resize backLayer theWidth theHeight 0 0)
    (gimp-floating-sel-anchor theText)

    (gimp-selection-all theImage)
    (gimp-drawable-edit-fill backLayer FILL-BACKGROUND)
    (gimp-selection-none theImage)

  (gimp-context-set-background BorderColor )

    (gimp-image-select-item theImage 0 textLayer)
    (gimp-selection-grow theImage inBorder)
    (gimp-drawable-edit-fill bloodLayer FILL-BACKGROUND)
    (gimp-selection-none theImage)

    (gimp-layer-scale bloodLayer theWidth (/ theHeight 8) TRUE)
    (define (smear n) 
    					  (cond((not(defined? 'plug-in-spread))(if (> n 0)
					                (gimp-drawable-merge-new-filter bloodLayer "gegl:wind" 0 LAYER-MODE-REPLACE 1.0
                                                                                                        "style" "blast" "direction" "bottom" "edge" "leading" "threshold" 10 "strength" n "seed" 10) 
						(gimp-drawable-merge-new-filter bloodLayer "gegl:noise-spread" 0 LAYER-MODE-REPLACE 1.0
                                                                                                        "amount-x" 0 "amount-y" 2 "seed" 10)

												))	
												       (else
    (if (> n 0) (begin (plug-in-spread TRUE theImage bloodLayer 0 1) (smear (- n 1)))))))
    (smear inDrip)
    (gimp-layer-scale bloodLayer theWidth theHeight TRUE)

    (gimp-image-select-item theImage 0 textLayer)
    (gimp-selection-grow theImage inBorder)
    (gimp-drawable-edit-fill bloodLayer FILL-BACKGROUND)
    (gimp-selection-none theImage)

    (apply-gauss2 theImage bloodLayer 4 4)
   ; (plug-in-threshold-alpha TRUE theImage bloodLayer 127)
   (gimp-drawable-threshold bloodLayer 0 0.2 0.7)
     (apply-gauss2 theImage bloodLayer 3 3)

    (gimp-image-select-item theImage 0 bloodLayer)
    (gimp-context-set-foreground BorderColor)
    (gimp-drawable-edit-bucket-fill bloodLayer FILL-FOREGROUND 0 100)
    (gimp-selection-none theImage)
    (apply-gauss2 theImage bloodLayer 1 1)

   (if (= conserve 0) (define oneLayer (car(gimp-image-flatten theImage)) ))
   ; (plug-in-autocrop TRUE theImage oneLayer)

    (gimp-context-set-foreground oldFore)
    (gimp-context-set-background oldBack)
(gimp-context-pop)
    (gimp-display-new theImage)
)



; Register the function with the GIMP:

(script-fu-register "script-fu-blood-logo300"
    _"Dracula 300"
    _"Draws the given text string with a border of dripping blood!"
    "Christopher Gutteridge"
    "1998, Christopher Gutteridge"
    "2007, Scott Mosteller"
    ""
   SF-TEXT     _"Text"               "Dracula!"
   SF-FONT       _"Font"               "QTFraktur Medium"
   SF-ADJUSTMENT _"Font Size (pixels)" '(150 2 1000 1 10 0 1)
   	SF-OPTION "Justify" '("Left" "Right" "Centered")
	SF-ADJUSTMENT "Letter Spacing" '(-5 -100 100 1 5 0 0)
	SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
   SF-ADJUSTMENT _"Border Size"    '(7 1 99 1 1 0 1)
   SF-ADJUSTMENT _"Drip Size"    '(2 0 2 1 1 0 1)
   SF-COLOR		"Fill Color"			'(255 255 255)
   SF-COLOR		"Border Color"			'(255 0 0)
   SF-COLOR		"Background"			'(0 0 0)
   SF-TOGGLE     "Keep the Layers"           FALSE
)

(script-fu-menu-register "script-fu-blood-logo300"
                         "<Image>/File/Create/Logos")
