; Polka Dot Logo rel 0.03
; Created by Graechan from tutorial by Conbagui at http://www.gimpchat.com/viewtopic.php?f=23&t=9108
; 
; Comments directed to http://gimpchat.com or http://gimpscripts.com
; Support link is at
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
; Rel 0.02 - Bugfix that prevented it's use in 2.6 due to default plugin 'python-fu-foggify' pos. of output layer
; Rel 0.03 - Added a independant color option for the bevel
;29 lug 2024 another step towards delirium and gimp 2.99

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-base-type)) (define gimp-image-get-base-type gimp-image-base-type)))


(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))
;
(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal" "Center to Top"))
;
; include layer Procedure
(define (include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.8 
          )
          (else
           (gimp-image-add-layer image newlayer (+ (car (gimp-image-get-layer-position image oldlayer)) stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end add layer procedure

(define (script-fu-polka-dot-logo 
                                      text
									  letter-spacing
									  line-spacing
                                      font-in 
                                      font-size
									  dots-color
									  bevel-color
									  border-size
                                      bkg-type 
                                      pattern
                                      bkg-color
									  gradient
									  gradient-type
									  reverse
									  blendir
									  repeat
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
		 (selection-channel 0)
		 (aspect 0)
		 (dots-bkg-layer 0)
		 (copy-layer 0)
		 (cloud-layer 0)
		 (stroke-layer 0)
		 (copy-layer-mask 0)
		 (noise-layer 0)
		 
		 (drop-shadow 0)
		 (x1 0)
		 (y1 0)
		 (x2 0)
		 (y2 0)
         )
	(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version	 
    
	(gimp-context-push)
	(gimp-context-set-paint-method "gimp-paintbrush")
	(if (= ver 2.8) (gimp-context-set-dynamics "Pressure Opacity"))
	(gimp-context-set-foreground '(189 189 189)) ;---------------------------------set text color here
	(gimp-context-set-background '(255 255 255))
	
;;;;adjust the size-layer
    (gimp-text-layer-set-justification size-layer 2)
	(gimp-text-layer-set-letter-spacing size-layer letter-spacing)
	(gimp-text-layer-set-line-spacing size-layer line-spacing)
    (set! final-width (car (gimp-drawable-get-width size-layer)))
    (set! final-height (car (gimp-drawable-get-height size-layer)))	

;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 500 4)) TRUE 500 PIXELS font)))
	(gimp-item-set-name text-layer "Text")
;;;;adjust text 
	(gimp-text-layer-set-justification text-layer 2)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
;;;;set the new width and height	
    (set! width (car (gimp-drawable-get-width text-layer)))
    (set! height (car (gimp-drawable-get-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)

;;;;create selection-channel (gimp-image-select-item img 2 selection-channel)
    (cond ((= ver 2.8) (gimp-image-select-item image 2 text-layer)) 
	(else (gimp-image-select-item image 2 text-layer))
	) ;endcond
    (set! selection-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name selection-channel "selection-channel"))
	(else (gimp-item-set-name selection-channel "selection-channel"))
    ) ;endcond
	;(gimp-image-set-active-layer image text-layer)
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector text-layer)))
(else (gimp-image-set-active-layer image text-layer))
)	
	(gimp-selection-none image)
    
;;;;begin the script-----------------------------------------------------------------------------------
;;;;create the dots-bkg layer    
	(set! dots-bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Dots Bkg" 100 LAYER-MODE-NORMAL-LEGACY )))
	(include-layer image dots-bkg-layer text-layer 1) ;stack 0=above 1=below

	(gimp-context-set-background dots-color)
	(gimp-drawable-fill dots-bkg-layer FILL-BACKGROUND)	
	
	(set! copy-layer (car (gimp-layer-copy dots-bkg-layer TRUE)))
	(include-layer image copy-layer text-layer 0) ;stack 0=above 1=below
	(plug-in-newsprint 1 image copy-layer 
	                           17 ;cell-width 
							   1 ;colorspace 
							   100 ;k-pullout 
							   15 ;gry-ang 
							   0 ;gry-spotfn 
							   15 ;red-ang 
							   0 ;red-spotfn 
							   75 ;grn-ang 
							   0 ;grn-spotfn 
							   0 ;blu-ang 
							   0 ;blu-spotfn 
							   15) ;oversample
	(gimp-layer-set-mode copy-layer LAYER-MODE-MULTIPLY-LEGACY )
	;(gimp-image-set-active-layer image dots-bkg-layer)
	(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector dots-bkg-layer)))
(else (gimp-image-set-active-layer image dots-bkg-layer))
)
	;(python-fu-foggify 1 image dots-bkg-layer "Clouds" "White" 4.4 100)
	;(set! cloud-layer (car (gimp-image-get-active-layer image)))
	;(if (= ver 2.6) (begin
	;(gimp-image-lower-layer-to-bottom image cloud-layer)
	;(gimp-image-raise-layer image cloud-layer)
	;)) ;endif
	;(plug-in-gauss-rle2 RUN-NONINTERACTIVE image cloud-layer 140 140)
	;(gimp-layer-set-mode cloud-layer LAYER-MODE-SOFTLIGHT-LEGACY )
	;(set! dots-bkg-layer (car (gimp-image-merge-down image cloud-layer EXPAND-AS-NECESSARY)))
		
	(set! stroke-layer (car (gimp-layer-new image width height RGBA-IMAGE "Stroke" 100 LAYER-MODE-NORMAL-LEGACY )))
	(include-layer image stroke-layer text-layer 1) ;stack 0=above 1=below
	(cond ((= ver 2.8) (gimp-image-select-item image 2 selection-channel))
	(else (gimp-image-select-item image 2 selection-channel))
	) ;endcond
	(gimp-selection-grow image border-size)
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear dots-bkg-layer)
	(gimp-selection-invert image)
	(cond ((= ver 2.8) (gimp-image-select-item image 1 selection-channel))
	(else (gimp-selection-combine  selection-channel 1))
	) ;endcond
	(gimp-context-set-foreground bevel-color)
	(gimp-drawable-edit-fill stroke-layer FILL-FOREGROUND)
	
;;;;create the mask	
	(cond ((= ver 2.8) (gimp-image-select-item image 2 selection-channel))
	(else (gimp-image-select-item image 2 selection-channel))
	) ;endcond
	
	(set! copy-layer-mask (car (gimp-layer-create-mask copy-layer ADD-MASK-SELECTION)))
	(gimp-layer-add-mask copy-layer copy-layer-mask)
	(gimp-selection-none image)
	;(gimp-image-set-active-layer image text-layer)
		(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector text-layer)))
(else (gimp-image-set-active-layer image text-layer))
)
	(dots-layerfx-drop-shadow image
				       text-layer ;drawable
				       "Black" ;color
				       75 ;opacity
				       0 ;contour
				       0 ;noise
				       2 ;mode
				       0 ;spread
				       12 ;size
				       148 ;offsetangle
				       2 ;offsetdist
				       FALSE ;knockout
				       FALSE) ;merge
	
	(dots-layerfx-inner-shadow image
					text-layer ;drawable
					"Black" ;color
					75 ;opacity
					10 ;contour
					0 ;noise
					2 ;mode
					0 ;source
					0 ;choke
					27 ;size
					148 ;offsetangle
					0 ;offsetdist
					FALSE) ;merge
	
	(gimp-layer-remove-mask copy-layer MASK-APPLY)
	(cond ((= ver 2.8) (gimp-image-select-item image 2 selection-channel))
	(else (gimp-image-select-item image 2 selection-channel))
	) ;endcond
	(set! noise-layer (car (gimp-layer-new image width height RGBA-IMAGE "Noise" 100 LAYER-MODE-SOFTLIGHT-LEGACY)))
	(include-layer image noise-layer copy-layer 0) ;stack 0=above 1=below
	(plug-in-solid-noise 1 image noise-layer FALSE FALSE 2384622079 3 4 4)
	(gimp-selection-none image)
	
	;(gimp-image-set-active-layer image text-layer)
			(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector text-layer)))
(else (gimp-image-set-active-layer image text-layer))
)
	(dots-bevel-emboss image
					text-layer ;drawable
					0 ;style
					65 ;depth
					0 ;direction
					21 ;size
					6 ;soften
					141 ;angle
					20 ;altitude
					0 ;glosscontour
					'(255 179 179) ;highlightcolor
					4 ;highlightmode
					34.6 ;highlightopacity
					'(195 0 0) ;shadowcolor
					2 ;shadowmode
					59.4 ;shadowopacity
					6 ;surfacecontour
					FALSE ;invert
					FALSE) ;merge
					
	(dots-bevel-emboss image
					copy-layer ;drawable
					1 ;style
					65 ;depth
					0 ;direction
					30 ;size
					6 ;soften
					141 ;angle
					20 ;altitude
					0 ;glosscontour
					'(255 179 179) ;highlightcolor
					4 ;highlightmode
					34.6 ;highlightopacity
					'(195 0 0) ;shadowcolor
					2 ;shadowmode
					59.4 ;shadowopacity
					6 ;surfacecontour
					FALSE ;invert
					FALSE) ;merge
					
	(map (lambda (x) (gimp-layer-resize-to-image-size x)) (vector->list (cadr (gimp-image-get-layers image))))
	
;;;;create the background layer    
	
	(cond ((not (= bkg-type 3))
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY )))
	(include-layer image bkg-layer dots-bkg-layer 1) ;stack 0=above 1=below
    )
	) ;endcond
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 1) (gimp-drawable-fill bkg-layer FILL-PATTERN))		
    (if (= bkg-type 0) (gimp-drawable-fill bkg-layer FILL-BACKGROUND))	
    (if (= bkg-type 2) 
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
	(set! y1 (/ height 2))
	(set! x2 (/ width 2))
	(set! y2 0)))	
	;(gimp-edit-blend bkg-layer CUSTOM-MODE LAYER-MODE-NORMAL-LEGACY  gradient-type 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE x1 y1 x2 y2)
	(gimp-context-set-gradient-reverse reverse)
	(if (= repeat 1)
	(gimp-context-set-gradient-repeat-mode 2)(gimp-context-set-gradient-repeat-mode 0))
		(gimp-drawable-edit-gradient-fill bkg-layer gradient-type 0 0 1 0 0 x1 y1 x2 y2) ; Fill with gradient

	))
    
;;;;Scale Image to it's original size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (if (= conserve FALSE) (begin
	(set! text-layer (car (gimp-image-merge-visible-layers image CLIP-TO-BOTTOM-LAYER)))
	(gimp-image-remove-channel image selection-channel)	
	)) ;endif
	(gimp-image-scale image final-width final-height )
	(if (= conserve FALSE) (plug-in-unsharp-mask 1 image text-layer 5 .5 0))
	(cond ((= ver 2.8) (gimp-item-set-name text-layer text))
	(else (gimp-item-set-name text-layer text))
    ) ;endcond	
	
	(gimp-context-pop)	
    (gimp-display-new image)
	
    )
  ) 
(script-fu-register "script-fu-polka-dot-logo"
  "Polka Dot Logo"
  "Create an image with a text layer over a pattern layer"
  "Graechan"
  "Graechan - http://gimpchat.com"
  "Nov 2013"
  ""
  SF-TEXT       "Text"    "DOTS"
  SF-ADJUSTMENT "Letter Spacing" '(45 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-FONT       "Font"               "QTGreece"
  SF-ADJUSTMENT "Font size (pixels)" '(200 6 500 1 1 0 1)
  SF-COLOR      "Polka-Dot Color"   '(204 0 0)
  SF-COLOR      "Bevel Color"   '(0 255 0)
  SF-ADJUSTMENT "Border Size" '(20 20 100 1 10 0 0)
  SF-OPTION "Background Type" '("Color" "Pattern" "Gradient" "Transparency")
  SF-PATTERN    "Pattern"            "Qbert"
  SF-COLOR      "Background color"   "Blue"
  SF-GRADIENT   "Background Gradient" "Golden"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
  SF-TOGGLE     "Repeat Gradient"   FALSE
  SF-TOGGLE     "Keep the Layers"   FALSE
  )
(script-fu-menu-register "script-fu-polka-dot-logo" "<Image>/Script-Fu/Logos")
  
 (define (get-blending-mode mode)
  (let* ((modenumbers #(0 1 3 15 4 5 16 17 18 19 20 21 6 7 8 9 10 11 12 13 14)))
    (vector-ref modenumbers mode)
  )
)

(define (math-round input)
  (floor (+ input 0.5))
)

(define (math-ceil input)
  (if (= input (floor input))
    input
    (+ (floor input) 1)
  )
)

(define (get-layer-pos img layer)
  (let* ((layerdata (gimp-image-get-layers img))
	 (numlayers (car layerdata))
	 (layerarray (cadr layerdata))
	 (i 0)
	 (pos -1)
	)
    (while (< i numlayers)
      (if (= layer (vector-ref layerarray i))
	(begin
	  (set! pos i)
	  (set! i numlayers)
	)
	(set! i (+ i 1))
      )
    )
    pos
  )
)

(define (add-under-layer img newlayer oldlayer)
  (gimp-image-insert-layer img newlayer 0 (+ (get-layer-pos img oldlayer) 1))
)

(define (add-over-layer img newlayer oldlayer)
  (gimp-image-insert-layer img newlayer 0 (get-layer-pos img 0 oldlayer) )
)

(define (draw-blurshape img drawable size initgrowth sel invert)
  (let* ((k initgrowth)
	 (currshade 0)
	 (i 0))
    (while (< i size)
      (if (> k 0)
	(gimp-selection-grow img k)
	(if (< k 0)
	  (gimp-selection-shrink img (abs k))
	)
      )
      (if (= invert 1)
	(set! currshade (math-round (* (/ (- size (+ i 1)) size) 255)))
	(set! currshade (math-round (* (/ (+ i 1) size) 255)))
      )
      (gimp-context-set-foreground (list currshade currshade currshade))
      (if (= (car (gimp-selection-is-empty img)) 0)
	(gimp-drawable-edit-fill drawable 0)
      )
      (gimp-image-select-item img 2 sel)
      (set! k (- k 1))
      (set! i (+ i 1))
    )
  )
)

(define (apply-contour drawable channel contour)
  (let* ((contourtypes #(0 0 0 0 0 0 0 0 0 1 1))
	 (contourlengths #(6 6 10 14 18 10 18 18 10 256 256))
	 (contours #(#(0 0 0.5 1 1 0)
#(0 1 0.498039 0 1 1)
#(0 0.25098 0.368627 0.290196 0.588235 0.45098 0.701961 0.701961 0.74902 1)
#(0 0 0.0196078 0.490196 0.0235294 0.490196 0.188235 0.580392 0.309804 0.701961 0.419608 0.85098 0.509804 1)
#(0 0 0.129412 0.0313725 0.25098 0.14902 0.380392 0.4 0.501961 0.65098 0.619608 0.819608 0.74902 0.921569 0.870588 0.968627 1 1)
#(0 0 0.109804 0.278431 0.341176 0.65098 0.760784 0.941176 1 1)
#(0 0 0.129412 0.431373 0.25098 0.929412 0.380392 0.941176 0.501961 0.541176 0.619608 0.129412 0.74902 0.0196078 0.870588 0.388235 1 1)
#(0 0 0.129412 0.290196 0.25098 0.858824 0.380392 0.729412 0.501961 0 0.619608 0.690196 0.74902 0.788235 0.870588 0.0117647 1 1)
#(0 1 0.211765 0.388235 0.380392 0.419608 0.701961 0.6 0.988235 0)
#(0 0.0196078 0.0352941 0.0509804 0.0627451 0.0745098 0.0862745 0.0980392 0.105882 0.113725 0.117647 0.12549 0.129412 0.133333 0.137255 0.141176 0.14902 0.152941 0.156863 0.160784 0.168627 0.172549 0.180392 0.184314 0.188235 0.192157 0.196078 0.2 0.203922 0.207843 0.211765 0.215686 0.215686 0.219608 0.219608 0.223529 0.223529 0.227451 0.227451 0.231373 0.231373 0.231373 0.235294 0.235294 0.235294 0.239216 0.239216 0.239216 0.239216 0.243137 0.243137 0.243137 0.243137 0.243137 0.247059 0.247059 0.247059 0.247059 0.247059 0.247059 0.25098 0.25098 0.25098 0.25098 0.25098 0.278431 0.294118 0.305882 0.317647 0.329412 0.337255 0.34902 0.356863 0.364706 0.372549 0.376471 0.384314 0.388235 0.396078 0.4 0.403922 0.407843 0.411765 0.419608 0.419608 0.423529 0.431373 0.435294 0.439216 0.443137 0.447059 0.45098 0.454902 0.458824 0.462745 0.466667 0.466667 0.470588 0.47451 0.47451 0.478431 0.482353 0.482353 0.482353 0.486275 0.486275 0.486275 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.494118 0.494118 0.494118 0.494118 0.494118 0.494118 0.494118 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.509804 0.52549 0.537255 0.552941 0.568627 0.580392 0.592157 0.6 0.611765 0.619608 0.627451 0.635294 0.639216 0.647059 0.65098 0.654902 0.658824 0.666667 0.670588 0.670588 0.67451 0.678431 0.682353 0.686275 0.690196 0.694118 0.698039 0.698039 0.701961 0.705882 0.709804 0.709804 0.713725 0.717647 0.717647 0.721569 0.721569 0.72549 0.72549 0.729412 0.729412 0.733333 0.733333 0.737255 0.737255 0.741176 0.741176 0.741176 0.741176 0.745098 0.745098 0.745098 0.745098 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.756863 0.760784 0.768627 0.772549 0.776471 0.784314 0.788235 0.796078 0.8 0.803922 0.811765 0.815686 0.819608 0.827451 0.831373 0.835294 0.839216 0.843137 0.85098 0.854902 0.858824 0.862745 0.862745 0.866667 0.870588 0.870588 0.87451 0.87451 0.878431 0.878431 0.878431 0.878431 0.878431 0.87451 0.87451 0.870588 0.870588 0.866667 0.866667 0.862745 0.858824 0.854902 0.85098 0.847059 0.843137 0.839216 0.835294 0.831373 0.827451 0.823529 0.819608 0.815686 0.807843 0.803922 0.8 0.796078 0.792157 0.784314 0.780392 0.776471 0.772549 0.768627 0.760784 0.760784)
#(0 0.00784314 0.0156863 0.0235294 0.0313725 0.0392157 0.0470588 0.054902 0.0627451 0.0705882 0.0784314 0.0862745 0.0941176 0.101961 0.109804 0.117647 0.12549 0.133333 0.141176 0.14902 0.156863 0.164706 0.172549 0.180392 0.188235 0.196078 0.203922 0.211765 0.219608 0.227451 0.235294 0.243137 0.25098 0.258824 0.266667 0.27451 0.282353 0.290196 0.298039 0.305882 0.313725 0.321569 0.329412 0.337255 0.345098 0.352941 0.360784 0.368627 0.376471 0.384314 0.392157 0.4 0.407843 0.415686 0.423529 0.431373 0.439216 0.447059 0.454902 0.462745 0.470588 0.478431 0.486275 0.494118 0.498039 0.490196 0.482353 0.47451 0.466667 0.458824 0.45098 0.443137 0.435294 0.427451 0.419608 0.411765 0.403922 0.396078 0.388235 0.380392 0.372549 0.364706 0.356863 0.34902 0.341176 0.333333 0.32549 0.317647 0.309804 0.301961 0.294118 0.286275 0.278431 0.270588 0.262745 0.254902 0.247059 0.239216 0.231373 0.223529 0.215686 0.207843 0.2 0.192157 0.184314 0.176471 0.168627 0.160784 0.152941 0.145098 0.137255 0.129412 0.121569 0.113725 0.105882 0.0980392 0.0901961 0.0823529 0.0745098 0.0666667 0.0588235 0.0509804 0.0431373 0.0352941 0.027451 0.0196078 0.0117647 0.00392157 0.00392157 0.0117647 0.0196078 0.027451 0.0352941 0.0431373 0.0509804 0.0588235 0.0666667 0.0745098 0.0823529 0.0901961 0.0980392 0.105882 0.113725 0.121569 0.129412 0.137255 0.145098 0.152941 0.160784 0.168627 0.176471 0.184314 0.192157 0.2 0.207843 0.215686 0.223529 0.231373 0.239216 0.247059 0.254902 0.262745 0.270588 0.278431 0.286275 0.294118 0.301961 0.309804 0.317647 0.32549 0.333333 0.341176 0.34902 0.356863 0.364706 0.372549 0.380392 0.388235 0.396078 0.403922 0.411765 0.419608 0.427451 0.435294 0.443137 0.45098 0.458824 0.466667 0.47451 0.482353 0.490196 0.498039 0.501961 0.494118 0.486275 0.478431 0.470588 0.462745 0.454902 0.447059 0.439216 0.431373 0.423529 0.415686 0.407843 0.4 0.392157 0.384314 0.376471 0.368627 0.360784 0.352941 0.345098 0.337255 0.329412 0.321569 0.313725 0.305882 0.298039 0.290196 0.282353 0.27451 0.266667 0.258824 0.25098 0.243137 0.235294 0.227451 0.219608 0.211765 0.203922 0.196078 0.188235 0.180392 0.172549 0.164706 0.156863 0.14902 0.141176 0.133333 0.12549 0.117647 0.109804 0.101961 0.0941176 0.0862745 0.0784314 0.0705882 0.0627451 0.054902 0.0470588 0.0392157 0.0313725 0.0235294 0.0156863 0.00784314)
)))
    (if (= (vector-ref contourtypes (- contour 1)) 0)
      (gimp-drawable-curves-spline drawable channel (vector-ref contourlengths (- contour 1)) (vector-ref contours (- contour 1)))
      (gimp-drawable-curves-explicit drawable channel (vector-ref contourlengths (- contour 1)) (vector-ref contours (- contour 1)))
    )
  )
)

 
(define (dots-bevel-emboss img
					drawable
					style
					depth
					direction
					size
					soften
					angle
					altitude
					glosscontour
					highlightcolor
					highlightmode
					highlightopacity
					shadowcolor
					shadowmode
					shadowopacity
					surfacecontour
					invert
					merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (layername (car (gimp-item-get-name drawable)))
	 (imgtype (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)))
	 (lyrgrowamt (math-round (* size 1.2)))
	 (bumpmaplayer 0)
	 (highlightlayer 0)
	 (highlightmask 0)
	 (shadowlayer 0)
	 (shadowmask 0)
	 (layersize 0)
	 (alphaSel 0)
	 (halfsizef 0)
	 (halfsizec 0)
	 (origmask 0)
	 (alphamask 0)
	)
    (cond
      ((= style 0)
	(begin
	  (set! layersize (list
	    (+ drwwidth (* lyrgrowamt 2))
	    (+ drwheight (* lyrgrowamt 2))
	    (- (car drwoffsets) lyrgrowamt)
	    (- (cadr drwoffsets) lyrgrowamt)
	  ))
	)
      )
      ((= style 1)
	(begin
	  (set! layersize (list
	    drwwidth
	    drwheight
	    (car drwoffsets)
	    (cadr drwoffsets)
	  ))
	)
      )
      ((= style 2)
	(begin
	  (set! layersize (list
	    (+ drwwidth lyrgrowamt)
	    (+ drwheight lyrgrowamt)
	    (- (car drwoffsets) (floor (/ lyrgrowamt 2)))
	    (- (cadr drwoffsets) (floor (/ lyrgrowamt 2)))
	  ))
	)
      )
      (
	(begin
	  (set! layersize (list
	    (+ drwwidth lyrgrowamt)
	    (+ drwheight lyrgrowamt)
	    (- (car drwoffsets) (floor (/ lyrgrowamt 2)))
	    (- (cadr drwoffsets) (floor (/ lyrgrowamt 2)))
	  ))
	)
      )
    )
    (set! bumpmaplayer (car (gimp-layer-new img (car layersize) (cadr layersize) imgtype (string-append layername "-bumpmap") 100 0)))
    (set! highlightlayer (car (gimp-layer-new img (car layersize) (cadr layersize) imgtype (string-append layername "-highlight") highlightopacity (get-blending-mode highlightmode))))
    (set! shadowlayer (car (gimp-layer-new img (car layersize) (cadr layersize) imgtype (string-append layername "-shadow") shadowopacity (get-blending-mode shadowmode))))
    (add-over-layer img bumpmaplayer drawable)
    (add-over-layer img shadowlayer bumpmaplayer)
    (add-over-layer img highlightlayer shadowlayer)
    (gimp-layer-set-offsets bumpmaplayer (caddr layersize) (cadddr layersize))
    (gimp-layer-set-offsets shadowlayer (caddr layersize) (cadddr layersize))
    (gimp-layer-set-offsets highlightlayer (caddr layersize) (cadddr layersize))
    (gimp-selection-all img)
    (gimp-context-set-foreground highlightcolor)
    (gimp-drawable-edit-fill highlightlayer 0)
    (gimp-context-set-foreground shadowcolor)
    (gimp-drawable-edit-fill shadowlayer 0)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill bumpmaplayer 0)
    (set! highlightmask (car (gimp-layer-create-mask highlightlayer 1)))
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask highlightlayer highlightmask)
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
       (gimp-selection-combine (car (gimp-layer-get-mask drawable)) 3)
    )
    (set! alphaSel (car (gimp-selection-save img)))
    (cond
      ((= style 0)
	(draw-blurshape img bumpmaplayer size size alphaSel 0)
      )
      ((= style 1)
	(draw-blurshape img bumpmaplayer size 0 alphaSel 0)
      )
      ((= style 2)
	(begin
	  (set! halfsizec (math-ceil (/ size 2)))
	  (draw-blurshape img bumpmaplayer size halfsizec alphaSel 0)
	)
      )
      (
	(begin
	  (set! halfsizef (floor (/ size 2)))
	  (set! halfsizec (- size halfsizef))
	  (gimp-selection-all img)
	  (gimp-context-set-foreground '(255 255 255))
	  (gimp-drawable-edit-fill bumpmaplayer 0)
	  (draw-blurshape img bumpmaplayer halfsizec halfsizec alphaSel 1)
	  (draw-blurshape img bumpmaplayer halfsizef 0 alphaSel 0)
	)
      )
    )
    (gimp-selection-all img)
    (gimp-context-set-foreground '(127 127 127))
    (gimp-drawable-edit-fill highlightmask 0)
    (gimp-selection-none img)
    (if (> surfacecontour 0)
      (apply-contour bumpmaplayer 0 surfacecontour)
    )
    (if (< angle 0)
      (set! angle (+ angle 360))
    )
    (plug-in-bump-map 1 img highlightmask bumpmaplayer angle altitude depth 0 0 0 0 1 direction 0)
    (if (> glosscontour 0)
      (apply-contour highlightmask 0 glosscontour)
    )
    (if (> soften 0)
      (plug-in-gauss-rle 1 img highlightmask soften 1 1)
    )
    (if (> invert 0)
      (gimp-invert highlightmask)
    )
    (gimp-channel-combine-masks shadowmask highlightmask 2 0 0)
   ; (gimp-levels highlightmask 0 127 255 1.0 0 255)
   ; (gimp-levels shadowmask 0 0 127 1.0 255 0)
       (gimp-drawable-levels highlightmask 0 0.5 1 FALSE 1.0 0.1 1 FALSE)
    (gimp-drawable-levels shadowmask 0 0 0.5 FALSE 1.0 1 0 FALSE)
    (gimp-image-select-item img 2 alphaSel)
    (if (= style 0)
      (gimp-selection-grow img size)
      (if (or (= style 2) (= style 3))
	(gimp-selection-grow img halfsizec)
      )
    )
    (gimp-selection-invert img)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill shadowmask 0)
    (gimp-selection-none img)
    (gimp-image-remove-layer img bumpmaplayer)
    (if (= merge 1)
      (if (= style 1)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (begin
	      (set! origmask (car (gimp-channel-copy origmask)))
	      (gimp-layer-remove-mask drawable 1)
	    )
	  )
	  (set! alphamask (car (gimp-layer-create-mask drawable 3)))
	  (set! shadowlayer (car (gimp-image-merge-down img shadowlayer 0)))
	  (set! highlightlayer (car (gimp-image-merge-down img highlightlayer 0)))
	  (gimp-item-set-name highlightlayer layername)
	  (gimp-layer-add-mask highlightlayer alphamask)
	  (gimp-layer-remove-mask highlightlayer 0)
	  (if (> origmask -1)
	    (gimp-layer-add-mask highlightlayer origmask)
	  )
	)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (gimp-layer-remove-mask drawable 0)
	  )
	  (set! shadowlayer (car (gimp-image-merge-down img shadowlayer 0)))
	  (set! highlightlayer (car (gimp-image-merge-down img highlightlayer 0)))
	  (gimp-item-set-name highlightlayer layername)
	)
      )
    )
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (dots-layerfx-drop-shadow img
				       drawable
				       color
				       opacity
				       contour
				       noise
				       mode
				       spread
				       size
				       offsetangle
				       offsetdist
				       knockout
				       merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (layername (car (gimp-item-get-name drawable)))
	 (growamt (math-ceil (/ size 2)))
	 (steps (math-round (- size (* (/ spread 100) size))))
	 (lyrgrowamt (math-round (* growamt 1.2)))
	 (shadowlayer (car (gimp-layer-new img (+ drwwidth (* lyrgrowamt 2)) (+ drwheight (* lyrgrowamt 2)) (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-dropshadow") opacity (get-blending-mode mode))))
	 (shadowmask 0)
	 (alphaSel 0)
	 (ang (* (* (+ offsetangle 180) -1) (/ (* 4 (atan 1.0)) 180)))
	 (offsetX (math-round (* offsetdist (cos ang))))
	 (offsetY (math-round (* offsetdist (sin ang))))
	 (origmask 0)
	)
    (add-under-layer img shadowlayer drawable)
    (gimp-layer-set-offsets shadowlayer (- (+ (car drwoffsets) offsetX) lyrgrowamt) (- (+ (cadr drwoffsets) offsetY) lyrgrowamt))
    (gimp-selection-all img)
    (gimp-context-set-foreground color)
    (gimp-drawable-edit-fill shadowlayer 0)
    (gimp-selection-none img)
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
      (gimp-selection-combine (car (gimp-layer-get-mask drawable)) 3)
    )
    (gimp-selection-translate img offsetX offsetY)
    (set! alphaSel (car (gimp-selection-save img)))
    (draw-blurshape img shadowmask steps growamt alphaSel 0)
    (gimp-selection-none img)
    (if (> contour 0)
      (begin
	(apply-contour shadowmask 0 contour)
	(gimp-image-select-item img 2 alphaSel)
	(gimp-selection-grow img growamt)
	(gimp-selection-invert img)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill shadowmask 0)
	(gimp-selection-none img)
      )
    )
    (if (> noise 0)
      (apply-noise img drawable shadowlayer noise)
    )
    (if (= knockout 1)
      (begin
	(gimp-context-set-foreground '(0 0 0))
	(gimp-image-select-item img 2 drawable)
	(gimp-drawable-edit-fill shadowmask 0)
      )
    )
    (gimp-layer-remove-mask shadowlayer 0)
    (gimp-selection-none img)
    (if (= merge 1)
      (begin
	(set! origmask (car (gimp-layer-get-mask drawable)))
	(if (> origmask -1)
	  (gimp-layer-remove-mask drawable 0)
	)
	(set! shadowlayer (car (gimp-image-merge-down img drawable 0)))
	(gimp-item-set-name shadowlayer layername)
      )
    )
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (dots-layerfx-inner-shadow img
					drawable
					color
					opacity
					contour
					noise
					mode
					source
					choke
					size
					offsetangle
					offsetdist
					merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (layername (car (gimp-item-get-name drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (shadowlayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-innershadow") opacity (get-blending-mode mode))))
	 (shadowmask 0)
	 (alphaSel 0)
	 (growamt (math-ceil (/ size 2)))
	 (chokeamt (* (/ choke 100) size))
	 (steps (math-round (- size chokeamt)))
	 (ang (* (* (+ offsetangle 180) -1) (/ (* 4 (atan 1.0)) 180)))
	 (offsetX (math-round (* offsetdist (cos ang))))
	 (offsetY (math-round (* offsetdist (sin ang))))
	 (origmask 0)
	 (alphamask 0)
	)
    (add-over-layer img shadowlayer drawable)
    (gimp-layer-set-offsets shadowlayer (car drwoffsets) (cadr drwoffsets))
    (gimp-selection-all img)
    (gimp-context-set-foreground color)
    (gimp-drawable-edit-fill shadowlayer 0)
    (gimp-selection-none img)
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
      (gimp-selection-combine (car (gimp-layer-get-mask drawable)) 3)
    )
    (gimp-selection-translate img offsetX offsetY)
    (set! alphaSel (car (gimp-selection-save img)))
    (if (= source 0)
      (begin
	(gimp-selection-all img)
	(gimp-context-set-foreground '(255 255 255))
	(gimp-drawable-edit-fill shadowmask 0)
	(gimp-image-select-item img 2 alphaSel)
	(draw-blurshape img shadowmask steps (- growamt chokeamt) alphaSel 1)
      )
      (draw-blurshape img shadowmask steps (- growamt chokeamt) alphaSel 0)
    )
    (gimp-selection-none img)
    (if (> contour 0)
      (apply-contour shadowmask 0 contour)
    )
    (if (= merge 0)
      (begin
	(gimp-image-select-item img 2 drawable)
	(gimp-selection-invert img)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill shadowmask 0)
      )
    )
    (if (> noise 0)
      (apply-noise img drawable shadowlayer noise)
    )
    (gimp-layer-remove-mask shadowlayer 0)
    (if (= merge 1)
      (if (= source 0)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (begin
	      (set! origmask (car (gimp-channel-copy origmask)))
	      (gimp-layer-remove-mask drawable 1)
	    )
	  )
	  (set! alphamask (car (gimp-layer-create-mask drawable 3)))
	  (set! shadowlayer (car (gimp-image-merge-down img shadowlayer 0)))
	  (gimp-item-set-name shadowlayer layername)
	  (gimp-layer-add-mask shadowlayer alphamask)
	  (gimp-layer-remove-mask shadowlayer 0)
	  (if (> origmask -1)
	    (gimp-layer-add-mask shadowlayer origmask)
	  )
	)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (begin
	      (set! origmask (car (gimp-channel-copy origmask)))
	      (gimp-layer-remove-mask drawable 1)
	    )
	  )
	  (set! shadowlayer (car (gimp-image-merge-down img shadowlayer 0)))
	  (gimp-item-set-name shadowlayer layername)
	  (if (> origmask -1)
	    (gimp-layer-add-mask shadowlayer origmask)
	  )
	)
      )
    )
    (gimp-selection-none img)
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)
