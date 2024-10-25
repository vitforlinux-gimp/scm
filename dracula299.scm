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


(define (script-fu-blood-logo299 inText inFont inFontSize justify letter-spacing line-spacing inBorder inDrip FillColor BorderColor BackgroundColor)

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(if (<> (string->number (substring (car(gimp-version)) 0 3)) 2.10)	
(define (prog1 form1 . form2)
  (let ((a form1))
    (if (not (null? form2))
      form2
    )
    a
  )
)
)
    (define oldFore (car(gimp-context-get-foreground)) )
    (define oldBack (car(gimp-context-get-background)) )

    (define theImage (car(gimp-image-new 100 100 RGB)) )
    (define textLayer (car(gimp-layer-new theImage 10 10 RGBA-IMAGE _"Text Layer" 100 LAYER-MODE-NORMAL-LEGACY)) )
    (define bloodLayer (car(gimp-layer-new theImage 10 10 RGBA-IMAGE _"Blood Layer" 100 LAYER-MODE-NORMAL-LEGACY)) )
    (define backLayer(car(gimp-layer-new theImage 10 10 RGBA-IMAGE _"Background" 100 LAYER-MODE-NORMAL-LEGACY)) )
    
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
    	 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)	
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
    (define (smear n) (if (> n 0) (prog1 (plug-in-spread TRUE theImage bloodLayer 0 1) (smear (- n 1)))))
    (smear inDrip)
    (gimp-layer-scale bloodLayer theWidth theHeight TRUE)

    (gimp-image-select-item theImage 0 textLayer)
    (gimp-selection-grow theImage inBorder)
    (gimp-drawable-edit-fill bloodLayer FILL-BACKGROUND)
    (gimp-selection-none theImage)

    (plug-in-gauss-iir TRUE theImage bloodLayer 4 TRUE TRUE)
    (plug-in-threshold-alpha TRUE theImage bloodLayer 127)
     (plug-in-gauss-iir TRUE theImage bloodLayer 3 TRUE TRUE)

    (gimp-image-select-item theImage 0 bloodLayer)
    (gimp-context-set-foreground BorderColor)
    (gimp-drawable-edit-bucket-fill bloodLayer FILL-FOREGROUND 0 100)
    (gimp-selection-none theImage)
    (plug-in-gauss-iir TRUE theImage bloodLayer 1 TRUE TRUE)

    (define oneLayer (car(gimp-image-flatten theImage)) )
   ; (plug-in-autocrop TRUE theImage oneLayer)

    (gimp-context-set-foreground oldFore)
    (gimp-context-set-background oldBack)
(gimp-context-pop)
    (gimp-display-new theImage)
)



; Register the function with the GIMP:

(script-fu-register "script-fu-blood-logo299"
    _"Dracula 299"
    _"Draws the given text string with a border of dripping blood!"
    "Christopher Gutteridge"
    "1998, Christopher Gutteridge"
    "2007, Scott Mosteller"
    ""
   SF-TEXT     _"Text"               "Dracula!"
   SF-FONT       _"Font"               "QTFraktur"
   SF-ADJUSTMENT _"Font Size (pixels)" '(150 2 1000 1 10 0 1)
   	SF-OPTION "Justify" '("Left" "Right" "Centered")
	SF-ADJUSTMENT "Letter Spacing" '(-5 -100 100 1 5 0 0)
	SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
   SF-ADJUSTMENT _"Border Size"    '(7 1 99 1 1 0 1)
   SF-ADJUSTMENT _"Drip Size"    '(12 0 99 1 1 0 1)
   SF-COLOR		"Fill Color"			'(255 255 255)
   SF-COLOR		"Border Color"			'(255 0 0)
   SF-COLOR		"Background"			'(0 0 0)
)

(script-fu-menu-register "script-fu-blood-logo299"
                         "<Image>/File/Create/Logos")
