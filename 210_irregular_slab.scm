
; Irregular Slab
;
; Christopher Gutteridge, cjg@ecs.soton.ac.uk
;
; Update/fix for Gimp 2.10.32 vitforlinux

; Define the function:

(define (script-fu-chris-slabtext inText inFont inFontSize tcolor tgrad ttexture
                                  inDistressText inDistressSlab inGilt inTextColor
                                  inTextOpacity inBufferAmount inFollowShape
                                  inWoodLook btype inBGColor bgrad bpat)


;2.4追加
  (let (
       (theImageWidth 0)	;0追加：2.6変更
       (theImageHeight 0)
       (theImage 0)
       (theTextLayer 0)
       (old-fg 0)
       (old-bg 0)
       (old-grad 0)
       (old-pat 0)
       (theText 0)
       (theImageWidthz 0)
       (theImageHeightz 0)
       )


              (set! theImageWidth 10)

              (set! theImageHeight 10)

              (set! theImage (car (gimp-image-new theImageWidth theImageHeight RGB) ) )

(gimp-image-undo-disable theImage)

          (set! theTextLayer (car (gimp-layer-new theImage theImageWidth theImageHeight RGBA-IMAGE "Text Layer" 100 NORMAL-MODE) ) )
          (gimp-image-add-layer theImage theTextLayer 0)

;追加
          (set! old-fg (car (gimp-palette-get-foreground)))
          (set! old-bg (car (gimp-palette-get-background)))
          (set! old-grad (car (gimp-gradients-get-gradient)))
          (set! old-pat (car (gimp-patterns-get-pattern)))

          (gimp-palette-set-background '(255 255 255) )
          (gimp-palette-set-foreground '(0 0 0) )

          (gimp-selection-all theImage)
          (gimp-edit-clear theTextLayer)
          (gimp-selection-none theImage)

;          (set! theText (car (gimp-text theImage theTextLayer 0 0 inText 0 TRUE inFontSize PIXELS "misc" "fixed" "medium" "r" "semicondensed" "c" "*" "8")))
(set! theText (car (gimp-text-fontname theImage theTextLayer 0 0 inText 0 TRUE inFontSize PIXELS inFont)))

;2.4改変theImageWidthz、theImageHeightz
          (set! theImageWidthz  (car (gimp-drawable-width  theText) ) )
          (set! theImageHeightz (car (gimp-drawable-height theText) ) )

          (gimp-image-resize theImage theImageWidthz theImageHeightz 0 0)
          (gimp-layer-resize theTextLayer theImageWidthz theImageHeightz 0 0)
          (gimp-floating-sel-anchor theText)
	  (gimp-display-new theImage)
	  (script-fu-chris-irregular-slab theImage theTextLayer inFontSize tcolor tgrad ttexture inDistressText inDistressSlab inGilt inTextColor inTextOpacity inBufferAmount inFollowShape inWoodLook btype inBGColor bgrad bpat)

          (gimp-palette-set-foreground old-fg)
          (gimp-palette-set-background old-bg)
          (gimp-gradients-set-gradient old-grad)
          (gimp-patterns-set-pattern old-pat)
          (gimp-selection-none theImage)

(gimp-image-undo-enable theImage)
          (gimp-displays-flush)         ;画像を更新するため

;2.4追加(let)
 )
)

(script-fu-register
    "script-fu-chris-slabtext"
    "Irregular Slab"
    "Applies irregualr slab to some text."
    "Chris Gutteridge"
    "1998, Christopher Gutteridge, ECS Dept. Uni. of Southampton"
    "April 28, 1998"
    ""
    SF-STRING      "Text String" "Dr.Dee"
    SF-FONT        "Font" "Comic Sans MS"
    SF-ADJUSTMENT _"Font Size(px)"   '(120 2 1000 1 2 0 1)
    SF-COLOR       "Text Color"      '(190 190 0)
    SF-GRADIENT    "Gradient"        "Golden"
    SF-PATTERN     "Texture"         "Pine?"
    SF-TOGGLE "Distress Text?" FALSE
    SF-TOGGLE "Distress Slab?" TRUE
    SF-TOGGLE "Gilt?" TRUE
    SF-COLOR "Paint Color (not used if gilt):"   '(0 0 0)
    SF-ADJUSTMENT _"Paint Opacity(not used if gilt)"  '(50 1 100 1 2 0 0)
    SF-ADJUSTMENT _"Buffer Amount"                    '(20 1 150 1 2 0 0)
    SF-TOGGLE "Follow Shape of text?" TRUE
    SF-TOGGLE "Wood Splinter Effect?" FALSE
;    SF-TOGGLE "Add a background?" TRUE
    SF-OPTION     "background mode"            '(_"color" _"gradient" _"pattern")
    SF-COLOR "Background Color:"   '(255 255 255)
    SF-GRADIENT   "Gradient"           "Yellow Orange"
    SF-PATTERN    "Pattern"            "Rain"
;    SF-TOGGLE "Flatten Image?" FALSE

)
(script-fu-menu-register "script-fu-chris-slabtext" "<Image>/Script-Fu/Logos/")

(define (script-fu-chris-irregular-slab inImage inSourceLayer inFontSize tcolor tgrad ttexture inDistress inDistressSlab inGilt inPaintColor inPaintOpacity inBufferAmount inFollowShape inWoodLook btype inBGColor bgrad bpat)

;2.4追加
  (let  (
	(theImage 0)		;0追加：2.6追加
	(theSourceLayer 0)
	(theImageWidth 0)
	(theImageHeight 0)
	(theBuffer 0)
	(theInc 0)
	(theImageHeight 0)
	(theImageWidth 0)
	(thePattLayer 0)
	(theBumpLayer 0)
	(theShadowLayer 0)
	(thePaintLayer 0)
	(thePaintMask 0)
	(thenewLayer 0)
	(thePaintLayer2 0)
	(thePattLayer2 0)
	(theBumpLayer2 0)
	(theBackground 0)
       )

        (set! theImage inImage)
        (set! theSourceLayer inSourceLayer)

          ;(plug-in-autocrop TRUE theImage theSourceLayer)

          (set! theImageWidth  (car (gimp-drawable-width  inSourceLayer) ) )
          (set! theImageHeight (car (gimp-drawable-height inSourceLayer) ) )
          (set! theBuffer inBufferAmount)
          (set! theInc (max 50 (* theBuffer 4)))
          (set! theImageHeight (+ theImageHeight theInc) )
          (set! theImageWidth  (+ theImageWidth  theInc) )

(gimp-image-undo-group-start theImage)

          (gimp-image-resize theImage theImageWidth theImageHeight 0 0)
          ;(gimp-layer-resize theSourceLayer theImageWidth theImageHeight 0 0)

          (gimp-layer-set-offsets theSourceLayer (/ theInc 2) (/  theInc 2))
          (gimp-selection-layer-alpha theSourceLayer)

          (gimp-edit-clear theSourceLayer)
          (gimp-selection-invert theImage)
          (gimp-edit-clear theSourceLayer)
          (gimp-selection-invert theImage)
	  (if (= inDistress TRUE) 
	      (script-fu-distress-selection theImage theSourceLayer 127 2 1.5 2 TRUE TRUE)
              (plug-in-gauss-iir TRUE theImage theSourceLayer 1 TRUE TRUE) 
          )
          (gimp-palette-set-background '(255 255 255) )
          (gimp-palette-set-foreground '(0 0 0) )
          (gimp-edit-fill theSourceLayer BACKGROUND-FILL)
          (gimp-selection-all theImage)


          (set! thePattLayer (car (gimp-layer-new theImage theImageWidth theImageHeight RGBA-IMAGE "Pattern Layer" 100 NORMAL-MODE) ) )
          (gimp-image-add-layer theImage thePattLayer 0)
          (gimp-edit-clear thePattLayer)

          (set! theBumpLayer (car (gimp-layer-new theImage theImageWidth theImageHeight RGBA-IMAGE "BumpMap Layer 1" 100 NORMAL-MODE) ) )
	  (gimp-palette-set-background '(255 255 255))
          (gimp-image-add-layer theImage theBumpLayer 2)
          (gimp-edit-fill theBumpLayer BACKGROUND-FILL)

          (gimp-selection-layer-alpha theSourceLayer)
          (if (= inFollowShape FALSE)
              (let ( (b (cdr (gimp-selection-bounds theImage))))
                   (gimp-rect-select 	theImage 
                              		(car b) 
					(cadr b) 
					(- (caddr b) (car b)) 
					(- (car (cdddr b)) (cadr b))
					CHANNEL-OP-REPLACE
 					FALSE
					0)
              )
              ()
          )
         
	  (gimp-selection-grow theImage theBuffer )

          (if (= inDistressSlab TRUE) 
	     (script-fu-distress-selection theImage theSourceLayer 127 8 4 
                   (if (= inWoodLook TRUE) 8 2) TRUE (if (= inWoodLook TRUE) FALSE TRUE))
             ()
          )
	  (gimp-palette-set-background '(0 0 0))
	  (gimp-edit-fill thePattLayer BACKGROUND-FILL)
          (gimp-edit-fill theBumpLayer BACKGROUND-FILL)

          (gimp-selection-none theImage)

	  (set! theShadowLayer (car(gimp-layer-copy thePattLayer FALSE)))
          (gimp-drawable-set-name theShadowLayer "Shadow")
          (gimp-image-add-layer theImage theShadowLayer 3)

	  (set! thePaintLayer (car(gimp-layer-copy thePattLayer FALSE)))
          (gimp-drawable-set-name thePaintLayer "Paint")
          (gimp-image-add-layer theImage thePaintLayer 0)

          (gimp-selection-layer-alpha thePattLayer)
          (gimp-patterns-set-pattern ttexture)
          (gimp-edit-bucket-fill thePattLayer PATTERN-BUCKET-FILL NORMAL-MODE 100 0 FALSE 0 0)

          (gimp-selection-none theImage)
	  
          (if (* (/ inFontSize 120) 8) (plug-in-gauss-iir TRUE theImage theShadowLayer (* (/ inFontSize 120) 8) TRUE TRUE))	;changed
          (plug-in-autocrop TRUE theImage theShadowLayer)

	  (set! thePaintMask (car(gimp-layer-create-mask thePaintLayer ADD-ALPHA-MASK)))
	  (gimp-layer-add-mask thePaintLayer thePaintMask)
          (gimp-selection-all theImage)
          (gimp-edit-clear thePaintLayer)
          (gimp-selection-layer-alpha theSourceLayer)
	  (if (= TRUE inGilt)
              (begin
	         (gimp-palette-set-background tcolor)
                 (gimp-edit-fill thePaintLayer BACKGROUND-FILL)
;                 (gimp-gradients-set-gradient "Golden")
                 (gimp-gradients-set-gradient tgrad)

;;LIGHTEN-ONLY-MODEでgimp-edit-blendを実行するとおかしくなるので変更した

		(set! thenewLayer (car(gimp-layer-new theImage theImageWidth theImageHeight RGB-IMAGE "T Layer" 100 NORMAL-MODE)))
;;;;;		(set! thenewLayer (car(gimp-layer-copy thePaintLayer FALSE)))	;;追加
		(gimp-image-add-layer theImage thenewLayer 0)			;;追加
		(gimp-selection-all theImage)					;;追加
		(gimp-edit-clear thenewLayer)					;;追加
		(gimp-selection-layer-alpha theSourceLayer)			;;追加
                (gimp-blend thenewLayer BLEND-CUSTOM LAYER-MODE-LIGHTEN-ONLY-LEGACY 0 100 0 REPEAT-NONE FALSE 0 0 0 TRUE 
        0 0 theImageWidth theImageHeight)
;;;;;		(gimp-edit-blend thenewLayer CUSTOM-MODE NORMAL-MODE GRADIENT-LINEAR 100 20 REPEAT-NONE FALSE FALSE 0 0 FALSE 
;;;;;	0 0 theImageWidth theImageHeight)
;;;;;		(gimp-layer-set-mode thenewLayer LIGHTEN-ONLY-MODE)		;;追加
		(gimp-layer-add-alpha thenewLayer)				;;追加
		(gimp-selection-invert theImage)				;;追加
		(gimp-edit-clear thenewLayer)					;;追加
		(set! thePaintLayer (car(gimp-image-merge-down theImage thenewLayer 0)))	;;追加
              )
              (begin
	         (gimp-palette-set-background inPaintColor)
                 (gimp-edit-fill thePaintLayer BACKGROUND-FILL)
              )
          )
          
   
          (gimp-selection-none theImage)


;(gimp-display-new theImage)) (define fish  ()

          (if (> (* (/ inFontSize 120) 2) 1) (plug-in-gauss-iir TRUE theImage theSourceLayer (* (/ inFontSize 120) 2) TRUE TRUE))	;changed
          (gimp-drawable-set-visible theShadowLayer FALSE)
          (gimp-drawable-set-visible thePattLayer FALSE)
          (gimp-drawable-set-visible thePaintLayer FALSE)
          (set! theBumpLayer2 (car(gimp-image-merge-visible-layers theImage 0)))	;2.4改変
	  (gimp-drawable-set-visible theBumpLayer2 FALSE)
	  (gimp-drawable-set-visible thePattLayer TRUE)
	  (gimp-drawable-set-visible thePaintLayer TRUE)
          (gimp-layer-set-opacity thePaintLayer (if (= inGilt TRUE) 97 inPaintOpacity))
          (set! thePattLayer2 (car(gimp-image-merge-visible-layers theImage 0)))	;2.4改変
	  (gimp-drawable-set-visible theShadowLayer TRUE)

	  (plug-in-bump-map TRUE theImage thePattLayer2 theBumpLayer2 135 45 (+ (* (/ inFontSize 120) 2) 1) 0 0 0 0.50 TRUE TRUE 1 )

          (gimp-image-remove-layer theImage theBumpLayer2)
;	  (if (= inBG TRUE)
;              (begin
                 (set! theBackground (car (gimp-layer-new theImage theImageWidth theImageHeight RGBA-IMAGE "Background" 100 NORMAL-MODE) ) )
                 (gimp-palette-set-background inBGColor )
          	 (gimp-selection-all theImage)
                 (gimp-image-add-layer theImage theBackground 2)
                 (gimp-edit-fill theBackground BACKGROUND-FILL)
  (cond((= btype 1)
    (gimp-gradients-set-gradient bgrad)
    (gimp-edit-blend theBackground CUSTOM-MODE NORMAL-MODE 0 100 20 REPEAT-NONE FALSE FALSE 0 0 FALSE 0 0 theImageWidth theImageHeight)
    )
    ((= btype 2)
       (gimp-selection-layer-alpha theBackground)
       (gimp-patterns-set-pattern bpat)
       (gimp-edit-bucket-fill theBackground PATTERN-BUCKET-FILL NORMAL-MODE 100 255 FALSE 0 0)
       (gimp-selection-none theImage)
       ))
;              )
;              ()
;          )
                  

;          (if     (= inFlatten TRUE)
;                  (gimp-image-flatten theImage)
;                  ()
;          )


          (gimp-image-clean-all theImage)
          (gimp-selection-none theImage)

(gimp-image-undo-group-end theImage)
          (gimp-displays-flush)         ;画像を更新するため

;2.4追加(let)
 )
)


; Register the function with the GIMP:

(script-fu-register
    "script-fu-chris-irregular-slab"
    "Irregular Slab Alpha"
    "Embosses the current image (according to it's alpha) onto an irregularly shaped slab in of the current pattern."
    "Chris Gutteridge"
    "1998, Christopher Gutteridge, ECS Dept. Uni. of Southampton"
    "April 28, 1998"
    "RGBA"
    SF-IMAGE "The Image" 0
    SF-DRAWABLE "The Layer" 0
    SF-ADJUSTMENT _"size"    '(120 2 1000 1 2 0 1)
    SF-COLOR       "Text Color"      '(190 190 0)
    SF-GRADIENT    "Gradient"        "Golden"
    SF-PATTERN     "Texture"         "Pine?"
    SF-TOGGLE "Distress Source?" FALSE
    SF-TOGGLE "Distress Slab?" TRUE
    SF-TOGGLE "Gilt?" TRUE
    SF-COLOR "Paint Color:"   '(0 0 0)
    SF-ADJUSTMENT _"Paint Opacity(%)"    '(50 1 100 1 2 0 0)
    SF-ADJUSTMENT _"Buffer Amount"       '(20 1 150 1 2 0 0)
    SF-TOGGLE "Follow Shape of source?" TRUE
    SF-TOGGLE "Wood Splinter Effect?" FALSE
;    SF-TOGGLE "Add a background?" TRUE
    SF-OPTION     "background mode"            '(_"color" _"gradient" _"pattern")
    SF-COLOR "Background Color:"   '(255 255 255)
    SF-GRADIENT   "Gradient"           "Yellow Orange"
    SF-PATTERN    "Pattern"            "Rain"
;    SF-TOGGLE "Flatten Image?" FALSE
)
(script-fu-menu-register "script-fu-chris-irregular-slab" "<Image>/Script-Fu/StencilOps/")