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
(define list-blend-dir '("Top-Botton" "Bottom-Top" "Left-Right" "Right-Left" "Diag-Top-Left" "Diag-Top-Right" "Diag-Bottom-Left" "Diag-Bottom-Right" "Diag-to-center" "Diag-from-center" "Center-to-Top center" "Center-to-Bottom center" ))
(define list-fill-dir '("Color" "Pattern" "Gradient" "Carbon fiber" "Aluminium Brushed" "Aluminium Brushed Light" "Blue Jeans" "Dark Jeans" "Bovination 2.10 only" "Camouflage 2.10 only"  "Bovination 2.99" "Camouflage 2.99" "Plasma" "None"  "Patchwork" "Diffraction" "Pizza" "Leopard" "Giraffe" "Zebra" "Leopard 2 colors" "Snake" "Snake 2 colors"))


; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))


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
				(gimp-context-set-pattern "Parque #3")
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
			
			
		(define (material-pattern pattern fond) (begin
				(gimp-context-set-pattern pattern)
				(gimp-drawable-fill fond FILL-PATTERN)
			))
			
		(define  (material-bovination fond image) (begin
				(plug-in-solid-noise 0 image fond 0 0 (random 65535) 1 16 4)
				    ;(gimp-brightness-contrast fond 0 127) ; cambiare!
				   ; (gimp-drawable-brightness-contrast fond 0.4 0.5)
				   (gimp-drawable-levels fond  0 0.1 0.4 FALSE 0.1 0.1 0.2 FALSE)
				   (gimp-drawable-brightness-contrast fond 0 0.5)
				   (gimp-drawable-brightness-contrast fond 0 0.5)
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
			))
		(define  (material-camo1 fond image) (begin
			(gimp-selection-none image)
				(plug-in-solid-noise 0 image fond 0 0 (random 65535) 1 16 4)
				    ;(gimp-brightness-contrast fond 0 127) ; cambiare!
				   ; (gimp-drawable-brightness-contrast fond 0.4 0.5)
				   (gimp-drawable-levels fond  0 0.1 0.4 FALSE 0.1 0.1 0.2 FALSE)
				   (gimp-drawable-brightness-contrast fond 0 0.5)
				   (gimp-drawable-brightness-contrast fond 0 0.5)
				    (gimp-drawable-brightness-contrast fond 0 0.5)
				    (gimp-image-select-color image 0 fond '(255 255 255) )
				    (gimp-selection-grow image 2)
				    	(gimp-context-set-foreground '(33 100 58) )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-invert image)
								    	(gimp-context-set-foreground '(170 170 60) )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-none image)
				 (gimp-image-select-color image 0 fond  '(33 100 58))
				 (gimp-selection-grow image 2)
				 (plug-in-solid-noise 0 image fond 0 0 (random 65535) 1 16 4)
				   (gimp-drawable-levels fond  0 0.1 0.4 FALSE 0.1 0.1 0.2 FALSE)
				(gimp-drawable-brightness-contrast fond 0 0.5)
				   (gimp-drawable-brightness-contrast fond 0 0.5)
				    (gimp-drawable-brightness-contrast fond 0 0.5)
				    (gimp-selection-none image)
					(gimp-image-select-color image 0 fond '(255 255 255) )
					(gimp-selection-grow image 2)
				    	(gimp-context-set-foreground '(33 100 58) )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
								    (gimp-selection-none image)
					(gimp-image-select-color image 0 fond '(0 0 0 ) )
					(gimp-selection-grow image 2)
									    	(gimp-context-set-foreground  '(150 115 100) )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-none image)
				    
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
		(define (material-none)  		)
		
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
	     (gimp-selection-none image)
	     (gimp-image-select-color image 0 fond '(0 0 0) )
	     (gimp-selection-grow image 3)
	     (gimp-context-set-foreground  '(255 0 0) )
				(gimp-drawable-edit-fill fond FILL-FOREGROUND)
				(gimp-selection-none image)
				(gimp-layer-set-lock-alpha fond TRUE)
	      (plug-in-oilify 1 image fond 20 0) 
			))
			

		(define  (material-leopard-old fond image) (begin
				          (gimp-selection-none image)    (material-bovination fond image)
	     (gimp-selection-none image)
	     (gimp-image-select-color image 0 fond '(255 255 255) )
	     (gimp-selection-shrink image 8)
	     (material-bovination fond image)
	       (gimp-image-select-color image 0 fond '(255 255 255) )
	     (gimp-selection-shrink image 8)
	     (material-bovination fond image)
	       (gimp-image-select-color image 0 fond '(255 255 255) )
	     (gimp-selection-shrink image 8)
	     (material-bovination fond image)
	       (gimp-image-select-color image 0 fond '(255 255 255) )
	     (gimp-selection-shrink image 8)
	     (material-bovination fond image)
		(gimp-image-select-color image 0 fond '(0 0 0) )
		(gimp-selection-shrink image 8)
		;(script-fu-distress-selection 1 image fond 127 8 4 2 1 1)
		;(gimp-drawable-edit-fill fond FILL-FOREGROUND)
		(gimp-selection-none image)
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
;MATERIAL END 
(define
	(
		apply-plastic-logo-effect
		img
		basetext
		border-color
		 border-size
		shadow-color
		type
		blurred-fill
		color
		color2
		pattern
		gradient
		gradient-type
		direction
		;ripple
		backtype
		fond-color
		fond-color2
                back-pattern
		back-gradient
		 back-gradient-type
		 blendir
		

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
				(material-pattern back-pattern fond)			
		)
		(if (= backtype 2) ;START gradient

	(begin
	(gimp-selection-none img)
	(gimp-drawable-fill fond FILL-BACKGROUND)
	(gimp-context-set-gradient back-gradient)
      (cond ((= blendir 0)         ; Top-Bottom 
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= blendir 1)           ; Bottom-Top
          (define x1 0)            ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= blendir 2)           ; Left-Right
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= blendir 3)           ; Right-Left
          (define x1 width)  ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
          ((= blendir 4)           ; Diag-Top-Left
          (define x1 0)            ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= blendir 5)           ; Diag-Top-Right
          (define x1 width)  ; X Blend Starting Point
          (define y1 0)            ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 height)   ; Y Blend Ending Point
          )
          ((= blendir 6)           ; Diag-Bottom-Left
          (define x1 0)            ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 width)    ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )

          ((= blendir 7)           ; Diag-Bottom-Right
          (define x1 width)  ; X Blend Starting Point
          (define y1 height) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  
	  ((= blendir 8)           ; Diag-to-center
          (define x1 0)  ; X Blend Starting Point
          (define y1 0) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2  (/ height 2))              ; Y Blend Ending Point
          )
	  
	  
	  ((= blendir 9)           ; Diag-from-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2 0)              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  	  ((= blendir 10)           ; center-to-top-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2 0)              ; Y Blend Ending Point
          )
	  
	  	  	  ((= blendir 11)           ; center-to-bottom-center
          (define x1 (/ width 2))  ; X Blend Starting Point
          (define y1 (/ height 2)) ; Y Blend Starting Point
          (define x2  (/ width 2))              ; X Blend Ending Point
          (define y2 height)              ; Y Blend Ending Point
          )
;          (else
;                 ; For later use.. 
;          )
       ) ;end cond
	;old(gimp-edit-blend fond BLEND-CUSTOM LAYER-MODE-NORMAL-LEGACY back-gradient-type 100 0 REPEAT-NONE back-reverse FALSE 3 0.2 TRUE x1 y1 x2 y2))
				(gimp-context-set-background fond-color)
			(gimp-context-set-foreground fond-color2)
	(gimp-drawable-edit-gradient-fill
	fond 
	;BLEND-CUSTOM 
	;LAYER-MODE-NORMAL-LEGACY
	back-gradient-type
	;100
	0
	REPEAT-NONE
	;back-reverse
	FALSE 
	;3
	0.2 TRUE x1 y1 x2 y2)
	)
			
		);END gradient
				(if (= backtype 3) 
(material-carbon fond)
			
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
(material-bovination fond img)
			
		)
	(if (= backtype 9) 
(material-camo1 fond img)
		)
	(if (= backtype 10) 
(material-bovination-2 fond img)
			
		)
	(if (= backtype 11) 
(material-camo2 fond img)
			
		)
	(if (= backtype 12) 
(material-plasma fond img)
			
		)
		(if (= backtype 13) 
(material-none)
			
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

		
		
		; composite text and channel
		(gimp-image-select-item img 0 basetext)
		(define chantext (car (gimp-selection-save img)))
		(define basetextmask (car (gimp-layer-create-mask basetext ADD-MASK-SELECTION)))
		(gimp-layer-add-mask basetext basetextmask)
		(define reflmask (car (gimp-layer-create-mask refl ADD-MASK-SELECTION)))
		(gimp-layer-add-mask refl reflmask)
		(gimp-selection-all img)
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
		(if (= type 0)
			(material-color color basetext)
		)
		(if (= type 1) 
			(material-pattern pattern basetext)
		)
		(if (= type 2) ;QUESTO
			(begin
				(gimp-context-set-gradient gradient)
								(gimp-context-set-background color)
			(gimp-context-set-foreground color2)
				(gimp-drawable-edit-gradient-fill 
					basetext 	; 
					gradient-type ;0 ;GRADIENT-LINEAR	; gradient type
					0				; opacity
					0				; offset
					100 				;
					0				; 
					0 ; FALSE			; dithering
					x1				; x1
					y1				; y1
					x2			; x2
					y2			; y2
				)
			)
		)

						(if (= type 3) 
(material-carbon basetext)
			
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
(material-bovination basetext img )
			
		)
														(if (= type 9) 
(material-camo1 basetext img )
			
		)
														(if (= type 10) 
(material-bovination-2 basetext img )
			
		)
														(if (= type 11) 
(material-camo2 basetext img )
			
		)
														(if (= type 12) 
(material-plasma basetext img )
			
		)
			(if (= type 13) 
(material-none)
			
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
		(gimp-selection-grow img (/ border-size 2))
		(gimp-selection-shrink img border-size)
		(gimp-selection-feather img 1)
		(gimp-selection-invert img)
		;(gimp-edit-cut border)
				(define bordmask (car (gimp-layer-create-mask border ADD-MASK-SELECTION)))
		(gimp-layer-add-mask border bordmask)
		; adding light reflect
		(gimp-image-insert-layer img refl 0 -1)
		(gimp-drawable-edit-clear refl)
		(gimp-image-select-ellipse img
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
		)
		(gimp-context-set-foreground '(255 255 255))
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
			100
			0
			0 ;FALSE
			(/ width 2)
			(* height 0.54)
			(/ width 2)
			(* height 0.05)
		)
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
					;(if 
		;(= ripple TRUE)		
		;(plug-in-ripple 1 img basetext 100 5 1 0 1 TRUE FALSE)

	;)

	
		(if (= blurred-fill 1) 
			(plug-in-gauss-iir TRUE img basetext 6 TRUE TRUE)
		)
		(if (= blurred-fill 2) 
			(gimp-layer-set-opacity basetext 64)
			(gimp-layer-set-opacity olight 33)
			(gimp-layer-set-opacity refl 33)
		)
		(if (= blurred-fill 3) 
			(gimp-layer-set-opacity basetext 33)
			(gimp-layer-set-opacity olight 15)
			(gimp-layer-set-opacity refl 15)
		)
		(if (= blurred-fill 4) 
		
			 (plug-in-oilify 1 img basetext 20 0)              ; Add olify effect
		)
		(if (= blurred-fill 5) 
		(plug-in-cubism 1 img basetext 15 9 1)               ; Add cubism effect
		)
		(if (= blurred-fill 6) 
		(plug-in-ripple 1 img basetext 100 5 1 0 1 TRUE FALSE)               ; Add ripple effect
		)
		
		    (if (= blurred-fill 7)
      (begin

        (set! effect-layer (car (gimp-layer-new-from-drawable basetext img))) ; New effect Layer
        (gimp-image-insert-layer img effect-layer 0 3) ; Add it to image
        (gimp-item-set-name effect-layer "Bumped")                             ; Name effect layer


        (set! bump-layer (car (gimp-layer-new-from-drawable basetext img))) ; New patten layer
        (gimp-context-set-pattern pattern)                             ; Make bump pattern active         
        (gimp-drawable-fill bump-layer FILL-PATTERN)                                     ; Fill with pattern
;
; Call bump map procedure (pattern bump)
;
        (plug-in-bump-map 
                     1              ; Interactive (0), non-interactive (1)
                     img            ; Input image
                     effect-layer   ; Input drawable
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
      )
    ) ; end
    		(gimp-layer-remove-mask border 0)
		(gimp-layer-remove-mask olight 0)
		(gimp-layer-remove-mask basetext 0)
		(gimp-layer-remove-mask shad 0)
		(gimp-layer-remove-mask refl 0)
		(gimp-context-pop)
	)
)



(define 
	(
		script-fu-plastic-logo299n-alpha
		img
		text-layer
		border-color
		 border-size
		shadow-color
		type
		blurred-fill
		color
		color2
		pattern
		gradient
		gradient-type
		direction
		;ripple
		backtype
		fond-color
		fond-color2
                back-pattern
		back-gradient
									          back-gradient-type
							          blendir
		)
	(begin
		(gimp-image-undo-disable img)
		(apply-plastic-logo-effect img text-layer border-color border-size shadow-color type blurred-fill color color2 pattern gradient gradient-type direction backtype fond-color fond-color2 back-pattern back-gradient back-gradient-type blendir)
		(gimp-image-undo-enable img)
		(gimp-displays-flush)
	)
)



(script-fu-register 	
	"script-fu-plastic-logo299n-alpha"
	"Polished Plastic Fun 299n alpha..."
	"Create a polished plastic logo alpha object"
	"Denis Bodor <lefinnois@lefinnois.net>"
	"Denis Bodor"
	"03/31/2005"
	""
	SF-IMAGE		"Image"			0
	SF-DRAWABLE		"Drawable"		0
	SF-COLOR		"Border Color"	'(0 0 0)
	SF-ADJUSTMENT "Border size" '(2 0 12 1 1 0 0)
	SF-COLOR		"Shadow Color"	'(50 50 50)
	SF-OPTION		"Fill with"		list-fill-dir
	SF-OPTION  	"Fill effect"    '("None" "Blur" "Transparent" "More Transparent" "Oilify" "Cubism" "Ripple" "Bump with pattern")
	SF-COLOR		"Fill Color"			'(255 0 255)
	SF-COLOR      "Fill Color  2 sometimes"         "White"
	SF-PATTERN		"Fill Pattern"		"Warning!"
	SF-GRADIENT		"Fill Gradient"		"Golden"
	SF-ENUM "Fill Gradient Mode" '("GradientType" "gradient-linear")
	SF-OPTION		"Fill gradient Direction" 		list-blend-dir
	;SF-TOGGLE  "Ripple"    FALSE
					 SF-OPTION "Background Type" list-fill-dir
    SF-COLOR      "Back Color"         "White"
    SF-COLOR      "Back Color 2 sometimes"         '(255 0 255)
  SF-PATTERN    "Back Pattern"            "Pink Marble"
  SF-GRADIENT   "Back Gradient" "Abstract 3"
    SF-ENUM "Back  Gradient Mode" '("GradientType" "gradient-linear")
  SF-OPTION		"Blend Direction" 		list-blend-dir
)

(script-fu-menu-register 
	"script-fu-plastic-logo299n-alpha"
	"<Image>/Filters/Alpha to Logo"
)

(define
	(
		script-fu-plastic-logo299n
		font
		size
		text
											  justify
									  letter-spacing
									  line-spacing
		border-color
		border-size
		shadow-color
		
		type						; Color=0 Pattern=1 Gradient=2
		blurred-fill
		color
		color2
		pattern
		gradient
		gradient-type
		direction
		;ripple
		backtype
		     fond-color
		     fond-color2
                back-pattern
		back-gradient
											          back-gradient-type
							          blendir
	)
  
	(let*
		(
			(img (car (gimp-image-new 256 256 RGB)))	; nouvelle image -> img
			(border (/ size 4))
			(text-layer (car (gimp-text-fontname img -1 0 0 text border TRUE size PIXELS font)))
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
			

		(gimp-image-undo-disable img)
		(gimp-item-set-name text-layer text)
		(apply-plastic-logo-effect img text-layer border-color border-size shadow-color type blurred-fill color color2 pattern gradient gradient-type direction  backtype fond-color fond-color2 back-pattern back-gradient back-gradient-type blendir)

		;(plug-in-waves 1 img text-layer 100 180 50 0 FALSE)
		(gimp-image-undo-enable img)
		(gimp-display-new img)    
    )
)


(script-fu-register
	"script-fu-plastic-logo299n"
	"Polished Plastic Fun 299n"
	"Create a polished plastic logo"
	"Denis Bodor <lefinnois@lefinnois.net>"
	"Denis Bodor"
	"03/31/2005"
	""
	SF-FONT			"Font Name"				"Blippo Heavy"
		SF-ADJUSTMENT	"Font size (pixels)"	'(150 2 1000 1 10 0 1)
	SF-TEXT		"Enter your text"		"PLASTIC FUN"
	SF-OPTION "Justify" '("Centered" "Left" "Right")
	SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
	SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
	SF-COLOR		"Border Color"			'(0 0 0)
	SF-ADJUSTMENT "Border size" '(2 0 12 1 1 0 0)
	SF-COLOR		"Shadow Color"	'(50 50 50)
	SF-OPTION		"Fill with"				list-fill-dir
	SF-OPTION  	"Fill Effect"    '("None" "Blur" "Transparent" "More Transparent" "Oilify" "Cubism" "Ripple" "Bump with pattern")
	SF-COLOR		"Fill Color"					'(255 0 255)
	SF-COLOR      "Fill Color  2 sometimes"         "White"
	SF-PATTERN		"Fill Pattern"				"Warning!"
	SF-GRADIENT		"Fill Gradient"				"Golden"
	 SF-ENUM "Fill Gradient Mode" '("GradientType" "gradient-linear")
	SF-OPTION		"Fill gradient Direction" 		list-blend-dir
	;SF-TOGGLE  "Fill Ripple"    FALSE
	SF-OPTION 		"Back Type" list-fill-dir
	SF-COLOR      "Back Color"         "White"
	SF-COLOR      "Back Color 2 sometimes"         '(255 0 255)
	SF-PATTERN    "Back Pattern"            "Pink Marble"
	SF-GRADIENT   "Back Gradient" "Abstract 3"
	  SF-ENUM "Back Gradient Mode" '("GradientType" "gradient-linear")
  SF-OPTION		"Blend Direction" 		list-blend-dir
) 

(script-fu-menu-register
	"script-fu-plastic-logo299n"
	; "<Toolbox>/Xtns/Logos"
	"<Image>/File/Create/Logos"
)

; FINgimp-selection-layer-alpha
