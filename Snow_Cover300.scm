;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Snow Cover rel 0.03
; Created by Graechan
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
;
; ------------
;| Change Log |
; ------------ 
; Rel 0.01 - Initial Release
; Rel 0.02 - Added Alpha-to-Logo script, Improved Logo script, and changed name to Snow Cover.scm
; Rel 0.03 - ammended script to function in 2-10
; Rel 299 for Gimp 2.10.22 and 2.99.8
; Rel 300 for Gimp 2.10.22 and 3.0 rc1

; Define the apply logo toolbox procedure

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		(define (apply-gauss img drawable x y)(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
      (plug-in-gauss  1  img drawable x y 0)
 (plug-in-gauss  1  img drawable (* x 0.32) (* y 0.32) 0)  )))
 
 		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "QTChanceryType Bold")
  (define sffont "QTChanceryType-Bold"))

;
; Gradients blend direction list
(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal to centre" "Diagonal from centre"))
;
; Include layer Procedure
(define (include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.8 
          )
          (else
           (gimp-image-insert-layer image newlayer (+ (car (gimp-image-get-item-position image oldlayer 0)) stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end include layer procedure
;
(define (script-fu-snow-cover300-alpha image layer
                               depth
							   conserve
							   )
							   
	(gimp-image-undo-group-start image)						  

 (let* (
        (width (car (gimp-image-get-width image)))
		(height (car (gimp-image-get-height image)))
		(layer-name (cond ((defined? 'gimp-image-get-item-position) (car (gimp-item-get-name layer)))
		            (else (car (gimp-drawable-get-name layer)))))
		(snow-layer 0)
		(snowtop-layer 0)
		(snowshadow-layer 0)
		(ver 2.8)		
        )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
	
	(gimp-context-push)
	 (gimp-context-set-paint-mode 0)
    (gimp-context-set-paint-method "gimp-paintbrush")
	;(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Dynamics Off")))
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

;;;;begin the script	
    (cond ((= ver 2.8) (gimp-image-select-item image 2 layer)) 
	(else (gimp-image-select-item image 2  layer))
	) ;endcond	
	(set! snow-layer (car (gimp-layer-new image width height RGBA-IMAGE "Snow Template" 100 LAYER-MODE-NORMAL-LEGACY)))
    (include-layer image snow-layer layer 0)	;stack 0=above 1=below
	(gimp-drawable-edit-fill snow-layer FILL-BACKGROUND)
	(gimp-layer-set-offsets snow-layer 0 (- 0 depth))
	(gimp-drawable-edit-clear snow-layer)
	(gimp-selection-none image)
	(gimp-image-select-item image 2  snow-layer)
			 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)	
	(script-fu-distress-selection image 
	                             snow-layer
								  127       ;Threshold (bigger 1<-->255 smaller)
								  2         ;Spread (8 0 1000 1 10 0 1)
								  4         ;Granularity (1 is low) (4 1 25 1 10 0 1)
								  2         ;Smooth (2 1 150 1 10 0 1)
								  TRUE      ;Smooth horizontally TRUE
								  TRUE)     ;Smooth vertically TRUE
		(script-fu-distress-selection image 
	                             (vector snow-layer )
								  0.5       ;Threshold (bigger 1<-->255 smaller)
								  2         ;Spread (8 0 1000 1 10 0 1)
								  4         ;Granularity (1 is low) (4 1 25 1 10 0 1)
								  2         ;Smooth (2 1 150 1 10 0 1)
								  TRUE      ;Smooth horizontally TRUE
								  TRUE)     ;Smooth vertically TRUE
								  )
	(gimp-item-set-visible snow-layer FALSE)
	
	(set! snowtop-layer (car (gimp-layer-new image width height RGBA-IMAGE "Snow Topping" 100 LAYER-MODE-NORMAL-LEGACY)))
    (include-layer image snowtop-layer snow-layer 0)	;stack 0=above 1=below
	(gimp-context-set-background '(243 243 255))
	(gimp-drawable-edit-fill snowtop-layer FILL-BACKGROUND)
	(gimp-selection-none image)
	(apply-gauss image snowtop-layer 3 3)
	(cond ((= ver 2.8)
	(gimp-context-set-sample-threshold-int 25)
	(gimp-context-set-antialias TRUE)
	(gimp-image-select-color image 2 snowtop-layer '(243 243 255)))
	(else (gimp-by-color-select snowtop-layer '(243 243 255) 25 2 TRUE FALSE 0 FALSE))
	) ;endcond
	(gimp-drawable-edit-fill snowtop-layer FILL-BACKGROUND)
	
	(set! snowshadow-layer (car (gimp-layer-new image width height RGBA-IMAGE "Snow Shadow" 100 LAYER-MODE-NORMAL-LEGACY)))
    (include-layer image snowshadow-layer snowtop-layer 0)	;stack 0=above 1=below
	(gimp-context-set-background '(149 149 207))
	(gimp-drawable-edit-fill snowshadow-layer FILL-BACKGROUND)
	(gimp-layer-set-offsets snowshadow-layer 0 (/ depth 2))
	(gimp-drawable-edit-clear snowshadow-layer)
	(gimp-layer-set-offsets snowshadow-layer 0 -1)
	(gimp-selection-invert image)
    (gimp-drawable-edit-clear snowshadow-layer)
	(gimp-selection-invert image)
	(apply-gauss image snowshadow-layer 10 10)
	(gimp-selection-none image)
	(apply-gauss image snowtop-layer 3 3)

;;;;finish the script	
    (if (= conserve FALSE) (begin
	(gimp-image-remove-layer image snow-layer)
	(set! layer (car (gimp-image-merge-down image snowtop-layer EXPAND-AS-NECESSARY)))
	(set! layer (car (gimp-image-merge-down image snowshadow-layer EXPAND-AS-NECESSARY)))
	)) ;endifs
    (cond ((= ver 2.8) (gimp-item-set-name layer (string-append layer-name "\nSnow")))
	(else (gimp-item-set-name layer (string-append layer-name "\nSnow")))
    ) ;endcond

	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
    
 )
) 

(script-fu-register "script-fu-snow-cover300-alpha"        		    
  "Snow Cover Alpha 300..."
  "Cover the Image with a Snow drift (image must have transparent background)"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Dec 2013"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-ADJUSTMENT "Snow Depth" '(10 0 50 1 10 0 0)
  SF-TOGGLE     "Keep the Layers"   FALSE
)

(script-fu-menu-register "script-fu-snow-cover300-alpha" "<Image>/Script-Fu/Alpha-to-Logo")

(define (script-fu-snow-cover300-logo 
                            text 
                            color 
                            font-in 
                            font-size
				justification
                                 letter-spacing
                                 line-spacing
							depth
							bkg-type 
                            pattern
                            bkg-color
							gradient
							gradient-type
							reverse
							blendir
							conserve
							)
  (let* (
         (offx 0)
         (offy 0)
         (image (car (gimp-image-new 100 100 RGB)))
         (border (/ font-size 4))
		 (font font-in)
         (text-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (width (car (gimp-drawable-get-width text-layer)))
         (height (car (gimp-drawable-get-height text-layer)))
		 (innermap 0)
		 (active-gradient (car (gimp-context-get-gradient)))
		 (active-fg (car (gimp-context-get-foreground)))
		 (active-bg (car (gimp-context-get-background)))
		 (bkg-layer 0)
		 (text-selection 0)
		 (masktext 0)
		 (x1 0)
		 (y1 0)
		 (x2 0)
		 (y2 0)
		 (ver 2.8)  
	  		  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))		 
         )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version	 
		 
    (gimp-context-push)
     (gimp-context-set-paint-mode 0)
	(gimp-context-set-paint-method "gimp-paintbrush")
	;(if (= ver 2.8) (gimp-context-set-dynamics "Dynamics Off"))
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
;;;;centre text on line
	;(gimp-text-layer-set-justification text-layer 2)
	      (gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification text-layer justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing
;;;;set the new Image size
	(gimp-image-resize image width height 0 0)

;;;;set the text clolor    
    (gimp-context-set-foreground color)
	(cond ((= ver 2.8) (gimp-image-select-item image 2 text-layer)) 
	(else (gimp-image-select-item image 2  text-layer)))
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)
	(gimp-selection-none image)
;;;;start of script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;save the selection    
    (cond ((= ver 2.8) (gimp-image-select-item image 2 text-layer)) 
	(else (gimp-image-select-item image 2  text-layer)))	
	(set! text-selection (car (gimp-selection-save image))) ;(gimp-image-select-item image 2  text-selection)
	(gimp-selection-none image)
	
		; creating  map (inner shape)
		(set! innermap (car (gimp-layer-new  image width height RGB-IMAGE "iMap" 100 LAYER-MODE-NORMAL-LEGACY)))
		(include-layer image innermap text-layer 1)	;stack 0=above 1=below
		(gimp-context-set-foreground '(255 255 255))
		(gimp-drawable-edit-fill innermap FILL-FOREGROUND)
		(gimp-image-select-item image 2  text-selection)
		(gimp-selection-shrink image 3)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-drawable-edit-fill innermap FILL-FOREGROUND)
		(gimp-selection-none image)
		(apply-gauss image innermap 6 6)

		(gimp-context-set-foreground color)
		(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)

		(plug-in-bump-map
			1
			image
			text-layer
			innermap
			135
			32
			5
			0
			0
			0
			0
			1
			1
			0)
	
		(gimp-image-select-item image 2  text-selection)
		(gimp-selection-shrink image 2)
		(set! masktext (car (gimp-layer-create-mask text-layer ADD-MASK-SELECTION)))
		(gimp-layer-add-mask text-layer masktext)
		(gimp-selection-none image)
		(apply-gauss image masktext 1 1)
		(gimp-layer-remove-mask text-layer MASK-APPLY)
		(gimp-image-remove-layer image innermap)
		(gimp-image-remove-channel image text-selection)


;;;;create the background layer    
	;;;;create the background layer    
	(cond ((not (= bkg-type 0))
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	(include-layer image bkg-layer text-layer 1)	;stack 0=above 1=below
    )
	) ;endcond
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (or (= bkg-type 3) (= bkg-type 4)) (begin 
	(gimp-context-set-foreground active-fg)
	(gimp-context-set-background active-bg)))
	(if (= bkg-type 4) (gimp-context-set-gradient active-gradient))
	(if (= bkg-type 2) (gimp-drawable-fill bkg-layer FILL-PATTERN))		
    (if (= bkg-type 1) (gimp-drawable-fill bkg-layer FILL-BACKGROUND))	
    (if (or (= bkg-type 3) (= bkg-type 4)) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)
    (if (= blendir 0) (set! x2 width))
	(if (= blendir 1) (set! y2 height))
	(if (= blendir 2) (begin
	(set! x2 (/ width 2))
	(set! y2 (/ height 2))))
	(if (= blendir 3) (begin
	(set! x1 (/ width 2))
	(set! y1 (/ height 2))))
	;(gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY gradient-type 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE x1 y1 x2 y2)
	(gimp-context-set-gradient-reverse reverse)
	(gimp-drawable-edit-gradient-fill bkg-layer gradient-type 0 0 1 0 0 x1 y1 x2 y2)
	)
	) ;endif
    
	
		
;;;;resize the text-layer
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
	(gimp-image-set-active-layer image text-layer)
	(gimp-image-set-selected-layers image (vector text-layer)))
	(script-fu-snow-cover300-alpha image 
                          text-layer
                          depth
						  conserve)
;	(gimp-layer-resize-to-image-size text-layer)

    (if (= conserve FALSE) (begin
	(set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
;	(gimp-image-remove-layer image snow-layer)
	)) ;endif    

	(gimp-context-pop)

    (gimp-display-new image)
    )
  ) 
(script-fu-register "script-fu-snow-cover300-logo"
  "Snow Cover Logo 300..."
  "Create a Logo covered in a snow drift"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Dec 2013"
  ""
  SF-TEXT       "Text"    "SEASONS\nGREETINGS"
  SF-COLOR      "Text color"         '(255 0 0)
  SF-FONT       "Font"               sffont
  SF-ADJUSTMENT "Font size (pixels)" '(250 6 500 1 1 0 1)
  		                        SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
				    SF-ADJUSTMENT _"Letter Spacing"        '(0 -50 50 1 5 0 1)
                    SF-ADJUSTMENT _"Line Spacing"          '(-5 -300 300 1 10 0 1)
  SF-ADJUSTMENT "Snow Depth" '(10 0 50 1 10 0 0)
  SF-OPTION "Background Type" '("None" "Color" "Pattern" "Gradient" "Active Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
  SF-TOGGLE     "Keep the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-snow-cover300-logo" "<Image>/Script-Fu/Logos" )


