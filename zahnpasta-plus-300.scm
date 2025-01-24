;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))


(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sfbrush '("Pencil Scratch" 1.0 20 0))
  (define sfbrush "Pencil Scratch")	)
  
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
  


(define (script-fu-zahnpasta-plus-300-logo text size font justify  brush brush-size fore outype outl  bgcol)

(let* (
  (img (car (gimp-image-new 256 256 RGB)))
  (old-fg (car (gimp-context-get-foreground)))
  (old-bg (car (gimp-context-get-background)))
  (new-fg (gimp-context-set-foreground fore))
  		 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))

 ; (theTextLayer (car (gimp-text img -1 0 0 text 25 TRUE size PIXELS "*" font "*" "*" "*" "*" "*" "*"))) 
    (theTextLayer (car (gimp-text-fontname img -1 0 0 text 50 TRUE size PIXELS font))) 
  (theImageWidth (car (gimp-drawable-get-width theTextLayer)))
  (theImageHeight (car (gimp-drawable-get-height theTextLayer)))
  (theBgLayer (car (gimp-layer-new-ng img theImageWidth theImageHeight RGBA-IMAGE "Fipsi" 100 LAYER-MODE-NORMAL-LEGACY)))
  (theOutlineLayer (car (gimp-layer-new-ng img theImageWidth theImageHeight RGBA-IMAGE "Outline" 100 LAYER-MODE-NORMAL-LEGACY)))
  (theBlurLayer (car (gimp-layer-new-ng img theImageWidth theImageHeight RGBA-IMAGE "Outline" 100 LAYER-MODE-NORMAL-LEGACY)))
  (theBlur2Layer (car (gimp-layer-new-ng img theImageWidth theImageHeight RGBA-IMAGE "Outline" 100 LAYER-MODE-NORMAL-LEGACY)))
  (theMerge 0) (theMap 0) )

    (gimp-context-push)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
  (gimp-image-undo-disable img)
  (gimp-image-resize img theImageWidth theImageHeight 0 0) 

  (gimp-item-set-name theTextLayer "Text")
  (gimp-item-set-name theOutlineLayer "Outline")
  (gimp-item-set-name theBlurLayer "Blur")
  (gimp-item-set-name theBlur2Layer "Blur2")
  
  (gimp-text-layer-set-justification theTextLayer justify)

  (gimp-image-insert-layer img theOutlineLayer 0 3)
  (gimp-image-insert-layer img theBlurLayer 0 2)
  (gimp-image-insert-layer img theBlur2Layer 0 1)
  (gimp-image-insert-layer img theBgLayer 0 0)

  (gimp-selection-all img)
  (gimp-drawable-edit-clear theOutlineLayer)
  (gimp-drawable-edit-clear theBlur2Layer)
  (gimp-selection-none img)

  (gimp-context-set-background '(255 255 255))
  (gimp-context-set-foreground '(0 0 0))

  (gimp-drawable-edit-fill theBgLayer 0)
  (gimp-drawable-edit-fill theBlurLayer 0)

    (gimp-context-set-foreground '(50 50 50))
   ; (gimp-context-set-brush "Circle Fuzzy (05)") 2. Hardness 100
         (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)   
(gimp-context-set-brush "2. Hardness 025")
(gimp-context-set-brush (car (gimp-brush-get-by-name "2. Hardness 025"))))
(gimp-context-set-brush-size 5)
    (gimp-image-select-item img 2 theTextLayer)
    (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)   
(gimp-edit-stroke theBlur2Layer)
(gimp-drawable-edit-stroke-selection theBlur2Layer))
    

    (gimp-image-select-item img 2 theTextLayer)
    (gimp-context-set-foreground outl)
    (if (= outype 0) )
        (if (= outype 1)  (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE)))
    (if (= outype 2)  (begin (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))(if  (defined? 'gimp-context-set-dynamics)(gimp-context-set-dynamics "Random Color")(gimp-context-set-dynamics-name "Random Color"))))
    (if (= outype 3)  (begin (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))(if  (defined? 'gimp-context-set-dynamics)(gimp-context-set-dynamics "Dynamics Random")(gimp-context-set-dynamics-name "Dynamics Random"))))
    (if (= outype 4)  (begin (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))(if  (defined? 'gimp-context-set-dynamics)(gimp-context-set-dynamics "Confetti")(gimp-context-set-dynamics-name "Confetti"))))

    ;(gimp-context-set-brush "Circle (19)")
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (gimp-context-set-brush (car  brush)) 
  (gimp-context-set-brush   brush)	)
  ;(if (> outype 0)
  (gimp-context-set-brush-size brush-size); )
;(gimp-context-set-brush-size brush-size)
    ;(gimp-drawable-edit-stroke-selection theOutlineLayer)
        (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)   
(gimp-edit-stroke theOutlineLayer)
(gimp-drawable-edit-stroke-selection theOutlineLayer))
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(0 0 0))
    (gimp-drawable-edit-fill theBlurLayer 0)
    (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)   
(gimp-edit-stroke theBlurLayer)
(gimp-drawable-edit-stroke-selection theBlurLayer))
   ; (gimp-drawable-edit-stroke-selection theBlurLayer)
    (gimp-selection-none img)

    (apply-gauss2 img theBlurLayer 5.0 5.0)

    (gimp-item-set-visible theBlurLayer FALSE)
    (gimp-item-set-visible theBlur2Layer FALSE)
    (gimp-item-set-visible theBgLayer FALSE)

    (set! theMerge (car (gimp-image-merge-visible-layers img 0)))

    (gimp-item-set-visible theBlurLayer TRUE)
    (gimp-item-set-visible theBlur2Layer TRUE)
    (gimp-item-set-visible theMerge FALSE)
    (gimp-item-set-visible theBgLayer FALSE)

    (set! theMap (car (gimp-image-merge-visible-layers img 0)))
    (gimp-item-set-visible theMap TRUE)
    (gimp-item-set-visible theMerge TRUE)

	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new theMerge "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 0 "elevation" 55 "depth" 3
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 0.0
                                      "compensate" TRUE "invert" FALSE "type" "linear"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" theMap)
      (gimp-drawable-merge-filter theMerge filter)
    ))
    (else
    (plug-in-bump-map 1 img theMerge theMap 0 55 3 0 0 0 0 TRUE FALSE GRADIENT-LINEAR)))
;;    (script-fu-drop-shadow 1 img theMerge "3" "3" "5" '(0 0 0) "0" FALSE)

    (gimp-item-set-name theMap "Background")
    (gimp-context-set-foreground bgcol)
    (gimp-drawable-edit-fill theMap FILL-FOREGROUND)
    (gimp-image-remove-layer img theBgLayer)

    (gimp-context-set-background old-bg)
    (gimp-context-set-foreground old-fg)
    (gimp-image-undo-enable img)
    (gimp-context-pop)
    (gimp-display-new img)))

(script-fu-register "script-fu-zahnpasta-plus-300-logo"
                    "Zahnpasta PLUS 300..."
                    "zahnpasta logos"
                    "Stefan Stiasny <sc°oeh.net>"
                    "Stefan Stiasny"
                    "11/08/1998"
                    ""
                    SF-TEXT     "Text"               "Zahnpasta\nPlus!"
                    SF-ADJUSTMENT "Font size (pixels)" '(150 2 1000 1 10 0 1)
                    SF-FONT       "Font"               "QTKooper"
		      SF-OPTION "Justify" '("Centered" "Left" "Right")
		                          SF-BRUSH      "Brush"            sfbrush
SF-ADJUSTMENT "Brush Max Size" '(50 1 1000 1 5 0 0)		
                    SF-COLOR      "Text color"         '(255 0 0)
		    		    SF-OPTION "Outline type" '("None - use brush panel" "Single Color" "Random from Gradient" "Dynamics Random" "Confetti")
		    SF-COLOR      "Outline Color"   '(54 255 0)
                    SF-COLOR      "Background Color"   '(0 0 0))

(script-fu-menu-register "script-fu-zahnpasta-plus-300-logo"
                    "<Image>/File/Create/Logos/")
