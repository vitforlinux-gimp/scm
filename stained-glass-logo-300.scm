;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;************************************************ *********
; Tested with GIMP 2.8 an 2.10.22/30
;************************************************ *********

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

(define (apply-super-logos04-300-effect image logo-layer tsize tspc random blur offset sf ft-color bg-color lwidth bgmosaic flatten)
(let* (
(bump-layer 0)
(v_point 0)
(path-layer 0)
(outline-layer 0)
(width (car (gimp-drawable-get-width logo-layer))) ; logo width
(height (car (gimp-drawable-get-height logo-layer))) ; logo height
(bg-layer (car (gimp-layer-new-ng image width height RGB-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY))) ; background layer
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

(cond((not(defined? 'plug-in-mosaic))
    (gimp-drawable-merge-new-filter bg-layer "gegl:mosaic" 0 LAYER-MODE-REPLACE 1.0
    "tile-type" "hexagons" "tile-size" tsize "tile-height" 4 "tile-neatness" 0.65 "color-variation" 0.2 "color-averaging" TRUE "tile-surface" sf "tile-allow-split" TRUE "tile-spacing" tspc "joints-color" fg-color "light-color" '(1 1 1) "light-dir" 135 "antialiasing" TRUE "seed" 0) 
    )
(else			
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
0)))

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
				    (cond((not(defined? 'plug-in-plasma))
		 		     (gimp-drawable-merge-new-filter logo-layer "gegl:plasma" 0 LAYER-MODE-REPLACE 1.0
"turbulence" 1 "x" 1 "y" 1 "width" width "height" height "seed" random ))		    
	(else
(plug-in-plasma 1 image logo-layer random 7))) ; plasma drawing
    (gimp-image-select-rectangle image 1 0 0 1 1) ; end plasma fix
 (cond((not(defined? 'plug-in-oilify))
    (gimp-drawable-merge-new-filter logo-layer "gegl:oilify" 0 LAYER-MODE-REPLACE 1.0
    "mask-radius" 5 "use-inten" TRUE) )
(else       
    (plug-in-oilify 1 image logo-layer 5 1)))
(gimp-context-set-background fg-color) ; set background color to black
(cond((not(defined? 'plug-in-mosaic))
    (gimp-drawable-merge-new-filter logo-layer "gegl:mosaic" 0 LAYER-MODE-REPLACE 1.0
    "tile-type" "hexagons" "tile-size" tsize "tile-height" 4 "tile-neatness" 0.65 "color-variation" 0.2 "color-averaging" TRUE "tile-surface" sf "tile-allow-split" TRUE "tile-spacing" tspc "joints-color" fg-color "light-color" '(1 1 1) "light-dir" 135 "antialiasing" TRUE "seed" 0) 
    )
(else
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
1)))
(set! v_point (cons-array 8 'byte)) ; adjust brightness and contrast
(set-pt v_point 0 0 0 )
(set-pt v_point 1 0.25098 0.25098 )
(set-pt v_point 2 0.5 0.88627 )
(set-pt v_point 3 1 1 )
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-drawable-curves-spline logo-layer HISTOGRAM-VALUE 8 v_point)
(gimp-drawable-curves-spline logo-layer HISTOGRAM-VALUE v_point))

(gimp-selection-none image)

; draw outline
; Convert text to path
(gimp-image-select-item image 2  bump-layer) ;select text
(if (not (defined? 'gimp-drawable-filter-new))
(plug-in-sel2path 1 image bump-layer)
(plug-in-sel2path 1 image (vector bump-layer))) ;


  (if (not (defined? 'gimp-drawable-filter-new)) 
(gimp-item-set-name (car (gimp-image-get-active-vectors image)) "Path")  
(gimp-item-set-name (vector-ref (car (gimp-image-get-selected-paths image)) 0) "Path")
)
;(gimp-item-set-name (car (gimp-image-get-active-vectors image)) "Path")
;(gimp-item-set-name (aref (cadr (gimp-image-get-selected-vectors image)) 0) "Path")
(gimp-selection-none image)
(set! path-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "Path" 100 LAYER-MODE-NORMAL-LEGACY)))
(gimp-image-insert-layer image path-layer  0 -1 ) ;Add new layer path-layer
(gimp-selection-all image)
(gimp-drawable-edit-clear path-layer)
(gimp-context-set-foreground fg-color)
 
(define brush-array (vector "Circle (05)" "Circle (07)" "Circle (09)" "Circle (11)" "Circle (13)" "Circle (15)" "Circle (17)" "Circle (19)"))
 
; (gimp-context-set-dynamics "Dynamics Off")
;(gimp-context-set-dynamics "Pressure Opacity")
;(gimp-context-enable-dynamics FALSE)
(if  (defined? 'gimp-context-set-dynamics)(gimp-context-set-dynamics "Pressure Opacity")(gimp-context-set-dynamics-name "Pressure Opacity"))
(if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics FALSE))
         (if (not (defined? 'gimp-drawable-filter-new))   
(gimp-context-set-brush "2. Hardness 100")
(gimp-context-set-brush (car (gimp-brush-get-by-name "2. Hardness 100"))))
(gimp-context-set-brush-size lwidth)
(gimp-context-set-brush-spacing 0.1)
;(gimp-path-stroke-current image)
  (if (not (defined? 'gimp-drawable-filter-new))   
 (gimp-drawable-edit-stroke-item path-layer (car (gimp-image-get-active-vectors image)))
 (gimp-drawable-edit-stroke-item path-layer (car (gimp-image-get-path-by-name image "Path")))	)
 
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

	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new outline-layer "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 135 "elevation" 45 "depth" 3
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 1.0
                                      "compensate" TRUE "invert" FALSE "type" "linear"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" outline-layer)
      (gimp-drawable-merge-filter outline-layer filter)
    ))
    (else
(plug-in-bump-map 1 image outline-layer outline-layer 135 45 3 0 0 0 0 1 0 0 )))
 (cond((not(defined? 'plug-in-oilify))
    (gimp-drawable-merge-new-filter outline-layer "gegl:oilify" 0 LAYER-MODE-REPLACE 1.0
    "mask-radius" 2 "use-inten" TRUE) )
(else   
 (plug-in-oilify 1 image outline-layer 2 1)))
 ;(gimp-layer-set-lock-alpha outline-layer TRUE)
 (apply-gauss2 image outline-layer 2 2)
 (gimp-drawable-brightness-contrast outline-layer 0 0.2)
(apply-gauss2 image path-layer blur blur)
(gimp-layer-set-offsets path-layer offset offset)

(gimp-selection-none image) ;no selection
(if (= flatten 1)
 (gimp-image-flatten image) ; image flattening
     

 )(gimp-context-pop)
);end of let*
);end of define
 
(define (script-fu-super-logos04-300-s text size fontname justification letter-spacing line-spacing tsize tspc random blur offset sf col bcol buffer lwidth bgmosaic flatten)
(let*
(
(img 0)
(text-layer 0)
)
(set! img (car (gimp-image-new 256 256 RGB)))
(gimp-context-push)
(gimp-context-set-foreground '(0 0 0) )
(set! text-layer (car (gimp-text-fontname img -1 0 0 text buffer TRUE size PIXELS fontname)))
(gimp-image-undo-disable img)

(gimp-item-set-name text-layer text)
	  (set! justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
(gimp-text-layer-set-justification text-layer justification) ; Text Justification (Rev Value) 
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)  ; Set Letter Spacing
	(gimp-text-layer-set-line-spacing text-layer line-spacing)      ; Set Line Spacing
(apply-super-logos04-300-effect img text-layer tsize tspc random blur offset sf col bcol lwidth bgmosaic flatten) ;FONT EFFECT
(gimp-image-undo-enable img)
	(gimp-context-pop)
(gimp-display-new img)
)
)
 
(define
(set-pt a index x y)
(begin
(vector-set! a (* index 2) x)
(vector-set! a (+ (* index 2) 1) y)
)
)
 
(script-fu-register
"script-fu-super-logos04-300-s" ;Script name
"Stained Glass Logo 300" ;Menu
"Super Logos No.04 beta" ;Description
"RETOUCH-SCRIPT" ;Creator
"copyright 2006, RETOUCH-SCRIPT" ;copyright notice
"Nov 01, 2006" ;date created
""
SF-TEXT"Text" "GIMP 3.0"
SF-ADJUSTMENT "Font size (pixels)" '(150 2 1000 1 10 0 0)
SF-FONT "Font" "QTBookmann Bold"
	    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill")
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
SF-ADJUSTMENT "Tile size" '(20 5 100 1 10 0 0)
SF-ADJUSTMENT "Tile spacing" '(1 1 100 1 10 0 0)
SF-ADJUSTMENT "Random seed" '(1000 0 2000 5 10 0 0)
SF-ADJUSTMENT "Shadow blur" '(3 0 30 1 10 0 0)
SF-ADJUSTMENT "Shadow offset" '(1 0 30 1 10 0 0)
SF-TOGGLE "Surface relief" FALSE
SF-COLOR "Rim color" '(255 255 255)
SF-COLOR "Background color" '(255 255 255)
SF-ADJUSTMENT  "Buffer amount" '(20 0 100 1 10 1 0)
SF-ADJUSTMENT "Line Thickness :-)  " '(5 1 100 1 10 0 0)
SF-TOGGLE "Stained Background" FALSE
SF-TOGGLE "Flatten layers" FALSE


); end of register
(script-fu-menu-register "script-fu-super-logos04-300-s" "<Image>/File/Create/Logos"
  )
