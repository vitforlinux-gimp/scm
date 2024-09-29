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
;;;  This is the first font decoration of Imigre-26 (imigre299)
;;; Code:

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sffont "QTSchoolCentury Bold")
  (define sffont "QTSchoolCentury-Bold"))
  
(define (script-fu-imigre299-gunya2 text text-color frame-color font font-size frame-size)
  (let* (
        (img (car (gimp-image-new 256 256 RGB)))
        (border (/ font-size 10))
        (text-layer (car (gimp-text-fontname img -1 0 0 text (* border 2)
                                             TRUE font-size PIXELS font)))
        (width (car (gimp-drawable-get-width text-layer)))
        (height (car (gimp-drawable-get-height text-layer)))
        (dist-text-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                              "Distorted text" 100 LAYER-MODE-NORMAL-LEGACY)))
        (dist-frame-layer (car (gimp-layer-new img width height RGBA-IMAGE
                                               "Distorted text" 100 LAYER-MODE-NORMAL-LEGACY)))
        (distortion-img (car (gimp-image-new width height GRAY)))
        (distortion-layer (car (gimp-layer-new distortion-img width height
                                               GRAY-IMAGE "temp" 100 LAYER-MODE-NORMAL-LEGACY)))
        (radius (/ font-size 10))
        (prob 0.5)
        )

    (gimp-context-push)
    (gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)

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
    ;; now make the distortion data
    (gimp-context-set-background '(255 255 255))
    (gimp-drawable-edit-fill distortion-layer FILL-BACKGROUND)
    (plug-in-noisify RUN-NONINTERACTIVE distortion-img distortion-layer FALSE prob prob prob 0.0)
    (plug-in-gauss-rle RUN-NONINTERACTIVE distortion-img distortion-layer radius 1 1)
    (plug-in-c-astretch RUN-NONINTERACTIVE distortion-img distortion-layer)
    (plug-in-gauss-rle RUN-NONINTERACTIVE distortion-img distortion-layer radius 1 1)
    ;; OK, apply it to dist-text-layer
    (plug-in-displace RUN-NONINTERACTIVE img dist-text-layer radius radius 1 1
                      distortion-layer distortion-layer 1)
    ;; make the distortion data once again fro the frame
    (gimp-drawable-edit-fill distortion-layer FILL-BACKGROUND)
    (plug-in-noisify RUN-NONINTERACTIVE distortion-img distortion-layer FALSE prob prob prob 0.0)
    (plug-in-gauss-rle RUN-NONINTERACTIVE distortion-img distortion-layer radius 1 1)
    (plug-in-c-astretch RUN-NONINTERACTIVE distortion-img distortion-layer)
    (plug-in-gauss-rle RUN-NONINTERACTIVE distortion-img distortion-layer radius 1 1)
    ;; then, apply it to dist-frame-layer
    (plug-in-displace RUN-NONINTERACTIVE img dist-frame-layer radius radius 1 1
                      distortion-layer distortion-layer 1)
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


(script-fu-register "script-fu-imigre299-gunya2"
  _"Imigre-_299..."
  _"Create a logo in a two-color, scribbled text style"
  "Shuji Narazaki"
  "Shuji Narazaki"
  "1997"
  ""
  SF-TEXT     _"Text"               "GIMP 2.99"
  SF-COLOR      _"Text color"         "red"
  SF-COLOR      _"Frame color"        '(0 34 255)
  SF-FONT       _"Font"               sffont
  SF-ADJUSTMENT _"Font size (pixels)" '(100 2 1000 1 10 0 1)
  SF-ADJUSTMENT _"Frame size"         '(2 1 20 1 5 0 1)
)

(script-fu-menu-register "script-fu-imigre299-gunya2"
                         "<Image>/File/Create/Logos")
