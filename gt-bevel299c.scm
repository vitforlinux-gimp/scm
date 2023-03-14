;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove
; and a little by hands
; GT Bevel V1.1
; 
; This script is an enhanced version of GIMP's add bevel script. 
;
; Created by GnuTux 
; Comments directed to http://gimpchat.com
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
; ------------
;| Change Log |
; ------------ 
; V0.90 - Initial Beta Release 
; V0.91 - Place Bevel On Separate Layer
; V1.0  - Initial Release
; V1.1  - For GIMP 2.10.xx (Procedures Deprecated)  
;         (gimp-layer-new)
;         (gimp-edit-bucket-fill)
; V299 fix for Gimp 2.99.6 and 2.10.22
; v299b finally works
; v299c fix for Gimp 2.99.12


; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))

;Define Main Procedure
;
(define (script-fu-gt-bevel299 
 
                           img               ; Image
                           in-layer          ; Drawable
                           bump-curve        ; Bump Curve
                           bevel-depth       ; Bevel Depth
                           bump-depth        ; Bump Depth
                           bump-azimuth      ; Bump Azimuth
                           bump-elevation    ; Bump Elevation 
                           bump-ambient      ; Bump Ambient Light
                           stretch-contrast  ; Stretch Contrast
                           bump-invert       ; Bump Invert Flag
                           keep-layers       ; Keep Bumpmap
        )
;
;Declare Variables
;
    (let* 
      (
	     (height 0)            ; Drawable Height
         (width 0)             ; Drawable Width
         (bump-layer -1)       ; Bumpmap Layer
         (bevel-layer -1)      ; Bevel Layer
         (saved-selection -1)  ; Saved Selection
         (saved-flag FALSE)    ; Saved Selection Flag   
         (in-layer-pos -1)     ; Current Slected Layer Position
         (loop-counter 1)      ; Loop Counter
         (bump-color 0)        ; Bumpmap Fill Color
         (layer-offsets 0)     ; Layer Offset From Image 
      )
;
; Save Context
; 
(gimp-context-push)

;
; Start Undo Group
;
;(gimp-image-undo-group-start img)
;
; Selection Check
;
    (if (= (car (gimp-selection-is-empty img)) TRUE)                       ; Check For A Selection 
        (begin
            (gimp-image-select-item img 2 in-layer)                          ; Select Alpha to Logo
        )
         (begin ; else
            (set! saved-selection (car (gimp-selection-save img)))         ; Save Selection
            (set! saved-flag TRUE)                                         ; Set Saved Selecion Flag
         )  
     ) ; endif

;
; Determine Layer Size
;
     (set! width (car (gimp-drawable-get-width in-layer)))     ; Active Layer Width 
     (set! height (car (gimp-drawable-get-height in-layer)))   ; Active Layer Height
     (set! layer-offsets (gimp-drawable-get-offsets in-layer)) ; Active Layer Offsets
   
;
; Create New Bevel Layer
; 
    (set! bevel-layer (car (gimp-layer-new img width height RGBA-IMAGE "Bevel" 100 LAYER-MODE-NORMAL)))
    (set! in-layer-pos (car (gimp-image-get-item-position img in-layer)))         ; Get Incomimg Layer Position   
    (gimp-image-insert-layer img bevel-layer 0 in-layer-pos)                       ; Insert Bevel layer
    (gimp-layer-set-offsets bevel-layer (car layer-offsets) (cadr layer-offsets))  ; Compensate For An Offset Layer
    (gimp-context-set-background '(127 127 127))                                   ; Set BG Color to Gray
    (gimp-drawable-edit-fill bevel-layer FILL-BACKGROUND) ; Fill Bevel Layer With Gray 
   ; (gimp-drawable-edit-bucket-fill bevel-layer FILL-BACKGROUND 0 0) ; Fill Bevel Layer With Gray 
;
; Create New Bumpmap Layer 
;
    (set! bump-layer (car (gimp-layer-new img width height RGB-IMAGE "Bumpmap" 100 LAYER-MODE-NORMAL)))
    (set! in-layer-pos (car (gimp-image-get-item-position img in-layer)))       ; Get Incomimg Layer Position   
    (gimp-image-insert-layer img bump-layer 0 (+ in-layer-pos 1))                ; Insert Bevel layer
    (gimp-layer-set-offsets bump-layer (car layer-offsets) (cadr layer-offsets)) ; Compensate For An Offset Layer

    (while (< loop-counter bevel-depth)
             (set! bump-color (/ (* loop-counter 255) bevel-depth))                  ; Bump Fill Color 
             (gimp-context-set-background (list bump-color bump-color bump-color))   ; Set Fill Color to BG

             ; If Selection Empty There Is No Space To Fill, So Don't
             (if (= (car (gimp-selection-is-empty img)) FALSE)                              
               (gimp-drawable-edit-fill bump-layer FILL-BACKGROUND) ; Fill Slice 
              ; (gimp-drawable-edit-bucket-fill bump-layer FILL-BACKGROUND 0 0) ; Fill Slice
    )

             (gimp-selection-shrink img 1)              ; Shrink the selection for next sliver
             (set! loop-counter (+ loop-counter 1))     ; Increment Loop Counter
    ) ; loop
;
; Bumpmap Incoming Layer
;
        (if (= stretch-contrast TRUE)
            (plug-in-autostretch-hsv 1 img bump-layer)  ;Stretch Contrast 
        )

        (gimp-selection-none img)   ; Clear the selection

        (plug-in-bump-map 
                     1              ; Interactive (0), Non-interactive (1)
                     img            ; Input Image
                     bevel-layer    ; Bevel Layer (Input Drawable)
                     bump-layer     ; Bumpmap Drawable
                     bump-azimuth   ; Azimuth (float)
                     bump-elevation ; Elevation (float)
                     bump-depth     ; Depth
                     0              ; X Offset
                     0              ; Y Offset
                     0              ; Level That Full Transparency Should Represent
                     bump-ambient   ; Ambient Lighting Factor
                     TRUE           ; Compensate for Darkening
                     bump-invert    ; Invert Bumpmap Toggle
                     bump-curve)    ; Type of Mmap (0=linear, 1=spherical, 2=sinusoidal)

        (gimp-item-set-visible bump-layer FALSE)            ; Set Bumpmap To Not Visible
        (plug-in-colortoalpha 1 img bevel-layer '(127 127 127)) ; Remove BG Gray Leaving Only Bevel
        ;(gimp-image-set-active-layer img bevel-layer)           ; Make Bevel Layer Active
;
; Remove Bumpmap
;
        (if (= keep-layers FALSE)
          (begin
            (gimp-image-merge-down img bevel-layer EXPAND-AS-NECESSARY) ; Merge Down Bevel Layer
            (gimp-image-remove-layer img bump-layer)                    ; Remove The Bumpmap Layer
          )
        )
;
; Check For A Saved Selection
;
        (if (= saved-flag TRUE)
          (begin
            (gimp-image-select-item img 0 saved-selection) ; Restore Selection
          )
        )
;
; End Undo Group
;
;(gimp-image-undo-group-end img)

;
; Restore Context 
;
(gimp-context-pop)

;
; Update Display
;
(gimp-displays-flush)

   ) ; End let
) ; End Main Procedure 

;
; Register GT Bevel Script
;
(script-fu-register "script-fu-gt-bevel299"
			"GT Bevel 299c..."
			" Bevel The Selected Layer"
			"GnuTux - http://gimpchat.com"
			"GnuTux - GPLv3"
			"April, 2015"
			"RGB*"
			SF-IMAGE        "Image"                 0
			SF-DRAWABLE     "Drawable"              0
            SF-OPTION       _"Bevel Slope"         '("Flat" "Curved" "Sinus")
            SF-ADJUSTMENT   _"Bevel Width"         '(10 0 200 1 2 0 0)
            SF-ADJUSTMENT   _"Bevel Height"        '(15 1 65 1 5 0 0)
            SF-ADJUSTMENT   _"Light Direction"     '(135 0 360 1 45 0 0)
            SF-ADJUSTMENT   _"Light Distance"      '(45 .5 90 .5 1 1 0)
            SF-ADJUSTMENT   _"Ambient Light"       '(.5 0 1 .01 0.05 2 0)
            SF-TOGGLE       _"Stretch Contrast"     FALSE
            SF-TOGGLE       _"Invert Bumpmap"       FALSE
            SF-TOGGLE       _"Keep Layers"          FALSE
) ;End register 
(script-fu-menu-register "script-fu-gt-bevel299"
			"<Image>/Filters/Decor/")
