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
(define (script-fu-heal-with-gmic-fast img
                              drawable
                 
			      dilation
			   

			      auto-enlarge-sel


                             
                              
                              
                             
                              
                              
        )
;
  (let* (
           (in-layer -1)                    ; Incoming layer
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


;(gimp-image-select-color img 2 drawable mask-color )
;
; Selection Check
;
;(gimp-layer-resize-to-image-size drawable)




     


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



			                                                  
  				(plug-in-gmic-qt 1 img in-layer 1 0
					(string-append
						"-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
						"-fx_inpaint_patch 7,16,0.1,1.2,0,0.05,10,1,"(number->string r)","(number->string g)","(number->string b)",255,"(number->string dilation)",0"

                                 
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
) ; return (from script-fu-heal-with-gmic-fast) 


;
; Register Script-Fu 3D Extrude 
;
(script-fu-register 
                   "script-fu-heal-with-gmic-fast"  
		"Heal with Gmic FAST"                   
                   "Heal with Gmic-Use Hardness Brush"
                   "Vitforlinux"                                         
                   "GPLv3"                                         
                   "2021 "                                         
                   "RGB*" 
                    SF-IMAGE        "Image"                -1
                    SF-DRAWABLE     "Drawable"             -1

		    SF-ADJUSTMENT "Mask Dilation" '(2 0 32 1 5 0 0)
		     SF-ADJUSTMENT "Auto Grow Selection" '(2 0 32 1 5 0 0)

         
   
                              
)
(script-fu-menu-register
"script-fu-heal-with-gmic-fast" 
"<Image>/Filters/Enhance/")
