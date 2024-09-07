;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; glossy-patterned-shadowed-and-bump-mapped-logo
; creates anything you can create with it :)
; (use it wisely, use it in peace...)
;
; GIMP - The GNU Image Manipulation Program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
;
; glossy gives a glossy outlook to your fonts (unlogical name, isn't it?)
; Copyright (C) 1998 Hrvoje Horvat
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))


(define (apply-glossy-logo-effect img
                                  logo-layer
                                  blend-gradient-text
                                  blend-gradient-text-reverse
                                  blend-gradient-outline
                                  blend-gradient-outline-reverse
                                  grow-size
                                  bg-color
                                  use-pattern-text
                                  pattern-text
                                  use-pattern-outline
                                  pattern-outline
                                  use-pattern-overlay
                                  pattern-overlay
                                  noninteractive
                                  shadow-toggle
                                  s-offset-x
                                  s-offset-y)
  (let* (
        (width (car (gimp-drawable-get-width logo-layer)))
        (height (car (gimp-drawable-get-height logo-layer)))
        (posx (- (car (gimp-drawable-get-offsets logo-layer))))
        (posy (- (cadr (gimp-drawable-get-offsets logo-layer))))
        (bg-layer (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
        (grow-me (car (gimp-layer-copy logo-layer TRUE)))
        (dont-drop-me 0)
        )

    (gimp-context-push)
    	(gimp-context-set-paint-mode 0)
    (gimp-context-set-defaults)

    (script-fu-util-image-resize-from-layer img logo-layer)
    (script-fu-util-image-add-layers img grow-me bg-layer)
    (gimp-item-set-name grow-me "Grow-me")
    (gimp-item-transform-translate grow-me posx posy)

    (gimp-context-set-background bg-color)
    (gimp-selection-all img)
    ;(gimp-drawable-edit-bucket-fill bg-layer FILL-BACKGROUND  100 0 )
    (gimp-drawable-edit-fill bg-layer FILL-BACKGROUND)	

    (gimp-selection-none img)

    (gimp-image-select-item img CHANNEL-OP-REPLACE logo-layer)

; if we are going to use transparent gradients for text, we will (maybe) need to uncomment this
; this clears black letters first so you don't end up with black where the transparent should be
;    (gimp-drawable-edit-clear img logo-layer)

    (if (= use-pattern-text TRUE)
      (begin
        (gimp-context-set-pattern pattern-text)
       ; (gimp-drawable-edit-bucket-fill logo-layer BUCKET-FILL-PATTERN  100 0 )
           (gimp-drawable-edit-fill logo-layer FILL-PATTERN)
      )
    )

    (if (= use-pattern-text FALSE)
      (begin
        (gimp-context-set-gradient blend-gradient-text)

       ; (gimp-edit-blend logo-layer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 REPEAT-NONE blend-gradient-text-reverse FALSE 0 0 TRUE 0 0 0 (+ height 5))
			(gimp-context-set-gradient-reverse blend-gradient-text-reverse)
		      (gimp-drawable-edit-gradient-fill logo-layer GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (+ height 5)) ; Fill with gradient

      )
    )

    (gimp-selection-none img)

    (gimp-image-select-item img CHANNEL-OP-REPLACE grow-me)
    (gimp-selection-grow img (- grow-size 2))
    (gimp-selection-feather img 2)

; if we are going to use transparent gradients for outline, we will (maybe) need to uncomment this
; I didn't put it in the options because there are already enough settings there and anyway, transparent
; gradients will be used very rarely (if ever)
;    (gimp-drawable-edit-clear img grow-me)

    (if (= use-pattern-outline TRUE)
      (begin
        (gimp-context-set-pattern pattern-outline)
        ;(gimp-drawable-edit-bucket-fill grow-me BUCKET-FILL-PATTERN  100 0 )
           	(gimp-drawable-edit-fill grow-me FILL-PATTERN)

      )
    )

    (if (= use-pattern-outline FALSE)
      (begin
        (gimp-context-set-gradient blend-gradient-outline)

        ;(gimp-edit-blend grow-me BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 0 REPEAT-NONE blend-gradient-outline-reverse FALSE 0 0 TRUE 0 0 0 (+ height 5))
				(gimp-context-set-gradient-reverse blend-gradient-outline-reverse)
		      (gimp-drawable-edit-gradient-fill grow-me GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (+ height 5)) ; Fill with gradient
      )
    )

    (gimp-selection-none img)

    (plug-in-bump-map (if (= noninteractive TRUE)
        RUN-NONINTERACTIVE
        RUN-INTERACTIVE)
          img grow-me logo-layer
                      110.0 45.0 3 0 0 0 0 TRUE FALSE 0)
    (gimp-layer-set-mode logo-layer LAYER-MODE-SCREEN-LEGACY)

    (if (= use-pattern-overlay TRUE)
      (begin
        (gimp-image-select-item img CHANNEL-OP-REPLACE grow-me)
        (gimp-context-set-pattern pattern-overlay)
       ; (gimp-drawable-edit-bucket-fill grow-me BUCKET-FILL-PATTERN LAYER-MODE-OVERLAY-LEGACY 100 0 )
                  	(gimp-drawable-edit-fill grow-me FILL-PATTERN)
        (gimp-selection-none img)
      )
    )

    (if (= shadow-toggle TRUE)
      (begin
        (gimp-image-select-item img CHANNEL-OP-REPLACE logo-layer)
        (set! dont-drop-me (car (script-fu-drop-shadow img logo-layer
                                                       s-offset-x s-offset-y
                                                       15 '(0 0 0) 80 TRUE)))
        (set! width (car (gimp-image-get-width img)))
        (set! height (car (gimp-image-get-height img)))
        (gimp-selection-none img)
      )
    )

    (gimp-context-pop)
  )
)


(define (script-fu-glossy-logo-alpha img
                                     logo-layer
                                     blend-gradient-text
                                     blend-gradient-text-reverse
                                     blend-gradient-outline
                                     blend-gradient-outline-reverse
                                     grow-size
                                     bg-color
                                     use-pattern-text
                                     pattern-text
                                     use-pattern-outline
                                     pattern-outline
                                     use-pattern-overlay
                                     pattern-overlay
                                     noninteractive
                                     shadow-toggle
                                     s-offset-x
                                     s-offset-y)
  (begin
    (gimp-image-undo-group-start img)
    	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (apply-glossy-logo-effect img logo-layer
                              blend-gradient-text
                              blend-gradient-text-reverse
                              blend-gradient-outline
                              blend-gradient-outline-reverse
                              grow-size bg-color
                              use-pattern-text pattern-text
                              use-pattern-outline pattern-outline
                              use-pattern-overlay pattern-overlay
                              noninteractive shadow-toggle
                              s-offset-x s-offset-y)
			          	(gimp-context-pop)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
  )
)


(script-fu-register "script-fu-glossy-logo-alpha"
  _"Glo_ssy ALPHA..."
  _"Add gradients, patterns, shadows, and bump maps to the selected region (or alpha)"
  "Hrvoje Horvat (hhorvat@open.hr)"
  "Hrvoje Horvat"
  "14/04/1998"
  "RGBA"
  SF-IMAGE      "Image"                     0
  SF-DRAWABLE   "Drawable"                  0
  SF-GRADIENT   _"Blend gradient (text) Shadows 2"    "Shadows 2"
  SF-TOGGLE     _"Text gradient reverse"    FALSE
  SF-GRADIENT   _"Blend gradient (outline) Shadows 2" "Shadows 2"
  SF-TOGGLE     _"Outline gradient reverse" FALSE
  SF-ADJUSTMENT _"Outline size"             '(5 2 250 1 10 0 0)
  SF-COLOR      _"Background color"         "white"
  SF-TOGGLE     _"Use pattern for text instead of gradient" FALSE
  SF-PATTERN    _"Pattern (text) Electric Blue"           "Electric Blue"
  SF-TOGGLE     _"Use pattern for outline instead of gradient" FALSE
  SF-PATTERN    _"Pattern (outline) Electric Blue"        "Electric Blue"
  SF-TOGGLE     _"Use pattern overlay"      FALSE
  SF-PATTERN    _"Pattern (overlay) Parque #1"        "Parque #1"
  SF-TOGGLE     _"Default bumpmap settings" TRUE
  SF-TOGGLE     _"Shadow"                   TRUE
  SF-ADJUSTMENT _"Shadow X offset"          '(8 0 100 1 10 0 0)
  SF-ADJUSTMENT _"Shadow Y offset"          '(8 0 100 1 10 0 0)
)

(script-fu-menu-register "script-fu-glossy-logo-alpha"
                         "<Image>/Filters/Alpha to Logo")


(define (script-fu-glossy-logo text
                               size
                               font
			       justification
			       letter-spacing
		               line-spacing
                               blend-gradient-text
                               blend-gradient-text-reverse
                               blend-gradient-outline
                               blend-gradient-outline-reverse
                               grow-size
                               bg-color
                               use-pattern-text
                               pattern-text
                               use-pattern-outline
                               pattern-outline
                               use-pattern-overlay
                               pattern-overlay
                               noninteractive
                               shadow-toggle
                               s-offset-x
                               s-offset-y)
  (let* (
        (img (car (gimp-image-new 256 256 RGB)))
        (text-layer (car (gimp-text-fontname img -1 0 0 text 30 TRUE size PIXELS font)))
		  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
        )
    	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
    (gimp-image-undo-disable img)
    	(gimp-text-layer-set-justification text-layer justification) ; Text Justification (Rev Value)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
	(gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing
    (apply-glossy-logo-effect img text-layer
                              blend-gradient-text
                              blend-gradient-text-reverse
                              blend-gradient-outline
                              blend-gradient-outline-reverse
                              grow-size bg-color
                              use-pattern-text pattern-text
                              use-pattern-outline pattern-outline
                              use-pattern-overlay pattern-overlay
                              noninteractive shadow-toggle
                              s-offset-x s-offset-y)
			      	(gimp-context-pop)
    (gimp-image-undo-enable img)
    (gimp-display-new img)
  )
)

(script-fu-register "script-fu-glossy-logo"
  _"Glo_ssy..."
  _"Create a logo with gradients, patterns, shadows, and bump maps"
  "Hrvoje Horvat (hhorvat@open.hr)"
  "Hrvoje Horvat"
  "14/04/1998"
  ""
  SF-TEXT     _"Text"                     "Glossy"
  SF-ADJUSTMENT _"Font size (pixels)"       '(100 2 1000 1 10 0 1)
  SF-FONT       _"Font"                     "Eras"
  SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill")
  SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
  SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)  
  SF-GRADIENT   _"Blend gradient (text) Shadows 2"    "Shadows 2"
  SF-TOGGLE     _"Text gradient reverse"    FALSE
  SF-GRADIENT   _"Blend gradient (outline) Shadows 2" "Shadows 2"
  SF-TOGGLE     _"Outline gradient reverse" FALSE
  SF-ADJUSTMENT _"Outline size"             '(5 2 250 1 10 0 0)
  SF-COLOR      _"Background color"         "white"
  SF-TOGGLE     _"Use pattern for text instead of gradient" FALSE
  SF-PATTERN    _"Pattern (text) Electric Blue"           "Electric Blue"
  SF-TOGGLE     _"Use pattern for outline instead of gradient" FALSE
  SF-PATTERN    _"Pattern (outline) Electric Blue"        "Electric Blue"
  SF-TOGGLE     _"Use pattern overlay"      FALSE
  SF-PATTERN    _"Pattern (overlay) Parque #1"        "Parque #1"
  SF-TOGGLE     _"Default bumpmap settings" TRUE
  SF-TOGGLE     _"Shadow"                   TRUE
  SF-ADJUSTMENT _"Shadow X offset"          '(8 0 100 1 10 0 0)
  SF-ADJUSTMENT _"Shadow Y offset"          '(8 0 100 1 10 0 0)
)

(script-fu-menu-register "script-fu-glossy-logo"
                         "<Image>/File/Create/Logos")
