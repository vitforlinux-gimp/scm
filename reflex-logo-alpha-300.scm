;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;; Script-Fu Reflex

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))

;(cond ((not (defined? 'gimp-image-get-selected-drawables)) (define gimp-image-get-selected-drawables gimp-image-get-active-drawable)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))

  (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "QTBodiniPoster Italic")
  (define sffont "QTBodiniPoster-Italic"))


(define (apply-reflex-300-logo image drawable grad-type gradient reverse displace merge)
 
	(let* (
		(old-bg (car (gimp-context-get-background)))
		(old-fg (car (gimp-context-get-foreground)))
		(old-gradient (car (gimp-context-get-gradient)))

		(image-width (car (gimp-drawable-get-width drawable)))
		(image-height (car (gimp-drawable-get-height drawable)))
		(area (+ image-width image-height))

		(c-x (car (gimp-drawable-get-offsets drawable)))
		(c-y (cadr (gimp-drawable-get-offsets drawable)))

		(white-layer (car (gimp-layer-new-ng image image-width image-height RGBA-IMAGE "Blur" 100 LAYER-MODE-NORMAL-LEGACY)))
		(text-layer (car (gimp-layer-new-from-drawable drawable image)))
		(fond-layer (car (gimp-layer-new-ng image image-width image-height RGBA-IMAGE "GRAD" 100 LAYER-MODE-NORMAL-LEGACY)))
		(horizon-layer (car (gimp-layer-new-from-drawable fond-layer image)))
		(bump-layer (car (gimp-layer-new-ng image image-width image-height RGBA-IMAGE "Edge" 100 LAYER-MODE-OVERLAY-LEGACY)))
		(blur-layer 0)
		(layer 0)
		(adjust 0) )


	(gimp-image-insert-layer image white-layer 0 -1)
	(gimp-image-insert-layer image text-layer 0 -1)
	(gimp-image-insert-layer image fond-layer 0 -1)
	(gimp-image-insert-layer image horizon-layer 0 -1)
	(gimp-image-insert-layer image bump-layer 0 -1)

	(gimp-drawable-edit-clear fond-layer) 
	(gimp-drawable-edit-clear horizon-layer)

	(gimp-layer-set-offsets white-layer c-x c-y)
	(gimp-layer-set-offsets text-layer c-x c-y)
	(gimp-layer-set-offsets fond-layer c-x c-y)
	(gimp-layer-set-offsets horizon-layer c-x c-y)
	(gimp-layer-set-offsets bump-layer c-x c-y)
    (gimp-context-set-paint-mode 0)

(gimp-context-set-background '(255 255 255))
(gimp-drawable-edit-fill white-layer 1)
(set! blur-layer (car (gimp-image-merge-down image text-layer 0)))
(apply-gauss2 image blur-layer (/ area 70) (/ area 70))

	(if (= grad-type 0)(begin   (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Horizon 2")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Horizon 2" )))
				))
	(gimp-context-set-gradient gradient))
;(gimp-context-set-gradient gradient)
(gimp-context-set-gradient-reverse reverse)
;(gimp-edit-blend fond-layer 3 0 0 100 0 0 FALSE FALSE 0 0 FALSE 0 0 0 (+ image-height displace))
		      (gimp-drawable-edit-gradient-fill fond-layer  GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (+ image-height displace)) ; Fill with gradient

(gimp-item-set-visible fond-layer FALSE)
;(gimp-edit-blend horizon-layer 3 0 0 100 0 0 FALSE FALSE 0 0 FALSE 0 0 0 image-height)
		      (gimp-drawable-edit-gradient-fill horizon-layer  GRADIENT-LINEAR 0 0 1 0 0 0 0 0 image-height) ; Fill with gradient

(gimp-item-set-name horizon-layer "Reflex")
(set! adjust  (/ area (- 70 (* displace 2))))
	(cond((not(defined? 'plug-in-displace))
          (let* (
                 (filter (car (gimp-drawable-filter-new horizon-layer "gegl:displace" ""))))
            (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                            "amount-x" adjust "amount-y" adjust "abyss-policy" "clamp"
                                            "sampler-type" "cubic" "displace-mode" "cartesian")
            (gimp-drawable-filter-set-aux-input filter "aux" blur-layer)
            (gimp-drawable-filter-set-aux-input filter "aux2" blur-layer)
            (gimp-drawable-merge-filter horizon-layer filter)
          ))
        (else
(plug-in-displace 1 image horizon-layer adjust adjust TRUE TRUE blur-layer blur-layer 1)))

(gimp-context-set-foreground '(152 152 152))
(gimp-drawable-edit-fill bump-layer 0)
	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new bump-layer "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 135 "elevation" 27 "depth" 7
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 0.120
                                      "compensate" TRUE "invert" TRUE "type" "sinusoidal"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" blur-layer)
      (gimp-drawable-merge-filter bump-layer filter)
    ))
    (else
(plug-in-bump-map 1 image bump-layer blur-layer 135 27 7 0 0 0 0 TRUE TRUE 2)))
(apply-gauss2 image bump-layer 1 1)
(gimp-image-remove-layer image blur-layer)
;(gimp-context-set-gradient "Three bars sin")

(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Three bars sin")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Three Bars Sin")))
				)

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (plug-in-gradmap 1 image bump-layer)
  (plug-in-gradmap 1 image (vector bump-layer))	)


;(gimp-selection-layer-alpha drawable)
(gimp-image-select-item image 2 drawable)
(if (> area 200)
    (gimp-selection-grow image (/ area 160))
    (gimp-selection-grow image 1))
(gimp-selection-invert image)
(gimp-image-remove-layer image fond-layer)
(gimp-drawable-edit-clear horizon-layer)
(gimp-drawable-edit-clear bump-layer)
(gimp-selection-none image)



;(gimp-context-set-background old-bg)
;(gimp-context-set-foreground old-fg)
;(gimp-context-set-gradient old-gradient)

	)
)



;; ------------------------
;; script pour <image> 
;; ------------------------

(define (script-fu-reflex-300-logo-alpha image drawable grad-type gradient reverse displace bg-type bg-col merge)

	(let* (
	(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
		(drawable (car (gimp-image-get-active-drawable image)))
		(drawable (aref (cadr (gimp-image-get-selected-drawables image)) 0)))
		(var-select 0)
		(canal 0)
		(old-fg 0) )

  		(gimp-image-undo-group-start image)
		    (gimp-context-push)
		    (gimp-context-set-paint-mode 0)

    		
		(set! var-select (car (gimp-selection-is-empty image)))
		(if (= var-select TRUE) 
			(begin 
			)
			(begin 
				(set! canal (car (gimp-selection-save image)))
			)
		)
		(gimp-selection-none image)

		(set! old-fg (car (gimp-context-get-foreground)))
		(gimp-context-set-foreground '(0 0 0))

		(set! drawable (car (gimp-layer-copy drawable TRUE)))
		(gimp-layer-set-mode drawable LAYER-MODE-NORMAL-LEGACY)
		(gimp-image-insert-layer image drawable 0 -1)
				(plug-in-autocrop-layer 1 image drawable)
				(gimp-layer-resize drawable (+ (car (gimp-drawable-get-width drawable)) 50) (+ (car (gimp-drawable-get-height drawable)) 50 ) 25 25)
		(gimp-layer-set-lock-alpha drawable TRUE)
		(gimp-drawable-edit-fill drawable FILL-FOREGROUND)
		(gimp-layer-set-lock-alpha drawable FALSE)

		(apply-reflex-300-logo image drawable grad-type gradient reverse displace FALSE)
    		
		(if (= var-select TRUE) 
			(begin 
			)
			(begin 
				(gimp-image-select-item image 2 canal)
				(gimp-image-remove-channel image canal)
			)
		)
		(gimp-layer-resize-to-image-size drawable)
				(gimp-selection-none image)

			(if (= bg-type 0)
		(begin 
	     ; (gimp-drawable-edit-fill drawable FILL-WHITE)
	     	     (gimp-drawable-edit-clear drawable)

	     		(gimp-layer-set-lock-alpha drawable TRUE)
	      (gimp-item-set-name drawable "Transparent")
		)
	)
	(if (= bg-type 1)
		(begin 
	      ;(gimp-drawable-edit-fill drawable FILL-WHITE)
	      		(gimp-context-set-background bg-col)
	(gimp-drawable-fill drawable FILL-BACKGROUND)
	      (gimp-item-set-name drawable "Color")
		)
	)
	(if (= bg-type 2)
		(begin 
	     ; (gimp-drawable-edit-fill drawable FILL-WHITE)
	      (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Horizon 2")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Horizon 2" )))
				)
	     (gimp-drawable-edit-gradient-fill drawable  GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (car (gimp-drawable-get-height drawable))) ; Fill with gradient
	      (gimp-item-set-name drawable "Grad default")
		)
	)
		(if (= bg-type 3)
		(begin 
	     ; (gimp-drawable-edit-fill drawable FILL-WHITE)
	     
						 (gimp-context-set-gradient gradient)

	     (gimp-drawable-edit-gradient-fill drawable  GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (car (gimp-drawable-get-height drawable))) ; Fill with gradient
	      (gimp-item-set-name drawable "Grad manual")
		)
	)
	(if (= merge TRUE)
	(begin
						(gimp-image-merge-visible-layers image 1)
	))

		;(if (= merge TRUE)
			;(gimp-image-merge-down image (car (gimp-image-get-selected-drawables image)) 0)
			;(gimp-image-remove-layer image drawable))

       ; (gimp-context-set-foreground old-fg)
	    (gimp-context-pop)
		(gimp-image-undo-group-end image)
		(gimp-displays-flush)
  )
)

(script-fu-register "script-fu-reflex-300-logo-alpha"
       _"Reflex 300 Alpha..."
        "reflection"
        "Expression"
        "Free"
        "2006"
        "RGBA"
        SF-IMAGE      "Image"        0
        SF-DRAWABLE   "Drawable"     0
	SF-OPTION "Gradient Type" '("Default Gradient" "Manual Gradient")
        SF-GRADIENT   "Gradient"     _"Horizon 2"
	SF-TOGGLE     "Gradient reverse" FALSE
        SF-ADJUSTMENT "Shift amount"     '(10 1 20 1 10 0 0)
	SF-OPTION "Background Type" '("Transparent" "Color" "Default Gradient" "Manual Gradient")
	SF-COLOR "Background color" '(255 255 255)
        SF-TOGGLE     "Flatten" FALSE
)

(script-fu-menu-register "script-fu-reflex-300-logo-alpha"
		_"<Image>/Filters/Alpha to Logo"
)



;; ------------------------
;; script pour <toolbox> 
;; ------------------------

(define (script-fu-reflex-300-logo text size font justification letter-spacing line-spacing buffer grad-type gradient reverse displace bg-type bg-col merge)

  (let* (
	(image (car (gimp-image-new 256 256 RGB)))
	(bg-layer (car (gimp-layer-new-ng image 256 256 RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	 (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))	
	(text-layer (car (gimp-text-fontname image -1 0 0 text (* 10 buffer) TRUE size PIXELS font))))
	
	   (gimp-text-layer-set-justification  text-layer  justification) ; Text Justification (Rev Value)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
	(gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing    

	(gimp-image-undo-disable image)
	    (gimp-context-push)
	    (gimp-context-set-paint-mode 0)


    (gimp-item-set-name text-layer "Text")
	(gimp-image-resize image (car (gimp-drawable-get-width text-layer)) (car (gimp-drawable-get-height text-layer)) 0 0)    	
	(apply-reflex-300-logo image text-layer grad-type gradient reverse displace FALSE)

	(if (= bg-type 0)
		(begin 
	     ; (gimp-drawable-edit-fill text-layer FILL-WHITE)
	     (gimp-drawable-edit-clear text-layer)
	     	     		(gimp-layer-set-lock-alpha text-layer TRUE)
	      (gimp-item-set-name text-layer "Transparent")
		)
	)
	(if (= bg-type 1)
		(begin 
	      ;(gimp-drawable-edit-fill text-layer FILL-WHITE)
	      		(gimp-context-set-background bg-col)
	(gimp-drawable-fill text-layer FILL-BACKGROUND)
	      (gimp-item-set-name text-layer "Color")
		)
	)
	(if (= bg-type 2)
		(begin 
	     ; (gimp-drawable-edit-fill text-layer FILL-WHITE)
	      (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Horizon 2")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Horizon 2" )))
				)
	     (gimp-drawable-edit-gradient-fill text-layer  GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (car (gimp-drawable-get-height text-layer))) ; Fill with gradient
	      (gimp-item-set-name text-layer "Grad default")
		)
	)
		(if (= bg-type 3)
		(begin 
	     ; (gimp-drawable-edit-fill text-layer FILL-WHITE)
	     
						 (gimp-context-set-gradient gradient)

	     (gimp-drawable-edit-gradient-fill text-layer  GRADIENT-LINEAR 0 0 1 0 0 0 0 0 (car (gimp-drawable-get-height text-layer))) ; Fill with gradient
	      (gimp-item-set-name text-layer "Grad manual")
		)
	)
	(if (= merge TRUE)
	(begin
			(gimp-image-merge-visible-layers image 1)
	)
)
	(gimp-image-undo-enable image)
	    (gimp-context-pop)
	(gimp-display-new image)
  )
)

(script-fu-register "script-fu-reflex-300-logo"
       _"Reflex 300 logo..."
        "reflective logo"
        "Expression"
        "Free"
        "2006"
        ""
        SF-TEXT     _"Text"               "Reflex"
        SF-ADJUSTMENT _"Font size (pixels)" '(200 2 1000 1 10 0 1)
        SF-FONT       _"Font"               sffont
	SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill")
	SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
	SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
	SF-ADJUSTMENT  "Buffer"           '(1 1 20 1 10 0 0)
	SF-OPTION "Gradient Type" '("Default Gradient" "Manual Gradient")
        SF-GRADIENT    "Gradient"           "Horizon 2"
	SF-TOGGLE      "Gradient reverse"        FALSE
        SF-ADJUSTMENT  "Shift amount"           '(10 1 20 1 10 0 0)
	SF-OPTION "Background Type" '("Transparent" "Color" "Default Gradient" "Manual Gradient")
	SF-COLOR "Background color" '(255 255 255)
        SF-TOGGLE      "Flatten"        FALSE
)

(script-fu-menu-register "script-fu-reflex-300-logo"
		_"<Image>/File/Create/Logos/"
)
