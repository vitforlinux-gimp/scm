;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Acc�s 
; File > Create > Logos > Bumpy
; Filters > Alpha to logo > Bumpy ...
;
;
; origine : http://www.lefinnois.net/wp/index.php/2007/10/29/mise-a-jour-des-script-fu-pour-the-gimp-24/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; bumpy.scm
; Version 0.3 (For The Gimp 2.0 and 2.2 and 2.4)
; A Script-Fu that create a bumpmapped Text or Shape
;
; Copyright (C) 2005 Denis Bodor <lefinnois@lefinnois.net>
;
; This program is free software; you can redistribute it and/or 
; modify it under the terms of the GNU General Public License   
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

(define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))

(define
	(
		apply-bumpy300-logo-effect
		img
		basetext
		text-color
		boolrippleh
		boolripplev
		bnoise
		bplasma
		colored
		bcolor
		
	)

	(let* 
		(
			(width (car (gimp-drawable-get-width basetext)))
			(height (car (gimp-drawable-get-height basetext)))
			(fond (car (gimp-layer-new-ng   img width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
			(damap (car (gimp-layer-new-ng  img width height RGB-IMAGE "Map" 100 LAYER-MODE-NORMAL-LEGACY)))
			(innermap (car (gimp-layer-new-ng  img width height RGB-IMAGE "iMap" 100 LAYER-MODE-NORMAL-LEGACY)))
			(chantext)
			(masktext)
		)

		(gimp-context-push)
		(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)


		; filling back with background
		(gimp-context-set-background '(255 255 255))
		(gimp-selection-none img)
		(script-fu-util-image-resize-from-layer img basetext)
		(gimp-image-insert-layer img fond 0 1)
		(gimp-drawable-edit-clear fond)

		; correcting resizing effect on background
		(gimp-context-set-foreground '(255 255 255))
		(gimp-layer-resize-to-image-size fond)
		(gimp-drawable-edit-fill fond FILL-FOREGROUND)

		;(gimp-message (number->string width))
		;(gimp-message (number->string height))

		; waving/rippling the text
		(if (= boolrippleh TRUE)
		    (cond((not(defined? 'plug-in-ripple))
		 		     (gimp-drawable-merge-new-filter basetext "gegl:ripple" 0 LAYER-MODE-REPLACE 1.0
"amplitude" 2 "period" 26 "phi" 0 "angle" 0 "sampler-type" "cubic" "wave-type" "sine" "abyss-policy" "none" "tileable" FALSE))		    
	(else
		(plug-in-ripple 1 img basetext 26 2 0 0 0 TRUE FALSE)))) ; Horiz
		(if (= boolripplev TRUE)
		    (cond((not(defined? 'plug-in-ripple))
		 		     (gimp-drawable-merge-new-filter basetext "gegl:ripple" 0 LAYER-MODE-REPLACE 1.0
"amplitude" 2 "period" 26 "phi" 0 "angle" 90 "sampler-type" "cubic" "wave-type" "sine" "abyss-policy" "none" "tileable" FALSE))		    
	(else
		(plug-in-ripple 1 img basetext 26 2 1 0 0 TRUE FALSE)))) ; Vert
;			(if (= boolrippleh TRUE) (plug-in-waves  1 img basetext 4 10 20 0 0)) ; Horiz
;		(if (= boolripplev TRUE) (plug-in-waves  1 img basetext 4 100 20 0 0)) ; Vert
		(apply-gauss2 img basetext 1 1)

		; save se selection
		(gimp-image-select-item img 2 basetext)
		(set! chantext (car (gimp-selection-save img)))
		(gimp-selection-none img)

		; creating map
		(gimp-image-insert-layer img damap 0 1)
		(gimp-context-set-foreground '(255 255 255))
		(gimp-drawable-edit-fill damap FILL-FOREGROUND)

		(gimp-image-select-item img 2  chantext)
		(gimp-selection-grow img 15)
		(gimp-selection-invert img)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-drawable-edit-fill damap FILL-FOREGROUND)
		(gimp-selection-none img)
		(apply-gauss2 img damap 27 27)
		(gimp-image-select-item img 2  chantext)
		(gimp-drawable-edit-fill damap FILL-FOREGROUND)
		(gimp-selection-none img)
		(apply-gauss2 img damap 2 2)

		(gimp-context-set-foreground '(128 128 128))
		(gimp-selection-all img)
		(gimp-drawable-edit-fill fond FILL-FOREGROUND)
		(gimp-selection-none img)

		(if (= bplasma TRUE)
				    (cond((not(defined? 'plug-in-plasma))
		 		     (gimp-drawable-merge-new-filter fond "gegl:plasma" 0 LAYER-MODE-REPLACE 1.0
"turbulence" 1.0 "x" 0 "y" 0 "width" width "height" height "seed" 0 ) (gimp-drawable-desaturate fond 4))		    
	(else
		(plug-in-plasma 1 img fond 0 1.0)(gimp-drawable-desaturate fond 4))))
		(if (= bnoise TRUE)
				    (cond((not(defined? 'plug-in-noisify))
		 		     (gimp-drawable-merge-new-filter fond "gegl:noise-hurl" 0 LAYER-MODE-REPLACE 1.0
"pct-random" 50 "repeat" 1 "seed" 0 ) (gimp-drawable-desaturate fond 4))		    
	(else
		(plug-in-noisify 1 img fond 1 0.2 0.2 0.2 0))))

		(gimp-drawable-desaturate fond 4)

		; apply bumpmap 1
	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new fond "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 135 "elevation" 42 "depth" 33
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 0
                                      "compensate" TRUE "invert" FALSE "type" "linear"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" damap)
      (gimp-drawable-merge-filter fond filter)
    ))
    (else
		(plug-in-bump-map
			1
			img
			fond
			damap
			135
			42 ; elevation
			33
			0
			0
			0
			0
			1
			0
			0
		)))

		; creating second map (inner shape)
		(gimp-image-insert-layer img innermap 0 1)
		(gimp-context-set-foreground '(255 255 255))
		(gimp-drawable-edit-fill innermap FILL-FOREGROUND)
		(gimp-image-select-item img 2  chantext)
		(gimp-selection-shrink img 3)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-drawable-edit-fill innermap FILL-FOREGROUND)
		(gimp-selection-none img)
		(apply-gauss2 img innermap 6 6)

		(gimp-context-set-foreground text-color)
		(gimp-drawable-edit-fill basetext FILL-FOREGROUND)

	(cond((not(defined? 'plug-in-bump-map)) ;text
	    (let* ((filter (car (gimp-drawable-filter-new basetext "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 135 "elevation" 32 "depth" 5
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0 "ambient" 0
                                      "compensate" TRUE "invert" TRUE "type" "linear"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" innermap)
      (gimp-drawable-merge-filter basetext filter)
    ))
    (else
		(plug-in-bump-map
			1
			img
			basetext
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
			0
		)))

		(gimp-image-select-item img 2  chantext)
		(gimp-selection-shrink img 2)
		(set! masktext (car (gimp-layer-create-mask basetext ADD-MASK-SELECTION)))
		(gimp-layer-add-mask basetext masktext)
		(gimp-selection-none img)
		(apply-gauss2 img masktext 1 1)

		(gimp-image-raise-item img fond)
		(gimp-image-raise-item img fond)
(if (= colored TRUE) (begin 	(gimp-context-set-paint-mode LAYER-MODE-MULTIPLY)	(gimp-context-set-foreground bcolor)
		(gimp-drawable-edit-fill fond FILL-FOREGROUND) ) )
		(gimp-context-pop)

	)
)



(define
	(
		script-fu-bumpy300-logo-alpha
		img
		text-layer
		text-color
		boolrippleh
		boolripplev
		bnoise
		bplasma
		colored
		bcolor
		
	)

	(begin
		(gimp-image-undo-disable img)
		(apply-bumpy300-logo-effect img text-layer text-color boolrippleh boolripplev bnoise bplasma colored bcolor)
		(gimp-image-undo-enable img)
		(gimp-displays-flush)
	)
)

;(gimp-message-set-handler 1)

(script-fu-register
	"script-fu-bumpy300-logo-alpha"
	"Bumpy 300 Alpha..."
	"Create a bumpmapped alpha"
	"Denis Bodor <lefinnois@lefinnois.net>"
	"Denis Bodor"
	"05/14/2005"
	""
	SF-IMAGE	"Image"			0
	SF-DRAWABLE	"Drawable"		0
	SF-COLOR 	"Shape Color" '(200 200 40)
	SF-TOGGLE	"Ripple Horiz." TRUE
	SF-TOGGLE	"Ripple Vert."  TRUE
	SF-TOGGLE 	"Back Noise" TRUE
	SF-TOGGLE 	"Back Plasma." TRUE
	SF-TOGGLE 	"Background colored" FALSE
	 SF-COLOR      "Background  color"         '(255 104 0)
)

(script-fu-menu-register 
	"script-fu-bumpy300-logo-alpha"
	"<Image>/Filters/Alpha to Logo"
)

(define
	(
		script-fu-bumpy300-logo
		text
		font
		size
		justify
		letter-spacing
		line-spacing
			 grow-text
									  outline
		text-color
		boolrippleh
		boolripplev
		bnoise
		bplasma
		colored
		bcolor
		inBufferAmount
		conserve
		
	)
  
	(let*
		(
			(img (car (gimp-image-new 256 256 RGB)))	; nouvelle image -> img
			(justify (cond ((= justify 0) 2)
		        ((= justify 1) 0)
			((= justify 2) 1)))
			(border (* (/ size 4) inBufferAmount))
			(text-layer (car (gimp-text-fontname img -1 0 0 text border TRUE size PIXELS font)))
			(width (car (gimp-drawable-get-width text-layer)))
			(height (car (gimp-drawable-get-height text-layer)))
		)
    
		(gimp-image-undo-disable img)
		(gimp-context-push)
		(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
		(gimp-item-set-name text-layer text)
		(gimp-text-layer-set-justification text-layer justify)
		(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
		(gimp-text-layer-set-line-spacing text-layer line-spacing)
		
		  (gimp-image-resize-to-layers img)
		;;;;;; SHRINK/GROW text
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
	(gimp-selection-shrink img (round outline))   
	(gimp-drawable-edit-clear text-layer)
	(gimp-image-select-item img 2 text-layer)
 ))
		
		(apply-bumpy300-logo-effect img text-layer text-color boolrippleh boolripplev bnoise bplasma colored bcolor)
		  (if (= conserve TRUE) (gimp-image-flatten img))
		(gimp-image-undo-enable img)
		(gimp-context-pop)
		(gimp-display-new img)    
    )
)


(script-fu-register
	"script-fu-bumpy300-logo"
	"Bumpy 300 Logo"
	"Create a bumpmapped logo"
	"Denis Bodor <lefinnois@lefinnois.net>"
	"Denis Bodor"
	"03/31/2005"
	""
	SF-TEXT "Enter your text" "BUMPY"
	SF-FONT "Font Name" "QTVagaRound Bold"
	SF-ADJUSTMENT "Font size (pixels)" '(150 2 1000 1 10 0 0)
	SF-OPTION "Justify" '("Centered" "Left" "Right")
	SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
	SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
	      SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -40 40 1 10 0 0)
  SF-ADJUSTMENT _"Outline"          '(0 0 40 1 10 0 0)
	SF-COLOR "Text Color" '(200 200 40)
	SF-TOGGLE "Ripple Horiz." TRUE
	SF-TOGGLE "Ripple Vert." TRUE
	SF-TOGGLE "Back Noise" TRUE
	SF-TOGGLE "Back Plasma." TRUE
	SF-TOGGLE "Background colored" FALSE
	SF-COLOR   "Background  color"         '(255 104 0)
	SF-ADJUSTMENT  "Buffer amount" '(1 1 200 1 10 0 0)
	SF-TOGGLE   "Merge Layers"     TRUE

	  
	
	
	)

(script-fu-menu-register 
	"script-fu-bumpy300-logo"
	"<Image>/File/Create/Logos"
)

; FIN du script
