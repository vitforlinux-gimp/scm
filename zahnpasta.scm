(define (script-fu-zahnpasta-logo text size font fore outl bgcol)

(let* (
  (img (car (gimp-image-new 256 256 RGB)))
  (old-fg (car (gimp-context-get-foreground)))
  (old-bg (car (gimp-context-get-background)))
  (new-fg (gimp-context-set-foreground fore))

  (theTextLayer (car (gimp-text img -1 0 0 text 25 TRUE size PIXELS "*" font "*" "*" "*" "*" "*" "*"))) 
  (theImageWidth (car (gimp-drawable-width theTextLayer)))
  (theImageHeight (car (gimp-drawable-height theTextLayer)))
  (theBgLayer (car (gimp-layer-new img theImageWidth theImageHeight RGBA-IMAGE "Fipsi" 100 NORMAL-MODE)))
  (theOutlineLayer (car (gimp-layer-new img theImageWidth theImageHeight RGBA-IMAGE "Outline" 100 NORMAL-MODE)))
  (theBlurLayer (car (gimp-layer-new img theImageWidth theImageHeight RGBA-IMAGE "Outline" 100 NORMAL-MODE)))
  (theBlur2Layer (car (gimp-layer-new img theImageWidth theImageHeight RGBA-IMAGE "Outline" 100 NORMAL-MODE)))
  (theMerge 0) (theMap 0) )

  (gimp-image-undo-disable img)
  (gimp-image-resize img theImageWidth theImageHeight 0 0) 

  (gimp-drawable-set-name theTextLayer "Text")
  (gimp-drawable-set-name theOutlineLayer "Outline")
  (gimp-drawable-set-name theBlurLayer "Blur")
  (gimp-drawable-set-name theBlur2Layer "Blur2")

  (gimp-image-add-layer img theOutlineLayer 3)
  (gimp-image-add-layer img theBlurLayer 2)
  (gimp-image-add-layer img theBlur2Layer 1)
  (gimp-image-add-layer img theBgLayer 0)

  (gimp-selection-all img)
  (gimp-edit-clear theOutlineLayer)
  (gimp-edit-clear theBlur2Layer)
  (gimp-selection-clear img)

  (gimp-context-set-background '(255 255 255))
  (gimp-context-set-foreground '(0 0 0))

  (gimp-edit-fill theBgLayer 0)
  (gimp-edit-fill theBlurLayer 0)

    (gimp-context-set-foreground '(50 50 50))
    (gimp-context-set-brush "Circle Fuzzy (05)")
    (gimp-selection-layer-alpha theTextLayer)
    (gimp-edit-stroke theBlur2Layer)

    (gimp-selection-layer-alpha theTextLayer)
    (gimp-context-set-foreground outl)
    (gimp-context-set-brush "Circle (19)")
    (gimp-edit-stroke theOutlineLayer)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-context-set-background '(0 0 0))
    (gimp-edit-fill theBlurLayer 0)
    (gimp-edit-stroke theBlurLayer)
    (gimp-selection-clear img)

    (plug-in-gauss-rle 1 img theBlurLayer 5.0 TRUE TRUE)

    (gimp-drawable-set-visible theBlurLayer FALSE)
    (gimp-drawable-set-visible theBlur2Layer FALSE)
    (gimp-drawable-set-visible theBgLayer FALSE)

    (set! theMerge (car (gimp-image-merge-visible-layers img 0)))

    (gimp-drawable-set-visible theBlurLayer TRUE)
    (gimp-drawable-set-visible theBlur2Layer TRUE)
    (gimp-drawable-set-visible theMerge FALSE)
    (gimp-drawable-set-visible theBgLayer FALSE)

    (set! theMap (car (gimp-image-merge-visible-layers img 0)))
    (gimp-drawable-set-visible theMap TRUE)
    (gimp-drawable-set-visible theMerge TRUE)

    (plug-in-bump-map 1 img theMerge theMap 0 55 3 0 0 0 0 TRUE FALSE GRADIENT-LINEAR)
;;    (script-fu-drop-shadow 1 img theMerge "3" "3" "5" '(0 0 0) "0" FALSE)

    (gimp-drawable-set-name theMap "Background")
    (gimp-context-set-foreground bgcol)
    (gimp-edit-fill theMap FOREGROUND-FILL)
    (gimp-image-remove-layer img theBgLayer)

    (gimp-context-set-background old-bg)
    (gimp-context-set-foreground old-fg)
    (gimp-image-undo-enable img)
    (gimp-display-new img)))

(script-fu-register "script-fu-zahnpasta-logo"
                    "Zahnpasta..."
                    "zahnpasta logos"
                    "Stefan Stiasny <sc°oeh.net>"
                    "Stefan Stiasny"
                    "11/08/1998"
                    ""
                    SF-TEXT     "Text"               "Zahnpasta!"
                    SF-ADJUSTMENT "Font size (pixels)" '(150 2 1000 1 10 0 1)
                    SF-FONT       "Font"               "Cooper Black,"
                    SF-COLOR      "Text color"         '(255 0 0)
		    SF-COLOR      "Outline Color"   '(150 0 0)
                    SF-COLOR      "Background Color"   '(0 0 0))

(script-fu-menu-register "script-fu-zahnpasta-logo"
                    "<Image>/File/Create/Logos/")
