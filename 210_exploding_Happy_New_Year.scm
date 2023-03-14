;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove
;And a little by hands
; exploding.scm 
; creates exploding logos
; (c) 1998 stefan stiasny
;
; The GIMP -- an image manipulation program
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


;; Functions to create spline curves to send to gimp-drawable-curves-spline

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))


(define (script-fu-exploding-logo210 text size font type tcolor tpattern tgrad blur displace_loop blur_toggle crop_toggle ft?)


(let* (
    (img (car (gimp-image-new size size RGB)))
    (theBgLayer (car (gimp-layer-new img size size RGB "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (oldfg (car (gimp-context-get-foreground)))
    (oldbg (car (gimp-context-get-background)))
    (oldgrad (car (gimp-context-get-gradient)))
    (oldpat (car (gimp-context-get-pattern)))
    (theTextLayer)
    (theText)
    (theImageWidth)
    (theImageHeight)
    (theImageSize)
    (theBuffer)
    (thePolarLayer)
    (theNoiseLayer)
    (theGreyLayer)
    (theMergedLayer)
    (i)
    (clayer)
    (clayer2))

 
    (gimp-image-undo-disable img)
    (gimp-image-insert-layer img theBgLayer 0 0)
    (gimp-context-set-background '(255 255 255))
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill theBgLayer 0)
    (define theTextLayer (car (gimp-layer-copy theBgLayer 0)))
    (gimp-item-set-name theTextLayer "Text")

    (gimp-image-insert-layer img theTextLayer 0 0)
;    errata (define theText (car (gimp-text-fontname img theTextLayer 50 0 text 0 1  size 1 "*" font "medium" "r" "*" "*" )))
 ; vecchia    (define theText (car (gimp-text-fontname img theTextLayer 50 0 text 0 TRUE  size 1 "*" font "medium" "r" "*" "*" "*" "*")))
 (define theText (car (gimp-text-fontname img theTextLayer 50 0 text 0 TRUE size 1  font   )))
    (define theImageWidth (+ (car (gimp-drawable-get-width theText)) 100))
    (define theImageHeight (+ (car (gimp-drawable-get-height theText)) 100))
    (define theImageSize theImageWidth)
(gimp-text-layer-set-justification theText 2)
    (gimp-image-resize img theImageSize theImageSize 0 0)
    (gimp-layer-resize theBgLayer theImageSize theImageSize 0 0)
    (gimp-layer-resize theTextLayer theImageSize theImageSize 0 0)
    (gimp-drawable-edit-clear theBgLayer)			;add
    (gimp-drawable-edit-clear theTextLayer)			;add
    (define theBuffer (/ (- theImageSize (car(gimp-drawable-height theText))) 2 ))
    (gimp-layer-set-offsets theText 50 theBuffer)
    (gimp-floating-sel-anchor theText)
    (plug-in-gauss-iir 1 img theTextLayer blur TRUE TRUE)

    (define (set-pt a index x y)
      (prog1
       (aset a (* index 2) x)
       (aset a (+ (* index 2) 1) y)))

    (define (spline-exploding)
      (let* ((a (cons-array 6 'byte)))
        (set-pt a 0 0 0)
        (set-pt a 1 127 255)
        (set-pt a 2 255 0)
        a))

    (gimp-drawable-curves-spline theTextLayer 0 6 (spline-exploding))
    (gimp-drawable-curves-spline theTextLayer 0 6 (spline-exploding))

    (define thePolarLayer (car (gimp-layer-copy theTextLayer 0)))
    (gimp-item-set-name thePolarLayer "Polar")
    (gimp-image-insert-layer img thePolarLayer 0 1)
    (plug-in-polar-coords 1 img thePolarLayer 100.000 0.000 FALSE TRUE FALSE)

    (define theNoiseLayer (car (gimp-layer-new img theImageSize 10 RGB "Noise" 100 LAYER-MODE-LIGHTEN-ONLY)))
    (define theGreyLayer (car (gimp-layer-new img theImageSize theImageSize RGB "Grey" 100 LAYER-MODE-NORMAL-LEGACY)))

    (gimp-image-insert-layer img theNoiseLayer 0 2)
    (gimp-image-insert-layer img theGreyLayer 0 3)
    (gimp-context-set-background '(128 128 128))
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill theGreyLayer 1)
    (gimp-drawable-edit-fill theNoiseLayer 1)
    (gimp-drawable-edit-fill theBgLayer 0)

    (plug-in-noisify 1 img theNoiseLayer 1 1.0 1.0 1.0 0.00)
    (gimp-drawable-desaturate theNoiseLayer 0)
    (gimp-layer-scale theNoiseLayer theImageSize theImageSize 1)
    (gimp-layer-set-offsets theNoiseLayer 0 0)

    (gimp-item-set-visible theBgLayer 0)
    (gimp-item-set-visible theTextLayer 0)
    (gimp-item-set-visible thePolarLayer 0)
    (define theMergedLayer (car (gimp-image-merge-visible-layers img 2)))

    (plug-in-displace 1 img thePolarLayer 0.000 -100.000 FALSE TRUE theMergedLayer theMergedLayer 1)
  ;;(plug-in-blur 1 img thePolarLayer)
;;    (plug-in-gauss-iir 1 img thePolarLayer blur TRUE TRUE)

    (define i displace_loop)
    (while (> i 1)
        (plug-in-displace 1 img thePolarLayer 0.000 -100.000 FALSE TRUE theMergedLayer theMergedLayer 1)
        (if (= TRUE blur_toggle)
        (plug-in-gauss-iir 1 img thePolarLayer blur TRUE TRUE))
        (define i (- i 1)))
    
    (plug-in-polar-coords 1 img thePolarLayer 100.000 0.000 FALSE TRUE TRUE)
    (gimp-drawable-edit-bucket-fill thePolarLayer FILL-FOREGROUND LAYER-MODE-NORMAL-LEGACY 100 )
;;;    (gimp-drawable-colorize-hsl thePolarLayer hue 100 0)		;none 2.0

    (gimp-item-set-visible theBgLayer 1)
    (gimp-item-set-visible theTextLayer 1)
    (gimp-item-set-visible thePolarLayer 1)
    (gimp-item-set-visible theMergedLayer 0)
    (gimp-layer-set-mode theTextLayer LAYER-MODE-SCREEN-LEGACY)

    (if (= crop_toggle TRUE) 
        ;(gimp-image-crop img theImageSize (/ theImageSize 2) 0 (/ theImageSize 2))
	(plug-in-autocrop TRUE img thePolarLayer)
	)

;追加
    (plug-in-gauss-iir2 1 img thePolarLayer 2 2)
    (define clayer (car (gimp-layer-copy thePolarLayer 0)))
    (gimp-image-insert-layer img clayer 0 0)
    
      (cond ((= type 0) 
      (gimp-item-set-name clayer "tint")
    (gimp-context-set-foreground tcolor)
    (gimp-drawable-fill clayer FILL-FOREGROUND)
    (gimp-layer-set-mode clayer 5)
    )
    ( (= type 1) 
	  (gimp-item-set-name clayer "pat")
	(gimp-context-set-pattern tpattern)
				(gimp-drawable-fill clayer FILL-PATTERN))
    ( (= type 2) 
	  (gimp-item-set-name clayer "grad")
	(gimp-context-set-gradient tgrad)
				;(gimp-drawable-fill clayer FILL-PATTERN))
				(gimp-context-set-gradient-repeat-mode 0)
								(gimp-drawable-edit-gradient-fill 
			clayer
			;BLEND-FG-TRANSPARENT
			;LAYER-MODE-NORMAL-LEGACY
			2 ;GRADIENT-LINEAR
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			100
			0
			0 ;FALSE
		
		    (/ theImageWidth 2)
    (/ theImageHeight 2)
    0
    0
		)
))
				
    (gimp-layer-set-mode clayer 5)
    (define clayer2 (car (gimp-layer-copy clayer 0)))
    (gimp-image-insert-layer img clayer2 0 0)
    (plug-in-gauss-iir2 1 img theTextLayer 2 2)

    (if (= ft? TRUE) (gimp-image-merge-visible-layers img 0))

    (gimp-context-set-foreground oldfg)
    (gimp-context-set-background oldbg)
	(gimp-context-set-gradient oldgrad)
      (gimp-context-set-pattern oldpat)
    (gimp-display-new img)
    (gimp-image-undo-enable img)))

(script-fu-register "script-fu-exploding-logo210"
                    _"Exploding 210 Happy New Year"
                    "Exploding Logo"
                    "Stefan Stiasny <sc@oeh.net>"
                    "Stefan Stiasny"
                    "11/08/1998"
                    ""
                    SF-TEXT	_"Text"			"HAPPY\nNEW\nYEAR"
                    SF-ADJUSTMENT	_"Font size (pixels)"	'(150 2 1000 1 10 0 0)
                    SF-FONT		_"Font"			"Baskerville Bold"
		    SF-OPTION		"Fill with"		'("Color" "Pattern" "Gradient")
		    SF-COLOR		"Fill Color"		'(255 128 0)
		    SF-PATTERN		"Fill Pattern"		"Disco Mania"
		    	SF-GRADIENT		"Fill Gradient"		"Skyline"
                    SF-ADJUSTMENT	_"Blur Value"		'(7 1 30 1 10 0 0)
                    SF-ADJUSTMENT	_"Displace how often?"	'(2 0 2 1 10 0 0)
;;;                    SF-ADJUSTMENT _"Hue"			'(32 1 100 1 10 0 1)
                    SF-TOGGLE					"Multilpe Blur?" FALSE
                    SF-TOGGLE					"Crop?"   FALSE
                    SF-TOGGLE					"flatten?"       TRUE)
		    
(script-fu-menu-register "script-fu-exploding-logo210"
                         "<Image>/File/Create/Logos")
