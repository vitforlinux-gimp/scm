;
;	File > Create > Logos > Polished Plastic Fu
;	Filters > Alpha to Logo > Polished Plastic Fu
;
; origine : http://www.lefinnois.net/wp/index.php/2007/10/29/mise-a-jour-des-script-fu-pour-the-gimp-24/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; plasticlogo.scm
; Version 0.8 (For The Gimp 2.0 and 2.2)
; A Script-Fu that create a Polished Plastic Text or Shape
;
; Copyright (C) 2004-2007 Denis Bodor <lefinnois@lefinnois.net>
;
; This program is free software; you can redistribute it and/or 
; modify it under the terms of the GNU General Public License   
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
;
;299d update for gimp 2.99.3 by viforlinux.wordpress.com
;299k added text alignment functions transparence, and materials carbon fiber, aluminium, jeans, bovination, camouflage
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define list-blend-ppf-dir '("Top-Botton" "Bottom-Top" "Left-Right" "Right-Left" "Diag-Top-Left" "Diag-Top-Right" "Diag-Bottom-Left" "Diag-Bottom-Right" "Diag-to-center" "Diag-from-center" "Center-to-Top center" "Center-to-Bottom center" ))
(define list-fill-ppf-dir '("Color" "Pattern" "Gradient" "None" "Aluminium Brushed" "Aluminium Brushed Light" "Blue Jeans" "Washed Jeans" "Dark Jeans" "Carbon fiber"  "Bovination" "Camouflage 1" "Camouflage 2" "Plasma"  "Patchwork" "Diffraction" "Pizza" "Leopard" "Giraffe" "Zebra" "Leopard 2 colors" "Snake" "Snake 2 colors" "Pois 2 colors" "Squares 2 colors" "Emap gradient" "Pijama gradient Horiz" "Pijama gradient 45" "Pijama gradient Vert" "Will Wood" "Steampunk Brass" "Steampunk Color" "Grunge Green" "Grunge Color" "Stripes Horiz" "Stripes 45" "Stripes Vert" "material gradient"))
(define list-effect-ppf-dir '("None" "Blur" "Oilify" "Cubism" "Ripple" "Bump with pattern" "Desaturate & Chrome"  "Desaturate+Chrome+Color LIGHTEN ONLY" "Desaturate+Chrome+Color MULTILPLY"  "Desaturate+Chrome+Color OVERLAY" "Desaturate+Color  LIGHTEN ONLY" "Desaturate+Color MULTILPLY" "Desaturate+Color OVERLAY" "Stained Glass" "Glitter"))


; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))


(cond ((not (defined? 'gimp-context-set-pattern-ng)) (define (gimp-context-set-pattern-ng value) 
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-pattern value)
				(gimp-context-set-pattern (car (gimp-pattern-get-by-name value)))
				))))

(cond ((not (defined? 'gimp-context-set-gradient-ng)) (define (gimp-context-set-gradient-ng value) 
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient value)
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name value)))
				))))
				
;scaled pattern fill procedure
(define (scaled-pattern-fill image drawable pattern scale)
  (let* (
	      (width (car (gimp-pattern-get-info pattern)))
          (height (cadr (gimp-pattern-get-info pattern)))
		  (pat-img (car (gimp-image-new (* 5 width) (* 5 height) RGB)))
		  (pat-layer (car (gimp-layer-new pat-img (* 5 width) (* 5 height) RGBA-IMAGE "Pattern" 100 LAYER-MODE-NORMAL-LEGACY)))
		  (new-width (* (/ (* 5 width) 100) scale))
		  (new-height (* (/ (* 5 height) 100) scale))
		  )
	(gimp-image-insert-layer pat-img pat-layer 0 0)
	(gimp-context-set-pattern pattern)
	(gimp-drawable-fill pat-layer FILL-PATTERN)
	(gimp-image-scale pat-img new-width new-height)
	(plug-in-unsharp-mask 1 pat-img pat-layer 5 .5 0)
	;(plug-in-make-seamless 1 pat-img pat-layer)
	(gimp-edit-copy-visible pat-img)
	;(gimp-context-set-pattern (caadr (gimp-patterns-list "")))
	(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
		(gimp-context-set-pattern (list-ref (cadr (gimp-patterns-get-list "")) 0))
			(gimp-context-set-pattern (car (gimp-pattern-get-by-name (list-ref (car (gimp-patterns-get-list "")) 0))))
	)
	(gimp-image-delete pat-img))
	(gimp-drawable-edit-fill drawable FILL-PATTERN))


(define (fun-util-image-resize-from-layer image layer)
  (let* (
        (width (car (gimp-drawable-get-width layer)))
        (height (car (gimp-drawable-get-height layer)))
        (posx (- (car (gimp-drawable-get-offsets layer))))
        (posy (- (car (gimp-drawable-get-offsets layer))))
        )

    (gimp-image-resize image width height posx posy)
  )
)
		(define  (material-carbon fond) (begin
						 (gimp-context-set-pattern-ng "Parque #3")
				(gimp-drawable-fill fond FILL-PATTERN)
				(gimp-drawable-desaturate fond 1)
				(gimp-drawable-brightness-contrast fond -0.5 0.15)
			))

		(define (material-color fond-color fond)  			(begin
				(gimp-context-set-paint-mode 28)
				(gimp-context-set-foreground fond-color)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				;(gimp-edit-bucket-fill fond 0 0 100 0 FALSE 100 100)
			))
			
			
		(define (material-pattern image pattern fond scale) (begin
				;(gimp-context-set-pattern pattern)
				;(gimp-drawable-fill fond FILL-PATTERN)
					(scaled-pattern-fill image fond pattern scale)

			))
		(define (material-gradient fond image gradient gradient-type direction reverse fond-color)  			(begin
		        (define width (car (gimp-drawable-get-width fond)))
        (define height (car (gimp-drawable-get-height fond)))
					(gimp-context-set-foreground fond-color)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				; choose gradient destination
     (cond ((= direction 0)         ; Top-Bottom 
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= direction 1)           ; Bottom-Top
          (define x1 0)            ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= direction 2)           ; Left-Right
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= direction 3)           ; Right-Left
          (define x1 width)  ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= direction 4)           ; Diag-Top-Left
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= direction 5)           ; Diag-Top-Right
          (define x1 width)  ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= direction 6)           ; Diag-Bottom-Left
          (define x1 0)            ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )

          ((= direction 7)           ; Diag-Bottom-Right
          (define x1 width)  ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  
	  ((= direction 8)           ; Diag-to-center
          (define x1 0)  ; X Blend Starting Point
          (define y1 0) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2  (/ height 2))              ; Y Blend Ending Point
          )
	  
	  
	  ((= direction 9)           ; Diag-from-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  	  ((= direction 10)           ; center-to-top-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  
	  	  	  ((= direction 11)           ; center-to-bottom-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2 height)              ; Y Blend Ending Point
          )
;          (else
;                 ; For later use.. 
;          )
       ) ;end cond
(gimp-context-set-gradient gradient)
(gimp-context-set-gradient-reverse reverse)
 (gimp-drawable-edit-gradient-fill fond gradient-type 0 REPEAT-NONE 1 0.0 FALSE x1 y1 x2 y2)
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
			))
		(define (material-camo2 fond image col-opt) (begin
					(gimp-selection-none image)
						(if (= col-opt 1) 
				(begin (define color1 '(136 125 52)) 
					(define color2 '(62 82 22))
					(define color3  '(50 28 0)))	)
						(if (= col-opt 0) 
				(begin (define color1 '(170 170 60)) 
					(define color2 '(33 100 58))
					(define color3  '(150 115 100)))	)

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
			))
		(define  (material-alubrushed fond image) (begin

						 (gimp-context-set-pattern-ng "Blue Squares")
				
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
			;	(gimp-context-set-gradient-ng "Rounded edge")
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Rounded edge")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Rounded Edge")))
				)
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
			1
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
			;	(gimp-context-set-gradient-ng "Rounded edge")
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-gradient "Rounded edge")
				(gimp-context-set-gradient (car (gimp-gradient-get-by-name "Rounded Edge")))
				)
				(gimp-context-set-gradient-repeat-mode 2)
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
			1
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
				(begin (gimp-drawable-colorize-hsl fond 230 36 20 )
				(gimp-drawable-brightness-contrast fond -0.1 0.3))
			
		)
				
																(if (= col-opt 1) 
				(begin(gimp-drawable-colorize-hsl fond 230 36 20 )
				(gimp-drawable-brightness-contrast fond -0.1 0.1))
			
		)
		
																(if (= col-opt 2) 
				(begin (gimp-drawable-colorize-hsl fond 10 10 10)
				(gimp-drawable-brightness-contrast fond -0.1 0.3)
				(gimp-drawable-desaturate fond 1))
			
		)
			))
			
					(define (material-plasma fond image)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
             (plug-in-plasma 1 image fond (rand 999999999) 7) ; Add plasma
			))
		(define (material-none fond)  	(gimp-drawable-edit-clear fond)	)
		
(define (material-patchwork  fond image)  			(begin
	    (plug-in-plasma 1 image fond (rand 999999999) (+ 1 (random 3))) ; Rnd Plasma Fill
	    (plug-in-cubism 1 image fond 6 10 0)
			))
		(define (material-diffraction  fond image)  			(begin
              (set! *seed* (car (gettimeofday))) ; Random Number Seed From Clock (*seed* is global)
              (random-next)                      ; Next Random Number Using Seed
	                    (plug-in-diffraction 1 image fond .815 1.221 1.123 (+ .821 (rand 2)) (+ .821 (rand 2)) (+ .974 (rand 2)) .610 .677 .636 .066 (+ 27.126 (rand 20)) (+ -0.437 (rand 1)))              

			))
					(define (material-pizza fond image)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
            
             (material-bovination-2 fond image)
	    ; (gimp-selection-none image)
	     (gimp-image-select-color image 2 fond '(0 0 0) )
	     (gimp-selection-grow image 3)
	     (gimp-context-set-foreground  '(255 0 0) )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-none image)
				(gimp-layer-set-lock-alpha fond TRUE)
	      (plug-in-oilify 1 image fond 20 0) 
			))
			
		(define (material-pijama fond image gradient col-opt)  			(begin
(gimp-context-set-gradient gradient)
 (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
 (if (= col-opt 1)(gimp-drawable-edit-gradient-fill fond 0 0 REPEAT-NONE 1 0.0 FALSE 0 0 90 45)) ;45
(if (= col-opt 0) (gimp-drawable-edit-gradient-fill fond 0 0 REPEAT-NONE 1 0.0 FALSE 0 0 0 45)); horiz
(if (= col-opt 2) (gimp-drawable-edit-gradient-fill fond 0 0 REPEAT-NONE 1 0.0 FALSE 0 0 90 0));vert
 (gimp-drawable-posterize fond 3)


			))
			
			
		(define (material-leopard fond image)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
            				(gimp-context-set-foreground '(0 0 0))
					(gimp-context-set-background '(208 169 110))
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)

;(plug-in-mosaic 1 image fond 30 1 7 0.5 0 135 0 1 0 1 0 1 )
(plug-in-mosaic 1 image fond 30 1 7 0.5 0 135 0 1 0 1 1 1 )
(gimp-selection-none image)
	     (gimp-image-select-color image 0 fond '(0 0 0) )
	     (gimp-selection-shrink image 1)
	     ;(script-fu-distress-selection 1 image fond 50 4 2 2 1 1)
	     ; (gimp-selection-shrink image 1)
	     (gimp-context-set-foreground '(189 140 84))
	     (gimp-drawable-edit-fill fond FILL-FOREGROUND)
	     (gimp-selection-none image)
;(plug-in-wind 1 image fond 1 3 1 0 0)
;(plug-in-oilify-enhanced 1 image fond 1 12 fond 12 fond) 
	      (plug-in-oilify 1 image fond 5 0) 
	      (plug-in-oilify 1 image fond 6 0) 
			))
		(define (material-snake fond image)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
            				(gimp-context-set-foreground '(0 0 0))
					(gimp-context-set-background '(208 169 110))
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)

(plug-in-mosaic 1 image fond 30 1 7 0.5 0 135 0 1 0 1 0 1 )
;(plug-in-mosaic 1 image fond 30 1 7 0.5 0 135 0 1 0 1 1 1 )
(gimp-selection-none image)
	     (gimp-image-select-color image 0 fond '(0 0 0) )
	     (gimp-selection-shrink image 1)
	     ;(script-fu-distress-selection 1 image fond 50 4 2 2 1 1)
	     ; (gimp-selection-shrink image 1)
	     (gimp-context-set-foreground '(189 140 84))
	     (gimp-drawable-edit-fill fond FILL-FOREGROUND)
	     (gimp-selection-none image)
;(plug-in-wind 1 image fond 1 3 1 0 0)
;(plug-in-oilify-enhanced 1 image fond 1 12 fond 12 fond)
            				(gimp-context-set-foreground '(255 255 255))
					(gimp-context-set-background '(0 0 0))
(plug-in-mosaic 1 image fond 7 1 1 0.5 0 135 0 1 0 1 0 1 )
	      (plug-in-oilify 1 image fond 2 0) 
	      ;(plug-in-oilify 1 image fond 6 0) 
			))
			(define (material-snake2 fond image color color2)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
            				(gimp-context-set-foreground '(0 0 0))
					(gimp-context-set-background color)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)

(plug-in-mosaic 1 image fond 30 1 7 0.5 0 135 0 1 0 1 0 1 )
;(plug-in-mosaic 1 image fond 30 1 7 0.5 0 135 0 1 0 1 1 1 )
(gimp-selection-none image)
	     (gimp-image-select-color image 0 fond '(0 0 0) )
	     (gimp-selection-shrink image 1)
	     ;(script-fu-distress-selection 1 image fond 50 4 2 2 1 1)
	     ; (gimp-selection-shrink image 1)
	     (gimp-context-set-foreground color2)
	     (gimp-drawable-edit-fill fond FILL-FOREGROUND)
	     (gimp-selection-none image)
;(plug-in-wind 1 image fond 1 3 1 0 0)
;(plug-in-oilify-enhanced 1 image fond 1 12 fond 12 fond)
            				(gimp-context-set-foreground '(255 255 255))
					(gimp-context-set-background '(0 0 0))
(plug-in-mosaic 1 image fond 7 1 1 0.5 0 135 0 1 0 1 0 1 )
	      (plug-in-oilify 1 image fond 2 0) 
	      ;(plug-in-oilify 1 image fond 6 0) 
			))
			
			(define (material-leopard2 fond image color color2 colopt)  			(begin
          
            				(gimp-context-set-foreground '(0 0 0))
					(gimp-context-set-background color)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
(plug-in-mosaic 1 image fond 30 1 7 0.5 0 135 0 1 0 1 1 1 )
(gimp-selection-none image)
	     (gimp-image-select-color image 0 fond '(0 0 0) )
	     (gimp-selection-shrink image 1)
	     (gimp-context-set-foreground color2)
	     (gimp-drawable-edit-fill fond FILL-FOREGROUND)
	     (gimp-selection-none image)
	      (plug-in-oilify 1 image fond 5 0) 
	      (plug-in-oilify 1 image fond 6 0) 
			))
			
		(define (material-giraffe fond image)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
            				(gimp-context-set-foreground '(112 68 31))
					(gimp-context-set-background '(248 202 164))
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)

(plug-in-mosaic 1 image fond 25 1 5 0.5 0 0 0 1 0 1 1 1 )
(plug-in-wind 1 image fond 1 3 1 0 0)
	      (plug-in-oilify 1 image fond 2 0) 
			))
			
		(define (material-zebra fond image)  			(begin
          ;(gimp-layer-set-lock-alpha fond TRUE)
	  (gimp-context-set-paint-mode 0)
            				(gimp-context-set-foreground '(0 0 0))
					(gimp-context-set-background '(255 255 255))
				(gimp-context-set-gradient-fg-bg-rgb)
				(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
				(gimp-context-set-gradient-repeat-mode 1)
				(gimp-context-set-gradient-repeat-mode 3))
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
			1
			0
			0 ;FALSE
			47
			43
			69
			52
		)
		(gimp-drawable-brightness-contrast fond 0 0.5)
		(plug-in-wind 1 image fond 1 3 1 0 0)
		 (plug-in-oilify 1 image fond 2 0)
		(plug-in-ripple 1 image fond 100 25 1 0 1 TRUE TRUE)
			))
			
		(define (material-pois fond image color color2)  			(begin
					(gimp-context-set-foreground '(165 165 165))
					(gimp-drawable-edit-fill fond FILL-FOREGROUND)
            				(gimp-context-set-foreground color)
					(gimp-context-set-background color2)
					;(plug-in-newsprint 1 image fond  1 0 0 0 0 0 0 0 0 0 0 0)
						(plug-in-newsprint 1 image fond 
	                           20 ;cell-width 
							   0 ;colorspace 
							   100 ;k-pullout 
							   15 ;gry-ang 
							   0 ;gry-spotfn QUI
							   15 ;red-ang 
							   0 ;red-spotfn 
							   75 ;grn-ang 
							   0 ;grn-spotfn 
							   0 ;blu-ang 
							   0 ;blu-spotfn 
							   45) ;oversample
					(gimp-image-select-color image 2 fond '(0 0 0))
				(gimp-drawable-edit-fill fond FILL-BACKGROUND)
				(gimp-selection-invert image)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
	      (plug-in-oilify 1 image fond 2 0) 
	      	     (gimp-selection-none image)

			))
			(define (material-squares fond image color color2)  			(begin
					(gimp-context-set-foreground '(165 165 165))
					(gimp-drawable-edit-fill fond FILL-FOREGROUND)
            				(gimp-context-set-foreground color)
					(gimp-context-set-background color2)
					;(plug-in-newsprint 1 image fond  1 0 0 0 0 0 0 0 0 0 0 0)
						(plug-in-newsprint 1 image fond 
	                           20 ;cell-width 
							   0 ;colorspace 
							   100 ;k-pullout 
							   15 ;gry-ang 
							   2 ;gry-spotfn QUI
							   15 ;red-ang 
							   0 ;red-spotfn 
							   75 ;grn-ang 
							   0 ;grn-spotfn 
							   0 ;blu-ang 
							   0 ;blu-spotfn 
							   45) ;oversample
					(gimp-image-select-color image 2 fond '(0 0 0))
				(gimp-drawable-edit-fill fond FILL-BACKGROUND)
				(gimp-selection-invert image)
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
	      (plug-in-oilify 1 image fond 2 0) 
	      	     (gimp-selection-none image)

			))
			
	(define  (material-emap fond image gradient) (begin
				(plug-in-solid-noise 1 image fond 1 0 (random 999999) 1 9 3)
				      (plug-in-gauss                 
                   1     ; Non-interactive 
                 image     ; Image to apply blur 
            fond     ; Layer to apply blur
         5     ; Blur Radius x  
         5     ; Blue Radius y 
                   0     ; Method (IIR=0 RLE=1)
      )
      (gimp-context-set-gradient gradient)
      (plug-in-autostretch-hsv 1 image fond)
 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)  
(plug-in-gradmap 1 image fond) 
      (plug-in-gradmap 1 image 1 (vector fond))   )              ; Map Gradient

	))
	(define  (material-willwood fond img n1 n2) (begin
				(plug-in-solid-noise 0 img fond 1 0 (random 65535) 2 n1 n2)
				(plug-in-alienmap2 1 img fond 1 0 1 0 15 0 1 FALSE FALSE TRUE)
				(plug-in-alienmap2 1 img fond 1 0 1 0 0.1 0 1 FALSE TRUE TRUE)
				(gimp-drawable-hue-saturation fond 0 0 30 -40 0)
				(plug-in-wind 1 img fond 1 3 1 0 0)
		 (plug-in-oilify 1 img fond 2 0)
			))
			
	(define (material-steampunk-brass img fond color n1) (begin
			(if (= n1 0) 
(gimp-context-set-foreground '(232 204 0) )
		(gimp-context-set-foreground color )	
		)	
	
	(gimp-context-set-paint-mode  LAYER-MODE-MULTIPLY-LEGACY)
 (plug-in-solid-noise 0 img fond 0 0 (random 65535) 1 16 4)
   (gimp-drawable-edit-fill fond FILL-FOREGROUND)
   (gimp-drawable-hue-saturation fond 0 0 0 100 0)
     (gimp-drawable-hue-saturation fond 0 0 0 100 0)
     (gimp-context-set-paint-mode  LAYER-MODE-NORMAL-LEGACY)
	) )
		(define (material-grunge-green img fond color n1) (begin 
       (plug-in-plasma 1 img fond 0 1.0) (gimp-drawable-desaturate fond 4)
      (plug-in-noisify 1 img fond 1 0.2 0.2 0.2 0)
      (gimp-context-set-paint-mode  LAYER-MODE-MULTIPLY-LEGACY)
      			(if (= n1 0) 
     (gimp-context-set-background '(0 96 4) )
		(gimp-context-set-background color )	
		)
      (gimp-drawable-edit-fill fond FILL-BACKGROUND)
     (gimp-context-set-paint-mode  LAYER-MODE-NORMAL-LEGACY)
	) )
	
		(define (material-stripes img fond color color2 45deg size) (begin
			    (gimp-context-set-background color2)
		(gimp-context-set-foreground color )	
				 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
		(gimp-context-set-gradient (list-ref (cadr (gimp-gradients-get-list "")) 1)) 
		(gimp-context-set-gradient (car (gimp-gradient-get-by-name(list-ref (car (gimp-gradients-get-list "")) 4)))) )
		  (gimp-context-set-gradient-repeat-mode REPEAT-SAWTOOTH)
        (cond ((= 45deg 0)
		(gimp-drawable-edit-gradient-fill fond 0 0 TRUE 1 0 TRUE 0 0 0 (round size))
          )
          ((= 45deg 1)
		(gimp-drawable-edit-gradient-fill fond 0 0 TRUE 1 0 TRUE 0 0 (round size) (round  size ))
          )
	 ((= 45deg 2)
		(gimp-drawable-edit-gradient-fill fond 0 0 TRUE 1 0 TRUE 0 0 (round size) 0)
          )
	  )
		)
		)
;;;;;;;
;;;;;;;MATERIAL END
;;;;;;;
		(define  (effect-blur fond image) (begin
				(plug-in-gauss-iir TRUE image fond 6 TRUE TRUE)
			))
		(define  (effect-oilify fond image) (begin
					 (plug-in-oilify 1 image fond 20 0)              ; Add olify effect
			))
		(define  (effect-cubism fond image) (begin
					(plug-in-cubism 1 image fond 15 9 1)               ; Add cubism effect
			))
		(define  (effect-ripple fond image) (begin
				(plug-in-ripple 1 image fond 100 5 1 0 1 TRUE FALSE)               ; Add ripple effect
			))
		(define  (effect-bump-pattern fond image pattern scale)  (begin

      ;  (set! effect-layer (car (gimp-layer-new-from-drawable fond image))) ; New effect Layer
       ; (gimp-image-insert-layer image effect-layer 0 3) ; Add it to image
       ; (gimp-item-set-name effect-layer "Bumped")                             ; Name effect layer


        (define bump-layer (car (gimp-layer-new-from-drawable fond image))) ; New patten layer
	(gimp-image-insert-layer image bump-layer 0 -1)
        (gimp-context-set-pattern pattern)                             ; Make bump pattern active         
        ;(gimp-drawable-fill bump-layer FILL-PATTERN)                                     ; Fill with pattern
						;(scaled-pattern-fill image bump-layer pattern scale)
						(material-pattern image pattern bump-layer scale)
						

;
; Call bump map procedure (pattern bump)
;
        (plug-in-bump-map 
                     1              ; Interactive (0), non-interactive (1)
                     image            ; Input image
                     fond   ; Input drawable
                     bump-layer     ; Bumpmap drawable
                     130            ; Azimuth (float)
                     55             ; Elevation (float)
                     7   ; Depth
                     0              ; X offset
                     0              ; Y offset
                     0              ; Level that full transparency should represent
                     0              ; Ambient lighting factor
                     TRUE           ; Compensate for darkening
                     FALSE          ; Invert bumpmap
                    0)        ; Type of map (0=linear, 1=spherical, 2=sinusoidal)
		    (gimp-image-remove-layer image bump-layer)
      ))
	(define  (effect-desat-chrome fond image) (begin
				(gimp-drawable-desaturate fond 4 )
					(gimp-drawable-curves-spline fond 0 12 #(0 0.34902 0.266667 0.882353 0.494118 0.376471 0.65098 0.886275 0.87451 0.152941 1 1))
					(plug-in-gauss-iir TRUE image fond 3 TRUE TRUE)


			))
	(define  (effect-desat-chrome-color fond image fond-color number) (begin
				(gimp-drawable-desaturate fond 2 )
					(gimp-drawable-curves-spline fond 0 12 #(0 0.34902 0.266667 0.882353 0.494118 0.376471 0.65098 0.886275 0.87451 0.152941 1 1))
					(gimp-context-set-foreground fond-color)
					(plug-in-gauss-iir TRUE image fond 3 TRUE TRUE)
					(if (= number 0) (gimp-context-set-paint-mode LAYER-MODE-LIGHTEN-ONLY-LEGACY))
					(if (= number 1) (gimp-context-set-paint-mode LAYER-MODE-MULTIPLY-LEGACY))
					(if (= number 2) (gimp-context-set-paint-mode LAYER-MODE-OVERLAY-LEGACY))
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)	
			))
	(define  (effect-desat-color fond image fond-color number) (begin
				(gimp-drawable-desaturate fond 2 )
					(gimp-context-set-foreground fond-color)
					(if (= number 0) (gimp-context-set-paint-mode LAYER-MODE-LIGHTEN-ONLY-LEGACY))
					(if (= number 1) (gimp-context-set-paint-mode LAYER-MODE-MULTIPLY-LEGACY))
					(if (= number 2) (gimp-context-set-paint-mode LAYER-MODE-OVERLAY-LEGACY))
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)	
			))
			
	(define  (effect-stain-glass fond image) (begin
			(plug-in-mosaic 1 image fond ; mosaic drawing
20 ;tsize
4
1 ;tspc
0.65
1
135
0.2
1
1
1
0
0)


			))
		(define  (effect-glitter fond image) (begin
				 ;(plug-in-solid-noise 0 image fond 0 0 (random 65535) 1 16 4)
				 (plug-in-rgb-noise 1 image fond  FALSE FALSE 0.6 0.6 0.6 0)
				 (plug-in-cubism 1 image fond 1 5 0)               ; Add cubism effect
			))

;;;;;;;			
;;;;;;;EFFECTS END
;;;;;;;
(define
	(
		apply-plastic-logo-effect-299o
		img
		basetext
		border-color
		 border-size
		refl-color
		refl-opacity
		refl-dir
		shadow-color
		type
		effect-fill
		opacity
		color
		color2
		pattern
		pattern-scale
		gradient
		gradient-type
		direction
		grad-rev
		;ripple
		backtype
		effect-back
		fond-color
		fond-color2
                back-pattern
		back-pattern-scale
		back-gradient
		 back-gradient-type
		 blendir
		 back-grad-rev
		 vignette
		 vignette-color
		 applyMasks
		

	)
	(let*
		(
			(width (car (gimp-drawable-get-width basetext)))
			(height (car (gimp-drawable-get-height basetext)))
			(fond (car (gimp-layer-new   img width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
			(olight (car (gimp-layer-new img width height RGBA-IMAGE "Light Outline" 90 LAYER-MODE-SCREEN-LEGACY)))
			(border (car (gimp-layer-new img width height RGBA-IMAGE "Border" 100 LAYER-MODE-NORMAL-LEGACY)))
			(refl (car (gimp-layer-new   img width height RGBA-IMAGE "Refl" 70 LAYER-MODE-NORMAL-LEGACY)))
			(mapeux (car (gimp-layer-new img width height RGBA-IMAGE "Mapper" 100 LAYER-MODE-NORMAL-LEGACY)))
			(shad (car (gimp-layer-new   img width height RGBA-IMAGE "Shadow" 100 LAYER-MODE-NORMAL-LEGACY)))
			(chantext)
			(basetextmask)
			(xdest)
			(ydest)
			(reflmask)
			           (bump-layer -1)    ; Bump Map layer
           (effect-layer -1)  ; Effect layer

		)
 

		(gimp-context-push)
				(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )

	;;;;;; filling back with background
			(gimp-context-set-background fond-color)
			(gimp-context-set-foreground fond-color2)
		(gimp-selection-none img)
		(fun-util-image-resize-from-layer img basetext)
		(gimp-image-insert-layer img fond 0 1)
		(gimp-drawable-edit-clear fond)
	(if (= backtype 0)
			(material-color fond-color fond)
			;(begin
			;	(gimp-context-set-foreground fond-color)
			;	(gimp-drawable-edit-fill fond FILL-FOREGROUND)
			;)
		)
	(if (= backtype 1) 
				(material-pattern img back-pattern fond back-pattern-scale)			
		)
		(if (= backtype 2) ;START gradient
	(material-gradient fond img back-gradient back-gradient-type blendir back-grad-rev fond-color))


				(if (= backtype 3) 
(material-none fond)
			
		)
						(if (= backtype 4) 
(material-alubrushed fond img)
			
		)
						(if (= backtype 5) 
(material-alubrushed-light fond img)
			
		)
								(if (= backtype 6) 
(material-blue-jeans fond img 0)
			
		)
								(if (= backtype 7) 
(material-blue-jeans fond img 1)
			
		)
										(if (= backtype 8) 
(material-blue-jeans fond img 2)
			
		)
	(if (= backtype 9) 
;(material-bovination fond img)
(material-carbon fond)
			
		)

	(if (= backtype 10) 
(material-bovination-2 fond img)
			
		)
	(if (= backtype 11) 
(material-camo2 fond img 0)
			
		)
	(if (= backtype 12) 
(material-camo2 fond img 1)
			
		)
	(if (= backtype 13) 
(material-plasma fond img)
			
		)
	(if (= backtype 14) 
(material-patchwork fond img)
		)
	(if (= backtype 15) 
(material-diffraction fond img)
		)
	(if (= backtype 16) 
(material-pizza fond img)
		)
	(if (= backtype 17) 
(material-leopard fond img)
		)
	(if (= backtype 18) 
(material-giraffe fond img)
		)

	(if (= backtype 19) 
(material-zebra fond img)
		)
	(if (= backtype 20) 
(material-leopard2 fond img fond-color fond-color2 0)
		)
	(if (= backtype 21) 
(material-snake fond img))

	(if (= backtype 22) 
(material-snake2 fond img fond-color fond-color2))

	(if (= backtype 23) 
(material-pois fond img fond-color fond-color2))

	(if (= backtype 24) 
(material-squares fond img fond-color fond-color2))
	(if (= backtype 25) 
(material-emap fond img back-gradient))
	(if (= backtype 26) 
(material-pijama fond img back-gradient 0))
	(if (= backtype 27) 
(material-pijama fond img back-gradient 1))
	(if (= backtype 28) 
(material-pijama fond img back-gradient 2))
	(if (= backtype 29) 
 (material-willwood fond img 9 1))
 	(if (= backtype 30) 
 (material-steampunk-brass img fond fond-color 0))
  	(if (= backtype 31) 
 (material-steampunk-brass img fond fond-color 1))
  	(if (= backtype 32) 
 (material-grunge-green img fond fond-color 0))
   	(if (= backtype 33) 
 (material-grunge-green img fond fond-color 1))
 (if (= backtype 34) 
(material-stripes img fond fond-color fond-color2 0 20))
 (if (= backtype 35) 
(material-stripes img fond fond-color fond-color2 1 20))
 (if (= backtype 36) 
(material-stripes img fond fond-color fond-color2 2 20))
   (if (= backtype 37) 
(material-gradient fond img back-gradient back-gradient-type blendir back-grad-rev fond-color))

		(if (= effect-back 1) ;Blur
		(effect-blur fond img)			; Blur effect
		)
		(if (= effect-back 2) 
		(effect-oilify fond img)              ; Add olify effect
		)
		(if (= effect-back 3) 
		(effect-cubism fond img)               ; Add cubism effect
		)
		(if (= effect-back 4) 
		(effect-ripple fond img)               ; Add ripple effect
		)
		(if (= effect-back 5) 
		(effect-bump-pattern fond img back-pattern back-pattern-scale); Bump gradient
		)
		(if (= effect-back 6)
		(effect-desat-chrome fond img)
		)
		(if (= effect-back 7)
		(effect-desat-chrome-color fond img fond-color 0)
		)
		(if (= effect-back 8)
		(effect-desat-chrome-color fond img fond-color 1)
		)
		(if (= effect-back 9)
		(effect-desat-chrome-color fond img fond-color 2)
		)
		(if (= effect-back 10)
		(effect-desat-color fond img fond-color 0) 
		)
		(if (= effect-back 11)
		(effect-desat-color fond img fond-color 1) 
		)
		(if (= effect-back 12)
		(effect-desat-color fond img fond-color 2) 
		)
		(if (= effect-back 13)
		(effect-stain-glass fond img)
		)
		(if (= effect-back 14)
		(effect-glitter fond img)
		)
		; composite text and channel
		(gimp-image-select-item img 0 basetext)
		(define chantext (car (gimp-selection-save img)))
		(define basetextmask (car (gimp-layer-create-mask basetext ADD-MASK-SELECTION)))
		(gimp-layer-add-mask basetext basetextmask)
		(define reflmask (car (gimp-layer-create-mask refl ADD-MASK-SELECTION)))
		(gimp-layer-add-mask refl reflmask)
		(gimp-selection-all img)
		; choose gradient destination

		(if (= type 0)
			(material-color color basetext)
		)
		(if (= type 1) 
			(material-pattern img pattern basetext pattern-scale)
		)
		(if (= type 2) ;QUESTO
(material-gradient basetext img gradient gradient-type direction grad-rev color)
		)

						(if (= type 3) 
(material-none basetext)
			
		)
								(if (= type 4) 
(material-alubrushed basetext img)
			
		)
										(if (= type 5) 
(material-alubrushed-light basetext img)
			
		)
										(if (= type 6) 
(material-blue-jeans basetext img 0)
			
		)
										(if (= type 7) 
(material-blue-jeans basetext img 1)
			
		)
												(if (= type 8) 
(material-blue-jeans basetext img 2)
			
		)
														(if (= type 9) 
;(material-bovination basetext img )
(material-carbon basetext)
			
		)
														(if (= type 10) 
(material-bovination-2 basetext img )
			
		)
														(if (= type 11) 
(material-camo2 basetext img 0)
			
		)
														(if (= type 12) 
(material-camo2 basetext img 1)
			
		)
														(if (= type 13) 
(material-plasma basetext img )
			
		)
		
	(if (= type 14) 
(material-patchwork basetext img)
		)
	(if (= type 15) 
(material-diffraction basetext img)
		)
	(if (= type 16) 
(material-pizza basetext img)
		)
	(if (= type 17) 
(material-leopard basetext img)
		)
	(if (= type 18) 
(material-giraffe basetext img)
		)
	(if (= type 19) 
(material-zebra basetext img)
		)
	(if (= type 20) 
(material-leopard2 basetext img color color2 0)
		)
	(if (= type 21) 
(material-snake basetext img)
		)
		(if (= type 22) 
(material-snake2 basetext img color color2)
		) 
		(if (= type 23) 
(material-pois basetext img color color2)
		)
		(if (= type 24) 
(material-squares basetext img color color2)
		)
	(if (= type 25) 
(material-emap basetext img gradient))
	(if (= type 26) 
(material-pijama basetext img gradient 0))
(if (= type 27) 
(material-pijama basetext img gradient 1))
(if (= type 28) 
(material-pijama basetext img gradient 2))
	(if (= type 29) 
 (material-willwood basetext img 9 1))
 	(if (= type 30) 
  (material-steampunk-brass img basetext color 0))
   	(if (= type 31) 
  (material-steampunk-brass img basetext color 1))
   	(if (= type 32) 
  (material-grunge-green img basetext color 0))
     	(if (= type 33) 
  (material-grunge-green img basetext color 1))
   (if (= type 34) 
(material-stripes img basetext color color2 0 20))
   (if (= type 35) 
(material-stripes img basetext color color2 1 20))
   (if (= type 36) 
(material-stripes img basetext color color2 2 20))
   (if (= type 37) 
(material-gradient basetext img gradient gradient-type direction grad-rev color))
	
		; Adding light effect on edge
		(gimp-selection-none img)
		(gimp-image-insert-layer img olight 0 0)
		(gimp-drawable-edit-clear olight)
		(gimp-image-select-item img 0 chantext)
		(gimp-selection-shrink img 3)
		(gimp-selection-invert img)
		(gimp-context-set-foreground '(255 255 255))
		(gimp-drawable-edit-fill olight FILL-FOREGROUND)
		(gimp-selection-none img)
		(plug-in-gauss-rle2 1 img olight 18 18)
		(gimp-image-select-item img 0 chantext)
		;(gimp-selection-invert img)
		;(gimp-edit-cut olight)
		(define litemask (car (gimp-layer-create-mask olight ADD-MASK-SELECTION)))
		(gimp-layer-add-mask olight litemask)
		(gimp-selection-invert img)
		(define shadmask (car (gimp-layer-create-mask shad ADD-MASK-SELECTION)))
		(gimp-layer-add-mask shad shadmask)
				(gimp-selection-invert img)
		; creating black border
		(gimp-image-insert-layer img border 0 -1)
		(gimp-drawable-edit-clear border)
		(gimp-context-set-foreground border-color)
		(gimp-image-select-item img 0 chantext)
		(gimp-drawable-edit-fill border FILL-FOREGROUND)
		;(gimp-selection-grow img (/ border-size 2))
		(gimp-selection-shrink img border-size)
		(gimp-selection-feather img 1)
		(gimp-selection-invert img)
		;(gimp-edit-cut border)
				(define bordmask (car (gimp-layer-create-mask border ADD-MASK-SELECTION)))
		(gimp-layer-add-mask border bordmask)
		; adding light reflect
		(gimp-image-insert-layer img refl 0 -1)
		(gimp-drawable-edit-clear refl)
		(if (= refl-dir 0) (begin (gimp-image-select-ellipse img
		;(gimp-ellipse-select img 
			2
			(- 0 (/ width 2))
			(- 0 height)
			(* width 2)
			(* height 1.54)
			;2 
			;TRUE
			;0
			;0
		)))
		(if (= refl-dir 1) (begin (gimp-image-select-ellipse img
		;(gimp-ellipse-select img 
			2
			 -300
			(/ height 2)
			 (+ width 600)
			(* height 1.54)
			;2 
			;TRUE
			;0
			;0
		)))
		;(gimp-context-set-foreground '(255 255 255))
		(gimp-context-set-foreground refl-color)
	(gimp-context-set-gradient-fg-transparent) ;chissà
	(gimp-context-set-gradient-reverse TRUE)
		(gimp-drawable-edit-gradient-fill 
			refl
			;BLEND-FG-TRANSPARENT
			;LAYER-MODE-NORMAL-LEGACY
			6 ;GRADIENT-LINEAR
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			1
			0
			0 ;FALSE
			(/ width 2)
			(* height 0.54)
			(/ width 2)
			(* height 0.05)
		)
		(gimp-layer-set-opacity refl refl-opacity)
		(gimp-image-select-item img 0 chantext)
		;(define reflmask (car (gimp-layer-create-mask refl ADD-MASK-SELECTION)))
		;(gimp-layer-add-mask refl reflmask)

		; creating bumpmap map
		(gimp-image-insert-layer img mapeux 0 -1)
		(gimp-drawable-edit-clear mapeux)
		(gimp-selection-none img)
		(gimp-context-set-foreground '(0 0 0))
		(gimp-drawable-edit-fill mapeux FILL-FOREGROUND)
		(gimp-image-select-item img 0 chantext)
		(gimp-selection-shrink img 5)
		(gimp-context-set-foreground '(255 255 255))
		(gimp-drawable-edit-fill mapeux FILL-FOREGROUND)
		(gimp-selection-none img)
		(plug-in-gauss-rle2 1 img mapeux 18 18)

		; bumpmapping:displacing reflect to follow shape
		(plug-in-displace 
			1
			img
			refl
			1.5
			1.5
			TRUE
			TRUE
			mapeux
			mapeux
			1
		)
		(gimp-image-remove-layer img mapeux)    
		
		; back shadow
		(gimp-image-insert-layer img shad 0 4)
		(gimp-drawable-edit-clear shad)
		(gimp-image-select-item img 0 chantext)
		(gimp-selection-translate img 0 12)
		(gimp-context-set-foreground shadow-color)
		(gimp-drawable-edit-fill shad FILL-FOREGROUND)
		(gimp-selection-none img)
		(plug-in-gauss-rle2 1 img shad 15 15)

		
		; correcting resizing effect on background
		;(gimp-context-set-foreground fond-color)
		;(gimp-layer-resize-to-image-size fond)
		;(gimp-drawable-edit-fill fond FILL-FOREGROUND)
		
		; final effects
	
		(if (= effect-fill 1) ;Blur
			;(plug-in-gauss-iir TRUE img basetext 6 TRUE TRUE)
			(effect-blur basetext img)
		)
		(if (= effect-fill 2) 
			; (plug-in-oilify 1 img basetext 20 0)              ; Add olify effect
			 (effect-oilify basetext img)
		)
		(if (= effect-fill 3) 
		;(plug-in-cubism 1 img basetext 15 9 1)               ; Add cubism effect
		(effect-cubism basetext img)
		)
		(if (= effect-fill 4) 
		;(plug-in-ripple 1 img basetext 100 5 1 0 1 TRUE FALSE)               ; Add ripple effect
		(effect-ripple basetext img)
		)
		
		 (if (= effect-fill 5)
		(effect-bump-pattern basetext img pattern pattern-scale); Bump gradient
  		  ) ; end
		 (if (= effect-fill 6)
		  (effect-desat-chrome basetext img)
		  )
		(if (= effect-fill 7)
		(effect-desat-chrome-color basetext img color 0)
		)
		(if (= effect-fill 8)
		(effect-desat-chrome-color basetext img color 1)
		)
		(if (= effect-fill 9)
		(effect-desat-chrome-color basetext img color 2)
		)
		(if (= effect-fill 10)
		(effect-desat-color basetext img color 0) 
		)
		(if (= effect-fill 11)
		(effect-desat-color basetext img color 1) 
		)
		(if (= effect-fill 12)
		(effect-desat-color basetext img color 2) 
		)
		(if (= effect-fill 13)
		(effect-stain-glass basetext img)
		)
		(if (= effect-fill 14)
		(effect-glitter basetext img)
		)
    		(if (< opacity 100)  ;Transparent
			(gimp-layer-set-opacity basetext opacity)
			(gimp-layer-set-opacity olight (round (/ opacity 2)))
			(gimp-layer-set-opacity refl (round (/ opacity 2)))
		)
		
		    (if (= vignette TRUE)
(begin
            (gimp-image-select-ellipse
            img
            CHANNEL-OP-REPLACE
            0
	    0
            (car (gimp-image-get-width img))
           (car (gimp-image-get-height img))
        )
	(gimp-selection-invert img)
    (gimp-selection-feather img (round (/ (car (gimp-image-get-width img)) 5 )))
    (gimp-context-set-opacity 50)
	(gimp-context-set-background vignette-color)
    (gimp-drawable-edit-fill fond FILL-BACKGROUND)
    		(gimp-selection-none img)
))
		
		(if (= applyMasks TRUE) (begin
    		(gimp-layer-remove-mask border 0)
		(gimp-layer-remove-mask olight 0)
		(gimp-layer-remove-mask basetext 0)
		(gimp-layer-remove-mask shad 0)
		(gimp-layer-remove-mask refl 0)))
		(gimp-context-pop)
	)
)



(define 
	(
		script-fu-plastic-logo299o-alpha
		img
		text-layer
		border-color
		 border-size
		refl-color
		refl-opacity
		refl-dir
		shadow-color
		type
		effect-fill
		opacity
		color
		color2
		pattern
		pattern-scale
		gradient
		gradient-type
		direction
		grad-rev
		;ripple
		backtype
		effect-back
		fond-color
		fond-color2
                back-pattern
		back-pattern-scale
		back-gradient
									          back-gradient-type
							          blendir
		back-grad-rev
		vignette
		vignette-color
		applyMasks
		)
	(begin
		(gimp-image-undo-disable img)
		(gimp-layer-resize-to-image-size text-layer)
		(apply-plastic-logo-effect-299o img text-layer border-color border-size refl-color refl-opacity refl-dir shadow-color type effect-fill opacity color color2 pattern pattern-scale gradient gradient-type direction grad-rev backtype effect-back fond-color fond-color2 back-pattern back-pattern-scale back-gradient back-gradient-type blendir back-grad-rev vignette vignette-color applyMasks)
		(gimp-image-undo-enable img)
		(gimp-displays-flush)
	)
)


(script-fu-register 	
	"script-fu-plastic-logo299o-alpha"
	"Polished Plastic Fun 299o ALPHA..."
	"Create a polished plastic logo alpha object"
	"Denis Bodor <lefinnois@lefinnois.net>"
	"Denis Bodor"
	"03/31/2005"
	""
	SF-IMAGE		"Image"			0
	SF-DRAWABLE		"Drawable"		0
	SF-COLOR		"Border Color"	'(0 0 0)
	SF-ADJUSTMENT "Border size" '(2 0 12 1 1 0 0)
	SF-COLOR		"Refl Color"	'(255 255 255)
	SF-ADJUSTMENT "Refl Opacity" '(70 0 100 1 1 0 0)
	SF-OPTION  	"Refl Direction"    '("Up" "Down")
	SF-COLOR		"Shadow Color"	'(50 50 50)
	SF-OPTION		"Fill with"		list-fill-ppf-dir
	SF-OPTION  	"Fill Effect"    list-effect-ppf-dir
	SF-ADJUSTMENT "Fill Opacity" '(100 0 100 1 1 0 0)
	SF-COLOR		"Fill Color"			'(255 0 255)
	SF-COLOR      "Fill Color  2 sometimes"         "White"
	SF-PATTERN		"Fill Pattern"		"Warning!"
	SF-ADJUSTMENT "Pattern Scale %" '(100 1 1000 1 50 0 0)
	SF-GRADIENT		"Fill Gradient"		"Golden"
	SF-ENUM "Fill Gradient Mode" '("GradientType" "gradient-linear")
	SF-OPTION		"Fill gradient Direction" 		list-blend-ppf-dir
	SF-TOGGLE  "Gradient reverse"    FALSE
	;SF-TOGGLE  "Ripple"    FALSE
					 SF-OPTION "Background Type" list-fill-ppf-dir
	SF-OPTION  	"Back Effect"    list-effect-ppf-dir
    SF-COLOR      "Back Color"         "White"
    SF-COLOR      "Back Color 2 sometimes"         '(255 0 255)
  SF-PATTERN    "Back Pattern"            "Pink Marble"
  SF-ADJUSTMENT "Pattern Scale %" '(100 1 1000 1 50 0 0)
  SF-GRADIENT   "Back Gradient" "Abstract 3"
    SF-ENUM "Back  Gradient Mode" '("GradientType" "gradient-linear")
  SF-OPTION		"Blend Direction" 		list-blend-ppf-dir
  SF-TOGGLE  "Back Gradient reverse"    FALSE
  SF-TOGGLE  "Apply Vignette"    FALSE
  	SF-COLOR		"Vignette Color"	'(0 0 0)
  SF-TOGGLE  "Apply Masks"    TRUE
)

(script-fu-menu-register 
	"script-fu-plastic-logo299o-alpha"
	"<Image>/Filters/Alpha to Logo"
)

(define
	(
		script-fu-plastic-logo299o
		font
		size
		text
											  justify
									  letter-spacing
									  line-spacing
					grow-text
					outline
					text-effect
					buffer
		border-color
		border-size
		refl-color
		refl-opacity
		refl-dir
		shadow-color
		
		type						; Color=0 Pattern=1 Gradient=2
		effect-fill
		opacity
		color
		color2
		pattern
		pattern-scale
		gradient
		gradient-type
		direction
		grad-rev
		;ripple
		backtype
		effect-back
		     fond-color
		     fond-color2
                back-pattern
		back-pattern-scale
		back-gradient
											          back-gradient-type
							          blendir
		back-grad-rev
		vignette
		vignette-color
		applyMasks
	)
  
	(let*
		(
			(img (car (gimp-image-new 256 256 RGB)))	; nouvelle image -> img
			(border (/ size 4))
			(text-layer (car (gimp-text-fontname img -1 0 0 text  (round (* border buffer)) TRUE size PIXELS font)))
					 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))

						
						
			(width (car (gimp-drawable-get-width text-layer)))
			(height (car (gimp-drawable-get-height text-layer)))
		)
    ;;;;adjust text 
	(gimp-text-layer-set-justification text-layer justify)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
			;(plug-in-ripple 1 img text-layer 100 5 1 0 1 TRUE FALSE)
;;;; shrink grow text
(cond ((> grow-text 0)
	(gimp-selection-none img)
	 (gimp-image-resize-to-layers img)
	(gimp-image-select-item img 2 text-layer)
	(gimp-selection-grow img (round grow-text))
	(gimp-drawable-edit-clear text-layer)
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
 )
 ((< grow-text 0)
        (gimp-selection-none img)
	 (gimp-image-resize-to-layers img)
	(gimp-image-select-item img 2 text-layer)
		(gimp-selection-grow img 1)
	(gimp-drawable-edit-clear text-layer)
	(gimp-selection-shrink img (- grow-text))   
	(gimp-drawable-edit-fill text-layer FILL-FOREGROUND)	
 ))
 
  ;;; outline
 (cond ((> outline 0)
	(gimp-selection-none img)
	(gimp-image-select-item img 2 text-layer)
		 (gimp-image-resize-to-layers img)

	(gimp-selection-shrink img (round outline))   
	(gimp-drawable-edit-clear text-layer)
	(gimp-image-select-item img 2 text-layer)
 ))
 		(if (= text-effect 1)
				(begin (plug-in-ripple 1 img text-layer 26 2 0 0 0 TRUE FALSE) ; Horiz
		(plug-in-ripple 1 img text-layer 26 2 1 0 0 TRUE FALSE)) ; Vert
		)
		 		(if (= text-effect 2)
				(begin (plug-in-ripple 1 img text-layer 800 50 1 1 0 TRUE FALSE) ; Vert
		))
		(if (= text-effect 3) (plug-in-waves  1 img text-layer 5 70 10 1 0 FALSE ))
		(if (= text-effect 4) (begin (gimp-selection-none img)
			(plug-in-gauss-rle2 RUN-NONINTERACTIVE img text-layer 20 20)
(gimp-drawable-curves-spline text-layer HISTOGRAM-ALPHA 8 #(0 0 0.6196 0.0745 0.68235 0.94901 1 1))))
 	(gimp-selection-none img)


		(gimp-image-undo-disable img)
		(gimp-item-set-name text-layer text)
		(apply-plastic-logo-effect-299o img text-layer border-color border-size refl-color refl-opacity refl-dir shadow-color type effect-fill opacity color color2 pattern pattern-scale gradient gradient-type direction grad-rev backtype effect-back fond-color fond-color2 back-pattern back-pattern-scale back-gradient back-gradient-type blendir back-grad-rev vignette vignette-color applyMasks)

		;(plug-in-waves 1 img text-layer 100 180 50 0 FALSE)
		(gimp-image-undo-enable img)
		(gimp-display-new img)    
    )
)

(script-fu-register
	"script-fu-plastic-logo299o"
	"Polished Plastic Fun 299o LOGO"
	"Create a polished plastic logo"
	"Denis Bodor <lefinnois@lefinnois.net>"
	"Denis Bodor"
	"03/31/2005"
	""
	SF-FONT			"Font Name"				"QTBlimpo"
		SF-ADJUSTMENT	"Font size (pixels)"	'(150 2 1000 1 10 0 1)
	SF-TEXT		"Enter your text"		"PLASTIC FUN"
	SF-OPTION "Justify" '("Centered" "Left" "Right")
	SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
	SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
	SF-ADJUSTMENT _"Shrink / Grow Text"          '(0 -20 20 1 10 0 0)
	SF-ADJUSTMENT _"Outline"          '(0 0 20 1 10 0 0)
		SF-OPTION "Text deformation" '("None" "Corrugated" "Wave" "Electrized" "Rounded" "Right" )
	SF-ADJUSTMENT _"Buffer"          '(1 1 20 1 10 0 0)
	SF-COLOR		"Border Color"			'(0 0 0)
	SF-ADJUSTMENT "Border size" '(2 0 12 1 1 0 0)
	SF-COLOR		"Refl Color"	'(255 255 255)
	SF-ADJUSTMENT "Refl Opacity" '(70 0 100 1 1 0 0)
	SF-OPTION  	"Refl Direction"    '("Up" "Down")
	SF-COLOR		"Shadow Color"	'(50 50 50)
	SF-OPTION		"Fill with"				list-fill-ppf-dir
	SF-OPTION  	"Fill Effect"    list-effect-ppf-dir
	SF-ADJUSTMENT "Fill Opacity" '(100 0 100 1 1 0 0)
	SF-COLOR		"Fill Color"					'(255 0 255)
	SF-COLOR      "Fill Color  2 sometimes"         "White"
	SF-PATTERN		"Fill Pattern"				"Warning!"
	SF-ADJUSTMENT "Pattern Scale %" '(100 1 1000 1 50 0 0)
	SF-GRADIENT		"Fill Gradient"				"Golden"
	 SF-ENUM "Fill Gradient Mode" '("GradientType" "gradient-linear")
	SF-OPTION		"Fill gradient Direction" 		list-blend-ppf-dir
	SF-TOGGLE  "Gradient Reverse"    FALSE
	;SF-TOGGLE  "Fill Ripple"    FALSE
	SF-OPTION 		"Back Type" list-fill-ppf-dir
	SF-OPTION  	"Back Effect"    list-effect-ppf-dir
	SF-COLOR      "Back Color"         "White"
	SF-COLOR      "Back Color 2 sometimes"         '(255 0 255)
	SF-PATTERN    "Back Pattern"            "Pink Marble"
	SF-ADJUSTMENT "Pattern Scale %" '(100 1 1000 1 50 0 0)
	SF-GRADIENT   "Back Gradient" "Abstract 3"
	  SF-ENUM "Back Gradient Mode" '("GradientType" "gradient-linear")
  SF-OPTION		"Blend Direction" 		list-blend-ppf-dir
  	SF-TOGGLE  "Back Gradient Reverse"    FALSE
    SF-TOGGLE  "Apply Vignette"    FALSE
    	SF-COLOR		"Vignette Color"			'(0 0 0)
    SF-TOGGLE  "Apply Masks"    TRUE

) 

(script-fu-menu-register
	"script-fu-plastic-logo299o"
	; "<Toolbox>/Xtns/Logos"
	"<Image>/File/Create/Logos"
)

; FINgimp-selection-layer-alpha
