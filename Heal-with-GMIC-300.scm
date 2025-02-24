;Heal with Gmic 
;
; Created by Vitforlinux - part of code from 3d-extrusion by GnuTux
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
;rev 0  two different engines GMIC for easy replacement of Heal Transparency and Heal Selection without Resinthesizer
;
; 
; Define 3D Extrude Aplha
;
(define (script-fu-heal-with-gmic-300 img
                              drawable
			      mask-color-sel
                              ext-type
			      mask-color
			      dilation
			      
			      dont-remove-sel
			      auto-enlarge-sel


                             
                              
                              
                             
                              
                              
        )
;
  (let* (
          ; (in-layer -1)                    ; Incoming layer
	         			(in-layer (if (not (defined? 'gimp-drawable-filter-new))
             (car (gimp-image-get-active-layer img))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers img)) 0)))))
           (in-pos 0)                       ; Position of incoming layer in layer stack 
           (extrusion-layer -1)             ; Extrusion layer
           (pattern-overlay -1)             ; Extrusion Pattern Overlay
           (temp-layer -1)                  ; Temp Layer Used To Create Pattern Overlay 
           (saved-selection -1)             ; Saved Selection
	(image-height 0)                 ; Image Height
           (image-width 0)                  ; Image Width
           (extrusion-counter 0)    ; Number of layers to extrude
           (layer-width -1)                 ; Incoming layer width
           (layer-height -1)                ; Incoming layer height
           (hpos 0)                         ; Extrusion Horizontal Position
           (vpos 0)                         ; Extrusion Verical Position
           (zoom-counter 0)                 ; Point Zoom Counter
	   			(r (car mask-color))
			(g (cadr mask-color))
			(b (caddr mask-color))
        )
;
; Save current values
; 

  (gimp-context-push)                               ; Push context onto stack
  (gimp-image-undo-group-start img)                 ; Begin undo group



;
; Position of incoming drawable in layer stack
;
 ; (set! in-pos (car (gimp-image-get-item-position img drawable))) 

 (gimp-context-set-foreground mask-color)
;(gimp-image-select-color img 2 drawable mask-color )
;
; Selection Check
;
;(gimp-layer-resize-to-image-size drawable)


 

    ;(if (= (car (gimp-selection-is-empty img)) TRUE)      ; Remove Transparent 
        (begin
(cond ( (= mask-color-sel 0)
        (gimp-image-select-item img 2 drawable)
	(gimp-selection-invert img)
	(gimp-drawable-edit-fill drawable FILL-FOREGROUND)
)
 ( (= mask-color-sel 1)
	
        
        
	(gimp-drawable-edit-fill drawable FILL-FOREGROUND)
)
 ( (= mask-color-sel 2)
	(gimp-selection-none img)
        (gimp-image-select-color img 2 drawable mask-color )
)
)
	(gimp-selection-grow img auto-enlarge-sel)
	)
    ; ) ; endif
     


;
; Create layer to hold incomimng drawable
;
  ;(set! in-layer (car (gimp-layer-new-from-drawable drawable img)))   ; New Layer 
 ; (gimp-image-insert-layer img in-layer (car (gimp-item-get-parent drawable)) (+ in-pos 1))   ; Add it
  ;(gimp-image-set-active-layer img in-layer)                          ; Make it active
 ; (gimp-selection-invert img)                                         ; Invert 
  ;(gimp-drawable-edit-clear in-layer)                                          ; Clear away eveything outside selection 
  ;(gimp-selection-invert img)                                         ; Invert 
  
 ; (gimp-layer-resize-to-image-size in-layer) ; RESIZE LEVEL AUTOMATICALLY FOR NEWBIES
              (if (= ext-type 0)                                                  
  				(plug-in-gmic-qt 1 img (if (not (defined? 'gimp-drawable-filter-new)) in-layer (vector in-layer)) 1 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"-fx_inpaint_pde 75,1,20,"(number->string r)","(number->string g)","(number->string b)",255,"(number->string dilation)

                                 
					)
				)       
		)
		(if (= ext-type 1)                                                  
  				(plug-in-gmic-qt 1 img (if (not (defined? 'gimp-drawable-filter-new)) in-layer (vector in-layer)) 1 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"-fx_inpaint_matchpatch 0,9,10,5,1,"(number->string r)","(number->string g)","(number->string b)",255,"(number->string dilation)",0"

                                 
					)
				)       
		)
		(if (= ext-type 2)                                                  
  				(plug-in-gmic-qt 1 img (if (not (defined? 'gimp-drawable-filter-new)) in-layer (vector in-layer)) 1 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"-fx_inpaint_morpho "(number->string r)","(number->string g)","(number->string b)",255,"(number->string dilation)

                                 
					)
				)       
		)
				(if (= ext-type 3)                                                  
  				(plug-in-gmic-qt 1 img (if (not (defined? 'gimp-drawable-filter-new)) in-layer (vector in-layer)) 1 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"-fx_inpaint_patch 7,16,0.1,1.2,0,0.05,10,1,"(number->string r)","(number->string g)","(number->string b)",255,"(number->string dilation)",0"

                                 
					)
				)       
		)
  ;(gimp-item-set-name in-layer "Incoming Layer")                     ; Name layer

;
;
; Calculate Extrusion Direction (Degrees to 2D Vector Normal)
;
   ;(set! hpos (round (cos (* ext-direction (/ 3.14 180)))))
   ;(set! vpos (round (sin (* ext-direction (/ 3.14 180)))))
;
;
; Extrude the copy of the incoming drawable 
;

       ;(gimp-selection-none img)                                     ; Clear selection
      ; (gimp-image-set-active-layer img in-layer)                    ; Make incoming layer active


;
; Extrusion The Layer or Selection
;
       ;  (set! layer-width (car (gimp-drawable-get-width in-layer)))        ; Layer width              
        ; (set! layer-height (car (gimp-drawable-get-height in-layer)))      ; Layer height


;
; Clean up

(if (= dont-remove-sel 0)

(gimp-selection-none img)

)
  (gimp-image-undo-group-end img) ; End undo group
  (gimp-context-pop)              ; Pop context off stack
  (gimp-displays-flush)           ; Flush changes to display

;
;
 ); endlet
) ; return (from script-fu-heal-with-gmic-300) 


;
; Register Script-Fu 3D Extrude 
;
(script-fu-register 
                   "script-fu-heal-with-gmic-300"  
		"Heal with Gmic 300"                   
                   "Heal with Gmic-Use Hardness Brush"
                   "Vitforlinux"                                         
                   "GPLv3"                                         
                   "2023 "                                         
                   "RGB*" 
                    SF-IMAGE        "Image"                -1
                    SF-DRAWABLE     "Drawable"             -1
		    SF-OPTION       _"Mode\nPLEASE Use Hardness Brush or\nClean selection"     '("Heal Transparency" "Heal Selection" "Heal Mask Color")
                    SF-OPTION       _"Gmic Inpaint engine"      '("Transport-Diffusion" "Multiscale" "Morphological" "Patch Based")
		    SF-COLOR      "Mask Color\nPLEASE Use color not present in image"         '(255 0 0)
		    SF-ADJUSTMENT "Mask Dilation" '(2 0 32 1 5 0 0)
		   ; SF-TOGGLE       "Use Mask Color for selection" FALSE
		    
		    SF-TOGGLE       "Dont Remove Selection " FALSE
		     SF-ADJUSTMENT "Auto Grow Selection" '(2 0 32 1 5 0 0)

         
   
                              
)
(script-fu-menu-register
"script-fu-heal-with-gmic-300" 
"<Image>/Filters/Enhance/")
