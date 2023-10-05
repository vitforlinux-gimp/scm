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
;
(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal"))
;
; include layer Procedure
(define (include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-layer-position image oldlayer)) stack))                                     ;For GIMP 2.8 
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
									  conserve
									  )
  (let* (
         (image (car (gimp-image-new 256 256 RGB)))         
         (border (/ font-size 4))
		 (font (if (> (string-length font-in) 0) font-in (car (gimp-context-get-font))))
         (size-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (final-width (car (gimp-drawable-width size-layer)))
         (final-height (car (gimp-drawable-height size-layer)))
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
	(if (= ver 2.8) (gimp-context-set-dynamics "Dynamics Off"))
	(gimp-context-set-foreground '(189 189 189)) ;---------------------------------set text color here
	(gimp-context-set-background '(255 255 255))
	
;;;;adjust the size-layer
    (gimp-text-layer-set-justification size-layer 2)
	(gimp-text-layer-set-letter-spacing size-layer letter-spacing)
	(gimp-text-layer-set-line-spacing size-layer line-spacing)
    (set! final-width (car (gimp-drawable-width size-layer)))
    (set! final-height (car (gimp-drawable-height size-layer)))	

;;;;Add the text layer for a temporary larger Image size
    (set! text-layer (car (gimp-text-fontname image -1 0 0 text (round (/ 500 4)) TRUE 500 PIXELS font)))
	(gimp-drawable-set-name text-layer "Text")
;;;;adjust text 
	(gimp-text-layer-set-justification text-layer 2)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
;;;;set the new width and height	
    (set! width (car (gimp-drawable-width text-layer)))
    (set! height (car (gimp-drawable-height text-layer)))    
    (gimp-image-remove-layer image size-layer)
    (gimp-image-resize-to-layers image)

;;;;create selection-channel (gimp-selection-load selection-channel)
    (cond ((= ver 2.8) (gimp-image-select-item image 2 text-layer)) 
	(else (gimp-selection-layer-alpha text-layer))
	) ;endcond
    (set! selection-channel (car (gimp-selection-save image)))
	(cond ((= ver 2.8) (gimp-item-set-name selection-channel "selection-channel"))
	(else (gimp-drawable-set-name selection-channel "selection-channel"))
    ) ;endcond
	(gimp-image-set-active-layer image text-layer)	
	(gimp-selection-none image)
    
;;;;begin the script-----------------------------------------------------------------------------------
;;;;create the dots-bkg layer    
	(set! dots-bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Dots Bkg" 100 NORMAL-MODE)))
	(include-layer image dots-bkg-layer text-layer 1) ;stack 0=above 1=below

	(gimp-context-set-background dots-color)
	(gimp-drawable-fill dots-bkg-layer BACKGROUND-FILL)	
	
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
	(gimp-layer-set-mode copy-layer MULTIPLY-MODE)
	(gimp-image-set-active-layer image dots-bkg-layer)
	;(python-fu-foggify 1 image dots-bkg-layer "Clouds" "White" 4.4 100)
	;(set! cloud-layer (car (gimp-image-get-active-layer image)))
	;(if (= ver 2.6) (begin
	;(gimp-image-lower-layer-to-bottom image cloud-layer)
	;(gimp-image-raise-layer image cloud-layer)
	;)) ;endif
	;(plug-in-gauss-rle2 RUN-NONINTERACTIVE image cloud-layer 140 140)
	;(gimp-layer-set-mode cloud-layer SOFTLIGHT-MODE )
	;(set! dots-bkg-layer (car (gimp-image-merge-down image cloud-layer EXPAND-AS-NECESSARY)))
		
	(set! stroke-layer (car (gimp-layer-new image width height RGBA-IMAGE "Stroke" 100 NORMAL-MODE)))
	(include-layer image stroke-layer text-layer 1) ;stack 0=above 1=below
	(cond ((= ver 2.8) (gimp-image-select-item image 2 selection-channel))
	(else (gimp-selection-load selection-channel))
	) ;endcond
	(gimp-selection-grow image border-size)
	(gimp-selection-invert image)
	(gimp-edit-clear dots-bkg-layer)
	(gimp-selection-invert image)
	(cond ((= ver 2.8) (gimp-image-select-item image 1 selection-channel))
	(else (gimp-selection-combine  selection-channel 1))
	) ;endcond
	(gimp-context-set-foreground bevel-color)
	(gimp-edit-fill stroke-layer FOREGROUND-FILL)
	
;;;;create the mask	
	(cond ((= ver 2.8) (gimp-image-select-item image 2 selection-channel))
	(else (gimp-selection-load selection-channel))
	) ;endcond
	
	(set! copy-layer-mask (car (gimp-layer-create-mask copy-layer ADD-SELECTION-MASK)))
	(gimp-layer-add-mask copy-layer copy-layer-mask)
	(gimp-selection-none image)
	(gimp-image-set-active-layer image text-layer)
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
	(else (gimp-selection-load selection-channel))
	) ;endcond
	(set! noise-layer (car (gimp-layer-new image width height RGBA-IMAGE "Noise" 100 SOFTLIGHT-MODE)))
	(include-layer image noise-layer copy-layer 0) ;stack 0=above 1=below
	(plug-in-solid-noise 1 image noise-layer FALSE FALSE 2384622079 3 4 4)
	(gimp-selection-none image)
	
	(gimp-image-set-active-layer image text-layer)
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
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 NORMAL-MODE)))
	(include-layer image bkg-layer dots-bkg-layer 1) ;stack 0=above 1=below
    )
	) ;endcond
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (= bkg-type 1) (gimp-drawable-fill bkg-layer PATTERN-FILL))		
    (if (= bkg-type 0) (gimp-drawable-fill bkg-layer BACKGROUND-FILL))	
    (if (= bkg-type 2) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer BACKGROUND-FILL)
    (if (= blendir 0) (set! x2 width))
	(if (= blendir 1) (set! y2 height))
	(if (= blendir 2) (begin
	(set! x2 (/ width 2))
	(set! y2 (/ height 2))))	
	(gimp-edit-blend bkg-layer CUSTOM-MODE NORMAL-MODE gradient-type 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE x1 y1 x2 y2)))
    
;;;;Scale Image to it's original size;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (if (= conserve FALSE) (begin
	(set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))
	(gimp-image-remove-channel image selection-channel)	
	)) ;endif
	(gimp-image-scale-full image final-width final-height 3)
	(if (= conserve FALSE) (plug-in-unsharp-mask 1 image text-layer 5 .5 0))
	(cond ((= ver 2.8) (gimp-item-set-name text-layer text))
	(else (gimp-drawable-set-name text-layer text))
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
  SF-FONT       "Font"               "Insaniburger with Cheese"
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
  (gimp-image-add-layer img newlayer (+ (get-layer-pos img oldlayer) 1))
)

(define (add-over-layer img newlayer oldlayer)
  (gimp-image-add-layer img newlayer (get-layer-pos img oldlayer))
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
      (gimp-palette-set-foreground (list currshade currshade currshade))
      (if (= (car (gimp-selection-is-empty img)) 0)
	(gimp-edit-fill drawable 0)
      )
      (gimp-selection-load sel)
      (set! k (- k 1))
      (set! i (+ i 1))
    )
  )
)

(define (apply-contour drawable channel contour)
  (let* ((contourtypes #(0 0 0 0 0 0 0 0 0 1 1))
	 (contourlengths #(6 6 10 14 18 10 18 18 10 256 256))
	 (contours #(#(0 0 127 255 255 0)
#(0 255 127 0 255 255)
#(0 64 94 74 150 115 179 179 191 255)
#(0 0 5 125 6 125 48 148 79 179 107 217 130 255)
#(0 0 33 8 64 38 97 102 128 166 158 209 191 235 222 247 255 255)
#(0 0 28 71 87 166 194 240 255 255)
#(0 0 33 110 64 237 97 240 128 138 158 33 191 5 222 99 255 255)
#(0 0 33 74 64 219 97 186 128 0 158 176 191 201 222 3 255 255)
#(3 255 54 99 97 107 179 153 252 0)
#(0 5 9 13 16 19 22 25 27 29 30 32 33 34 35 36 38 39 40 41 43 44 46 47 48 49 50 51 52 53 54 55 55 56 56 57 57 58 58 59 59 59 60 60 60 61 61 61 61 62 62 62 62 62 63 63 63 63 63 63 64 64 64 64 64 71 75 78 81 84 86 89 91 93 95 96 98 99 101 102 103 104 105 107 107 108 110 111 112 113 114 115 116 117 118 119 119 120 121 121 122 123 123 123 124 124 124 125 125 125 125 125 125 125 126 126 126 126 126 126 126 125 125 125 125 125 125 125 125 130 134 137 141 145 148 151 153 156 158 160 162 163 165 166 167 168 170 171 171 172 173 174 175 176 177 178 178 179 180 181 181 182 183 183 184 184 185 185 186 186 187 187 188 188 189 189 189 189 190 190 190 190 191 191 191 191 191 191 191 191 191 191 193 194 196 197 198 200 201 203 204 205 207 208 209 211 212 213 214 215 217 218 219 220 220 221 222 222 223 223 224 224 224 224 224 223 223 222 222 221 221 220 219 218 217 216 215 214 213 212 211 210 209 208 206 205 204 203 202 200 199 198 197 196 194 194)
#(0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42 44 46 48 50 52 54 56 58 60 62 64 66 68 70 72 74 76 78 80 82 84 86 88 90 92 94 96 98 100 102 104 106 108 110 112 114 116 118 120 122 124 126 127 125 123 121 119 117 115 113 111 109 107 105 103 101 99 97 95 93 91 89 87 85 83 81 79 77 75 73 71 69 67 65 63 61 59 57 55 53 51 49 47 45 43 41 39 37 35 33 31 29 27 25 23 21 19 17 15 13 11 9 7 5 3 1 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 33 35 37 39 41 43 45 47 49 51 53 55 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119 121 123 125 127 128 126 124 122 120 118 116 114 112 110 108 106 104 102 100 98 96 94 92 90 88 86 84 82 80 78 76 74 72 70 68 66 64 62 60 58 56 54 52 50 48 46 44 42 40 38 36 34 32 30 28 26 24 22 20 18 16 14 12 10 8 6 4 2))))
    (if (= (vector-ref contourtypes (- contour 1)) 0)
      (gimp-curves-spline drawable channel (vector-ref contourlengths (- contour 1)) (vector-ref contours (- contour 1)))
      (gimp-curves-explicit drawable channel (vector-ref contourlengths (- contour 1)) (vector-ref contours (- contour 1)))
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
  (let* ((origfgcolor (car (gimp-palette-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-width drawable)))
	 (drwheight (car (gimp-drawable-height drawable)))
	 (drwoffsets (gimp-drawable-offsets drawable))
	 (layername (car (gimp-drawable-get-name drawable)))
	 (imgtype (cond ((= (car (gimp-image-base-type img)) 0) 1) ((= (car (gimp-image-base-type img)) 1) 3)))
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
    (gimp-palette-set-foreground highlightcolor)
    (gimp-edit-fill highlightlayer 0)
    (gimp-palette-set-foreground shadowcolor)
    (gimp-edit-fill shadowlayer 0)
    (gimp-palette-set-foreground '(0 0 0))
    (gimp-edit-fill bumpmaplayer 0)
    (set! highlightmask (car (gimp-layer-create-mask highlightlayer 1)))
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask highlightlayer highlightmask)
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-selection-layer-alpha drawable)
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
	  (gimp-palette-set-foreground '(255 255 255))
	  (gimp-edit-fill bumpmaplayer 0)
	  (draw-blurshape img bumpmaplayer halfsizec halfsizec alphaSel 1)
	  (draw-blurshape img bumpmaplayer halfsizef 0 alphaSel 0)
	)
      )
    )
    (gimp-selection-all img)
    (gimp-palette-set-foreground '(127 127 127))
    (gimp-edit-fill highlightmask 0)
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
    (gimp-levels highlightmask 0 127 255 1.0 0 255)
    (gimp-levels shadowmask 0 0 127 1.0 255 0)
    (gimp-selection-load alphaSel)
    (if (= style 0)
      (gimp-selection-grow img size)
      (if (or (= style 2) (= style 3))
	(gimp-selection-grow img halfsizec)
      )
    )
    (gimp-selection-invert img)
    (gimp-palette-set-foreground '(0 0 0))
    (gimp-edit-fill shadowmask 0)
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
	  (gimp-drawable-set-name highlightlayer layername)
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
	  (gimp-drawable-set-name highlightlayer layername)
	)
      )
    )
    (gimp-palette-set-foreground origfgcolor)
    (gimp-selection-load origselection)
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
  (let* ((origfgcolor (car (gimp-palette-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-width drawable)))
	 (drwheight (car (gimp-drawable-height drawable)))
	 (drwoffsets (gimp-drawable-offsets drawable))
	 (layername (car (gimp-drawable-get-name drawable)))
	 (growamt (math-ceil (/ size 2)))
	 (steps (math-round (- size (* (/ spread 100) size))))
	 (lyrgrowamt (math-round (* growamt 1.2)))
	 (shadowlayer (car (gimp-layer-new img (+ drwwidth (* lyrgrowamt 2)) (+ drwheight (* lyrgrowamt 2)) (cond ((= (car (gimp-image-base-type img)) 0) 1) ((= (car (gimp-image-base-type img)) 1) 3)) (string-append layername "-dropshadow") opacity (get-blending-mode mode))))
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
    (gimp-palette-set-foreground color)
    (gimp-edit-fill shadowlayer 0)
    (gimp-selection-none img)
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-selection-layer-alpha drawable)
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
	(gimp-selection-load alphaSel)
	(gimp-selection-grow img growamt)
	(gimp-selection-invert img)
	(gimp-palette-set-foreground '(0 0 0))
	(gimp-edit-fill shadowmask 0)
	(gimp-selection-none img)
      )
    )
    (if (> noise 0)
      (apply-noise img drawable shadowlayer noise)
    )
    (if (= knockout 1)
      (begin
	(gimp-palette-set-foreground '(0 0 0))
	(gimp-selection-layer-alpha drawable)
	(gimp-edit-fill shadowmask 0)
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
	(gimp-drawable-set-name shadowlayer layername)
      )
    )
    (gimp-palette-set-foreground origfgcolor)
    (gimp-selection-load origselection)
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
  (let* ((origfgcolor (car (gimp-palette-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-width drawable)))
	 (drwheight (car (gimp-drawable-height drawable)))
	 (layername (car (gimp-drawable-get-name drawable)))
	 (drwoffsets (gimp-drawable-offsets drawable))
	 (shadowlayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-base-type img)) 0) 1) ((= (car (gimp-image-base-type img)) 1) 3)) (string-append layername "-innershadow") opacity (get-blending-mode mode))))
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
    (gimp-palette-set-foreground color)
    (gimp-edit-fill shadowlayer 0)
    (gimp-selection-none img)
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-selection-layer-alpha drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
      (gimp-selection-combine (car (gimp-layer-get-mask drawable)) 3)
    )
    (gimp-selection-translate img offsetX offsetY)
    (set! alphaSel (car (gimp-selection-save img)))
    (if (= source 0)
      (begin
	(gimp-selection-all img)
	(gimp-palette-set-foreground '(255 255 255))
	(gimp-edit-fill shadowmask 0)
	(gimp-selection-load alphaSel)
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
	(gimp-selection-layer-alpha drawable)
	(gimp-selection-invert img)
	(gimp-palette-set-foreground '(0 0 0))
	(gimp-edit-fill shadowmask 0)
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
	  (gimp-drawable-set-name shadowlayer layername)
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
	  (gimp-drawable-set-name shadowlayer layername)
	  (if (> origmask -1)
	    (gimp-layer-add-mask shadowlayer origmask)
	  )
	)
      )
    )
    (gimp-selection-none img)
    (gimp-palette-set-foreground origfgcolor)
    (gimp-selection-load origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)