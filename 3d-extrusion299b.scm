; 3D Extrusion - Release V2.4 
;
; This script extrudes the image or selection in a given layer 
; Supports bump mapping & extrusion via 2D drawable transform
; Option To Invert Bump Map 
; Option To Create Pattern Overlay & Extrude With A Pattern
; Directional, Shrink & Zoom Extrusion Options
; Option To Merge Extrusion
; Layer Group Support In GIMP 2.8.x 
; Backward Compatible With GIMP 2.6.x
; (Procedures Deprecated) GIMP 2.10.x 
;
;
; Created by GnuTux
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
; ------------
;| Change Log |
; ------------ 
;
;V1.0 - Modified, Translated & Documented Old Make 3D Script by Frans Rijven
;       Fix Image Types & Redo/Undo options
;       Improved User Interface 
;       Add Bump Map Type Option  
;V2.0 - Abandon Old Make 3D Script And Perform A Complete Rewrite 
;       Properly Support All Bump Mapping Options
;       Option To Create Pattern Overlay 
;       Option For Directional Extrusions
;       Option To Merge Extrusion Layer
;V2.1 - Simplify Merge Options
;       Add Zoom & Shrink Extrusions
;V2.2 - Option To Grow Along The X-Axis 
;V2.3 - Option To Extrude With Selected Pattern
;       Improve Overlay Code
;       Add Layer Group Support While Maintaining Backward Compatibilty With GIMP 2.6.x 
;       Ensure Correct Relative Layer Positions of All Newly Added layers In Stack
;V2.4 - For GIMP 2.10.x (Procedures Deprecated) 
;       (gimp-layer-set-mode)
;V2.5 - Fix for GIMP 2.99.6 
; 
; Define 3D Extrude Aplha
;
(define (script-fu-3d-extrude299 img
                              drawable
                              ext-type
                              ext-depth
                              ext-direction
                              bump-azimuth
                              bump-elevation
                              bump-depth
                              bump-ambient
                              bump-type
                              bump-invert
                              keep-layers
                              overlay-with-pattern
                              extrude-with-pattern
                              extrusion-pattern
        )
;
  (let* (
           (in-layer -1)                    ; Incoming layer
           (in-pos 0)                       ; Position of incoming layer in layer stack 
           (extrusion-layer -1)             ; Extrusion layer
           (pattern-overlay -1)             ; Extrusion Pattern Overlay
           (temp-layer -1)                  ; Temp Layer Used To Create Pattern Overlay 
           (saved-selection -1)             ; Saved Selection
           (invert-bump FALSE)              ; Inverted Bump Map
           (image-height 0)                 ; Image Height
           (image-width 0)                  ; Image Width
           (extrusion-counter ext-depth)    ; Number of layers to extrude
           (layer-width -1)                 ; Incoming layer width
           (layer-height -1)                ; Incoming layer height
           (hpos 0)                         ; Extrusion Horizontal Position
           (vpos 0)                         ; Extrusion Verical Position
           (zoom-counter 0)                 ; Point Zoom Counter
        )
;
; Save current values
; 

  (gimp-context-push)                               ; Push context onto stack
  ;(gimp-image-undo-group-start img)                 ; Begin undo group

;
;           Define GIMP 2.8.x Layer Group Procedures That Do Not Exists In GIMP 2.6.x
; This allows Layer Group Support in GIMP 2.8.x while maintaining backward compatibility with GIMP 2.6.x
;
 (if (not (defined? 'gimp-image-get-item-position))         ; Check for get-item-posiiton
    (begin
        (define (gimp-image-get-item-position image layer)  ; Define it, if it doesn't exist
            (gimp-image-get-layer-position image layer)     ; Call get-layer-postion for GIMP 2.6.x
        )
    )
 );endif

 (if (not (defined? 'gimp-image-insert-layer))                   ; Check for image-insert-layer
    (begin
       (define (gimp-image-insert-layer image layer ignored pos) ; Define it, if it doesn't exist
           (gimp-image-add-layer image layer pos)                ; Call image-add-layer for GIMP 2.6.x 
       )
    )
  );endif

 (if (not (defined? 'gimp-item-get-linked))                   ; Check for item-get-linked
    (begin
       (define (gimp-item-get-linked layer)                   ; Define it, if it doesn't exist
           (gimp-layer-get-linked layer)                      ; Call layer-get-linked for GIMP 2.6.x 
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
; Overlay Incoming Layer/Selection With Extrusion Pattern Using Multiplay Mode (To Enable Extrusion With A Pattern)
;
   (if (= extrude-with-pattern TRUE)                                         ; Extrude With Pattern?
     (begin

       (set! saved-selection (car (gimp-selection-save img)))                ; Save selection
       (gimp-selection-none img)                                             ; Clear selection
       (set! pattern-overlay (car (gimp-layer-copy drawable TRUE)))          ; Copy incoming drawable Pattern Overlay
       (gimp-image-insert-layer img pattern-overlay (car (gimp-item-get-parent drawable)) in-pos)     ; Add layer at new position
       ;(gimp-image-set-active-layer img pattern-overlay)                     ; Make pattern overlay layer actve
       (gimp-drawable-edit-clear pattern-overlay)                                     ; Clear Layer
       (gimp-context-set-pattern extrusion-pattern)                          ; Make overlay pattern active
       (gimp-drawable-fill pattern-overlay 4)                                ; Fill with pattern
       (gimp-layer-set-mode pattern-overlay LAYER-MODE-MULTIPLY)                   ; Set overlay pattern to Multiply Mode
       (gimp-brightness-contrast drawable -0.5 -0.5)                           ; Make drawable white So Multiply acts like Fill
       (set! drawable (car (gimp-image-merge-down img pattern-overlay 0)))   ; Merge pattern down

       (gimp-image-select-item img 2 saved-selection)                                 ; Restore Selection
       (gimp-image-remove-channel img saved-selection)                       ; Remove Selection Mask

     )
   ) ; End Pattern Extrusion 

;
; Selection Check
;
(gimp-layer-resize-to-image-size drawable)
    (if (= (car (gimp-selection-is-empty img)) TRUE)      ; Check for a selection 
        (begin
          ;(gimp-selection-layer-alpha drawable)           ; Alpha to Selection (if needed)
        (gimp-image-select-item img 2 drawable)
	)
     ) ; endif

;
; Create layer to hold incomimng drawable
;
  (set! in-layer (car (gimp-layer-new-from-drawable drawable img)))   ; New Layer 
  (gimp-image-insert-layer img in-layer (car (gimp-item-get-parent drawable)) (+ in-pos 1))   ; Add it
  ;(gimp-image-set-active-layer img in-layer)                          ; Make it active
  (gimp-selection-invert img)                                         ; Invert 
  (gimp-drawable-edit-clear in-layer)                                          ; Clear away eveything outside selection 
  (gimp-selection-invert img)                                         ; Invert 
  
  (gimp-layer-resize-to-image-size in-layer) ; RESIZE LEVEL AUTOMATICALLY FOR NEWBIES
  
  (gimp-item-set-name in-layer "Incoming Layer")                     ; Name layer

;
;
; Calculate Extrusion Direction (Degrees to 2D Vector Normal)
;
   (set! hpos (round (cos (* ext-direction (/ 3.14 180)))))
   (set! vpos (round (sin (* ext-direction (/ 3.14 180)))))
;
;
; Extrude the copy of the incoming drawable 
;

       (gimp-selection-none img)                                     ; Clear selection
       ;(gimp-image-set-active-layer img in-layer)                    ; Make incoming layer active

;
; Bump the incoming layer for extrusion 
;
        (plug-in-bump-map 
                     1              ; Interactive (0), non-interactive (1)
                     img            ; Input image
                     in-layer       ; Input drawable (incoming layer)
                     in-layer       ; Bumpmap drawable (incoming layer)
                     bump-azimuth   ; Azimuth (float)
                     bump-elevation ; Elevation (float)
                     bump-depth     ; Depth
                     0              ; X offset
                     0              ; Y offset
                     0              ; Level that full transparency should represent
                     bump-ambient   ; Ambient lighting factor
                     TRUE           ; Compensate for darkening
                     bump-invert    ; Invert bumpmap toggle
                     bump-type)     ; Type of map (0=linear, 1=spherical, 2=sinusoidal)

;
; Extrusion The Layer or Selection
;
         (set! layer-width (car (gimp-drawable-get-width in-layer)))        ; Layer width              
         (set! layer-height (car (gimp-drawable-get-height in-layer)))      ; Layer height

		  (while (> extrusion-counter 0)                                ; Begin Extrusion Loop 
            (let*
	    	    (
			      (working-layer (car (gimp-layer-copy in-layer TRUE )))       ; Copy fill to working layer
			      (drwpos (car (gimp-image-get-item-position img in-layer)))  ; Get position
				  (new-pos (+ drwpos 1))                                       ; Layer stack position
                )

                  (gimp-image-insert-layer img working-layer (car (gimp-item-get-parent drawable)) new-pos)  ; Add layer at new position
                  (set! zoom-counter (+ zoom-counter 1))                         ; Increment zoom counter

             (if (= ext-type 0)                                                  ; Directional
               (begin
                 ; (gimp-drawable-transform-2d-default working-layer 0 0 1 1 0 hpos vpos TRUE 0)
		  (gimp-item-transform-2d working-layer  0 0 1 1 0  hpos vpos)
               )
             )
             (if (= ext-type 1)                                                 ; Shrink
               (begin
                   (gimp-layer-scale working-layer (- layer-width zoom-counter) (- layer-height zoom-counter) TRUE)
               )
              )
             (if (= ext-type 2)                                                 ; Grow
               (begin
                  ;(gimp-drawable-transform-scale working-layer (* -1 zoom-counter) (* -1 zoom-counter) (+ layer-width zoom-counter) (+ layer-height zoom-counter) 0 2 TRUE 3 0)
		  (gimp-item-transform-scale working-layer (* -1 zoom-counter) (* -1 zoom-counter) (+ layer-width zoom-counter) (+ layer-height zoom-counter))
               )
              )
             (if (= ext-type 3)                                                 ; Grow Along X-Axis Only
               (begin
                 ; (gimp-drawable-transform-scale working-layer (* -1 zoom-counter) (* -1 0) (+ layer-width zoom-counter) (+ layer-height 0) 0 2 TRUE 3 0)
		  (gimp-item-transform-scale working-layer (* -1 zoom-counter) (* -1 0) (+ layer-width zoom-counter) (+ layer-height 0))
               )
              )

                  (set! in-layer (car (gimp-image-merge-down img in-layer 0))) ; Merge extrusion
                  (set! extrusion-counter (- extrusion-counter 1))             ; Decrement loop counter

            ) ;End Let
          ) ; End While

;
; Name Extrusion Layer
;
        (if (= extrude-with-pattern TRUE)   ; Extrude With pattern?
                ; True 
               (gimp-item-set-name in-layer "Pattern Extrusion")      ; Name The Pattern Extrusion Layer
                ; Else
               (gimp-item-set-name in-layer "Extrusion")              ; Name The Standard Extrusion Layer
        )

;
;  Pattern Overlay
;
   (if (= overlay-with-pattern TRUE)                                ; Overlay check
     (begin

       (set! saved-selection (car (gimp-selection-save img)))                ; Save selection
       (gimp-selection-none img)                                             ; Clear selection
       (set! pattern-overlay (car (gimp-layer-copy in-layer TRUE)))          ; Copy Extrusion layer to Pattern Overlay 
       (set! temp-layer (car (gimp-layer-copy in-layer TRUE)))               ; Copy Extrusion layer to temp layer
       (gimp-image-insert-layer img pattern-overlay (car (gimp-item-get-parent drawable))in-pos)    ; Add layer at new position
       (gimp-image-insert-layer img temp-layer (car (gimp-item-get-parent drawable)) in-pos)             ; Add layer at new position
       ;(gimp-image-set-active-layer img temp-layer)                          ; Make temp layer actve
       (gimp-drawable-edit-clear temp-layer)                                          ; Clear temp Layer
       (gimp-context-set-pattern extrusion-pattern)                          ; Make overlay pattern active
       (gimp-drawable-fill temp-layer 4)                                     ; Fill temp layer with pattern
       (gimp-layer-set-mode temp-layer LAYER-MODE-MULTIPLY)                        ; Set temp layer to Multiply Mode
       (gimp-brightness-contrast pattern-overlay -0.5 -0.5)                    ; Make Pattern Overlay white So Multiply acts like Fill
       (set! pattern-overlay (car (gimp-image-merge-down img temp-layer 0))) ; Merge temp layer down
       (gimp-layer-set-mode pattern-overlay LAYER-MODE-OVERLAY)                    ; Set overlay pattern to Overlay-Mode

       (gimp-image-select-item img 2 saved-selection)                                 ; Restore Selection
       (gimp-image-remove-channel img saved-selection)                       ; Remove Selection Mask

       (gimp-item-set-name pattern-overlay "Pattern Overlay")               ; Name the Extrusion Pattern Overlay

     )
   ) ; End Pattern Overlay

;
; Merge Extrusion
;
   (if (= keep-layers TRUE)                                        ; Merge check
     (begin
       (gimp-image-merge-down img drawable 0)                      ; Merge it
     )
   ) 
;
; Clean up
;
  ;(gimp-image-undo-group-end img) ; End undo group
  (gimp-context-pop)              ; Pop context off stack
  (gimp-displays-flush)           ; Flush changes to display

;
;
 ); endlet
) ; return (from script-fu-3d-extrude299) 


;
; Register Script-Fu 3D Extrude 
;
(script-fu-register 
                   "script-fu-3d-extrude299"  
		"3D Extrusion 299b"                   
                   "3D Extrusion Of Image or Selection"
                   "GnuTux"                                         
                   "GPLv3"                                         
                   "2014 "                                         
                   "RGB*" 
                    SF-IMAGE        "Image"                -1
                    SF-DRAWABLE     "Drawable"             -1
                    SF-OPTION       _"Extrusion Type"      '("Directional" "Shrink" "Grow" "Grow Along X-Axis")
                    SF-ADJUSTMENT   _"Extrusion Depth"     '(10 1 200 .1 1 2 0)
                    SF-ADJUSTMENT   _"Extrusion Direction" '(135 0 360 45 45 0 1)
                    SF-ADJUSTMENT   _"Bump Azimuth"        '(125 0 360 1 10 2 0)
                    SF-ADJUSTMENT   _"Bump Elevation"      '(45 .5 90 .1 1 2 0)
                    SF-ADJUSTMENT   _"Bump Depth"          '(1 1 65 1 5 0 0)
                    SF-ADJUSTMENT   _"Bump Ambient Light"  '(.3 0 1 .01 .45 2 0)
                    SF-OPTION       _"Bump Curve"          '("Linear" "Spherical" "Sinusoidal")
                    SF-TOGGLE       _"Invert Bump"          FALSE           
                    SF-TOGGLE       _"Merge Extrusion"      FALSE
                    SF-TOGGLE       _"Overlay With Pattern" FALSE
                    SF-TOGGLE       _"Extrude With Pattern" FALSE
                    SF-PATTERN      _"Extrusion Pattern"    "Dried mud"             
)
(script-fu-menu-register
"script-fu-3d-extrude299" 
"<Image>/Filters/Render")
