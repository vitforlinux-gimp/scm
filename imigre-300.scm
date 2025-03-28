;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;;; imigre210-gunya2.scm -*-scheme-*-
;;; Time-stamp: <1997/05/11 18:46:26 narazaki@InetQ.or.jp>
;;; Author: Shuji Narazaki (narazaki@InetQ.or.jp)
; ************************************************************************
; Changed on Feb 4, 1999 by Piet van Oostrum <piet@cs.uu.nl>
; For use with GIMP 1.1.
; All calls to gimp-text-* have been converted to use the *-fontname form.
; The corresponding parameters have been replaced by an SF-FONT parameter.
; ************************************************************************

;;; Comment:
;;;  This is the first font decoration of Imigre-26 (imigre300)
;;; Code:

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
;(gimp-message "30 logo")
  (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

(define (script-fu-imigre300-gunya2 text text-color frame-color font font-size frame-size strength)
  (let* (
        (img (car (gimp-image-new 256 256 RGB)))
        (border (/ font-size 10))
        (text-layer (car (gimp-text-fontname img -1 0 0 text (* border 2)
                                             TRUE font-size PIXELS font)))
        (width (car (gimp-drawable-get-width text-layer)))
        (height (car (gimp-drawable-get-height text-layer)))
        (dist-text-layer (car (gimp-layer-new-ng img width height RGBA-IMAGE
                                              "Distorted text" 100 LAYER-MODE-NORMAL-LEGACY)))
        (dist-frame-layer (car (gimp-layer-new-ng img width height RGBA-IMAGE
                                               "Distorted text" 100 LAYER-MODE-NORMAL-LEGACY)))
        (distortion-img (car (gimp-image-new width height GRAY)))
        (distortion-layer (car (gimp-layer-new-ng distortion-img width height
                                               GRAY-IMAGE "temp" 100 LAYER-MODE-NORMAL-LEGACY)))
        (radius (/ font-size 10))
        (prob 0.5)
        )

    (gimp-context-push)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
;(gimp-message "57 logo")
    (gimp-image-undo-disable img)
    (gimp-image-undo-disable distortion-img)
    (gimp-image-resize img width height 0 0)
    (gimp-image-insert-layer img dist-text-layer 0 -1)
    (gimp-image-insert-layer img dist-frame-layer 0 -1)
    (gimp-image-insert-layer distortion-img distortion-layer 0 -1)
    (gimp-selection-none img)
    (gimp-drawable-edit-clear dist-text-layer)
    (gimp-drawable-edit-clear dist-frame-layer)
    ;; get the text shape
    (gimp-image-select-item img 2 text-layer)
    ;; fill it with the specified color
    (gimp-context-set-foreground text-color)
    (gimp-drawable-edit-fill dist-text-layer FILL-FOREGROUND)
    ;; get the border shape
    (gimp-selection-border img frame-size)
    (gimp-context-set-background frame-color)
    (gimp-drawable-edit-fill dist-frame-layer FILL-BACKGROUND)
    (gimp-selection-none img)
;(gimp-message "77 logo")
    ;; now make the distortion data
    (gimp-context-set-background '(255 255 255))
    (gimp-drawable-edit-fill distortion-layer FILL-BACKGROUND)
    				    (cond((not(defined? 'plug-in-noisify))
		 		     (gimp-drawable-merge-new-filter distortion-layer "gegl:noise-hurl" 0 LAYER-MODE-REPLACE 1.0
"pct-random" 50 "repeat" 1 "seed" 0 ))		    
	(else
    (plug-in-noisify RUN-NONINTERACTIVE distortion-img distortion-layer FALSE prob prob prob 0.0)))
    (apply-gauss2 distortion-img distortion-layer radius strength strength)
    ;(plug-in-c-astretch RUN-NONINTERACTIVE distortion-img distortion-layer)
;(gimp-message "88 logo")
   ; (gimp-drawable-levels-stretch distortion-img)
;(gimp-message "90 logo")
    (apply-gauss2 distortion-img distortion-layer radius strength strength)
;(gimp-message "92 logo")
    ;; OK, apply it to dist-text-layer
;(gimp-message "94 logo")
    	(cond((not(defined? 'plug-in-displace))
          (let* (
                 (filter (car (gimp-drawable-filter-new dist-text-layer "gegl:displace" ""))))
            (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                            "amount-x" radius "amount-y" radius "abyss-policy" "clamp"
                                            "sampler-type" "cubic" "displace-mode" "cartesian")
            (gimp-drawable-filter-set-aux-input filter "aux" distortion-layer)
            (gimp-drawable-filter-set-aux-input filter "aux2" distortion-layer)
            (gimp-drawable-merge-filter dist-text-layer filter)
          ))
        (else
    (plug-in-displace RUN-NONINTERACTIVE img dist-text-layer radius radius 1 1
                      distortion-layer distortion-layer 1)))
;(gimp-message "108 logo")
    ;; make the distortion data once again fro the frame
    (gimp-drawable-edit-fill distortion-layer FILL-BACKGROUND)
    				    (cond((not(defined? 'plug-in-noisify))
		 		     (gimp-drawable-merge-new-filter distortion-layer "gegl:noise-hurl" 0 LAYER-MODE-REPLACE 1.0
"pct-random" 50 "repeat" 1 "seed" 0 ))		    
	(else
    (plug-in-noisify RUN-NONINTERACTIVE distortion-img distortion-layer FALSE prob prob prob 0.0)))
;(gimp-message "116 logo")
    (apply-gauss2 distortion-img distortion-layer radius strength strength)
    ;(plug-in-c-astretch RUN-NONINTERACTIVE distortion-img distortion-layer)
;(gimp-message "119 logo")
  ;  (gimp-drawable-levels-stretch distortion-img)
;(gimp-message "121 logo")
    (apply-gauss2 distortion-img distortion-layer radius strength strength)
    ;; then, apply it to dist-frame-layer
;(gimp-message "124 logo")
    	(cond((not(defined? 'plug-in-displace))
          (let* (
                 (filter (car (gimp-drawable-filter-new dist-frame-layer "gegl:displace" ""))))
            (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                            "amount-x" radius "amount-y" radius "abyss-policy" "clamp"
                                            "sampler-type" "cubic" "displace-mode" "cartesian")
            (gimp-drawable-filter-set-aux-input filter "aux" distortion-layer)
            (gimp-drawable-filter-set-aux-input filter "aux2" distortion-layer)
            (gimp-drawable-merge-filter dist-frame-layer filter)
          ))
        (else
    (plug-in-displace RUN-NONINTERACTIVE img dist-frame-layer radius radius 1 1
                      distortion-layer distortion-layer 1)))
    ;; Finally, clear the bottom layer (text-layer)
    (gimp-selection-all img)
    (gimp-context-set-background '(255 255 255))
    (gimp-drawable-edit-fill text-layer FILL-BACKGROUND)
    ;; post processing
    ;(gimp-image-set-active-layer img dist-text-layer)
    (gimp-selection-none img)
    (gimp-image-undo-enable img)
    (gimp-image-delete distortion-img)
    (gimp-display-new img)

    (gimp-context-pop)
  )
)


(script-fu-register "script-fu-imigre300-gunya2"
  _"Imigre_300..."
  _"Create a logo in a two-color, scribbled text style"
  "Shuji Narazaki"
  "Shuji Narazaki"
  "1997"
  ""
  SF-TEXT     _"Text"               "Imigre 3.0"
  SF-COLOR      _"Text color"         "red"
  SF-COLOR      _"Frame color"        '(0 34 255)
  SF-FONT       _"Font"               "QTSchoolCentury Bold"
  SF-ADJUSTMENT _"Font size (pixels)" '(100 2 1000 1 10 0 1)
  SF-ADJUSTMENT _"Frame size"         '(2 1 20 1 5 0 1)
  SF-ADJUSTMENT _"Strength effect "         '(3 1 20 1 5 0 1)
)

(script-fu-menu-register "script-fu-imigre300-gunya2"
                         "<Image>/File/Create/Logos")
