;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Gradient Stroke V1.6
;
; This Script creates a gradient stroke by copying the selected layer. filling with selected gradient,
; shrinking by the stroke width, then clearing the remainder of the image.
; If no selection is detected, the script performs Alpha to Selection.
; Otherwise, the script uses the existing selection.
; Fully compatible with GIMP 2.10.x, GIMP 2.8.x layer groups and GIMP 2.6.x
;     
;
;
; Created by GnuTux & Graechan
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
; ------------
;| Change Log |
; ------------
; V .90 - Beta Release
; V .91 - Fixed selection issues
; V .92 - Proper position in stack
;         Make Compatible with GIMP 2.8 & 2.6
;         Keep Script's Selection
; V .93 - Fixed Bug Where Gradient Wasn't Being Fully Applied
; V 1.0 - Added Angle & Scale
;         Added Inner/Outer Stroke Option
;         Added Option To Bump Stroke
; V 1.1 - Fixed Bug With Outer Stroke
; V 1.2 - Add Back Original Blend Directions + Angle & Scale
;         Stroke Width = 0 Becomes Gradient Fill (Per Request)
; V 1.3 - Add Option To Set Bump Depth
;         Fix Issue When No Alpha Channel Exists
;         Default Gradient Set To Metallic Something
; V 1.4 - Graduated Stroke Positioning
;         Keep Selection: Active, Inner, Outer or None
; V 1.5 - Update CUSTOM To BLEND-CUSTOM
;         Update LINEAR To TRUE
; V 1.6 little fix for 2.10 32
;
;Define Main Procedure
;
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(define (script-fu-gradient-stroke

            img               ; Image
            drawable          ; Drawable
            stroke-width      ; Stroke Width (0=Fill)
            stroke-pos        ; Stroke Position (0=Inner <---> 100=Outer)
            sel-gradient      ; Selected Gradient
            rev-gradient      ; Reverse Gradient
            paint-mode        ; Blend Mode
            blend-shape       ; Blend Shape
            blend-repeat      ; Blend Repeat
            blend-direction   ; Blend Direction
            blend-angle       ; Blend Angle
            gradient-scale    ; Gradient Scale
            blend-offset      ; Blend Offset
            bump-depth        ; Bump Depth (0=None)
            keep-selection    ; Keep New Selection
        )

  (let*
    (
      (stroke-layer -1)      ; Stroke layer
      (image-height 0)       ; Drawable Height
      (image-width 0)        ; Drawable Width
      (tsw 0)                ; Temp Stroke Width
      (xblend-start 0)       ; X Blend Starting Point
      (yblend-start 0)       ; Y Blend Starting Point
      (xblend-end 0)         ; X Blend Ending Point
      (yblend-end 0)         ; Y Blend Ending Point
      (in-pos 0)             ; Positin of Selected Drawable In Stack
      (sel-flag 0)           ; Selection Flag
      (saved-selection 0)    ; Saved Incoming Selection
      (saved-inner 0)        ; Saved Inner Selection
      (saved-outer 0)        ; Saved Outer Selction
      (radians 0)            ; Radians
      (x-distance 0)         ; X Distance
      (y-distance 0)         ; Y Distance
      (x-center 0)           ; X Center
      (y-center 0)           ; Y Center
    )
;
; Save Context
;
(gimp-context-push)

; Start Undo Group

(gimp-image-undo-group-start img)

;
; Define GIMP 2.8.x Layer Group Procedures That Do Not Exists In GIMP 2.6.x
; Allows Layer Group Support in GIMP 2.8.x while maintaining backward compatibility with GIMP 2.6.x
;
(if (not (defined? 'gimp-image-get-item-position))              ; Check for get-item-posiiton
    (begin
        (define (gimp-image-get-item-position image layer)       ; Define it, if it doesn't exist
            (gimp-image-get-item-position image layer)          ; Call get-layer-postion for GIMP 2.6.x
        )
    )
);endif
(if (not (defined? 'gimp-image-insert-layer))                   ; Check for image-insert-layer
    (begin
       (define (gimp-image-insert-layer image layer ignored pos) ; Define it, if it doesn't exist
           (gimp-image-insert-layer image layer 0 pos) ; Call image-add-layer for GIMP 2.6.x
       )
    )
  );endif
(if (not (defined? 'gimp-item-get-parent))        ; Check for item-get-parent
    (begin
       (define (gimp-item-get-parent layer)        ; Define it, if it doesn't exist
        (cons #f #f)                               ; Return a pair
       )
    )
  );endif

;
; Position of incoming drawable in layer stack
;
  (set! in-pos (car (gimp-image-get-item-position img drawable)))

;
; Selection Check
;

    (if (= (car (gimp-selection-is-empty img)) TRUE)      ; Check For A Selection
        (begin
          (gimp-selection-layer-alpha drawable)           ; Alpha To Selection (if there is no selection)
        )
       (begin
         (set! sel-flag 1)                                ; Set Selection Flag to True
       )
     ) ; endif

         (set! saved-selection (car (gimp-selection-save img))) ; Save The Incoming Selection
         (set! stroke-layer (car (gimp-layer-new-from-drawable drawable img))) ; New Stoke Layer
         (gimp-layer-add-alpha stroke-layer)                                   ; Add Alpha Channel
         (gimp-image-insert-layer img stroke-layer (car (gimp-item-get-parent drawable)) in-pos) ; Add it
         (gimp-image-set-active-layer img stroke-layer)                        ; Make Stroke Layer Active
         (gimp-layer-set-name stroke-layer "Gradient Stroke")                  ; Name Layer

         (plug-in-autocrop-layer 1 img stroke-layer)   ; Autocrop Stroke Layer So Gradient Fully Applied

     (if (and (= stroke-width 1) (> stroke-pos 0))     ; Handle Case of 1px Stroke
          (set! stroke-pos 100)
     ) 

     (if (> stroke-pos 0)                                                 ; Not A Fill
         (begin
           (set! tsw (* (* (/ stroke-width 100) stroke-pos) 2))           ; Temp Stroke Width
           (set! image-height (car (gimp-drawable-get-height stroke-layer)))  ; Get Stroke Layer Height
           (set! image-width (car (gimp-drawable-get-width stroke-layer)))    ; Get Stroke layer Width
            ; Compensate For Outer Stroke
           (gimp-layer-resize stroke-layer (+ tsw image-width) (+ tsw image-height) (/ tsw 2) (/ tsw 2))
         )   
     )

     (set! image-height (car (gimp-drawable-get-height stroke-layer)))       ; Get Stroke Layer Height
     (set! image-width (car (gimp-drawable-get-width stroke-layer)))         ; Get Stroke layer Width
;
; Blend Direction
;
(cond ((= blend-direction 0)               ; Top-Bottom
          (set! xblend-start 0)            ; X Blend Starting Point
          (set! yblend-start 0)            ; Y Blend Starting Point
          (set! xblend-end 0)              ; X Blend Ending Point
          (set! yblend-end image-height)   ; Y Blend Ending Point
          )
          ((= blend-direction 1)           ; Bottom-Top
          (set! xblend-start 0)            ; X Blend Starting Point
          (set! yblend-start image-height) ; Y Blend Starting Point
          (set! xblend-end 0)              ; X Blend Ending Point
          (set! yblend-end 0)              ; Y Blend Ending Point
          )
          ((= blend-direction 2)           ; Left-Right
          (set! xblend-start 0)            ; X Blend Starting Point
          (set! yblend-start 0)            ; Y Blend Starting Point
          (set! xblend-end image-width)    ; X Blend Ending Point
          (set! yblend-end 0)              ; Y Blend Ending Point
          )
          ((= blend-direction 3)           ; Right-Left
          (set! xblend-start image-width)  ; X Blend Starting Point
          (set! yblend-start 0)            ; Y Blend Starting Point
          (set! xblend-end 0)              ; X Blend Ending Point
          (set! yblend-end 0)              ; Y Blend Ending Point
          )
          ((= blend-direction 4)           ; Diag-Top-Left
          (set! xblend-start 0)            ; X Blend Starting Point
          (set! yblend-start 0)            ; Y Blend Starting Point
          (set! xblend-end image-width)    ; X Blend Ending Point
          (set! yblend-end image-height)   ; Y Blend Ending Point
          )
          ((= blend-direction 5)           ; Diag-Top-Right
          (set! xblend-start image-width)  ; X Blend Starting Point
          (set! yblend-start 0)            ; Y Blend Starting Point
          (set! xblend-end 0)              ; X Blend Ending Point
          (set! yblend-end image-height)   ; Y Blend Ending Point
          )
          ((= blend-direction 6)           ; Diag-Bottom-Left
          (set! xblend-start 0)            ; X Blend Starting Point
          (set! yblend-start image-height) ; Y Blend Starting Point
          (set! xblend-end image-width)    ; X Blend Ending Point
          (set! yblend-end 0)              ; Y Blend Ending Point
          )
          ((= blend-direction 7)           ; Diag-Bottom-Right
          (set! xblend-start image-width)  ; X Blend Starting Point
          (set! yblend-start image-height) ; Y Blend Starting Point
          (set! xblend-end 0)              ; X Blend Ending Point
          (set! yblend-end 0)              ; Y Blend Ending Point
          )
(else
;
; Calculate Gradient Blend Start & End Points
; Based on angle and scale technique from iccii effects     
;
      (set! radians (/ (* 2 *pi* blend-angle) 360))                       ; Convert Blend Angle to Radians 
      (set! x-distance (* 0.5 gradient-scale image-width (sin radians)))  ; Calculate X Distance
      (set! y-distance (* 0.5 gradient-scale image-height (cos radians))) ; Calculate Y Distance
      (set! x-center (/ image-width 2))                                   ; X Center     
      (set! y-center (/ image-height 2))                                  ; Y Center
      (set! xblend-start (- x-center x-distance))                         ; X Starting Blend Point
      (set! yblend-start (- y-center y-distance))                         ; Y Starting Blend Point 
      (set! xblend-end (+ x-center x-distance))                           ; X Ending Blend Point
      (set! yblend-end (+ y-center y-distance))                           ; Y Ending Blend Point
)
) ;end cond

;
; Fill with Gradient
;
     (if (> stroke-pos 0)                               ; Position Outer Stroke
          (begin
             (gimp-selection-grow img (/ tsw 2))        ; Grow Selection For Outer Stroke
          )   
     )
     (set! saved-outer (car (gimp-selection-save img))) ; Save Outer Selection
     (gimp-context-set-gradient sel-gradient)           ; Make selected gradient active

             (gimp-edit-blend        ; Blend (Gradient)
                        stroke-layer ; Drawable - (The affected drawable)
                        BLEND-CUSTOM       ; Int32 - Blend Type (BLEND-FG-BG-RGB (0))
                        paint-mode   ; Int32 - Paint Mode (LAYER-MODE-NORMAL-LEGACY (0))
                        blend-shape  ; Int32 - Gradient Type (LINEAR (0))
                        100          ; Float - Opacity (0 - 100)
                        blend-offset ; Float - Offset ( >= 0)
                        blend-repeat ; Int32 - Repeat (NONE (0))
                        rev-gradient ; Int32 - Reverse (TRUE or FALSE)
                        TRUE         ; Int32 - Supersample (TRUE or FALSE)
                        3            ; Int32 - Supersampling Recursion  Dept (1 - 9)
                        0.25         ; Float - Supersampling threshold (0 <= 4)
                        TRUE         ; Int32 - Dither (TRUE or FALSE)
                        xblend-start ; Int32 - X Blend Starting Point
                        yblend-start ; Int32 - Y Blend Starting Point
                        xblend-end   ; Int32 - X Blend Ending Point 
                        yblend-end   ; Int32 - Y Blend Ending Point
             ) ; End Blend

     (if (> stroke-pos 0)                                           ; Position Inner Stroke
          (begin
             (gimp-selection-load saved-selection)                  ; Restore Selection
             (gimp-selection-shrink img (- stroke-width (/ tsw 2))) ; Shrink By Position Offset 
          )  
          ;else
          (begin         
             (gimp-selection-shrink img stroke-width)       ; Shrink Selection By Offset
          )
     )

    (set! saved-inner (car (gimp-selection-save img)))      ; Save Inner Selection

    (if (> stroke-width 0) (begin 
             (gimp-drawable-edit-clear stroke-layer)                 ; Clear stroke layer If Stroke Width > 0
             (gimp-selection-load saved-selection))         ; Restore The Selection
    )
             (gimp-layer-resize-to-image-size stroke-layer) ; Restore Fill Layer To Image Size
;
; Selection Checks
;
     (if (= keep-selection 0)                               ; Keep Active Selection 
         (begin
           (if (= sel-flag 1)                               ; Check For Initial Selection
               (gimp-selection-load saved-selection)        ; Restore Selection
               ;else
                 (gimp-selection-clear img)                 ; Clear Script's Selection
            ); endif
         ) 
     ) ; endif

     (gimp-image-remove-channel img saved-selection)        ; Remove The Saved Selection Channel

     (if (= keep-selection 1)                               ; Keep Selection Inner
         (begin
                (gimp-selection-load saved-inner)           ; Restore Inner
                (gimp-image-remove-channel img saved-inner) ; Remove The Save Inner Selection Channel
         ) 
     ) ; endif

     (if (= keep-selection 2)                                ; Keep Selection Outer
         (begin
                 (gimp-selection-load saved-outer)           ; Restore Outer
                 (gimp-image-remove-channel img saved-outer) ; Remove The Save Outer Selection Channel
         ) 
     ) ; endif

     (if (= keep-selection 3)                                ; Keep Selection None
         (begin
           (if (= sel-flag 1)                                ; Check For Initial Selection
              (set! sel-flag 0)                              ; Clear Selection Flag
           ) 
          (gimp-selection-clear img)                         ; Clear The Selection
         ) 
     ) ; endif
;
; Bump The Stroke
;
(if (> bump-depth 0)
     (begin
        (if (= (car (gimp-selection-is-empty img)) FALSE)           ; Check For A Selection
           (begin
             (set! sel-flag 1)                                      ; Set Selection Flag to True
             (set! saved-selection (car (gimp-selection-save img))) ; Save The Current Selection
             (gimp-selection-clear img)                             ; Clear The Selection For Bumping 
           ) 
        )

        (plug-in-bump-map
                     1              ; Interactive (0), non-interactive (1)
                     img            ; Input image
                     stroke-layer   ; Input drawable
                     stroke-layer   ; Bumpmap drawable
                     135            ; Azimuth (float)
                     65             ; Elevation (float)
                     bump-depth     ; Depth
                     0              ; X offset
                     0              ; Y offset
                     0              ; Level that full transparency should represent
                     0              ; Ambient lighting factor
                     TRUE           ; Compensate for darkening
                     FALSE          ; Invert bumpmap toggle
                     TRUE)          ; Type of map (0=linear, 1=spherical, 2=sinusoidal)

        (if (= sel-flag 1)                        ; Check Selection Flag
            (gimp-selection-load saved-selection) ; Restore The Incoming Selection
        )
     )
); endif

(gimp-image-set-active-layer img drawable)        ; Make Incoming Drawable Active

;
; End Undo Group
;
(gimp-image-undo-group-end img)

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
; Register Gradient Stroke
;
(script-fu-register "script-fu-gradient-stroke"
         "Gradient Stroke"
         "Gradient Stroke"
         "GnuTux & Graechan - http://gimpchat.com"
         "GnuTux & Graechan - GPLv3"
         "July, 2014"
         "RGB*"
         SF-IMAGE       "Image"                    0
         SF-DRAWABLE    "Drawable"                 0
         SF-ADJUSTMENT _"Stroke Width (0=Fill) "   '(5 0 100 1 1 0 0)
         SF-ADJUSTMENT _"Inner=0...Outer=100 "    '(0 0 100 1 10 0 0)
         SF-GRADIENT   _"Select Gradient"          "Metallic Something"
         SF-TOGGLE     _"Reverse Gradient"          FALSE
         SF-OPTION     _"Blending Mode"            '("Normal" "Dissolve" "Behind" "Multiply" "Screen" "Overlay" "Difference" "Addition" "Subtract" "Darken" "Lighten" "Hue" "Saturation" "Color" "Value" "Divide" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge")
         SF-OPTION     _"Blend Shape"              '("Linear" "Bilinear" "Radial" "Square" "Conical-Symmetric" "Conical-Asymmetric" "Shapeburst-Angular" "Shapeburst-Spherical" "Shapeburst-Dimpled" "Spiral-CW" "Spiral-CCW")
         SF-OPTION     _"Blend Repeat"             '("None" "Sawtooth" "Triangular")
         SF-OPTION     _"Blend Direction"          '("Top To Botton" "Bottom To Top" "Left To Right" "Right To Left" "Diagonal From Top Left" "Diagonal From Top Right" "Diagonal From Bottom Left" "Diagonal From Bottom Right" "Use Angle & Scale Options")
         SF-ADJUSTMENT _"Blend Angle"              '(0 0 360 1 45 0 0)
         SF-ADJUSTMENT _"Gradient Scale"           '(1.00 0.05 5 0.05 0.1 2 0)
         SF-ADJUSTMENT _"Blend Offset"             '(0 0 500 1 10 0 0)
         SF-ADJUSTMENT _"Bump Depth (0=none) "     '(0 0 10 1 1 0 0)
         SF-OPTION     _"Keep Selection"           '("Active Selection" "Inner Edge" "Outer Edge" "None")
) ;End register

(script-fu-menu-register "script-fu-gradient-stroke" "<Image>/Filters/Decor/")