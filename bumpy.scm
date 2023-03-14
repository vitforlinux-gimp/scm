;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; Accès 
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


(define
	(
		apply-bumpy-logo-effect
		img
		basetext
		text-color
		boolrippleh
		boolripplev
		bnoise
		bplasma
	)

	(let* 
		(
			(width (car (gimp-drawable-get-width basetext)))
			(height (car (gimp-drawable-get-height basetext)))
			(fond (car (gimp-layer-new   img width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
			(damap (car (gimp-layer-new  img width height RGB-IMAGE "Map" 100 LAYER-MODE-NORMAL-LEGACY)))
			(innermap (car (gimp-layer-new  img width height RGB-IMAGE "iMap" 100 LAYER-MODE-NORMAL-LEGACY)))
			(chantext)
			(masktext)
		)

		(gimp-context-push)

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
		(if (= boolrippleh TRUE) (plug-in-ripple 1 img basetext 26 2 0 0 0 TRUE FALSE)) ; Horiz
		(if (= boolripplev TRUE) (plug-in-ripple 1 img basetext 26 2 1 0 0 TRUE FALSE)) ; Vert
		(plug-in-gauss-rle2 1 img basetext 1 1)

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
		(plug-in-gauss-rle2 1 img damap 27 27)
		(gimp-image-select-item img 2  chantext)
		(gimp-drawable-edit-fill damap FILL-FOREGROUND)
		(gimp-selection-none img)
		(plug-in-gauss-rle2 1 img damap 2 2)

		(gimp-context-set-foreground '(128 128 128))
		(gimp-selection-all img)
		(gimp-drawable-edit-fill fond FILL-FOREGROUND)
		(gimp-selection-none img)

		(if (= bplasma TRUE) (plug-in-plasma 1 img fond 0 1.0) (gimp-drawable-desaturate fond 4))
		(if (= bnoise TRUE)  (plug-in-noisify 1 img fond 1 0.2 0.2 0.2 0))

		(gimp-drawable-desaturate fond 4)

		; apply bumpmap
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
		)

		; creating second map (inner shape)
		(gimp-image-insert-layer img innermap 0 1)
		(gimp-context-set-foreground '(255 255 255))
		(gimp-drawable-edit-fill innermap FILL-FOREGROUND)
		(gimp-image-select-item img 2  chantext)
		(gimp-selection-shrink img 3)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-drawable-edit-fill innermap FILL-FOREGROUND)
		(gimp-selection-none img)
		(plug-in-gauss-rle2 1 img innermap 6 6)

		(gimp-context-set-foreground text-color)
		(gimp-drawable-edit-fill basetext FILL-FOREGROUND)

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
		)

		(gimp-image-select-item img 2  chantext)
		(gimp-selection-shrink img 2)
		(set! masktext (car (gimp-layer-create-mask basetext ADD-MASK-SELECTION)))
		(gimp-layer-add-mask basetext masktext)
		(gimp-selection-none img)
		(plug-in-gauss-rle2 1 img masktext 1 1)

		(gimp-image-raise-item img fond)
		(gimp-image-raise-item img fond)

		(gimp-context-pop)

	)
)



(define
	(
		script-fu-bumpy-logo-alpha
		img
		text-layer
		text-color
		boolrippleh
		boolripplev
		bnoise
		bplasma
	)

	(begin
		(gimp-image-undo-disable img)
		(apply-bumpy-logo-effect img text-layer text-color boolrippleh boolripplev bnoise bplasma)
		(gimp-image-undo-enable img)
		(gimp-displays-flush)
	)
)

(gimp-message-set-handler 1)

(script-fu-register
	"script-fu-bumpy-logo-alpha"
	"Bumpy Alpha..."
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
)

(script-fu-menu-register 
	"script-fu-bumpy-logo-alpha"
	"<Image>/Filters/Alpha to Logo"
)

(define
	(
		script-fu-bumpy-logo
		font
		text
		text-color
		boolrippleh
		boolripplev
		bnoise
		bplasma
		size
	)
  
	(let*
		(
			(img (car (gimp-image-new 256 256 RGB)))	; nouvelle image -> img
			(border (/ size 4))
			(text-layer (car (gimp-text-fontname img -1 0 0 text border TRUE size PIXELS font)))
			(width (car (gimp-drawable-get-width text-layer)))
			(height (car (gimp-drawable-get-height text-layer)))
		)
    
		(gimp-image-undo-disable img)
		(gimp-item-set-name text-layer text)
		(apply-bumpy-logo-effect img text-layer text-color boolrippleh boolripplev bnoise bplasma)
		(gimp-image-undo-enable img)
		(gimp-display-new img)    
    )
)


(script-fu-register
	"script-fu-bumpy-logo"
	"Bumpy"
	"Create a bumpmapped logo"
	"Denis Bodor <lefinnois@lefinnois.net>"
	"Denis Bodor"
	"03/31/2005"
	""
	SF-FONT "Font Name" "Blippo Heavy"
	SF-TEXT "Enter your text" "BUMPY"
	SF-COLOR "Text Color" '(200 200 40)
	SF-TOGGLE "Ripple Horiz." TRUE
	SF-TOGGLE "Ripple Vert." TRUE
	SF-TOGGLE "Back Noise" TRUE
	SF-TOGGLE "Back Plasma." TRUE
	SF-ADJUSTMENT "Font size (pixels)" '(150 2 1000 1 10 0 1))

(script-fu-menu-register 
	"script-fu-bumpy-logo"
	"<Image>/File/Create/Logos"
)

; FIN du script
