; Random Font Text rel 5.2 
; Created by Graechan and GnuTux
; You will need to install GMIC to run the cube option in this Scipt
; GMIC can be downloaded from http://sourceforge.net/projects/gmic/files/
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
; Rel 0.02 - Added Palette selection or (random RGB color choice) for color Choice; option for rotation threshold, option to bumbmap letters
; Rel 0.03 - Added 'Random color from random palette' to color choices, moved cornercurl back to toggle 
;            Added bumpmap, chisel and 'inner shadow' to 'Text Effects'
;            Added the options to lock the font and color
; Rel 0.04 - Added Text output options
; Rel 0.05 - Added Text 0n cubes option{THIS OPTION REQUIES GMIC}, option to square the text layers and option to add an individual Bkg color to layers
; Rel 0.5.1 - Improved rendering
; Rel 0.5.2 - Improved GUI, and added font name to layers if Text Output Options = Each Character On Separate Layer
; slight update for gimp 2.10 and gimp_gimp_qt  - rich - 31 July 2021
; Rel 0.5.4 - now works with 4 colors palette without errors.
;
;;;; define default pattern
(define default-pattern
    (let* (
           (pat FALSE) 
           (default-patternId " ")
           )
    (map (lambda (x) (if (string=? x "paper_4") (set! pat TRUE))) (cadr (gimp-patterns-get-list "")))
    (cond ((= pat TRUE)
    (set! default-patternId "paper_4"))
    (else (set! default-patternId "Crinkled Paper"))))
    (list default-patternId)    
) ;end defaut-pattern proceedure
;       
; Include layer Procedure
(define (include-layer image newlayer oldlayer stack)   ;stack 0=above 1=below
    (cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
            (+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.8 
          )
          (else
           (gimp-image-add-layer image newlayer (+ (car (gimp-image-get-layer-position image oldlayer)) stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end include layer procedure
;
(define (script-fu-random-font-text
                text        ;text input
                font-size   ;font size
                font-color  ;font color options 
                palette     ;selected palette
                locked-color ;locked color
                lower       ;rgb lower limit  
                upper       ;rgb upper limit  
                font-filter ;font filter
                font-in     ;locked font
                rot-let     ;letter rotation
                text-output ;text output options
                text-effect ;text effect (0=none 1=bump 2=chisel 3=stroke 4= Inner shadow)
                effect-color ;sroke or inner shadow color
                stroke-radius ;text stroke Radius
                effect-blur  ;inner shadow blur
                layerOutline ;layer outline
                brush-size  ;outline brush size
                lyr-bkg     ;apply color to the layer background
                square      ;square the text layers
                lcurl       ;layer curl
                cube        ;text in cubes
                bkg-type    ;bkg type (0=none 1=pattern 2=color 3=transparency)
                bkg-pattern ;background pattern
                bkg-color   ;background color
        )
                     

(let* (
         (width 3000)           ;width flag (set to initial image width)
         (height 3000)          ;height flag (set to initial image height)
         (offx (/ font-size 4)) ;X offset flag
         (offy (/ font-size 4)) ;Y offset flag
         (image (car (gimp-image-new width height RGB))) ;image
         (font (if (> (string-length font-in) 0) font-in (car (gimp-context-get-font))))
         (bkg-layer 0)
         (text-layer 0)
         (activeLayer 0)
         (effect-layer 0)
         (effect-channel 0)
         (effect-mask 0)
         (ver 2.8)             ;gimp version flag
         (letterList ())
         (letter 0)
         (random-font 0)        ;font flag
         (random-color 0)       ;color flag
         (random-rotation 0)    ;rotation flag
         (center-x 0)           ;layer center X flag
         (center-y 0)           ;layer center Y flag
         (f1 FALSE)             ;f1 flag space detect
         (f2 FALSE)             ;f2 flag line detect
         (f3 FALSE)             ;f3 flag layerOutline brush detect
         (f4 FALSE)             ;f4 flag channel detect
         (f5 FALSE)             ;f5 flag textOutline brush detect
         (r 0)                  ;(r)gb random 
         (g 0)                  ;r(g)b random
         (b 0)                  ;rg(b) random
         (ffilter 0)            ;Font Filter
         (name "")              ;name flag
         (flatten-color 0)      ;flatten color flag
         (size 0)               ;size flag
         (n 1)                  ;line number flag
        )
   (cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
   
   (gimp-context-push)
   (gimp-context-set-paint-method "gimp-paintbrush")
   (if (= ver 2.8) (gimp-context-set-dynamics "Dynamics Off"))
   (gimp-context-set-foreground '(0 0 0))
   (gimp-context-set-background '(255 255 255))
   (gimp-context-set-antialias TRUE)
   

;;;;begin the script

  (set! *seed* (car (gettimeofday))) ; Random Number Seed From Clock (*seed* is global) 
  (random-next)                      ; Next Random Number Using Seed 

   (if (= font-color 1) ;select pallete at random 
     (begin
      (set! palette (vector-ref (list->vector (cadr (gimp-palettes-get-list "")))
            (rand (car (gimp-palettes-get-list "")))))                ;get random palette 
      (gimp-palettes-set-palette palette)                            ; set random palette
     )  
   )
   
   (set! letterList (map (lambda (x) (make-string 1 x)) (string->list text))) ;create the list of letters

   (while (not (null? letterList))
   
   (set! letter (car letterList))                                   ;aquire the next letter
   (if (string=? letter " ") (begin                                 ;check if letter is valid (not space)
   (set! letter "-")                                                ;change the letter to valid text
    (set! f1 TRUE)                                                   ;set the f1 flag
   )) ;endif
   
   (if (string=? letter "\n") (begin                                ;check if letter is valid (not \n)
   (set! letter "-")                                                ;change the letter to valid text
    (set! f2 TRUE)                                                   ;set the f2 flag
   )) ;endif

   (if (= font-filter 0)                                            ;Font Filter Options
   (begin
     (set! ffilter "")
    ))
   (if (= font-filter 1)
   (begin
     (set! ffilter "Bold")
    ))
   (if (= font-filter 2)
   (begin
     (set! ffilter "Italic")
    ))
   
   (if (< font-filter 3) 
   (begin
   (set! random-font (list-ref (cadr (gimp-fonts-get-list ffilter))  
   (round (random (car (gimp-fonts-get-list ffilter))))))            ;select random font
   ))
   
   (if (= font-filter 3)
   (set! random-font font)
   )

   ; Color Options 
   ;
   (if (= font-color 0) 
     (begin
      (set! random-color (car (gimp-palette-entry-get-color palette
       (- (random  (car (gimp-palette-get-colors palette))) 1)
)))          ;random color from palette 
     )  
   )
   (if (= font-color 1) 
     (begin
       (set! random-color (car (gimp-palette-entry-get-color palette
         (- (random  (car (gimp-palette-get-colors palette))) 1)
	 )))          ;random color from palette 
     )  
   )

   (if (= font-color 2)
     (begin

     (if (> lower upper)                               ;make sure lower is >= upper 
         (set! lower (- upper 1))
     )

       (set! r (+ (rand (- upper lower)) lower))       ;caculate random number range 
       (set! g (+ (rand (- upper lower)) lower))
       (set! b (+ (rand (- upper lower)) lower))

       (set! random-color (list r g b))  ;select random color 
     )  
   )
   (if (= font-color 3)
     (begin
       (set! random-color locked-color)
     )
   )     

   (gimp-context-set-foreground random-color)    ;set foreground color                    
   (set! text-layer (car (gimp-text-fontname                        ;create a new text layer
              image ;image
           -1 ;drawable { The affected drawable: (-1 for a new text layer)}
           0 ;x The x coordinate for the left of the text bounding box
           0 ;y The y coordinate for the top of the text bounding box
           letter ;text The text to generate (in UTF-8 encoding)(symbol->string letter) ;
           0 ;border The size of the border (border >= -1)
           TRUE ;antialias Antialiasing (TRUE or FALSE)
           font-size ;size The size of text in either pixels or points (size >= 0)
           PIXELS ;size-type The units of specified size { PIXELS (0), POINTS (1) }
           random-font))) ;fontname The name of the font
   (set! activeLayer (car (gimp-image-get-active-layer image)))    ;assign the new layer as "activeLayer"
;;;;------------------------------------------------------------------------------------------------------create the text effects   
   (if (or (= text-effect 1) (= text-effect 3) (= text-effect 4))
   (begin
   (gimp-selection-layer-alpha activeLayer)
   (set! effect-channel (car (gimp-selection-save image))) ;(gimp-selection-load effect-channel)
   (gimp-selection-none image)
   (set! f4 TRUE)
   )) ;endif
   
   (if (= text-effect 1) (begin ;-------------------------------------------------------------------------------------------------------bumpmap   
   (plug-in-bump-map RUN-NONINTERACTIVE image activeLayer effect-channel 135 45 5 0 0 0 0 TRUE FALSE 0) ;bumpmap the activeLayer   
   )) ;endif
   
   (if (= text-effect 2) (begin ;-------------------------------------------------------------------------------------------------------chisel
   (rft-chisel image activeLayer 20 5 0 0 135 30 20 0 0 0 FALSE)
   (set! activeLayer (car (gimp-image-merge-down image (car (gimp-image-get-active-layer image)) EXPAND-AS-NECESSARY)))
   )) ;endif 
   
   (if  (= text-effect 3) (begin ;------------------------------------------------------------------------------------------------------color stroke
   (gimp-selection-load effect-channel)

   (set! effect-layer (car (gimp-layer-copy activeLayer TRUE))) ;create and add effect-layer
   (include-layer image effect-layer activeLayer 0) ;stack 0=above 1=below
   (gimp-context-set-foreground effect-color)       ;set the stroke color
   (gimp-edit-fill effect-layer FILL-FOREGROUND)  ;fill background with text color
   (gimp-selection-shrink image stroke-radius)
   (gimp-edit-clear effect-layer)
   (gimp-selection-none image)  

   (set! activeLayer (car (gimp-image-merge-down image effect-layer EXPAND-AS-NECESSARY)))
   (gimp-context-set-foreground random-color)    ;set foreground color
   )) ;endif
   
   (if  (= text-effect 4) (begin ;----------------------------------------------------------------------------------------------Inner shadow
   (set! effect-layer (car (gimp-layer-copy activeLayer TRUE)))
   (include-layer image effect-layer activeLayer 0) ;stack 0=above 1=below
   (gimp-context-set-foreground effect-color)
   (gimp-selection-load effect-channel)
   (gimp-edit-fill effect-layer FILL-FOREGROUND)
   (gimp-selection-invert image)
   
   (set! effect-mask (car (gimp-layer-create-mask effect-layer ADD-MASK-SELECTION)))
   (gimp-layer-add-mask effect-layer effect-mask)
   
   (gimp-selection-none image)
   (plug-in-gauss-rle2 RUN-NONINTERACTIVE image effect-mask effect-blur effect-blur)
   (set! activeLayer (car (gimp-image-merge-down image effect-layer EXPAND-AS-NECESSARY)))
   (gimp-context-set-foreground random-color)                               ;reset foreground color
   )) ;endif

   (if (= f4 TRUE) (gimp-image-remove-channel image effect-channel))        ;remove the channel
   
   (if (and (= cube FALSE) (= square FALSE))
     (begin
   (if (= lyr-bkg TRUE)
    (begin
    (set! bkg-layer (car (gimp-layer-copy activeLayer TRUE))) ;create and add bkg-layer
    (include-layer image bkg-layer activeLayer 1)   ;stack 0=above 1=below
    (gimp-drawable-fill bkg-layer FILL-FOREGROUND)  ;fill background with text color
    (gimp-invert bkg-layer)                         ;invert background color
    (set! activeLayer (car (gimp-image-merge-down image activeLayer EXPAND-AS-NECESSARY)))
    )
   ) ;endif
    )
   ) ;endif
    
 ;;;;----------------------------------------------------------------------------------------------------------------resize for cube text
    (if (or (= cube TRUE) (= square TRUE))
     (begin
    (set! size (max (car (gimp-drawable-width activeLayer)) (car (gimp-drawable-height activeLayer)))) ;set the size flag
    (gimp-layer-resize activeLayer 
    size ;set the new width 
    size ;set the new height 
    (/ (- size (car (gimp-drawable-width activeLayer))) 2) ;set xoff 
    (/ (- size (car (gimp-drawable-height activeLayer))) 2)) ;set yoff
    
    (if (or (= cube TRUE) (= lyr-bkg TRUE))
     (begin
    (set! bkg-layer (car (gimp-layer-copy activeLayer TRUE))) ;create and add bkg-layer
    (include-layer image bkg-layer activeLayer 1)   ;stack 0=above 1=below
    (gimp-drawable-fill bkg-layer FILL-FOREGROUND)  ;fill background with text color
    (gimp-invert bkg-layer)                         ;invert background color
    
    (set! activeLayer (car (gimp-image-merge-down image activeLayer EXPAND-AS-NECESSARY)))
     )
    ) ;endif
     )
    ) ;endif
    
   
   (gimp-layer-set-offsets activeLayer offx offy)                           ;offset the activeLayer
   
   (set! center-x (+ offx (/ (car (gimp-drawable-width activeLayer)) 2)))   ;get the x-center of layer
    (set! center-y (+ offy (/ (car (gimp-drawable-height activeLayer)) 2))) ;get the y-center of layer
   ;outline and pagecurl the active layer here----------------------------------------------------------------------------------------------------
   (if (= layerOutline TRUE)                                      ;create layer ouline
    (begin                                                            
   (gimp-rect-select image                                        ;select the activeLayer
                        (car (gimp-drawable-offsets activeLayer))
                        (cadr (gimp-drawable-offsets activeLayer))
                        (car (gimp-drawable-width activeLayer))
                        (car (gimp-drawable-height activeLayer))
                  CHANNEL-OP-REPLACE ;operation
                  FALSE ;feather
                  10)  ;feather radious   
                          
   (set! bkg-layer (car (gimp-layer-copy activeLayer TRUE))) ;create and add bkg-layer
   (include-layer image bkg-layer activeLayer 0)    ;stack 0=above 1=below
   (gimp-context-set-foreground random-color)
   (gimp-drawable-fill bkg-layer FILL-FOREGROUND)  ;fill background with text color
   (gimp-selection-shrink image brush-size)
   (gimp-edit-clear bkg-layer)
   (gimp-selection-none image)   
   (set! activeLayer (car (gimp-image-merge-down image bkg-layer EXPAND-AS-NECESSARY)))
    )
   ) ;endif
     
   (if (= lcurl TRUE)                                             ;create a layer corner curl
    (begin
   (gimp-rect-select image                                        ;select the 'lower right' of activeLayer
                        center-x
                        center-y
                        (car (gimp-drawable-width activeLayer))
                        (car (gimp-drawable-height activeLayer))
                        CHANNEL-OP-REPLACE ;operation
                        FALSE ;feather
                        10)  ;feather radious


     (plug-in-pagecurl 1 image activeLayer 0 1 1 1)               ;run Pagecurl plugin
     (set! activeLayer (car (gimp-image-merge-down image (car (gimp-image-get-active-layer image)) EXPAND-AS-NECESSARY)))
     (gimp-selection-none image)                                  ;remove the selection
    (if (= cube TRUE) 
     (begin
    (set! bkg-layer (car (gimp-layer-copy activeLayer TRUE))) ;create and add bkg-layer
    (include-layer image bkg-layer activeLayer 1)   ;stack 0=above 1=below
    (gimp-context-set-pattern "Wood #2")         ;set the pattern
    (gimp-drawable-fill bkg-layer FILL-PATTERN)  ;fill background with pattern
    (set! activeLayer (car (gimp-image-merge-down image activeLayer EXPAND-AS-NECESSARY)))
    
    )
   ) ;endif
    )
   ) ;endif    
   
   (if (defined? 'plug-in-gmic-qt)
    (begin
   
   (if (= cube TRUE) 
    (begin
   ; *******************************************start 3d image object   
    
            
                
                    ;; Matching variables
                    (set! activeLayer (car (gimp-image-get-active-layer image)))             ;set the activeLayer
                    (set! width (car (gimp-drawable-width activeLayer)))                     ;set the width
                    (set! height (car (gimp-drawable-height activeLayer)))                   ;set the height                               
                    
                    
                ;; Render Imageobject3d using G'MIC.
                (plug-in-gmic-qt 1 image activeLayer 1 0
                    (string-append
                        "-v - " ; To have a silent output. Remove it to display errors from the G'MIC interpreter on stderr.
                        "fx_imageobject3d 1,"
                        (number->string width) ","
                        (number->string height) ",0.56,57,41,21,45,0,0,-100,0,0,4,1"         
                    )
                )       
        
; *******************************************end 3d image object
    (set! activeLayer (car (gimp-image-get-active-layer image)))    ;assign the new layer as "activeLayer"
    )
   ) ;endif
    )
   ) ;endif 
    (if (= text-output 0)
     (begin
    (gimp-drawable-set-name activeLayer (string-append letter "\n" random-font)))
     (begin
    (gimp-drawable-set-name activeLayer letter)                     ;restore the layers correct name
     )
    )
    (gimp-hue-saturation activeLayer 0 0 -70 100)
    
   (if (> rot-let 0) 
    (begin
   (set! random-rotation (/ (- (random rot-let) (/ rot-let 2)) 100))                 ;set the rotation threshold angle 
   (gimp-drawable-transform-rotate-default activeLayer random-rotation TRUE center-x center-y TRUE 0)
    )
   ) ;endif
   
   (gimp-layer-set-offsets activeLayer offx offy)                  ; offset the activeLayer
   
   (set! offx (+ offx (car (gimp-drawable-width activeLayer))))    ;set the x offset
   
   (if (= f2 TRUE)                                                 ;check if f2 flag has been set
    (begin                                          
   (gimp-image-remove-layer image activeLayer)                     ;remove the current layer
   (gimp-image-resize-to-layers image)                             ;set the image size
   (set! offx 0)                                                   ;set the offx flag
   (set! offy (car (gimp-image-height image)))                     ;set the offy flag   
    )
   ) ;endif
   
   (if (= f1 TRUE)                                                 ;check if f1 flag has been set
    (begin                                          
   (gimp-image-remove-layer image activeLayer)                     ;remove the current layer   
    )
   ) ;endif
   
   (if (= text-output 1) ;--------------------------------individual words
    (begin
   (if (and (= f1 FALSE) (= f2 FALSE))
    (begin
   (set! name (string-append name (car (gimp-drawable-get-name activeLayer))))
    )
   )
    )
   )
   
   (if (= text-output 2) ;---------------------------------individual lines
    (begin
   (if (and (= f1 FALSE) (= f2 FALSE))
    (begin
   (set! name (string-append name (car (gimp-drawable-get-name activeLayer))))
    )
   )
   (if (and (= f1 TRUE) (= f2 FALSE))
    (begin
   (set! name (string-append name " "))
    )
   )
    )
   )
   
   (gimp-image-resize image 3000 3000 0 0)                         ;resize the image for next line
   
   
;;;;----------------------------------------------------------------------------------------------------set text output options here
   (if (= text-output 1) ;--------------------------------individual words
    (begin
   (if (or (= f1 TRUE) (= f2 TRUE))
    (begin
   (set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))                ;merge the text layers
   (gimp-drawable-set-name text-layer name)
   (set! name "")
   (gimp-drawable-set-visible text-layer FALSE)
    )
   )
    )
   )

   (if (= text-output 2) ;---------------------------------individual lines
    (begin
   (if (= f2 TRUE)
    (begin
   (set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))                ;merge the text layers
   (gimp-drawable-set-name text-layer (string-append "Line" (number->string n) "\n" name))
   (set! name "")
   (gimp-drawable-set-visible text-layer FALSE)
   (set! n (+ n 1))
    )
   )
    )
   )

   (set! f1 FALSE)                                                 ;reset the f1 flag
   (set! f2 FALSE)                                                 ;reset the f2 flag
   
   (set! letterList (cdr letterList))
   ) ;endwhile
   
   (if (= text-output 1)
    (begin
   (set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))                ;merge the text layers
   (gimp-drawable-set-name text-layer name)
   (map (lambda (x) (gimp-drawable-set-visible x TRUE)) (vector->list (cadr (gimp-image-get-layers image))))
    )
   )
   (if (= text-output 2) ;---------------------------------individual lines
    (begin
   (set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))                ;merge the text layers
   (gimp-drawable-set-name text-layer (string-append "Line" (number->string n) "\n" name))
   (map (lambda (x) (gimp-drawable-set-visible x TRUE)) (vector->list (cadr (gimp-image-get-layers image))))
    )
   )
   
   (if (= text-output 3) 
    (begin
   (set! text-layer (car (gimp-image-merge-visible-layers image EXPAND-AS-NECESSARY)))                ;merge the text layers
   (gimp-drawable-set-name text-layer text)                                                      ;name the merged text-layers
    )
   )
   
   (gimp-image-resize-to-layers image)                             ;set the image size
   (set! width (car (gimp-image-width image)))                     ;set the width
   (set! height (car (gimp-image-height image)))                   ;set the height
   
   (script-fu-reverse-layers image (car (gimp-image-get-active-layer image)))                        ;reverse layer order

   (if (> bkg-type 0) (begin
   (set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY))) ;create and add the bkg-layer
   (cond ((= ver 2.8)                                                                                 ;insert or add the new bkg layer
   (gimp-image-insert-layer image bkg-layer 0 0)) ;new layer 2.8
   (else (gimp-image-add-layer image bkg-layer 0)) ;new layer 2.6
   ) ;endcond
   (gimp-image-lower-layer-to-bottom image bkg-layer)                                                 ;lower bkg-layer to bottom of stack
   )) ;endif   
   
   (gimp-context-set-pattern bkg-pattern)                                                             ;set the active pattern
   (gimp-context-set-background bkg-color)
   (if (= bkg-type 1) (gimp-drawable-fill bkg-layer FILL-PATTERN))                                    ;fill the bkg-layer with pattern
   (if (= bkg-type 2) (gimp-drawable-fill bkg-layer FILL-BACKGROUND))                                 ;fill the bkg-layer with color
   
   
   
   (if (= font-color 1) (begin
   (let ((handler (car (gimp-message-get-handler))))
   (gimp-message-set-handler 0) ;{ MESSAGE-BOX (0), CONSOLE (1), ERROR-CONSOLE (2) }
   (gimp-message (string-append "Random palette used is" " " palette))
   (gimp-message-set-handler handler))
   )) ;endif
   
;;;;finish the script   
      
   (gimp-display-new image)
   (gimp-displays-flush)
   (gimp-context-pop)
   
)
)

(script-fu-register "script-fu-random-font-text"                 
  "Random Font Text..."
  "Creates text with each letter having a different font. Options include user configurable font size, choice of filter for random font selection, 
  background pattern, letter effects, random rotation of each letter, letter outline, curl and layer merging. "
  "Graechan & GnuTux"
  "Graechan - http://gimpchat.com"
  "July 2014"
  ""
  SF-TEXT       "Text"                  "Random\nFont Text"
  SF-ADJUSTMENT "Font Size (pixels)"    '(200 6 500 1 1 0 1)
  SF-OPTION     "Font Color"            '("Random From Selected Color Palette" "Random From Random Color Pallete" "Random RGB Color From Range" "Locked Color")
  SF-PALETTE    "Color Palette"          "Named Colors"
  SF-COLOR      "Locked Color"          '(0 255 0)
  SF-ADJUSTMENT "RGB Color Range Start" '(0 0 255 1 5 0 0) 
  SF-ADJUSTMENT "RGB Color Range End"   '(255 1 255 1 5 0 0) 
  SF-OPTION     "Font Filter"           '("All Fonts" "Bold Fonts Only" "Italic Fonts Only" "Use Locked Font")
  SF-FONT       "Locked Font"           "Serif Bold"
  SF-ADJUSTMENT "Font Rotation 0=Off"   '(0 0 180 1 10 0 0)
  SF-OPTION     "Text Output Options"   '("Each Character On Separate Layer" "Each Word On Separate Layer" "Each Line On Separate Layer" "All Text On Single Layer")
  SF-OPTION     "Text Effect"           '("None" "Bump" "Chisel" "Stroke" "Inner Shadow")
  SF-COLOR      "Stroke/Shadow Color"   "Black"
  SF-ADJUSTMENT "Stroke Width"          '(1 1 15 1 1 0 0)
  SF-ADJUSTMENT "Shadow Blur Radius"    '(20 0 50 1 5 0 0)
  SF-TOGGLE     "Text Border Outline"    FALSE
  SF-ADJUSTMENT "Border Outline Width"  '(4 1 10 1 1 0 0)
  SF-TOGGLE     "Color Each Character's Background" FALSE
  SF-TOGGLE     "Square Layers"          FALSE
  SF-TOGGLE     "Corner Curl"            FALSE
  SF-TOGGLE     "Cubes {Requires GMIC}"  FALSE  
  SF-OPTION     "Image Background"           '("None" "Pattern" "Color" "Transparency")
  SF-PATTERN    "Image Background Pattern"    default-pattern
  SF-COLOR      "Image Background Color"      "White"
)

(script-fu-menu-register "script-fu-random-font-text" "<Image>/Script-Fu/Logos/")

;--------------------------------------------------------------------------------------------------------
(define (rft-chisel img inLayer inWidth inSoften inCurve inPow inAizmuth inElevation inDepth inMode inLocation inBlur inKeepBump)
  (let*
    (
       (varNoSelection (car (gimp-selection-is-empty img)))
       (inPow (- 0 inPow))
       (varSavedSelection 0)
       (varBlurredSelection 0)
       (varBumpmapLayer)
       (varBevelLayer)
       (varLoopCounter 1)
       (varFillValue)
       (varNumBytes 256)
       (varAdjCurve    (cons-array varNumBytes 'byte))
       (varLayerName (car (gimp-drawable-get-name inLayer)))
    )
    ;  it begins here
    (gimp-context-push)
    (gimp-image-undo-group-start img)
    
    ;save selection or select all if no selection
    (if (= varNoSelection TRUE)
      (if (= (car (gimp-drawable-has-alpha inLayer)) TRUE)  ;check for alpha
        (gimp-selection-layer-alpha inLayer) ;  transfer the alpha to selection
        (gimp-selection-all img)  ;else select the whole image
      )
    )
    (set! varSavedSelection (car (gimp-selection-save img)))
    
    (set! varBumpmapLayer (car (gimp-layer-new-from-drawable inLayer img)))
    (gimp-drawable-set-name varBumpmapLayer (string-append varLayerName " bumpmap"))
    (gimp-image-add-layer img varBumpmapLayer -1)
    (if (= inLocation 1) ;if outside, enlarge the layer canvas
      (gimp-layer-resize varBumpmapLayer (+ (car (gimp-drawable-width inLayer)) (* 2 inWidth))
                                       (+ (car (gimp-drawable-height inLayer)) (* 2 inWidth))
                                       inWidth
                                       inWidth)
    )
    
    ;blur selection for soft chisel
    (gimp-selection-feather img inSoften)
    (set! varBlurredSelection (car (gimp-selection-save img)))
    
    ;when shrinking check selection size and reset inWidth if necessary
    (when (= inLocation 0)
      (set! varLoopCounter inWidth)
      (gimp-selection-shrink img varLoopCounter)
      (while (= (car (gimp-selection-is-empty img)) TRUE)
        (set! varLoopCounter (- varLoopCounter 1))
        (gimp-selection-load varBlurredSelection)   
        (gimp-selection-shrink img varLoopCounter)
        ;(gimp-progress-set-text "Chiseling...")
        ;(gimp-progress-pulse)
      )
      ;(gimp-progress-set-text "")
      (set! inWidth (min inWidth varLoopCounter))
      (gimp-selection-load varBlurredSelection) 
    )
    
    ; create bevel in bumpmap layer black to white
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-fill varBumpmapLayer FILL-FOREGROUND)

    (set! varLoopCounter 1)
    (while (<= varLoopCounter inWidth)
      ;inCurve of 0 will be flat, inCurve of 1 is a quarter round, inCurve of -1 is a quarter round fillet
      (set! varFillValue (* (pow (+ (* (- (sin (* (/ varLoopCounter inWidth) (tan 1))) (/ varLoopCounter inWidth)) inCurve) (/ varLoopCounter inWidth)) (pow 2 inPow)) 255))
      
      ;avoid distortion
      (gimp-selection-load varBlurredSelection) 
      
      (if (= inLocation 0)
        (gimp-selection-shrink img (- varLoopCounter 1)) ;inside
        (gimp-selection-grow img (- inWidth (- varLoopCounter 1))) ;outside
      )
      
      (gimp-context-set-foreground (list varFillValue varFillValue varFillValue)) ;shade of grey
        
      (if (= (car (gimp-selection-is-empty img)) FALSE)
        (gimp-edit-fill varBumpmapLayer FILL-FOREGROUND) 
        (gimp-edit-fill varBumpmapLayer FILL-FOREGROUND) ; second time to blend better
        (set! varLoopCounter (+ inWidth 1))
      )
        
      (set! varLoopCounter (+ varLoopCounter 1))
    )

    ;finish up with white
    (gimp-context-set-foreground (list 255 255 255)) ;white
    (gimp-selection-load varBlurredSelection)   
    (if (= inLocation 0)
        (gimp-selection-shrink img inWidth) ;inside
    )   
    (if (= (car (gimp-selection-is-empty img)) FALSE)
      (gimp-edit-fill varBumpmapLayer FILL-FOREGROUND) 
      (gimp-edit-fill varBumpmapLayer FILL-FOREGROUND)  ; second time to blend better
    )

    (gimp-selection-none img) 
    
    ;make bevel from  bumpmap
    (set! varBevelLayer (car (gimp-layer-new-from-drawable inLayer img)))
    (gimp-drawable-set-name varBevelLayer (string-append varLayerName " bevel"))
    (gimp-image-add-layer img varBevelLayer -1) 
    (if (= inLocation 1) ;if outside, enlarge the layer canvas
      (gimp-layer-resize varBevelLayer (+ (car (gimp-drawable-width inLayer)) (* 2 inWidth))
                                       (+ (car (gimp-drawable-height inLayer)) (* 2 inWidth))
                                       inWidth
                                       inWidth)
    )

    (gimp-context-set-foreground '(127 127 127))
    (gimp-drawable-fill varBevelLayer FILL-FOREGROUND)

    (plug-in-bump-map RUN-NONINTERACTIVE img varBevelLayer varBumpmapLayer inAizmuth inElevation inDepth 0 0 0 0 
                      TRUE (cond ((= inMode 0) FALSE) ((= inMode 1) TRUE)) 1)
    (gimp-layer-set-mode varBevelLayer LAYER-MODE-HARDLIGHT-LEGACY)
    (gimp-layer-set-opacity varBevelLayer 80)
    
    ;delete outside the desired bevel
    (if (= inLocation 0)
      (begin ;inside
        (gimp-selection-load varSavedSelection)
        (gimp-selection-invert img)
        (if (= (car (gimp-selection-is-empty img)) FALSE)
          (gimp-edit-clear varBevelLayer)
        )
        (gimp-selection-load varSavedSelection)
        (gimp-selection-shrink img inWidth)
        (if (= (car (gimp-selection-is-empty img)) FALSE)
          (gimp-edit-clear varBevelLayer)
        )
      )     
      (begin ;outside
        (gimp-selection-load varSavedSelection)
        (if (= (car (gimp-selection-is-empty img)) FALSE)
          (gimp-edit-clear varBevelLayer)
        )
        (gimp-selection-load varSavedSelection)
        (gimp-selection-grow img inWidth)
        (gimp-selection-invert img)
        (if (= (car (gimp-selection-is-empty img)) FALSE)
          (gimp-edit-clear varBevelLayer)
        )
      )     
    )

    ; blur if desired
    (when (> inBlur 0)
      (gimp-selection-load varBlurredSelection) 
      (if (= inLocation 1)
        (gimp-selection-invert img)
      ) 
      (plug-in-gauss RUN-NONINTERACTIVE img varBevelLayer inBlur inBlur 0)
      (gimp-selection-none img) 
    )
    
    ;delete bumpmap layer
    (if (= inKeepBump TRUE)
      (gimp-drawable-set-visible varBumpmapLayer FALSE)
      (gimp-image-remove-layer img varBumpmapLayer)
    )
    
    ;load initial selection back up 
    (if (= varNoSelection TRUE)
      (gimp-selection-none img)
      (begin
        (gimp-selection-load varSavedSelection)
      )
    )

    ;and delete the channels
    (gimp-image-remove-channel img varSavedSelection)
    (gimp-image-remove-channel img varBlurredSelection)
    
    (gimp-image-set-active-layer img varBevelLayer)
    
    ;done
    ;(gimp-progress-end)
    (gimp-image-undo-group-end img)
    (gimp-displays-flush)
    (gimp-context-pop)
  )
)
