; following Oregonian's tutorial on Double Bump Map
; found at link: http://gimpchat.com/viewtopic.php?f=23&t=12
; author: Tin Tran
; date: 2014
; update and extend 2023 vitforlinux
(define (script-fu-double-bump-map image layer 
              color
			  pattern
			  no-pattern
              grow-distance
			  blur-radius
			  bump-azimuth
			  bump-elevation
			  bump-depth
			  ;shadow settings
			  shadow-offset-X   ;offset x
			  shadow-offset-Y   ;offset y
			  shadow-blur-radius ;blur-radius
			  shadow-color       ;color
	          shadow-opacity     ;opacity
         )
	(let* 
		(
		(dummy-variable-to-make-let-happy 0)
		(image-width)
		(image-height)

		;vectors/paths related variables to create our own path and select it to cut after blur
		(get-vectors-returned-values)
		(vectors-count)
		(vectors-array)
		(current-vector)

		(color-layer)
		(pattern-layer)
		) ;end of variable declaration
		(gimp-context-push)
		(gimp-image-undo-group-start image)                   ;undo-group in one step


		(set! image-width (car (gimp-image-width image)))
		(set! image-height (car (gimp-image-height image)))
		;START
		(gimp-layer-resize-to-image-size layer)
		(gimp-image-select-item image CHANNEL-OP-REPLACE layer)
		(gimp-edit-fill layer WHITE-FILL)

		;grow selection, invert, the create vector path
		(gimp-selection-grow image grow-distance)
		(gimp-selection-invert image)
		(gimp-selection-feather image 2)
		(plug-in-sel2path RUN-NONINTERACTIVE image layer)
		(set! get-vectors-returned-values (gimp-image-get-vectors image))
		(set! vectors-count (car  get-vectors-returned-values))
		(set! vectors-array (cadr get-vectors-returned-values))
		(set! current-vector (aref vectors-array 0))      ;top path, our own created from selection

		;blurs white bump map
		(gimp-selection-none image)
		(plug-in-gauss RUN-NONINTERACTIVE image layer
											blur-radius blur-radius
											1 ;1 RLE or 0 IIR
											)
											
		;creates new colored layer to bump map
		(set! color-layer (car (gimp-layer-new image image-width image-height
							   RGBA-IMAGE "Color" 100 COLOR-MODE)))  ;creates layer
							   	(if (= no-pattern 0) (gimp-layer-set-mode color-layer NORMAL-MODE)) 
		;creates new pattern layer to bump map as well
		(set! pattern-layer (car (gimp-layer-new image image-width image-height
							   RGBA-IMAGE "Pattern" 100 NORMAL-MODE)))  ;creates layer
		;insert above current layer  
		(gimp-image-insert-layer image color-layer 0 (car (gimp-image-get-item-position image layer)))
		(gimp-image-insert-layer image pattern-layer 0 (car (gimp-image-get-item-position image layer)))
		
		;fill color layer with color
		;(gimp-image-set-active-layer image color-layer)
		(gimp-selection-all image)
		(gimp-context-set-foreground color)
		(gimp-edit-fill color-layer FOREGROUND-FILL)
		
		;fill pattern layer with pattern
		;(gimp-image-set-active-layer image pattern-layer)
		(gimp-selection-all image)
		(gimp-context-set-pattern pattern)
		(gimp-edit-fill pattern-layer PATTERN-FILL)
			
		
		;perform bump map 1st time (color layer)
		(plug-in-bump-map 1 image color-layer layer 
							  bump-azimuth ;Azimuth
							  bump-elevation  ;Elevation
							  bump-depth  ;Depth
							  0   ;X-offset
							  0   ;Y-offset
							  0   ;water level
							  0   ;ambient
							  TRUE ;compensate for darkening
							  FALSE ;invert
							  0    ;type of map LINEAR (0), SPHERICAL (1), SINUSOIDAL (2)
		)
		;perform bump map 1st time (pattern layer)
		(plug-in-bump-map 1 image pattern-layer layer 
							  bump-azimuth ;Azimuth
							  bump-elevation  ;Elevation
							  bump-depth  ;Depth
							  0   ;X-offset
							  0   ;Y-offset
							  0   ;water level
							  0   ;ambient
							  TRUE ;compensate for darkening
							  FALSE ;invert
							  0    ;type of map LINEAR (0), SPHERICAL (1), SINUSOIDAL (2)
		)

		;cut out color layer using previously created path
		(gimp-image-select-item image CHANNEL-OP-REPLACE current-vector)
		(gimp-edit-cut color-layer)
		(gimp-selection-none image)
		;cur out pattern layer using previously created path
		(gimp-image-select-item image CHANNEL-OP-REPLACE current-vector)
		(gimp-edit-cut pattern-layer)
		(gimp-selection-none image)
		
		;delete current-vector
		(gimp-image-remove-vectors image current-vector)
				
		;bump map 2nd time (color layer)
		(plug-in-bump-map 1 image color-layer layer 
							  bump-azimuth ;Azimuth
							  bump-elevation  ;Elevation
							  bump-depth  ;Depth
							  0   ;X-offset
							  0   ;Y-offset
							  0   ;water level
							  0   ;ambient
							  TRUE ;compensate for darkening
							  FALSE ;invert
							  0    ;type of map LINEAR (0), SPHERICAL (1), SINUSOIDAL (2)
		)
        ;bump map 2nd time (pattern layer)
		(plug-in-bump-map 1 image pattern-layer layer 
							  bump-azimuth ;Azimuth
							  bump-elevation  ;Elevation
							  bump-depth  ;Depth
							  0   ;X-offset
							  0   ;Y-offset
							  0   ;water level
							  0   ;ambient
							  TRUE ;compensate for darkening
							  FALSE ;invert
							  0    ;type of map LINEAR (0), SPHERICAL (1), SINUSOIDAL (2)
		)
		;drops shadow of color-layer
		(script-fu-drop-shadow image pattern-layer
								   shadow-offset-X   ;offset x
								   shadow-offset-Y   ;offset y
								   shadow-blur-radius ;blur-radius
								   shadow-color       ;color
								   shadow-opacity     ;opacity
								   TRUE ;allow resizing
		)
	  ;DONE
	  
	
	(gimp-image-undo-group-end image)                     ;undo group in one step
	(gimp-context-pop)
	(gimp-displays-flush)
	) ;end of let*
) ;end of define

(script-fu-register
  "script-fu-double-bump-map"         ;function name
  "Double Bump Map"    ;menu register
  "Creates Double Bump Map effect on your art/text/shapes."       ;description
  "Tin Tran"                          ;author name
  "copyright info and description"         ;copyright info or description
  "2014"                          ;date
  "RGB*, GRAY*"                        ;mode
  SF-IMAGE      "Image" 0                   
  SF-DRAWABLE   "Layer" 0
  SF-COLOR      "Solid Color"          '(0 129 229)
  SF-PATTERN    "Pattern" (car (gimp-context-get-pattern))
  SF-TOGGLE     "Use Pattern instead of solid color" TRUE
  SF-ADJUSTMENT "Grow Distance(from border to cut)" '(2 0 100 1 10 0 0)
  SF-ADJUSTMENT "Bump Map Blur Radius"             '(3 0 100 1 10 0 0)
  SF-ADJUSTMENT "Bump Azimuth"             '(135 0 360 1 10 0 0)
  SF-ADJUSTMENT "Bump Elevation"           '(33 0 100 1 10 0 0)
  SF-ADJUSTMENT "Bump Depth"               '(35 0 100 1 10 0 0)
  
  SF-ADJUSTMENT "Shadow Offset X" '(4 0 100 1 10 0 0)
  SF-ADJUSTMENT "Shadow Offset Y" '(4 0 100 1 10 0 0)
  SF-ADJUSTMENT "Shadow Blur Radius" '(15 0 100 1 10 0 0)
  SF-COLOR      "Shadow Color"     '(0 0 0)
  SF-ADJUSTMENT "Shadow Opacity"   '(60 0 100 1 10 0 0)
  
)

(script-fu-menu-register "script-fu-double-bump-map" "<Image>/Script-Fu/Alpha-to-Logo/")


  (script-fu-register
            "script-fu-double-bump-text"                        ;function name
            "Double Bumped Text"                                  ;menu label
            "Creates a text, with double bump effect,\
              font, font size, and color pattern, grow/shrink and outline, "              ;description
            "Michael Terry"                             ;author
            "copyright 2023, vitforlinux;\
              2009, the GIMP Documentation Team"        ;copyright notice
            "May 12, 2023"                          ;date created
            ""                              ;image type that the script works on
            SF-TEXT      "Text"          "Double Bumped Text"   ;a string variable
            SF-FONT        "Font"          "Ubuntu Bold"    ;a font variable
            SF-ADJUSTMENT  "Font size"     '(150 1 1000 1 10 0 0)
                                                        ;a spin-button
							SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
SF-ADJUSTMENT  "Letter Spacing"        '(0 -50 50 1 5 0 0)
SF-ADJUSTMENT  "Line Spacing"          '(-5 -300 300 1 10 0 0)
          SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
	  SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
	      SF-COLOR      "Solid Color"          '(0 129 229)
  SF-PATTERN    "Pattern" (car (gimp-context-get-pattern))
  SF-TOGGLE     "Use Pattern instead of solid color" TRUE
  SF-COLOR      "Background Color"          '(255 255 255)
  SF-ADJUSTMENT "Grow Distance(from border to cut)" '(2 0 100 1 10 0 0)
  SF-ADJUSTMENT "Bump Map Blur Radius"             '(3 0 100 1 10 0 0)
  SF-ADJUSTMENT "Bump Azimuth"             '(135 0 360 1 10 0 0)
  SF-ADJUSTMENT "Bump Elevation"           '(33 0 100 1 10 0 0)
  SF-ADJUSTMENT "Bump Depth"               '(35 0 100 1 10 0 0)
  
  SF-ADJUSTMENT "Shadow Offset X" '(4 0 100 1 10 0 0)
  SF-ADJUSTMENT "Shadow Offset Y" '(4 0 100 1 10 0 0)
  SF-ADJUSTMENT "Shadow Blur Radius" '(15 0 100 1 10 0 0)
  SF-COLOR      "Shadow Color"     '(0 0 0)
  SF-ADJUSTMENT "Shadow Opacity"   '(60 0 100 1 10 0 0)
            SF-ADJUSTMENT  "Buffer amount" '(35 3 100 1 10 1 0)
                                                        ;a slider
	SF-TOGGLE     "Flatten" TRUE
  )
  (script-fu-menu-register "script-fu-double-bump-text" "<Image>/Script-Fu/Logos/")
  (define (script-fu-double-bump-text inText inFont inFontSize  justification letter-spacing line-spacing grow-text outline color pattern  no-pattern bgcolor grow-distance blur-radius bump-azimuth bump-elevation  bump-depth  shadow-offset-X  shadow-offset-Y  shadow-blur-radius  shadow-color  shadow-opacity     inBufferAmount flatten)
    (let*
      (
        ; define our local variables
        ; create a new image:
        (theImageWidth  10)
        (theImageHeight 10)
        (theImage)
        (theImage
                  (car
                      (gimp-image-new
                        theImageWidth
                        theImageHeight
                        RGB
                      )
                  )
        )
        (theText)             ;a declaration for the text
        (theBuffer)           ;create a new layer for the image
        (theLayer
                  (car
                      (gimp-layer-new
                        theImage
                        theImageWidth
                        theImageHeight
                        RGB-IMAGE
                        "layer 1"
                        100
                        LAYER-MODE-NORMAL
                      )
                  )
        )
	  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))	 
      ) ;end of our local variables
      (gimp-image-insert-layer theImage theLayer 0 0)
      (gimp-context-set-background bgcolor )
      (gimp-context-set-foreground color)
      (gimp-drawable-fill theLayer BACKGROUND-FILL)
      (set! theText
                    (car
                          (gimp-text-fontname
                          theImage theLayer
                          0 0
                          inText
                          0
                          TRUE
                          inFontSize PIXELS
                          inFont)
                      )
        )
      (set! theImageWidth   (car (gimp-drawable-width  theText) ) )
      (set! theImageHeight  (car (gimp-drawable-height theText) ) )
      (set! theBuffer (* theImageHeight (/ inBufferAmount 100) ) )
      (set! theImageHeight (+ theImageHeight theBuffer theBuffer) )
      (set! theImageWidth (+ theImageWidth theBuffer theBuffer) )
      ;;;;centre text on line
	;(gimp-text-layer-set-justification theText 2)
	      (gimp-text-layer-set-letter-spacing theText letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification theText justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing theText line-spacing)      ; Set Line Spacing   
      (gimp-image-resize theImage theImageWidth theImageHeight 0 0)
      (gimp-layer-resize theLayer theImageWidth theImageHeight 0 0)



      (gimp-layer-set-offsets theText theBuffer theBuffer)
      (gimp-floating-sel-to-layer theText)
;;;; shrink grow text
(cond ((> grow-text 0)
	(gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-grow theImage (round grow-text)) 
        (gimp-selection-feather theImage 2 )	
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-drawable-edit-clear theText)
	(gimp-selection-shrink theImage (- grow-text))
(gimp-selection-feather theImage 2 )		
	(gimp-drawable-edit-fill theText FILL-FOREGROUND)	
 ))
   ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none theImage)
	(gimp-image-select-item theImage 2 theText)
	(gimp-selection-feather theImage 2 )
	(gimp-selection-shrink theImage (round outline)) 
(gimp-selection-feather theImage 2 )	
	(gimp-drawable-edit-clear theText)
	(gimp-image-select-item theImage 2 theText)
 ))
      (gimp-layer-resize-to-image-size theText)
      (gimp-display-new theImage)
                  (script-fu-double-bump-map theImage theText 
              color
			  pattern
			  no-pattern
              grow-distance
			  blur-radius
			  bump-azimuth
			  bump-elevation
			  bump-depth
			  ;shadow settings
			  shadow-offset-X   ;offset x
			  shadow-offset-Y   ;offset y
			  shadow-blur-radius ;blur-radius
			  shadow-color       ;color
	          shadow-opacity     ;opacity
         )

	 (gimp-selection-none theImage)
	
	(gimp-layer-resize-to-image-size theLayer)
	(if (= flatten 1) (gimp-image-merge-visible-layers theImage 0)) 
      (list theImage theLayer theText)
    (gimp-display-new theImage)
    )
  )
