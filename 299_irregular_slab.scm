;Modernized with ModernizeMatic8 for Gimp 2.10.28 by vitforlinux.wordpress.com - dont remove


; Irregular Slab
;
; Christopher Gutteridge, cjg@ecs.soton.ac.uk
;
; Update/fix for Gimp 2.10.32 and 2.99.16/18 vitforlinux

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))

; Define the function:

(define (script-fu-chris-slabtext inText inFont inFontSize justification letter-spacing line-spacing tcolor tgrad ttexture
                                  inDistressText inDistressSlab inGilt inTextColor
                                  inTextOpacity inBufferAmount inFollowShape
                                  inWoodLook btype inBGColor bgrad bpat)


;2.4追加
  (let (
       (theImageWidth 0)	;0追加：2.6変更
       (theImageHeight 0)
       (theImage 0)
       (theTextLayer 0)
       (theText 0)
       (theImageWidthz 0)
       (theImageHeightz 0)
       	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
       )


              (set! theImageWidth 10)

              (set! theImageHeight 10)

              (set! theImage (car (gimp-image-new theImageWidth theImageHeight RGB) ) )

(gimp-image-undo-disable theImage)

          (set! theTextLayer (car (gimp-layer-new theImage theImageWidth theImageHeight RGBA-IMAGE "Text Layer" 100 LAYER-MODE-NORMAL-LEGACY) ) )
          (gimp-image-insert-layer theImage theTextLayer 0 0)

;追加
	(gimp-context-push)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )

          (gimp-context-set-background '(255 255 255) )
          (gimp-context-set-foreground '(0 0 0) )

          (gimp-selection-all theImage)
	  
          (gimp-drawable-edit-clear theTextLayer)
          (gimp-selection-none theImage)

;          (set! theText (car (gimp-text theImage theTextLayer 0 0 inText 0 TRUE inFontSize PIXELS "misc" "fixed" "medium" "r" "semicondensed" "c" "*" "8")))
(set! theText (car (gimp-text-fontname theImage theTextLayer 0 0 inText (+ 50 inBufferAmount) TRUE inFontSize PIXELS inFont)))

;2.4改変theImageWidthz、theImageHeightz
          (set! theImageWidthz  (car (gimp-drawable-get-width  theText) ) )
          (set! theImageHeightz (car (gimp-drawable-get-height theText) ) )
	      (gimp-text-layer-set-letter-spacing theText letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification theText justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing theText line-spacing)      ; Set Line Spacing    

          (gimp-image-resize theImage theImageWidthz theImageHeightz 0 0)
          (gimp-layer-resize theTextLayer theImageWidthz theImageHeightz 0 0)
          (gimp-floating-sel-anchor theText)
	  (gimp-display-new theImage)
	  (script-fu-chris-irregular-slab theImage theTextLayer inFontSize tcolor tgrad ttexture inDistressText inDistressSlab inGilt inTextColor inTextOpacity inBufferAmount inFollowShape inWoodLook btype inBGColor bgrad bpat)
          
	  (gimp-context-pop)
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
    SF-TEXT      "Text String" "Dr.Dee"
    SF-FONT        "Font" "QTCaligulatype"
    SF-ADJUSTMENT _"Font Size(px)"   '(120 2 1000 1 2 0 1)
    SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill")
    SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
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
	  	  (gimp-layer-resize-to-image-size inSourceLayer)


          (set! theImageWidth  (car (gimp-drawable-get-width  inSourceLayer) ) )
          (set! theImageHeight (car (gimp-drawable-get-height inSourceLayer) ) )
          (set! theBuffer inBufferAmount)
          (set! theInc (max 50 (* theBuffer 4)))
          (set! theImageHeight (+ theImageHeight theInc) )
          (set! theImageWidth  (+ theImageWidth  theInc) )
(gimp-context-push)
(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
(gimp-image-undo-group-start theImage)

        ;  (gimp-image-resize theImage theImageWidth theImageHeight 0 0)
         ; (gimp-layer-resize theSourceLayer theImageWidth theImageHeight 0 0)

         ; (gimp-layer-set-offsets theSourceLayer (/ theInc 2) (/  theInc 2))
          (gimp-image-select-item theImage 2 theSourceLayer)

          (gimp-drawable-edit-clear theSourceLayer)
          (gimp-selection-invert theImage)
          (gimp-drawable-edit-clear theSourceLayer)
          (gimp-selection-invert theImage)
	;  (gimp-image-select-rectangle theImage 0 0 0 1 1) ; plasma fix
	  (if (= inDistress TRUE) 
	  	  	 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)	
	      (script-fu-distress-selection theImage theSourceLayer 127 2 1.5 2 TRUE TRUE)
	      (script-fu-distress-selection theImage (vector theSourceLayer) 0.5 2 1.5 2 TRUE TRUE))
              (plug-in-gauss-iir TRUE theImage theSourceLayer 1 TRUE TRUE) 
	     ; (gimp-image-select-rectangle theImage 0 0 0 1 1) ; plasma fix
          )
          (gimp-context-set-background '(255 255 255) )
          (gimp-context-set-foreground '(0 0 0) )
          (gimp-drawable-edit-fill theSourceLayer FILL-BACKGROUND)
          (gimp-selection-all theImage)


          (set! thePattLayer (car (gimp-layer-new theImage theImageWidth theImageHeight RGBA-IMAGE "Pattern Layer" 100 LAYER-MODE-NORMAL-LEGACY) ) )
          (gimp-image-insert-layer theImage thePattLayer 0 0)
          (gimp-drawable-edit-clear thePattLayer)

          (set! theBumpLayer (car (gimp-layer-new theImage theImageWidth theImageHeight RGBA-IMAGE "BumpMap Layer 1" 100 LAYER-MODE-NORMAL-LEGACY) ) )
	  (gimp-context-set-background '(255 255 255))
          (gimp-image-insert-layer theImage theBumpLayer 0 2)
          (gimp-drawable-edit-fill theBumpLayer FILL-BACKGROUND)

          (gimp-image-select-item theImage 2 theSourceLayer)
          (if (= inFollowShape FALSE)
              (let ( (b (cdr (gimp-selection-bounds theImage))))
                   (gimp-image-select-rectangle 	theImage 
					CHANNEL-OP-REPLACE
                              		(car b) 
					(cadr b) 
					(- (caddr b) (car b)) 
					(- (car (cdddr b)) (cadr b))
					
 					
					)
              )
              ()
          )
         
	  (gimp-selection-grow theImage theBuffer )

          (if (= inDistressSlab TRUE) 
	  	 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)	
	     (script-fu-distress-selection theImage theSourceLayer 127 8 4 
                   (if (= inWoodLook TRUE) 8 2) TRUE (if (= inWoodLook TRUE) FALSE TRUE))
		     (script-fu-distress-selection theImage (vector theSourceLayer) 0.5 8 4 
                   (if (= inWoodLook TRUE) 8 2) TRUE (if (= inWoodLook TRUE) FALSE TRUE)))
             ()
          )
	  (gimp-context-set-background '(0 0 0))
	  (gimp-drawable-edit-fill thePattLayer FILL-BACKGROUND)
          (gimp-drawable-edit-fill theBumpLayer FILL-BACKGROUND)

          (gimp-selection-none theImage)

	  (set! theShadowLayer (car(gimp-layer-copy thePattLayer FALSE)))
          (gimp-item-set-name theShadowLayer "Shadow")
          (gimp-image-insert-layer theImage theShadowLayer 0 3)

	  (set! thePaintLayer (car(gimp-layer-copy thePattLayer FALSE)))
          (gimp-item-set-name thePaintLayer "Paint")
          (gimp-image-insert-layer theImage thePaintLayer 0 0)

          (gimp-image-select-item theImage 2 thePattLayer)
          (gimp-context-set-pattern ttexture)
         ; (gimp-drawable-edit-bucket-fill thePattLayer BUCKET-FILL-PATTERN  100 0 )
	 (gimp-drawable-edit-fill thePattLayer FILL-PATTERN)

          (gimp-selection-none theImage)
	  
          (if (* (/ inFontSize 120) 8) (plug-in-gauss-iir TRUE theImage theShadowLayer (* (/ inFontSize 120) 8) TRUE TRUE))	;changed
          ;(plug-in-autocrop TRUE theImage theShadowLayer)

	  (set! thePaintMask (car(gimp-layer-create-mask thePaintLayer ADD-MASK-ALPHA)))
	  (gimp-layer-add-mask thePaintLayer thePaintMask)
          (gimp-selection-all theImage)
          (gimp-drawable-edit-clear thePaintLayer)
          (gimp-image-select-item theImage 2 theSourceLayer)
	  (if (= TRUE inGilt)
              (begin
	         (gimp-context-set-background tcolor)
                 (gimp-drawable-edit-fill thePaintLayer FILL-BACKGROUND)
;                 (gimp-context-set-gradient "Golden")
                 (gimp-context-set-gradient tgrad)

;;LIGHTEN-ONLY-MODEでgimp-edit-blendを実行するとおかしくなるので変更した

		(set! thenewLayer (car(gimp-layer-new theImage theImageWidth theImageHeight RGB-IMAGE "T Layer" 100 LAYER-MODE-NORMAL-LEGACY)))
;;;;;		(set! thenewLayer (car(gimp-layer-copy thePaintLayer FALSE)))	;;追加
		;(gimp-image-add-layer theImage thenewLayer 0)			;;追加
		       (gimp-image-insert-layer theImage thenewLayer 0 0) ; Add it to image
		(gimp-selection-all theImage)					;;追加
		(gimp-drawable-edit-clear thenewLayer)					;;追加
		(gimp-image-select-item theImage 2 theSourceLayer)			;;追加
                ;(gimp-blend thenewLayer BLEND-CUSTOM LAYER-MODE-LIGHTEN-ONLY-LEGACY 0 100 0 REPEAT-NONE FALSE 0 0 0 TRUE 0 0 theImageWidth theImageHeight)
				      (gimp-drawable-edit-gradient-fill thenewLayer GRADIENT-LINEAR 0 0 1 0 0 0 0  theImageWidth theImageHeight) ; Fill with gradient
		(gimp-layer-set-mode thenewLayer LAYER-MODE-LIGHTEN-ONLY-LEGACY)
;;;;;		(gimp-edit-blend thenewLayer BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY GRADIENT-LINEAR 100 20 REPEAT-NONE FALSE FALSE 0 0 FALSE 
;;;;;	0 0 theImageWidth theImageHeight)
;;;;;		(gimp-layer-set-mode thenewLayer LIGHTEN-ONLY-MODE)		;;追加
		(gimp-layer-add-alpha thenewLayer)				;;追加
		(gimp-selection-invert theImage)				;;追加
		(gimp-drawable-edit-clear thenewLayer)					;;追加
		(set! thePaintLayer (car(gimp-image-merge-down theImage thenewLayer 0)))	;;追加
              )
              (begin
	         (gimp-context-set-background inPaintColor)
                 (gimp-drawable-edit-fill thePaintLayer FILL-BACKGROUND)
              )
          )
          
   
          (gimp-selection-none theImage)


;(gimp-display-new theImage)) (define fish  ()

          (if (> (* (/ inFontSize 120) 2) 1) (plug-in-gauss-iir TRUE theImage theSourceLayer (* (/ inFontSize 120) 2) TRUE TRUE))	;changed
          (gimp-item-set-visible theShadowLayer FALSE)
          (gimp-item-set-visible thePattLayer FALSE)
          (gimp-item-set-visible thePaintLayer FALSE)
          (set! theBumpLayer2 (car(gimp-image-merge-visible-layers theImage 0)))	;2.4改変
	  (gimp-item-set-visible theBumpLayer2 FALSE)
	  (gimp-item-set-visible thePattLayer TRUE)
	  (gimp-item-set-visible thePaintLayer TRUE)
          (gimp-layer-set-opacity thePaintLayer (if (= inGilt TRUE) 97 inPaintOpacity))
          (set! thePattLayer2 (car(gimp-image-merge-visible-layers theImage 0)))	;2.4改変
	  (gimp-item-set-visible theShadowLayer TRUE)
	  
	            (gimp-selection-none theImage)

	(plug-in-bump-map TRUE theImage thePattLayer2 theBumpLayer2 135 45 (+ (* (/ inFontSize 120) 2) 1) 0 0 0 0.50 TRUE TRUE 1 )
	;(plug-in-bump-map TRUE theImage thePattLayer2 theBumpLayer2 135 45 60 0 0 0 0.50 TRUE TRUE 1 )

          (gimp-image-remove-layer theImage theBumpLayer2)
;	  (if (= inBG TRUE)
;              (begin
                 (set! theBackground (car (gimp-layer-new theImage theImageWidth theImageHeight RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY) ) )
                 (gimp-context-set-background inBGColor )
          	 (gimp-selection-all theImage)
                 (gimp-image-insert-layer theImage theBackground 0 2)
                 (gimp-drawable-edit-fill theBackground FILL-BACKGROUND)
  (cond((= btype 1)
    (gimp-context-set-gradient bgrad)
    ;(gimp-edit-blend theBackground BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY 0 1 20 REPEAT-NONE FALSE FALSE 0 0 FALSE 0 0 theImageWidth theImageHeight) QUI!!
(gimp-drawable-edit-gradient-fill theBackground GRADIENT-LINEAR 0 0 1 0 0 0 0  theImageWidth theImageHeight) ; Fill with gradient

    )
    ((= btype 2)
       (gimp-image-select-item theImage 2 theBackground)
       (gimp-context-set-pattern bpat)
       ;(gimp-drawable-edit-bucket-fill theBackground BUCKET-FILL-PATTERN  100 255 )
       	 (gimp-drawable-edit-fill theBackground FILL-PATTERN)

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
	  (gimp-layer-resize-to-image-size theBackground)
(gimp-context-pop)
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
