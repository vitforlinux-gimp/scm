;;mhbevel3d
;Kiki
;http://kikidide.yuki-mura.net/GIMP/gimp.htm
;http://kikidide.yuki-mura.net/GIMP/engimp.htm
;

(define (script-fu-mhbevel3d text size font 3d md foption tcolor text-gradient pat
	 bg-md bg-color bggrad bgpat stp bmpblr bmpmp ck? white?)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
;;文字
	 (text-layer (car (gimp-text-fontname img -1 0 0 text (+ (/ size 12) 4) TRUE size PIXELS font)))
;;幅と高さ
	 (width (car (gimp-drawable-width text-layer)))
	 (height (car (gimp-drawable-height text-layer)))

         (old-fg (car (gimp-palette-get-foreground)))
         (old-grad (car (gimp-gradients-get-gradient)))
         (old-pat (car (gimp-patterns-get-pattern)))
)
    (gimp-image-undo-disable img)

;;サイズ調整
    (if (= md 0) (gimp-image-resize img (+ width (* 3d stp)) (+ height (* 3d stp)) (* 3d stp) (* 3d stp)))	;rb-slant
    (if (= md 1) (gimp-image-resize img width (+ height (* (* 3d stp) 2)) 0 (* (* 3d stp) 2)))		;b-vertical
    (if (= md 2) (gimp-image-resize img (+ width (* 3d stp)) (+ height (* 3d stp)) 0 (* 3d stp)))	;lb-slant
    (if (= md 3) (gimp-image-resize img (+ width (* (* 3d stp) 2)) height 0 0))				;l-horizontal
    (if (= md 4) (gimp-image-resize img (+ width (* 3d stp)) (+ height (* 3d stp)) 0 0))		;lt-slant
    (if (= md 5) (gimp-image-resize img width (+ height (* (* 3d stp) 2)) 0 0))				;t-vertical
    (if (= md 6) (gimp-image-resize img (+ width (* 3d stp)) (+ height (* 3d stp)) (* 3d stp) 0))	;rt-slant
    (if (= md 7) (gimp-image-resize img (+ width (* (* 3d stp) 2)) height (* (* 3d stp) 2) 0))		;r-horizontal

;これがなければバンプマップが正しく適用されない
    (if (= md 0) (gimp-layer-resize text-layer (+ width (* 3d stp)) (+ height (* 3d stp)) (* 3d stp) (* 3d stp)))	;rb-slant
    (if (= md 1) (gimp-layer-resize text-layer width (+ height (* (* 3d stp) 2)) 0 (* (* 3d stp) 2)))		;b-vertical
    (if (= md 2) (gimp-layer-resize text-layer (+ width (* 3d stp)) (+ height (* 3d stp)) 0 (* 3d stp)))	;lb-slant
    (if (= md 3) (gimp-layer-resize text-layer (+ width (* (* 3d stp) 2)) height 0 0))				;l-horizontal
    (if (= md 4) (gimp-layer-resize text-layer (+ width (* 3d stp)) (+ height (* 3d stp)) 0 0))			;lt-slant
    (if (= md 5) (gimp-layer-resize text-layer width (+ height (* (* 3d stp) 2)) 0 0))				;t-vertical
    (if (= md 6) (gimp-layer-resize text-layer (+ width (* 3d stp)) (+ height (* 3d stp)) (* 3d stp) 0))	;rt-slant
    (if (= md 7) (gimp-layer-resize text-layer (+ width (* (* 3d stp) 2)) height (* (* 3d stp) 2) 0))		;r-horizontal

;前景色の設定
  (gimp-palette-set-foreground tcolor)
  (gimp-layer-set-preserve-trans text-layer TRUE)
  (gimp-edit-fill text-layer FOREGROUND-FILL)
  (cond((= foption 1)
    (gimp-gradients-set-gradient text-gradient)
    (gimp-layer-set-preserve-trans text-layer TRUE)
;    (if (= 0 gradmd) (gimp-edit-blend text-layer CUSTOM-MODE NORMAL-MODE 0 100 20 1 FALSE FALSE 0 0 FALSE 0 0 width height))
;    (if (= 1 gradmd) (gimp-edit-blend text-layer CUSTOM-MODE NORMAL-MODE 0 100 20 1 FALSE FALSE 0 0 FALSE 0 0 width 0))
;    (if (= 2 gradmd) (gimp-edit-blend text-layer CUSTOM-MODE NORMAL-MODE 0 100 20 1 FALSE FALSE 0 0 FALSE 0 0 0 height))
     (gimp-edit-blend text-layer CUSTOM-MODE NORMAL-MODE 0 100 20 1 FALSE FALSE 0 0 FALSE 0 0 width height))
    ((= foption 2)
       (gimp-selection-layer-alpha text-layer)
       (gimp-patterns-set-pattern pat)
       (gimp-edit-bucket-fill text-layer PATTERN-BUCKET-FILL NORMAL-MODE 100 255 FALSE 0 0)
       (gimp-selection-none img)
       ))

    (script-fu-mhbevel3dimg img text-layer TRUE 3d md bg-md bg-color bggrad bgpat stp bmpblr bmpmp ck? white? TRUE)

    (gimp-palette-set-foreground old-fg)
    (gimp-gradients-set-gradient old-grad)
    (gimp-patterns-set-pattern old-pat)

    (gimp-image-undo-enable img)
    (gimp-display-new img)
))

(script-fu-register "script-fu-mhbevel3d"
		    "<Toolbox>/Xtns/Script-Fu/MH/bevel3d"
		    "mhbevel2"
		    "Kiki"
		    "Kiki"
		    "2012/1"
		    ""
		    SF-TEXT     "Text String"        "3D Bevel"
		    SF-ADJUSTMENT "Font Size (pixels)" '(120 2 1000 1 10 0 1)
		    SF-FONT       "Font"               "Pump Demi Bold LET"
		    SF-ADJUSTMENT "3D"			'(10 1 600 1 2 0 1)
                    SF-OPTION     "logo-direction"            '(_"right-bottom" _"vertical-bottom" _"left-bottom" _"left-horizontal" _"left-top" _"vertical-top" _"right-top" _"right-horizontal")
                    SF-OPTION     "fg-mode"            '(_"color" _"gradient" _"pattern")
		    SF-COLOR      "Color"              '(222 200 156)
                    SF-GRADIENT   "Gradient"           "Pastel Rainbow"
                    SF-PATTERN    "Pattern"            "Dried mud"
                    SF-OPTION     "bg-mode"            '(_"color" _"gradient" _"pattern")
		    SF-COLOR      "Background Color"   '(243 255 222)
                    SF-GRADIENT   "Background Gradient" "Greens"
                    SF-PATTERN    "Background Pattern"  "Fibers"
		    SF-ADJUSTMENT  "step"  		'(1 1 5 1 2 0 1)
		    SF-ADJUSTMENT  "bumpmap blur"  	'(5 1 70 1 2 0 1)
		    SF-ADJUSTMENT  "bumpmap depth"  	'(3 1 65 1 2 0 1)
                    SF-TOGGLE     "sp?"  		FALSE
                    SF-TOGGLE     "white?"              FALSE
)

(define (script-fu-mhbevel3dimg img drawable resize? 3d md bg-md bg-color bggrad bgpat stp bmpblr bmpmp ck? white? bg?)
  (let* (

;;幅と高さ
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
;;背景
	 (bg-layer (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 NORMAL-MODE)))
	 (bump-layer (car (gimp-layer-new img width height RGB-IMAGE "Bump" 100 NORMAL-MODE)))
)
;2.4追加
  (let (
       (bcopy 0)
       (bump 0)
       (l1 0) (l2 0) (l21 0) (a 0) (b 0) (c 0) (d 0) (olda 0) (y 0)
       )

    (set! bcopy (car (gimp-layer-copy drawable 0)))
    (gimp-image-add-layer img bcopy 1)
    (gimp-image-add-layer img bump-layer 2)
    (gimp-palette-set-foreground '(0 0 0))
    (gimp-layer-set-preserve-trans bcopy TRUE)
    (gimp-edit-fill bcopy FOREGROUND-FILL)
    (gimp-palette-set-foreground '(255 255 255))
    (gimp-edit-fill bump-layer FOREGROUND-FILL)
    (set! bump (car (gimp-image-merge-down img bcopy 0)))
    (plug-in-gauss-iir2 1 img bump bmpblr bmpblr)

    (cond((= 0 md)
	(plug-in-bump-map 1 img drawable bump 135 45 bmpmp 0 0 0 0 TRUE TRUE 0)
	)
       ((= 1 md)
	(plug-in-bump-map 1 img drawable bump 135 45 bmpmp 0 0 0 0 TRUE TRUE 0)
	)
       ((= 2 md)
	(plug-in-bump-map 1 img drawable bump 45 45 bmpmp 0 0 0 0 TRUE TRUE 0)
	)
       ((= 3 md)
	(plug-in-bump-map 1 img drawable bump 45 45 bmpmp 0 0 0 0 TRUE TRUE 0)
	)
       ((= 4 md)
	(plug-in-bump-map 1 img drawable bump 225 45 bmpmp 0 0 0 0 TRUE TRUE 0)
	)
       ((= 5 md)
	(plug-in-bump-map 1 img drawable bump 225 45 bmpmp 0 0 0 0 TRUE TRUE 0)
	)
       ((= 6 md)
	(plug-in-bump-map 1 img drawable bump 225 45 bmpmp 0 0 0 0 TRUE TRUE 0)
	)
       ((= 7 md)
	(plug-in-bump-map 1 img drawable bump 135 45 bmpmp 0 0 0 0 TRUE TRUE 0)
	)
     )

    (gimp-image-remove-layer img bump)


    (cond((= 0 md)
	(set! a -1)
	(set! b 0)
	(set! c 0)
	(set! d -1)
	)
       ((= 1 md)
	(set! a 0)
	(set! b -1)
	(set! c 0)
	(set! d -1)
	)
       ((= 2 md)
	(set! a 1)
	(set! b 0)
	(set! c 0)
	(set! d -1)
	)
       ((= 3 md)
	(set! a 1)
	(set! b 0)
	(set! c 1)
	(set! d 0)
	)
       ((= 4 md)
	(set! a 1)
	(set! b 0)
	(set! c 0)
	(set! d 1)
	)
       ((= 5 md)
	(set! a 0)
	(set! b 1)
	(set! c 0)
	(set! d 1)
	)
       ((= 6 md)
	(set! a -1)
	(set! b 0)
	(set! c 0)
	(set! d 1)
	)
       ((= 7 md)
	(set! a -1)
	(set! b 0)
	(set! c -1)
	(set! d 0)
	)
     )


	(set! a (* a stp))
	(set! b (* b stp))
	(set! c (* c stp))
	(set! d (* d stp))
	(set! olda a)

    (set! y 0)
    (set! l2 (car (gimp-layer-copy drawable 0)))
    (while (< y 3d)
    (set! l1 (car (gimp-layer-copy l2 0)))     ;レイヤーのコピー作成
    (gimp-image-add-layer img l1 0)                  ;レイヤー追加
    (gimp-layer-translate l1 a b)                    ;ずらす
    (set! l2 (car (gimp-layer-copy l1 0)))
    (gimp-image-add-layer img l2 0)
    (gimp-layer-translate l2 c d)
    (set! y (+ y 1))

	(if (= ck? TRUE)
		(if (> y (/ 3d 2))
			(begin
			(if (= a olda) (set! a (- 0 a)))
			(cond((= 1 md)
			   (if (= 0 a)
			   (begin
				 (set! a 1)
				 (gimp-image-resize img (+ width (/ 3d 2)) height 0 0)
			    ))
			)
			((= 3 md)
			   (if (= 0 d)
			   (begin
				 (set! d 1)
				 (if (> stp 1) (set! width (+ 10 width)))
				 (gimp-image-resize img (- width (* 3d stp)) (+ height (/ 3d 2)) 0 0)
			    ))
			)
			((= 5 md)
			   (if (= 0 a)
			   (begin
				 (set! a 1)
				 (gimp-image-resize img (+ width (/ 3d 2)) height 0 0)
			    ))
			)
			((= 7 md)
			   (if (= 0 d)
			   (begin
				 (set! d 1)
				 (if (> stp 1) (set! width (+ 10 width)))
				 (if (= stp 1) (gimp-image-resize img (- width (* 3d stp)) (+ height (/ 3d 2)) (- 0 (* 3d stp)) 0))
				 (if (> stp 1) (gimp-image-resize img (- width (* 3d stp)) (+ height (/ 3d 2)) (+ (- 0 (* 3d stp)) 10) 0))
			    ))
			)
	)


			)
		)
	)

    )
    (set! l21 (car (gimp-layer-copy l2 0)))		;add
    (gimp-image-merge-visible-layers img 1)

    (gimp-image-add-layer img l21 0)		;add
;    (gimp-layer-translate l21 -1 -1)		;add
    (if (= TRUE white?)				;add
    (begin					;add
      (gimp-palette-set-foreground '(255 255 255))	;add
      (gimp-edit-fill l21 FOREGROUND-FILL)		;add
      (gimp-layer-set-opacity l21 50)		;add
    ))

;;背景色の決定
(if (= TRUE bg?)
(begin
    (gimp-palette-set-foreground bg-color)
    (gimp-image-add-layer img bg-layer 2)
    (gimp-layer-resize-to-image-size bg-layer)		;追加
    (gimp-drawable-fill bg-layer FOREGROUND-FILL)
    (cond((= bg-md 1)
       (gimp-gradients-set-gradient bggrad)
       (gimp-blend bg-layer CUSTOM-MODE NORMAL-MODE GRADIENT-LINEAR 100 20 REPEAT-NONE
                                            FALSE 0 0 0 0 0 0 width height))
       ((= bg-md 2)
       (gimp-selection-all img)
       (gimp-patterns-set-pattern bgpat)
       (gimp-edit-bucket-fill bg-layer PATTERN-BUCKET-FILL NORMAL-MODE 100 255 FALSE 0 0)
       (gimp-selection-none img)
       ))
))

;;;    (if (= TRUE fr?) (gimp-image-flatten img))

;2.4追加(let)
 )
))





;ここはTosi様のscript-fuを使用しました。
;http://www.geocities.jp/gimproject/scripts/layers-view-delete.html

(define (script-fu-layers-view-none image drawable)
 (let* ((layers (gimp-image-get-layers image))
	    (number-layers (car layers))
	    (layer-array (cadr layers))
	    (layer-count 0)
	    (layer))
    (set! layer-count 0)
    (while (< layer-count number-layers)
           (set! layer (aref layer-array layer-count))
           (gimp-drawable-set-visible layer FALSE)
           (set! layer-count (+ layer-count 1)))
))
(define (script-fu-layers-view-current-only image drawable)
    (script-fu-layers-view-none image drawable)
    (if (not (= 0 (car (gimp-drawable-is-layer drawable))))
        (gimp-drawable-set-visible drawable TRUE))
)


;こっちが本体
(define (script-fu-mhbevel3dimg22 img2 drawable2 resize? 3d md stp bmpblr bmpmp ck? white?)
  (let* (
	(img (car (gimp-channel-ops-duplicate img2)))
	(drawable (car (gimp-image-get-active-layer img)))

;;幅と高さ
	 (width (car (gimp-drawable-width drawable)))
	 (height (car (gimp-drawable-height drawable)))
;;背景
	 (bg-layer (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 NORMAL-MODE)))
	 (bump-layer (car (gimp-layer-new img width height RGB-IMAGE "Bump" 100 NORMAL-MODE)))

         (old-fg (car (gimp-palette-get-foreground)))
         (old-grad (car (gimp-gradients-get-gradient)))
         (old-pat (car (gimp-patterns-get-pattern)))
)
    (gimp-image-undo-disable img)

    (script-fu-layers-view-current-only img drawable)	;Tosi様のscript-fuより

;;サイズ調整
(if (= resize? TRUE)
(begin
    (if (= md 0) (gimp-image-resize img (+ width (* 3d stp)) (+ height (* 3d stp)) (* 3d stp) (* 3d stp)))	;rb-slant
    (if (= md 1) (gimp-image-resize img width (+ height (* (* 3d stp) 2)) 0 (* (* 3d stp) 2)))		;b-vertical
    (if (= md 2) (gimp-image-resize img (+ width (* 3d stp)) (+ height (* 3d stp)) 0 (* 3d stp)))	;lb-slant
    (if (= md 3) (gimp-image-resize img (+ width (* (* 3d stp) 2)) height 0 0))				;l-horizontal
    (if (= md 4) (gimp-image-resize img (+ width (* 3d stp)) (+ height (* 3d stp)) 0 0))		;lt-slant
    (if (= md 5) (gimp-image-resize img width (+ height (* (* 3d stp) 2)) 0 0))				;t-vertical
    (if (= md 6) (gimp-image-resize img (+ width (* 3d stp)) (+ height (* 3d stp)) (* 3d stp) 0))	;rt-slant
    (if (= md 7) (gimp-image-resize img (+ width (* (* 3d stp) 2)) height (* (* 3d stp) 2) 0))		;r-horizontal

;これがなければバンプマップが正しく適用されない
    (if (= md 0) (gimp-layer-resize drawable (+ width (* 3d stp)) (+ height (* 3d stp)) (* 3d stp) (* 3d stp)))	;rb-slant
    (if (= md 1) (gimp-layer-resize drawable width (+ height (* (* 3d stp) 2)) 0 (* (* 3d stp) 2)))		;b-vertical
    (if (= md 2) (gimp-layer-resize drawable (+ width (* 3d stp)) (+ height (* 3d stp)) 0 (* 3d stp)))	;lb-slant
    (if (= md 3) (gimp-layer-resize drawable (+ width (* (* 3d stp) 2)) height 0 0))				;l-horizontal
    (if (= md 4) (gimp-layer-resize drawable (+ width (* 3d stp)) (+ height (* 3d stp)) 0 0))			;lt-slant
    (if (= md 5) (gimp-layer-resize drawable width (+ height (* (* 3d stp) 2)) 0 0))				;t-vertical
    (if (= md 6) (gimp-layer-resize drawable (+ width (* 3d stp)) (+ height (* 3d stp)) (* 3d stp) 0))	;rt-slant
    (if (= md 7) (gimp-layer-resize drawable (+ width (* (* 3d stp) 2)) height (* (* 3d stp) 2) 0))		;r-horizontal
))

    (script-fu-mhbevel3dimg img drawable resize? 3d md "color" old-fg old-grad old-pat stp bmpblr bmpmp ck? white? FALSE)

    (gimp-palette-set-foreground old-fg)
    (gimp-gradients-set-gradient old-grad)
    (gimp-patterns-set-pattern old-pat)

    (gimp-image-undo-enable img)
    (gimp-display-new img)
))

(script-fu-register "script-fu-mhbevel3dimg22"
		    "<Image>/Script-Fu/MH/bevel3d"
		    "mhbevel3dimg"
		    "Kiki"
		    "Kiki"
		    "2012/1"
		    "RGBA"
		    SF-IMAGE      "Image"     0
		    SF-DRAWABLE   "Drawable"  0
                    SF-TOGGLE     "resize?"  		TRUE
		    SF-ADJUSTMENT "3D"			'(10 1 600 1 2 0 1)
                    SF-OPTION     "direction"            '(_"right-bottom" _"vertical-bottom" _"left-bottom" _"left-horizontal" 
						_"left-top" _"vertical-top" _"right-top" _"right-horizontal")
		    SF-ADJUSTMENT  "step"  		'(1 1 5 1 2 0 1)
		    SF-ADJUSTMENT  "bumpmap blur"  	'(5 1 70 1 2 0 0)
		    SF-ADJUSTMENT  "bumpmap depth"  	'(3 1 65 1 2 0 1)
                    SF-TOGGLE     "sp?"  		FALSE
                    SF-TOGGLE     "white?"              FALSE
)

