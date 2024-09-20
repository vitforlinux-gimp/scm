; Shiny Chrome rel 0.02
; Created by Graechan using details from a tutorial by 'The Warrior'
; You will need to install GMIC to run this Scipt
; GMIC can be downloaded from http://sourceforge.net/projects/gmic/files/ 
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
; Rel 0.02 - improved undo function of Logo Script and improved both scripts output
;
; Gradients blend direction list

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))


(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal to centre" "Diagonal from centre"))

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

;
; Include layer Procedure
(define (include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.8 
          )
          (else
           (gimp-image-insert-layer image newlayer 0 (+ (car (gimp-image-get-item-position image oldlayer)) stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end add layer procedure
;
(define (script-fu-shiny-chrome-logo 
                                      text
									  justify
									  letter-spacing
									  line-spacing
                                      font-in 
                                      font-size
                                      bkg-type 
                                      pattern
                                      bkg-color
							          gradient
							          gradient-type
							          reverse
							          blendir)
									  
	(gimp-context-push)
	 (gimp-context-set-paint-mode 0)
	(gimp-context-set-foreground '(0 0 0))
	
  (let* (
         (width 0)
         (height 0)
         (offx 0)
         (offy 0)
         (image (car (gimp-image-new 50 50 RGB)))
         (area (* 1000 1000))
         (border (/ font-size 4))
		 (font font-in)
         (text-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (text-width (car (gimp-drawable-get-width text-layer)))
         (text-height (car (gimp-drawable-get-height text-layer)))
		 (active-gradient (car (gimp-context-get-gradient)))
		 (active-fg (car (gimp-context-get-foreground)))
		 (active-bg (car (gimp-context-get-background)))
		 (bkg-layer 0)
		 (text-selection 0)
		 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))
		 (x1 0)
		 (y1 0)
		 (x2 0)
		 (y2 0)
		 (ver 2.8)         
         )
	;(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version	 
		 
    
	(gimp-context-set-paint-method "gimp-paintbrush")
	      (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))
	(if (= ver 2.8) (gimp-context-set-dynamics "Pressure Opacity"))
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	
;;;;adjust text 
	(gimp-text-layer-set-justification text-layer justify)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
;;;;set the new width and height	
    (set! width (car (gimp-drawable-get-width text-layer)))
    (set! height (car (gimp-drawable-get-height text-layer)))    
    (gimp-image-resize-to-layers image)
;;;;set the new Image size
	(if (> text-width (car (gimp-image-get-width image))) (set! width text-width))           
    (if (> text-height (car (gimp-image-get-height image))) (set! height text-height))

;;;;resize the image	
	(gimp-image-resize image width height 0 0)

;;;;centre the text layer	
    (set! offx (/ (- width text-width) 2))
    (set! offy (/ (- height text-height) 2))    
    (gimp-layer-set-offsets text-layer offx offy)
	(gimp-image-resize-to-layers image)

;;;;start of script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-image-undo-group-start image)
	(script-fu-shiny-chrome image text-layer
                                       bkg-type 
                                       pattern
                                       bkg-color
							           gradient
							           gradient-type
							           reverse
							           blendir)
    


;;;;end of script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	(gimp-context-pop)
    (gimp-display-new image)
	(gimp-image-undo-group-end image)
	
    )
  ) 
(script-fu-register "script-fu-shiny-chrome-logo"
  "Shiny Chrome Logo"
  "Create an image with a text layer over a pattern layer"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "March 2015"
  ""
  SF-TEXT       "Text"    "CHROME"
  SF-OPTION "Justify" '("Centered" "Left" "Right")
  SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-FONT       "Font"               "QTBookmann-Bold"
  SF-ADJUSTMENT "Font size (pixels)" '(175 6 500 1 1 0 1)
  SF-OPTION "Background Type" '("None" "Color" "Pattern" "Gradient" "Active Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
  
  )
(script-fu-menu-register "script-fu-shiny-chrome-logo" "<Image>/Script-Fu/Logos/")
;
 (define (script-fu-shiny-chrome image drawable
                                       bkg-type 
                                       pattern
                                       bkg-color
							           gradient
							           gradient-type
							           reverse
							           blendir)
							   
	(gimp-image-undo-group-start image)
    (gimp-image-resize-to-layers image)	

 (let* (
            (width (car (gimp-drawable-get-width drawable)))
			(height (car (gimp-drawable-get-height drawable)))
			(offx (car (gimp-drawable-get-offsets drawable)))
            (offy (cadr (gimp-drawable-get-offsets drawable)))
			(bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
			(chrome (car (gimp-layer-new image width height RGBA-IMAGE "Chrome" 100 LAYER-MODE-NORMAL-LEGACY)))
			(alpha (car (gimp-drawable-has-alpha drawable)))
		    (no-sel (car (gimp-selection-is-empty image)))
			(active-gradient (car (gimp-context-get-gradient)))
		    (active-fg (car (gimp-context-get-foreground)))
		    (active-bg (car (gimp-context-get-background)))
			(chrome-copy 0)
		    (ver 2.8)
			(x1 0)
		    (y1 0)
		    (x2 0)
		    (y2 0)
        )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
	
	(gimp-context-push)
	 (gimp-context-set-paint-mode 0)
    (gimp-context-set-paint-method "gimp-paintbrush")
          (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))
	(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Pressure Opacity")))
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

	(if (= alpha FALSE) (gimp-layer-add-alpha drawable))
	
;;;;check that a selection was made if not make one	
	(if (= no-sel TRUE) (begin
	(cond ((= ver 2.8) (gimp-image-select-item image 2 drawable)) 
	(else (gimp-selection-layer-alpha drawable))
	) ;endcond
	)
	)

    ; samj Old code ->   (gimp-image-set-active-layer image drawable)
	; samj New code for gimp-2.99.12
   ; (gimp-image-set-selected-layers image 1 (vector drawable))
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector drawable)))
(else (gimp-image-set-active-layer image drawable))
)

;;;;begin the script	
	(include-layer image bkg-layer drawable 0)	;stack 0=above 1=below
	(gimp-layer-set-offsets bkg-layer offx offy)
	(gimp-drawable-fill bkg-layer FILL-FOREGROUND)
	(gimp-drawable-edit-fill bkg-layer FILL-BACKGROUND)
	(gimp-selection-none image)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image bkg-layer 5 5)
	;(gimp-image-select-color image 2 bkg-layer '(0 0 0) )
(gimp-image-select-item image 2 drawable)
;	(gimp-selection-invert image)
	(set! x1 (cadr (gimp-drawable-mask-bounds drawable)))                     ;x co-ord of upper left corner of selection of the specified drawable.
    (set! y1 (caddr (gimp-drawable-mask-bounds drawable)))                    ;y co-ord of upper left corner of selection of the specified drawable.
    (set! x2 (cadddr (gimp-drawable-mask-bounds drawable)))                   ;x co-ord of lower right corner of selection of the specified drawable. 
	(set! y2 (cadr (cdddr (gimp-drawable-mask-bounds drawable))))             ;y co-ord of lower right corner of selection of the specified drawable.
	
	(include-layer image chrome bkg-layer 0)	;stack 0=above 1=below
	(gimp-layer-set-offsets chrome offx offy)
	(gimp-item-set-visible bkg-layer FALSE)
	(gimp-context-set-foreground '(89 89 89))
	(gimp-context-set-background '(185 185 185))
	(gimp-context-set-gradient-fg-bg-rgb)
;(gimp-image-select-item image 2 drawable)
	;(gimp-drawable-edit-gradient-fill chrome GRADIENT-LINEAR 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE (+ offx x1) (+ offy y2) (+ offx x1) (+ offy y1))
	  (gimp-drawable-edit-gradient-fill chrome GRADIENT-LINEAR 0 0 1 0 0 (+ offx x1) (+ offy y2) (+ offx x1) (+ offy y1))
	(gimp-selection-none image)
	(plug-in-bump-map RUN-NONINTERACTIVE image chrome bkg-layer 135 45 3 0 0 0 0 TRUE FALSE 0) ;{LINEAR(0),SPHERICAL(1),SINUSOIDAL(2)}
	(gimp-drawable-curves-spline chrome 0 12 #(0 0.34902 0.266667 0.882353 0.494118 0.376471 0.65098 0.886275 0.87451 0.152941 1 1))
	(plug-in-alienmap2 1 image chrome 1 0 1 0 1 0 0 TRUE TRUE TRUE)
	(gimp-image-remove-layer image bkg-layer)
	
	(set! chrome-copy (car (gimp-layer-copy chrome TRUE)))
	(include-layer image chrome-copy chrome 0)	;stack 0=above 1=below
	(gimp-item-set-name chrome-copy "Chrome-Copy")
	;(gimp-context-set-gradient "Sunrise")
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Sunrise")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Sunrise")))
				)
	;(plug-in-gradmap 1 image chrome-copy)
			 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (plug-in-gradmap 1 image chrome-copy)
  (plug-in-gradmap 1 image 1 (vector chrome-copy))	)
	(gimp-layer-set-mode chrome-copy LAYER-MODE-BURN-LEGACY)
	(set! chrome (car (gimp-image-merge-down image chrome-copy EXPAND-AS-NECESSARY)))
	(apply-drop-shadow image chrome 3 3 10 '(0 0 0) 80 FALSE)
	
	;;;;create the background layer
  (let* (
        (x1 0)
		(y1 0)
		(x2 0)
		(y2 0)
        )  
	(cond ((not (= bkg-type 0))
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	(include-layer image bkg-layer drawable 1)	;stack 0=above 1=below
	(gimp-layer-set-offsets bkg-layer offx offy)
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
	;(gimp-drawable-edit-gradient-fill bkg-layer gradient-type 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE x1 y1 x2 y2)
	(gimp-context-set-gradient-reverse reverse)
	 (gimp-drawable-edit-gradient-fill bkg-layer gradient-type 0 0 1 0 0 x1 y1 x2 y2)
	)
	) ;endif
	) ;endlet
	
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)

	(gimp-context-pop)

 )
) 

(script-fu-register "script-fu-shiny-chrome"        		    
  "Shiny Chrome"
  "Instructions"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "March 2015"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-OPTION "Background Type" '("None" "Color" "Pattern" "Gradient" "Active Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
)

(script-fu-menu-register "script-fu-shiny-chrome" "<Image>/Script-Fu/Alpha-to-Logo/")


 
  
