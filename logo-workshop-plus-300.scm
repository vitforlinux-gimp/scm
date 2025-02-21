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
(define list-blend-wksp-dir '("Top-Botton" "Bottom-Top" "Left-Right" "Right-Left" "Diag-Top-Left" "Diag-Top-Right" "Diag-Bottom-Left" "Diag-Bottom-Right" "Diag-to-center" "Diag-from-center" "Center-to-Top center" "Center-to-Bottom center" ))

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image (vector drawable)))))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))

  		(define (remove-color2 img  fond color)(begin
		 (cond((not(defined? 'plug-in-colortoalpha))
		 		     (gimp-drawable-merge-new-filter fond "gegl:color-to-alpha" 0 LAYER-MODE-REPLACE 1.0
"color" color "transparency-threshold" 0 "opacity-threshold" 1)
		)
		(else
(plug-in-colortoalpha RUN-NONINTERACTIVE img fond color)
		))))

 
  (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sfrepeat '("None"  "Sawtooth"  "Triangular"  "Truncate"))
  (define sfrepeat '("None" "Truncate" "Sawtooth" "Triangular" ))	)
  
  		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "LobsterTwo Bold")
  (define sffont "LobsterTwo-Bold"))
;Material start
		(define (material-wksp-gradient fond image gradient gradient-type direction repeat reverse fond-color)  			(begin
		        (define width (car (gimp-drawable-get-width fond)))
        (define height (car (gimp-drawable-get-height fond)))
					(gimp-context-set-foreground fond-color)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-context-set-gradient-repeat-mode repeat)
				
				; choose gradient destination
     (cond ((= direction 0)         ; Top-Bottom 
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= direction 1)           ; Bottom-Top
          (define x1 0)            ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= direction 2)           ; Left-Right
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= direction 3)           ; Right-Left
          (define x1 width)  ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= direction 4)           ; Diag-Top-Left
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= direction 5)           ; Diag-Top-Right
          (define x1 width)  ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= direction 6)           ; Diag-Bottom-Left
          (define x1 0)            ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )

          ((= direction 7)           ; Diag-Bottom-Right
          (define x1 width)  ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  
	  ((= direction 8)           ; Diag-to-center
          (define x1 0)  ; X Blend Starting Point
          (define y1 0) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2  (/ height 2))              ; Y Blend Ending Point
          )
	  
	  
	  ((= direction 9)           ; Diag-from-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  	  ((= direction 10)           ; center-to-top-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  
	  	  	  ((= direction 11)           ; center-to-bottom-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2 height)              ; Y Blend Ending Point
          )
;          (else
;                 ; For later use.. 
;          )
       ) ;end cond
(gimp-context-set-gradient gradient)

(gimp-context-set-gradient-reverse reverse)
	
 (gimp-drawable-edit-gradient-fill fond gradient-type 0 REPEAT-NONE 1 0.0 FALSE x1 y1 x2 y2)
			))
			
;Material END

(define (script-fu-workshop-shine image drawable)
							  

 (let* (
            ;(image-layer (car (gimp-image-get-active-layer image)))
	(image-layer (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
			(width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(layer-name (car (gimp-item-get-name image-layer)))
			(img-layer 0)
			(img-channel 0)
			(bkg-layer 0)
			(tmp-layer 0)
        )
		
		
	(gimp-context-push)
    (gimp-image-undo-group-start image)
    		      (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY  )
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
    
	 (gimp-image-select-item image 2 image-layer)
	
	(set! img-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "img-layer" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer image img-layer 0 -1)
	(gimp-drawable-fill img-layer  FILL-BACKGROUND)
	(gimp-drawable-edit-fill img-layer FILL-FOREGROUND)
	
;;;;create channel
	(gimp-selection-save image)
	;(set! img-channel (car (gimp-image-get-active-drawable image)))
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (set! img-channel (car (gimp-image-get-active-drawable image)))
  (set! img-channel (vector-ref (car (gimp-image-get-selected-drawables image)) 0))	)
	(gimp-channel-set-opacity img-channel 100)	
	(gimp-item-set-name img-channel "img-channel")
	(gimp-image-set-active-layer image img-layer)	
	;(gimp-item-set-name image-layer "Original Image")
	
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 1) 

;;;;apply the image effects
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	(apply-gauss2 image img-layer 12 12)
		 (cond((not(defined? 'plug-in-emboss))
		 		     (gimp-drawable-merge-new-filter img-layer "gegl:emboss" 0 LAYER-MODE-REPLACE 1.0
"type" "emboss" "azimuth" 225 "elevation" 84 "depth" 10)
		)
		(else
	(plug-in-emboss RUN-NONINTERACTIVE image img-layer 225 84 10 TRUE)))	
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear img-layer)
	(gimp-selection-invert image)
	;(plug-in-colortoalpha RUN-NONINTERACTIVE image img-layer '(254 254 254));;fefefe
	(remove-color2 image img-layer '(254 254 254))
	(apply-gauss2 image img-channel 15 15)
	;(plug-in-blur RUN-NONINTERACTIVE image img-layer)
	(apply-gauss2 image img-layer 2 2)
	(gimp-image-set-active-layer image bkg-layer)
	(cond((not(defined? 'plug-in-displace))
          (let* (
                 (filter (car (gimp-drawable-filter-new bkg-layer "gegl:displace" ""))))
            (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                            "amount-x" 8 "amount-y" 8 "abyss-policy" "clamp"
                                            "sampler-type" "cubic" "displace-mode" "cartesian")
            (gimp-drawable-filter-set-aux-input filter "aux" img-channel)
            (gimp-drawable-filter-set-aux-input filter "aux2" img-channel)
            (gimp-drawable-merge-filter bkg-layer filter)
          ))
        (else
(plug-in-displace RUN-NONINTERACTIVE image bkg-layer 8 8 TRUE TRUE img-channel img-channel 1)))
(gimp-image-remove-layer image bkg-layer)
	
;;;;create the shadow		
	;(gimp-image-remove-channel image img-channel)
			 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
(begin)		
(gimp-image-merge-down image img-layer 0))

	
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
    ;(gimp-display-new image)
	(gimp-displays-flush)

 )
) 


(define (apply-logo-workshop-plus-300 img
                             logo-layer
                             fill-style
                             logo-color
			     logo-pattern
			     logo-gradient
			      logo-grad-type
			      logo-grad-dir
			      logo-grad-rep
			     logo-grad-rvs
                             bevel-amt
			     stroke-type
                             stroke-color
			      stroke-pattern
			      stroke-gradient
				stroke-grad-type
				 stroke-grad-dir
				 stroke-grad-rep
			     stroke-grad-rvs
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
       		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (script-fu-drop-shadow img logo-layer shadowx shadowy 3 shadow-color shadow-opacity 1) ; Create shadow
	        (script-fu-drop-shadow img (vector logo-layer) shadowx shadowy 3 shadow-color shadow-opacity 1) ); Create shadow

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
		(gimp-drawable-edit-fill stroke-layer FILL-FOREGROUND)
       ;  (cond ((defined? 'plug-in-autocrop-layer)(plug-in-autocrop-layer 1 img stroke-layer)) ; Autocrop fill layer so gradient is fully applied 
	;(else (gimp-image-autocrop-selected-layers img stroke-layer)))
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
         (cond ((defined? 'plug-in-autocrop-layer)(plug-in-autocrop-layer 1 img stroke-layer)) ; Autocrop fill layer so gradient is fully applied 
	(else (gimp-image-autocrop-selected-layers img stroke-layer)))
	 ; (gimp-context-set-gradient stroke-gradient)
	 (gimp-drawable-edit-fill stroke-layer FILL-FOREGROUND)
		;(gimp-context-set-gradient-reverse stroke-grad-rvs)
		     ; (gimp-drawable-edit-gradient-fill stroke-layer GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (car (gimp-drawable-get-height stroke-layer))) ; Fill with gradient
		     				     ;    (cond ((defined? 'plug-in-autocrop-layer)(plug-in-autocrop-layer 1 img stroke-layer)) ; Autocrop fill layer so gradient is fully applied 
	;(else (gimp-image-autocrop-selected-layers img stroke-layer)))
		(material-wksp-gradient stroke-layer img stroke-gradient stroke-grad-type stroke-grad-dir stroke-grad-rep stroke-grad-rvs stroke-color)
					    (gimp-layer-resize-to-image-size stroke-layer)


          )
          (else
                      ;(gimp-edit-blend stroke-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 0 FALSE TRUE 3 0.20 TRUE 0 0 0 (car (gimp-drawable-height stroke-layer))) ; Fill with gradient
		      (gimp-drawable-edit-gradient-fill stroke-layer GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (car (gimp-drawable-get-height stroke-layer))) ; Fill with gradient
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
	((= fill-style 2)	    (gimp-drawable-edit-fill fill-layer FILL-FOREGROUND)

        (cond ((defined? 'plug-in-autocrop-layer)(plug-in-autocrop-layer 1 img fill-layer)) ; Autocrop fill layer so gradient is fully applied 
	(else (gimp-image-autocrop-selected-layers img fill-layer)))
	(material-wksp-gradient fill-layer img logo-gradient logo-grad-type logo-grad-dir logo-grad-rep logo-grad-rvs logo-color)
			    (gimp-layer-resize-to-image-size fill-layer)

          )
          (else
                      ;(gimp-edit-blend fill-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 0 FALSE TRUE 3 0.20 TRUE 0 0 0 (car (gimp-drawable-height fill-layer))) ; Fill with gradient
		      (gimp-drawable-edit-gradient-fill fill-layer GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (car (gimp-drawable-get-height fill-layer))) ; Fill with gradient
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
             (plug-in-plasma 1 img fill-layer (random 999999999) effect-depth) ; Add plasma
          )
	  ((= effect-style 9) ;Glitter
	 (cond ((not(defined? 'plug-in-rgb-noise))
	             (gimp-drawable-merge-new-filter fill-layer "gegl:noise-rgb" 0 LAYER-MODE-REPLACE 1.0
		     "correlated" FALSE "independent" FALSE "linear" TRUE "gaussian" TRUE "red" 0.6 "green" 0.6 "blue" 0.6 "alpha" 0 "seed" 0))
		     (else
		(plug-in-rgb-noise 1 img fill-layer  FALSE FALSE 0.6 0.6 0.6 0)))
		 (cond ((not(defined? 'plug-in-cubism))
	             (gimp-drawable-merge-new-filter fill-layer "gegl:cubism" 0 LAYER-MODE-REPLACE 1.0
		     "tile-size" 1 "tile-saturation" 5 "bg-color" '(0 0 0)))
		     (else
		(plug-in-cubism 1 img fill-layer 1 5 0)   ))            ; Add cubism effect
          )
	  	  ((= effect-style 10) ;Shined
(script-fu-workshop-shine img fill-layer)

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
           (apply-gauss2 img bump-layer 5 5)                                ; Blur by 3
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
           (apply-gauss2 img bump-layer 5 5)                 ; Blur by 5

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
) ; return (from apply-logo-workshop-plus-300) 
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
(define (script-fu-logo-workshop-plus-300-alpha img
                                       logo-layer
                                       fill-style
                                       logo-color
				       logo-pattern
				       logo-gradient
				       logo-grad-type
				       logo-grad-dir
				       logo-grad-rep
				       logo-grad-rvs
                                       bevel-amt
				       stroke-type
                                       stroke-color
				        stroke-pattern
					stroke-gradient
					stroke-grad-type
					stroke-grad-dir
					stroke-grad-rep
					stroke-grad-rvs					
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
    (apply-logo-workshop-plus-300 img logo-layer fill-style logo-color logo-pattern logo-gradient logo-grad-type logo-grad-dir logo-grad-rep logo-grad-rvs bevel-amt stroke-type stroke-color  stroke-pattern stroke-gradient stroke-grad-type stroke-grad-dir stroke-grad-rep stroke-grad-rvs stroke-width shadow-color shadowx shadowy shadow-opacity effect-style effect-pattern effect-depth alpha2logo)

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
(script-fu-register "script-fu-logo-workshop-plus-300-alpha"
                    _"_Logo Workshop PLUS ALPHA 300..."
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
		    SF-ENUM "Logo Gradient Mode" '("GradientType" "gradient-linear")
		      SF-OPTION		"Gradient Blend Direction" 		list-blend-wksp-dir
		      			SF-OPTION "Gradient Repeat" sfrepeat
		    SF-TOGGLE "Gradient Reverse" FALSE
                    SF-ADJUSTMENT _"Logo Bevel Depth"    '(10 0 50 1 1 0 0)
		    SF-OPTION     _"Stroke Fill Method"     '("Color" "Pattern" "Gradient")
                    SF-COLOR      _"Stroke Color"         '(9 45 68)
		    SF-PATTERN	   "Stroke Pattern"				"Wood #2"
		    SF-GRADIENT   "Stroke Gradient" "Golden"
			SF-ENUM "Stroke Gradient Mode" '("GradientType" "gradient-linear")
			SF-OPTION		"Gradient Blend Direction" 		list-blend-wksp-dir
						SF-OPTION "Gradient Repeat" sfrepeat
		    SF-TOGGLE "Gradient Reverse" FALSE
                    SF-ADJUSTMENT _"Stroke Width"         '(3 0 19 1 1 0 0)
                    SF-COLOR      _"Shadow Color"         '(0 0 0)
                    SF-ADJUSTMENT _"Shadow Offset X"      '(-6 -99 99 1 1 0 0)
                    SF-ADJUSTMENT _"Shadow Offset Y"      '(4 -99 99 1 1 0 0)
                    SF-ADJUSTMENT _"Shadow Opacity"       '(25 0 100 1 1 0 0)
                    SF-OPTION     _"Added Effect"         '("None" "Bump With Pattern" "Simple Gloss Layer" "Translucent/Glass Layer" "Double Bevel" "Double Stroke" "Cubism on Fill" "Oilify on Fill" "Plasma on fill" "Glitter on fill" "Shined")
                    SF-PATTERN    _"Added Effect Pattern" "Bricks"
                    SF-ADJUSTMENT _"Added Effect Depth"   '(7 0 50 1 1 0 0))

(script-fu-menu-register "script-fu-logo-workshop-plus-300-alpha"
                         "<Image>/Filters/Alpha to Logo")

;
; Define logo effect text procedure
;
(define (script-fu-logo-workshop-plus-300 text
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
				 logo-grad-type
				 logo-grad-dir
				 logo-grad-rep
				 logo-grad-rvs
                                 bevel-amt
				 stroke-type
                                 stroke-color
				  stroke-pattern
				  stroke-gradient
				 stroke-grad-type
				 stroke-grad-dir
				 stroke-grad-rep
				stroke-grad-rvs
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
				back-grad-type
					back-grad-dir
					back-grad-rep
					back-grad-rvs
					vignette
					vignette-color
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
                      (gimp-layer-new-ng
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
  (apply-logo-workshop-plus-300 img logo-layer fill-style logo-color logo-pattern logo-gradient logo-grad-type logo-grad-dir logo-grad-rep logo-grad-rvs bevel-amt stroke-type stroke-color stroke-pattern stroke-gradient stroke-grad-type stroke-grad-dir stroke-grad-rep stroke-grad-rvs stroke-width shadow-color shadowx shadowy shadow-opacity effect-style effect-pattern effect-depth alpha2logo)
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
          	(material-wksp-gradient bg-layer img back-gradient back-grad-type back-grad-dir back-grad-rep back-grad-rvs back-color)
	  )
          (else
                      ;(gimp-edit-blend bg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 0 FALSE TRUE 3 0.20 TRUE 0 0 0 (car (gimp-drawable-height bg-layer))) ; Fill with gradient
		      (gimp-drawable-edit-gradient-fill bg-layer GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (car (gimp-drawable-get-height bg-layer))) ; Fill with gradient
          )
    )
    
    		    (if (= vignette TRUE)
(begin
            (gimp-image-select-ellipse
            img
            CHANNEL-OP-REPLACE
            0
	    0
            (car (gimp-image-get-width img))
           (car (gimp-image-get-height img))
        )
	(gimp-selection-invert img)
    (gimp-selection-feather img (round (/ (car (gimp-image-get-width img)) 5 )))
    (gimp-context-set-opacity 50)
	(gimp-context-set-background vignette-color)
    (gimp-drawable-edit-fill bg-layer FILL-BACKGROUND)
    		(gimp-selection-none img)
))
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
(script-fu-register "script-fu-logo-workshop-plus-300"
                    _"_Logo Workshop PLUS LOGO 300..."
                    _"Create logo with selected fill type, drop shadow and effect"
                    "GnuTux - http://gimpchat.com"
                    "GnuTux - GPLv3"
                    "10-2011"
                    ""
                    SF-TEXT     _"Text"                 "Logo Workshop\nPlus\n300"
                    SF-ADJUSTMENT _"Font size (pixels)"   '(220 2 1000 1 10 0 0)
                    SF-FONT       _"Font"                 sffont
		                        SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
				    SF-ADJUSTMENT _"Letter Spacing"        '(0 -50 50 1 5 0 0)
                    SF-ADJUSTMENT _"Line Spacing"          '(-5 -300 300 1 10 0 0)
		    SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -12 12 1 10 0 0)
		    SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
                    SF-OPTION     _"Logo Fill Method"     '("Color Fill" "Fill With Pattern" "Fill With Gradient")
                    SF-COLOR      _"Logo Fill Color"      '(23 131 181)
		    SF-PATTERN	   "Logo Fill Pattern"				"Burlwood"
		    SF-GRADIENT   "Logo Fill Gradient" "Yellow Orange"
			SF-ENUM "Logo Gradient Mode" '("GradientType" "gradient-linear")
		      SF-OPTION		"Gradient Blend Direction" 		list-blend-wksp-dir
			SF-OPTION "Gradient Repeat" sfrepeat
		    SF-TOGGLE "Gradient Reverse" FALSE
                    SF-ADJUSTMENT _"Logo Bevel Depth"    '(10 0 50 1 1 0 0)
		    SF-OPTION     _"Stroke Fill Method"     '("Color" "Pattern" "Gradient")
                    SF-COLOR      _"Stroke Color"         '(9 45 68)
		    SF-PATTERN	   "Stroke Pattern"				"Wood #2"
		    SF-GRADIENT   "Stroke Gradient" "Golden"
			SF-ENUM "Stroke Gradient Mode" '("GradientType" "gradient-linear")
			SF-OPTION		"Gradient Blend Direction" 		list-blend-wksp-dir
			SF-OPTION "Gradient Repeat" sfrepeat
		    SF-TOGGLE "Gradient Reverse" FALSE
                    SF-ADJUSTMENT _"Stroke width"         '(3 0 19 1 1 0 0)
                    SF-COLOR      _"Shadow color"         '(0 0 0)
                    SF-ADJUSTMENT _"Shadow Offset X"      '(-6 -99 99 1 1 0 0)
                    SF-ADJUSTMENT _"Shadow Offset Y"      '(4 -99 99 1 1 0 0)
                    SF-ADJUSTMENT _"Shadow Opacity"       '(50 0 100 1 1 0 0)
                    SF-OPTION     _"Added Effect"         '("None" "Bump With Pattern" "Simple Gloss Layer" "Translucent/Glass Layer" "Double Bevel" "Double Stroke" "Cubism on Fill" "Oilify on Fill" "Plasma on fill" "Glitter on fill" "Shined")
                    SF-PATTERN    _"Added Effect Pattern" "Bricks"
                    SF-ADJUSTMENT _"Added Effect Depth"   '(7 0 50 1 1 0 0)
		     SF-ADJUSTMENT  "Buffer amount" '(10 0 100 1 10 1 0) ;a slider
		     		    SF-OPTION     _"Background Fill Method"     '("Color" "Pattern" "Gradient" "None")
                    SF-COLOR      _"Background Color"         '(255 255 255)
		    SF-PATTERN	   "Background Pattern"				"Pine?"
		    SF-GRADIENT   "Background Gradient" "Brushed Aluminium"
		    SF-ENUM "Back Gradient Mode" '("GradientType" "gradient-linear")
		      SF-OPTION		"Gradient Blend Direction" 		list-blend-wksp-dir
		      SF-OPTION "Back Gradient Repeat" sfrepeat
		      		    SF-TOGGLE "Gradient Reverse" FALSE
				      SF-TOGGLE  "Apply Vignette"    FALSE
  	SF-COLOR		"Vignette Color"	'(0 0 0)

		    )

(script-fu-menu-register "script-fu-logo-workshop-plus-300"
                         _"<Image>/File/Create/Logos/")
