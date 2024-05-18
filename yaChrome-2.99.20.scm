
; samj 20230120 modifications for gimp-2.99.15 (new API)
; lines 184 to 190 here is the problem...
; you can test script-fu-ya-chrome-logo-29920 with console messages






; samj 20220831 modification for gimp-2.99.12 (new API)
;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove
; ya Chrome rel 299
; Created by Graechan using details from a tutorial by 'The Warrior'
; 
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
;
; ------------
;| Change Log |
; ------------ 
; Rel 0.01 - Initial Release
; Rel 0.02 - improved undo function of Logo Script and improved both scripts output
; Rel 299 - attempt update for Gimp 2.99.8 and 2.10... but not are the same... changed name 
; Gradients blend direction list

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))


(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal to centre" "Diagonal from centre"))
(define list-gradname-dir '("None" "Crown Molding" "Deep Sea" "Flare Rays Size 1" "Four Bars" "Full Saturation Spectrum CW" "Golden" "Greens" "Incandescent" "Metallic Something" "Pastels" "Purples" "Rounded Edge" "Three Bars Sin" ))
;
;; Start Define RGB to HSV functions by GnuTux

(define (convert-rgb-to-hsv color)
	(let* (
			(r (car color))
			(g (cadr color))
			(b (caddr color))
			(cmin (min r (min g b)))
			(cmax (max r (max g b)))
			(diff 0.0)
			(rc 0.0)
			(gc 0.0)
			(bc 0.0)
			(h 0.0)
		  )
			
		(set! diff (- cmax cmin))
		(if (= diff 0.0)
			(set! diff (+ diff 1.0)))
		(set! rc (/ (- cmax r) diff))
		(set! gc (/ (- cmax g) diff))
		(set! bc (/ (- cmax b) diff))
		(set! h  (/ (if (= r cmax)
							(- bc gc)
							(if (= g cmax)
								(+ 2.0 (- rc bc))
								(+ 4.0 (- gc rc))))
						6.0))
		
		(list (if (= cmin cmax)
				0
				(* 360 (if (< h 0.0)
						(+ h 1.0)
						h
					)
				)
			)
			(if (= cmin cmax)
				0
				(/ (- cmax cmin) cmax)
			)
			cmax
		)
	)
)

; RGB to HSV in gimp ranges
(define (rgb-to-hsv color)
	(let*
		(
			(r (car color))
			(g (cadr color))
			(b (caddr color))
			(hsv (convert-rgb-to-hsv (list (/ r 255.0) (/ g 255.0) (/ b 255.0))))
			(h (car hsv))
			(s (cadr hsv))
			(v (caddr hsv))
		)
		(list h (* s 100.0) (* v 100.0))
	)
)

;; End Define RGB to HSV functions by GnuTux
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
(define (script-fu-ya-chrome-logo-29920 
                                      text
									  justify
									  letter-spacing
									  line-spacing
                                      font-in 
                                      font-size
				      metal
				      colorize
				      metal-finish
				      depth
				      3d-height
				      shined
				      gradmap
                                      bkg-type 
                                      pattern
                                      bkg-color
							          gradient
							          gradient-type
							          reverse
							          blendir)
									  
	(gimp-context-push)
	(gimp-context-set-foreground '(0 0 0))
	
  (let* (
         (width 0)
         (height 0)
         (offx 0)
         (offy 0)
         (image (car (gimp-image-new 50 50 RGB)))
	 (gimp-image-set-resolution image 300 300)
         (area (* 1000 1000))
         (border (/ font-size 4))
		 (font  font-in)
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
        (major_version_no 0)
        (minor_version_no 0)
        (version_list (strbreakup (car (gimp-version)) "."))		 
         )
	;(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version	 
		 
    
	;(gimp-context-set-paint-method "gimp-paintbrush")
	;(if (= ver 2.8) (gimp-context-set-dynamics "Dynamics Off"))
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
	(script-fu-ya-chrome-29920 image text-layer
					metal
					colorize
					metal-finish
					depth
					3d-height
					shined
					gradmap
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
(script-fu-register "script-fu-ya-chrome-logo-29920"
  "ya Chrome Logo 2.99.20"
  "Create an image with a text layer over a pattern layer"
  "Graechan"
  "Failed update and change name Vitforlinux"
  "Feb 2022"
  ""
  SF-TEXT       "Text"    "ya Chrome"
  SF-OPTION "Justify" '("Centered" "Left" "Right")
  SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-FONT       "Font"               "Serif Bold"
  SF-ADJUSTMENT "Font size (pixels)" '(150 6 500 1 1 0 0)
    SF-OPTION "Metal Type" '("None" "Colorized" "Gold" "Silver" "Copper" "Bronze" "Brass" "Chrome" "Gold Shined")
  SF-COLOR      "Colorize"         "White"
  SF-OPTION "Metal Finish" '("None" "Hammered" "Cloudy")
        SF-ADJUSTMENT "depth (pixels)" '(3 1 60 1 1 0 0)
	SF-ADJUSTMENT "3d height" '(0 0 50 1 1 0 0)
	  SF-TOGGLE     "Shined"   FALSE
  SF-OPTION "Gradmap" list-gradname-dir
  SF-OPTION "Background Type" '("None" "Color" "Pattern" "Gradient" "Active Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
  
  )
(script-fu-menu-register "script-fu-ya-chrome-logo-29920" "<Image>/Script-Fu/Logos/")
;
 (define (script-fu-ya-chrome-29920 image drawable
                                       metal
				       colorize
				       metal-finish
				       depth
				       3d-height
				       shined
				       gradmap
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
			(hammered 0)
			(gradname210 0)
			(gradname299 0)
		    (ver 2.8)
		            (major_version_no 0)
        (minor_version_no 0)
        (version_list (strbreakup (car (gimp-version)) "."))
			(x1 0)
		    (y1 0)
		    (x2 0)
		    (y2 0)
		    		   (h 0)     ;add MrQ
		   (s 0)     ;add MrQ
		   (v 0)     ;add MrQ
		   (hsv 0)   ;add MrQ
        )
	;(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
	
	(gimp-context-push)
    ;(gimp-context-set-paint-method "gimp-paintbrush")
	;(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Dynamics Off")))
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

	 	(cond ((not (= metal-finish 0))
	(set! hammered (set! hammered (car (gimp-layer-copy chrome TRUE))))
	(include-layer image hammered drawable 1)	;stack 0=above 1=below
	(gimp-layer-set-offsets hammered offx offy)
    )) ;endcond
	(cond ( (= metal-finish 1)	
				(gimp-context-set-background '(255 255 255))
	(gimp-drawable-edit-fill hammered FILL-BACKGROUND)
	(gimp-context-set-background '(0 0 0 ))
	 (plug-in-mosaic 1 image hammered 10 10 3 0 FALSE 175 0.3 TRUE FALSE 1 0 1)
	 (plug-in-gauss-iir2 1 image hammered 6 6)
	 (gimp-selection-none image)
	 	(plug-in-bump-map RUN-NONINTERACTIVE image chrome hammered 135 30 5 0 0 0 0 TRUE FALSE 1) ;{LINEAR(0),SPHERICAL(1),SINUSOIDAL(2)})
			)
				)
					  (if (= metal-finish 2)
	 (plug-in-solid-noise 1 image chrome FALSE TRUE 0 1 4 4)
	 );
	(gimp-selection-none image)
	(if (> 3d-height 0)
	(plug-in-mblur 1 image bkg-layer 0 3d-height 90 (/ width 2) (/ height 2)))
	(plug-in-bump-map RUN-NONINTERACTIVE image chrome bkg-layer 135 45 depth 0 0 0 0 TRUE FALSE 0) ;{LINEAR(0),SPHERICAL(1),SINUSOIDAL(2)}
	(gimp-drawable-curves-spline chrome 0 12 #(0 0.34902 0.266667 0.882353 0.494118 0.376471 0.65098 0.886275 0.87451 0.152941 1 1))
	(if (= shined 1) (plug-in-alienmap2 1 image chrome 1 0 1 0 1 0 0 TRUE TRUE TRUE))
	(gimp-image-remove-layer image bkg-layer)
	
	(set! chrome-copy (car (gimp-layer-copy chrome TRUE)))
	(include-layer image chrome-copy chrome 0)	;stack 0=above 1=below
	(gimp-item-set-name chrome-copy "Chrome-Copy")
	;(gimp-context-set-gradient "Sunrise")
	;(plug-in-gradmap 1 image chrome-copy)
	;(gimp-layer-set-mode chrome-copy LAYER-MODE-BURN-LEGACY)
	
	;
; Gradient map
;
(if ( = gradmap 1)(begin (set! gradname210 "Crown molding") (set! gradname299 "Crown Molding") ))
(if ( = gradmap 2)(begin (set! gradname210 "Deep Sea") (set! gradname299 "Deep Sea") )) 
(if ( = gradmap 3)(begin (set! gradname210 "Flare Rays Size 1") (set! gradname299 "Flare Rays Size 1") ))
(if ( = gradmap 4)(begin (set! gradname210 "Four bars") (set! gradname299 "Four Bars") ))
(if ( = gradmap 5)(begin (set! gradname210 "Full saturation spectrum CW") (set! gradname299 "Full Saturation Spectrum CW") ))
(if ( = gradmap 6)(begin (set! gradname210 "Golden") (set! gradname299 "Golden") ))
(if ( = gradmap 7)(begin (set! gradname210 "Greens") (set! gradname299 "Greens") ))
(if ( = gradmap 8)(begin (set! gradname210 "Incandescent") (set! gradname299 "Incandescent") ))
(if ( = gradmap 9)(begin (set! gradname210 "Metallic Something") (set! gradname299 "Metallic Something") ))
(if ( = gradmap 10)(begin (set! gradname210 "Pastels") (set! gradname299 "Pastels") ))
(if ( = gradmap 11)(begin (set! gradname210 "Purples") (set! gradname299 "Purples") ))
(if ( = gradmap 12)(begin (set! gradname210 "Rounded edge") (set! gradname299 "Rounded Edge") ))
(if ( = gradmap 13)(begin (set! gradname210 "Three bars sin") (set! gradname299 "Three Bars Sin") ))


(if (> gradmap 0)
    (begin 
(plug-in-gauss-iir2 1 image chrome-copy 1 1)
;(if (= gradmap 3)(plug-in-gauss-iir2 1 image chrome-copy 2 2))
  ; (gimp-context-set-gradient gradient)
  (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient gradname210)
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name gradname299 )))
				)
 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)  
(plug-in-gradmap 1 image chrome-copy) 
      (plug-in-gradmap 1 image 1 (vector chrome-copy))   )              ; Map Gradient
      (plug-in-oilify 1 image chrome-copy 3 1)
      (plug-in-gauss-iir2 1 image chrome-copy 1 1)
)     
) ;endif

	


	(set! chrome (car (gimp-image-merge-down image chrome-copy EXPAND-AS-NECESSARY)))
	(script-fu-drop-shadow image chrome 3 3 10 '(0 0 0) 80 FALSE)

	
		(if (= metal 2) (set! colorize '(253 208 23)));gold
		;(if (= metal 1) (set! colorize '(167 148 0)));gold
		(if (= metal 3) (set! colorize '(192 192 192)));silver
		(if (= metal 4) (set! colorize '(184 115 51)));copper
		(if (= metal 5) (set! colorize '(140 120 83)));bronze
		(if (= metal 6) (set! colorize '(181 166 66)));brass
		(if (= metal 7) (set! colorize '(192 192 192)));chrome
		(if (= metal 8) (set! colorize '(253 208 23)));gold shined

			(if (> metal 0) 	(begin   ; add for convert RGB to hsv	
			(set! hsv (rgb-to-hsv colorize))
			(set! h (car hsv))
			(set! s (cadr hsv))
			(set! v (caddr hsv))
			;(set! v (- v 100))
			(set! v (- v 115))
			(if (< v  -99) (set! v (- 100) ))
			(gimp-drawable-colorize-hsl chrome h s v)
			))
		(if (= metal 2) (gimp-drawable-brightness-contrast chrome 0.354330708661 0.157480314961));gold
		(if (= metal 3) (gimp-drawable-brightness-contrast chrome 0.354330708661 0.216535433071));silver
		(if (= metal 4) (gimp-drawable-brightness-contrast chrome 0.216535433071 0.1968503937));copper
		(if (= metal 5) (gimp-drawable-brightness-contrast chrome 0.137795275591 0.236220472441));bronze
		(if (= metal 6) (gimp-drawable-brightness-contrast chrome 0.0905511811024 0.0905511811024));brass
		(if (= metal 7)(gimp-drawable-curves-spline chrome 0 12 #(0 0.34902 0.266667 0.882353 0.494118 0.376471 0.65098 0.886275 0.87451 0.152941 1 1)) (gimp-layer-set-lock-alpha chrome TRUE)(plug-in-gauss-iir2 1 image chrome 1 1));chrome
		(if (= metal 8)(gimp-drawable-curves-spline chrome 0 14 #(0 0 0.23677581863979855 0.16731517509727623 0.37027707808564231 0.44357976653696496 0.62468513853904284 0.57587548638132291 0.7153652392947103 0.77042801556420237 0.86649874055415621 0.82101167315175105 1 1 )) (gimp-layer-set-lock-alpha chrome TRUE)(plug-in-gauss-iir2 1 image chrome 1 1));chrome

(gimp-layer-set-lock-alpha chrome TRUE)
(if (= shined 1) (plug-in-gauss-iir2 1 image chrome 3 3))
;(gimp-drawable-hue-saturation chrome image 0 0 56 50 50)
;; effets

			  (if (not(= metal-finish 0))
	; (gimp-image-remove-layer image hammered )
	 );
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

(script-fu-register "script-fu-ya-chrome-29920"        		    
  "ya Chrome 2.99.20 Alpha"
  "chrome any object with transparent background "
  "Graechan"
  "Failed update and change name Vitforlinux"
  "Feb 2022"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
      SF-OPTION "Metal Type" '("None" "Colorized" "Gold" "Silver" "Copper" "Bronze" "Brass" "Chrome" "Gold Shined")
   SF-COLOR      "Colorize"         "White"
   SF-OPTION "Metal Finish" '("None" "Hammered" "Cloudy")
         SF-ADJUSTMENT "depth (pixels)" '(3 1 60 1 1 0 0)
	SF-ADJUSTMENT "3d height" '(0 0 50 1 1 0 0)
	SF-TOGGLE     "Shined"   FALSE
  SF-OPTION "Gradmap" list-gradname-dir
  SF-OPTION "Background Type" '("None" "Color" "Pattern" "Gradient" "Active Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
)

(script-fu-menu-register "script-fu-ya-chrome-29920" "<Image>/Script-Fu/Alpha-to-Logo/")


 
  
