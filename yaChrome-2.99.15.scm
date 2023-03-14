
; samj 20230120 modifications for gimp-2.99.15 (new API)
; lines 184 to 190 here is the problem...
; you can test script-fu-ya-chrome-logo with console messages






; samj 20220831 modification for gimp-2.99.12 (new API)
;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove
; ya Chrome rel 299
; Created by Graechan using details from a tutorial by 'The Warrior'
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
; Rel 0.02 - improved undo function of Logo Script and improved both scripts output
; Rel 299 - attempt update for Gimp 2.99.8 and 2.10... but not are the same... changed name 
; Gradients blend direction list

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))

(define list-blend-dir '("Left to Right" "Top to Bottom" "Diagonal to centre" "Diagonal from centre"))
;
;; Start Define RGB to HSV functions by GnuTux

(define (convert-rgb-to-hsv color)
	(let* (
			(r (car color))
			(g (cadr color))
			(b (caddr color))
			(cmin (min r (min g b)))
			(cmax (max r (max g b)))
			(diff 0.0)
			(rc 0.0)
			(gc 0.0)
			(bc 0.0)
			(h 0.0)
		  )
			
		(set! diff (- cmax cmin))
		(if (= diff 0.0)
			(set! diff (+ diff 1.0)))
		(set! rc (/ (- cmax r) diff))
		(set! gc (/ (- cmax g) diff))
		(set! bc (/ (- cmax b) diff))
		(set! h  (/ (if (= r cmax)
							(- bc gc)
							(if (= g cmax)
								(+ 2.0 (- rc bc))
								(+ 4.0 (- gc rc))))
						6.0))
		
		(list (if (= cmin cmax)
				0
				(* 360 (if (< h 0.0)
						(+ h 1.0)
						h
					)
				)
			)
			(if (= cmin cmax)
				0
				(/ (- cmax cmin) cmax)
			)
			cmax
		)
	)
)

; RGB to HSV in gimp ranges
(define (rgb-to-hsv color)
	(let*
		(
			(r (car color))
			(g (cadr color))
			(b (caddr color))
			(hsv (convert-rgb-to-hsv (list (/ r 255.0) (/ g 255.0) (/ b 255.0))))
			(h (car hsv))
			(s (cadr hsv))
			(v (caddr hsv))
		)
		(list h (* s 100.0) (* v 100.0))
	)
)

;; End Define RGB to HSV functions by GnuTux
; Include layer Procedure
(define (include-layer image newlayer oldlayer stack)	;stack 0=above 1=below
	(cond ((defined? 'gimp-image-get-item-position) ;test for 2.8 compatability
            (gimp-image-insert-layer image newlayer (car (gimp-item-get-parent oldlayer)) 
			(+ (car (gimp-image-get-item-position image oldlayer)) stack))                                     ;For GIMP 2.8 
          )
          (else
           (gimp-image-insert-layer image newlayer 0 (+ (car (gimp-image-get-item-position image oldlayer)) stack)) ;For GIMP 2.6 
          )
    ) ;end cond
) ;end add layer procedure
;
(define (script-fu-ya-chrome-logo 
                                      text
									  justify
									  letter-spacing
									  line-spacing
                                      font-in 
                                      font-size
				      metal
				      colorize
				      metal-finish
                                      bkg-type 
                                      pattern
                                      bkg-color
							          gradient
							          gradient-type
							          reverse
							          blendir)
									  
	(gimp-context-push)
	(gimp-context-set-foreground '(0 0 0))
	
  (let* (
         (width 0)
         (height 0)
         (offx 0)
         (offy 0)
         (image (car (gimp-image-new 50 50 RGB)))
	 (gimp-image-set-resolution image 300 300)
         (area (* 1000 1000))
         (border (/ font-size 4))
		 (font (if (> (string-length font-in) 0) font-in (car (gimp-context-get-font))))
         (text-layer (car (gimp-text-fontname image -1 0 0 text border TRUE font-size PIXELS font)))
         (text-width (car (gimp-drawable-get-width text-layer)))
         (text-height (car (gimp-drawable-get-height text-layer)))
		 (active-gradient (car (gimp-context-get-gradient)))
		 (active-fg (car (gimp-context-get-foreground)))
		 (active-bg (car (gimp-context-get-background)))
		 (bkg-layer 0)
		 (text-selection 0)
		 (justify (cond ((= justify 0) 2)
		                ((= justify 1) 0)
						((= justify 2) 1)))
		 (x1 0)
		 (y1 0)
		 (x2 0)
		 (y2 0)
		 (ver 2.8)   
        (major_version_no 0)
        (minor_version_no 0)
        (version_list (strbreakup (car (gimp-version)) "."))		 
         )
	;(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version	 
		 
    
	;(gimp-context-set-paint-method "gimp-paintbrush")
	;(if (= ver 2.8) (gimp-context-set-dynamics "Dynamics Off"))
	(gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

;;;;adjust text 
    (cond ((not(defined? 'gimp-image-set-selected-layers) )

	(gimp-text-layer-set-justification text-layer justify)
	(gimp-text-layer-set-letter-spacing text-layer letter-spacing)
	(gimp-text-layer-set-line-spacing text-layer line-spacing)
	
)
(else ( gimp-message "OH! Justify and spacing not working in 2.99.12/14"))
)


;;;;set the new width and height	
    (set! width (car (gimp-drawable-get-width text-layer)))
    (set! height (car (gimp-drawable-get-height text-layer)))    
    (gimp-image-resize-to-layers image)
;;;;set the new Image size
	(if (> text-width (car (gimp-image-get-width image))) (set! width text-width))           
    (if (> text-height (car (gimp-image-get-height image))) (set! height text-height))

;;;;resize the image	
	(gimp-image-resize image width height 0 0)

;;;;centre the text layer	
    (set! offx (/ (- width text-width) 2))
    (set! offy (/ (- height text-height) 2))    
    (gimp-layer-set-offsets text-layer offx offy)
	(gimp-image-resize-to-layers image)

;;;;start of script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (gimp-image-undo-group-start image)
	(script-fu-ya-chrome image text-layer
					metal
					colorize
					metal-finish
                                       bkg-type 
                                       pattern
                                       bkg-color
							           gradient
							           gradient-type
							           reverse
							           blendir)
    


;;;;end of script;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	(gimp-context-pop)
    (gimp-display-new image)
	(gimp-image-undo-group-end image)
	
    )
  ) 
(script-fu-register "script-fu-ya-chrome-logo"
  "ya Chrome Logo"
  "Create an image with a text layer over a pattern layer"
  "Graechan"
  "Failed update and change name Vitforlinux"
  "Feb 2022"
  ""
  SF-TEXT       "Text"    "ya CHROME"
  SF-OPTION "Justify" '("Centered" "Left" "Right")
  SF-ADJUSTMENT "Letter Spacing" '(0 -100 100 1 5 0 0)
  SF-ADJUSTMENT "Line Spacing" '(0 -100 100 1 5 0 0)
  SF-FONT       "Font"               "Serif Bold"
  SF-ADJUSTMENT "Font size (pixels)" '(150 6 500 1 1 0 1)
    SF-OPTION "Metal Type" '("None" "Gold" "Silver" "Copper" "Bronze" "Brass" "Chrome" "Gold Shined")
  SF-COLOR      "Colorize"         "White"
  SF-OPTION "Metal Finish" '("None" "Hammered" "Cloudy")
  SF-OPTION "Background Type" '("None" "Color" "Pattern" "Gradient" "Active Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
  
  )
(script-fu-menu-register "script-fu-ya-chrome-logo" "<Image>/Script-Fu/Logos/")
;
 (define (script-fu-ya-chrome image drawable
                                       metal
				       colorize
				       metal-finish
				       bkg-type 
                                       pattern
                                       bkg-color
							           gradient
							           gradient-type
							           reverse
							           blendir)
							   
	(gimp-image-undo-group-start image)
    (gimp-image-resize-to-layers image)	

 (let* (
            (width (car (gimp-drawable-get-width drawable)))
			(height (car (gimp-drawable-get-height drawable)))
			(offx (car (gimp-drawable-get-offsets drawable)))
            (offy (cadr (gimp-drawable-get-offsets drawable)))
			(bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
			(chrome (car (gimp-layer-new image width height RGBA-IMAGE "Chrome" 100 LAYER-MODE-NORMAL-LEGACY)))
			(alpha (car (gimp-drawable-has-alpha drawable)))
		    (no-sel (car (gimp-selection-is-empty image)))
			(active-gradient (car (gimp-context-get-gradient)))
		    (active-fg (car (gimp-context-get-foreground)))
		    (active-bg (car (gimp-context-get-background)))
			(chrome-copy 0)
			(hammered 0)
		    (ver 2.8)
		            (major_version_no 0)
        (minor_version_no 0)
        (version_list (strbreakup (car (gimp-version)) "."))
			(x1 0)
		    (y1 0)
		    (x2 0)
		    (y2 0)
		    		   (h 0)     ;add MrQ
		   (s 0)     ;add MrQ
		   (v 0)     ;add MrQ
		   (hsv 0)   ;add MrQ
        )
	;(cond ((not (defined? 'gimp-image-get-item-position)) (set! ver 2.6))) ;define the gimp version
	
	(gimp-context-push)
    ;(gimp-context-set-paint-method "gimp-paintbrush")
	;(cond ((defined? 'gimp-context-set-dynamics) (gimp-context-set-dynamics "Dynamics Off")))
    (gimp-context-set-foreground '(0 0 0))
	(gimp-context-set-background '(255 255 255))

	(if (= alpha FALSE) (gimp-layer-add-alpha drawable))
	
;;;;check that a selection was made if not make one	
	(if (= no-sel TRUE) (begin
	(cond ((= ver 2.8) (gimp-image-select-item image 2 drawable)) 
	(else (gimp-selection-layer-alpha drawable))
	) ;endcond
	)
	)

    ; samj Old code ->   (gimp-image-set-active-layer image drawable)
	; samj New code for gimp-2.99.12
   ; (gimp-image-set-selected-layers image 1 (vector drawable))
(cond ((defined? 'gimp-image-set-selected-layers) (gimp-image-set-selected-layers image 1 (vector drawable)))
(else (gimp-image-set-active-layer image drawable))
)

;;;;begin the script	
	(include-layer image bkg-layer drawable 0)	;stack 0=above 1=below
	(gimp-layer-set-offsets bkg-layer offx offy)
	(gimp-drawable-fill bkg-layer FILL-FOREGROUND)
	(gimp-drawable-edit-fill bkg-layer FILL-BACKGROUND)
	(gimp-selection-none image)
	(plug-in-gauss-rle2 RUN-NONINTERACTIVE image bkg-layer 5 5)
	;(gimp-image-select-color image 2 bkg-layer '(0 0 0) )
(gimp-image-select-item image 2 drawable)
;	(gimp-selection-invert image)
	(set! x1 (cadr (gimp-drawable-mask-bounds drawable)))                     ;x co-ord of upper left corner of selection of the specified drawable.
    (set! y1 (caddr (gimp-drawable-mask-bounds drawable)))                    ;y co-ord of upper left corner of selection of the specified drawable.
    (set! x2 (cadddr (gimp-drawable-mask-bounds drawable)))                   ;x co-ord of lower right corner of selection of the specified drawable. 
	(set! y2 (cadr (cdddr (gimp-drawable-mask-bounds drawable))))             ;y co-ord of lower right corner of selection of the specified drawable.
	
	(include-layer image chrome bkg-layer 0)	;stack 0=above 1=below
	(gimp-layer-set-offsets chrome offx offy)
	(gimp-item-set-visible bkg-layer FALSE)
	(gimp-context-set-foreground '(89 89 89))
	(gimp-context-set-background '(185 185 185))
	(gimp-context-set-gradient-fg-bg-rgb)
;(gimp-image-select-item image 2 drawable)
	;(gimp-drawable-edit-gradient-fill chrome GRADIENT-LINEAR 100 0 REPEAT-NONE FALSE FALSE 3 0.2 TRUE (+ offx x1) (+ offy y2) (+ offx x1) (+ offy y1))
	  (gimp-drawable-edit-gradient-fill chrome GRADIENT-LINEAR 0 0 100 0 0 (+ offx x1) (+ offy y2) (+ offx x1) (+ offy y1))

	 	(cond ((not (= metal-finish 0))
	(set! hammered (set! hammered (car (gimp-layer-copy chrome TRUE))))
	(include-layer image hammered drawable 1)	;stack 0=above 1=below
	(gimp-layer-set-offsets hammered offx offy)
    )) ;endcond
	(cond ( (= metal-finish 1)	
				(gimp-context-set-background '(255 255 255))
	(gimp-drawable-edit-fill hammered FILL-BACKGROUND)
	(gimp-context-set-background '(0 0 0 ))
	 (plug-in-mosaic 1 image hammered 10 10 3 0 FALSE 175 0.3 TRUE FALSE 1 0 1)
	 (plug-in-gauss-iir2 1 image hammered 6 6)
	 (gimp-selection-none image)
	 	(plug-in-bump-map RUN-NONINTERACTIVE image chrome hammered 135 30 5 0 0 0 0 TRUE FALSE 1) ;{LINEAR(0),SPHERICAL(1),SINUSOIDAL(2)})
			)
				)
					  (if (= metal-finish 2)
	 (plug-in-solid-noise 1 image chrome FALSE TRUE 0 1 4 4)
	 );
	(gimp-selection-none image)
	(plug-in-bump-map RUN-NONINTERACTIVE image chrome bkg-layer 135 45 10 0 0 0 0 TRUE FALSE 0) ;{LINEAR(0),SPHERICAL(1),SINUSOIDAL(2)}
	;(gimp-drawable-curves-spline chrome 0 12 #(0 0.34902 0.266667 0.882353 0.494118 0.376471 0.65098 0.886275 0.87451 0.152941 1 1))
	(gimp-drawable-curves-spline chrome 0 12 #(0 0 0.1593336269849942 0.90554815461736837 0.29674183238636365 0.51862126059513758 0.38610469933712122 0.91144287816345926 0.5971582941797785 0.45082864061745886 1 1))
	 (if (not (= metal-finish 1))
	(gimp-drawable-curves-explicit chrome 0 256 #(0 0.029999873779949081 0.059971699695111333 0.08988742988069999 0.11971901647192813 0.14943841160400906 0.1790175674121558 0.20842843603158168 0.23764296959749986 0.26663312024512342 0.29537084010966569 0.32382808132633967 0.35197679603035864 0.37978893635693578 0.40723645444128431 0.43429130241861741 0.46092543242414813 0.48711079659308987 0.51281934706065546 0.53802303596205858 0.56269381543251196 0.58680363760722898 0.61032445462142271 0.63322821861030643 0.65548688170909353 0.67707239605299663 0.69795671377722956 0.71811178701700495 0.7375095679075363 0.75612200858403678 0.77392106118171933 0.79087867783579746 0.80696681068148413 0.82215741185399249 0.83642243348853595 0.84973382772032768 0.86206354668458041 0.87338354251650774 0.88366576735132285 0.8928821733242388 0.90100471257046866 0.90554815461736837 0.91108602696984431 0.91408666294398333 0.91469198782397632 0.91304392689401459 0.90928440543828959 0.90355534874099208 0.89599868208631328 0.88675633075844462 0.87597022004157676 0.86378227521990159 0.85033442157760963 0.83576858439889212 0.82022668896793993 0.80385066056894539 0.78678242448609836 0.7691639060035913 0.75113703040561419 0.73284372297635825 0.71442590900001524 0.69602551376077615 0.67778446254283198 0.65984468063037394 0.64234809330759335 0.62543662585868109 0.60925220356782861 0.59393675171922677 0.57963219559706702 0.56648046048554013 0.55462347166883763 0.54420315443115064 0.53536143405667036 0.52824023582958757 0.5229814850340937 0.51972710695437996 0.51862126059513758 0.52095464152437798 0.52747929804512006 0.53778781440436918 0.55147277484913115 0.5681267636264109 0.58734236498321379 0.60871216316654564 0.63182874242341147 0.65628468700081655 0.6816725811457669 0.70758500910526734 0.73361455512632312 0.75935380345594017 0.78439533834112363 0.80833174402887886 0.83075560476621124 0.85125950480012624 0.86943602837762912 0.88487775974572536 0.89717728315142053 0.90592718284171936 0.91144287816345926 0.91010902150592488 0.90790054871727 0.90485225693339932 0.90099894329021657 0.89637540492362633 0.89101643896953264 0.88495684256383933 0.87823141284245121 0.8708749469412721 0.86292224199620604 0.85440809514315763 0.84536730351803102 0.83583466425673025 0.82584497449515926 0.81543303136922274 0.80463363201482474 0.79348157356786897 0.78201165316426047 0.77025866793990272 0.75825741503069999 0.74604269157255676 0.73364929470137719 0.72111202155306542 0.70846566926352539 0.69574503496866169 0.68298491580437848 0.67022010890657957 0.65748541141116956 0.64481562045405216 0.63224553317113208 0.61980994669831324 0.60754365817149991 0.59548146472659613 0.58365816349950639 0.57210855162613461 0.56086742624238517 0.54996958448416211 0.5394498234873697 0.52934294038791196 0.51968373232169351 0.51050699642461805 0.50184752983259007 0.49374012968151376 0.48621959310729312 0.47932071724583247 0.47307829923303613 0.46752713620480796 0.4627020252970524 0.45863776364567355 0.45536914838657561 0.45293097665566284 0.45135804558883941 0.4506851523220094 0.45082864061745886 0.45146392114664063 0.45223744934862808 0.45314786618514319 0.4541938126179072 0.4553739296086417 0.45668685811906823 0.45813123911090853 0.4597057135458838 0.46140892238571574 0.46323950659212587 0.46519610712683568 0.46727736495156691 0.46948192102804098 0.47180841631797926 0.47425549178310356 0.47682178838513545 0.47950594708579614 0.48230660884680732 0.48522241462989057 0.4882520053967675 0.4913940221091595 0.49464710572878823 0.49800989721737515 0.50148103753664186 0.50505916764830983 0.50874292851410075 0.51253096109573582 0.51642190635493701 0.52041440525342564 0.52450709875292323 0.52869862781515131 0.53298763340183153 0.53737275647468552 0.54185263799543437 0.54642591892580006 0.551091240227504 0.55584724286226761 0.56069256779181276 0.56562585597786053 0.57064574838213278 0.57575088596635093 0.58093990969223652 0.58621146052151141 0.59156417941589645 0.59699670733711363 0.60250768524688458 0.60809575410693073 0.6137595548789736 0.61949772852473439 0.62530891600593519 0.63119175828429741 0.63714489632154259 0.64316697107939191 0.64925662351956737 0.65541249460379025 0.6616332252937821 0.66791745655126455 0.67426382933795914 0.68067098461558728 0.68713756334587073 0.69366220649053079 0.7002435550112891 0.70688024986986719 0.71357093202798672 0.72031424244736919 0.72710882208973593 0.73395331191680868 0.74084635289030898 0.74778658597195835 0.7547726521234781 0.76180319230658999 0.76887684748301566 0.77599225861447652 0.7831480666626941 0.79034291258938993 0.79757543735628555 0.80484428192510271 0.8121480872575626 0.81948549431538686 0.82685514406029714 0.83425567745401497 0.84168573545826186 0.84914395903475937 0.856628989145229 0.86413946675139219 0.87167403281497058 0.87923132829768602 0.88680999416125927 0.89440867136741264 0.90202600087786733 0.90966062365434497 0.91731118065856698 0.92497631285225501 0.93265466119713059 0.94034486665491523 0.9480455701873306 0.95575541275609788 0.96347303532293882 0.97119707884957529 0.97892618429772815 0.9866589926291196 0.99439414480547073 1))
	)
		(cond ((or (>= major_version_no 2) (> minor_version_no 98))
		;(gimp-image-select-item image 2 drawable) ;for gimp 2.99+ 
		;(gimp-drawable-brightness-contrast chrome 0 0.551181102362 )
		(gimp-drawable-brightness-contrast chrome 0 (/  77 255) )
		) 
		(else 
		;(gimp-selection-layer-alpha drawable) ; for 2.10
		;(gimp-drawable-brightness-contrast chrome 0 0.157480314961 )
		(gimp-drawable-brightness-contrast chrome 0 (/  68 255) )
		)
	) ;endcond
	(plug-in-gauss-iir2 1 image chrome 2 2)
	;(plug-in-alienmap2 1 image chrome 1 0 1 0 1 0 0 TRUE TRUE TRUE)
	(gimp-image-remove-layer image bkg-layer)
	
	(set! chrome-copy (car (gimp-layer-copy chrome TRUE)))
	(include-layer image chrome-copy chrome 0)	;stack 0=above 1=below
	(gimp-item-set-name chrome-copy "Chrome-Copy")
	;(gimp-context-set-gradient "Sunrise")
	;(plug-in-gradmap 1 image chrome-copy)
	;(gimp-layer-set-mode chrome-copy LAYER-MODE-BURN-LEGACY)
	


	(set! chrome (car (gimp-image-merge-down image chrome-copy EXPAND-AS-NECESSARY)))
	(script-fu-drop-shadow image chrome 3 3 10 '(0 0 0) 80 FALSE)

	
		(if (= metal 1) (set! colorize '(253 208 23)));gold
		;(if (= metal 1) (set! colorize '(167 148 0)));gold
		(if (= metal 2) (set! colorize '(192 192 192)));silver
		(if (= metal 3) (set! colorize '(184 115 51)));copper
		(if (= metal 4) (set! colorize '(140 120 83)));bronze
		(if (= metal 5) (set! colorize '(181 166 66)));brass
		(if (= metal 6) (set! colorize '(192 192 192)));chrome
		(if (= metal 7) (set! colorize '(253 208 23)));gold shined

				(begin   ; add for convert RGB to hsv	
			(set! hsv (rgb-to-hsv colorize))
			(set! h (car hsv))
			(set! s (cadr hsv))
			(set! v (caddr hsv))
			;(set! v (- v 100))
			(set! v (- v 115))
			(if (< v  -99) (set! v (- 100) ))
			(gimp-drawable-colorize-hsl chrome h s v)
			)
		(if (= metal 1) (gimp-drawable-brightness-contrast chrome 0.354330708661 0.157480314961));gold
		(if (= metal 2) (gimp-drawable-brightness-contrast chrome 0.354330708661 0.216535433071));silver
		(if (= metal 3) (gimp-drawable-brightness-contrast chrome 0.216535433071 0.1968503937));copper
		(if (= metal 4) (gimp-drawable-brightness-contrast chrome 0.137795275591 0.236220472441));bronze
		(if (= metal 5) (gimp-drawable-brightness-contrast chrome 0.0905511811024 0.0905511811024));brass
		(if (= metal 6)(gimp-drawable-curves-spline chrome 0 12 #(0 0.34902 0.266667 0.882353 0.494118 0.376471 0.65098 0.886275 0.87451 0.152941 1 1)) (gimp-layer-set-lock-alpha chrome TRUE)(plug-in-gauss-iir2 1 image chrome 1 1));chrome
		(if (= metal 7)(gimp-drawable-curves-spline chrome 0 14 #(0 0 0.23677581863979855 0.16731517509727623 0.37027707808564231 0.44357976653696496 0.62468513853904284 0.57587548638132291 0.7153652392947103 0.77042801556420237 0.86649874055415621 0.82101167315175105 1 1 )) (gimp-layer-set-lock-alpha chrome TRUE)(plug-in-gauss-iir2 1 image chrome 1 1));chrome

(gimp-layer-set-lock-alpha chrome TRUE)
;(gimp-drawable-hue-saturation chrome image 0 0 56 50 50)
;; effets

			  (if (not(= metal-finish 0))
	; (gimp-image-remove-layer image hammered )
	 );
	;;;;create the background layer
  (let* (
        (x1 0)
		(y1 0)
		(x2 0)
		(y2 0)
        )  
	(cond ((not (= bkg-type 0))
	(set! bkg-layer (car (gimp-layer-new image width height RGBA-IMAGE "Background" 100 LAYER-MODE-NORMAL-LEGACY)))
	(include-layer image bkg-layer drawable 1)	;stack 0=above 1=below
	(gimp-layer-set-offsets bkg-layer offx offy)
    )
	) ;endcond
	(gimp-context-set-pattern pattern)
	(gimp-context-set-background bkg-color)
	(gimp-context-set-gradient gradient)
	(if (or (= bkg-type 3) (= bkg-type 4)) (begin 
	(gimp-context-set-foreground active-fg)
	(gimp-context-set-background active-bg)))
	(if (= bkg-type 4) (gimp-context-set-gradient active-gradient))
	(if (= bkg-type 2) (gimp-drawable-fill bkg-layer FILL-PATTERN))		
    (if (= bkg-type 1) (gimp-drawable-fill bkg-layer FILL-BACKGROUND))	
    (if (or (= bkg-type 3) (= bkg-type 4)) 
	(begin
	(gimp-selection-none image)
	(gimp-drawable-fill bkg-layer FILL-BACKGROUND)
    (if (= blendir 0) (set! x2 width))
	(if (= blendir 1) (set! y2 height))
	(if (= blendir 2) (begin
	(set! x2 (/ width 2))
	(set! y2 (/ height 2))))
	(if (= blendir 3) (begin
	(set! x1 (/ width 2))
	(set! y1 (/ height 2))))
	;(gimp-drawable-edit-gradient-fill bkg-layer gradient-type 100 0 REPEAT-NONE reverse FALSE 3 0.2 TRUE x1 y1 x2 y2)
	(gimp-context-set-gradient-reverse reverse)
	 (gimp-drawable-edit-gradient-fill bkg-layer gradient-type 0 0 100 0 0 x1 y1 x2 y2)
	)
	) ;endif
	) ;endlet
	
	(gimp-displays-flush)
	(gimp-image-undo-group-end image)
	(gimp-context-pop)

 )
) 

(script-fu-register "script-fu-ya-chrome"        		    
  "ya Chrome Alpha"
  "chrome any object with transparent background "
  "Graechan"
  "Failed update and change name Vitforlinux"
  "Feb 2022"
  "RGB*"
  SF-IMAGE      "image"      0
  SF-DRAWABLE   "drawable"   0
      SF-OPTION "Metal Type" '("None" "Gold" "Silver" "Copper" "Bronze" "Brass" "Chrome" "Gold Shined")
   SF-COLOR      "Colorize"         "White"
   SF-OPTION "Metal Finish" '("None" "Hammered" "Cloudy")
  SF-OPTION "Background Type" '("None" "Color" "Pattern" "Gradient" "Active Gradient")
  SF-PATTERN    "Pattern"            "Pink Marble"
  SF-COLOR      "Background color"         "Blue"
  SF-GRADIENT   "Background Gradient" "Abstract 3"
  SF-ENUM "Gradient Fill Mode" '("GradientType" "gradient-linear")
  SF-TOGGLE     "Reverse the Gradient"   FALSE
  SF-OPTION		"Blend Direction" 		list-blend-dir
)

(script-fu-menu-register "script-fu-ya-chrome" "<Image>/Script-Fu/Alpha-to-Logo/")


 
  
