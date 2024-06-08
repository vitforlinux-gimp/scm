; Rakugaki299.scm Ver2.0 for Gimp 2.10 / 2.99  Etigoya
; Updated by Vitforlinux 10-2022
; You draw Ver1.0」 
; Draw the image randomly in a random color.
; If you apply this script to the work that you struggled with,
; You can enjoy a comfortable feeling of weakness ...

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))

		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
        (define sfbrush '("Pencil Scratch" 1.0 20 0))
  (define sfbrush "Pencil Scratch")	)

(define (script-fu-rakugaki299 image drawable randpoint brush)

(let* (
       
       ;(width (gimp-drawable-get-width drawable))
       ;(height (gimp-drawable-get-height drawable))
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
   (while (<= count randpoint)
      (set! r (rand 255))
      (set! g (rand 255))
      (set! b (rand 255))
      (set! random-color (list r g b))
      (gimp-context-set-foreground random-color)

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

(script-fu-register "script-fu-rakugaki299"
_"Rakugaki (Graffiti) 299..."
"Draw images randomly in random colors"
                    "越後屋 - Echigo"
                    "越後屋 - Echigo"
                    "2005/03/11"
                    "RGB* GRAY*"
                    SF-IMAGE      "Image"       0
                    SF-DRAWABLE   "Drawable"    0
                    SF-ADJUSTMENT "Power"  '(30 1 1000 1 10 0 1)
                    SF-BRUSH      "Brush"            sfbrush )

(script-fu-menu-register "script-fu-rakugaki299"
_"<Image>/Script-Fu/Alchemy")
