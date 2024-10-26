;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
;
; A set of layer effects script  for GIMP 1.2
; Copyright (C) 2001 Laetitia Marin titix@gimpforce.org 
; Copyright (C) 2001 Ostertag Raymond coordinateur@gimp-fr.org 
; Copyright (C) 2007 Philippe Demartin philippe@demartinenchile.com Paint corroded version for GIMP 2.4
; 2024 update for 2.10 vitforlinux
;
; --------------------------------------------------------------------
; version 0.2 2007-october-21
;     - Initial relase
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
; --------------------------------------------------------------------
;
; This is the official English version you'll find a french version at http://www.gimp-fr.org/
;
; Script-fu Liquid-Water  an attempt to realise some funy water effect 
; 
; Copyright (C) Philippe Demartin www.demartinenchile.com  25 october 2007 
;
; See the manual at the tutorial section of the gug http://gug.sunsite.dk/
;
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))
(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))



(define (Aply-script-fu-Liquid-Water-299 img Bump-Layer Back-color ShapeW DropsA LightA sh-op inter)
  (let* ((width (car (gimp-drawable-get-width Bump-Layer)))
	(height (car (gimp-drawable-get-height Bump-Layer)))
        (Noise_width)
        (Noise_height)
        (DropsA (*  DropsA 2.55))
        (ShapeW (/  ShapeW 2))
        (theLayers)
        (theLayersArray 0)
        (DropShadow 0)
        (activ_selection (car (gimp-selection-is-empty img)))
	(Noise_calque (car (gimp-layer-new img width height RGBA-IMAGE "Noise" 100 3)))
	(Background-Color_calque (car (gimp-layer-new img width height RGBA-IMAGE "Background-Color" 100
                                                                 				LAYER-MODE-NORMAL-LEGACY)))
	(Mosaic_calque (car (gimp-layer-new img width height RGBA-IMAGE "Mosaic" 100 LAYER-MODE-NORMAL-LEGACY)))
	(Water_calque (car (gimp-layer-new img width height RGBA-IMAGE "Water" 100 LAYER-MODE-NORMAL-LEGACY)))
	;(old-fg (car (gimp-context-get-foreground)))
	;(old-bg (car (gimp-context-get-background)))
        (White '(255 255 255))
        (Black '(0 0 0))
        (Grey_1 '(43 43 43))
        (Grey_2 '(211 211 211)))

    ; undo initialisation
    (gimp-image-undo-group-start img)
    	(gimp-context-set-paint-mode 0)
	 (gimp-context-push)

    (gimp-image-resize-to-layers img)
(let* ((height (car (gimp-image-get-height img)))
       (width  (car (gimp-image-get-width  img))))
       (gimp-selection-all img)

    ; Create Layer and fill them
    (gimp-image-insert-layer img Background-Color_calque 0 0)
        (gimp-context-set-foreground Back-color)
        (gimp-drawable-edit-fill Background-Color_calque 0)
    (gimp-image-insert-layer img Mosaic_calque 0 0)
        (gimp-context-set-foreground Grey_2)
        (gimp-drawable-edit-fill Mosaic_calque 0)
    (gimp-image-insert-layer img Noise_calque 0 0)
        (gimp-context-set-foreground White)
        (gimp-drawable-edit-fill Noise_calque 0)

    ; Create Noise 
    ;(gimp-image-set-active-layer img Noise_calque)
       (set! Noise_height (/ height 10))
       (set! Noise_width  (/ width  10))
    (gimp-layer-scale Noise_calque Noise_width Noise_height 0)
    (plug-in-rgb-noise 1 img Noise_calque FALSE FALSE 1 1 1 0)
    (gimp-layer-scale Noise_calque width height 0)
    (gimp-layer-resize-to-image-size Noise_calque)

    ; Transforming the text
    (gimp-image-raise-item-to-top img Bump-Layer)
    (gimp-image-select-item img 2 Bump-Layer)
    (gimp-context-set-foreground Black)
    (gimp-drawable-edit-fill Bump-Layer 0)
    (gimp-selection-invert img)
    (gimp-context-set-foreground White)
    (gimp-drawable-edit-fill Bump-Layer 0) 
    (gimp-selection-all img) 
    (plug-in-gauss 1 img Noise_calque 20 20 0)
    (gimp-drawable-threshold Noise_calque 0 (/ DropsA 255) 1)    ;
    (plug-in-gauss 1 img Bump-Layer  ShapeW ShapeW 0)   
    (gimp-drawable-threshold Bump-Layer 0 0.764705882353 1)
    (gimp-image-raise-item-to-top img Noise_calque)
    (gimp-image-merge-down img Noise_calque 0)
    (set! theLayers (gimp-image-get-layers img))
        (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
    (set! theLayersArray (cadr theLayers))
    (set! theLayersArray (car theLayers)))
    (set! Bump-Layer (vector-ref theLayersArray 0))

   ;Create floor texure 
    (gimp-context-set-background Black)
    (gimp-context-set-foreground Black)
    (plug-in-mosaic 1 img Mosaic_calque 80 6 1 1 TRUE 135 0.1 TRUE FALSE 0 0 1)

     ; preparing the layers for bumping
(let* ((Highlight_up   (car (gimp-layer-copy Bump-Layer FALSE)))
      (Highlight_down  (car (gimp-layer-copy Bump-Layer FALSE))) 
      (Highlight_fill  (car (gimp-layer-copy Bump-Layer FALSE)))
      (Shadow  (car (gimp-layer-copy Bump-Layer FALSE))))
      (gimp-image-insert-layer img Highlight_up 0 0)
      (gimp-image-insert-layer img Highlight_down 0 0)
      (gimp-image-insert-layer img Highlight_fill 0 0)	
      (gimp-image-insert-layer img Shadow 0 4)

    (gimp-selection-none img)
    ;(gimp-by-color-select   Bump-Layer '(255 255 255) 0 0 FALSE FALSE 0 FALSE)
    (gimp-image-select-color img 2 Bump-Layer '(255 255 255))
    (gimp-drawable-edit-clear   Highlight_up)
    (gimp-drawable-edit-clear Highlight_down)
    (gimp-drawable-edit-clear Highlight_fill)
    (gimp-drawable-edit-clear       Shadow)
    (gimp-selection-invert img)
    (gimp-context-set-foreground Grey_1)
    (gimp-drawable-edit-fill Highlight_up 0)
    (gimp-drawable-edit-fill Highlight_down 0)
    (gimp-drawable-edit-fill Highlight_fill 0)
    (gimp-selection-all img)
    (plug-in-gauss 1 img Bump-Layer 20 20 0)
    (plug-in-gauss 1 img Shadow 10 10 0)
    (gimp-layer-set-offsets Shadow 4 3)
 
    ;Bumping an Highlight
    (plug-in-bump-map FALSE img Highlight_up Bump-Layer    130 15 30 0 0 0 0 TRUE TRUE 3)
    (plug-in-bump-map FALSE img Highlight_down Bump-Layer  300 30 30 0 0 0 0 TRUE TRUE 3)
    (gimp-image-select-item img 2 Highlight_fill)  
    (gimp-drawable-edit-clear Shadow)
    (plug-in-displace 1 img Mosaic_calque 2 -4 2 2 Bump-Layer Bump-Layer 1)
    (cond ((= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
    (plug-in-lighting 
                       inter img Highlight_up Highlight_up  Highlight_up FALSE FALSE FALSE 0 White 
                       -1 -1 1 -4 -0 1 LightA 
                       1 0.6 2 40 TRUE FALSE FALSE))
	(else
	(plug-in-lighting 
                       inter img  (vector Highlight_up) Highlight_up  Highlight_up FALSE FALSE "bumpmap-sinusoidal" 0 "light-directional" White 1
                       -1 -1 1 -4 -0 1 LightA 
                       1 0.6 0.5 40 FALSE TRUE FALSE FALSE  0.25))
	)
		       
    (gimp-selection-none img)
   ;(gimp-by-color-select   Highlight_up Grey_1 30 0 FALSE TRUE 10 FALSE)
    (gimp-image-select-color img 2 Highlight_up Grey_1)
    (gimp-drawable-edit-clear  Highlight_up)
        (gimp-selection-none img)
    (gimp-selection-none img)
    ;(gimp-by-color-select Highlight_down Grey_1 10 0 FALSE TRUE 5 FALSE)
    (gimp-image-select-color img 2 Highlight_down Grey_1)
    (gimp-drawable-edit-clear  Highlight_down)
        (gimp-selection-none img)
	    (cond ((= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
    (plug-in-lighting 
                       inter img Mosaic_calque Mosaic_calque Mosaic_calque  1 FALSE FALSE 0 White 
                       -1 -1 1 -4 -0 1 LightA 
                       0.2 0.6 0.5 27 TRUE FALSE FALSE))
		       (else
	    (plug-in-lighting 
                       inter img  (vector Mosaic_calque) Mosaic_calque Mosaic_calque  FALSE FALSE "bumpmap-sinusoidal" 0 "light-point" White 1
                       -1 -1 1 -4 -0 1 LightA 
                       0.2 0.6 0.5 27 FALSE TRUE FALSE FALSE 0.25)
		       ) 
		       )
    (gimp-image-select-item img 2 Highlight_fill) 
    (plug-in-bump-map FALSE img Mosaic_calque Bump-Layer  135 13.5 1 10 10 0 0 TRUE TRUE 3)

    ;Layer seting adjustment
    (gimp-selection-all img)
    (gimp-layer-set-opacity Mosaic_calque 70)
    (gimp-layer-set-opacity Shadow sh-op)
    (gimp-layer-set-opacity Highlight_up 80)
    (gimp-layer-set-opacity Highlight_down 85)
    (gimp-layer-set-opacity Highlight_fill 15)
    (gimp-image-lower-item img Highlight_fill)
    (gimp-image-lower-item img Highlight_fill)
    (gimp-layer-set-mode Highlight_up 4)
    (gimp-layer-set-mode Highlight_down 4)
    (gimp-layer-set-mode Mosaic_calque 18)
    (gimp-item-set-visible Bump-Layer FALSE)
    (gimp-layer-resize-to-image-size Shadow)
    (gimp-item-set-name Shadow "Shadow")
    (gimp-item-set-name Highlight_up "Highlight_up")
    (gimp-item-set-name Highlight_down "Highlight_down")
    (gimp-item-set-name Highlight_fill "Highlight_fill")
    (gimp-item-set-name Bump-Layer "Bump-Layer")
     (gimp-context-pop)

   ; (gimp-context-set-foreground old-fg)
   ; (gimp-context-set-background old-bg)
    ;Finish the undo group for the process
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
))))

(define (script-fu-Liquid-Water-299-logo-alpha img Bump-Layer Back-color  ShapeW DropsA LightA shopacity interact)
(begin
         (Aply-script-fu-Liquid-Water-299 img Bump-Layer Back-color ShapeW DropsA LightA shopacity interact)
         (gimp-displays-flush)))

(script-fu-register "script-fu-Liquid-Water-299-logo-alpha"
		    _"Liquid-Water 299 ALPHA"
		    "Liquid-Water effect"
		    "www.demartinenchile.com"
		    "2007 Philippe Demartin"
		    "20.10.2007"
		    ""
	   	        SF-IMAGE "Image" 0
		        SF-DRAWABLE "Drawable" 0
			SF-COLOR "Background" '(0 0 255)
		        SF-ADJUSTMENT "Shape watering" '(20 0 100 1 1 2 0)
		        SF-ADJUSTMENT "Water drops Amount" '(60 1 100 1 1 2 0)
		        SF-ADJUSTMENT "Light Amount" '(0.80 0 1.6 0.01 1 2 0)
			SF-ADJUSTMENT "Shadow Opacity" '(30 0 100 1 1 0 0)
			SF-TOGGLE		"NO Interact"		TRUE)
(script-fu-menu-register "script-fu-Liquid-Water-299-logo-alpha"
			 "<Image>/Script-Fu/Alpha-to-Logo")

(define (script-fu-Liquid-Water-299-logo font size text justify letter-spacing line-spacing Back-color ShapeW DropsA LightA shopacity interact )
  
  (let* ((img (car (gimp-image-new 256 256  RGB)))	; nouvelle image -> img
	; (border (/ size 4))
         (text-layer (car (gimp-text-fontname img -1 0 0 text size TRUE size PIXELS font)))
				(justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
				((= justify 2) 1)))
	 ) 

    (gimp-layer-new img 256 256 RGBA-IMAGE "background" 90 0)
    (gimp-image-undo-disable img)
    	(gimp-context-set-paint-mode 0)
	      (gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification text-layer justify) ; Text Justification 
   (gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing
	 (gimp-context-push)
    (Aply-script-fu-Liquid-Water-299 img text-layer Back-color ShapeW DropsA LightA shopacity interact)
     (gimp-context-pop)
    (gimp-image-undo-enable img)
    (gimp-display-new img)    
    ))
                    
(script-fu-register 	"script-fu-Liquid-Water-299-logo"
			"Liquid Water 299 LOGO"
			"Create a Water logo with random drops"
			"Philippe Demartin"
			"www.demartinenchile.com"
			"10/21/2007"
			""
			SF-FONT "Font Name" "QTKooper"
			SF-ADJUSTMENT "Font size (pixels)" '(120 50 1000 1 10 0 1)
			SF-TEXT "Enter your text" "Liquid Water..."
			SF-OPTION "Justify" '("Centered" "Left" "Right")
			SF-ADJUSTMENT _"Letter Spacing"        '(0 -50 50 1 5 0 0)
                    SF-ADJUSTMENT _"Line Spacing"          '(0 -300 300 1 10 0 0)			
			SF-COLOR "Background" '(0 0 255)
		        SF-ADJUSTMENT "Shape watering" '(17 2 100 1 1 2 0)
		        SF-ADJUSTMENT "Water drops Amount" '(72 0 100 1 1 2 0)
		        SF-ADJUSTMENT "Light Amount" '(0.80 0 1.6 0.01 1 2 0)
			SF-ADJUSTMENT "Shadow Opacity" '(30 0 100 1 1 0 0)
			SF-TOGGLE		"NO Interact"		TRUE
			)

(script-fu-menu-register "script-fu-Liquid-Water-299-logo"
			 "<Image>/File/Create/Logos")
