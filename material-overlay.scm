(define list-material-dir '("Carbon fiber" "Aluminium Brushed" "Aluminium Brushed Light" "Blue Jeans" "Dark Jeans" "Bovination 2.99" "Camouflage 2.99" "Plasma" "Patchwork" "Diffraction" "Pizza"))

		
		(define  (material-carbon fond) (begin
				(gimp-context-set-pattern "Parque #3")
				(gimp-drawable-fill fond FILL-PATTERN)
				(gimp-drawable-desaturate fond 1)
				(gimp-drawable-brightness-contrast fond -0.5 0.15)
			))

			
		(define  (material-bovination-2 fond image) (begin
				(plug-in-solid-noise 0 image fond 0 0 (random 65535) 1 16 4)
					(gimp-drawable-equalize fond 0)
					;	(gimp-drawable-threshold fond HISTOGRAM-VALUE 0 1)

				    ;(gimp-brightness-contrast fond 0 127) ; cambiare!
				    (gimp-drawable-brightness-contrast fond 0 0.5)
				   ;(gimp-drawable-levels fond  0 0.1 0.4 FALSE 0.1 0.1 0.2 FALSE)
				   (gimp-drawable-brightness-contrast fond 0 0.5)
				   (gimp-drawable-brightness-contrast fond 0 0.5)
				   ;(gimp-drawable-levels fond  0 0 0.4 FALSE 0.1 0.1 0.2 FALSE)
				    (gimp-drawable-brightness-contrast fond 0 0.5)
				    (gimp-layer-set-lock-alpha fond TRUE)
				(plug-in-oilify 1 image fond 20 0) 
			))
		(define (material-camo2 fond image) (begin
					(gimp-selection-none image)
					(define color1 '(136 125 52)) 
					(define color2 '(62 82 22))
					(define color3  '(50 28 0))
					;(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
					(gimp-context-set-paint-mode LAYER-MODE-NORMAL)
				(material-bovination-2 fond image)
				(gimp-image-select-color image 0 fond '(255 255 255) )
				(gimp-selection-grow image 2)
				(gimp-context-set-foreground color1 )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-invert image)
				(gimp-context-set-foreground color2 )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-none image)
				(gimp-image-select-color image 0 fond  color1)
				 (gimp-selection-grow image 2)
				(material-bovination-2 fond image)
				(gimp-selection-none image)
				(gimp-image-select-color image 0 fond '(0 0 0) )
				(gimp-selection-grow image 2)
				(gimp-context-set-foreground color1 )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-none image)
				(gimp-image-select-color image 0 fond '(255 255 255))
				(gimp-selection-grow image 2)
				(gimp-context-set-foreground color3 )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				
				(gimp-selection-none image)
				(gimp-layer-set-lock-alpha fond TRUE)
				(plug-in-oilify 1 image fond 20 0) 
			))

		(define  (material-alubrushed fond image) (begin
				(gimp-context-set-pattern "Blue Squares")
				(gimp-drawable-fill fond FILL-PATTERN)
				(gimp-drawable-desaturate fond 1)
				(gimp-drawable-brightness-contrast fond -0.5 0.15)
				(gimp-selection-none image)
				(plug-in-gauss-iir TRUE  image fond 20 TRUE TRUE)
				(plug-in-randomize-hurl 0 image fond 50 50 TRUE 0)
				(plug-in-mblur 0 image fond 0 25 0 0 0)
				(gimp-drawable-colorize-hsl fond 0 0 10 )
				;(script-fu-colorize 0 image fond 959595 1)
			))
		(define  (material-alubrushed-light fond image) (begin
				;(gimp-context-set-gradient "Flare Rays Size 1")
				(gimp-context-set-gradient "Rounded edge")
				(gimp-context-set-gradient-repeat-mode 0)
				(gimp-drawable-edit-gradient-fill 
			fond
			;BLEND-FG-TRANSPARENT
			;LAYER-MODE-NORMAL-LEGACY
			0 ;GRADIENT-LINEAR
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			100
			0
			0 ;FALSE
			0
			0
			(car (gimp-drawable-get-width fond))
			0
		)
			
				(gimp-drawable-desaturate fond 1)
				(gimp-drawable-brightness-contrast fond -0.5 0.15)
				(gimp-selection-none image)
				(plug-in-gauss-iir TRUE  image fond 20 TRUE TRUE)
				(plug-in-randomize-hurl 0 image fond 5 5 TRUE 0)
				(plug-in-mblur 0 image fond 0 25 0 0 0)
				(gimp-drawable-colorize-hsl fond 0 0 10 )
			))
			
					(define  (material-blue-jeans fond image col-opt) (begin
				(gimp-context-set-gradient "Rounded edge")
				(gimp-context-set-gradient-repeat-mode 1)
				(gimp-drawable-edit-gradient-fill 
			fond
			;BLEND-FG-TRANSPARENT
			;LAYER-MODE-NORMAL-LEGACY
			0 ;GRADIENT-LINEAR
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			100
			0
			0 ;FALSE
			0
			0
			5
			5
		)
				(gimp-drawable-brightness-contrast fond -0.5 0.15)
				(plug-in-randomize-hurl 0 image fond 5 5 TRUE 0)
				(gimp-drawable-desaturate fond 1)
				(plug-in-gauss-iir TRUE image fond 3 TRUE TRUE)
				;(gimp-drawable-colorize-hsl fond 230 36 20 )
				
																(if (= col-opt 0) 
				(gimp-drawable-colorize-hsl fond 230 36 20 )
				;(gimp-drawable-brightness-contrast fond 0.0 -0.5)
			
		)
		
																(if (= col-opt 1) 
				;(gimp-drawable-colorize-hsl fond 0 0 0)
				(gimp-drawable-brightness-contrast fond -0.2 0.4)
			
		)
			))
			
					(define (material-plasma fond image)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
             (plug-in-plasma 1 image fond (rand 999999999) 7) ; Add plasma
			))
								(define (material-patchwork fond image)  			(begin
             (plug-in-plasma 1 image fond (rand 999999999) 7) ; Add plasma
	                   (plug-in-cubism 1 image fond 6 10 0)			                   
			))
				(define (material-pizza fond image)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
            
             (material-bovination-2 fond image)
	     (gimp-selection-none image)
	     (gimp-image-select-color image 0 fond '(0 0 0) )
	     (gimp-selection-grow image 3)
	     (gimp-context-set-foreground  '(255 0 0) )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-none image)
				(gimp-layer-set-lock-alpha fond TRUE)
	      (plug-in-oilify 1 image fond 20 0) 
			))
			
		(define (material-diffraction fond image)  			
        (begin  
              (set! *seed* (car (gettimeofday))) ; Random Number Seed From Clock (*seed* is global)
              (random-next)                      ; Next Random Number Using Seed
              (plug-in-diffraction 1 image fond .815 1.221 1.123 (+ .821 (rand 2)) (+ .821 (rand 2)) (+ .974 (rand 2)) .610 .677 .636 .066 (+ 27.126 (rand 20)) (+ -0.437 (rand 1)))              
          ))
			
(define (script-fu-layerfx-material-overlay img
					 drawable
					 color
					 opacity
					 mode
					 merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (layername (car (gimp-item-get-name drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (colorlayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-color") opacity (get-blending-mode mode))))
	 (origmask 0)
	 (alphamask 0)
	)
    (add-over-layer img colorlayer drawable)
    (gimp-layer-set-offsets colorlayer (car drwoffsets) (cadr drwoffsets))
    (gimp-selection-all img)
    ;(gimp-context-set-foreground color)
				(if (= color 0) 
(material-carbon colorlayer)
			
		)
		
		(
    if ( = color 1)
        (material-alubrushed colorlayer img)

)
(
    if ( = color 2)
        (material-alubrushed-light colorlayer img)

)
(
    if ( = color 3)
        (material-blue-jeans colorlayer img 0)

)
(
    if ( = color 4)
        (material-blue-jeans colorlayer img 1)

)

	(if (= color 5) 
(material-bovination-2 colorlayer img)
			
		)
	(if (= color 6) 
(material-camo2 colorlayer img)
			
		)
	(if (= color 7) 
(material-plasma colorlayer img)
			
		)
	(if (= color 8) 
(material-patchwork colorlayer img)
			
		)
		(if (= color 9) 
(material-diffraction colorlayer img)
			
		)
		(if (= color 10) 
		(material-pizza colorlayer img)
		)
    ;(gimp-drawable-edit-fill colorlayer 0)
    (gimp-selection-none img)
    (if (= merge 1)
      (begin
	(set! origmask (car (gimp-layer-get-mask drawable)))
	(if (> origmask -1)
	  (begin
	    (set! origmask (car (gimp-channel-copy origmask)))
	    (gimp-layer-remove-mask drawable 1)
	  )
	)
	(set! alphamask (car (gimp-layer-create-mask drawable 3)))
	(set! colorlayer (car (gimp-image-merge-down img colorlayer 0)))
	(gimp-item-set-name colorlayer layername)
	(gimp-layer-add-mask colorlayer alphamask)
	(gimp-layer-remove-mask colorlayer 0)
	(if (> origmask -1)
	  (gimp-layer-add-mask colorlayer origmask)
	)
      )
      (begin
	(gimp-image-select-item img 2 drawable)
	(if (> (car (gimp-layer-get-mask drawable)) -1)
	  (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
	)
	(set! alphamask (car (gimp-layer-create-mask colorlayer 4)))
	(gimp-layer-add-mask colorlayer alphamask)
	(gimp-layer-remove-mask colorlayer 0)
      )
    )
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)
	
(script-fu-register "script-fu-layerfx-material-overlay"
		    "Material Overlay..."
		    "Overlays a material over a layer."
		    "vitforlinux"
		    "based on Jonathan Stipe work"
		    "January 2022"
		    ""
		    SF-IMAGE		"Image"			0
		    SF-DRAWABLE		"Drawable"		0
		    	SF-OPTION		"Fill with Material"				list-material-dir
		    SF-ADJUSTMENT	"Opacity"		'(100 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"		'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-TOGGLE		"Merge with layer"	FALSE)
(script-fu-menu-register "script-fu-layerfx-material-overlay" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-material-overlay" "<Layers>/Layer Effects By Jon Stipe 299/")
