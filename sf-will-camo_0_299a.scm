;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

;;  Camo - This is a script for The GIMP to generate a camouflage pattern
;;  Copyright (C) 2010  William Morrison
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; A helper function to apply one layer of colour
(define (camo-help299 img clr iterations cutoff size)
  (let* ((newlayer 0) (fgcolor 0))
	(set! fgcolor (car (gimp-context-get-foreground)));preserving the foreground colour

 ;; Create the new layer and the mask
	(set! newlayer (car (gimp-layer-new img 1 1 0 "Camo" 100 0 )))
	(gimp-image-insert-layer img newlayer 0 0)
	(gimp-layer-resize-to-image-size newlayer)
	(gimp-context-set-foreground clr)
	(gimp-drawable-fill newlayer 0)
	(gimp-layer-add-mask newlayer (car (gimp-layer-create-mask newlayer 0)))
	
 ;; Generate the basic smooth camo shapes
	(plug-in-solid-noise 1 img (car (gimp-layer-get-mask newlayer)) 0 0 (random 65535) 1 size size)
	(gimp-drawable-equalize (car (gimp-layer-get-mask newlayer)) 0)
	(gimp-drawable-threshold (car (gimp-layer-get-mask newlayer)) HISTOGRAM-VALUE (/ cutoff 255) 1)
;	(gimp-threshold (car (gimp-layer-get-mask newlayer)) cutoff 255)
 ;; Roughen the edges with the Pick filter
	(while (and (> iterations 0) (not (= 0 cutoff)))
	(plug-in-randomize-pick 1 img (car (gimp-layer-get-mask newlayer)) 100 50 1 0)
	(set! iterations (- iterations 1))
	)
	(plug-in-gauss 1 img (car (gimp-layer-get-mask newlayer)) 5 5 0)
	(gimp-drawable-threshold (car (gimp-layer-get-mask newlayer)) HISTOGRAM-VALUE 0.5 1)

 ;; Merge the layer if needed, and restore the foreground colour
	;(if (not (= 0 cutoff)) (gimp-image-merge-down img newlayer 1) ())
	(gimp-context-set-foreground fgcolor)
  )
)

(define (script-fu-camo-299 img opt clr1 use1 clr2 use2 clr3 use3 clr4 use4 clr5 use5 size iterations)
  (let* ((divs 5) (count 0))

  (gimp-image-undo-group-start img)
  ;bovination
  	(if (= opt 1)  (begin  
(define use1 1)
(define use2 0)
(define use3 0)
(define use4 0)
(define use5 1)
(define clr1 '(0 0 0))
(define clr5 '(255 255 255))
)
		)
 ;pizza
  	(if (= opt 2)  (begin 
(define use1 1)
(define use2 0)
(define use3 0)
(define use4 0)
(define use5 1)
(define iterations 0)
;(define size 7)
(define clr1 '(255 255 255))
(define clr5 '(255 0 0))
)
		)
		
;chococream
  	(if (= opt 3)  (begin 
(define use1 1)
(define use2 0)
(define use3 0)
(define use4 0)
(define use5 1)
(define iterations 0)
;(define size 7)
(define clr1 '(241 228 143))
(define clr5 '(43 21 2))
)
		)
		
 ;psychedelic
  	(if (= opt 4)  (begin 
(define use1 1)
(define use2 1)
(define use3 1)
(define use4 1)
(define use5 1)
(define iterations 0)
(define clr1 '(255 0 255))
(define clr2 '(0 44 255))
(define clr3 '(19 255 0))
(define clr4 '(255 255 0))
(define clr5 '(255 0 0))
))

  (set! divs (+ use1 use2 use3 use4 use5)) ; the number of colours being used
  
  ;; Generate the spots for each colour. All the divs and count stuff is for making sure there's an even distriution of colour
  (if (= 1 use1) (camo-help299 img clr1 iterations (- 255 (* (- divs count) (/ 255 divs))) size) (set! count (- count 1)))
  (set! count (+ count 1))
  (if (= 1 use2) (camo-help299 img clr2 iterations (- 255 (* (- divs count) (/ 255 divs))) size) (set! count (- count 1)))
  (set! count (+ count 1))
  (if (= 1 use3) (camo-help299 img clr3 iterations (- 255 (* (- divs count) (/ 255 divs))) size) (set! count (- count 1)))
  (set! count (+ count 1))
  (if (= 1 use4) (camo-help299 img clr4 iterations (- 255 (* (- divs count) (/ 255 divs))) size) (set! count (- count 1)))
  (set! count (+ count 1))
  (if (= 1 use5) (camo-help299 img clr5 iterations (- 255 (* (- divs count) (/ 255 divs))) size) (set! count (- count 1)))
  
  (gimp-image-undo-group-end img)

  ; Update the display
  (gimp-displays-flush)
 )
)

(script-fu-register "script-fu-camo-299"
                    "Camo... 299"
                    "Generates a layer filled with a camouflage pattern. Be aware that roughening the edges can be very slow."
                    "Will Morrison"
                    "GNU General Public License"
                    "2010"
                    "RGB*"
                    SF-IMAGE    "Image"         0
		SF-OPTION		"Color preset"				'("Manual" "Bovination" "Pizza" "Choco Cream" "Psychedelic")
		    SF-COLOR "Color 1" '(136 125 52)               SF-TOGGLE "Use colour 1" 1
                    SF-COLOR "Color 2" '(62 82 22)                 SF-TOGGLE "Use colour 2" 1
                    SF-COLOR "Color 3" '(82 56 11)                 SF-TOGGLE "Use colour 3" 1
                    SF-COLOR "Color 4" '(50 28 0)                  SF-TOGGLE "Use colour 4" 1
                    SF-COLOR "Color 5" '(0 0 0)                    SF-TOGGLE "Use colour 5" 1 
		    SF-ADJUSTMENT "Size" '(5 0.1 16 1 3 1 0)
		    SF-ADJUSTMENT "Roughness" '(1 0 10 1 3 0 0)
)

(script-fu-menu-register "script-fu-camo-299"
                         "<Image>/Filters/Will's Script Pack")
