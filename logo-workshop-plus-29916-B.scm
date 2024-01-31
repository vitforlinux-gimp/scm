;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Logo Workshop Release Candidate Version RC 0.04 (10-2011) 
;
; Created by GnuTux 
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
; RC 0.01 - Initial Release Candidate  
; RC 0.02 - Code clean-up, keep user selection, more descriptive variable names, eliminate tabs from source
;           Add gloss layer and glass layer
; RC 0.03 - All elements on separate layers, Stroke to path implemented, allow shadow to be toggled off 
; RC 0.04 - Dumped stroke to path, code optimization, dialog tweak, double stroke, double bevel, added   
;           three new effects (cubism, olify & plasma) to fill layer, proper layer arrangement
; 
; Define the apply logo effect procedure
;
(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image 1 (vector drawable)))))


(define (apply-logo-workshop-plus-299b16 img
                             logo-layer
                             fill-style
                             logo-color
			     logo-pattern
			     logo-gradient
			     logo-gradient-rvs
                             bevel-amt
			     stroke-type
                             stroke-color
			      stroke-pattern
			      stroke-gradient
			     stroke-gradient-rvs
                             stroke-width
                             shadow-color
                             shadowx
                             shadowy
                             shadow-opacity
                             effect-style
                             effect-pattern
                             effect-depth
                             alpha2logo)
  (let* (
           (stroke-layer -1)  ; Stroke layer
           (bump-layer -1)    ; Bump Map layer
           (effect-layer -1)  ; Effect layer
           (fill-layer -1)    ; Fill layer
           (feather-amt 3)    ; Set global feather 
           (sindex 0)         ; Stroke index counter 
        )

;
;  Logo layer
;
;    (script-fu-util-image-resize-from-layer img logo-layer)        ; logo layer to image size
;    (gimp-item-set-name logo-layer "Logo Layer")                  ; Name logo Layer

;
; Create Shadow Layer (only if opacity > 0)
;
   (if (> shadow-opacity 0)
       (begin 
        (script-fu-drop-shadow img logo-layer shadowx shadowy 3 shadow-color shadow-opacity 1) ; Create shadow
        )
     ) ; endif  

;
; Selection Check
;

    (if (= (car (gimp-selection-is-empty img)) TRUE)                ; Check for a selection 
        (begin
          (gimp-image-select-item img 2 logo-layer)                   ; Select alpha to logo If there isn't one
        )
     ) ; endif
;
; Create Stroke Layer (only if stroke width > 0)
;

   (if (> stroke-width 0)
       (begin 
         (set! stroke-layer (car (gimp-layer-new-from-drawable logo-layer img))) ; New Stoke Layer 
         (gimp-image-insert-layer img stroke-layer 0 0) ; Add it to image
         (gimp-image-set-active-layer img stroke-layer)                          ; Make stroke logo layer active
         (gimp-item-set-name stroke-layer "Stroke")  
	(gimp-layer-resize-to-image-size stroke-layer)	 ; Name the stroke layer
         (gimp-selection-feather img feather-amt)   ; Feather the selection

         (if (= effect-style 5) 					; Double stroke 
             (begin          
                (gimp-selection-shrink img effect-depth)
                (gimp-selection-invert img)                             ; Invert the selction
                (gimp-drawable-edit-clear stroke-layer)                          ; Clear stroke layer
                (gimp-selection-invert img)                             ; Invert the selction
				      (gimp-layer-resize-to-image-size stroke-layer)

              )
         ); endif          
           
        ; (if (= alpha2logo 1)                                          ; Aplha stroke method
             (begin
               (gimp-selection-grow img 2)	                       ; Grow the selection
              ; (gimp-context-set-foreground stroke-color)              ; Set stroke color
               ;(gimp-drawable-edit-bucket-fill stroke-layer 0 0 0)    ; Fill with Stroke color
		;(gimp-layer-resize-to-image-size stroke-layer)
		(plug-in-autocrop-layer 1 img stroke-layer)
		;(gimp-drawable-edit-fill stroke-layer FILL-FOREGROUND)
		    (cond ((= stroke-type 0)
            (gimp-context-set-foreground stroke-color)            ; Set logo color
            ;(gimp-drawable-edit-bucket-fill stroke-layer 0  0 0)  ; Fill with color
	    (gimp-drawable-edit-fill stroke-layer FILL-FOREGROUND)
          )
          ((= stroke-type 1)
	  (gimp-context-set-pattern stroke-pattern)    
            ;(gimp-drawable-edit-bucket-fill stroke-layer 4  0 0)  ; Fill with pattern)
	    (gimp-drawable-edit-fill stroke-layer FILL-PATTERN)
          )
	((= stroke-type 2)
	  (gimp-context-set-gradient stroke-gradient)
		(gimp-context-set-gradient-reverse stroke-gradient-rvs)
		      (gimp-drawable-edit-gradient-fill stroke-layer GRADIENT-LINEAR 0 0 100 0 0 0 0 0 (car (gimp-drawable-get-height stroke-layer))) ; Fill with gradient
          )
          (else
                      ;(gimp-edit-blend stroke-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 0 FALSE TRUE 3 0.20 TRUE 0 0 0 (car (gimp-drawable-height stroke-layer))) ; Fill with gradient
		      (gimp-drawable-edit-gradient-fill stroke-layer GRADIENT-LINEAR 0 0 100 0 0 0 0 0 (car (gimp-drawable-get-height stroke-layer))) ; Fill with gradient
          )
    )
    (gimp-layer-resize-to-image-size stroke-layer)
               (gimp-selection-shrink img 2)                           ; Shrink the selection
               (gimp-selection-invert img)                             ; Invert the selction
               (gimp-drawable-edit-clear stroke-layer)                          ; Clear stroke layer
               (gimp-selection-invert img)                             ; Invert the selction
            )
       ;   ); endif
                                                             ; Text stroke method (always do this) 
         (gimp-selection-shrink img stroke-width)            ; Shrink by stroke width
         (gimp-drawable-edit-clear stroke-layer)                      ; Clear all but stroke
      )
   ) ; endif

;
; Create fill layer to hold fill style
;

  (set! fill-layer (car (gimp-layer-new-from-drawable logo-layer img)))   ; New Fill Layer 
  (gimp-image-insert-layer img fill-layer 0 1) ; Add it to image
  (gimp-image-set-active-layer img fill-layer)                            ; Make fill layer active
  (gimp-layer-resize-to-image-size fill-layer)
  (gimp-selection-invert img)                                             ; Invert the stroke selection
  (gimp-drawable-edit-clear fill-layer)                                            ; Clear stroke area
  (gimp-selection-invert img)                                             ; Invert the stroke selection
  (gimp-item-set-name fill-layer "Fill")                                 ; Name fill layer
;
; Fill case structure (0-logo color fill, 1-current pattern, 2-current gradient) 
(gimp-context-set-paint-mode 0)
;
    (cond ((= fill-style 0)
            (gimp-context-set-foreground logo-color)            ; Set logo color
            ;(gimp-drawable-edit-bucket-fill fill-layer 0  0 0)  ; Fill with color
	    (gimp-drawable-edit-fill fill-layer FILL-FOREGROUND)
          )
          ((= fill-style 1)
	  (gimp-context-set-pattern logo-pattern)    
            ;(gimp-drawable-edit-bucket-fill fill-layer 4  0 0)  ; Fill with pattern)
	    (gimp-drawable-edit-fill fill-layer FILL-PATTERN)
          )
	((= fill-style 2)
	(gimp-context-set-foreground logo-color) 	    (gimp-drawable-edit-fill fill-layer FILL-FOREGROUND)


			(plug-in-autocrop-layer 1 img fill-layer)

	  (gimp-context-set-gradient logo-gradient)   (gimp-context-set-gradient-reverse logo-gradient-rvs)
(gimp-drawable-edit-fill fill-layer FILL-FOREGROUND)

		      (gimp-drawable-edit-gradient-fill fill-layer GRADIENT-LINEAR 0 0 100 0 0 0 0 0 (car (gimp-drawable-get-height fill-layer))) ; Fill with gradient
		            (gimp-layer-resize-to-image-size fill-layer)

          )
          (else
                      ;(gimp-edit-blend fill-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 0 FALSE TRUE 3 0.20 TRUE 0 0 0 (car (gimp-drawable-height fill-layer))) ; Fill with gradient
		      (gimp-drawable-edit-gradient-fill fill-layer GRADIENT-LINEAR 0 0 100 0 0 0 0 0 (car (gimp-drawable-get-height fill-layer))) ; Fill with gradient
          )
    )

;
; Apply additional effects directly to fill style
;
    (cond ((= effect-style 6)
            (plug-in-cubism 1 img fill-layer effect-depth 3 0)               ; Add cubism effect
          )         
          ((= effect-style 7)
               (plug-in-oilify 1 img fill-layer effect-depth 0)              ; Add olify effect
          )
          ((= effect-style 8)
          (gimp-selection-none img)
          (gimp-layer-set-lock-alpha fill-layer TRUE)
             (plug-in-plasma 1 img fill-layer (rand 999999999) effect-depth) ; Add plasma
          )
	  ((= effect-style 9) ;Glitter
		(plug-in-rgb-noise 1 img fill-layer  FALSE FALSE 0.6 0.6 0.6 0)
		(plug-in-cubism 1 img fill-layer 1 5 0)               ; Add cubism effect
          )
    )
          (gimp-image-select-item img 2 stroke-layer)
      (gimp-drawable-edit-clear logo-layer)
      (gimp-image-select-item img 2 logo-layer); a little trick for gt-bevel
;
; bevel (only if bevel-amt depth is > 0) 
;
    (if (> bevel-amt 0) 
      (begin
         (script-fu-add-bevel img fill-layer bevel-amt 0 0)         ; Bevel fill layer
         (if (= effect-style 4)                                     ; Effect case test
            (begin                                                  ; Double bevel
              (gimp-selection-shrink img stroke-width)              ; Shrink by stroke width
              (script-fu-add-bevel img fill-layer bevel-amt 0 0)    ; Bevel fill layer again
              (gimp-selection-grow img stroke-width)                ; Reset by stroke width
            )
         );endif 
      )
    );endif

;
; Pattern Bump (only if bump depth > 0 and additional effect = 1) 
;
    (if (and(> effect-depth 0)(= effect-style 1)) 
      (begin

        (set! effect-layer (car (gimp-layer-new-from-drawable fill-layer img))) ; New effect Layer
        (gimp-image-insert-layer img effect-layer 0 -1) ; Add it to image
        (gimp-item-set-name effect-layer "Bumped")                             ; Name effect layer


        (set! bump-layer (car (gimp-layer-new-from-drawable fill-layer img))) ; New patten layer
        (gimp-context-set-pattern effect-pattern)                             ; Make bump pattern active         
        (gimp-drawable-fill bump-layer FILL-PATTERN)                                     ; Fill with pattern
;
; Call bump map procedure (pattern bump)
;
        (plug-in-bump-map 
                     1              ; Interactive (0), non-interactive (1)
                     img            ; Input image
                     effect-layer   ; Input drawable
                     bump-layer     ; Bumpmap drawable
                     130            ; Azimuth (float)
                     55             ; Elevation (float)
                     effect-depth   ; Depth
                     0              ; X offset
                     0              ; Y offset
                     0              ; Level that full transparency should represent
                     0              ; Ambient lighting factor
                     TRUE           ; Compensate for darkening
                     FALSE          ; Invert bumpmap
                    0)        ; Type of map (0=linear, 1=spherical, 2=sinusoidal)
      )
    ) ; endif
;
; Create Gloss Effect Layer 
;
;
   (if (and(> effect-depth 0)(= effect-style 2)) 
      (begin

           (set! bump-layer (car (gimp-layer-new-from-drawable logo-layer img))) ; New effect Layer
           (gimp-image-insert-layer img bump-layer 0 -1) ; Add it to image
           (gimp-item-set-name bump-layer "Gloss")                              ; Name effect layer
           (gimp-selection-shrink img (- effect-depth 4))                        ; Shrink selection
           (gimp-context-set-foreground '(255 255 255))                          ; Set FG to white
           (gimp-drawable-edit-bucket-fill bump-layer 0 0 0)                    ; Fill with color
           (plug-in-gauss 1 img bump-layer 5 5 1)                                ; Blur by 3
           (gimp-selection-invert img)                                           ; Invert Selection
           (gimp-drawable-edit-clear bump-layer)                                          ; Clear all but gloss
           (gimp-layer-set-opacity bump-layer (- effect-depth 1))                ; Set Opacity     

       )
   ) ; endif 
;
; Create Glass Effect Layer 
;
;
   (if (and(> effect-depth 0)(= effect-style 3)) 
      (begin

           (set! bump-layer (car (gimp-layer-new-from-drawable logo-layer img))) ; New effect Layer
           (gimp-image-insert-layer img bump-layer 0 -1) ; Add it to image
           (gimp-item-set-name bump-layer "Bump")                               ; Name effect layer
           (gimp-context-set-foreground '(255 255 255))           ; Set FG to white
           (gimp-drawable-edit-bucket-fill bump-layer 0 0 0)     ; Fill with color
           (plug-in-gauss 1 img bump-layer 5 5 1)                 ; Blur by 5

           (set! effect-layer (car (gimp-layer-new-from-drawable logo-layer img))) ; New patten layer
           (gimp-image-insert-layer img effect-layer 0 -1) ; Add it to image
           (gimp-item-set-name effect-layer "Glass")                              ; Name effect layer

           (plug-in-bump-map 1 img effect-layer bump-layer 135 45 (+ effect-depth 0) 0 0 0 0 0 0 0) ; Bump it

           (gimp-image-set-active-layer img effect-layer)                    ; Ensure this layer active
           (gimp-selection-shrink img (- effect-depth 1))                    ; Shrink selection
           (gimp-selection-feather img feather-amt)                          ; feather it
           (gimp-drawable-curves-spline effect-layer 4 4 (get-glass-trans-curve 64))  ; Modify alpha channel curves

           (gimp-selection-none img)					; Clear Selection
           (gimp-drawable-hue-saturation effect-layer 0 0 0 -100 0)                ; Desaturate to clear glass 
           (gimp-drawable-invert effect-layer FALSE)                                   ; Invert colors
           (gimp-image-remove-layer img bump-layer)                     ; Delete the bump layer
;           (plug-in-sample-colorize 1 img effect-layer logo-layer TRUE TRUE TRUE TRUE  0 255 1 0 255) 
;           (gimp-image-remove-layer img bump-layer)                     ; Dump The Bump 

       )
   ) ; endif 

  ); endlet
) ; return (from apply-logo-workshop-plus-299b16) 
;
;
; Define function for glass translucency values
;
(define (get-glass-trans-curve parm)
  (let* ((curve-value (cons-array 4 'byte)))
   (aset curve-value 0 0)
   (aset curve-value 1 0)
   (aset curve-value 2 255)
   (aset curve-value 3 parm)
   curve-value     
   )
) ; return

;
; Define alpha to selection procedure
;
(define (script-fu-logo-workshop-plus-299b-alpha img
                                       logo-layer
                                       fill-style
                                       logo-color
				       logo-pattern
				       logo-gradient
				       logo-gradient-rvs
                                       bevel-amt
				       stroke-type
                                       stroke-color
				        stroke-pattern
					stroke-gradient
					stroke-gradient-rvs					
                                       stroke-width
                                       shadow-color
                                       shadowx
                                       shadowy
                                       shadow-opacity
                                       effect-style
                                       effect-pattern
                                       effect-depth)
  (let* (
          (alpha2logo 1) ; 0 - Text mode , 1 - Alpha mode
        )

;
; Save current GIMP context
;
    (gimp-context-push)               ; Push context onto stack
    (gimp-image-undo-group-start img) ; Begin undo group
;
; Call apply logo effect procedure  
;
    (apply-logo-workshop-plus-299b16 img logo-layer fill-style logo-color logo-pattern logo-gradient logo-gradient-rvs bevel-amt stroke-type stroke-color  stroke-pattern stroke-gradient stroke-gradient-rvs stroke-width shadow-color shadowx shadowy shadow-opacity effect-style effect-pattern effect-depth alpha2logo)

;
; Drop logo layer to bottom
;
    (gimp-image-lower-item-to-bottom img logo-layer) ; layer to botton
    (gimp-item-set-visible logo-layer FALSE)      ; Toggle layer off
    (gimp-image-set-active-layer img logo-layer)      ; Make it active 


    (gimp-image-undo-group-end img) ; End undo group
    (gimp-context-pop)              ; Pop context off stack
    (gimp-displays-flush)           ; Flush display

  ) ;endlet
) ; return  

;
; Register logo effect to alpha procedure
;
(script-fu-register "script-fu-logo-workshop-plus-299b-alpha"
                    _"_Logo Workshop PLUS ALPHA 299 B..."
                    _"Create selected logo effect with a drop shadow"
                    "GnuTux - http://gimpchat.com"
                    "GnuTux - GPLv3"
                    "10-2011"
                    "RGBA"
                    SF-IMAGE      "Image"                 0
                    SF-DRAWABLE   "Drawable"              0
                    SF-OPTION     _"Logo Fill Method"     '("Color Fill" "Fill With Pattern" "Fill With Gradient")
                    SF-COLOR      _"Logo Fill Color"      '(23 131 181)
		    SF-PATTERN	    "Logo Fill Pattern"				"Burlwood"
		    SF-GRADIENT   "Logo Fill Gradient" "Yellow Orange"
		    SF-TOGGLE "Gradient Reverse" FALSE
                    SF-ADJUSTMENT _"Logo Bevel Depth"    '(10 0 50 1 1 0 0)
		    SF-OPTION     _"Stroke Fill Method"     '("Color" "Pattern" "Gradient")
                    SF-COLOR      _"Stroke Color"         '(9 45 68)
		    SF-PATTERN	   "Stroke Pattern"				"Wood #2"
		    SF-GRADIENT   "Stroke Gradient" "Golden"
		    SF-TOGGLE "Gradient Reverse" FALSE
                    SF-ADJUSTMENT _"Stroke Width"         '(3 0 19 1 1 0 0)
                    SF-COLOR      _"Shadow Color"         '(0 0 0)
                    SF-ADJUSTMENT _"Shadow Offset X"      '(-6 -99 99 1 1 0 0)
                    SF-ADJUSTMENT _"Shadow Offset Y"      '(4 -99 99 1 1 0 0)
                    SF-ADJUSTMENT _"Shadow Opacity"       '(25 0 100 1 1 0 0)
                    SF-OPTION     _"Added Effect"         '("None" "Bump With Pattern" "Simple Gloss Layer" "Translucent/Glass Layer" "Double Bevel" "Double Stroke" "Cubism on Fill" "Oilify on Fill" "Plasma on fill" "Glitter on fill")
                    SF-PATTERN    _"Added Effect Pattern" "Bricks"
                    SF-ADJUSTMENT _"Added Effect Depth"   '(7 0 50 1 1 0 0))

(script-fu-menu-register "script-fu-logo-workshop-plus-299b-alpha"
                         "<Image>/Filters/Alpha to Logo")

;
; Define logo effect text procedure
;
(define (script-fu-logo-workshop-plus-299b text
                                 size
                                 font 
								 justification
                                 letter-spacing
                                 line-spacing
				grow-text
				outline				 
                                 fill-style
                                 logo-color
				 logo-pattern
				 logo-gradient
				 logo-gradient-rvs
                                 bevel-amt
				 stroke-type
                                 stroke-color
				  stroke-pattern
				  stroke-gradient
				stroke-gradient-rvs
                                 stroke-width
                                 shadow-color
                                 shadowx
                                 shadowy
                                 shadow-opacity
                                 effect-style
                                 effect-pattern
                                 effect-depth
				 inBufferAmount
				back-type
                                back-color
				back-pattern
				back-gradient 
				 )
 (let* (
		        (theImageWidth  10)
        (theImageHeight 10)
        (img)
	        (img
                  (car
                      (gimp-image-new
                        theImageWidth
                        theImageHeight
                        RGB
                      )
                  )
        )
         ; (img (car (gimp-image-new 256 256 RGB))) ; Create a new image
          (text-layer -1)                          ; Declare and init text-layer
          (logo-layer -1)                          ; Declare and init logo-layer 
	          (bg-layer
                  (car
                      (gimp-layer-new
                        img
                        theImageWidth
                        theImageHeight
                        RGBA-IMAGE
                        "Background"
                        100
                        LAYER-MODE-NORMAL
                      )
                  )
        )
	  (theBuffer 0 )           ;create a new layer for the image
          (alpha2logo 0)			   ; 0 - Text mode , 1 - Alpha mode
	  		  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
        )
        (gimp-image-insert-layer img bg-layer 0 0)

  (gimp-context-push)                          ; Push context onto stack

;
; Original Text Layer (keep untouched)
;
   (gimp-context-set-foreground logo-color)   ; Set FG to logo color
   (set! text-layer (car (gimp-text-fontname img -1 0 0 text 10 TRUE size PIXELS font))) ; Create text layer
   (script-fu-util-image-resize-from-layer img text-layer)  ; logo layer to image size
      (gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification text-layer justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing
   (gimp-item-set-name text-layer "Text")                  ; Name text Layer
   
           (set! theImageWidth   (car (gimp-drawable-get-width  text-layer) ) )
      (set! theImageHeight  (car (gimp-drawable-get-height text-layer) ) )
      (set! theBuffer (* theImageHeight (/ inBufferAmount 100) ) )
      (set! theImageHeight (+ theImageHeight theBuffer theBuffer) )
      (set! theImageWidth  (+ theImageWidth  theBuffer theBuffer) )
      (gimp-image-resize img theImageWidth theImageHeight 0 0)
      (gimp-layer-resize text-layer theImageWidth theImageHeight 0 0)
      (gimp-layer-set-offsets text-layer theBuffer theBuffer)
      (gimp-layer-resize-to-image-size text-layer)
   
   ;;;; shrink grow text
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
		; (gimp-image-resize-to-layers img)
	(gimp-selection-shrink img (round outline))   
	(gimp-drawable-edit-clear text-layer)
	(gimp-image-select-item img 2 text-layer)
 ))
   
   
;
; Logo layer (color woth stroke color and pass to the logo effects procedure)  
;
  (gimp-context-set-foreground stroke-color)   ; Set FG to stroke color
  (set! logo-layer (car (gimp-text-fontname img -1 0 0 text 10 TRUE size PIXELS font))) ; Create logo layer
  (script-fu-util-image-resize-from-layer img logo-layer)  ; logo layer to image size
  (gimp-item-set-name logo-layer "Logo Layer")            ; Name logo Layer
    (gimp-text-layer-set-letter-spacing logo-layer letter-spacing)   ; Set Letter Spacing
  (gimp-text-layer-set-line-spacing logo-layer line-spacing)       ; Set Line Spacing
  (gimp-text-layer-set-justification logo-layer justification) ; Text Jusification (Rev Value)
  
          (set! theImageWidth   (car (gimp-drawable-get-width  logo-layer) ) )
      (set! theImageHeight  (car (gimp-drawable-get-height logo-layer) ) )
      (set! theBuffer (* theImageHeight (/ inBufferAmount 100) ) )
      (set! theImageHeight (+ theImageHeight theBuffer theBuffer) )
      (set! theImageWidth  (+ theImageWidth  theBuffer theBuffer) )
      (gimp-image-resize img theImageWidth theImageHeight 0 0)
      (gimp-layer-resize logo-layer theImageWidth theImageHeight 0 0)
      (gimp-layer-set-offsets logo-layer theBuffer theBuffer) 
  
  ;;;; shrink grow text
(cond ((> grow-text 0)
	(gimp-selection-none img)
		; (gimp-image-resize-to-layers img)
	(gimp-image-select-item img 2  logo-layer)
	(gimp-selection-grow img (round grow-text))   
	(gimp-drawable-edit-fill  logo-layer FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none img)
		 ;(gimp-image-resize-to-layers img)
	(gimp-image-select-item img 2  logo-layer)
	(gimp-drawable-edit-clear  logo-layer)
	(gimp-selection-shrink img (- grow-text))   
	(gimp-drawable-edit-fill  logo-layer FILL-FOREGROUND)	
 ))
 
   ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none img)
	(gimp-image-select-item img 2  logo-layer)
		 ;(gimp-image-resize-to-layers img)
	(gimp-selection-shrink img (round outline))   
	(gimp-drawable-edit-clear  logo-layer)
	(gimp-image-select-item img 2  logo-layer)
 ))

      (gimp-layer-resize-to-image-size bg-layer)

  (gimp-image-undo-disable img)                ; Disallow undo 
  ;(gimp-image-resize-to-layers img)
  
 ;   
 
;
; Call the logo effect procedure 
;
  (apply-logo-workshop-plus-299b16 img logo-layer fill-style logo-color logo-pattern logo-gradient logo-gradient-rvs bevel-amt stroke-type stroke-color stroke-pattern stroke-gradient stroke-gradient-rvs stroke-width shadow-color shadowx shadowy shadow-opacity effect-style effect-pattern effect-depth alpha2logo)
(gimp-selection-all img)   		   
		   (cond ((= back-type 0)
            (gimp-context-set-foreground back-color)            ; Set logo color
            ;(gimp-drawable-edit-bucket-fill bg-layer 0  0 0)  ; Fill with color
	    (gimp-drawable-edit-fill bg-layer FILL-FOREGROUND)
          )
          ((= back-type 1)
	  (gimp-context-set-pattern back-pattern)    
            ;(gimp-drawable-edit-bucket-fill bg-layer 4  0 0)  ; Fill with pattern)
	    (gimp-drawable-edit-fill bg-layer FILL-PATTERN)
          )
	((= back-type 2)
	  (gimp-context-set-gradient back-gradient)    
		      (gimp-drawable-edit-gradient-fill bg-layer GRADIENT-LINEAR 0 0 100 0 0 0 0 0 (car (gimp-drawable-get-height bg-layer))) ; Fill with gradient
          )
          (else
                      ;(gimp-edit-blend bg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 0 FALSE TRUE 3 0.20 TRUE 0 0 0 (car (gimp-drawable-height bg-layer))) ; Fill with gradient
		      (gimp-drawable-edit-gradient-fill bg-layer GRADIENT-LINEAR 0 0 100 0 0 0 0 0 (car (gimp-drawable-get-height bg-layer))) ; Fill with gradient
          )
    )
    (gimp-image-remove-layer img logo-layer)        ; Delete the logo layer (stroke color dup in this case)
    (gimp-image-set-active-layer img text-layer)    ; Make text layer active 

 
    (gimp-selection-none img)       ; Clear selection
    (gimp-image-undo-enable img)    ; Allow undo  
    (gimp-context-pop)              ; Pop context off stack
    (gimp-display-new img)          ; Show the image

 ) ; endlet
) ; return

;
; Register the script
;    
(script-fu-register "script-fu-logo-workshop-plus-299b"
                    _"_Logo Workshop PLUS LOGO 299 B..."
                    _"Create logo with selected fill type, drop shadow and effect"
                    "GnuTux - http://gimpchat.com"
                    "GnuTux - GPLv3"
                    "10-2011"
                    ""
                    SF-TEXT     _"Text"                 "Logo Workshop\nPlus\n2.99.16"
                    SF-ADJUSTMENT _"Font size (pixels)"   '(220 2 1000 1 10 0 0)
                    SF-FONT       _"Font"                 "Comic Sans MS Bold"
		                        SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
				    SF-ADJUSTMENT _"Letter Spacing"        '(0 -50 50 1 5 0 0)
                    SF-ADJUSTMENT _"Line Spacing"          '(-5 -300 300 1 10 0 0)
		    SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -12 12 1 10 0 0)
		    SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
                    SF-OPTION     _"Logo Fill Method"     '("Color Fill" "Fill With Pattern" "Fill With Gradient")
                    SF-COLOR      _"Logo Fill Color"      '(23 131 181)
		    SF-PATTERN	   "Logo Fill Pattern"				"Burlwood"
		    SF-GRADIENT   "Logo Fill Gradient" "Yellow Orange"
		    SF-TOGGLE "Gradient Reverse" FALSE
                    SF-ADJUSTMENT _"Logo Bevel Depth"    '(10 0 50 1 1 0 0)
		    SF-OPTION     _"Stroke Fill Method"     '("Color" "Pattern" "Gradient")
                    SF-COLOR      _"Stroke Color"         '(9 45 68)
		    SF-PATTERN	   "Stroke Pattern"				"Wood #2"
		    SF-GRADIENT   "Stroke Gradient" "Golden"
		    SF-TOGGLE "Gradient Reverse" FALSE
                    SF-ADJUSTMENT _"Stroke width"         '(3 0 19 1 1 0 0)
                    SF-COLOR      _"Shadow color"         '(0 0 0)
                    SF-ADJUSTMENT _"Shadow Offset X"      '(-6 -99 99 1 1 0 0)
                    SF-ADJUSTMENT _"Shadow Offset Y"      '(4 -99 99 1 1 0 0)
                    SF-ADJUSTMENT _"Shadow Opacity"       '(50 0 100 1 1 0 0)
                    SF-OPTION     _"Added Effect"         '("None" "Bump With Pattern" "Simple Gloss Layer" "Translucent/Glass Layer" "Double Bevel" "Double Stroke" "Cubism on Fill" "Oilify on Fill" "Plasma on fill" "Glitter on fill")
                    SF-PATTERN    _"Added Effect Pattern" "Bricks"
                    SF-ADJUSTMENT _"Added Effect Depth"   '(7 0 50 1 1 0 0)
		     SF-ADJUSTMENT  "Buffer amount" '(10 0 100 1 10 1 0) ;a slider
		     		    SF-OPTION     _"Background Fill Method"     '("Color" "Pattern" "Gradient" "None")
                    SF-COLOR      _"Background Color"         '(255 255 255)
		    SF-PATTERN	   "Background Pattern"				"Pine?"
		    SF-GRADIENT   "Background Gradient" "Brushed Aluminium"
		    )

(script-fu-menu-register "script-fu-logo-workshop-plus-299b"
                         _"<Image>/File/Create/Logos/")
