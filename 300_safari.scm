;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

;; http://abcdugimp.free.fr
;; ---------------------------------------------------------
;; *							   
;; * 		  	    Script-Fu Safari
;; *							   
;; ---------------------------------------------------------
;; creative commons licence
;; http://creativecommons.org/licenses/by-nc-sa/2.0/fr/
;; 31-lug-2024 a little fix for Gimp 2.10.38 compatibility OFF

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))
(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))


(cond ((not (defined? 'gimp-context-set-pattern-ng)) (define (gimp-context-set-pattern-ng value) 
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-pattern value)
				(gimp-context-set-pattern (car (gimp-pattern-get-by-name value)))
				))))
		(define (apply-gauss img drawable x y)(begin (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
      (plug-in-gauss  1  img drawable x y 0)
 (plug-in-gauss  1  img drawable (* x 0.32) (* y 0.32) 0)  )))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "QTFrizQuad Bold")
  (define sffont "QTFrizQuad-Bold"	))


(define (apply-safari-logo-300 image drawable size type relief grad-type gradient flou flou-r elevation depth conserv trans? bgcolor scolor sblur soff)
 	
	(let* (
		;; conserver les outils dans des variables
		;(old-pat (car (gimp-context-get-pattern)))
		;(old-fg (car (gimp-context-get-foreground)))
		;(old-deg (car (gimp-context-get-gradient)))
		
		;; connaitre les dimensions de l'image
		(image-width (car (gimp-drawable-get-width drawable)))
		(image-height (car (gimp-drawable-get-height drawable)))
		
		(finale-image (car (gimp-image-new image-width image-height RGB)))
		
		(texture-terra-image 0)
		(texture-blueweb-image 0)
		(texture-safari-image 0)
		(texture-terra-layer 0)
		(texture-blueweb-layer 0)
		(texture-safari-layer 0)
		(bump-image 0)
		(bump-layer 0)
		(duplicate-layer 0)
		(flou-layer 0)
		(mask 0)
		(shou 0)
		(width 0)
		(height 0)

		(bg-layer (car (gimp-layer-new finale-image image-width image-height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
		(s-layer (car (gimp-layer-new finale-image image-width image-height RGBA-IMAGE "Shadow" 100 LAYER-MODE-NORMAL-LEGACY)))

		(text-layer (car (gimp-layer-new-from-drawable drawable finale-image)))
		(fond-map-layer 0) ;; map pour le relief
		)
		(gimp-context-push)
		(gimp-context-set-paint-mode 0)
		
		;; *******************************************************************************
		;; PREPARATION CALQUE FINALE
		;; *******************************************************************************
		;; add layer
		(if (> flou 0) ;; si un flou est demand
			(begin
				(set! flou-layer (car (gimp-layer-new finale-image image-width image-height RGBA-IMAGE "Flou" 100 LAYER-MODE-NORMAL-LEGACY)))
				(gimp-image-insert-layer finale-image flou-layer 0 -1)
				(gimp-drawable-edit-clear flou-layer)	
			)
		)
		(gimp-image-insert-layer finale-image text-layer 0 -1)
		(gimp-item-set-name text-layer "Script-fu Safari")
		(gimp-layer-set-offsets text-layer 0 0) ;; mettre le calques aux bonnes coordonnees
		(gimp-context-set-foreground '(255 255 255))
		(gimp-layer-set-lock-alpha text-layer 1) ;; preserve la transparence
		(gimp-drawable-edit-fill text-layer 0) ;; remplir de blanc

		;; *******************************************************************************
		;; MAP
		;; *******************************************************************************
		;; dupliquer text-layer pour creer la map
		(set! bump-image (car (gimp-image-duplicate finale-image)))
		(set! fond-map-layer (car (gimp-layer-new bump-image image-width image-height RGB-IMAGE "Map" 100 LAYER-MODE-NORMAL-LEGACY))) ;; map pour le relief
		(gimp-context-set-foreground '(0 0 0))
		(gimp-image-insert-layer bump-image fond-map-layer 0 1)
		(gimp-drawable-edit-fill fond-map-layer 0) ;; remplir de noir
		(set! bump-layer (car (gimp-image-flatten bump-image))) ;; aplatir l'image map
		(apply-gauss bump-image bump-layer flou-r flou-r) ;; flou gaussien
		
		;; *******************************************************************************
		;; REPOUSSAGE
		;; *******************************************************************************
		(if (>= depth 1) (plug-in-bump-map 1 finale-image text-layer bump-layer 135 elevation depth 0 0 0 0 TRUE FALSE 0)) ;; repoussage
				
		;; *******************************************************************************
		;; TYPE D'EFFET
		;; *******************************************************************************
		;; base
	(if (= grad-type 0)(begin   (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Shadows 1")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Shadows 1" )))
				)))
	(if (= grad-type 1)(begin   (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Greens")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Greens" )))
				)))
	(if (= grad-type 2)(begin   (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Four bars")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Four Bars" )))
				)))
		(if (= grad-type 3)	(gimp-context-set-gradient gradient))
		;(gimp-context-set-gradient gradient)
		(if (= relief 1)	;; relief double
			(begin		;;changed 5 to 10 2.6
			(plug-in-displace RUN-NONINTERACTIVE finale-image text-layer (* (/ size 121) 5) (* (/ size 120) 5) TRUE TRUE bump-layer bump-layer 1)
		)
		)
		(if (> flou 0) ;; si un flou est demandÈ
			(begin
				(gimp-image-select-item finale-image 2 text-layer) ;; alpha vers selection
				(gimp-drawable-edit-fill flou-layer FILL-FOREGROUND) ;; remplir de noir
				(gimp-selection-none finale-image)
				(apply-gauss finale-image flou-layer flou flou) ;; flou gaussien
			)
		)
		;; texture terra
		(set! texture-terra-image (car (gimp-image-new image-width image-height RGB)))
		(set! texture-terra-layer (car (gimp-layer-new texture-terra-image image-width image-height RGB "Pattern Terra" 100 LAYER-MODE-NORMAL-LEGACY)))
		(gimp-image-insert-layer texture-terra-image texture-terra-layer 0 -1)
		(gimp-context-set-pattern-ng "Terra")
		(gimp-drawable-edit-fill texture-terra-layer FILL-PATTERN)
		;; texture blue web
		(set! texture-blueweb-image (car (gimp-image-new image-width image-height RGB)))
		(set! texture-blueweb-layer (car (gimp-layer-new texture-blueweb-image image-width image-height RGB "Pattern Blue Web" 100 LAYER-MODE-NORMAL-LEGACY)))
		(gimp-image-insert-layer texture-blueweb-image texture-blueweb-layer 0 -1)
		(gimp-context-set-pattern-ng "Blue Web")
		(gimp-drawable-edit-fill texture-blueweb-layer FILL-PATTERN)
		;; texture safari
		(set! texture-safari-image (car (gimp-image-new image-width image-height RGB)))
		(set! texture-safari-layer (car (gimp-layer-new texture-safari-image image-width image-height RGB "Texture Safari" 100 LAYER-MODE-NORMAL-LEGACY)))
		(gimp-image-insert-layer texture-safari-image texture-safari-layer 0 -1)
		(plug-in-solid-noise RUN-NONINTERACTIVE texture-safari-image texture-safari-layer FALSE FALSE 0 1 4.0 4.0)
	(plug-in-displace RUN-NONINTERACTIVE texture-safari-image texture-safari-layer (* (/ size 121) 20) (* (/ size 120) 20) TRUE TRUE texture-blueweb-layer texture-blueweb-layer 1)
	(plug-in-oilify RUN-NONINTERACTIVE texture-safari-image texture-safari-layer 8 1)
		;(plug-in-gradmap RUN-NONINTERACTIVE texture-safari-image texture-safari-layer) ;; appliqule drad
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)  
(plug-in-gradmap 1 texture-safari-image texture-safari-layer) 
      (plug-in-gradmap 1 texture-safari-image (vector texture-safari-layer))   )              ; Map Gradient
	(plug-in-displace RUN-NONINTERACTIVE texture-safari-image texture-safari-layer (* (/ size 121) 10) (* (/ size 120) 10) TRUE TRUE texture-terra-layer texture-terra-layer 1)

	(if (= type 1) ;; cameleon malade
			(begin
				(plug-in-spread RUN-NONINTERACTIVE texture-safari-image texture-safari-layer (* (/ size 120) 20) (* (/ size 120) 20))
			)
		)
		(if (= type 2) ;; tigre grincheux
			(begin

		(if (symbol-bound? 'plug-in-cartoon (the-environment))
			(plug-in-cartoon RUN-NONINTERACTIVE texture-safari-image texture-safari-layer (* (/ size 120) 7.0) 0.200)	;changed
			)

			)
		)
		(if (= type 3) ;; Serpent facetieux
			(begin
				(plug-in-mosaic RUN-NONINTERACTIVE texture-safari-image texture-safari-layer (* (/ size 120) 15.0) (* (/ size 120) 4.0) (/ size 120) 0.65 TRUE 135.0 0.2 TRUE FALSE 1 FALSE FALSE)
			)
		)
		(if (= type 4) ;; himpala harmonieux
			(begin
				(plug-in-polar-coords RUN-NONINTERACTIVE texture-safari-image texture-safari-layer 100.0 0.0 FALSE TRUE FALSE)
			)
		)

		(set! duplicate-layer (car (gimp-layer-new-from-drawable texture-safari-layer finale-image)))
		(gimp-image-insert-layer finale-image duplicate-layer 0 -1)

		(gimp-layer-set-mode duplicate-layer LAYER-MODE-HARDLIGHT-LEGACY)
		(gimp-image-select-item finale-image 2 text-layer)		;add 2.6
		(gimp-layer-add-alpha duplicate-layer)		;add 2.6
		(gimp-selection-invert finale-image)		;add 2.6
		(gimp-drawable-edit-clear duplicate-layer)		;add 2.6
		(gimp-selection-none finale-image)		;add 2.6

		(if (= type 2)								;add 2.0
		(if (symbol-bound? 'plug-in-cartoon (the-environment))			;add 2.0
			()								;add 2.0
			(begin								;add 2.0
			(set! c-layer (car (gimp-layer-copy duplicate-layer TRUE)))	;add 2.0
			(gimp-image-insert-layer finale-image c-layer 0 0) ;add 2.0
			(plug-in-edge 1 finale-image c-layer 3 0 4)			;add 2.0
			(gimp-desaturate c-layer)					;add 2.0
			(gimp-invert c-layer)						;add 2.0
			(gimp-threshold c-layer 155 255)				;add 2.0
			(gimp-layer-set-mode c-layer MULTIPLY)				;add 2.0
			(apply-gauss finale-image c-layer (* (/ size 120) 6) (* (/ size 120) 6))	;add 2.0
			(plug-in-unsharp-mask 1 finale-image c-layer 5 3 0)		;add 2.0
			(set! duplicate-layer (car (gimp-image-merge-down finale-image c-layer 0)))	;add 2.0
			(gimp-layer-set-mode duplicate-layer LAYER-MODE-HARDLIGHT-LEGACY)		;add 2.0
		))									;add 2.0
		)									;add 2.0

		(if (> flou 0) ;; si un flou est demand
			(begin
				(set! mask (car (gimp-layer-create-mask duplicate-layer ADD-MASK-BLACK)))
				(gimp-layer-add-mask duplicate-layer mask)
				(gimp-context-set-foreground '(255 255 255))
				(gimp-image-select-item finale-image 2 text-layer) ;; alpha vers selection
				(gimp-drawable-edit-fill mask FILL-FOREGROUND) ;; remplir de noir
				(gimp-selection-none finale-image)
			)
		)


		;; *******************************************************************************
		;; FINALISATIONS
		;; *******************************************************************************
		(gimp-image-resize finale-image (+ (+ image-width soff) (* sblur 1.1)) (+ (+ image-height soff) (* sblur 1.1)) (/ (* sblur 1.1) 2) (/ (* sblur 1.1) 2))

		(if (= trans? FALSE)				;add
		(begin						;add
		(gimp-image-insert-layer finale-image bg-layer 0 2) ;add
		(gimp-layer-resize bg-layer (+ (+ image-width soff) (* sblur 1.1)) (+ (+ image-height soff) (* sblur 1.1)) 0 0)
		(gimp-context-set-foreground bgcolor)		;add
		(gimp-drawable-edit-fill bg-layer FILL-FOREGROUND)		;add
		))						;add

		(gimp-image-insert-layer finale-image s-layer 0 2) ;add
		(gimp-layer-resize s-layer (+ (+ image-width soff) (* sblur 1.1)) (+ (+ image-height soff) (* sblur 1.1)) 0 0)
		(gimp-drawable-edit-clear s-layer)			;add
		(gimp-image-select-item finale-image 2 text-layer)		;add
		(gimp-context-set-foreground scolor)		;add
		(gimp-drawable-edit-fill s-layer FILL-FOREGROUND)	;add
		(gimp-selection-none finale-image)		;add
		(if (>= sblur 1) (apply-gauss finale-image s-layer sblur sblur))	;add
		(gimp-item-transform-translate s-layer soff soff)	;add

		(set! width (car (gimp-image-get-width finale-image)))	;add
		(set! height (car (gimp-image-get-height finale-image)))	;add
		(if (>= soff sblur ) (set! shou sblur)			;add
			(set! shou soff)				;add
		)							;add
		(gimp-image-resize finale-image (- width (/ shou 2))  (- height (/ shou 2)) (- 0 (/ shou 2)) (- 0 (/ shou 2)))	;add
		(if (= trans? FALSE) (gimp-layer-resize bg-layer (- width (/ shou 2))  (- height (/ shou 2)) (- 0 (/ shou 2)) (- 0 (/ shou 2))))	;add

		(gimp-display-new finale-image)
		(gimp-image-delete texture-terra-image)
		(gimp-image-delete texture-blueweb-image)
		(if (= conserv FALSE) ;; Conserver les images ?
			(begin
				(gimp-image-delete texture-safari-image)
				(gimp-image-delete bump-image)
;				(gimp-image-merge-visible-layers finale-image EXPAND-AS-NECESSARY)	;none
			)
			(begin
				(gimp-display-new texture-safari-image)
				(gimp-display-new bump-image)
			)
		)
		
		

		;; mise a jour
		;(gimp-context-set-pattern-ng old-pat)
		;(gimp-context-set-foreground old-fg)
		;(gimp-context-set-gradient old-deg)
		(gimp-context-pop)
		
	)
)


;; ------------------------
;; script pour <image> 
;; ------------------------

(define (script-fu-safari-logo-300-alpha image drawable size type relief grad-type gradient flou flou-r elevation depth conserv trans? bgcolor scolor sblur soff)
	(let* (
		(var-select (car (gimp-selection-is-empty image)))
		(canal 0)
		)

  		(gimp-image-undo-group-start image)
    		
		
		(if (= var-select TRUE) ;; test si il y a selection
			(begin ;; aucune selection n'a faite 
			)
			(begin ;; une selection a ete faite
				(set! canal (car (gimp-selection-save image))) ;; canal stockant la selection originelle de l'utilisateur
			)
		)
		
		(gimp-selection-none image)

		(apply-safari-logo-300 image drawable size type relief grad-type gradient flou flou-r elevation depth conserv trans? bgcolor scolor sblur soff)
    		
		(if (= var-select TRUE) ;; test si il y AVAIT selection
			(begin ;; aucune selection n'avait faite 
			)
			(begin ;; une selection avait faite (remettre la selection de l'utilisateur)
				(gimp-image-select-item image 2 canal) ;; mask de canal vers selection
				(gimp-image-remove-channel image canal) ;; supprimer le mask de canal
			)
		)
		
		(gimp-image-undo-group-end image)
    		
		(gimp-displays-flush)
		
	)
)

(script-fu-register "script-fu-safari-logo-300-alpha"
		"Safari 300 ALPHA"
		"Applique une texture animal a une surface a partir de votre calque."
		"abcdugimp.free.fr - creative commons licence"
		"Michel Douez"
		"21/03/2008"
		"RGBA"
            SF-IMAGE      "Image" 0
            SF-DRAWABLE   "Drawable" 0
		SF-ADJUSTMENT	"Size (pixels)" '(120 2 1000 1 10 0 1)
		SF-OPTION "Type" '("Cameleon paisible" "Cameleon malade" "Tigre grincheux" "Serpent facetieux" "Himpala harmonieux")
		SF-OPTION "Relief" '("Simple" "Double")
		SF-OPTION "Gradient type" '("Desert (Shadows 1)" "Jungle (Greens)" "Urban (Four Bars)" "User choice")
		SF-GRADIENT _"Gradient User choice" "Shadows 1"
		SF-ADJUSTMENT "Bump blur" '(0 0 50 1 10 0 1)
		SF-ADJUSTMENT "Bump blur (repoussage)" '(15 1 120 1 0 0 1)
		SF-ADJUSTMENT "Elevation (repoussage)" '(20 1 90 1 0 0 1)
		SF-ADJUSTMENT "Depth" '(3 0 100 1 0 0 1)
		SF-TOGGLE "Conserver les images et les calques ?" FALSE
		SF-TOGGLE "Background Transparent?" FALSE
		SF-COLOR	"Background Color"	'(212 205 192)
		SF-COLOR	"Shadow Color"	'(35 35 35)
		SF-ADJUSTMENT "Shadow blur" '(3 0 100 1 0 0 1)
		SF-ADJUSTMENT "Shadow offset" '(3 0 100 1 0 0 1)
)
(script-fu-menu-register "script-fu-safari-logo-300-alpha" "<Image>/Script-Fu/Alpha-to-Logo/")


(define (script-fu-safari-logo-300 text size font justify type relief grad-type gradient flou flou-r elevation depth conserv trans? bgcolor scolor sblur soff)
  (let* ((img (car (gimp-image-new 256 256 RGB)))
;;ï∂éö
	 (text-layer (car (gimp-text-fontname img -1 0 0 text (+ (/ size 12) 4) TRUE size PIXELS font)))
;;ïùÇ∆çÇÇ≥
	 (width (car (gimp-drawable-get-width text-layer)))
	 (height (car (gimp-drawable-get-height text-layer)))
;
         ;(old-fg (car (gimp-context-get-foreground)))
         ;(old-grad (car (gimp-context-get-gradient)))
         ;(old-pat (car (gimp-context-get-pattern)))
	(justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
				((= justify 2) 1)))


)
(gimp-image-undo-disable img)
(gimp-context-push)
(gimp-context-set-paint-mode 0)
;;ÉTÉCÉYí≤êÆ
    (gimp-text-layer-set-justification text-layer justify)

    (gimp-image-resize img width height 0 0)

    (script-fu-safari-logo-300-alpha img text-layer size type relief grad-type gradient flou flou-r elevation depth conserv trans? bgcolor scolor sblur soff)

    (gimp-selection-none img)
    ;(gimp-context-set-foreground old-fg)
    ;(gimp-context-set-gradient old-grad)
    ;(gimp-context-set-pattern old-pat)
    (gimp-context-pop)

    (gimp-image-undo-enable img)
    (gimp-image-delete img)			;add

))

(script-fu-register "script-fu-safari-logo-300"
		    "Safari 300 LOGO"
		    "safari-logo-300"
		    "Apply by Kiki"
		    "Giants"
		    "2008/4"
		    ""
		SF-TEXT	"Text String"      "Safari"
		SF-ADJUSTMENT	"Font Size (pixels)" '(120 2 1000 1 10 0 1)
		SF-FONT		"Font"             sffont
		  SF-OPTION "Justify" '("Centered" "Left" "Right") 
		SF-OPTION	"Type" '("Cameleon paisible" "Cameleon malade" "Tigre grincheux" "Serpent facetieux" "Himpala harmonieux")
		SF-OPTION	"Relief" '("Simple" "Double")
		SF-OPTION "Gradient type" '("Desert (Shadows 1)" "Jungle (Greens)" "Urban (Four Bars)" "User choice")
		SF-GRADIENT	"Gradient User choice" "Shadows 1"
		SF-ADJUSTMENT	"Bump blur" '(0 0 50 1 10 0 1)
		SF-ADJUSTMENT	"Bump blur (repoussage)" '(15 1 120 1 0 0 1)
		SF-ADJUSTMENT	"Elevation (repoussage)" '(20 1 90 1 0 0 1)
		SF-ADJUSTMENT "Depth" '(3 0 100 1 0 0 1)
		SF-TOGGLE	"Conserver les images et les calques?" FALSE
		SF-TOGGLE "Background Transparent?" FALSE
		SF-COLOR	"Background Color"	'(212 205 192)
		SF-COLOR	"Shadow Color"	'(35 35 35)
		SF-ADJUSTMENT "Shadow blur" '(3 0 100 1 0 0 1)
		SF-ADJUSTMENT "Shadow offset" '(3 0 100 1 0 0 1)
)

(script-fu-menu-register "script-fu-safari-logo-300" "<Image>/Script-Fu/Logos/")
