;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Emap rel 0.01
; Created by Graechan using the 'Environment script' from GnuTux and a highlight technique from Espers 'Science Labs'
; the default Logo font is from  http://www.fontstock.net/10277/pt-banana-split.html
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
; Rel 2.99.16 - Port to Gimp 2.99.16 and 2.10.34 Vitforlinux
; Gradients blend direction list
(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal to centre" "Diagonal from centre"))
;
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "QTFloraline Bold")
  (define sffont "QTFloraline-Bold"))

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


; Include layer Procedure
(define (include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.8 
          )
          (else
           (gimp-image-insert-layer image newlayer (+ (car (gimp-image-get-item-position image oldlayer)) 0 stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end include layer procedure
;
;find layer by name proceedure
(define (find-layer-by-name image layerName)
  (let* (
           (layerList (vector->list (cadr (gimp-image-get-layers image))))    
           (wantedLayerId -1)
		   (layerId 0)
           (layerText "")
        )
       
        (while (not (null? layerList))
          (set! layerId (car layerList))
		  (set! layerText (cond ((defined? 'gimp-image-get-item-position) (car (gimp-item-get-name layerId)))
		                  (else (car (gimp-drawable-get-name layerId)))))
          (if (string=? layerText layerName) (set! wantedLayerId layerId))          
          (set! layerList (cdr layerList))) ;endwhile        
        (if (= -1 wantedLayerId) (error (string-append "Could not find a layer with name:- " layerName)))
        (list wantedLayerId)
  ) ;end variables
) ;end find layer by name proceedure
;
(define (script-fu-emap299-logo 
                                      text
									  font-in 
                                      font-size
				      								 justification
                                 letter-spacing
                                 line-spacing	
				 grow-text
				 outline
                                      map-type    ; Environment Map Type
                                      paint-mode    ; Selected Paint Mode For Use WIth Blend Plug-in
                                      blend-direction    ; Blend Direction
                                      blend-shape    ; Blend Shape
                                      emap-gradient    ; Selected Gradient For Environment Map
                                      texturesizex    ; Drawable Width
                                      texturesizey    ; Drawable Height 
                                      blur-radius    ; Gaussian Blur Radius 
                                      turbulent
							          hl-dist
							          ds-off
							          ds-blur
							          bkg-type
									  conserve
									  )
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))         
         (border (/ font-size 4))
		 (font font-in)
         (size-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (final-width (car (gimp-drawable-get-width size-layer)))
         (final-height (car (gimp-drawable-get-height size-layer)))
         (text-layer 0)
         (width 0)
         (height 0)
         (bkg-layer 0)
		 (ver 2.8)	
	  		  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))			 
         )
	;(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version	 
    
	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
	(gimp-context-set-paint-method "gimp-paintbrush")
	;(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Dynamics Off")))
		(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Pressure Opacity")))
	(if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics FALSE))
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 250 4)) TRUE 250 PIXELS font)))
	(gimp-item-set-name text-layer "Text")
;;;;adjust text 
	;(gimp-text-layer-set-justification text-layer 2)
          (gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification text-layer justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing	

;;;;set the new width and height	
    (set! width (car (gimp-drawable-get-width text-layer)))
    (set! height (car (gimp-drawable-get-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)
;;;;;; SHRINK/GROW text
(cond ((> grow-text 0)
	(gimp-selection-none image)
	(gimp-image-select-item image 2 text-layer)
	(gimp-selection-grow image (round grow-text))   
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none image)
	(gimp-image-select-item image 2 text-layer)
	(gimp-drawable-edit-clear text-layer)
	(gimp-selection-shrink image (- grow-text))   
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
 ))
 ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none image)
	(gimp-image-select-item image 2 text-layer)
	(gimp-selection-shrink image (round outline))   
	(gimp-drawable-edit-clear text-layer)
	(gimp-image-select-item image 2 text-layer)
 ))
;;;;set the text clolor    
    (cond ((= ver 2.8) (gimp-image-select-item image 2 text-layer)) 
	(else (gimp-selection-layer-alpha text-layer)))
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
	(gimp-selection-none image)
    
;;;;begin the script
	(script-fu-emap299-alpha image text-layer
                               map-type    ; Environment Map Type
                               paint-mode    ; Selected Paint Mode For Use WIth Blend Plug-in
                               blend-direction    ; Blend Direction
                               blend-shape    ; Blend Shape
                               emap-gradient    ; Selected Gradient For Environment Map
                               texturesizex    ; Drawable Width
                               texturesizey    ; Drawable Height 
                               blur-radius    ; Gaussian Blur Radius 
                               turbulent
							   .2
							   1
							   .5
							   27
							   hl-dist
							   ds-off
							   ds-blur
							   bkg-type
							   conserve)
	
;;;;Scale Image to it's original size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-image-scale image final-width final-height )
	(set! width (car (gimp-image-get-width image)))
	(set! height (car (gimp-image-get-height image)))	

	(gimp-context-pop)
	
    (gimp-display-new image)
	
    )
  ) 
(script-fu-register "script-fu-emap299-logo"
  "Emap Logo 299"
  "The default font is from https://www.dafontfree.net/pt-banana-split-normal/f64465.htm"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "June 2011"
  ""
  SF-TEXT     "Text"                  "Emap"
  SF-FONT       "Font"               sffont
  SF-ADJUSTMENT "Font size (pixels)" '(250 6 500 1 1 0 1)
  		                        SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
				    SF-ADJUSTMENT _"Letter Spacing"        '(0 -50 50 1 5 0 0)
                    SF-ADJUSTMENT _"Line Spacing"          '(0 -300 300 1 10 0 0)
		    SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
		    SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
  SF-OPTION     _"Map Type"                 '("Topographical" "Cloud")
  SF-OPTION      "Blending Mode"            '("Normal" "Dissolve" "Behind" "Multiply" "Screen" "Overlay" "Difference" "Addition" "Subtract" "Darken" "Lighten" "Hue" "Saturation" "Color" "Value" "Divide" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge")
  SF-OPTION     _"Blend Direction"          '("Top-Botton" "Bottom-Top" "Left-Right" "Right-Left" "Diag-Top-Left" "Diag-Top-Right" "Diag-Bottom-Left" "Diag-Bottom-Right")
  SF-OPTION     _"Blend Shape"              '("Linear""Bilinear" "Radial" "Square" "Conical-Symmetric" "Conical-Asymmetric" "Shapeburst-Angular" "Shapburst-Spherical" "Shapeburst-Dimpled" "Spiral-CW" "Spiral-CCW")
  SF-GRADIENT   _"Select Gradient"          "Tropical Colors"
  SF-ADJUSTMENT _"Horizontal Texture Size"  '(2.8 1 5 .1 .5 1 1)
  SF-ADJUSTMENT _"Vertical Texture Size"    '(2.8 1 5 .1 .5 1 1)
  SF-ADJUSTMENT _"Blur Radius"              '(5 0 30 1 5 0 1)
  SF-TOGGLE     _"Turbulent Noise"          TRUE
  SF-ADJUSTMENT "Highlight Dist fr Edge"    '(6 0 10 1 1 0 0)
  SF-ADJUSTMENT "Drop Shadow Offset"        '(8 0 50 1 1 0 1)
  SF-ADJUSTMENT "Drop Shadow Blur"          '(15 0 100 1 5 0 1)
  SF-OPTION     "Background Type"           '("Transparency" "From Gradient" "Environment Map")
  SF-TOGGLE     "Keep the Layers"           FALSE
  )
(script-fu-menu-register "script-fu-emap299-logo" "<Image>/Script-Fu/Logos")

(define (script-fu-emap299-alpha image layer
                               map-type    ; Environment Map Type
                               paint-mode    ; Selected Paint Mode For Use WIth Blend Plug-in
                               blend-direction    ; Blend Direction
                               blend-shape    ; Blend Shape
                               emap-gradient    ; Selected Gradient For Environment Map
                               texturesizex    ; Drawable Width
                               texturesizey    ; Drawable Height 
                               blur-radius    ; Gaussian Blur Radius 
                               turbulent
							   glow
							   bright
							   shine
							   polish
							   hl-dist
							   ds-off
							   ds-blur
							   bkg-type
							   conserve)
							   
	(gimp-image-undo-group-start image)						  

 (let* (
            (width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
			(highlight (car (gimp-layer-new image width height RGBA-IMAGE "Highlight" 100 LAYER-MODE-NORMAL-LEGACY)))
			(alpha (car (gimp-drawable-has-alpha layer)))
		    (sel (car (gimp-selection-is-empty image)))
		    (layer-name (cond ((defined? 'gimp-image-get-item-position) (car (gimp-item-get-name layer)))
		            (else (car (gimp-drawable-get-name layer)))))
			(selection-channel 0)
			(bump-channel 0)
			(highlight-channel 0)
			(auto-hsv TRUE)
			(detail-level 1)
			(ver 2.8)
		
        )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
	
	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (gimp-context-set-paint-method "gimp-paintbrush")
	(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Pressure Opacity")))
	(if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics FALSE))
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

	(if (= alpha FALSE) (gimp-layer-add-alpha layer))
	
;;;;check that a selection was made if not make one	
	(if (= sel TRUE) (begin
	(cond ((= ver 2.8) (gimp-image-select-item image 2 layer)) 
	(else (gimp-selection-layer-alpha layer))
	) ;endcond
	)
	)
;;;;create selection-channel (gimp-image-select-item image 2  selection-channel)	
	(set! selection-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name selection-channel "selection-channel"))
	(else (gimp-item-set-name selection-channel "selection-channel"))
    ) ;endcond
		
;;;;create bump-channel (gimp-image-select-item image 2  bump-channel) ;---------------------------------------------create the bump channel	
	(set! bump-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name bump-channel "bump-channel"))
	(else (gimp-item-set-name bump-channel "bump-channel"))
    ) ;endcond
	(gimp-selection-none image)	
;;;;begin the script	
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image bump-channel 10 10) ;-------------------------------------blur the bump-channel
	;(gimp-image-set-active-layer image layer)
	(include-layer image bkg-layer layer 1)	;stack 0=above 1=below ;---------------------------------------add layer for environment map
	
	(the-environment-map
              image     ; Image
         bkg-layer     ; Drawable
          map-type    ; Environment Map Type
        paint-mode    ; Selected Paint Mode For Use WIth Blend Plug-in
   blend-direction    ; Blend Direction
       blend-shape    ; Blend Shape
     emap-gradient    ; Selected Gradient For Environment Map
      detail-level    ; Detail Level For Solid Noise Plug-in 
      texturesizex    ; Drawable Width
      texturesizey    ; Drawable Height 
       blur-radius    ; Gaussian Blur Radius 
          auto-hsv    ; Autostretch HSV Flag
         turbulent)   ; Turbulance Flag
	;(set! bkg-layer (car (gimp-image-get-active-layer image)))	 
	
	;(gimp-image-set-active-layer image layer)
	
	
(cond ((= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
	
	(plug-in-lighting 1 
	    image              ; IMAGE
		layer              ; DRAWABLE
		bump-channel      ; BUMP MAP  (set to valid drawable)
		bkg-layer          ; ENVIRONMENT MAP  (set to 0 if disabled)
		FALSE              ; ENABLE BUMPMAPPING
		TRUE               ; ENABLE ENVMAPPING
		2                  ; TYPE OF MAPPING (0=linear,1=log, 2=sinusoidal, 3=spherical)
		1                  ; TYPE OF LIGHTSOURCE (0=point,1=directional,3=spot,4=none) 
		'(255 255 255)     ; LIGHTSOURCE COLOR
		-1.63                 ; LIGHTSOURCE POS X
		-1.25                 ; LIGHTSOURCE POS Y
		1                  ; LIGHTSOURCE POS Z
		-1                 ; LIGHTSOURCE DIR X
		-1                 ; LIGHTSOURCE DIR Y
		1                  ; LIGHTSOURCE DIR Z
		glow               ; AMBIANT INTENSITY (GLOWING)0.20
		0.50               ; DIFFUSE INTENSITY (BRIGHT)0.50
		bright                 ; DIFFUSE REFLECTIVITY (INTENSITY)1
		shine               ; SPECULAR REFLECTIVITY (SHINY)0.50
		polish                  ; HIGHLIGHT (POLISHED)27
		TRUE               ; ANTIALIASING
		FALSE              ; CREATE NEW IMAGE
		FALSE)	           ; MAKE BACKGROUND TRANSPARENT
	)
	 
	(else
		(plug-in-lighting
				1  ;ok
	    	image              ; IMAGE ok
		;1    ;ok
		(vector layer )             ; DRAWABLE ok
		 bump-channel     ; BUMP MAP  (set to valid drawable)ok
		bkg-layer          ; ENVIRONMENT MAP  (set to 0 if disabled)
		FALSE              ; ENABLE BUMPMAPPING ok
		TRUE               ; ENABLE ENVMAPPING ok
		"bumpmap-sinusoidal"		; TYPE OF MAPPING (0=linear,1=log, 2=sinusoidal, 3=spherical)ok
		
		1                 ; max height bumpmapping ok
		"light-directional"	 ;TYPE OF LIGHTSOURCE (0=point,1=directional,3=spot,4=none) ok
		'(255 255 255)     ; LIGHTSOURCE COLOR ok
		1 ; light inteensity NEW
		1.63                 ; LIGHTSOURCE POS X ok
		-1.25                 ; LIGHTSOURCE POS Y ok
		1                  ; LIGHTSOURCE POS Z ok
		-1                 ; LIGHTSOURCE DIR X ok
		-1                 ; LIGHTSOURCE DIR Y ok
		1                  ; LIGHTSOURCE DIR Z ok
		glow               ; AMBIANT INTENSITY (GLOWING)0.20 ok
		0.50               ; DIFFUSE INTENSITY (BRIGHT)0.50 ok
		 bright                 ; DIFFUSE REFLECTIVITY (INTENSITY)1 GUARDA QUI !! ok
		shine               ; SPECULAR REFLECTIVITY (SHINY)0.50
		0.55 ;polish                  ; material HIGHLIGHT (POLISHED)27 ok
		FALSE ; metallic NEW ok
		TRUE               ; ANTIALIASING
		FALSE              ; CREATE NEW IMAGE
		FALSE;	           ; MAKE BACKGROUND TRANSPARENT
		0.25) ;distance NEW ok
	)
  	)
  
	(plug-in-bump-map RUN-NONINTERACTIVE image layer bump-channel 135 45 40 0 0 0 0 TRUE FALSE 1) ; { LINEAR (0), SPHERICAL (1), SINUSOIDAL (2) }
	
;;;;create the highlight
	(gimp-image-select-item image 2  selection-channel)
	(include-layer image highlight layer 0)	;stack 0=above 1=below
	(gimp-selection-shrink image hl-dist)
	(gimp-context-set-foreground '(128 128 128))
	(gimp-drawable-edit-fill highlight FILL-FOREGROUND)	
;;;;create highlight-channel (gimp-image-select-item image 2  highlight-channel)	
	(set! highlight-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name highlight-channel "highlight-channel"))
	(else (gimp-item-set-name highlight-channel "highlight-channel"))
    ) ;endcond	
	(gimp-selection-none image)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image highlight-channel 5 5)
	;(gimp-image-set-active-layer image highlight)
	(plug-in-bump-map RUN-NONINTERACTIVE image highlight highlight-channel 135 15 10 0 0 0 1 TRUE FALSE 0) ;{LINEAR(0),SPHERICAL(1),SINUSOIDAL(2)}
	(plug-in-colortoalpha RUN-NONINTERACTIVE image highlight '(128 128 128))
	
;;;;add a drop shadow
	;(script-fu-drop-shadow image layer ds-off ds-off ds-blur "Black" 80 FALSE)
	(apply-drop-shadow image layer ds-off ds-off ds-blur "Black" 80 FALSE)
	
;;;;create alternate bkg
	;(gimp-image-set-active-layer image bkg-layer)
	(gimp-context-set-gradient emap-gradient)
	(cond ((= bkg-type 0) (gimp-layer-add-alpha bkg-layer) (gimp-drawable-edit-clear bkg-layer))
	      ((= bkg-type 1)
	     ; (gimp-edit-blend bkg-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-SHAPEBURST-SPHERICAL 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE 0 0 (/ width 2) (/ height 2))
	      				(gimp-drawable-edit-gradient-fill bkg-layer blend-direction 
					0				; opacity
					0				; offset
					1 				;
					1				; 
					0 
					0 0 (/ width 2) (/ height 2)
				)
	      )
	) ;endcond
	
;;;;finish the script	
	(if (= conserve FALSE) (begin
	;(set! layer (car (gimp-image-merge-down image layer EXPAND-AS-NECESSARY)))
	(set! layer (car (gimp-image-merge-down image layer EXPAND-AS-NECESSARY)))
	(set! layer (car (gimp-image-merge-down image highlight EXPAND-AS-NECESSARY)))
	(gimp-image-remove-channel image highlight-channel)
	(gimp-image-remove-channel image bump-channel)
	(gimp-image-remove-channel image selection-channel)
	)) ;endif
  ;  (cond ((= ver 2.8) (gimp-item-set-name layer (string-append layer-name "\n" emap-gradient)))
	;(else (gimp-item-set-name layer (string-append layer-name "\n" emap-gradient)))
   ; ) ;endcond
	(if (and (= conserve FALSE) (= alpha FALSE)) (gimp-layer-flatten layer))	
	
	(gimp-displays-flush)
	;(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
)

(script-fu-register "script-fu-emap299-alpha"        		    
  "Emap Alpha 299"
  "Instructions"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "2012"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
  SF-OPTION     _"Map Type"                 '("Topographical" "Cloud")
  SF-OPTION      "Blending Mode"            '("Normal" "Dissolve" "Behind" "Multiply" "Screen" "Overlay" "Difference" "Addition" "Subtract" "Darken" "Lighten" "Hue" "Saturation" "Color" "Value" "Divide" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge")
  SF-OPTION     _"Blend Direction"          '("Top-Botton" "Bottom-Top" "Left-Right" "Right-Left" "Diag-Top-Left" "Diag-Top-Right" "Diag-Bottom-Left" "Diag-Bottom-Right")
  SF-OPTION     _"Blend Shape"              '("Linear""Bilinear" "Radial" "Square" "Conical-Symmetric" "Conical-Asymmetric" "Shapeburst-Angular" "Shapburst-Spherical" "Shapeburst-Dimpled" "Spiral-CW" "Spiral-CCW")
  SF-GRADIENT   _"Select Gradient"          "Tropical Colors"
  SF-ADJUSTMENT _"Horizontal Texture Size"  '(2.8 1 5 .1 .5 1 1)
  SF-ADJUSTMENT _"Vertical Texture Size"    '(2.8 1 5 .1 .5 1 1)
  SF-ADJUSTMENT _"Blur Radius"              '(5 0 30 1 5 0 1)
  SF-TOGGLE     _"Turbulent Noise"          TRUE
  SF-ADJUSTMENT "Glowing"                   '(.2 0 100000 .01 1 2 1)
  SF-ADJUSTMENT "Brightness"                '(1 0 1 .01 1 2 1)
  SF-ADJUSTMENT "Shiny"                     '(.5 0 1 .01 1 2 1)
  SF-ADJUSTMENT "Polish"                    '(27 0 100000 .01 1 2 1)
  SF-ADJUSTMENT "Highlight Dist fr Edge"    '(6 0 10 1 1 0 0)
  SF-ADJUSTMENT "Drop Shadow Offset"        '(8 0 50 1 1 0 1)
  SF-ADJUSTMENT "Drop Shadow Blur"          '(15 0 100 1 5 0 1)
  SF-OPTION     "Background Type"           '("Transparency" "From Gradient" "Environment Map")
  SF-TOGGLE     "Keep the Layers"           FALSE
)

(script-fu-menu-register "script-fu-emap299-alpha" "<Image>/Script-Fu/Alpha-to-Logo")

(define (the-environment-map 

              img     ; Image
         drawable     ; Drawable
          map-type    ; Environment Map Type
        paint-mode    ; Selected Paint Mode For Use WIth Blend Plug-in
   blend-direction    ; Blend Direction
       blend-shape    ; Blend Shape
     emap-gradient    ; Selected Gradient For Environment Map
      detail-level    ; Detail Level For Solid Noise Plug-in 
      texturesizex    ; Drawable Width
      texturesizey    ; Drawable Height 
       blur-radius    ; Gaussian Blur Radius 
          auto-hsv    ; Autostretch HSV Flag
         turbulent)   ; Turbulance Flag

;
;Declare Variables
;
    (let* 
    (
	(image-height 0)       ; Drawable Height For Blend Plug-in
	(image-width 0)        ; Drawable Width For Blend Plug-in
    (xblend-start 0)       ; X Blend Starting Point
    (yblend-start 0)       ; X Blend Starting Point
    (xblend-end 0)         ; X Blend Ending Point
    (yblend-end 0)         ; X Blend Ending Point
    )
;
; Save Context
; 
(gimp-context-push)

; Start Undo Group

;(gimp-undo-push-group-start img)
;(gimp-image-undo-group-start)
;
; Call Solid Noise Plug-in
;
      (plug-in-solid-noise 
                       1         ; Interactive
                     img         ; Input Image
                drawable         ; Imput Drawable
                    TRUE         ; Tileable
               turbulent         ; Turbulent Noise
          (random 999999)        ; Random Seed
             detail-level        ; Detail Level
             texturesizex        ; Horizontal Texture Size
             texturesizey        ; Vertical Texture Size
      )

;
; Auto-stretch HSV
;
(if (= auto-hsv TRUE)
    (begin  
      (plug-in-autostretch-hsv 1 img drawable)
    )
) ;endif

;
; Gaussian Blur
;
(if (> blur-radius 0)
    (begin  
      (plug-in-gauss                 
                   1     ; Non-interactive 
                 img     ; Image to apply blur 
            drawable     ; Layer to apply blur
         blur-radius     ; Blur Radius x  
         blur-radius     ; Blue Radius y 
                   0     ; Method (IIR=0 RLE=1)
      )
    )
) ;endif

;
; Set Specified Gradient Active
;
(gimp-context-set-gradient emap-gradient)


;
; Environment Map Type: Topographical
;
(if (= map-type 0)
    (begin 
 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)  
(plug-in-gradmap 1 img drawable) 
      (plug-in-gradmap 1 img (vector drawable))   )              ; Map Gradient
      (gimp-item-set-name drawable "EnviroMap: Topo") ; Name it
)     
) ;endif



;
; Environment Map Type: Cloud
;
(if (or (> paint-mode 0) (= map-type 1))
    (begin  

     (set! image-height (car (gimp-drawable-get-height drawable)))     ; Get Height 
     (set! image-width (car (gimp-drawable-get-width drawable)))       ; Get Width


;
; Calculate Gradient Blend Start & End Points
;

      (cond ((= blend-direction 0)         ; Top-Bottom 
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
;          (else
;                 ; For later use.. 
;          )
       ) ;end cond
;
; Check Paint Mode
;

     (if (= paint-mode 0)
            (begin  
              (set! paint-mode 4)   ; Normal Makes No Sense For Cloud Map So Set To Screen As Default
            )
      ) ;endif


	     	(gimp-drawable-edit-gradient-fill
	drawable
	;BLEND-CUSTOM 
	;LAYER-MODE-NORMAL-LEGACY
	blend-shape
	;100
	1
	1
	;back-reverse
	1
	;3
	0.2
	TRUE
	                        xblend-start ; Int32 - X Blend Starting Point
                        yblend-start ; Int32 - Y Blend Starting Point
                        xblend-end   ; Int32 - X Blend Ending Point  
                        yblend-end   ; Int32 - Y Blend Ending Point
	)
	

             (gimp-item-set-name drawable "EnviroMap: Cloud")          ; Name Environment Map
     )
) ;endif


;
; Ensure Environment Map Does Not Have An Alpha Channel So Flatten
;
(gimp-layer-flatten drawable)    

;
; End Undo Group
;
(gimp-image-undo-group-end img)

;
; Update display
;
(gimp-displays-flush)

;
; Restore Context 
;
(gimp-context-pop)

) ; End let
) ; End Main Procedure 
