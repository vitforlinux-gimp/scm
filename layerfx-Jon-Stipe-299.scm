;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; GIMP Layer Effects
; Copyright (c) 2008 Jonathan Stipe
; JonStipe@prodigy.net

; ---------------------------------------------------------------------

; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.

; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.

; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-drawable-get-width)) (define gimp-drawable-get-width gimp-drawable-width)))
(cond ((not (defined? 'gimp-drawable-get-height)) (define gimp-drawable-get-height gimp-drawable-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-base-type)) (define gimp-image-get-base-type gimp-image-base-type)))

(define (get-blending-mode mode)
  (let* ((modenumbers #(0 1 3 15 4 5 16 17 18 19 20 21 6 7 8 9 10 11 12 13 14)))
    (vector-ref modenumbers mode)
  )
)

(define (math-fix-round input)
  (floor (+ input 0.5))
)

(define (math-fix-ceil input)
  (if (= input (floor input))
    input
    (+ (floor input) 1)
  )
)

(define (get-layer-pos img layer)
  (let* ((layerdata (gimp-image-get-layers img))
	 (numlayers (car layerdata))
	 (layerarray (cadr layerdata))
	 (i 0)
	 (pos -1)
	)
    (while (< i numlayers)
      (if (= layer (vector-ref layerarray i))
	(begin
	  (set! pos i)
	  (set! i numlayers)
	)
	(set! i (+ i 1))
      )
    )
    pos
  )
)

(define (add-under-layer img newlayer oldlayer)
  ;(gimp-image-insert-layer img newlayer (+ (get-layer-pos img oldlayer 0) 1))
  (gimp-image-insert-layer img newlayer 0 (+ (get-layer-pos img oldlayer) 1))
)

(define (add-over-layer img newlayer oldlayer)
  ;(gimp-image-insert-layer img newlayer (get-layer-pos img oldlayer 0))
  (gimp-image-insert-layer img newlayer 0 (get-layer-pos img oldlayer))
)

(define (draw-fix-blurshape img drawable size initgrowth sel invert)
  (let* ((k initgrowth)
	 (currshade 0)
	 (i 0))
    (while (< i size)
      (if (> k 0)
	(gimp-selection-grow img k)
	(if (< k 0)
	  (gimp-selection-shrink img (abs k))
	)
      )
      (if (= invert 1)
	(set! currshade (math-fix-round (* (/ (- size (+ i 1)) size) 255)))
	(set! currshade (math-fix-round (* (/ (+ i 1) size) 255)))
      )
      (gimp-context-set-foreground (list currshade currshade currshade))
      (if (= (car (gimp-selection-is-empty img)) 0)
	(gimp-drawable-edit-fill drawable 0)
      )
      (gimp-image-select-item img 2 sel)
      (set! k (- k 1))
      (set! i (+ i 1))
    )
  )
)

(define (apply-contour drawable channel contour)
  (let* ((contourtypes #(0 0 0 0 0 0 0 0 0 1 1))
	 (contourlengths #(6 6 10 14 18 10 18 18 10 256 256))
	 (contours #(#(0 0 0.5 1 1 0)
#(0 1 0.498039 0 1 1)
#(0 0.25098 0.368627 0.290196 0.588235 0.45098 0.701961 0.701961 0.74902 1)
#(0 0 0.0196078 0.490196 0.0235294 0.490196 0.188235 0.580392 0.309804 0.701961 0.419608 0.85098 0.509804 1)
#(0 0 0.129412 0.0313725 0.25098 0.14902 0.380392 0.4 0.501961 0.65098 0.619608 0.819608 0.74902 0.921569 0.870588 0.968627 1 1)
#(0 0 0.109804 0.278431 0.341176 0.65098 0.760784 0.941176 1 1)
#(0 0 0.129412 0.431373 0.25098 0.929412 0.380392 0.941176 0.501961 0.541176 0.619608 0.129412 0.74902 0.0196078 0.870588 0.388235 1 1)
#(0 0 0.129412 0.290196 0.25098 0.858824 0.380392 0.729412 0.501961 0 0.619608 0.690196 0.74902 0.788235 0.870588 0.0117647 1 1)
#(0 1 0.211765 0.388235 0.380392 0.419608 0.701961 0.6 0.988235 0)
#(0 0.0196078 0.0352941 0.0509804 0.0627451 0.0745098 0.0862745 0.0980392 0.105882 0.113725 0.117647 0.12549 0.129412 0.133333 0.137255 0.141176 0.14902 0.152941 0.156863 0.160784 0.168627 0.172549 0.180392 0.184314 0.188235 0.192157 0.196078 0.2 0.203922 0.207843 0.211765 0.215686 0.215686 0.219608 0.219608 0.223529 0.223529 0.227451 0.227451 0.231373 0.231373 0.231373 0.235294 0.235294 0.235294 0.239216 0.239216 0.239216 0.239216 0.243137 0.243137 0.243137 0.243137 0.243137 0.247059 0.247059 0.247059 0.247059 0.247059 0.247059 0.25098 0.25098 0.25098 0.25098 0.25098 0.278431 0.294118 0.305882 0.317647 0.329412 0.337255 0.34902 0.356863 0.364706 0.372549 0.376471 0.384314 0.388235 0.396078 0.4 0.403922 0.407843 0.411765 0.419608 0.419608 0.423529 0.431373 0.435294 0.439216 0.443137 0.447059 0.45098 0.454902 0.458824 0.462745 0.466667 0.466667 0.470588 0.47451 0.47451 0.478431 0.482353 0.482353 0.482353 0.486275 0.486275 0.486275 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.494118 0.494118 0.494118 0.494118 0.494118 0.494118 0.494118 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.490196 0.509804 0.52549 0.537255 0.552941 0.568627 0.580392 0.592157 0.6 0.611765 0.619608 0.627451 0.635294 0.639216 0.647059 0.65098 0.654902 0.658824 0.666667 0.670588 0.670588 0.67451 0.678431 0.682353 0.686275 0.690196 0.694118 0.698039 0.698039 0.701961 0.705882 0.709804 0.709804 0.713725 0.717647 0.717647 0.721569 0.721569 0.72549 0.72549 0.729412 0.729412 0.733333 0.733333 0.737255 0.737255 0.741176 0.741176 0.741176 0.741176 0.745098 0.745098 0.745098 0.745098 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.74902 0.756863 0.760784 0.768627 0.772549 0.776471 0.784314 0.788235 0.796078 0.8 0.803922 0.811765 0.815686 0.819608 0.827451 0.831373 0.835294 0.839216 0.843137 0.85098 0.854902 0.858824 0.862745 0.862745 0.866667 0.870588 0.870588 0.87451 0.87451 0.878431 0.878431 0.878431 0.878431 0.878431 0.87451 0.87451 0.870588 0.870588 0.866667 0.866667 0.862745 0.858824 0.854902 0.85098 0.847059 0.843137 0.839216 0.835294 0.831373 0.827451 0.823529 0.819608 0.815686 0.807843 0.803922 0.8 0.796078 0.792157 0.784314 0.780392 0.776471 0.772549 0.768627 0.760784 0.760784)
#(0 0.00784314 0.0156863 0.0235294 0.0313725 0.0392157 0.0470588 0.054902 0.0627451 0.0705882 0.0784314 0.0862745 0.0941176 0.101961 0.109804 0.117647 0.12549 0.133333 0.141176 0.14902 0.156863 0.164706 0.172549 0.180392 0.188235 0.196078 0.203922 0.211765 0.219608 0.227451 0.235294 0.243137 0.25098 0.258824 0.266667 0.27451 0.282353 0.290196 0.298039 0.305882 0.313725 0.321569 0.329412 0.337255 0.345098 0.352941 0.360784 0.368627 0.376471 0.384314 0.392157 0.4 0.407843 0.415686 0.423529 0.431373 0.439216 0.447059 0.454902 0.462745 0.470588 0.478431 0.486275 0.494118 0.498039 0.490196 0.482353 0.47451 0.466667 0.458824 0.45098 0.443137 0.435294 0.427451 0.419608 0.411765 0.403922 0.396078 0.388235 0.380392 0.372549 0.364706 0.356863 0.34902 0.341176 0.333333 0.32549 0.317647 0.309804 0.301961 0.294118 0.286275 0.278431 0.270588 0.262745 0.254902 0.247059 0.239216 0.231373 0.223529 0.215686 0.207843 0.2 0.192157 0.184314 0.176471 0.168627 0.160784 0.152941 0.145098 0.137255 0.129412 0.121569 0.113725 0.105882 0.0980392 0.0901961 0.0823529 0.0745098 0.0666667 0.0588235 0.0509804 0.0431373 0.0352941 0.027451 0.0196078 0.0117647 0.00392157 0.00392157 0.0117647 0.0196078 0.027451 0.0352941 0.0431373 0.0509804 0.0588235 0.0666667 0.0745098 0.0823529 0.0901961 0.0980392 0.105882 0.113725 0.121569 0.129412 0.137255 0.145098 0.152941 0.160784 0.168627 0.176471 0.184314 0.192157 0.2 0.207843 0.215686 0.223529 0.231373 0.239216 0.247059 0.254902 0.262745 0.270588 0.278431 0.286275 0.294118 0.301961 0.309804 0.317647 0.32549 0.333333 0.341176 0.34902 0.356863 0.364706 0.372549 0.380392 0.388235 0.396078 0.403922 0.411765 0.419608 0.427451 0.435294 0.443137 0.45098 0.458824 0.466667 0.47451 0.482353 0.490196 0.498039 0.501961 0.494118 0.486275 0.478431 0.470588 0.462745 0.454902 0.447059 0.439216 0.431373 0.423529 0.415686 0.407843 0.4 0.392157 0.384314 0.376471 0.368627 0.360784 0.352941 0.345098 0.337255 0.329412 0.321569 0.313725 0.305882 0.298039 0.290196 0.282353 0.27451 0.266667 0.258824 0.25098 0.243137 0.235294 0.227451 0.219608 0.211765 0.203922 0.196078 0.188235 0.180392 0.172549 0.164706 0.156863 0.14902 0.141176 0.133333 0.12549 0.117647 0.109804 0.101961 0.0941176 0.0862745 0.0784314 0.0705882 0.0627451 0.054902 0.0470588 0.0392157 0.0313725 0.0235294 0.0156863 0.00784314))))
   
 (if (= (vector-ref contourtypes (- contour 1)) 0)
      (gimp-drawable-curves-spline drawable channel (vector-ref contourlengths (- contour 1)) (vector-ref contours (- contour 1)))
      (gimp-drawable-curves-explicit drawable channel (vector-ref contourlengths (- contour 1)) (vector-ref contours (- contour 1)))
    )
  )
)

(define (apply-noise img drawable srclayer noise)
  (let* ((drwwidth (car (gimp-drawable-get-width srclayer)))
	 (drwheight (car (gimp-drawable-get-height srclayer)))
	 (layername (car (gimp-item-get-name drawable)))
	 (drwoffsets (gimp-drawable-get-offsets srclayer))
	 (srcmask (car (gimp-layer-get-mask srclayer)))
	 (noiselayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-noise") 100 0)))
	 (blanklayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-noise") 100 0))))
    (add-over-layer img noiselayer srclayer)
    (add-over-layer img blanklayer noiselayer)
    (gimp-layer-set-offsets noiselayer (car drwoffsets) (cadr drwoffsets))
    (gimp-layer-set-offsets blanklayer (car drwoffsets) (cadr drwoffsets))
    (gimp-selection-all img)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill noiselayer 0)
    (gimp-drawable-edit-fill blanklayer 0)
    (gimp-context-set-foreground '(255 255 255))
    (gimp-image-select-item img 2 srcmask)
    (gimp-drawable-edit-fill blanklayer 0)
    (plug-in-hsv-noise 1 img noiselayer 1 0 0 255)
    (gimp-layer-set-mode blanklayer 5)
    (gimp-layer-set-opacity blanklayer noise)
    (set! noiselayer (car (gimp-image-merge-down img blanklayer 0)))
    (set! blanklayer (car (gimp-layer-create-mask noiselayer 5)))
    (gimp-channel-combine-masks srcmask blanklayer 2 0 0)
    (gimp-image-remove-layer img noiselayer)
  )
)

(define (script-fu-layerfx-drop-shadow img
				       drawable
				       color
				       opacity
				       contour
				       noise
				       mode
				       spread
				       size
				       offsetangle
				       offsetdist
				       knockout
				       merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (layername (car (gimp-item-get-name drawable)))
	 (growamt (math-fix-ceil (/ size 2)))
	 (steps (math-fix-round (- size (* (/ spread 100) size))))
	 (lyrgrowamt (math-fix-round (* growamt 1.2)))
	 (shadowlayer (car (gimp-layer-new img (+ drwwidth (* lyrgrowamt 2)) (+ drwheight (* lyrgrowamt 2)) (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-dropshadow") opacity (get-blending-mode mode))))
	 (shadowmask 0)
	 (alphaSel 0)
	 (ang (* (* (+ offsetangle 180) -1) (/ (* 4 (atan 1.0)) 180)))
	 (offsetX (math-fix-round (* offsetdist (cos ang))))
	 (offsetY (math-fix-round (* offsetdist (sin ang))))
	 (origmask 0)
	)
    (add-under-layer img shadowlayer drawable)
    (gimp-layer-set-offsets shadowlayer (- (+ (car drwoffsets) offsetX) lyrgrowamt) (- (+ (cadr drwoffsets) offsetY) lyrgrowamt))
    (gimp-selection-all img)
    (gimp-context-set-foreground color)
    (gimp-drawable-edit-fill shadowlayer 0)
    (gimp-selection-none img)
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
      (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
    )
    (gimp-selection-translate img offsetX offsetY)
    (set! alphaSel (car (gimp-selection-save img)))
    (draw-fix-blurshape img shadowmask steps growamt alphaSel 0)
    (gimp-selection-none img)
    (if (> contour 0)
      (begin
	(apply-contour shadowmask 0 contour)
	(gimp-image-select-item img 2 alphaSel)
	(gimp-selection-grow img growamt)
	(gimp-selection-invert img)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill shadowmask 0)
	(gimp-selection-none img)
      )
    )
    (if (> noise 0)
      (apply-noise img drawable shadowlayer noise)
    )
    (if (= knockout 1)
      (begin
	(gimp-context-set-foreground '(0 0 0))
	(gimp-image-select-item img 2 drawable)
	(gimp-drawable-edit-fill shadowmask 0)
      )
    )
    (gimp-layer-remove-mask shadowlayer 0)
    (gimp-selection-none img)
    (if (= merge 1)
      (begin
	(set! origmask (car (gimp-layer-get-mask drawable)))
	(if (> origmask -1)
	  (gimp-layer-remove-mask drawable 0)
	)
	(set! shadowlayer (car (gimp-image-merge-down img drawable 0)))
	(gimp-item-set-name shadowlayer layername)
      )
    )
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (script-fu-layerfx-inner-shadow img
					drawable
					color
					opacity
					contour
					noise
					mode
					source
					choke
					size
					offsetangle
					offsetdist
					merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (layername (car (gimp-item-get-name drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (shadowlayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-innershadow") opacity (get-blending-mode mode))))
	 (shadowmask 0)
	 (alphaSel 0)
	 (growamt (math-fix-ceil (/ size 2)))
	 (chokeamt (* (/ choke 100) size))
	 (steps (math-fix-round (- size chokeamt)))
	 (ang (* (* (+ offsetangle 180) -1) (/ (* 4 (atan 1.0)) 180)))
	 (offsetX (math-fix-round (* offsetdist (cos ang))))
	 (offsetY (math-fix-round (* offsetdist (sin ang))))
	 (origmask 0)
	 (alphamask 0)
	)
    (add-over-layer img shadowlayer drawable)
    (gimp-layer-set-offsets shadowlayer (car drwoffsets) (cadr drwoffsets))
    (gimp-selection-all img)
    (gimp-context-set-foreground color)
    (gimp-drawable-edit-fill shadowlayer 0)
    (gimp-selection-none img)
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
      (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
    )
    (gimp-selection-translate img offsetX offsetY)
    (set! alphaSel (car (gimp-selection-save img)))
    (if (= source 0)
      (begin
	(gimp-selection-all img)
	(gimp-context-set-foreground '(255 255 255))
	(gimp-drawable-edit-fill shadowmask 0)
	(gimp-image-select-item img 2 alphaSel)
	(draw-fix-blurshape img shadowmask steps (- growamt chokeamt) alphaSel 1)
      )
      (draw-fix-blurshape img shadowmask steps (- growamt chokeamt) alphaSel 0)
    )
    (gimp-selection-none img)
    (if (> contour 0)
      (apply-contour shadowmask 0 contour)
    )
    (if (= merge 0)
      (begin
	(gimp-image-select-item img 2 drawable)
	(gimp-selection-invert img)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill shadowmask 0)
      )
    )
    (if (> noise 0)
      (apply-noise img drawable shadowlayer noise)
    )
    (gimp-layer-remove-mask shadowlayer 0)
    (if (= merge 1)
      (if (= source 0)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (begin
	      (set! origmask (car (gimp-channel-copy origmask)))
	      (gimp-layer-remove-mask drawable 1)
	    )
	  )
	  (set! alphamask (car (gimp-layer-create-mask drawable 3)))
	  (set! shadowlayer (car (gimp-image-merge-down img shadowlayer 0)))
	  (gimp-item-set-name shadowlayer layername)
	  (gimp-layer-add-mask shadowlayer alphamask)
	  (gimp-layer-remove-mask shadowlayer 0)
	  (if (> origmask -1)
	    (gimp-layer-add-mask shadowlayer origmask)
	  )
	)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (begin
	      (set! origmask (car (gimp-channel-copy origmask)))
	      (gimp-layer-remove-mask drawable 1)
	    )
	  )
	  (set! shadowlayer (car (gimp-image-merge-down img shadowlayer 0)))
	  (gimp-item-set-name shadowlayer layername)
	  (if (> origmask -1)
	    (gimp-layer-add-mask shadowlayer origmask)
	  )
	)
      )
    )
    (gimp-selection-none img)
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (script-fu-layerfx-outer-glow img
				      drawable
				      color
				      opacity
				      contour
				      noise
				      mode
				      spread
				      size
				      knockout
				      merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (layername (car (gimp-item-get-name drawable)))
	 (lyrgrowamt (math-fix-round (* size 1.2)))
	 (glowlayer (car (gimp-layer-new img (+ drwwidth (* lyrgrowamt 2)) (+ drwheight (* lyrgrowamt 2)) (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-outerglow") opacity (get-blending-mode mode))))
	 (glowmask 0)
	 (alphaSel 0)
	 (growamt (* (/ spread 100) size))
	 (steps (- size growamt))
	 (origmask 0)
	)
    (add-under-layer img glowlayer drawable)
    (gimp-layer-set-offsets glowlayer (- (car drwoffsets) lyrgrowamt) (- (cadr drwoffsets) lyrgrowamt))
    (gimp-selection-all img)
    (gimp-context-set-foreground color)
    (gimp-drawable-edit-fill glowlayer 0)
    (gimp-selection-none img)
    (set! glowmask (car (gimp-layer-create-mask glowlayer 1)))
    (gimp-layer-add-mask glowlayer glowmask)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
      (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
    )
    (set! alphaSel (car (gimp-selection-save img)))
    (draw-fix-blurshape img glowmask steps size alphaSel 0)
    (gimp-selection-none img)
    (if (> contour 0)
      (begin
	(apply-contour glowmask 0 contour)
	(gimp-image-select-item img 2 alphaSel)
	(gimp-selection-grow img size)
	(gimp-selection-invert img)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill glowmask 0)
	(gimp-selection-none img)
      )
    )
    (if (> noise 0)
      (apply-noise img drawable glowlayer noise)
    )
    (if (= knockout 1)
      (begin
	(gimp-context-set-foreground '(0 0 0))
	(gimp-image-select-item img 2 drawable)
	(gimp-drawable-edit-fill glowmask 0)
      )
    )
    (gimp-layer-remove-mask glowlayer 0)
    (gimp-selection-none img)
    (if (= merge 1)
      (begin
	(set! origmask (car (gimp-layer-get-mask drawable)))
	(if (> origmask -1)
	  (gimp-layer-remove-mask drawable 0)
	)
	(set! glowlayer (car (gimp-image-merge-down img drawable 0)))
	(gimp-item-set-name glowlayer layername)
      )
    )
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (script-fu-layerfx-inner-glow img
				      drawable
				      color
				      opacity
				      contour
				      noise
				      mode
				      source
				      choke
				      size
				      merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (layername (car (gimp-item-get-name drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (glowlayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-innerglow") opacity (get-blending-mode mode))))
	 (glowmask 0)
	 (alphaSel 0)
	 (shrinkamt (* (/ choke 100) size))
	 (steps (- size shrinkamt))
	 (i 0)
	 (currshade 0)
	 (origmask 0)
	 (alphamask 0)
	)
    (add-over-layer img glowlayer drawable)
    (gimp-layer-set-offsets glowlayer (car drwoffsets) (cadr drwoffsets))
    (gimp-selection-all img)
    (gimp-context-set-foreground color)
    (gimp-drawable-edit-fill glowlayer 0)
    (gimp-selection-none img)
    (set! glowmask (car (gimp-layer-create-mask glowlayer 1)))
    (gimp-layer-add-mask glowlayer glowmask)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
      (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
    )
    (set! alphaSel (car (gimp-selection-save img)))
    (if (= source 0)
      (begin
	(gimp-selection-all img)
	(gimp-context-set-foreground '(255 255 255))
	(gimp-drawable-edit-fill glowmask 0)
	(gimp-image-select-item img 2 alphaSel)
	(draw-fix-blurshape img glowmask steps (- (* shrinkamt -1) 1) alphaSel 1)
      )
      (draw-fix-blurshape img glowmask steps (* shrinkamt -1) alphaSel 0)
    )
    (gimp-selection-none img)
    (if (> contour 0)
      (apply-contour glowmask 0 contour)
    )
    (if (and (= source 0) (= merge 0))
      (begin
	(gimp-image-select-item img 2 alphaSel)
	(gimp-selection-invert img)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill glowmask 0)
      )
    )
    (if (> noise 0)
      (apply-noise img drawable glowlayer noise)
    )
    (gimp-layer-remove-mask glowlayer 0)
    (if (= merge 1)
      (if (= source 0)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (begin
	      (set! origmask (car (gimp-channel-copy origmask)))
	      (gimp-layer-remove-mask drawable 1)
	    )
	  )
	  (set! alphamask (car (gimp-layer-create-mask drawable 3)))
	  (set! glowlayer (car (gimp-image-merge-down img glowlayer 0)))
	  (gimp-item-set-name glowlayer layername)
	  (gimp-layer-add-mask glowlayer alphamask)
	  (gimp-layer-remove-mask glowlayer 0)
	  (if (> origmask -1)
	    (gimp-layer-add-mask glowlayer origmask)
	  )
	)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (begin
	      (set! origmask (car (gimp-channel-copy origmask)))
	      (gimp-layer-remove-mask drawable 1)
	    )
	  )
	  (set! glowlayer (car (gimp-image-merge-down img glowlayer 0)))
	  (gimp-item-set-name glowlayer layername)
	  (if (> origmask -1)
	    (gimp-layer-add-mask glowlayer origmask)
	  )
	)
      )
    )
    (gimp-selection-none img)
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (script-fu-layerfx-bevel-emboss img
					drawable
					style
					depth
					direction
					size
					soften
					angle
					altitude
					glosscontour
					highlightcolor
					highlightmode
					highlightopacity
					shadowcolor
					shadowmode
					shadowopacity
					surfacecontour
					invert
					merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (layername (car (gimp-item-get-name drawable)))
	 (imgtype (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)))
	 (lyrgrowamt (math-fix-round (* size 1.2)))
	 (bumpmaplayer 0)
	 (highlightlayer 0)
	 (highlightmask 0)
	 (shadowlayer 0)
	 (shadowmask 0)
	 (layersize 0)
	 (alphaSel 0)
	 (halfsizef 0)
	 (halfsizec 0)
	 (origmask 0)
	 (alphamask 0)
	)
    (cond
      ((= style 0)
	(begin
	  (set! layersize (list
	    (+ drwwidth (* lyrgrowamt 2))
	    (+ drwheight (* lyrgrowamt 2))
	    (- (car drwoffsets) lyrgrowamt)
	    (- (cadr drwoffsets) lyrgrowamt)
	  ))
	)
      )
      ((= style 1)
	(begin
	  (set! layersize (list
	    drwwidth
	    drwheight
	    (car drwoffsets)
	    (cadr drwoffsets)
	  ))
	)
      )
      ((= style 2)
	(begin
	  (set! layersize (list
	    (+ drwwidth lyrgrowamt)
	    (+ drwheight lyrgrowamt)
	    (- (car drwoffsets) (floor (/ lyrgrowamt 2)))
	    (- (cadr drwoffsets) (floor (/ lyrgrowamt 2)))
	  ))
	)
      )
      (
	(begin
	  (set! layersize (list
	    (+ drwwidth lyrgrowamt)
	    (+ drwheight lyrgrowamt)
	    (- (car drwoffsets) (floor (/ lyrgrowamt 2)))
	    (- (cadr drwoffsets) (floor (/ lyrgrowamt 2)))
	  ))
	)
      )
    )
    (set! bumpmaplayer (car (gimp-layer-new img (car layersize) (cadr layersize) imgtype (string-append layername "-bumpmap") 100 0)))
    (set! highlightlayer (car (gimp-layer-new img (car layersize) (cadr layersize) imgtype (string-append layername "-highlight") highlightopacity (get-blending-mode highlightmode))))
    (set! shadowlayer (car (gimp-layer-new img (car layersize) (cadr layersize) imgtype (string-append layername "-shadow") shadowopacity (get-blending-mode shadowmode))))
    (add-over-layer img bumpmaplayer drawable)
    (add-over-layer img shadowlayer bumpmaplayer)
    (add-over-layer img highlightlayer shadowlayer)
    (gimp-layer-set-offsets bumpmaplayer (caddr layersize) (cadddr layersize))
    (gimp-layer-set-offsets shadowlayer (caddr layersize) (cadddr layersize))
    (gimp-layer-set-offsets highlightlayer (caddr layersize) (cadddr layersize))
    (gimp-selection-all img)
    (gimp-context-set-foreground highlightcolor)
    (gimp-drawable-edit-fill highlightlayer 0)
    (gimp-context-set-foreground shadowcolor)
    (gimp-drawable-edit-fill shadowlayer 0)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill bumpmaplayer 0)
    (set! highlightmask (car (gimp-layer-create-mask highlightlayer 1)))
    (set! shadowmask (car (gimp-layer-create-mask shadowlayer 1)))
    (gimp-layer-add-mask highlightlayer highlightmask)
    (gimp-layer-add-mask shadowlayer shadowmask)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
       (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
    )
    (set! alphaSel (car (gimp-selection-save img)))
    (cond
      ((= style 0)
	(draw-fix-blurshape img bumpmaplayer size size alphaSel 0)
      )
      ((= style 1)
	(draw-fix-blurshape img bumpmaplayer size 0 alphaSel 0)
      )
      ((= style 2)
	(begin
	  (set! halfsizec (math-fix-ceil (/ size 2)))
	  (draw-fix-blurshape img bumpmaplayer size halfsizec alphaSel 0)
	)
      )
      (
	(begin
	  (set! halfsizef (floor (/ size 2)))
	  (set! halfsizec (- size halfsizef))
	  (gimp-selection-all img)
	  (gimp-context-set-foreground '(255 255 255))
	  (gimp-drawable-edit-fill bumpmaplayer 0)
	  (draw-fix-blurshape img bumpmaplayer halfsizec halfsizec alphaSel 1)
	  (draw-fix-blurshape img bumpmaplayer halfsizef 0 alphaSel 0)
	)
      )
    )
    (gimp-selection-all img)
    (gimp-context-set-foreground '(127 127 127))
    (gimp-drawable-edit-fill highlightmask 0)
    (gimp-selection-none img)
    (if (> surfacecontour 0)
      (apply-contour bumpmaplayer 0 surfacecontour)
    )
    (if (< angle 0)
      (set! angle (+ angle 360))
    )
    (plug-in-bump-map 1 img highlightmask bumpmaplayer angle altitude depth 0 0 0 0 1 direction 0)
    (if (> glosscontour 0)
      (apply-contour highlightmask 0 glosscontour)
    )
    (if (> soften 0)
      (plug-in-gauss-rle 1 img highlightmask soften 1 1)
    )
    (if (> invert 0)
      (gimp-drawable-invert highlightmask TRUE)
    )
    (gimp-channel-combine-masks shadowmask highlightmask 2 0 0)
    (gimp-drawable-levels highlightmask 0 0.5 1 FALSE 1.0 0 1 FALSE)
    (gimp-drawable-levels shadowmask 0 0 0.5 FALSE 1.0 1 0 FALSE)
    (gimp-image-select-item img 2 alphaSel)
    (if (= style 0)
      (gimp-selection-grow img size)
      (if (or (= style 2) (= style 3))
	(gimp-selection-grow img halfsizec)
      )
    )
    (gimp-selection-invert img)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill shadowmask 0)
    (gimp-selection-none img)
    (gimp-image-remove-layer img bumpmaplayer)
    (if (= merge 1)
      (if (= style 1)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (begin
	      (set! origmask (car (gimp-channel-copy origmask)))
	      (gimp-layer-remove-mask drawable 1)
	    )
	  )
	  (set! alphamask (car (gimp-layer-create-mask drawable 3)))
	  (set! shadowlayer (car (gimp-image-merge-down img shadowlayer 0)))
	  (set! highlightlayer (car (gimp-image-merge-down img highlightlayer 0)))
	  (gimp-item-set-name highlightlayer layername)
	  (gimp-layer-add-mask highlightlayer alphamask)
	  (gimp-layer-remove-mask highlightlayer 0)
	  (if (> origmask -1)
	    (gimp-layer-add-mask highlightlayer origmask)
	  )
	)
	(begin
	  (set! origmask (car (gimp-layer-get-mask drawable)))
	  (if (> origmask -1)
	    (gimp-layer-remove-mask drawable 0)
	  )
	  (set! shadowlayer (car (gimp-image-merge-down img shadowlayer 0)))
	  (set! highlightlayer (car (gimp-image-merge-down img highlightlayer 0)))
	  (gimp-item-set-name highlightlayer layername)
	)
      )
    )
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (script-fu-layerfx-satin img
				 drawable
				 color
				 opacity
				 mode
				 offsetangle
				 offsetdist
				 size
				 contour
				 invert
				 merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (layername (car (gimp-item-get-name drawable)))
	 (growamt (math-fix-ceil (/ size 2)))
	 (lyrgrowamt (math-fix-round (* growamt 1.2)))
	 (satinlayer (car (gimp-layer-new img (+ (car (gimp-drawable-get-width drawable)) (* lyrgrowamt 2)) (+ (car (gimp-drawable-get-height drawable)) (* lyrgrowamt 2)) (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-satin") 100 0)))
	 (satinmask 0)
	 (blacklayer 0)
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (ang (* (* (+ offsetangle 180) -1) (/ (* 4 (atan 1.0)) 180)))
	 (offsetX (math-fix-round (* offsetdist (cos ang))))
	 (offsetY (math-fix-round (* offsetdist (sin ang))))
	 (alphaSel 0)
	 (layeraoffsets 0)
	 (layerboffsets 0)
	 (dx 0)
	 (dy 0)
	 (origmask 0)
	 (alphamask 0)
	)
    (add-over-layer img satinlayer drawable)
    (gimp-layer-set-offsets satinlayer (- (car drwoffsets) lyrgrowamt) (- (cadr drwoffsets) lyrgrowamt))
    (gimp-selection-all img)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill satinlayer 0)
    (gimp-selection-none img)
    (gimp-image-select-item img 2 drawable)
    (if (> (car (gimp-layer-get-mask drawable)) -1)
       (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
    )
    (set! alphaSel (car (gimp-selection-save img)))
    (draw-fix-blurshape img satinlayer size growamt alphaSel 0)
    ;(plug-in-autocrop-layer 1 img satinlayer)
    (set! satinmask (car (gimp-layer-copy satinlayer 0)))
    (add-over-layer img satinmask satinlayer)
    (gimp-item-transform-translate satinlayer offsetX offsetY)
    (gimp-item-transform-translate satinmask (* offsetX -1) (* offsetY -1))
    (set! layeraoffsets (gimp-drawable-get-offsets satinlayer))
    (set! layerboffsets (gimp-drawable-get-offsets satinmask))
    (set! dx (- (max (car layeraoffsets) (car layerboffsets)) (min (car layeraoffsets) (car layerboffsets))))
    (set! dy (- (max (cadr layeraoffsets) (cadr layerboffsets)) (min (cadr layeraoffsets) (cadr layerboffsets))))
    (set! blacklayer (car (gimp-layer-new img (+ (car (gimp-drawable-get-width satinlayer)) dx) (+ (car (gimp-drawable-get-height satinlayer)) dy) (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-satinblank") 100 0)))
    (add-under-layer img blacklayer satinlayer)
    (gimp-layer-set-offsets blacklayer (min (car layeraoffsets) (car layerboffsets)) (min (cadr layeraoffsets) (cadr layerboffsets)))
    (gimp-selection-all img)
    (gimp-context-set-foreground '(0 0 0))
    (gimp-drawable-edit-fill blacklayer 0)
    (gimp-selection-none img)
    (gimp-layer-set-mode satinmask 6)
    (set! satinlayer (car (gimp-image-merge-down img satinlayer 0)))
    (set! satinlayer (car (gimp-image-merge-down img satinmask 0)))
    (gimp-item-set-name satinlayer (string-append layername "-satin"))
    (if (> contour 0)
      (begin
	(apply-contour satinlayer 0 contour)
	(gimp-image-select-item img 2 alphaSel)
	(gimp-selection-grow img size)
	(gimp-selection-invert img)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill satinlayer 0)
	(gimp-selection-none img)
      )
    )
    (if (= invert 1)
      (gimp-drawable-invert satinlayer TRUE)
    )
    (set! satinmask (car (gimp-layer-create-mask satinlayer 5)))
    (gimp-layer-add-mask satinlayer satinmask)
    (gimp-selection-all img)
    (gimp-context-set-foreground color)
    (gimp-drawable-edit-fill satinlayer 0)
    (gimp-selection-none img)
    (gimp-layer-set-opacity satinlayer opacity)
    (gimp-layer-set-mode satinlayer (get-blending-mode mode))
    (gimp-layer-resize satinlayer (car (gimp-drawable-get-width drawable)) (car (gimp-drawable-get-height drawable)) (- (car (gimp-drawable-get-offsets satinlayer)) (car drwoffsets)) (- (cadr (gimp-drawable-get-offsets satinlayer)) (cadr drwoffsets)))
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
	(set! satinlayer (car (gimp-image-merge-down img satinlayer 0)))
	(gimp-item-set-name satinlayer layername)
	(gimp-layer-add-mask satinlayer alphamask)
	(gimp-layer-remove-mask satinlayer 0)
	(if (> origmask -1)
	  (gimp-layer-add-mask satinlayer origmask)
	)
      )
      (begin
	(gimp-image-select-item img 2 alphaSel)
	(gimp-selection-invert img)
	(gimp-context-set-foreground '(0 0 0))
	(gimp-drawable-edit-fill satinmask 0)
      )
    )
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaSel)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (script-fu-layerfx-stroke img
				  drawable
				  color
				  opacity
				  mode
				  size
				  position
				  merge)
  (gimp-image-undo-group-start img)
  (let* ((origfgcolor (car (gimp-context-get-foreground)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (layername (car (gimp-item-get-name drawable)))
	 (strokelayer 0)
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (alphaselection 0)
	 (outerselection 0)
	 (innerselection 0)
	 (origmask 0)
	 (alphamask 0)
	 (outerwidth 0)
	 (innerwidth 0)
	 (growamt 0)
	)
    (if (= position 0)
      (begin
	(set! strokelayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-stroke") opacity (get-blending-mode mode))))
	(add-over-layer img strokelayer drawable)
	(gimp-layer-set-offsets strokelayer (car drwoffsets) (cadr drwoffsets))
	(gimp-selection-all img)
	(gimp-drawable-edit-clear strokelayer)
	(gimp-selection-none img)
	(gimp-image-select-item img 2 drawable)
	(if (> (car (gimp-layer-get-mask drawable)) -1)
	  (gimp-image-select-item 3 img (car (gimp-layer-get-mask drawable)))
	)
	(set! alphaselection (car (gimp-selection-save img)))
	(gimp-selection-shrink img size)
	(set! innerselection (car (gimp-selection-save img)))
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
	    (gimp-selection-none img)
	    (gimp-drawable-threshold alphaselection 0,00392156862745 1)
	    (gimp-image-select-item img 2 alphaselection)
	    (gimp-image-select-item img 1 innerselection)
	    (gimp-context-set-foreground color)
	    (gimp-drawable-edit-fill strokelayer 0)
	    (set! strokelayer (car (gimp-image-merge-down img strokelayer 0)))
	    (gimp-item-set-name strokelayer layername)
	    (gimp-layer-add-mask strokelayer alphamask)
	    (gimp-layer-remove-mask strokelayer 0)
	    (if (> origmask -1)
	      (gimp-layer-add-mask strokelayer origmask)
	    )
	  )
	  (begin
	    (gimp-image-select-item img 2 alphaselection)
	    (gimp-image-select-item img 1 innerselection)
	    (gimp-context-set-foreground color)
	    (gimp-drawable-edit-fill strokelayer 0)
	  )
	)
      )
      (if (= position 100)
	(begin
	  (set! growamt (math-fix-round (* size 1.2)))
	  (set! strokelayer (car (gimp-layer-new img (+ drwwidth (* growamt 2)) (+ drwheight (* growamt 2)) (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-stroke") opacity (get-blending-mode mode))))
	  (add-under-layer img strokelayer drawable)
	  (gimp-layer-set-offsets strokelayer (- (car drwoffsets) growamt) (- (cadr drwoffsets) growamt))
	  (gimp-selection-all img)
	  (gimp-drawable-edit-clear strokelayer)
	  (gimp-selection-none img)
	  (gimp-image-select-item img 2 drawable)
	  (if (> (car (gimp-layer-get-mask drawable)) -1)
	    (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
	  )
	  (set! alphaselection (car (gimp-selection-save img)))
	  (set! innerselection (car (gimp-selection-save img)))
	  (gimp-selection-none img)
	  (gimp-drawable-threshold innerselection 1 1)
	  (gimp-image-select-item img 2 alphaselection)
	  (gimp-selection-grow img size)
	  (gimp-image-select-item img 1 innerselection)
	  (gimp-context-set-foreground color)
	  (gimp-drawable-edit-fill strokelayer 0)
	  (if (= merge 1)
	    (begin
	      (set! origmask (car (gimp-layer-get-mask drawable)))
	      (if (> origmask -1)
		(gimp-layer-remove-mask drawable 0)
	      )
	      (set! strokelayer (car (gimp-image-merge-down img drawable 0)))
	      (gimp-item-set-name strokelayer layername)
	    )
	  )
	)
	(begin
	  (set! outerwidth (math-fix-round (* (/ position 100) size)))
	  (set! innerwidth (- size outerwidth))
	  (set! growamt (math-fix-round (* outerwidth 1.2)))
	  (set! strokelayer (car (gimp-layer-new img (+ drwwidth (* growamt 2)) (+ drwheight (* growamt 2)) (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-stroke") opacity (get-blending-mode mode))))
	  (add-over-layer img strokelayer drawable)
	  (gimp-layer-set-offsets strokelayer (- (car drwoffsets) growamt) (- (cadr drwoffsets) growamt))
	  (gimp-selection-all img)
	  (gimp-drawable-edit-clear strokelayer)
	  (gimp-selection-none img)
	  (gimp-image-select-item img 2 drawable)
	  (if (> (car (gimp-layer-get-mask drawable)) -1)
	    (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
	  )
	  (set! alphaselection (car (gimp-selection-save img)))
	  (gimp-selection-shrink img innerwidth)
	  (set! innerselection (car (gimp-selection-save img)))
	  (gimp-image-select-item img 2 alphaselection)
	  (gimp-selection-grow img outerwidth)
	  (gimp-image-select-item img 1 innerselection)
	  (gimp-context-set-foreground color)
	  (gimp-drawable-edit-fill strokelayer 0)
	  (if (= merge 1)
	    (begin
	      (set! origmask (car (gimp-layer-get-mask drawable)))
	      (if (> origmask -1)
		(gimp-layer-remove-mask drawable 0)
	      )
	      (set! strokelayer (car (gimp-image-merge-down img strokelayer 0)))
	      (gimp-item-set-name strokelayer layername)
	    )
	  )
	)
      )
    )
    (gimp-context-set-foreground origfgcolor)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img alphaselection)
    (gimp-image-remove-channel img innerselection)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (script-fu-layerfx-color-overlay img
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
    (gimp-context-set-foreground color)
    (gimp-drawable-edit-fill colorlayer 0)
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

(define (script-fu-layerfx-gradient-overlay img
					    drawable
					    grad
					    gradtype
					    repeattype
					    reverse
					    opacity
					    mode
					    cx
					    cy
					    gradangle
					    gradsize
					    merge)
  (gimp-image-undo-group-start img)
  (let* ((origgradient (car (gimp-context-get-gradient)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (layername (car (gimp-item-get-name drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (gradientlayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-gradient") opacity (get-blending-mode mode))))
	 (origmask 0)
	 (alphamask 0)
	 (ang (* (* gradangle -1) (/ (* 4 (atan 1.0)) 180)))
	 (offsetX (math-fix-round (* (/ gradsize 2) (cos ang))))
	 (offsetY (math-fix-round (* (/ gradsize 2) (sin ang))))
	 (x1 (- (- cx offsetX) (car drwoffsets)))
	 (y1 (- (- cy offsetY) (cadr drwoffsets)))
	 (x2 (- (+ cx offsetX) (car drwoffsets)))
	 (y2 (- (+ cy offsetY) (cadr drwoffsets)))
	)
    (add-over-layer img gradientlayer drawable)
    (gimp-layer-set-offsets gradientlayer (car drwoffsets) (cadr drwoffsets))
    (gimp-selection-none img)
    (gimp-drawable-edit-clear gradientlayer)
    (gimp-context-set-gradient grad)
    (if (and (>= gradtype 6) (<= gradtype 8))
      (gimp-image-select-item img 2 drawable)
    )
    ;(gimp-edit-blend gradientlayer 3 0 gradtype 100 1 repeattype reverse 0 1 0 0 x1 y1 x2 y2)
    (gimp-context-set-gradient-reverse reverse)
    (gimp-context-get-gradient-repeat-mode repeattype )
   ; (gimp-drawable-edit-gradient-fill gradientlayer gradtype 0 repeattype FALSE 0.2 TRUE x1 y1 x2 y2)
     (gimp-drawable-edit-gradient-fill gradientlayer gradtype 0  FALSE 0 0 0 x1 y1 x2 y2)
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
	(set! gradientlayer (car (gimp-image-merge-down img gradientlayer 0)))
	(gimp-item-set-name gradientlayer layername)
	(gimp-layer-add-mask gradientlayer alphamask)
	(gimp-layer-remove-mask gradientlayer 0)
	(if (> origmask -1)
	  (gimp-layer-add-mask gradientlayer origmask)
	)
      )
      (begin
	(gimp-image-select-item img 2 drawable)
	(if (> (car (gimp-layer-get-mask drawable)) -1)
	  (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
	)
	(set! alphamask (car (gimp-layer-create-mask gradientlayer 4)))
	(gimp-layer-add-mask gradientlayer alphamask)
	(gimp-layer-remove-mask gradientlayer 0)
      )
    )
    (gimp-context-set-gradient origgradient)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(define (script-fu-layerfx-pattern-overlay img
					   drawable
					   pattern
					   opacity
					   mode
					   merge)
  (gimp-image-undo-group-start img)
  (let* ((origpattern (car (gimp-context-get-pattern)))
	 (origselection (car (gimp-selection-save img)))
	 (drwwidth (car (gimp-drawable-get-width drawable)))
	 (drwheight (car (gimp-drawable-get-height drawable)))
	 (layername (car (gimp-item-get-name drawable)))
	 (drwoffsets (gimp-drawable-get-offsets drawable))
	 (patternlayer (car (gimp-layer-new img drwwidth drwheight (cond ((= (car (gimp-image-get-base-type img)) 0) 1) ((= (car (gimp-image-get-base-type img)) 1) 3)) (string-append layername "-pattern") opacity (get-blending-mode mode))))
	 (origmask 0)
	 (alphamask 0)
	)
    (add-over-layer img patternlayer drawable)
    (gimp-layer-set-offsets patternlayer (car drwoffsets) (cadr drwoffsets))
    (gimp-selection-all img)
    (gimp-context-set-pattern pattern)
    (gimp-drawable-edit-fill patternlayer 4)
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
	(set! patternlayer (car (gimp-image-merge-down img patternlayer 0)))
	(gimp-item-set-name patternlayer layername)
	(gimp-layer-add-mask patternlayer alphamask)
	(gimp-layer-remove-mask patternlayer 0)
	(if (> origmask -1)
	  (gimp-layer-add-mask patternlayer origmask)
	)
      )
      (begin
	(gimp-image-select-item img 2 drawable)
	(if (> (car (gimp-layer-get-mask drawable)) -1)
	  (gimp-image-select-item img 3 (car (gimp-layer-get-mask drawable)))
	)
	(set! alphamask (car (gimp-layer-create-mask patternlayer 4)))
	(gimp-layer-add-mask patternlayer alphamask)
	(gimp-layer-remove-mask patternlayer 0)
      )
    )
    (gimp-context-set-pattern origpattern)
    (gimp-image-select-item img 2 origselection)
    (gimp-image-remove-channel img origselection)
    (gimp-displays-flush)
  )
  (gimp-image-undo-group-end img)
)

(script-fu-register "script-fu-layerfx-drop-shadow"
		    "Drop Shadow..."
		    "Adds a drop shadow to a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"				0
		    SF-DRAWABLE		"Drawable"			0
		    SF-COLOR		_"Color"			'(0 0 0)
		    SF-ADJUSTMENT	"Opacity"			'(75 0 100 1 10 1 0)
		    SF-OPTION		"Contour"			'("Linear" "Cone" "Cone - Inverted" "Cove - Deep" "Cove-Shallow" "Gaussian" "Half Round" "Ring" "Ring - Double" "Rolling Slope - Descending" "Rounded Steps" "Sawtooth 1")
		    SF-ADJUSTMENT	"Noise"				'(0 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"			'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-ADJUSTMENT	"Spread"			'(0 0 100 1 10 1 0)
		    SF-ADJUSTMENT	"Size"				'(5 0 250 1 10 1 1)
		    SF-ADJUSTMENT	"Offset Angle"			'(120 -180 180 1 10 1 0)
		    SF-ADJUSTMENT	"Offset Distance"		'(5 0 30000 1 10 1 1)
		    SF-TOGGLE		"Layer knocks out Drop Shadow"	FALSE
		    SF-TOGGLE		"Merge with layer"		FALSE)
(script-fu-menu-register "script-fu-layerfx-drop-shadow" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-drop-shadow" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-inner-shadow"
		    "Inner Shadow..."
		    "Adds an inner shadow to a layer"
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"			0
		    SF-DRAWABLE		"Drawable"		0
		    SF-COLOR		_"Color"		'(0 0 0)
		    SF-ADJUSTMENT	"Opacity"		'(75 0 100 1 10 1 0)
		    SF-OPTION		"Contour"		'("Linear" "Cone" "Cone - Inverted" "Cove - Deep" "Cove-Shallow" "Gaussian" "Half Round" "Ring" "Ring - Double" "Rolling Slope - Descending" "Rounded Steps" "Sawtooth 1")
		    SF-ADJUSTMENT	"Noise"			'(0 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"		'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-OPTION		"Source"		'("Edge" "Center")
		    SF-ADJUSTMENT	"Choke"			'(0 0 100 1 10 1 0)
		    SF-ADJUSTMENT	"Size"			'(5 0 250 1 10 1 1)
		    SF-ADJUSTMENT	"Offset Angle"		'(120 -180 180 1 10 1 0)
		    SF-ADJUSTMENT	"Offset Distance"	'(5 0 30000 1 10 1 1)
		    SF-TOGGLE		"Merge with layer"	FALSE)
(script-fu-menu-register "script-fu-layerfx-inner-shadow" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-inner-shadow" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-outer-glow"
		    "Outer Glow..."
		    "Creates an outer glow effect around a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"				0
		    SF-DRAWABLE		"Drawable"			0
		    SF-COLOR		_"Color"			'(255 255 190)
		    SF-ADJUSTMENT	"Opacity"			'(75 0 100 1 10 1 0)
		    SF-OPTION		"Contour"			'("Linear" "Cone" "Cone - Inverted" "Cove - Deep" "Cove-Shallow" "Gaussian" "Half Round" "Ring" "Ring - Double" "Rolling Slope - Descending" "Rounded Steps" "Sawtooth 1")
		    SF-ADJUSTMENT	"Noise"				'(0 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"			'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-ADJUSTMENT	"Spread"			'(0 0 100 1 10 1 0)
		    SF-ADJUSTMENT	"Size"				'(5 0 999 1 10 1 1)
		    SF-TOGGLE		"Layer knocks out Outer Glow"	FALSE
		    SF-TOGGLE		"Merge with layer"		FALSE)
(script-fu-menu-register "script-fu-layerfx-outer-glow" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-outer-glow" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-inner-glow"
		    "Inner Glow..."
		    "Creates an inner glow effect around a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"			0
		    SF-DRAWABLE		"Drawable"		0
		    SF-COLOR		_"Color"		'(255 255 190)
		    SF-ADJUSTMENT	"Opacity"		'(75 0 100 1 10 1 0)
		    SF-OPTION		"Contour"		'("Linear" "Cone" "Cone - Inverted" "Cove - Deep" "Cove-Shallow" "Gaussian" "Half Round" "Ring" "Ring - Double" "Rolling Slope - Descending" "Rounded Steps" "Sawtooth 1")
		    SF-ADJUSTMENT	"Noise"			'(0 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"		'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-OPTION		"Source"		'("Edge" "Center")
		    SF-ADJUSTMENT	"Choke"			'(0 0 100 1 10 1 0)
		    SF-ADJUSTMENT	"Size"			'(5 0 999 1 10 1 1)
		    SF-TOGGLE		"Merge with layer"	FALSE)
(script-fu-menu-register "script-fu-layerfx-inner-glow" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-inner-glow" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-bevel-emboss"
		    "Bevel and Emboss..."
		    "Creates beveling and embossing effects over a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"			0
		    SF-DRAWABLE		"Drawable"		0
		    SF-OPTION		"Style"			'("Outer Bevel" "Inner Bevel" "Emboss" "Pillow Emboss")
		    SF-ADJUSTMENT	"Depth"			'(3 1 65 1 10 0 0)
		    SF-OPTION		"Direction"		'("Up" "Down")
		    SF-ADJUSTMENT	"Size"			'(5 0 250 1 10 0 0)
		    SF-ADJUSTMENT	"Soften"		'(0 0 16 1 2 0 0)
		    SF-ADJUSTMENT	"Angle"			'(120 -180 180 1 10 1 0)
		    SF-ADJUSTMENT	"Altitude"		'(30 0 90 1 10 1 0)
		    SF-OPTION		"Gloss Contour"		'("Linear" "Cone" "Cone - Inverted" "Cove - Deep" "Cove-Shallow" "Gaussian" "Half Round" "Ring" "Ring - Double" "Rolling Slope - Descending" "Rounded Steps" "Sawtooth 1")
		    SF-COLOR		_"Highlight Color"	'(255 255 255)
		    SF-OPTION		"Highlight Mode"	'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-ADJUSTMENT	"Highlight Opacity"	'(75 0 100 1 10 1 0)
		    SF-COLOR		_"Shadow Color"		'(0 0 0)
		    SF-OPTION		"Shadow Mode"		'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-ADJUSTMENT	"Shadow Opacity"	'(75 0 100 1 10 1 0)
		    SF-OPTION		"Surface Contour"	'("Linear" "Cone" "Cone - Inverted" "Cove - Deep" "Cove-Shallow" "Gaussian" "Half Round" "Ring" "Ring - Double" "Rolling Slope - Descending" "Rounded Steps" "Sawtooth 1")
		    SF-TOGGLE		"Invert"		FALSE
		    SF-TOGGLE		"Merge with layer"	FALSE)
(script-fu-menu-register "script-fu-layerfx-bevel-emboss" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-bevel-emboss" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-satin"
		    "Satin..."
		    "Creates a satin effect over a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"			0
		    SF-DRAWABLE		"Drawable"		0
		    SF-COLOR		_"Color"		'(0 0 0)
		    SF-ADJUSTMENT	"Opacity"		'(75 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"		'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-ADJUSTMENT	"Offset Angle"		'(19 -180 180 1 10 1 0)
		    SF-ADJUSTMENT	"Offset Distance"	'(11 0 30000 1 10 1 1)
		    SF-ADJUSTMENT	"Size"			'(14 0 250 1 10 0 0)
		    SF-OPTION		"Contour"		'("Linear" "Cone" "Cone - Inverted" "Cove - Deep" "Cove-Shallow" "Gaussian" "Half Round" "Ring" "Ring - Double" "Rolling Slope - Descending" "Rounded Steps" "Sawtooth 1")
		    SF-TOGGLE		"Invert"		TRUE
		    SF-TOGGLE		"Merge with layer"	FALSE)
(script-fu-menu-register "script-fu-layerfx-satin" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-satin" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-stroke"
		    "Stroke..."
		    "Creates a stroke around a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"					0
		    SF-DRAWABLE		"Drawable"				0
		    SF-COLOR		_"Color"				'(255 255 255)
		    SF-ADJUSTMENT	"Opacity"				'(100 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"				'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-ADJUSTMENT	"Size"					'(1 1 999 1 10 0 1)
		    SF-ADJUSTMENT	"Position (1 = inside, 99 = outside)"	'(50 1 99 1 10 1 0)
		    SF-TOGGLE		"Merge with layer"			FALSE)
(script-fu-menu-register "script-fu-layerfx-stroke" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-stroke" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-color-overlay"
		    "Color Overlay..."
		    "Overlays a color over a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"			0
		    SF-DRAWABLE		"Drawable"		0
		    SF-COLOR		_"Color"		'(255 255 255)
		    SF-ADJUSTMENT	"Opacity"		'(100 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"		'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-TOGGLE		"Merge with layer"	FALSE)
(script-fu-menu-register "script-fu-layerfx-color-overlay" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-color-overlay" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-gradient-overlay"
		    "Gradient Overlay..."
		    "Overlays a gradient over a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"			0
		    SF-DRAWABLE		"Drawable"		0
		    SF-GRADIENT		_"Gradient"		"Full saturation spectrum CCW"
		    SF-OPTION		"Gradient Type"		'("Linear" "Bi-linear" "Radial" "Square" "Conical (sym)" "Conical (asym)" "Shaped (angular)" "Shaped (spherical)" "Shaped (dimpled)" "Spiral (cw)" "Spiral (ccw)")
		    SF-OPTION		"Repeat"		'("None" "Sawtooth Wave" "Triangular Wave")
		    SF-TOGGLE		"Reverse"		FALSE
		    SF-ADJUSTMENT	"Opacity"		'(100 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"		'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-ADJUSTMENT	"Center X"		'(0 0 262144 1 10 0 1)
		    SF-ADJUSTMENT	"Center Y"		'(0 0 262144 1 10 0 1)
		    SF-ADJUSTMENT	"Gradient Angle"	'(90 -180 180 1 10 1 0)
		    SF-ADJUSTMENT	"Gradient Width"	'(10 0 262144 1 10 1 1)
		    SF-TOGGLE		"Merge with layer"	FALSE)
(script-fu-menu-register "script-fu-layerfx-gradient-overlay" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-gradient-overlay" "<Layers>/Layer Effects By Jon Stipe 299/")

(script-fu-register "script-fu-layerfx-pattern-overlay"
		    "Pattern Overlay..."
		    "Overlays a pattern over a layer."
		    "Jonathan Stipe <JonStipe@prodigy.net>"
		    "Jonathan Stipe"
		    "January 2008"
		    "RGBA, GRAYA"
		    SF-IMAGE		"Image"			0
		    SF-DRAWABLE		"Drawable"		0
		    SF-PATTERN		_"Pattern"		"Blue Squares"
		    SF-ADJUSTMENT	"Opacity"		'(100 0 100 1 10 1 0)
		    SF-OPTION		"Blending Mode"		'("Normal" "Dissolve" "Multiply" "Divide" "Screen" "Overlay" "Dodge" "Burn" "Hard Light" "Soft Light" "Grain Extract" "Grain Merge" "Difference" "Addition" "Subtract" "Darken Only" "Lighten Only" "Hue" "Saturation" "Color" "Value")
		    SF-TOGGLE		"Merge with layer"	FALSE)
(script-fu-menu-register "script-fu-layerfx-pattern-overlay" "<Image>/Layer/Layer Effects By Jon Stipe 299/")
;(script-fu-menu-register "script-fu-layerfx-pattern-overlay" "<Layers>/Layer Effects By Jon Stipe 299/")
