;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

;;mhpaint
;Kiki
;http://kikidide.yuki-mura.net/GIMP/gimp.htm
;http://kikidide.yuki-mura.net/GIMP/engimp.htm
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		(define (apply-gauss img drawable x y)(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
      (plug-in-gauss  1  img drawable x y 1)
 (plug-in-gauss  1  img drawable (* x 0.32) (* y 0.32) 1)  )))
;

(define (script-fu-mhpaint text size font justify mode psize oil bg-mode bg-color bg-grad bg-pat s-color sblur soff)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
;;ï∂éö
	 (text-layer (car (gimp-text-fontname img -1 0 0 text (+ (/ size 12) 4) TRUE size PIXELS font)))
;;ïùÇ∆çÇÇ≥
	 (width (car (gimp-drawable-get-width text-layer)))
	 (height (car (gimp-drawable-get-height text-layer)))
;;îwåi
	 (bg-layer (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 0)))
	 (paint-layer (car (gimp-layer-new img width height RGB-IMAGE "Paint" 100 0)))

        ; (old-fg (car (gimp-context-get-foreground)))
         ;(old-grad (car (gimp-context-get-gradient)))
         ;(old-pat (car (gimp-context-get-pattern)))
	(justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
				((= justify 2) 1)))
)
(gimp-image-undo-disable img)
		(gimp-context-push)
				(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
;;ÉTÉCÉYí≤êÆ
    (gimp-image-resize img width height 0 0)
    (gimp-text-layer-set-justification text-layer justify)

    (script-fu-mhpaintimg img text-layer mode psize oil bg-mode bg-color bg-grad bg-pat s-color sblur soff)

    ;(gimp-context-set-foreground old-fg)
    ;(gimp-context-set-gradient old-grad)
    ;(gimp-context-set-pattern old-pat)

    (gimp-image-undo-enable img)
    		(gimp-context-pop)
    (gimp-display-new img)
))

(script-fu-register "script-fu-mhpaint"
			"MH paint Logo"
			"mhpaint"
			"Kiki"
			"Kiki"
			"2013/10"
			""
			SF-TEXT	"Text String"	"Paint"
			SF-ADJUSTMENT	"Font Size (pixels)"	'(150 2 1000 1 10 0 1)
			SF-FONT		"Font"		"QTKooper"
			SF-OPTION "Justify" '("Centered" "Left" "Right")
			SF-OPTION	"mode"		'(_"0(colorful)" _"1(red)" _"2(yellow)" 
						_"3(green)" _"4(watercolor)" _"5(blue)" _"6(magenta)")
			SF-ADJUSTMENT	"Paint size"	'(10 5 30 1 2 0 0)
			SF-TOGGLE  "Oilify"    TRUE
			SF-OPTION	"bg mode"          '(_"color" _"gradient" _"pattern")
			SF-COLOR	"Background Color"	'(255 232 252)
			SF-GRADIENT "Background Gradient"     "Yellow Orange"
			SF-PATTERN  "Background Pattern"      "Wood"
			SF-COLOR	"Shadow Color"	'(87 32 45)
			SF-ADJUSTMENT	"shadow blur"	'(3 0 100 1 2 0 1)
			SF-ADJUSTMENT	"shadow offset"	'(2 0 100 1 2 0 1)
)

(script-fu-menu-register "script-fu-mhpaint"
                         "<Image>/Script-Fu/Logos")

(define (script-fu-mhpaintimg img drawable mode psize oil bg-mode bg-color bg-grad bg-pat s-color sblur soff)
  (let* (

;;ïùÇ∆çÇÇ≥
	 (width (car (gimp-drawable-get-width drawable)))
	 (height (car (gimp-drawable-get-height drawable)))

;;îwåi
	 (bg-layer (car (gimp-layer-new img width height RGB-IMAGE "Background" 100 0)))
	 (paint-layer (car (gimp-layer-new img width height RGB-IMAGE "paint" 100 0)))

        ; (old-fg (car (gimp-context-get-foreground)))
        ; (old-grad (car (gimp-context-get-gradient)))
         ;(old-pat (car (gimp-context-get-pattern)))

	 (shou)
)
    (gimp-image-undo-group-start img)
    		(gimp-context-push)
				(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )

    (gimp-image-select-item img 2 drawable)
    (gimp-selection-sharpen img)
    (gimp-image-insert-layer img paint-layer 0 1)
    (gimp-selection-none img)
    (gimp-drawable-edit-clear paint-layer)
    (cond ((= mode 0)
	(gimp-context-set-foreground '(190 190 190))
        (if (< psize 7) (gimp-context-set-foreground '(190 185 190)))
    )
	((= mode 1)
	(gimp-context-set-foreground '(255 190 190))
        (if (< psize 9) (gimp-context-set-foreground '(225 145 145)))
        (if (> psize 16) (gimp-context-set-foreground '(190 175 175)))
    )
	((= mode 2)
	(gimp-context-set-foreground '(240 240 170))
        (if (< psize 7) (gimp-context-set-foreground '(255 250 110)))
        (if (> psize 16) (gimp-context-set-foreground '(190 190 130)))
    )
	((= mode 3)
	(gimp-context-set-foreground '(160 190 160))
        (if (> psize 15) (gimp-context-set-foreground '(160 170 160)))
    )
	((= mode 4)
	(gimp-context-set-foreground '(170 255 255))
        (if (< psize 7) (gimp-context-set-foreground '(170 245 255)))
        (if (> psize 16) (gimp-context-set-foreground '(180 215 215)))
    )
	((= mode 5)
	(gimp-context-set-foreground '(210 210 255))
        (if (> psize 16) (gimp-context-set-foreground '(210 210 235)))
    )
	((= mode 6)
	(gimp-context-set-foreground '(200 150 200))
        (if (> psize 16) (gimp-context-set-foreground '(180 150 180)))
    ))

    (gimp-drawable-fill paint-layer 0)
    (gimp-image-select-item img 2 drawable)
    (gimp-selection-grow img 3)
    (plug-in-noisify 1 img paint-layer TRUE 1.0 1.0 1.0 1.0)
    (plug-in-noisify 1 img paint-layer TRUE 1.0 1.0 1.0 1.0)
    (gimp-selection-none img)
    (plug-in-pixelize 1 img paint-layer psize)
    (gimp-drawable-hue-saturation paint-layer 0 0 0 100 0)
    (gimp-drawable-hue-saturation paint-layer 0 0 0 100 0)
    (gimp-drawable-hue-saturation paint-layer 0 0 0 100 0)
    (if (> psize 10)
    (begin
    (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
    (plug-in-despeckle 1 img paint-layer psize 0 -1 200)
   (plug-in-despeckle 1 img (vector paint-layer) psize "median" -1 255))
;    (gimp-drawable-hue-saturation paint-layer 0 0 0 (* psize 3.3) 0)
    )
	(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
    (plug-in-despeckle 1 img paint-layer 10 0 -1 255)
        (plug-in-despeckle 1 img (vector paint-layer) 10 "median" 1 255))
    )
    	(if (= oil 1)(begin (gimp-layer-set-lock-alpha paint-layer TRUE)
	      (plug-in-oilify 1 img paint-layer 10 0)
(gimp-layer-set-lock-alpha paint-layer FALSE)))    
    (gimp-drawable-hue-saturation paint-layer 0 0 0 100 0)
    (gimp-drawable-hue-saturation paint-layer 0 0 -35 70 0)
    (gimp-image-select-item img 2 drawable)
    (gimp-layer-add-alpha paint-layer)
    (gimp-selection-invert img)
    (gimp-drawable-edit-clear paint-layer)
    (gimp-selection-none img)

    (gimp-image-insert-layer img bg-layer 0 2)

;;ÉTÉCÉYí≤êÆ
    (gimp-image-resize img (+ (+ width soff) (* sblur 1.1)) (+ (+ height soff) (* sblur 1.1)) (/ sblur 1.9) (/ sblur 1.9))
    (gimp-layer-resize drawable (+ (+ width soff) (* sblur 1.1)) (+ (+ height soff) (* sblur 1.1)) (/ sblur 1.9) (/ sblur 1.9))
    (gimp-layer-resize paint-layer (+ (+ width soff) (* sblur 1.1)) (+ (+ height soff) (* sblur 1.1)) (/ sblur 1.9) (/ sblur 1.9))
    (gimp-layer-resize bg-layer (+ (+ width soff) (* sblur 1.1)) (+ (+ height soff) (* sblur 1.1)) (/ sblur 1.9) (/ sblur 1.9))

    (gimp-layer-set-lock-alpha drawable TRUE)
    (gimp-context-set-foreground s-color)
    (gimp-drawable-edit-fill drawable 0)
    (gimp-layer-set-lock-alpha drawable FALSE)
    (gimp-image-raise-item img paint-layer)
    (if (>= sblur 1) (apply-gauss img drawable sblur sblur))
    (gimp-item-transform-translate drawable soff soff)
    (gimp-layer-set-opacity drawable 75)

;;îwåiêFÇÃåàíË
    (gimp-context-set-foreground bg-color)
    (gimp-drawable-fill bg-layer 0)
    (cond((= bg-mode 1)
       (gimp-context-set-gradient bg-grad)
      ; (gimp-blend bg-layer 3 0 0 100 20 REPEAT-NONE FALSE 0 0 0 0 0 0 width height))	;CUSOM:3 NORMAL:0 LINEAR:0
        (gimp-drawable-edit-gradient-fill bg-layer 0 0 REPEAT-NONE 1 0.0 FALSE 0 0 width height))

    ((= bg-mode 2)
       (gimp-selection-all img)
       (gimp-context-set-pattern bg-pat)
       ;(gimp-bucket-fill bg-layer BUCKET-FILL-PATTERN 0 100 255 FALSE 0 0)		;NORNAL:0
       (gimp-drawable-fill bg-layer FILL-PATTERN)
       (gimp-selection-none img)
       ))

    (set! width (car (gimp-drawable-get-width bg-layer)))		;add
    (set! height (car (gimp-drawable-get-height bg-layer)))		;add
    (if (>= soff sblur ) (set! shou sblur)			;add
	(set! shou soff)					;add
    )								;add
    (gimp-image-resize img (- width (/ shou 2))  (- height (/ shou 2)) (- 0 (/ shou 2)) (- 0 (/ shou 2)))	;add
    (gimp-layer-resize bg-layer (- width (/ shou 2))  (- height (/ shou 2)) (- 0 (/ shou 2)) (- 0 (/ shou 2)))	;add

    ;(gimp-context-set-foreground old-fg)
    ;(gimp-context-set-gradient old-grad)
    ;(gimp-context-set-pattern old-pat)

    (gimp-image-undo-group-end img)
    		(gimp-context-pop)
    (gimp-displays-flush)

))

(script-fu-register "script-fu-mhpaintimg"
			"MH paint ALPHA"
			"mhpaintimg"
			"Kiki"
			"Kiki"
			"2013/10"
			"RGB*"
			SF-IMAGE        "Image"		0
			SF-DRAWABLE     "Drawable"	0
			SF-OPTION	"mode"		'(_"0(colorful)" _"1(red)" _"2(yellow)" 
						_"3(green)" _"4(watercolor)" _"5(blue)" _"6(magenta)")
			SF-ADJUSTMENT    "Paint size"	'(10 5 30 1 2 0 0)
			SF-TOGGLE  "Oilfy"    TRUE
			SF-OPTION	"bg mode"          '(_"color" _"gradient" _"pattern")
			SF-COLOR    "Background Color"	'(255 232 252)
			SF-GRADIENT "Background Gradient"     "Yellow Orange"
			SF-PATTERN  "Background Pattern"      "Wood"
			SF-COLOR    "Shadow Color"	'(87 32 45)
			SF-ADJUSTMENT  "shadow blur"	'(3 0 100 1 2 0 1)
			SF-ADJUSTMENT  "shadow offset"	'(2 0 100 1 2 0 1)
)
(script-fu-menu-register "script-fu-mhpaintimg"
                         "<Image>/Script-Fu/Alpha-to-Logo")
