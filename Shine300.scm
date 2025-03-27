; shine alpha-to-logo rel 0.01
;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove
; Created by Graechan
;
;   
; Comments directed to http://gimpchat.com or http://gimpscripts.com
;
; License: GPLv3
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;    GNU General Public License for more details.
;
;    To view a copy of the GNU General Public License
;    visit: http://www.gnu.org/licenses/gpl.html
;
;
; ------------
;| Change Log |
; ------------ 
; Rel 0.01 - Initial Release 
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

; Fix code for gimp 2.10 working in 2.99.16
(cond ((not (defined? 'gimp-image-set-active-layer)) (define (gimp-image-set-active-layer image drawable) (gimp-image-set-selected-layers image (vector drawable)))))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))
 		
  		(define (remove-color2 img  fond color)(begin
		 (cond((not(defined? 'plug-in-colortoalpha))
		 		     (gimp-drawable-merge-new-filter fond "gegl:color-to-alpha" 0 LAYER-MODE-REPLACE 1.0
"color" color "transparency-threshold" 0 "opacity-threshold" 1)
		)
		(else
(plug-in-colortoalpha RUN-NONINTERACTIVE img fond color)
		))))
		
  (define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))



(define (script-fu-shine300 image drawable
                              shadow-size
							  shadow-opacity
							  shining
							  conserve)
							  

 (let* (
       			(image-layer (if (not (defined? 'gimp-drawable-filter-new))
             (car (gimp-image-get-active-layer image))
	        (car (list (vector-ref (car (gimp-image-get-selected-layers image)) 0)))))
			(width (car (gimp-image-get-width image)))
			(height (car (gimp-image-get-height image)))
			(sel (car (gimp-selection-is-empty image)))
			(img-layer 0)
			(img-channel 0)
			(bkg-layer 0)
			(shadow-layer 0)
			(tmp-layer 0)
        )
		
		
	(gimp-context-push)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
    (gimp-image-undo-group-start image)
    
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	(gimp-layer-add-alpha image-layer)
    (if (= sel TRUE) (gimp-image-select-item image 2 image-layer))
	(set! img-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "img-layer" 100 LAYER-MODE-NORMAL-LEGACY)))
	(gimp-image-insert-layer image img-layer 0 -1)
	(gimp-drawable-fill img-layer  FILL-BACKGROUND)
	(gimp-drawable-edit-fill img-layer FILL-FOREGROUND)
	
;;;;create channel
	(gimp-selection-save image)
	;(set! img-channel (car (gimp-image-get-active-drawable image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! img-channel (vector-ref (car (gimp-image-get-selected-drawables image)) 0))	)
(else (set! img-channel (car (gimp-image-get-active-drawable image)))
	)	)	
	(gimp-channel-set-opacity img-channel 100)	
	(gimp-item-set-name img-channel "img-channel")
	(gimp-image-set-active-layer image img-layer)	
	(gimp-item-set-name image-layer "Original Image")
	
;;;;create the background layer    
	(set! bkg-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
    (gimp-image-insert-layer image bkg-layer 0 1) 

;;;;apply the image effects
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))
	(apply-gauss2 image img-layer 12 12)
		 (cond((not(defined? 'plug-in-emboss))
		 		     (gimp-drawable-merge-new-filter img-layer "gegl:emboss" 0 LAYER-MODE-REPLACE 1.0
"type" "emboss" "azimuth" 225 "elevation" 84 "depth" 10)
		)
		(else
	(plug-in-emboss RUN-NONINTERACTIVE image img-layer 225 84 10 TRUE)))	
	(gimp-selection-invert image)
	(gimp-drawable-edit-clear img-layer)
	(gimp-selection-invert image)
	;(plug-in-colortoalpha RUN-NONINTERACTIVE image img-layer '(254 254 254));;fefefe
	(remove-color2 image img-layer '(254 254 254));;fefefe
	(apply-gauss2 image img-channel 15 15)
	;(plug-in-blur RUN-NONINTERACTIVE image img-layer)
	(apply-gauss2  image img-layer shining shining)
	(gimp-image-set-active-layer image bkg-layer)
	(cond((not(defined? 'plug-in-displace))
          (let* (
                 (filter (car (gimp-drawable-filter-new bkg-layer "gegl:displace" ""))))
            (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                            "amount-x" 8 "amount-y" 8 "abyss-policy" "clamp"
                                            "sampler-type" "cubic" "displace-mode" "cartesian")
            (gimp-drawable-filter-set-aux-input filter "aux" img-channel)
            (gimp-drawable-filter-set-aux-input filter "aux2" img-channel)
            (gimp-drawable-merge-filter bkg-layer filter)
          ))
        (else
(plug-in-displace RUN-NONINTERACTIVE image bkg-layer 8 8 TRUE TRUE img-channel img-channel 1)))
(gimp-image-remove-layer image bkg-layer)
	
;;;;create the shadow
(if (> shadow-size 0)
  (begin
    (apply-drop-shadow image img-layer shadow-size shadow-size shadow-size '(0 0 0) shadow-opacity FALSE)
    ;(set! tmp-layer (car (gimp-layer-new-ng image width height RGBA-IMAGE "temp" 100 LAYER-MODE-NORMAL-LEGACY)))
    ;(gimp-image-insert-layer image tmp-layer 0 -1)
	;(gimp-image-raise-item image tmp-layer)
  ;  (gimp-image-merge-down image tmp-layer CLIP-TO-IMAGE)
	;(set! shadow-layer (car (gimp-image-get-active-drawable image)))
(cond ((defined? 'gimp-image-get-selected-layers) (set! shadow-layer (vector-ref (car (gimp-image-get-selected-drawables image)) 0))	)
(else (set! shadow-layer (car (gimp-image-get-active-drawable image)))
	)	)
	;(gimp-image-lower-item image shadow-layer)
	
   )
 )	

 (if (= conserve FALSE)
    (begin
	(set! img-layer (car (gimp-image-merge-down image img-layer EXPAND-AS-NECESSARY)))
	(set! img-layer (car (gimp-image-merge-down image img-layer EXPAND-AS-NECESSARY)))
	(gimp-item-set-name img-layer "Shined Image")
	)
	)	
;(if (= conserve FALSE) (gimp-image-merge-visible-layers image  EXPAND-AS-NECESSARY))
	(gimp-image-remove-channel image img-channel)
	(gimp-selection-none image)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)
    ;(gimp-display-new image)
	(gimp-displays-flush)

 )
)

(script-fu-register "script-fu-shine300"        		    
                    "Shine300"
                     "Shine the Image (Image must have transparent background)"
                    "Graechan"
                    "Graechan"
                    "1/6/2012"
                    "RGBA"
                    SF-IMAGE      "image"      0
                    SF-DRAWABLE   "drawable"   0
                    SF-ADJUSTMENT "Shadow Size" '(8 0 16 1 10 0 0)
					SF-ADJUSTMENT "Shadow Opacity" '(50 0 100 1 10 0 0)
					SF-ADJUSTMENT "Shining" '(5 0 20 1 10 0 0)
					SF-TOGGLE "Keep layers?" FALSE
)

(script-fu-menu-register "script-fu-shine300" "<Image>/Script-Fu/Alpha-to-Logo/")


