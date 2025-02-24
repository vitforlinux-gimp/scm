;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; The GIMP -- an image manipulation program
; Copyright (C) 1995 Spencer Kimball and Peter Mattis
; 
; Raindrop effect script  for GIMP 1.2
; Copyright (C) 2001 Iccii <iccii(@)hotmail.com>
; 
; --------------------------------------------------------------------
; version 0.1  by Iccii 2001/01/30(else 
;     - Initial relase
;       This is "FIXME" version, which is spaghetti program code
; version 0.2  by Iccii 2001/02/09
;     - Add to offset in highlight option
; version 0.2a by Iccii 2001/02/23
;     - Sorry, I had some mistakes, now fixed
; version 0.2b by Iccii 2001/02/24
;     - Highlight offset is set by persent instead of pixel
; version 0.3  by Iccii 2001/03/27
;     - Add the reflect-width setting
;     - Use Pattern as background
;     - Clean up code and more proofing
; version 0.3a by Iccii 2001/03/30
;     - Make better (speed up)
; version 0.3b by Iccii 2001/04/02
;     - Make better (cleanup code)
; version 0.3c by Iccii 2001/04/10
;     - Fix the layer mask problem (Thanks, Kajiyama)
; version 0.3d by Iccii 2001/05/25
;     - A bit better
; version 0.3e by Iccii 2001/06/21
;     - Minor fix
; version 0.3f by Iccii 2001/07/01
;     - bug fix (if image size doesn't equal to drawable size in alpha-logo)
; version 299 for gimp 2.10 and 2.99.19 - AUG 2024 - vitforlinux
; version 300 for gimp 2.10 and 3.0 rc1 - DIC 2024 - vitforlinux
; --------------------------------------------------------------------
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.  
; 
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))
  
  (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

	; 水玉(水滴)のような効果
(define (apply-raindrop-300-logo-effect20
		img				; IMAGE
		logo-layer		; DRAWABLE (レイヤー)
		text-color		; 水玉の色
		light			; 光の方向 (0-360度)
		blur			; シャドゥ、ハイライトのぼかし半径
		hi-width		; ハイライト幅 (%)
		hi-offset		; ハイライトのオフセット (%)
		hi-option		; ハイライト作成法オプション
		sh-offset		; シャドゥのオフセット
		reflect-width	; 表面反射のバンド幅
		antialias		; アンチエイリアスの有効/無効
)

 (let* (
        (layer-color 0)			;2.4追加
        (mask-color 0)			;2.4追加
        (logo-selection 0)		;2.4追加
        ;(old-bg 0)			;2.4追加
        (logo-layer-blur 0)		;2.4追加
        (hilight-width 0)		;2.4追加
        (hi-xoffset 0)			;2.4追加
        (hi-yoffset 0)			;2.4追加
        (mask-hilight2 0)		;2.4追加
        )

	; 前処理
	(set! layer-color (car (gimp-layer-copy logo-layer TRUE)))
	(gimp-image-insert-layer img layer-color 0 -1)
	(gimp-item-set-name layer-color "Color adjust")
	(set! mask-color (car (gimp-layer-create-mask layer-color 5)))
	(gimp-layer-add-mask layer-color mask-color)
	(gimp-layer-set-lock-alpha logo-layer FALSE)
	(gimp-image-select-item img 2  logo-layer)
	(gimp-selection-grow img reflect-width)
	(gimp-drawable-edit-fill logo-layer FILL-WHITE)
	(if (eqv? antialias TRUE)
	    (gimp-selection-feather img (/ blur 5)))
	(set! logo-selection (car (gimp-selection-save img)))
	(gimp-selection-invert img)
	;(set! old-bg (car (gimp-context-get-background)))
	(gimp-context-set-background '(0 0 0))
	(gimp-drawable-edit-fill logo-layer FILL-BACKGROUND)
	;(gimp-context-set-background old-bg)
	(gimp-selection-none img)
	(set! logo-layer-blur (car (gimp-layer-copy logo-layer TRUE)))
	(gimp-image-insert-layer img logo-layer-blur 0 -1)
	(apply-gauss2 img logo-layer-blur blur blur)

	; 処理の本体部分
 (let* (;(old-fg (car (gimp-context-get-foreground)))
		;(old-bg (car (gimp-context-get-background)))
		(radians (/ (* 2 *pi* light) 360))
		(sh-xoffset (* sh-offset (cos radians)))
		(sh-yoffset (* sh-offset (sin radians)))
		(layer-value        (car (gimp-layer-copy logo-layer TRUE)))
		(layer-hilight      (car (gimp-layer-copy logo-layer TRUE)))
		(layer-hilight-inn  (car (gimp-layer-copy logo-layer-blur TRUE)))
		(layer-shadow       (car (gimp-layer-copy logo-layer-blur TRUE)))
		(layer-shadow-inn   (car (gimp-layer-copy logo-layer-blur TRUE)))
		(mask-hilight       (car (gimp-layer-create-mask layer-hilight 5)))
		(mask-hilight-inn   (car (gimp-layer-create-mask layer-hilight-inn ADD-MASK-BLACK)))
		(mask-shadow        (car (gimp-layer-create-mask layer-shadow ADD-MASK-BLACK)))
		(mask-shadow-inn    (car (gimp-layer-create-mask layer-shadow-inn ADD-MASK-BLACK))))

	; 各レイヤーの準備
	(gimp-item-set-name layer-value       "Value layer")
	(gimp-item-set-name layer-hilight     "Highlight layer")
	(gimp-item-set-name layer-hilight-inn "Highlight inner")
	(gimp-item-set-name layer-shadow      "Drop shadow")
	(gimp-item-set-name layer-shadow-inn  "Inner shadow")

	(gimp-image-insert-layer img layer-shadow-inn 0 -1)
	(gimp-image-insert-layer img layer-shadow 0 -1)
	(gimp-image-insert-layer img layer-hilight-inn 0 -1)
	(gimp-image-insert-layer img layer-hilight 0 -1)
	(gimp-image-insert-layer img layer-value 0 -1)

	; レイヤーマスクを追加する
	(gimp-layer-add-mask layer-hilight mask-hilight)
	(gimp-layer-add-mask layer-hilight-inn mask-hilight-inn)
	(gimp-layer-add-mask layer-shadow mask-shadow)
	(gimp-layer-add-mask layer-shadow-inn mask-shadow-inn)
	(gimp-image-select-item img 2 logo-selection)
	(gimp-drawable-edit-fill mask-hilight-inn FILL-WHITE)
	(gimp-drawable-edit-fill mask-shadow FILL-WHITE)
	(gimp-drawable-edit-fill mask-shadow-inn FILL-WHITE)
	(gimp-selection-none img)


	; 色反転、色付け、レイヤーモードの変更、ずらしを行う
	(gimp-drawable-invert layer-hilight-inn TRUE)
	(gimp-drawable-invert mask-shadow TRUE)
	(gimp-context-set-foreground text-color)
	(gimp-drawable-fill layer-color FILL-FOREGROUND)
	(gimp-layer-set-mode layer-value LAYER-MODE-ADDITION-LEGACY)
	(gimp-layer-set-mode layer-hilight LAYER-MODE-SCREEN-LEGACY)
	(gimp-layer-set-mode layer-hilight-inn LAYER-MODE-SCREEN-LEGACY)
	(gimp-layer-set-mode layer-shadow LAYER-MODE-SUBTRACT-LEGACY)
	(gimp-layer-set-mode layer-shadow-inn LAYER-MODE-MULTIPLY-LEGACY)
	(gimp-layer-set-mode layer-color LAYER-MODE-NORMAL-LEGACY)
	(cond ((not (defined? 'OFFSET-COLOR))
	(gimp-drawable-offset layer-hilight-inn FALSE OFFSET-BACKGROUND (- sh-xoffset) (- sh-yoffset))
	(gimp-drawable-offset layer-shadow      FALSE OFFSET-TRANSPARENT sh-xoffset sh-yoffset)
	(gimp-drawable-offset layer-shadow-inn  FALSE OFFSET-BACKGROUND sh-xoffset sh-yoffset))
	(else
	(gimp-drawable-offset layer-hilight-inn FALSE OFFSET-COLOR (car(gimp-context-get-background)) (- sh-xoffset) (- sh-yoffset))
	(gimp-drawable-offset layer-shadow      FALSE OFFSET-TRANSPARENT (car(gimp-context-get-background)) sh-xoffset sh-yoffset)
	(gimp-drawable-offset layer-shadow-inn  FALSE OFFSET-COLOR (car(gimp-context-get-background)) sh-xoffset sh-yoffset)
	))

	; ハイライトレイヤーの処理
	(gimp-image-select-item img 2 mask-hilight)
	(gimp-selection-sharpen img)
	(set! hilight-width 0)
	(while (eqv? (car (gimp-selection-is-empty img)) FALSE)
	(gimp-selection-shrink img 1)
	(set! hilight-width (+ hilight-width 1)))
	(gimp-selection-none img)
	(set! hi-xoffset (- (/ (* (* hi-offset (cos radians)) hilight-width) 100)))
	(set! hi-yoffset (- (/ (* (* hi-offset (sin radians)) hilight-width) 100)))
		(cond ( (not (defined? 'OFFSET-COLOR))
	(gimp-drawable-offset layer-hilight FALSE OFFSET-BACKGROUND hi-xoffset hi-yoffset)
	(gimp-drawable-offset mask-hilight  FALSE OFFSET-BACKGROUND hi-xoffset hi-yoffset))
	(else
	(gimp-drawable-offset layer-hilight FALSE OFFSET-COLOR (car(gimp-context-get-background)) hi-xoffset hi-yoffset)
	(gimp-drawable-offset mask-hilight  FALSE OFFSET-COLOR (car(gimp-context-get-background)) hi-xoffset hi-yoffset)
	))
	(cond
	  ((eqv? hi-option 0)	; 縮めるとき
	    (begin
	  (gimp-image-select-item img 2 mask-hilight)
	  (gimp-selection-invert img)
	  (gimp-selection-grow img (/ (* hilight-width (- 100 hi-width)) 100))
	  (gimp-context-set-foreground '(0 0 0))
	  (gimp-drawable-edit-fill layer-hilight FILL-FOREGROUND)
	  (gimp-selection-none img)
	  (apply-gauss2 img layer-hilight (* 0.8 blur) (* 0.8 blur))
	  (gimp-layer-remove-mask layer-hilight MASK-APPLY)))
	  ((eqv? hi-option 1)	; オフセットのとき...さらなる改良が必要
        (begin
		(cond ((not (defined? 'OFFSET-COLOR))
	  (gimp-drawable-offset layer-hilight FALSE OFFSET-BACKGROUND
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (- (cos radians)))
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (- (sin radians))))
	  (gimp-drawable-offset mask-hilight FALSE OFFSET-BACKGROUND
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (cos radians))
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (sin radians))))
		  (else
	  (gimp-drawable-offset layer-hilight FALSE OFFSET-COLOR (car(gimp-context-get-background))
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (- (cos radians)))
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (- (sin radians))))
	  (gimp-drawable-offset mask-hilight FALSE OFFSET-COLOR (car(gimp-context-get-background))
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (cos radians))
		  (* (/ (* hilight-width (- 100 hi-width)) 100) (sin radians)))
))
	  (gimp-layer-remove-mask layer-hilight MASK-APPLY)
	  (apply-gauss2 1 img layer-hilight (* 0.8 blur) (* 0.8 blur)))))
	  (set! mask-hilight2 (car (gimp-layer-create-mask logo-layer ADD-MASK-BLACK)))
	  (gimp-layer-add-mask layer-hilight mask-hilight2)
	  (gimp-image-select-item img 2 logo-selection)
	  (gimp-drawable-edit-fill mask-hilight2 FILL-WHITE)
	  (gimp-selection-none img)


	; 最後の調整
	(gimp-selection-none img)
	(gimp-layer-set-opacity layer-value 15)
	(gimp-layer-set-opacity layer-hilight 90)
	(gimp-layer-set-opacity layer-hilight-inn 90)
	(gimp-layer-set-opacity layer-shadow 80)
	(gimp-layer-set-opacity layer-shadow-inn 80)

	; 終わり
	(gimp-image-remove-layer img logo-layer)
	(gimp-image-remove-layer img logo-layer-blur)
	(gimp-image-remove-channel img logo-selection)
	;(gimp-image-set-active-layer img layer-value)
	(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers img (vector layer-value)))
(else (gimp-image-set-active-layer img layer-value))
)
	;(gimp-context-set-background old-bg)
	;(gimp-context-set-foreground old-fg)
)			;2.4追加
))


	; 透明度をロゴに
(define (script-fu-raindrop-300-logo-alpha
		img
		text-layer
		text-color
		light
		blur
		hi-width
		hi-offset
		hi-option
		sh-offset
		reflect-width
		antialias)

 (let* ((width  (car (gimp-drawable-get-width  text-layer)))
		(height (car (gimp-drawable-get-height text-layer)))
		(bg-layer (car (gimp-layer-new-ng img (+ width (* 4 sh-offset)) (+ height (* 4 sh-offset)) RGBA-IMAGE "BG layer" 100 LAYER-MODE-NORMAL-LEGACY))))
		(gimp-image-undo-group-start img)
		(gimp-context-push)
		(gimp-context-set-paint-mode 0)
		(gimp-image-resize img (+ width (* 4 sh-offset)) (+ height (* 4 sh-offset)) (* sh-offset 2) (* sh-offset 2))	;changed
		(gimp-layer-resize text-layer (+ width (* 4 sh-offset)) (+ height (* 4 sh-offset)) (* sh-offset 2) (* sh-offset 2))	;add
		(if (< 0 (car (gimp-layer-get-mask text-layer)))
		  (begin
		  (gimp-layer-remove-mask text-layer MASK-APPLY)
		  (gimp-displays-flush)	))	; why I need this call?
		(gimp-layer-set-lock-alpha text-layer TRUE)
		(gimp-selection-none img)
		(gimp-drawable-edit-fill text-layer 2)
		(apply-raindrop-300-logo-effect20 img text-layer
		 text-color light blur hi-width hi-offset hi-option sh-offset reflect-width antialias)
		 (gimp-context-pop)
		(gimp-image-undo-group-end img)
		(gimp-displays-flush)))

(script-fu-register
	"script-fu-raindrop-300-logo-alpha"
	_"Rain drop 300 ALPHA..."
	"Creates a logo like a raindrop"
	"Iccii <iccii(@)hotmail.com>"
	"Iccii"
	"Mar, 2001"
	"RGBA"
    SF-IMAGE			"Image"			0
	SF-DRAWABLE		"Drawable"		0
	SF-COLOR		_"Base Color"		'(0 63 255)
	SF-ADJUSTMENT		"lighting angle"	'(45 0 360 1 10 0 0)
	SF-ADJUSTMENT		"blur radius"		'(10 1 50 1 5 0 0)
	SF-ADJUSTMENT		"higlight width (%)"	'(30 0 100 1 5 0 0)
	SF-ADJUSTMENT		"higlight offset (%)"	'(40 0 100 1 5 0 0)
	SF-OPTION		"higlight option"	'(_"shrink" _"staggering")
	SF-ADJUSTMENT		"shadow offset"		'(5 0 50 1 5 0 1)
	SF-ADJUSTMENT		_"reflections width"	'(5 0 50 1 5 0 1)
	SF-TOGGLE		_"antialias"		TRUE)
(script-fu-menu-register "script-fu-raindrop-300-logo-alpha"
                         "<Image>/Script-Fu/Alpha-to-Logo")


	; ロゴ作成
(define (script-fu-raindrop-300-logo
		text
		font-size
		fontname
		justify
		text-color
		pattern
		light
		blur
		hi-width
		hi-offset
		hi-option
		sh-offset
		reflect-width
		antialias)

 (let* ((img (car (gimp-image-new 256 256 RGB)))
		(text-layer (car (gimp-text-fontname img -1 0 0
						  text (+ 20 reflect-width) TRUE font-size PIXELS fontname)))
		(width  (car (gimp-drawable-get-width  text-layer)))
		(height (car (gimp-drawable-get-height text-layer)))
		(bg-layer (car (gimp-layer-new-ng img (+ width sh-offset) (+ height sh-offset) RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
		;(old-pattern (car (gimp-context-get-pattern)))
			(justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
				((= justify 2) 1)))
		)

	(gimp-image-undo-disable img)
	(gimp-context-push)
	(gimp-context-set-paint-mode 0)
	    (gimp-text-layer-set-justification text-layer justify)

	(gimp-image-resize img (+ width sh-offset) (+ height sh-offset) 0 0)		;changed
	(gimp-layer-resize text-layer (+ width sh-offset) (+ height sh-offset) 0 0)	;add
	(gimp-layer-set-lock-alpha text-layer TRUE)
	(gimp-drawable-edit-fill text-layer FILL-WHITE)
	(gimp-image-insert-layer img bg-layer 0 -1)
	(gimp-selection-all img)
	(gimp-context-set-pattern pattern)
(gimp-drawable-edit-fill bg-layer FILL-PATTERN)
(gimp-selection-none img)
	(apply-raindrop-300-logo-effect20 img text-layer
	 text-color light blur hi-width hi-offset hi-option sh-offset reflect-width antialias)
	;(gimp-context-set-pattern old-pattern)
	(gimp-context-pop)
	(gimp-image-undo-enable img)
	(gimp-display-new img)
	(gimp-displays-flush)))

(script-fu-register
	"script-fu-raindrop-300-logo"
	_"Rain drop 300 TEXT..."
	"Create a raindrop like logo"
	"Iccii <iccii(@)hotmail.com>"
	"Iccii"
	"Jun, 2001"
	""
	SF-TEXT		_"Text"			"Rain Drop"
	SF-ADJUSTMENT		_"Font size (px)"	'(150 2 1000 1 10 0 1)
	SF-FONT			_"Font"			"QTSlogantype"
	SF-OPTION "Justify" '("Centered" "Left" "Right") 
	SF-COLOR		_"Font Color"		'(0 127 255)
	SF-PATTERN		_"Background Pattern"		"Pine?"
	SF-ADJUSTMENT	_"Lighting angle"		'(45 0 360 1 10 0 0)
	SF-ADJUSTMENT	_"Blur radius"			'(10 1 50 1 5 0 0)
	SF-ADJUSTMENT	_"Higlight width (%)"		'(30 0 100 1 5 0 0)
	SF-ADJUSTMENT	_"Higlight offset (%)"		'(40 0 100 1 5 0 0)
	SF-OPTION	"Higlight option"		'(_"reduction" _"displace")
	SF-ADJUSTMENT	_"Shadow offset"		'(5 0 50 1 5 0 1)
	SF-ADJUSTMENT	_"Reflections width"		'(5 0 50 1 5 0 1)
	SF-TOGGLE	_"Antialias"			 TRUE)

(script-fu-menu-register "script-fu-raindrop-300-logo"
                         "<Image>/File/Create/Logos")
