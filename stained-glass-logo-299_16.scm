;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;************************************************ *********
; Tested with GIMP 2.8 an 2.10.22/30
;************************************************ *********

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

(define (apply-super-logos04-effect image logo-layer tsize tspc random blur offset sf ft-color bg-color lwidth bgmosaic flatten)
(let* (
(bump-layer 0)
(v_point 0)
(path-layer 0)
(outline-layer 0)
(width (car (gimp-drawable-get-width logo-layer))) ; logo width
(height (car (gimp-drawable-get-height logo-layer))) ; logo height
(bg-layer (car (gimp-layer-new image width height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY))) ; background layer
(fg-color '(0 0 0)) ) ; foreground color=black
; (bg-color '(20 20 20)) ) ;background color=white

    (gimp-context-push)
		(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )

; Image resizing and background layer creation
(gimp-image-insert-layer image bg-layer 0 1) ;Add background layer under logo-layer
(gimp-image-resize-to-layers image) ;Resize image to layers
(gimp-selection-none image) ;no selection
(gimp-context-set-background bg-color) ; background mosaic color
(gimp-drawable-edit-fill bg-layer FILL-BACKGROUND) ; Fill background layer with background mosaic color

				(if (= bgmosaic 1) 

			
(plug-in-mosaic 1 image bg-layer ; mosaic drawing
tsize
4
tspc
0.65
1
135
0.2
1
1
1
0
0)

	) ; 
; Create image for bump map
(set! bump-layer (car(gimp-layer-copy logo-layer 1))) ; copy logo-layer
;(gimp-item-set-name bump-layer "bump")
(gimp-image-insert-layer image bump-layer 0 -1) ;Add bump-layer to Top
(gimp-image-raise-item-to-top image bump-layer)
(gimp-item-set-name bump-layer "Text")

; Plasma/mosaic drawing on text
(gimp-image-select-item image 2  logo-layer) ; AlphaChanel to SelecdtionMask
    (gimp-image-select-rectangle image 0 0 0 1 1) ; plasma fix
(plug-in-plasma 1 image logo-layer random 7) ; plasma drawing
    (gimp-image-select-rectangle image 1 0 0 1 1) ; end plasma fix
    (plug-in-oilify 1 image logo-layer 5 1)
(gimp-context-set-background fg-color) ; set background color to black
(plug-in-mosaic 1 image logo-layer ; mosaic drawing
tsize
4
tspc
0.65
1
135
0.2
1
1
1
sf
1)
(set! v_point (cons-array 8 'byte)) ; adjust brightness and contrast
(set-pt v_point 0 0 0 )
(set-pt v_point 1 0.25098 0.25098 )
(set-pt v_point 2 0.5 0.88627 )
(set-pt v_point 3 1 1 )
(gimp-drawable-curves-spline logo-layer HISTOGRAM-VALUE 8 v_point)
(gimp-selection-none image)

; draw outline
; Convert text to path
(gimp-image-select-item image 2  bump-layer) ;select text
(plug-in-sel2path 1 image bump-layer) ;
(cond ((defined? 'gimp-image-get-selected-vectors) (gimp-item-set-name (aref (cadr (gimp-image-get-selected-vectors image)) 0) "Path"))
(else (gimp-item-set-name (car (gimp-image-get-active-vectors image)) "Path"))
)
;(gimp-item-set-name (car (gimp-image-get-active-vectors image)) "Path")
;(gimp-item-set-name (aref (cadr (gimp-image-get-selected-vectors image)) 0) "Path")
(gimp-selection-none image)
(set! path-layer (car (gimp-layer-new image width height RGBA-IMAGE "Path" 100 LAYER-MODE-NORMAL-LEGACY)))
(gimp-image-insert-layer image path-layer  0 -1 ) ;Add new layer path-layer
(gimp-selection-all image)
(gimp-drawable-edit-clear path-layer)
(gimp-context-set-foreground fg-color)
 
(define brush-array (vector "Circle (05)" "Circle (07)" "Circle (09)" "Circle (11)" "Circle (13)" "Circle (15)" "Circle (17)" "Circle (19)"))
 
; (gimp-context-set-dynamics "Dynamics Off")
(gimp-context-set-dynamics "Pressure Opacity")
;(gimp-context-enable-dynamics FALSE)
         (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)   
(gimp-context-set-brush "2. Hardness 100")
(gimp-context-set-brush (car (gimp-brush-get-by-name "2. Hardness 100"))))
(gimp-context-set-brush-size lwidth)
(gimp-context-set-brush-spacing 0.1)
;(gimp-path-stroke-current image)
  (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)   
 (gimp-drawable-edit-stroke-item path-layer (car (gimp-image-get-active-vectors image)))
 (gimp-drawable-edit-stroke-item path-layer (car (gimp-image-get-vectors-by-name image "Path")))	)
 
(set!  outline-layer (car(gimp-layer-copy path-layer 1)))
(gimp-image-insert-layer image outline-layer 0 0)
(gimp-item-set-name outline-layer "Outline")
 
(gimp-item-set-visible bump-layer 0)

(gimp-context-set-background ft-color) ;Text border color
(gimp-image-select-item image 2  outline-layer) ;select non-transparent
;(gimp-edit-blend outline-layer ; drawable
;BLEND-FG-BG-RGB ;blend_mode
;LAYER-MODE-NORMAL-LEGACY ;paint_mode
;GRADIENT-SHAPEBURST-SPHERICAL ;gradient_type
;100             ;opacity
;0               ;offset
;REPEAT-NONE     ;repeat
;TRUE            ;reverse
;FALSE           ;supersample
;0               ;max_depth(supersample)
;0               ;threshold(supersample)
;TRUE            ;dither
;width
;height
;(+ width 20)
;height)
(gimp-context-set-gradient-fg-bg-rgb)
(gimp-context-set-gradient-reverse TRUE)
				(gimp-drawable-edit-gradient-fill 
			outline-layer
			;BLEND-FG-TRANSPARENT
			;LAYER-MODE-NORMAL-LEGACY
			7 ;GRADIENT-SHAPEBURST-SPHERICAL
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			1
			0
			0 ;FALSE
width
height
(+ width 20)
height
		)


(gimp-selection-none image) ;deselection

(plug-in-bump-map 1 image outline-layer outline-layer 135 45 3 0 0 0 0 1 0 0 )
 (plug-in-oilify 1 image outline-layer 2 1)
 ;(gimp-layer-set-lock-alpha outline-layer TRUE)
 (plug-in-gauss-iir2 1 image outline-layer 2 2)
 (gimp-drawable-brightness-contrast outline-layer 0 0.2)
(plug-in-gauss-iir2 1 image path-layer blur blur)
(gimp-layer-set-offsets path-layer offset offset)

(gimp-selection-none image) ;no selection
(if (= flatten 1)
 (gimp-image-flatten image) ; image flattening
 )
);end of let*
);end of define
 
(define (script-fu-super-logos04s text size fontname tsize tspc random blur offset sf col bcol lwidth bgmosaic flatten)
(let*
(
(img 0)
(text-layer 0)
)
(set! img (car (gimp-image-new 256 256 RGB)))
(gimp-context-set-foreground '(0 0 0) )
(set! text-layer (car (gimp-text-fontname img -1 0 0 text 10 TRUE size PIXELS fontname)))
(gimp-image-undo-disable img)
(gimp-item-set-name text-layer text)
(apply-super-logos04-effect img text-layer tsize tspc random blur offset sf col bcol lwidth bgmosaic flatten) ;FONT EFFECT
(gimp-image-undo-enable img)
	(gimp-context-pop)
(gimp-display-new img)
)
)
 
(define
(set-pt a index x y)
(begin
(aset a (* index 2) x)
(aset a (+ (* index 2) 1) y)
)
)
 
(script-fu-register
"script-fu-super-logos04s" ;Script name
"Stained Glass Logo" ;Menu
"Super Logos No.04 beta" ;Description
"RETOUCH-SCRIPT" ;Creator
"copyright 2006, RETOUCH-SCRIPT" ;copyright notice
"Nov 01, 2006" ;date created
""
SF-STRING "Text" "GIMP 2.99.18"
SF-ADJUSTMENT "Font size (pixels)" '(150 2 1000 1 10 0 0)
SF-FONT "Font" "Sans Bold"
SF-ADJUSTMENT "Tile size" '(20 5 100 1 10 0 0)
SF-ADJUSTMENT "Tile spacing" '(1 1 100 1 10 0 0)
SF-ADJUSTMENT "Random seed" '(1000 0 2000 5 10 0 0)
SF-ADJUSTMENT "Shadow blur" '(3 0 30 1 10 0 0)
SF-ADJUSTMENT "Shadow offset" '(1 0 30 1 10 0 0)
SF-TOGGLE "Surface relief" FALSE
SF-COLOR "Rim color" '(255 255 255)
SF-COLOR "Background color" '(255 255 255)
SF-ADJUSTMENT "Line Thickness :-)  " '(5 1 100 1 10 0 0)
SF-TOGGLE "Stained Background" FALSE
SF-TOGGLE "Flatten layers" FALSE


); end of register
(script-fu-menu-register "script-fu-super-logos04s" "<Image>/File/Create/Logos"
  )
