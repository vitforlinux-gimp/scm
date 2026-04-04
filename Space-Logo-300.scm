(define list-blend-space-dir '("Top-Botton" "Bottom-Top" "Left-Right" "Right-Left" "Diag-Top-Left" "Diag-Top-Right" "Diag-Bottom-Left" "Diag-Bottom-Right" "Diag-to-center" "Diag-from-center" "Center-to-Top center" "Center-to-Bottom center" ))
;(define list-fill-space-dir '("Gradient Linear""Stripes Horiz" "Stripes 45" "Stripes Vert"))
		 (if (not (defined? 'gimp-drawable-filter-new))
        (define sfrepeat '("None"  "Sawtooth"  "Triangular"  "Truncate"))
  (define sfrepeat '("None" "Truncate" "Sawtooth" "Triangular" ))	)
  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))
;Material start
		(define (material-space-gradient fond image gradient-type numcol direction repeat reverse fond-color)  			(begin
	      (define width   (car (gimp-drawable-get-width  fond) ) )
      (define height  (car (gimp-drawable-get-height fond) ) )
					;(gimp-context-set-foreground fond-color)
				;(gimp-drawable-edit-fill fond FILL-FOREGROUND)
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
;(gimp-context-set-gradient gradient)
				(cond ((= numcol 2) (if (not (defined? 'gimp-drawable-filter-new)) 
		(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 0)) 
		;(gimp-context-set-gradient (car (gimp-gradient-get-by-name(list-ref (car (gimp-gradients-get-list "")) 4))))
(gimp-context-set-gradient (vector-ref (car (gimp-gradients-get-list ""))3))		))
((= numcol 1) (if (not (defined? 'gimp-drawable-filter-new)) 
		(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 2)) 
		;(gimp-context-set-gradient (car (gimp-gradient-get-by-name(list-ref (car (gimp-gradients-get-list "")) 4))))
(gimp-context-set-gradient (vector-ref (car (gimp-gradients-get-list ""))6))		)))

(gimp-context-set-gradient-reverse reverse)
	
 (gimp-drawable-edit-gradient-fill fond gradient-type 0 REPEAT-NONE 1 0.0 FALSE x1 y1 x2 y2)
			)) 

(script-fu-register
            "script-fu-space-300"                        ;function name
            "Space logo 300"                                  ;menu label
            "Creates Retro Space logo."              ;description
            "Michael Terry"                             ;author
            "copyright 1997, Michael Terry;\
              2009, the GIMP Documentation Team"        ;copyright notice
            "October 27, 1997"                          ;date created
            ""                              ;image type that the script works on
            SF-TEXT      "Text"          "SPACE"   ;a string variable
            SF-FONT        "Font"          "QTEraType Medium"    ;a font variable
            SF-ADJUSTMENT  "Font size"     '(150 1 1000 1 10 0 0)
	     SF-COLOR       "Color1"         '(0 240 255)     ;color variable
	     SF-COLOR       "Color2"         '(0 0 0)     ;color variable
			SF-ENUM "Logo Gradient Mode" '("GradientType" "gradient-linear") ;add
		      SF-OPTION		"Gradient Blend Direction" 		list-blend-space-dir ;add
			SF-OPTION "Gradient Repeat" sfrepeat ;add
		    SF-TOGGLE "Gradient Reverse" FALSE ;add
	    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(30 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
                                                        ;a spin-button
           SF-COLOR       "Background Color"         '(0 0 0)     ;color variable
            SF-ADJUSTMENT  "Buffer amount" '(65 0 100 1 10 1 0)
                                                        ;a slider
  )
  (script-fu-menu-register "script-fu-space-300" "<Image>/File/Create/Text")
  
(define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))
  
  (define (script-fu-space-300 inText inFont inFontSize inTextColor1 inTextColor2 logo-grad-type logo-grad-dir logo-grad-rep logo-grad-rvs
					justification
					letter-spacing
					line-spacing
					grow-text
					outline
					bgColor
					inBufferAmount)
    (let*
      (
        ; define our local variables
        ; create a new image:
        (theImageWidth  10)
        (theImageHeight 10)
        (theImage)
        (theImage
                  (car
                      (gimp-image-new
                        theImageWidth
                        theImageHeight
                        RGB
                      )
                  )
        )
        (theText)             ;a declaration for the text
        (theBuffer)           ;create a new layer for the image
        (theLayer
                  (car
                      (gimp-layer-new-ng
                        theImage
                        theImageWidth
                        theImageHeight
                        RGB-IMAGE
                        "layer 1"
                        100
                        LAYER-MODE-NORMAL
                      )
                  )
        )
	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
      ) ;end of our local variables
      
          (gimp-context-push)
    (gimp-context-set-defaults)
    (gimp-context-set-paint-mode 0)
          (gimp-image-insert-layer theImage theLayer 0 0)
      (gimp-context-set-background bgColor)
      (gimp-context-set-foreground inTextColor1)
      (gimp-drawable-fill theLayer FILL-BACKGROUND)
      (set! theText
      		 (if (not (defined? 'gimp-drawable-filter-new))
		                    (car
                          (gimp-text-fontname
                          theImage theLayer
                          0 0
                          inText
                          0
                          TRUE
                          inFontSize PIXELS
                          inFont)
                      )
	
                    (car
                          (gimp-text-font
                          theImage theLayer
                          0 0
                          inText
                          0
                          TRUE
                          inFontSize
                          inFont)
                      ))
        )
	;; text alignment
	(gimp-text-layer-set-justification theText justification) ; Text Justification (Rev Value) 
	(gimp-text-layer-set-letter-spacing theText letter-spacing)  ; Set Letter Spacing
	(gimp-text-layer-set-line-spacing theText line-spacing)      ; Set Line Spacing


      (set! theImageWidth   (car (gimp-drawable-get-width  theText) ) )
      (set! theImageHeight  (car (gimp-drawable-get-height theText) ) )
      (set! theBuffer (* theImageHeight (/ inBufferAmount 100) ) )
      (set! theImageHeight (+ theImageHeight theBuffer theBuffer) )
      (set! theImageWidth  (+ theImageWidth  theBuffer theBuffer) )
      (gimp-image-resize theImage theImageWidth theImageHeight 0 0)
      (gimp-layer-resize theLayer theImageWidth theImageHeight 0 0)
      (gimp-layer-set-offsets theText theBuffer theBuffer)
      (gimp-floating-sel-to-layer theText)
      (gimp-layer-resize-to-image-size theText)
;;;; shrink grow text
(cond ((> grow-text 0)
	(gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-grow theImage (round grow-text))
(gimp-context-set-foreground inTextColor1)	
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-drawable-edit-clear theText)
	(gimp-selection-shrink theImage (- grow-text)) 
	(gimp-context-set-foreground inTextColor1)
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 ))
   ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-shrink theImage (round outline))   
	(gimp-drawable-edit-clear theText)
	(gimp-image-select-item theImage 2 theText)
 ))
 ;(gimp-image-resize-to-layers theImage)
 (gimp-context-set-foreground inTextColor1)
 (gimp-context-set-background inTextColor2)
 	(gimp-image-select-item theImage 2 theText)
(gimp-selection-grow theImage 5)
 		    (gimp-drawable-edit-fill theText FILL-FOREGROUND)

        (cond ((defined? 'plug-in-autocrop-layer)(plug-in-autocrop-layer 1 theImage theText)) ; Autocrop fill layer so gradient is fully applied 
	(else (gimp-image-autocrop-selected-layers theImage theText))
	)
(gimp-image-select-item theImage 2 theText)
(gimp-drawable-edit-fill theText FILL-TRANSPARENT)
	(material-space-gradient theText theImage logo-grad-type 2 logo-grad-dir logo-grad-rep 0 inTextColor1)
			    ;(gimp-layer-resize-to-image-size theText)
(gimp-selection-shrink theImage 3) 
          	(material-space-gradient theText theImage logo-grad-type 2 logo-grad-dir logo-grad-rep 1 inTextColor1)
		
         (define light-layer (car (gimp-layer-new-from-drawable theText theImage))) ; New Stoke Layer 
         (gimp-image-insert-layer theImage light-layer 0 1) ; Add it to image
         (gimp-image-set-active-layer theImage light-layer)                          ; Make stroke logo layer active
         (gimp-item-set-name light-layer "light")
	 (gimp-image-select-item theImage 2 light-layer)
	 (gimp-drawable-edit-fill light-layer FILL-TRANSPARENT)
	 (material-space-gradient light-layer theImage logo-grad-type 1 logo-grad-dir logo-grad-rep 0 inTextColor1)
	(gimp-layer-resize-to-image-size light-layer)
	(gimp-selection-none theImage)
	(apply-gauss2 theImage light-layer 15 15)
	(gimp-layer-resize-to-image-size theText)
	(apply-gauss2 theImage theText 2 2)


	(gimp-context-pop)
      (gimp-display-new theImage)
      (list theImage theLayer theText)
    )
  )
