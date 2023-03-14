;
;	Mike Markowski		University of Delaware
;	mm@udel.edu		June 2000
;
; My first script-fu program!  At long last I've taken the time to learn
; script-fu.  It turns out that it's not difficult, except that
; there is very little documentation on it.  To that end, I decided
; to make a program that closely follows an online tutorial.  I've
; also made an effort to fully document this code so that others
; might use this as a tool in learning script-fu themselves.  I
; strongly recommend that you manually complete that tutorial before
; going through this.  It really will be a big help in following the
; code.  And before that, you'll probably want to run through the
; script-fu chapters of the GUM at http://manual.gimp.org.
;
; I've tried to closely follow the tutorial at
;
;	http://www.gimp.org/tut-sum1.html
;
; or go http://www.gimp.org -> Documentation -> Tutorials -> Summary
; (The URL and link hops are correct as of June 2000.)
;
; But I've probably strayed from it here and there.  Drop me a line if
; you think it should be done differently or in a better/cleaner way.
; After all, this is my first crack at it.  I doubt it's optimal.
;
; Please email me with any recommendations or changes.  In the
; meantime, enjoy!  I sincerely hope you find this helpful and
; would be happy to hear your opinion of it.  Thanks, and
; happy script fu'ing!
;
; Directions:
;
;	- Put this script in your $HOME/.gimp-1.1/scripts directory
;         as framed-glass-text.scm
;	- Start gimp (or do a Xtns -> Script-Fu -> Refresh)
;	- Use Xtns -> Script-Fu -> Logos -> Framed Glass...
; update/fast fix for Gimp 2.10.32 vitforlinux

(define (script-fu-framed-glass-text
	  inText	; Text to render.
	  inFont	; Font to render text with.
	  inFontSize	; Size of characters in pixels.
	  borderPat	; Pattern to bump map onto text frame.
	  glassColor	; Color of glass that will fill text frame.
	  bgColor	; Color of background layer.
	  useShadow	; TRUE/FLASE, do/don't draw a drop shadow.
	  shadX		; X offset, in pixels, of drop shadow.
	  shadY		; Y offset, in pixels, of drop shadow.
	  useGlass)	; TRUE/FALSE, do/don't add glass layer.
  (let*
   (;   L o c a l   V a r i a b l e s
    (img (car (gimp-image-new 256 256 RGB)))

    ;;originalMaskoldに変更
    (old-fg (car (gimp-palette-get-foreground)))
    (old-bg (car (gimp-palette-get-background)))
    (old-pat (car (gimp-patterns-get-pattern)))
    (tmp (car (gimp-palette-set-foreground '(  0   0   0))))	;add
    (tmp1 (car (gimp-palette-set-background '(255 255 255))))	;add
    (floatSel (car (gimp-text-fontname img -1 0 0 inText (+ (/ inFontSize 12) 4) TRUE inFontSize PIXELS inFont)))
    (imgWidth (car (gimp-drawable-width floatSel)))
    (imgHeight (car (gimp-drawable-height floatSel)))
    ; End of local variables.
   )

   ; Disallow user to undo substeps of this script.
   (gimp-image-undo-disable img)

   ;   I n i t i a l   T e x t
   ; Black on white text.
;   (gimp-palette-set-background '(255 255 255))
;   (gimp-palette-set-foreground '(  0   0   0))

   ; 削除した

   (gimp-image-resize img (+ imgWidth shadX) (+ imgHeight shadY) 0 0)

(script-fu-framed-glass-textcore
	  img floatSel
	  inFontSize
	  borderPat	; Pattern to bump map onto text frame.
	  glassColor	; Color of glass that will fill text frame.
	  bgColor	; Color of background layer.
	  useShadow	; TRUE/FLASE, do/don't draw a drop shadow.
	  shadX		; X offset, in pixels, of drop shadow.
	  shadY		; Y offset, in pixels, of drop shadow.
	  useGlass TRUE)

   ;   D o n e

   ; display the fruits of our labor
   (gimp-display-new img)
   (gimp-palette-set-background old-bg)
   (gimp-palette-set-foreground old-fg)
   (gimp-patterns-set-pattern old-pat)
   (gimp-image-undo-enable img)

   ; Make list available to calling function.
   ;(list img originalMask ...<add layers of interest here>...)
  )
)

(script-fu-register
  "script-fu-framed-glass-text"		; Function name.
  "Framed Glass..." ; Menu position.
  "Creates a text box sized to fit around the user's choice of text, font, font size, and color.  The text will appear as colored glass framed with wood as appearing in the tutorial named 'Summary' at http://www.gimp.org.  At that URL, follow links to Documentation -> Tutorials -> Summary"
  "Michael Markowski"			; Author
  "Copyright 2000 Michael Markowski"	; Copyright notice.
  "June 6, 2000"			; Date created.
  ""					; Image type that the script works on.
  SF-STRING	_"Text"			"Warm breeze..."
  SF-FONT	_"Font" "bookman"
  SF-ADJUSTMENT "Font Size (pixels)"	'(100 2 1000 1 10 0 1)
  SF-PATTERN	_"Pattern"		"Wood of some sort"
  SF-COLOR	_"Glass Color"		'(0 100 0)
  SF-COLOR	_"Background Color"	'(249 217 134)
  SF-TOGGLE	_"Add drop shadow?" TRUE
  SF-ADJUSTMENT _"Shadow X offset"	'(10 1 200 1 10 0 1)
  SF-ADJUSTMENT _"Shadow Y offset"	'(12 1 200 1 10 0 1)
  SF-TOGGLE	_"Use glass?" TRUE
)
(script-fu-menu-register "script-fu-framed-glass-text" "<Image>/Script-Fu/Logos/")


(define (script-fu-framed-glass-textimg
	  img drawable
	  inFontSize
	  borderPat	; Pattern to bump map onto text frame.
	  glassColor	; Color of glass that will fill text frame.
	  bgColor	; Color of background layer.
	  useShadow	; TRUE/FLASE, do/don't draw a drop shadow.
	  shadX		; X offset, in pixels, of drop shadow.
	  shadY		; Y offset, in pixels, of drop shadow.
	  useGlass)	; TRUE/FALSE, do/don't add glass layer.
  (let*
   (;   L o c a l   V a r i a b l e s

    ;;originalMaskoldに変更
    (old-fg (car (gimp-palette-get-foreground)))
    (old-bg (car (gimp-palette-get-background)))
    (old-pat (car (gimp-patterns-get-pattern)))
    (tmp (car (gimp-palette-set-foreground '(  0   0   0))))	;add
    (tmp1 (car (gimp-palette-set-background '(255 255 255))))	;add
    (imgWidth (car (gimp-drawable-width drawable)))
    (imgHeight (car (gimp-drawable-height drawable)))
    ; End of local variables.
   )

   ; Disallow user to undo substeps of this script.
   (gimp-image-undo-group-start img)

   ;   I n i t i a l   T e x t
   ; Black on white text.
;   (gimp-palette-set-background '(255 255 255))
;   (gimp-palette-set-foreground '(  0   0   0))

   (gimp-image-resize img (+ (+ imgWidth shadX) (* (/ inFontSize 100) 18)) (+ (+ imgHeight shadY) (* (/ inFontSize 100) 18)) (* (/ inFontSize 100) 9) (* (/ inFontSize 100) 9))
   (gimp-layer-resize drawable (+ imgWidth (* (/ inFontSize 100) 18)) (+ imgHeight (* (/ inFontSize 100) 18)) (* (/ inFontSize 100) 9) (* (/ inFontSize 100) 9))
   (gimp-selection-layer-alpha drawable)		;add
   (gimp-edit-fill drawable FILL-FOREGROUND)		;add
   (gimp-selection-none img)				;add

(script-fu-framed-glass-textcore
	  img drawable
	  inFontSize
	  borderPat	; Pattern to bump map onto text frame.
	  glassColor	; Color of glass that will fill text frame.
	  bgColor	; Color of background layer.
	  useShadow	; TRUE/FLASE, do/don't draw a drop shadow.
	  shadX		; X offset, in pixels, of drop shadow.
	  shadY		; Y offset, in pixels, of drop shadow.
	  useGlass FALSE)

   ;   D o n e

   ; display the fruits of our labor
   (gimp-palette-set-background old-bg)
   (gimp-palette-set-foreground old-fg)
   (gimp-patterns-set-pattern old-pat)
   (gimp-image-undo-group-end img)
   (gimp-displays-flush)

   ; Make list available to calling function.
   ;(list img originalMask ...<add layers of interest here>...)
  )
)

;画像加工本体
(define (script-fu-framed-glass-textimgh
	  img drawable
	  inFontSize
	  borderPat	; Pattern to bump map onto text frame.
	  glassColor	; Color of glass that will fill text frame.
	  bgColor	; Color of background layer.
	  useShadow	; TRUE/FLASE, do/don't draw a drop shadow.
	  shadX		; X offset, in pixels, of drop shadow.
	  shadY		; Y offset, in pixels, of drop shadow.
	  useGlass)
  (let* (
	(img2 (car (gimp-channel-ops-duplicate img)))
	(drawable2 (car (gimp-image-get-active-layer img2)))
	)
	(gimp-image-undo-disable img2)
	(script-fu-framed-glass-textimg
	  img2 drawable2
	  inFontSize
	  borderPat	; Pattern to bump map onto text frame.
	  glassColor	; Color of glass that will fill text frame.
	  bgColor	; Color of background layer.
	  useShadow	; TRUE/FLASE, do/don't draw a drop shadow.
	  shadX		; X offset, in pixels, of drop shadow.
	  shadY		; Y offset, in pixels, of drop shadow.
	  useGlass)
	(gimp-image-undo-enable img2)
	(gimp-display-new img2)
  )
)

(script-fu-register
  "script-fu-framed-glass-textimgh"		; Function name.
  "Framed Glass Alpha..." ; Menu position.
  "Creates a text box sized to fit around the user's choice of text, font, font size, and color.  The text will appear as colored glass framed with wood as appearing in the tutorial named 'Summary' at http://www.gimp.org.  At that URL, follow links to Documentation -> Tutorials -> Summary"
  "Michael Markowski"			; Author
  "Copyright 2000 Michael Markowski"	; Copyright notice.
  "June 6, 2000"			; Date created.
  "RGBA"				; Image type that the script works on.
  SF-IMAGE        "Image"    0
  SF-DRAWABLE     "Drawable" 0
  SF-ADJUSTMENT _"size"	'(100 1 1000 1 10 0 1)
  SF-PATTERN	_"Pattern"		"Wood of some sort"
  SF-COLOR	_"Glass Color"		'(0 100 0)
  SF-COLOR	_"Background Color"	'(249 217 134)
  SF-TOGGLE	_"Add drop shadow?" TRUE
  SF-ADJUSTMENT _"Shadow X offset"	'(10 1 200 1 10 0 1)
  SF-ADJUSTMENT _"Shadow Y offset"	'(12 1 200 1 10 0 1)
  SF-TOGGLE	_"Use glass?" TRUE
)
(script-fu-menu-register "script-fu-framed-glass-textimgh" "<Image>/Script-Fu/Alpha-to-Logo/")

(define (script-fu-framed-glass-textcore
	  img floatSel
	  inFontSize
	  borderPat	; Pattern to bump map onto text frame.
	  glassColor	; Color of glass that will fill text frame.
	  bgColor	; Color of background layer.
	  useShadow	; TRUE/FLASE, do/don't draw a drop shadow.
	  shadX		; X offset, in pixels, of drop shadow.
	  shadY		; Y offset, in pixels, of drop shadow.
	  useGlass text?)
  (let*((originalMaskold (car (gimp-layer-new img 256 256 RGBA-IMAGE "Original Mask" 100 NORMAL-MODE)))
    (bgLayer (car (gimp-layer-new img 256 256 RGBA-IMAGE "Background" 100 NORMAL-MODE)))
    (woodBorder (car (gimp-layer-new img 256 256 RGBA-IMAGE "Wood Border" 100 NORMAL-MODE)))
    (imgWidth (car (gimp-drawable-width floatSel)))
    (imgHeight (car (gimp-drawable-height floatSel)))
    (layer 0)

;;2.4追加
    (originalMask)
    (blurredMaskUpper)
    (blurredMaskLower)
    (blurredMask)
    (invMaskBlurred)
    (mask)
    (fatMask)
    (edgeBlurred)
    (aa)
    (bb)
    (cc)
    (desaturated)
    (borderShadow)
    (bb3)
    (bb4)
    )

   ; I use a variable for the layer because you'll see below that there
   ; are some layers that might or might not be created.  It seems that 
   ; if you assign a layer number that is higher than the next one in 
   ; sequence that gimp just uses the current number.  In this program
   ; that happened and my shadow layers were below the background layer,
   ; etc.
   (set! layer (+ layer 1))
   ; Add the initial text layer.
   (gimp-image-add-layer img originalMaskold 1)
   (gimp-layer-resize originalMaskold (+ imgWidth shadX) (+ imgHeight shadY) 0 0)
   (gimp-edit-fill originalMaskold WHITE-FILL)

   ;;変更＆移動
   (set! originalMask (car (gimp-image-merge-down img floatSel 0)))
   (gimp-drawable-set-visible originalMask FALSE)

   ; 削除

   ;   G l a s s   H i g h l i g h t s
   ;
   ; See the tutorial for a short discussion on what's going on here.

   (if (= useGlass TRUE)
     (begin
       (set! blurredMaskUpper (car (gimp-layer-copy originalMask TRUE)))
       (if (= TRUE text?) (set! layer (+ layer 1)))
       (gimp-image-add-layer img blurredMaskUpper layer)
       (gimp-drawable-set-visible blurredMaskUpper TRUE)
       (gimp-drawable-set-name blurredMaskUpper "Blurred Mask, Upper")
       ; Blur copy of original mask.
       (plug-in-gauss-iir TRUE img blurredMaskUpper (* (/ inFontSize 100) 15) TRUE TRUE)
       ; Invert blurred mask.
       (gimp-invert blurredMaskUpper)

       ; Since blurredMaskLower is a bopy of blurredMaskUpper, it will
       ; also be visible; hence, don't need to call gimp-drawable-set-visible.
       (set! blurredMaskLower (car (gimp-layer-copy blurredMaskUpper TRUE)))
       (gimp-drawable-set-visible blurredMaskLower TRUE)
       (gimp-drawable-set-name blurredMaskLower "Blurred Mask, Lower")

       ; Add layers to the image
       (set! layer (+ layer 1))
       (gimp-image-add-layer img blurredMaskLower layer)
       ; Creat the shadow with glass-like highlights.
       (gimp-layer-set-mode blurredMaskUpper DIFFERENCE-MODE)
       (gimp-layer-translate blurredMaskUpper (* (/ inFontSize 100) -4) (* (/ inFontSize 100) -4))
       (gimp-layer-set-mode blurredMaskLower NORMAL-MODE)
       (gimp-layer-translate blurredMaskLower (* (/ inFontSize 100) 4) (* (/ inFontSize 100) 4))

       ; Merge blurred masks, clipped to image.
       (set! blurredMask
	 (car (gimp-image-merge-visible-layers img CLIP-TO-IMAGE)))
       (gimp-drawable-set-name blurredMask "Blurred Mask")
       (gimp-desaturate blurredMask)				;add to remove noise

       ; Accentuate highlights.  I got these values by first interactively
       ; using (in  gimp-1.1.23) "image -> colors -> levels".  When the values
       ; made the image look more or less like in the tutorial, I read off
       ; the numbers.  They're displayed as, say, A B C D E, but remember
       ; that the gimp-levels routine needs them as A C B D E.
       (gimp-levels blurredMask HISTOGRAM-VALUE 0 86 2.010000 0 255)))

   ;   C u t   O u t   G l a s s   I n t e r i o r

   (if (= useGlass TRUE)
     (begin
       ; Copy original text, invert it, and blur it.
       (set! invMaskBlurred (car (gimp-layer-copy originalMask TRUE)))
       (gimp-drawable-set-name invMaskBlurred "Inv. Mask (blurred)")
       (set! layer (+ layer 1))
       (gimp-image-add-layer img invMaskBlurred layer)
       (gimp-invert invMaskBlurred)
       (plug-in-gauss-iir TRUE img invMaskBlurred (* (/ inFontSize 100) 4) TRUE TRUE)

       ; Use invMaskBlurred layer to cut out, i.e, sharpen, blurredMask layer.
       (set! mask (car (gimp-layer-create-mask blurredMask ADD-WHITE-MASK)))
       (gimp-layer-add-mask blurredMask mask)

       ; Put the mask in place.
;       (gimp-edit-copy invMaskBlurred)				;moved
;       (set! floatSel (car (gimp-edit-paste mask FALSE)))	;moved
;       (gimp-floating-sel-anchor floatSel)			;moved

       ; Now fatten & sharpen the mask some.  Yes, make sure it's the mask.
       ; Don't waste endless time like I did, modifying levels on the layer
       ; image (invMaskBlurred) wondering why it's not working...
       (gimp-levels mask HISTOGRAM-VALUE 0 60 0.38 0 255)))

   ;   M a k e   F a t   M a s k
   ;
   ; There might be a way to copy the mask, which is already blurred &
   ; inverted.  But I couldn't figure out how to do it!  That's why
   ; you'll see I go through the invert and blur once again in the next
   ; few lines.  :-/

   (set! fatMask (car (gimp-layer-copy originalMask TRUE)))
   (gimp-drawable-set-name fatMask "Fat Mask")
   (set! layer (+ layer 1))
   (gimp-image-add-layer img fatMask layer)
   (gimp-invert fatMask)
	(set! bb3 (- (* (/ inFontSize 140) 12) 0.6))
	(if (> 1 bb3) (set! bb3 1))
   (plug-in-gauss-iir TRUE img fatMask bb3 TRUE TRUE)
   (gimp-levels fatMask HISTOGRAM-VALUE 0 60 0.38 0 255)
   (set! edgeBlurred (car (gimp-layer-copy fatMask TRUE)))
   (set! layer (+ layer 1))
   (gimp-image-add-layer img edgeBlurred layer)
   (gimp-layer-set-name edgeBlurred "Edge Blurred")
   (plug-in-edge TRUE img edgeBlurred 10 1 1)
	(set! bb4 (+ (* (/ inFontSize 200) 8) 1))
	(if (> 1 bb4) (set! bb4 1))
   (plug-in-gauss-iir TRUE img edgeBlurred bb4 TRUE TRUE)

       (gimp-edit-copy fatMask)					;moved and changed
       (set! floatSel (car (gimp-edit-paste mask FALSE)))	;moved
       (gimp-floating-sel-anchor floatSel)			;moved

   ;   M a k e   F r a m e

   ; Pattern fill the layer with the pattern.
   (gimp-palette-set-background '(0 0 0))
   (gimp-image-add-layer img woodBorder 1)
   (gimp-layer-resize woodBorder (+ imgWidth shadX) (+ imgHeight shadY) 0 0)
   (gimp-edit-fill woodBorder BACKGROUND-FILL)
   (gimp-patterns-set-pattern borderPat)
   (gimp-edit-bucket-fill woodBorder PATTERN-BUCKET-FILL NORMAL-MODE 100 0 FALSE 0 0)
   ; Bump map the edge-detected text border onto the pattern.
   (plug-in-bump-map TRUE img woodBorder edgeBlurred 135. 45. (+ (/ inFontSize 80) 1.75) 0 0 0 0 
		     TRUE FALSE GRADIENT-LINEAR)		;changed
   ; Mask off the raised letters.
   (set! mask (car (gimp-layer-create-mask woodBorder ADD-WHITE-MASK)))
   (gimp-layer-add-mask woodBorder mask)

   ; Put the mask in place.
   (gimp-edit-copy edgeBlurred)
   (set! floatSel (car (gimp-edit-paste mask FALSE)))
   (gimp-floating-sel-anchor floatSel)

   ; Sharpen the mask a bit.
   (gimp-levels mask HISTOGRAM-VALUE 0 130 0.51 0 255)

   ;   C o l o r   t h e   G l a s s
   ;
   ; The tutorial claims you can get the green glassy look all with
   ; the gimp-hue-saturation settings.  If you know how to do this,
   ; please email me.  I can't figure it out, so I had to use
   ; gimp-hue-saturation and then gimp-color-balance to get the
   ; color to somewhat match the tutorial.

   (if (= useGlass TRUE)
     (begin
       (gimp-invert blurredMask)
       (gimp-hue-saturation blurredMask ALL-HUES 0. 80. 90.)
	;;エラーが出るので追加した
	(set! aa (car glassColor))
	(set! bb (cadr glassColor))
	(set! cc (caddr glassColor))
	(if (< 100 aa) (set! aa 100))
	(if (< 100 bb) (set! bb 100))
	(if (< 100 cc) (set! cc 100))

	(gimp-color-balance blurredMask SHADOWS TRUE aa bb cc)
       (gimp-hue-saturation blurredMask 0 0 0 -40)	;add 2.4
	(gimp-color-balance blurredMask 1 TRUE (/ aa 8) (/ bb 8) (/ cc 8))		;add 2.8
	(gimp-color-balance blurredMask 2 TRUE (/ aa 1.5) (/ bb 1.5) (/ cc 1.5))	;add 2.8
	(if (and (< 80 aa) (< 80 bb)) (gimp-brightness-contrast blurredMask -10 0))

       ; Make glass partially transparent.
	(gimp-layer-set-opacity blurredMask 60.)))

   ;   M a k e   t h e   G l a s s   S h a d o w
   ;
   ; Straightfoward following of steps in tutorial.  Nothing to
   ; see here, move along, move along...

   (if (and (= useGlass TRUE) (= useShadow TRUE))
     (begin
       (set! desaturated (car (gimp-layer-copy blurredMask TRUE)))
       (gimp-drawable-set-name desaturated "Desaturated")
       (set! layer (+ layer 1))
       (gimp-image-add-layer img desaturated 4) 
       (gimp-desaturate desaturated)
       (plug-in-gauss-iir TRUE img desaturated (* (/ inFontSize 100) 12) TRUE TRUE)
       (gimp-layer-set-opacity desaturated 30)
       (gimp-layer-set-offsets desaturated shadX shadY)))

   ;   M a k e   t h e   B o r d e r   S h a d o w

   (if (= useShadow TRUE)
     (begin
       (set! borderShadow (car (gimp-layer-copy woodBorder TRUE)))
       (gimp-drawable-set-name borderShadow "Border blurred")
       (set! layer (+ layer 1))
       (gimp-image-add-layer img borderShadow 5) 
       ; It took me a looong time to realize that this is the routine
       ; used to apply a mask!
       (gimp-layer-remove-mask borderShadow MASK-APPLY)
       (gimp-palette-set-background '(0 0 0))
       ; Preserve transparency so that when do a fill, only the non-
       ; transparent pixels, i.e., the text, are filled.
       (gimp-layer-set-preserve-trans borderShadow TRUE)
       (gimp-edit-fill borderShadow BACKGROUND-FILL)
       ; Now turn off transparency so we can blur the text.
       (gimp-layer-set-preserve-trans borderShadow FALSE)
       (plug-in-gauss-iir TRUE img borderShadow (* (/ inFontSize 100) 12) TRUE TRUE)
       (gimp-layer-set-opacity borderShadow 55.)
       (gimp-layer-set-offsets borderShadow shadX shadY)))

   ;   A d d   B a c k g r o u n d   C o l o r   L a y e r

   (set! layer (+ layer 1))
   (gimp-image-add-layer img bgLayer layer)
   (gimp-layer-resize bgLayer (+ (+ imgWidth shadX) (* (/ inFontSize 100) 12)) (+ (+ imgHeight shadY) (* (/ inFontSize 100) 12)) 0 0)
   (gimp-palette-set-background bgColor)
   (gimp-edit-fill bgLayer BACKGROUND-FILL)

)			;let
)
