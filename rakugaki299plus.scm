; Rakugaki-plus299.scm Ver2.0 for Gimp 2.10 / 2.99  Etigoya
; Updated by Vitforlinux 9-2023 for Gimp 2.10.34 2.99.16
; You draw Ver1.0」 
; Draw the image randomly in a random color.
; If you apply this script to the work that you struggled with,
; You can enjoy a comfortable feeling of weakness ...

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

(define (script-fu-rakugaki-plus299 image drawable randpoint brush brush-size rotation rsize ctype color gradient)

(let* (
       (width (car (gimp-drawable-get-width drawable)))
       (height (car (gimp-drawable-get-height drawable)))
       (point 4)
       (count 1)
       (random-color)
       (segment)
       (r 0)(g 0)(b 0)
       (xa 0)(ya 0))
       
(gimp-context-push)
   (gimp-image-undo-group-start image)
   		(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY)
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (gimp-context-set-brush (car  brush)) 
  (gimp-context-set-brush   brush)	)
 
		(gimp-context-set-gradient-reverse TRUE)
		(gimp-context-set-gradient gradient)
		
		(gimp-context-set-brush-size  brush-size)
			
	(while (<= count randpoint)
      (set! r (rand 255))
      (set! g (rand 255))
      (set! b (rand 255))
      (set! random-color (list r g b))
     (if (= ctype 0)  (gimp-context-set-foreground random-color))
      (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics TRUE))
      (if (= ctype 1) (gimp-context-set-foreground color) (gimp-context-set-dynamics "Pressure Opacity"))
       (if (= ctype 2) (gimp-context-set-dynamics "Random Color"))
(if (= rotation 1) (gimp-context-set-brush-angle  (random 180 )))
(if (= rsize 1) (gimp-context-set-brush-size  (round (random brush-size ))))

      (set! segment (cons-array 4 'double))
      (set! xa (rand width))
      (set! ya (rand height))
      (aset segment 0 (* 1 xa))
      (aset segment 1 (* 1 ya))
      (aset segment 2 (* 1 xa))
      (aset segment 3 (* 1 ya))
      (gimp-paintbrush-default drawable point segment)
      (set! count (+ count 1)) )

   (gimp-image-undo-group-end image)
   (gimp-context-pop)
   (gimp-displays-flush) ))

(script-fu-register "script-fu-rakugaki-plus299"
_"Rakugaki-PLUS (Graffiti) 299..."
"Draw images randomly in random colors"
                    "越後屋 - Echigo"
                    "越後屋 - Echigo"
                    "2005/03/11"
                    "RGB* GRAY*"
                    SF-IMAGE      "Image"       0
                    SF-DRAWABLE   "Drawable"    0
                    SF-ADJUSTMENT "Power"  '(30 1 1000 1 10 0 1)
                    SF-BRUSH      "Brush"            '("Pencil Scratch" 1.0 20 0)
SF-ADJUSTMENT "Brush Max Size" '(35 1 1000 1 5 0 0)		    
		      SF-TOGGLE	"Random rotation?"			FALSE
		      SF-TOGGLE	"Random size?"			FALSE
		    SF-OPTION "Color type" '("Random Color" "Single Color" "Random from Gradient")
		      SF-COLOR      "Color"         '(255 255 255)
		      SF-GRADIENT		"Fill Gradient"		"Full saturation spectrum CCW"
		      )

(script-fu-menu-register "script-fu-rakugaki-plus299"
_"<Image>/Script-Fu/Alchemy")
