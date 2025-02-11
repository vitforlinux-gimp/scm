;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Logo Toolbox Version 2.3
;
; Created by GnuTux 
; Download From: http://gimpscripts.com
;
; Support Thread: http://gimpchat.com/viewtopic.php?f=9&t=7237
; Tutorial: http://gimpchat.com/viewtopic.php?f=23&t=9472
;
; License: GPLv3 (c) Copyright 2013
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
; ------------
;| Change Log |
; ------------ 
; RC V0.01 - Initial Release Candidate  
; RC V0.02 - Code clean-up, keep user selection, more descriptive variable names, eliminate tabs
;            from source. Add simple gloss and desaturated glass/transparent layer.
; RC V0.03 - All elements on separate layers. Allow shadow toggle .
; RC V0.4 -  Code optimization, Dialog tweaks, Add Offset stroke, Add Double bevel,
;            Added new color fill fill effects uisng Cubism, Olify & Plasma. 
;            Improve layer arrangement.
; RC V0.5 -  Updated script to be more intuitive and easier to use.
;            Enhance fill options and removed built-in drop shadow feature. 
;            Add dialog options for easy to use double bevel & offset stroke.
;            Implemented Global feather (set to 3).    
;            Implemented Glass color select and added it as fill layer.
;            Simplified wokflow by moving added effect layers to become fill layers. 
;            Added effect layers consist of Simple Shine & Pattern Bump.
; Rel V1.0 - Optimize logic and fully document code for official release.
;            Renamed from Logo Workshop to Logo Toolbox.
; Rel V1.1 - Give Bump it's own dropdown and add invert option
;            Add new effect drop down for Background, Shadow & Gloss + combinations of each
;            Add option for Character letter-spacing  
; Rel V1.2 - Revamp Glass Routines
;            Add support for beveled, textured (bumped) & gradient filled glass
;            Add support for Vertical, Horizontal & Diagonal Gradients  
;            Impoved logic & optimized code
; Rel V1.2.1 Fixed Bug Where attempted to delete Bump layer when it did not exist
; Rel V1.2.2 Modified Code To Allow Script To Run In GIMP V2.6.x
; Rel V1.3 - Fixed selection accuracy issues by properly saving selections
;            Added Color Fills: Random Lava Using Active Gradient & Random Color Diffraction Fill
; Rel V1.3.1 Fixed Bug From Left Over Test Code 
; Rel V2.0 - Redesigned UI To Split Out Background/Shadow/Misc Effects
;            Added Interactive iWarp with edge smoothing per request by Rod
;            Added Extrusion Option (Fill, Bump & Pattern Overlay) 
;            Global Feather Dialog
;            More Background Layer Fill Options
;            Expand To Full Text Area on File/Create/Logo
; Rel V2.1 - Add Justification Option For Text   
;            More Intuative Streamline of Input Dialog
;            Eliminate Seldom Used Effects Options (IWarp & Simple Gloss) in Favor of Extrusion Only Options 
;            Options To Extrude the Fill Layer or the Bump Layer
;            Kick Warning To GIMP Console If User Attempts to Extrude Non-Existant Bump Layer
;            Apply Blends To Image/Text only (Not Full Canvas)
; Rel V2.2 - Fixed Bug in Glass Fills/Gradient Glass Fill 
;            Add Glass Depth for Correct Glass Effect
;            Clarify/Simplify Fill Method Dialog
;            Added Option for Blend Shape & Reverse Blend 
; Rel V2.3 - Added Outline Shadow
;            Added Shadow Blur Radius
;            Option To Keep Selection
;            Fixed Transposition Bug On UI
;            General UI Improvements (default layout, colors, order)
; Rel V2.4 - MrQ: procedures adapted to Gimp-2.10, added text direction,  for Alpha To Logo- creates a new image from the selected layer.
;            Fixed deprecated procedure:
		  ; (gimp-item-set-name item name)                -> (gimp-item-set-name item name) - 22x
		  ; (gimp-selection-layer-alpha layer)            -> (gimp-image-select-item image operation[CHANNEL-OP-ADD (0), CHANNEL-OP-SUBTRACT (1), CHANNEL-OP-REPLACE (2), CHANNEL-OP-INTERSECT (3)] item) - 4x
		  ; (gimp-image-insert-layer image layer position 0) -> (gimp-image-insert-layer image layer parent position) - 12x
		  ; (gimp-selection-load channel)                 -> (gimp-image-select-item image operation[CHANNEL-OP-ADD (0), CHANNEL-OP-SUBTRACT (1), CHANNEL-OP-REPLACE (2), CHANNEL-OP-INTERSECT (3)]  item) - 7x
		  ; (gimp-image-lower-layer-to-bottom image item) -> (gimp-image-lower-item-to-bottom image item) - 2x
		  ; (gimp-layer-set-visible item visible)         -> (gimp-item-set-visible item visible) - 2x
		  ; (gimp-image-get-item-position image item)    -> (gimp-image-get-item-position image item) - 5x
		  ; (gimp-invert drawable)                        -> (gimp-drawable-invert drawable linear[(TRUE or FALSE)}) - 2x
		  ; (gimp-drawable-curves-spline drawable channel num-points control-pts) -> (gimp-drawable-curves-spline drawable channel num-points points) - 1x



; Define the apply logo toolbox procedure
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-base-type)) (define gimp-image-get-base-type gimp-image-base-type)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

; Fix code for gimp 2.10 working in 2.99.16
(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image (vector drawable)))))

  		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "LobsterTwo Bold")
  (define sffont "LobsterTwo-Bold"))

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
			
  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))

(define (apply-logo-toolbox  img
                             logo-layer
                             fill-style
                             logo-color
                             blend-shape
                             rev-blend
                             glass-depth
                             bevel-amt
                             bevel-2x 
                             stroke-color
                             stroke-width
                             stroke-offset
                             bump-style
                             bump-pattern
                             bump-depth
                             extru-type
                             extru-depth
                             extru-direction
                             extru-overlay
                             background-fill
                             bg-pattern
                             shadow-style
                             shadow-blur
                             keep-selection
                             feather-amt 
                             alpha2logo
        )
;
;
; Display Message Procedure
;
(define (lt-display_message
                 text_message                              ; Message to display
                 output_destination                        ; MESSAGE-BOX (0), CONSOLE (1), ERROR-CONSOLE (2)
        )
   (let* (
          (handler_state (car (gimp-message-get-handler))) ; Save current message handler state
         )
          (gimp-message-set-handler output_destination)    ; Set message handler to the desired output destination   
          (gimp-message text_message)                      ; Display the message
          (gimp-message-set-handler handler_state)         ; Restore message handler to saved state

   ) ;endlet
) ; return
;

; Define function for glass translucency values
;
(define (lt-get-glass-trans-curve parm)
  (let* ((curve-value (cons-array 4 'byte)))
   (vector-set! curve-value 0 0)
   (vector-set! curve-value 1 0)
   ;(vector-set! curve-value 2 255)
   (vector-set! curve-value 2 1)   
   (vector-set! curve-value 3 parm)
   curve-value     
   )
) ; return
;
;
  (let* (
           (stroke-layer -1)                ; Stroke layer
           (bump-layer -1)                  ; Bumped layer
           (bumpmap-layer -1)               ; Glass Bumpmap
           (fill-layer -1)                  ; Fill layer
           (background -1)                  ; Background Layer
           (extrusion-layer -1)             ; Extrusion layer
           (temp-layer -1)                  ; Temp Layer
           (pattern-overlay -1)             ; Extrusion Pattern Overlay
           (overlay-pos 2)                  ; Extrusion pattern Overlay Position
           (saved-selection -1)             ; Saved Selection
           (invert-bump FALSE)              ; Inverted Bump Map
           (image-height 0)                 ; Image Height
           (image-width 0)                  ; Image Width
           (current-pattern  -1)            ; Current Pattern
           (extrusion-counter extru-depth)  ; Number of layers to extrude
           (hpos 0)                         ; Extrusion Horizontal Position
           (vpos 0)                         ; Extrusion Verical Position
           (layer-width -1)                 ; Extrusuon Layer Width
           (layer-height -1)                ; Extrusion Layer Height
           (zoom-counter 0)                 ; Point Zoom Counter For Shrink Extrusion
        )

;
; Save Current Active Pattern
;

   (set! current-pattern  (car (gimp-context-get-pattern img)))    ; Save Active Pattern

;
; Selection Check
;

    (if (= (car (gimp-selection-is-empty img)) TRUE)      ; Check for a selection 
        (begin
          (gimp-image-select-item img 2 logo-layer)         ; Select alpha to logo If there isn't one
        )
     ) ; endif

;
; Global feathering
;
     (gimp-selection-feather img feather-amt)             ; Feather the selection

;
; Resize Image For Extrusion During Alpha To Logo
;
   (if (and (= alpha2logo 1) (> extru-type 0))           ; Alpha & Extrusion?
     (begin
      (gimp-image-resize img (+ (+ 15 extru-depth) (car (gimp-image-width img))) (+ (+ 15 extru-depth) (car (gimp-image-height img))) (+ 15 extru-depth) (+ 15 extru-depth))         ; Resize Image
      (gimp-layer-resize logo-layer (+  (+ 15 extru-depth) (car (gimp-image-width img))) (+ (+ 15 extru-depth) (car (gimp-image-height img))) (+ 15 extru-depth) (+ 15 extru-depth)) ; Resize Image
     )
    ) ; endif

;
; Create fill layer to hold fill style
;
  (set! fill-layer (car (gimp-layer-new-from-drawable logo-layer img))) ; New Fill Layer 
  (gimp-image-insert-layer img fill-layer 0 1)                               ; Add it to image
  (gimp-image-set-active-layer img fill-layer)                          ; Make fill layer active
  (gimp-selection-invert img)                                           ; Invert the selection
  (gimp-drawable-edit-clear fill-layer)                                          ; Clear Area Outside of Selection
  (gimp-selection-invert img)                                           ; Restore Selection
  (gimp-item-set-name fill-layer "Fill")                               ; Name fill layer

;
; Fill style case structure 
;
(gimp-context-set-paint-mode 0)
    (if (= fill-style 0)
        (begin  
            (gimp-context-set-foreground logo-color)            ; Set logo color
				(gimp-drawable-edit-fill fill-layer FILL-FOREGROUND)
            ;(gimp-drawable-edit-bucket-fill fill-layer 0 0 100 0 0 0 0)  ; Fill with color
            (gimp-item-set-name fill-layer "Color Fill")       ; Name layer
         )
     ) ;endif
  
    (if (= fill-style 1)
        (begin
            ;(gimp-drawable-edit-bucket-fill fill-layer 2 0 100)  ; Fill with pattern
	    ;(gimp-image-select-item img 2 fill-layer )
	    				(gimp-context-set-pattern current-pattern)
				(gimp-drawable-edit-fill fill-layer FILL-PATTERN)
            (gimp-item-set-name fill-layer "Pattern Fill")     ; Name layer
        )
     ) ;endif
;
; Fill with gradient
;

    (if (and (> fill-style 1)(< fill-style 5))      ; Check for gradient fill
        (begin 

         (cond ((defined? 'plug-in-autocrop-layer)(plug-in-autocrop-layer 1 img fill-layer)) ; Autocrop fill layer so gradient is fully applied 
	(else (gimp-image-autocrop-selected-layers img fill-layer)))
          (if (= fill-style 2)                      ; Vertical gradient fill
            (begin
               (set! image-height (car (gimp-drawable-get-height fill-layer)))
            )
          ) ; endif
          (if (= fill-style 3)                      ; Horizontal gradient fill
            (begin
               (set! image-width (car (gimp-drawable-get-width fill-layer)))
            )
          ) ; endif
          (if (= fill-style 4)                      ; Diagonal gradient fill
            (begin
               (set! image-height (car (gimp-drawable-get-height fill-layer)))
               (set! image-width (car (gimp-drawable-get-width fill-layer)))
            )
          ) ; endif
(gimp-context-set-gradient-reverse rev-blend)
		(gimp-drawable-edit-gradient-fill 
			fill-layer
			;BLEND-CUSTOM; Int32 - Blend Type (BLEND-FG-BG-RGB (0), BLEND-FG-BG-HSV (1), BLEND-FG-TRANSPARENT (2), BLEND-CUSTOM (3))
			;LAYER-MODE-NORMAL-LEGACY
			blend-shape  ; ; Int32 - Gradient Type (GRADIENT-LINEAR (0), GRADIENT-BILINEAR (1), GRADIENT-RADIAL (2), GRADIENT-SQUARE (3), GRADIENT-CONICAL-SYMMETRIC (4), GRADIENT-CONICAL-ASYMMETRIC (5), GRADIENT-SHAPEBURST-ANGULAR (6), GRADIENT-SHAPEBURST-SPHERICAL (7), GRADIENT-SHAPEBURST-DIMPLED (8), GRADIENT-SPIRAL-CLOCKWISE (9), GRADIENT-SPIRAL-ANTICLOCKWISE (10)
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			4
			0.50
			1 ;FALSE
			0
			0
                        image-width  ; Int32 - X Blend Ending Point  
                        image-height ; Int32 - Y Blend Ending Point
             ) ; End Blend

             (gimp-layer-resize-to-image-size fill-layer)      ; Restore Fill Layer To Image Size
             (gimp-item-set-name fill-layer "Gradient Fill")  ; Name layer
        )
     ) ;endif

    (if (= fill-style 5) ;Plasma Fill
        (begin  
	(gimp-image-select-rectangle img 0 0 0 1 1)
	  				    (cond((not(defined? 'plug-in-plasma))
		 		     (gimp-drawable-merge-new-filter fill-layer "gegl:plasma" 0 LAYER-MODE-REPLACE 1.0
"turbulence" 1.0 "x" 0 "y" 0 "width" (car (gimp-drawable-get-width fill-layer)) "height" (car (gimp-drawable-get-height fill-layer)) "seed" (random 999999999) ))		    
	(else
	    (plug-in-plasma 1 img fill-layer (random 999999999) (+ 1 (random 3))))) ; Rnd Plasma Fill
	    (gimp-image-select-rectangle img 1 0 0 1 1)
            (gimp-item-set-name fill-layer "Plasma Fill")                      ; Name layer
         )
     ); endif

    (if (= fill-style 6) ; Patchwork Fill (Plasma + Cubism)
        (begin  
              (gimp-image-select-rectangle img 0 0 0 1 1)
	  				    (cond((not(defined? 'plug-in-plasma))
		 		     (gimp-drawable-merge-new-filter fill-layer "gegl:plasma" 0 LAYER-MODE-REPLACE 1.0
"turbulence" 1.0 "x" 0 "y" 0 "width" (car (gimp-drawable-get-width fill-layer)) "height" (car (gimp-drawable-get-height fill-layer)) "seed" (+ 1 (random 3)) ))		    
	(else
	      (plug-in-plasma 1 img fill-layer (random 999999999) (+ 1 (random 3))))) ; Rnd Plasma Fill
	      (gimp-image-select-rectangle img 1 0 0 1 1)
              ;(plug-in-cubism 1 img fill-layer 6 12 0)                            ; Cubism Fill (patchwork) (plug-in-cubism run-mode image drawable tile-size tile-saturation bg-color)
	 (cond ((not(defined? 'plug-in-cubism))
	             (gimp-drawable-merge-new-filter fill-layer "gegl:cubism" 0 LAYER-MODE-REPLACE 1.0
		     "tile-size" 5 "tile-saturation" 2 "bg-color" '(0 0 0)))
		     (else
	      (plug-in-cubism 1 img fill-layer 5 2 0)))			                   ; 0 <= tile-saturation <= 10
              (gimp-item-set-name fill-layer "Patchwork Fill")                   ; Name layer
          )
     ); endif


    (if (= fill-style 7) ; Diffraction Fill
        (begin  
              (set! *seed* (car (gettimeofday))) ; Random Number Seed From Clock (*seed* is global)
              (random-next)                      ; Next Random Number Using Seed
             ;(plug-in-diffraction run-mode image drawable lam-r lam-g lam-b contour-r contour-g contour-b edges-r edges-g edges-b brightness scattering polarization[-1-1])
             ;(plug-in-diffraction 1 img fill-layer .815 1.221 1.123 (+ .821 (random 2)) (+ .821 (random 2)) (+ .974 (random 2)) .610 .677 .636 .066 (+ 27.126 (random 20)) (+ -0.437 (random 2)))
             ; (plug-in-diffraction 1 img fill-layer .815 1.221 1.123 (+ .821 (random 2)) (+ .821 (random 2)) (+ .974 (random 2)) .610 .677 .636 .066 (+ 27.126 (random 20)) (+ -0.437 (random 1)))              
			  (gimp-item-set-name fill-layer "Diffraction Fill")                ; Name layer

          )
     ); endif

;
;   Fill With Glass (colored, gradient)
;
    (if (and(> fill-style 7)(< fill-style 12)) ; Check for glass fill (compensates for glass edge) 
        (begin
           (cond ((defined? 'plug-in-autocrop-layer)(plug-in-autocrop-layer 1 img fill-layer)) ; Autocrop fill layer so gradient is fully applied 
	(else (gimp-image-autocrop-selected-layers img fill-layer)))
           (set! bump-layer (car (gimp-layer-new-from-drawable fill-layer img))) ; New glass Layer
           (gimp-image-insert-layer img bump-layer 0 -1)                              ; Add it to image
           (gimp-item-set-name bump-layer "Bump")                               ; Name glass layer
           (gimp-context-set-foreground '(255 255 255))                          ; Set FG to white
           ;(gimp-drawable-edit-bucket-fill bump-layer 0 0 100 )                    ; Fill with color
	   (gimp-drawable-edit-fill fill-layer FILL-FOREGROUND)
           (apply-gauss2 img bump-layer 5 5)                                ; Blur by 5
           (gimp-context-set-foreground logo-color)                              ; Set FG to logo

           (if (= fill-style 8)   ; Glass Color Fill
             (begin
               ; (gimp-drawable-edit-bucket-fill fill-layer 0 0 100 )
	       (gimp-layer-set-opacity fill-layer 20)
			(gimp-drawable-edit-fill fill-layer FILL-FOREGROUND)
             )
           ) ; endif 

           (if (and(> fill-style 8)(< fill-style 12))   ; Glass Gradient Fill
             (begin
		 (gimp-layer-set-opacity fill-layer 20)
              (if (= fill-style 9)                      ; Vertical gradient fill
                (begin
                  (set! image-height (car (gimp-drawable-get-height fill-layer)))
                )
              ) ; endif
              (if (= fill-style 10)                      ; Horizontal gradient fill
                (begin
                   (set! image-width (car (gimp-drawable-get-width fill-layer)))
                )
              ) ; endif
             (if (= fill-style 11)                      ; Diagonal gradient fill
               (begin
                   (set! image-height (car (gimp-drawable-get-height fill-layer)))
                   (set! image-width (car (gimp-drawable-get-width fill-layer)))
               )
              ) ; endif
(gimp-context-set-gradient-reverse rev-blend)
		(gimp-drawable-edit-gradient-fill 
			fill-layer
			;BLEND-CUSTOM; Int32 - Blend Type (BLEND-FG-BG-RGB (0), BLEND-FG-BG-HSV (1), BLEND-FG-TRANSPARENT (2), BLEND-CUSTOM (3))
			;LAYER-MODE-NORMAL-LEGACY
			blend-shape  ; ; Int32 - Gradient Type (GRADIENT-LINEAR (0), GRADIENT-BILINEAR (1), GRADIENT-RADIAL (2), GRADIENT-SQUARE (3), GRADIENT-CONICAL-SYMMETRIC (4), GRADIENT-CONICAL-ASYMMETRIC (5), GRADIENT-SHAPEBURST-ANGULAR (6), GRADIENT-SHAPEBURST-SPHERICAL (7), GRADIENT-SHAPEBURST-DIMPLED (8), GRADIENT-SPIRAL-CLOCKWISE (9), GRADIENT-SPIRAL-ANTICLOCKWISE (10)
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			4
			0.50
			1 ;FALSE
			0
			0
                        image-width  ; Int32 - X Blend Ending Point  
                        image-height ; Int32 - Y Blend Ending Point
               ) ; End Blend
             )
           ) ; endif (glass gradient fill)

           (gimp-drawable-invert fill-layer TRUE)                                       ; Invert colors
	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new fill-layer "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 135 "elevation" 45 "depth" glass-depth
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 0
                                      "compensate" FALSE "invert" FALSE "type" "linear"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" bump-layer)
      (gimp-drawable-merge-filter fill-layer filter)
    ))
    (else
           (plug-in-bump-map 1 img fill-layer bump-layer 135 45 glass-depth 0 0 0 0 0 0 0))) ; Bump
           (set! saved-selection (car (gimp-selection-save img)))         ; Save selection
           (gimp-image-set-active-layer img fill-layer)                   ; Ensure layer active
           (gimp-selection-shrink img glass-depth)                        ; Shrink selection
           (gimp-selection-feather img (- glass-depth 1))                 ; Feather Selection
           ;(gimp-curves-spline fill-layer 4 4 (lt-get-glass-trans-curve 64)) ; Modify channel curves
	   (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
           (gimp-drawable-curves-spline fill-layer 4 4 (lt-get-glass-trans-curve 64)) ; Modify channel curves
(gimp-drawable-curves-spline fill-layer 4 (lt-get-glass-trans-curve 64))) ; Modify channel curves	   
           (gimp-image-select-item img 2 saved-selection)                          ; Restore Selection
           (gimp-image-remove-channel img saved-selection)                ; Remove Selection Mask
           (gimp-layer-resize-to-image-size fill-layer)                   ; Restore Fill Layer To Image Size

           (gimp-drawable-invert fill-layer TRUE)                                   ; Invert colors
           (gimp-image-remove-layer img bump-layer)                   ; Delete the bump layer
           (gimp-item-set-name fill-layer "Glass Fill")              ; Name glass layer

        )
     ) ; endif (glass fill)

;
; Bevel Fill Layer (only if bevel-amt depth is > 0) 
;
    (if (> bevel-amt 0) 
      (begin
          (script-fu-add-bevel img fill-layer bevel-amt 0 0)         ; Bevel fill layer
         (if (> bevel-2x 0)                                          ; Check for 2x Bevel
            (begin                                                   ; Double the bevel
              (set! saved-selection (car (gimp-selection-save img))) ; Save selection
              (gimp-image-set-active-layer img fill-layer)           ; Make fill layer active
              (gimp-selection-shrink img bevel-2x)                   ; Shrink by 2nd bevel offset
              (script-fu-add-bevel img fill-layer bevel-amt 0 0)     ; Bevel fill layer again
              (gimp-image-select-item img 2 saved-selection)                  ; Restore Selection
              (gimp-image-remove-channel img saved-selection)        ; Remove Selection Mask
            )
         );endif 
      )
    );endif

;
; Add bump layer only if bump depth > 0) 
;
  (if (and (> bump-depth 0)(< bump-style 4))
    (begin

        (set! overlay-pos 3)                                   ; Set pattern overlay position offset

        (gimp-image-set-active-layer img fill-layer)           ; Make fill layer active
        (set! saved-selection (car (gimp-selection-save img))) ; Save selection

        (set! bump-layer (car (gimp-layer-new-from-drawable fill-layer img)))    ; New bump Layer
        (gimp-image-insert-layer img bump-layer 0 -1)                                 ; Add it to image
        (gimp-item-set-name bump-layer "Bumped")                                ; Name bump layer

        (set! bumpmap-layer (car (gimp-layer-new-from-drawable fill-layer img))) ; New bumpmap Layer
        (gimp-image-insert-layer img bumpmap-layer 0 -1)                              ; Add it to image
        (gimp-item-set-name bumpmap-layer "Bump Map")                           ; Name bumpmap

        (if (and(> fill-style 8)(< fill-style 13))     ; Check for glass fill
            (begin
              (gimp-selection-shrink img stroke-width)  ; Shrink selection for glass edge compensate
            )
        ) ; endif 

;
; Bump 2x-bevel only
;
    (if (or(= bump-style 2)(= bump-style 3))
        (begin
         (gimp-selection-shrink img bevel-2x)                 ; Shrink by 2nd bevel offset
         (gimp-image-set-active-layer img bump-layer)         ; Make fill layer active
         (gimp-selection-invert img)                          ; Invert the selection
         (gimp-drawable-edit-clear bump-layer)                         ; Clear area
         (gimp-selection-invert img)                          ; Invert selection

        )
     ) ; endif

        (gimp-context-set-pattern bump-pattern)                  ; Make bump pattern active         
        (gimp-image-set-active-layer img bumpmap-layer)          ; Make fill layer active
       ; (gimp-drawable-edit-bucket-fill bumpmap-layer 2 0 100) ; Selection fill
	(gimp-drawable-edit-fill bumpmap-layer FILL-PATTERN)
;
; Bump Inversion Check
;
    (if (or(= bump-style 1)(= bump-style 3))
        (begin
          (set! invert-bump TRUE)         ; Set Bump Inversion Toggle to True
        )
     ) ; endif
;
; Call bump map procedure (pattern bump)
;
(gimp-selection-none img)
	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new bump-layer "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 130 "elevation" 55 "depth" bump-depth
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 0
                                      "compensate" TRUE "invert" invert-bump "type" "linear"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" bumpmap-layer)
      (gimp-drawable-merge-filter bump-layer filter)
    ))
    (else
        (plug-in-bump-map 
                     1              ; Interactive (0), non-interactive (1)
                     img            ; Input image
                     bump-layer     ; Input drawable
                     bumpmap-layer  ; Bumpmap drawable
                     130            ; Azimuth (float)
                     55             ; Elevation (float)
                     bump-depth     ; Depth
                     0              ; X offset
                     0              ; Y offset
                     0              ; Level that full transparency should represent
                     0              ; Ambient lighting factor
                     TRUE           ; Compensate for darkening
                     invert-bump    ; Invert bumpmap toggle
					 0)))
                     ;LINEAR)        ; Type of map (0=linear, 1=spherical, 2=sinusoidal)
;
; Remove bumpmap
;
        (gimp-image-remove-layer img bumpmap-layer)        ; Remove the bumpmap
        (gimp-image-set-active-layer img fill-layer)       ; Make fill layer active
        (gimp-image-select-item img 2 saved-selection)              ; Restore Selection
        (gimp-image-remove-channel img saved-selection)    ; Remove Selection Mask

   ) 
  ) ; endif (end of bump depth check) 
;
;
; Create Stroke Layer (only if stroke width > 0)
;

   (if (> stroke-width 0)
       (begin

         (set! overlay-pos 3)                                   ; Set pattern overlay position offset

         (gimp-image-set-active-layer img fill-layer)           ; Make fill layer active
         (set! saved-selection (car (gimp-selection-save img))) ; Save selection

         (set! stroke-layer (car (gimp-layer-new-from-drawable logo-layer img))) ; New Stoke Layer 
         (gimp-image-insert-layer img stroke-layer 0 0)                  ; Add it to image
         (gimp-image-set-active-layer img stroke-layer)             ; Make stroke logo layer active
         (gimp-item-set-name stroke-layer "Stroke")                ; Name the stroke layer

         (if (> stroke-offset 0) 					                    ; Stroke offset
             (begin
                (gimp-selection-shrink img stroke-offset)               ; Shrink selection by offset
                (gimp-selection-invert img)                             ; Invert the selection
                (gimp-drawable-edit-clear stroke-layer)                          ; Clear stroke layer
                (gimp-selection-invert img)                             ; Invert the selction
              )
         ); endif          
;
; Delete everything outside selection for Alpha Mode
;           
         (if (= alpha2logo 1)                                          ; Aplha stroke method
             (begin                                                    ;
               (gimp-selection-grow img 2)	                           ; Grow the selection
               (gimp-context-set-foreground stroke-color)              ; Set stroke color
               ;(gimp-drawable-edit-bucket-fill stroke-layer 0 0 100 )    ; Fill with Stroke color
	       (gimp-drawable-edit-fill stroke-layer FILL-FOREGROUND)
               (gimp-selection-shrink img 2)                           ; Shrink the selection
               (gimp-selection-invert img)                             ; Invert the selction
               (gimp-drawable-edit-clear stroke-layer)                          ; Clear stroke layer
               (gimp-selection-invert img)                             ; Invert the selction
            )
          ); endif
                                                             ; Text stroke method (always do this) 
         (gimp-selection-shrink img stroke-width)            ; Shrink by stroke width
         (gimp-drawable-edit-clear stroke-layer)                      ; Clear all but stroke

         (gimp-image-set-active-layer img fill-layer)        ; Make fill layer active
         (gimp-image-select-item img 2 saved-selection)               ; Restore Selection
         (gimp-image-remove-channel img saved-selection)     ; Remove Selection Mask
         
      )
   ) ; endif
;
; Create Background Layer 
;
;
    (if (< background-fill 4)
      (begin

        (set! saved-selection (car (gimp-selection-save img)))                ; Save selection
        (gimp-selection-none img)                                             ; Clear Selection

        (set! background (car (gimp-layer-new-from-drawable logo-layer img))) ; New layer
        (gimp-image-insert-layer img background 0 -1)                              ; Add it to image
        (script-fu-util-image-resize-from-layer img background)               ; Layer to image size
        (gimp-image-set-active-layer img background)                          ; Make BG layer active
        (gimp-drawable-edit-clear background)                                          ; Clear background
        (gimp-item-set-name background "Background")                         ; Name backgound layer

        (if (= background-fill 0)                      ; Background Pattern
          (begin 
            (gimp-context-set-pattern bg-pattern)      ; Make effect pattern active
            (gimp-drawable-fill background FILL-PATTERN)          ; Fill with pattern
          )
        )
        (if (= background-fill 1)                      ; Active Pattern
          (begin 
            (gimp-context-set-pattern current-pattern) ; Make effect pattern active
            (gimp-drawable-fill background  FILL-PATTERN )          ; Fill with pattern
          )
        )
        (if (= background-fill 2)       ; Active Gradient
          (begin 

            (set! image-height (car (gimp-drawable-get-height background)))

		(gimp-drawable-edit-gradient-fill 
			background
			;BLEND-CUSTOM; Int32 - Blend Type (BLEND-FG-BG-RGB (0), BLEND-FG-BG-HSV (1), BLEND-FG-TRANSPARENT (2), BLEND-CUSTOM (3))
			;LAYER-MODE-NORMAL-LEGACY
			GRADIENT-LINEAR  ; ; Int32 - Gradient Type (GRADIENT-LINEAR (0), GRADIENT-BILINEAR (1), GRADIENT-RADIAL (2), GRADIENT-SQUARE (3), GRADIENT-CONICAL-SYMMETRIC (4), GRADIENT-CONICAL-ASYMMETRIC (5), GRADIENT-SHAPEBURST-ANGULAR (6), GRADIENT-SHAPEBURST-SPHERICAL (7), GRADIENT-SHAPEBURST-DIMPLED (8), GRADIENT-SPIRAL-CLOCKWISE (9), GRADIENT-SPIRAL-ANTICLOCKWISE (10)
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			4
			0.50
			1 ;FALSE
			0
			0
                        image-width  ; Int32 - X Blend Ending Point  
                        image-height ; Int32 - Y Blend Ending Point
             ) ; End Blend
          )
        )

        (if (= background-fill 3)                          ; BG Color
          (begin 
            (gimp-drawable-fill background 1)              ; Fill with BG color
          )
        )
        (gimp-image-select-item img 2 saved-selection)               ; Restore Selection
        (gimp-image-remove-channel img saved-selection)     ; Remove Selection Mask
        (gimp-image-lower-item-to-bottom img background)   ; Background to botton
       )
   ) ; endif (end of background layer)
;
;
; Extrusion Layer 
;
; Calculate Direction (Degrees to 2D Vector Normal)
;
   (set! hpos (round (cos (* extru-direction (/ 3.14 180)))))
   (set! vpos (round (sin (* extru-direction (/ 3.14 180)))))
;
;
; Extrude the fill layer
;

   (if (or (= extru-type 1) (= extru-type 2)  (= extru-type 3))        ; Extrude fill layer
     (begin
       (gimp-selection-none img)                     ; Clear selection
       (gimp-image-set-active-layer img fill-layer)  ; Make fill layer active

       (set! extrusion-layer (car (gimp-layer-copy fill-layer TRUE ))) ; Copy to extrusion layer
       (gimp-image-insert-layer img extrusion-layer 0 (+ 0 (car (gimp-image-get-item-position img fill-layer))))  ; Add layer at new position
       (gimp-item-set-name extrusion-layer "Fill")   ; Name it the new fill later
       (gimp-image-set-active-layer img fill-layer)   ; Make the fill layer active
;
;        Extrusion Loop
;
         (set! layer-width (car (gimp-drawable-get-width fill-layer)))        ; Layer width              
         (set! layer-height (car (gimp-drawable-get-height fill-layer)))      ; Layer height

		  (while (> extrusion-counter 0)
            (let*
	    	    (
			      (working-layer (car (gimp-layer-copy fill-layer TRUE )))       ; Copy fill to working layer
			      (drwpos (car (gimp-image-get-item-position img fill-layer)))  ; Get position
				  (new-pos (+ drwpos 1))                                         ; Calculate insert position    
                )

                  (gimp-image-insert-layer img working-layer 0 new-pos)      ; Add layer at new position
                  (set! zoom-counter (+ zoom-counter 1))                ; Increment zoom counter

                (if (= extru-type 1)                                    ; Directional
                  (begin
                     (gimp-item-transform-2d working-layer 0 0 1 1 0 hpos vpos)
                  )
                )
                (if (= extru-type 2)                                    ; Shrink
                  (begin
                      (gimp-layer-scale working-layer (- layer-width zoom-counter) (- layer-height zoom-counter) TRUE)
                  )
                 )
		(if (= extru-type 3)                                    ; Grow
                  (begin
			(gimp-drawable-transform-scale working-layer (* -1 zoom-counter) (* -1 zoom-counter) (+ layer-width zoom-counter) (+ layer-height zoom-counter) 0 2 TRUE 3 0)

                  )
                 )

                  (set! fill-layer (car (gimp-image-merge-down img fill-layer 0))) ; Merge extrusion
                  (set! extrusion-counter (- extrusion-counter 1)) ; Decrement loop counter
              )
            ) 
	    (if (and(> fill-style 7)(< fill-style 12)) (begin (gimp-layer-set-opacity fill-layer 30) ))
          (gimp-item-set-name fill-layer "Fill Extrusion")   ; Name the Extruded Fill 

     )
   ) ;Endif Fill Extrusion

;
; Extrude Bump Layer
;
   (if (and (or (= extru-type 4)(= extru-type 5)(= extru-type 6))(< bump-style 4))     ; Extrude Bump Layer if exists
     (begin
       (gimp-selection-none img)                         ; Clear selection
       (gimp-image-set-active-layer img bump-layer)      ; Make Bump layer active

       (set! extrusion-layer (car (gimp-layer-copy bump-layer TRUE ))) ; Initialize extrusion layer
       (gimp-image-insert-layer img extrusion-layer 0 (+ 0 (car (gimp-image-get-item-position img bump-layer)))) ; Add layer at new position
       (gimp-item-set-name extrusion-layer "Bump")   ; Name the New Bump 
       (gimp-image-set-active-layer img bump-layer)   ; Make fill layer active
;
;        Extrusion Loop
;
         (set! layer-width (car (gimp-drawable-get-width bump-layer)))        ; Layer width              
         (set! layer-height (car (gimp-drawable-get-height bump-layer)))      ; Layer height

		  (while (> extrusion-counter 0)
            (let*
	    	    (
			      (working-layer (car (gimp-layer-copy bump-layer TRUE )))       ; Copy bump layer to working layer
			      (drwpos (car (gimp-image-get-item-position img bump-layer)))  ; Get position
				  (new-pos (+ drwpos 1))                                         ; Calculate insert position    
                )

                  (gimp-image-insert-layer img working-layer 0 new-pos)      ; Add layer at new position
                  (set! zoom-counter (+ zoom-counter 1))                ; Increment zoom counter

                  (if (= extru-type 4)                                    ; Directional
                   (begin
                      (gimp-item-transform-2d working-layer 0 0 1 1 0 hpos vpos)
                   )
                  )
                  (if (= extru-type 5)                                    ; Shrink
                   (begin
                      (gimp-layer-scale working-layer (- layer-width zoom-counter) (- layer-height zoom-counter) TRUE)
                   )
                  )
		 (if (= extru-type 6)                                    ; Grow
                   (begin
			(gimp-drawable-transform-scale working-layer (* -1 zoom-counter) (* -1 zoom-counter) (+ layer-width zoom-counter) (+ layer-height zoom-counter) 0 2 TRUE 3 0)

                   )
                  )

                  (set! bump-layer (car (gimp-image-merge-down img bump-layer 0))) ; Merge extrusion
                  (set! extrusion-counter (- extrusion-counter 1)) ; Decrement loop counter
              )
            ) 
          (gimp-item-set-name bump-layer "Bump Extrusion")   ; Name the Extruded Bump 
;
     )
   ) ;Endif Bump Extrusion

;
; Sanity check to ensure users doesn't attempt to extrude a bump layer that doen't exist 
;
(if (and (or (= extru-type 4)(= extru-type 5)(= extru-type 6))(= bump-style 4))       ; Extrude Bump Layer if exists
  (begin
    (lt-display_message "No Bump Layer To Extrude: Bump Layer Set To: None" 2)  
  )
  (begin
;
; Create Extrusion Overlay
;
   (if (and (> extru-type 0)(> extru-overlay 0))      ; Check For Extrusion and Overlay Options
     (begin
       (gimp-selection-none img)                      ; Clear selection
;
;       Choose Bump or Active pattern as Extrusion Overlay Pattern  
;
        (if (= extru-overlay 1)                               ; Bump Pattern
          (begin 
            (gimp-context-set-pattern bump-pattern)           ; Make Bump Pattern Active
          )
        )
        (if (= extru-overlay 2)                               ; Active Pattern
          (begin 
            (gimp-context-set-pattern current-pattern)        ; Make Current Pattern Active
          )
        )
;
;       Have We Extruded the Fill Layer or The Bump Layer?
;
        (if (or (= extru-type 1)(= extru-type 2)(= extru-type 3))             ; Active Pattern
          (begin 
            (set! pattern-overlay (car (gimp-layer-new-from-drawable fill-layer img))) ; Pattern Overlay Layer
            (gimp-drawable-fill pattern-overlay 4)            ; Fill with Overlay Pattern
            (gimp-image-set-active-layer img fill-layer)      ; Make Fill Layer Actve
            (gimp-image-select-item img 2 fill-layer)           ; Selection of Fill layer
          )
        )
        (if (or (= extru-type 4)(= extru-type 5) (= extru-type 6))             ; Bump Pattern
          (begin 
            (set! pattern-overlay (car (gimp-layer-new-from-drawable bump-layer img))) ; Pattern Overlay Layer            (gimp-context-set-pattern bump-pattern)           ; Make Bump Pattern Active
            (gimp-drawable-fill pattern-overlay 4)            ; Fill with Overlay Pattern
            (gimp-image-set-active-layer img bump-layer)      ; Make Bump Layer Actve
            (gimp-image-select-item img 2 bump-layer)           ; Selection of Bump layer
          )
        )

       (gimp-image-insert-layer img pattern-overlay 0 0)              ; Add Extrusion Pattern Overlay to Image
       (gimp-image-set-active-layer img pattern-overlay)         ; Make pattern Overlay Layer Actve
       (gimp-selection-invert img)                               ; Invert the selection
       (gimp-drawable-edit-clear pattern-overlay)                         ; Clear outside selection
       (gimp-image-raise-item-to-top img pattern-overlay)        ; Extrusion Pattern Overlay To Top
       (gimp-layer-set-mode pattern-overlay LAYER-MODE-OVERLAY-LEGACY)        ; Set to Overlay Mode
       (gimp-item-set-name pattern-overlay "Extrusion Overlay") ; Name the Extrusion Overlay
     )
   ) ; Extrusion Overlay

  ) ; End else sanity check
) ; Endif for sanity check  

;
; Create Drop Shadow  
;
;
    (if (= shadow-style 0)
      (begin
         (set! saved-selection (car (gimp-selection-save img)))               ; Save Selection
         (gimp-selection-none img)                                            ; Clear Selection

          ;Funky Scheme if-then-else clause
          (if (and (or (= extru-type 4)(= extru-type 5)(= extru-type 6))(< bump-style 4))
                ; true                                                                 ; Make Drop Shadow from Bump Layer 
                (apply-drop-shadow img bump-layer 10 10 shadow-blur '(0 0 0) 50 1) ; Create Drop Shadow
                ; else                                                                 ; Make Drop Shadow From Fill Layer   
                (apply-drop-shadow img fill-layer 10 10 shadow-blur '(0 0 0) 50 1) ; Create Drop Shadow
          )
         (gimp-image-select-item img 2 saved-selection)                               ; Restore Selection
         (gimp-image-remove-channel img saved-selection)                     ; Remove Selection Mask
       )
   ) ; endif 

;
; Create Outline Shadow (Best For Glass)  
;
;
    (if (= shadow-style 1)
      (begin
         (set! temp-layer (car (gimp-layer-new-from-drawable logo-layer img)))  ; New Temp Layer For Shadow 
         (gimp-image-insert-layer img temp-layer 0 (+ (car (gimp-image-get-item-position img fill-layer)) 1)) ; Add it
         (gimp-item-set-name temp-layer "Temp Layer")                          ; Name the Temp Layer

         (set! saved-selection (car (gimp-selection-save img)))      ; Save Selection
         (gimp-image-select-item img 2 temp-layer)                     ; Select Alpha to Logo If there isn't one

         (gimp-selection-shrink img 3)                               ; Shrink the Selection
         (gimp-drawable-edit-clear temp-layer)                                ; Clear Temp Layer

         (gimp-selection-none img)                                   ; Clear Selection
         (gimp-image-set-active-layer img temp-layer)                ; Make it active          
         (plug-in-colorify 1 img temp-layer '(0 0 0))                ; Set outline to black

         (apply-drop-shadow img temp-layer 23 18 shadow-blur '(0 0 0) 50 1)  ; Create Outline Shadow

         (gimp-image-select-item img 2 saved-selection)                       ; Restore Selection
         (gimp-image-remove-channel img saved-selection)             ; Remove Selection Mask
         (gimp-image-remove-layer img temp-layer)                    ; Remove Temp Layer
       )
   ) ; endif 
;
;
    (if (= keep-selection FALSE)               ; Check Selection Toggle
          (gimp-selection-none img)            ; Clear Selection
    )
;
 ); endlet
) ; return (from apply-logo-toolbox) 
;
;
; Define alpha to selection procedure
;
(define (script-fu-logo-toolbox300-alpha image
                                       layer
									   create-new
                                       fill-style
                                       logo-color
                                       blend-shape
                                       rev-blend
                                       glass-depth
                                       bevel-amt
                                       bevel-2x  
                                       stroke-color
                                       stroke-width
                                       stroke-offset
                                       bump-style
                                       bump-pattern
                                       bump-depth
                                       extru-type
                                       extru-depth
                                       extru-direction
                                       extru-overlay 
                                       background-fill
                                       bg-pattern  
                                       shadow-style
                                       shadow-blur
                                       keep-selection
                                       feather-amt
        )
  (let* (
          (alpha2logo 1) ; 0 - Text mode , 1 - Alpha mode
        )
	(gimp-layer-resize-to-image-size layer)
    (if (= create-new TRUE)
	    (begin(gimp-image-undo-group-start image)
		
; star layer to new image - add MrQ ----------------------------------------------------------
			(let*	(
				(active_layer (car (gimp-image-get-active-layer image)))
				(image-type (car (gimp-image-get-base-type image)))
				(width (car (gimp-drawable-get-width active_layer)))
				(height (car (gimp-drawable-get-height active_layer)))
				(new-image 0)
				(new-layer 0)
				(aa 0)
					)
				(gimp-image-undo-disable image)
				(set! new-image (car (gimp-image-new width height image-type)))
				(gimp-display-new new-image)
				(set! new-layer (car (gimp-layer-new-from-drawable layer new-image)))
				(set! aa (gimp-image-insert-layer new-image new-layer 0 0))
				(gimp-image-undo-enable image)

; end new image MrQ -----------------------------------------------------------------------------------------------------

				(apply-logo-toolbox new-image new-layer fill-style logo-color blend-shape rev-blend glass-depth bevel-amt bevel-2x stroke-color stroke-width stroke-offset bump-style bump-pattern bump-depth extru-type extru-depth extru-direction extru-overlay background-fill bg-pattern shadow-style shadow-blur keep-selection feather-amt alpha2logo)
				(gimp-image-undo-group-end image)
				;(gimp-displays-flush)
	        )	
        )
	)	
	(if (= create-new FALSE)
		(begin
			(gimp-context-push)               ; Push context onto stack
			(gimp-image-undo-group-start image) ; Begin undo group
			(apply-logo-toolbox image layer fill-style logo-color blend-shape rev-blend glass-depth bevel-amt bevel-2x stroke-color stroke-width stroke-offset bump-style bump-pattern bump-depth extru-type extru-depth extru-direction extru-overlay background-fill bg-pattern shadow-style shadow-blur keep-selection feather-amt alpha2logo)
			(gimp-image-undo-group-end image) ; End undo group
			(gimp-context-pop)               ; Push context onto stack
		)
    )


;
; Drop logo layer to bottom
;
    ;(gimp-image-lower-item-to-bottom image layer) ; layer to botton
    ;(gimp-image-set-active-layer image layer)      ; Make it active
    ;(gimp-item-set-visible layer FALSE)         ; Turn Off Logo Layer


    ;(gimp-context-pop)              ; Pop context off stack
    (gimp-displays-flush)           ; Flush display

  ) ;endlet
) ; return  

;
; Register logo to alpha procedure
;
(script-fu-register "script-fu-logo-toolbox300-alpha"
                    _"_Logo Toolbox300 alpha..."
                    _"Create selected logo with fill types and effects"
                    "GnuTux - http://gimpchat.com"
                    "GnuTux - GPLv3"
                    "05-2013"
                    "RGBA"
                    SF-IMAGE      "Image"                 0
                    SF-DRAWABLE   "Drawable"              0
					SF-TOGGLE     _"Active Layer to New Image"   TRUE
                    SF-OPTION     _"Fill Method"          '("Color" "Active Pattern" "Active Gradient (Vertical)" "Active Gradient (Horizonal)" "Active Gradient (Diagonal)" "Random Color (Plasma)" "Random Color (Patchwork)" "Random Color (Diffracton)" "Glass Color" "Glass Active Gradient (Vertical)" "Glass Active Gradient (Horizontal)" "Glass Active Gradient (Diagonal)")
                    SF-COLOR      _"Fill/Glass Color"     '(145 169 179)
                    SF-OPTION     _"Gradient Blend Shape" '("Linear" "Bilinear" "Radial" "Square" "Conical-Symmetric" "Conical-Asymmetric" "Shapeburst-Angular" "Shapeburst-Spherical" "Shapeburst-Dimpled" "Spiral-CW" "Spiral-CCW")
                    SF-TOGGLE     _"Reverse Gradient"      FALSE
					SF-ADJUSTMENT _"Glass Depth"          '(2 1 10 1 1 0 1)
                    SF-ADJUSTMENT _"Bevel Depth"          '(8 0 30 1 1 0 1)
                    SF-ADJUSTMENT _"2x Bevel Offset"      '(4 0 20 1 1 0 1)
                    SF-COLOR      _"Stroke Color"         '(0 0 0)
                    SF-ADJUSTMENT _"Stroke Width"         '(0 0 50 1 1 0 1)
                    SF-ADJUSTMENT _"Stroke Offset"        '(0 0 50 1 1 0 1)
                    SF-OPTION     _"Bump Layer"           '("Bump Pattern" "Invert Bump Pattern" "Bump Pattern 2nd Bevel Only" "Invert Bump Pattern 2nd Bevel Only" "None")
                    SF-PATTERN    _"Bump Pattern"         "Tree Bark"
                    SF-ADJUSTMENT _"Bump Depth"           '(4 0 100 1 1 0 1)
                    SF-OPTION     _"Extrusion Layer"      '("None" "Fill Layer (Directional)" "Fill Layer (Shrink)"  "Fill Layer (Grow)" "Bump Layer (Directional)" "Bump Layer (Shrink)" "Bump Layer (Grow)")
                    SF-ADJUSTMENT _"Extrusion Depth"      '(11 1 200 1 10 0 1)
                    SF-ADJUSTMENT _"Extrusion Direction"  '(45 0 360 45 45 0 1)
                    SF-OPTION     _"Extrusion Overlay"    '("None" "Bump Pattern" "Active Pattern")
                    SF-OPTION     _"Background Layer"     '("Background Pattern" "Active Pattern" "Active Gradient" "Background Color" "None")
                    SF-PATTERN    "Background pattern"   "Paper"
                    SF-OPTION     _"Shadow Style"         '("Drop Shadow" "Outline Shadow (Glass)" "None")
                    SF-ADJUSTMENT _"Shadow Blur Radius"   '(8 1 50 1 1 0 1)
                    SF-TOGGLE     _"Keep Selection"         FALSE
                    SF-ADJUSTMENT _"Global Feather"       '(0 0 6 1 1 0 1)
)

(script-fu-menu-register "script-fu-logo-toolbox300-alpha"
                         "<Image>/Filters/Alpha to Logo")

;
; Define logo text procedure
;
(define (script-fu-logo-toolbox300 text
                                 font
                                 size
								 direction
								 justification
                                 letter-spacing
                                 line-spacing
                                 fill-style
                                 logo-color
                                 blend-shape
                                 rev-blend
                                 glass-depth
                                 bevel-amt
                                 bevel-2x
                                 stroke-color
                                 stroke-width
                                 stroke-offset
                                 bump-style
                                 bump-pattern
                                 bump-depth
                                 extru-type
                                 extru-depth
                                 extru-direction
                                 extru-overlay 
                                 background-fill
                                 bg-pattern  
                                 shadow-style
                                 shadow-blur
                                 feather-amt
        )
 (let*  (
          (img -1)                                 ; Declare and Init img
          (text-layer -1)                          ; Declare and init text-layer
          (logo-layer -1)                          ; Declare and init logo-layer 
          (alpha2logo 0)			               ; 0 - Text mode , 1 - Alpha mode
          (keep-selection FALSE)                   ; Keep Selection Place Holder
		  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
        )
  
  (gimp-context-push)                              ; Push context onto stack
  (set! img (car (gimp-image-new 256 256 RGB)))    ; Create a new image

;
; Original Text Layer (keep untouched)      

   (gimp-context-set-foreground logo-color)                        ; Set FG to logo color
   (set! text-layer (car (gimp-text-fontname img -1 0 0 text (+ 25 extru-depth) TRUE size PIXELS font))) ; Create text layer
   (gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification text-layer justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing
   (gimp-text-layer-set-base-direction text-layer direction)
   (script-fu-util-image-resize-from-layer img text-layer)         ; Logo layer to image size
   (gimp-item-set-name text-layer "Text")                         ; Name text Layer
   (gimp-image-undo-group-start img)                               ; Begin undo group
                                                            
;          
; Logo layer (color with stroke color and pass to the logo procedure)  
;
  (gimp-context-set-foreground stroke-color)                       ; Set FG to stroke color

  (set! logo-layer (car (gimp-text-fontname img -1 0 0 text (+ 25 extru-depth) TRUE size PIXELS font))) ; Create logo layer
  (gimp-item-set-name logo-layer "Logo Layer")                    ; Name logo Layer
  (gimp-text-layer-set-letter-spacing logo-layer letter-spacing)   ; Set Letter Spacing
  (gimp-text-layer-set-line-spacing logo-layer line-spacing)       ; Set Line Spacing
  (gimp-text-layer-set-justification logo-layer justification) ; Text Jusification (Rev Value)
  (gimp-text-layer-set-base-direction logo-layer direction)

;
; Call the logo toolbox main procedure  with text
;
  (apply-logo-toolbox img logo-layer fill-style logo-color blend-shape rev-blend glass-depth bevel-amt bevel-2x stroke-color stroke-width stroke-offset bump-style bump-pattern bump-depth extru-type extru-depth extru-direction extru-overlay background-fill bg-pattern shadow-style shadow-blur keep-selection feather-amt alpha2logo)

    (gimp-image-remove-layer img logo-layer)        ; Delete the logo layer (stroke color duplicate)
    (gimp-image-set-active-layer img text-layer)    ; Make text layer active 
    (gimp-item-set-visible text-layer FALSE)       ; Turn Off Text Layer

    (gimp-selection-none img)       ; Clear selection
    (gimp-image-undo-group-end img) ; End undo group
    (gimp-context-pop)              ; Pop context off stack

    (gimp-display-new img)          ; Show the image

 ) ; endlet
) ; return

;
; Register the script
;    
(script-fu-register "script-fu-logo-toolbox300"
                    _"_Logo Toolbox 300.."
                    _"Create logo with selected fill types and effects"
                    "GnuTux - http://gimpchat.com"
                    "GnuTux - GPLv3"
                    "05-2013"
                    ""
                    SF-TEXT       _"Text"                  "Logo\nToolBox"
                    SF-FONT       _"Font"                  sffont
					SF-ADJUSTMENT _"Font size (pixels)"    '(220 10 1000 1 10 0 1) 
				    SF-OPTION     _"Direction"             '("From left to right"  "From right to left" "Vertical, right to left (mixed orientation)" "Vertical, right to left (upright orientation)" "Vertical, left to right (mixed orientation)" "Vertical, left to right (upright orientation)")		
                    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
				    SF-ADJUSTMENT _"Letter Spacing"        '(-10 -50 50 1 5 0 1)
                    SF-ADJUSTMENT _"Line Spacing"          '(-10 -300 300 1 10 0 1)
                    SF-OPTION     _"Fill Method"           '("Color" "Active Pattern" "Active Gradient (Vertical)" "Active Gradient (Horizonal)" "Active Gradient (Diagonal)" "Random Color (Plasma)" "Random Color (Patchwork)" "Random Color (Diffracton)" "Glass Color" "Glass Active Gradient (Vertical)" "Glass Active Gradient (Horizontal)" "Glass Active Gradient (Diagonal)")
                    SF-COLOR      _"Fill/Glass Color"      '(145 169 179)
                    SF-OPTION     _"Gradient Blend Shape"  '("Linear" "Bilinear" "Radial" "Square" "Conical-Symmetric" "Conical-Asymmetric" "Shapeburst-Angular" "Shapeburst-Spherical" "Shapeburst-Dimpled" "Spiral-CW" "Spiral-CCW")
                    SF-TOGGLE     _"Reverse Gradient"      FALSE
					SF-ADJUSTMENT _"Glass Depth"           '(2 1 10 1 1 0 1)
                    SF-ADJUSTMENT _"Bevel Depth"           '(8 0 30 1 1 0 1)
                    SF-ADJUSTMENT _"2x Bevel Offset"       '(4 0 20 1 1 0 1)
                    SF-COLOR      _"Stroke Color"          '(53 67 71)
                    SF-ADJUSTMENT _"Stroke Width"          '(1 0 50 1 1 0 1)
                    SF-ADJUSTMENT _"Stroke Offset"         '(0 0 50 1 1 0 1)
                    SF-OPTION     _"Bump Layer"            '("Bump Pattern" "Invert Bump Pattern" "Bump Pattern 2nd Bevel Only" "Invert Bump Pattern 2nd Bevel Only" "None")
                    SF-PATTERN    _"Bump Pattern"          "Tree Bark"
                    SF-ADJUSTMENT _"Bump Depth"            '(4 0 100 1 1 0 1)
                    SF-OPTION     _"Extrusion Layer"       '("None" "Fill Layer (Directional)" "Fill Layer (Shrink)"  "Fill Layer (Grow)" "Bump Layer (Directional)" "Bump Layer (Shrink)"  "Bump Layer (Grow)")
                    SF-ADJUSTMENT _"Extrusion Depth"       '(11 1 200 1 10 0 1)
                    SF-ADJUSTMENT _"Extrusion Direction"   '(45 0 360 45 45 0 1)
                    SF-OPTION     _"Extrusion Overlay"     '("None" "Bump Pattern" "Active Pattern")
                    SF-OPTION     _"Background Layer"      '("Background Pattern" "Active Pattern" "Active Gradient" "Background Color" "None")
                    SF-PATTERN    "Background pattern"    "Paper"
                    SF-OPTION     _"Shadow Style"          '("Drop Shadow" "Outline Shadow (Glass)" "None")
                    SF-ADJUSTMENT _"Shadow Blur Radius"    '(8 1 50 1 1 0 1)
                    SF-ADJUSTMENT _"Global Feather"        '(0 0 6 1 1 0 1)
)

(script-fu-menu-register "script-fu-logo-toolbox300"
                         _"<Image>/File/Create/Logos/")
