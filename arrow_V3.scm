; Berengar W. Lehr (Berengar.Lehr@gmx.de)
; Medical Physics Group, Department of Diagnostic and Interventional Radiology
; Jena University Hospital, 07743 Jena, Thueringen, Germany
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; If you use this script and/or like it the author would be happy to
; receive a postcard from you:
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;
; Version history:
;   11/10/2009 first release
;   11/15/2009 Added fixed brush width and double headed error, removed bug 1) one-point-paths, 2) horizontal paths
;   11/16/2009 Fixed image type restriction string
;   11/19/2009 Added feature for absolute wing length, fixed handling gray-scale images
;   25/01/2010 Fixed fixed opacity bug (thanks to Richard)
;	20/07/2010 Report an error and terminate the script if the path only has one point.
;              Display a warning message if the path has more than two points
;              Display a warning message if there is more than one path
;              Delete the path by default.
;              Temporarily set the brush mode to 'Normal' (arrows are not drawn normally if 'Disolve'
;				mode (for example) is selected).
;	22/07/2013 Allow curved arrows
;   11/9/2014 - setting the radius of the brush when defining the new brush seems to have no effect in GIMP 2.8.14 - it
;       uses the radius of the brush as specified in the toolbox. These mods save the radius of the
;       toolbox brush, sets the new brush to be the default brush and then sets the radius of the toolbox brush.
;       The toolbox brush radius is then restored afterwards
;   16/9/2014 Use gimp-context-push and gimp-context-pop rather than saving the toolbox brush and radius explicitly
;   20/12/2016 Corrected the drawing of arrow heads at the end of paths that have more than 2 points
;              Added extra controls to determine whether the wing length and brush thickness are related to the path
;                length or in absolute pixels. This is instead of using negative numbers for relative settings and
;                positive numbers for absolute pixel values.
;              Added patches, supplied by Helmut, to allow the script to work in GIMP V2.9/V2.10
;              Removed previous edit comments and commented out code
;              The warning about paths with more than 2 points is now only given once following an activation of GIMP
;                or a refresh of the Script-Fu scripts
;              Swapped the up/down cursor key actions with the page up/down actions for the LoW and BT value fields
;                (the page keys now increment/decrement by 10 and the up/down keys by 1)
;    22/12/2016 Changed "Delete path after arrow was drawn?" to "Delete path after arrow is drawn?"
;    4/9/2017 Changed the final line of the message displayed when the active path has more than two points from
;             "The first and last points are used" to "The first and second points are used" There is no change to the
;             operation of the script. The old message related to the original behaviour of the script.
;   15/1/2018 The error messages displayed when the active path has less than two points (0 or 1) now says that the
;              script needs at least two points
;   18/4/2021 é characters replaced with é characters so that xed doesn't complain (yes they are the same characters but
;             represented in a different way within the file.
;   18/4/2021 Final parameter of the call of gimp-image-insert-layer changed from 0 to -1 - this is, according to the pdb
;             documentation the correct value for placing the new layer at the top
;   18/4/2021 Deprecated function gimp-edit-bucket-fill replaced with gimp-drawable-edit-fill
;   18/4/2021 Deprecated function gimp-edit-stroke-vectors replaced with gimp-drawable-edit-stroke-item
;   6/5/2021  Updated so that the script will register in GIMP V2.99.6
;   6/5/2021  Default settings for length of arrow wings and thickness of the brush altered
;   8/5/2021  Default settings changed to use absolute pixel (rather than proportional) settings
;   27/7/2021 Various sections of conditional code added to allow the script to run in V2.10.x and V2.99.7 and later
;   29/7/2021 Removed the slider from the control that sets the angle between the arrow and the wings. This control is then in the same
;             format as the other SF-ADJUSTMENT controls in the script and it avoids the V2.99.x problem where the control description
;             is repeated
;   13/10/2022 Fix problem where the arrow wings were drawn in the wrong place if the arrow was drawn directly on to a layer that
;              had an offset.
;   13/10/2022 Remove any existing selection(s) before running the script otherwise the arrow is not drawn correctly
;
;   19/10/2022 Started changes for V3 - can't complete these until gimp-image-get-active-vectors() is put back into GIMP or a replacement is
;               provided. Also can't complete the change to a V3 script (and so turn off the nag message about filters that take only a
;               single drawable being deprecated) until SF-OPTION is supported for V3 (or an alternative approach provided).
;
;  3/10/2023 Small changes to have backward compatibility with Gimp 2.10 and make it work without creating a brush and removing it (not possible on 2.99.16) (vitforlinux).
;
;               Replaced call of gimp-image-set-active layer with call of gimp-image-set-selected-layers
;  29/2/2024 fixes for Gimp 2.99.18... work with errors, last version with backwards compatibility with 2.10 (vitforlinux)
;  21/7/2024 fixes for Gimp 2.99.19 r988/R1005 
;
;              programmer_ceds A T yahoo D O T co D O T uk
;
; Fix code for gimp 2.99.6 working in 2.10
(cond ((not (defined? 'gimp-image-get-width)) (define gimp-image-get-width gimp-image-width)))
(cond ((not (defined? 'gimp-image-get-height)) (define gimp-image-get-height gimp-image-height)))
(cond ((not (defined? 'gimp-drawable-get-offsets)) (define gimp-drawable-get-offsets gimp-drawable-offsets)))
(cond ((not (defined? 'gimp-image-get-selected-path)) (define gimp-image-get-selected-path gimp-image-get-vectors)))
(cond ((not (defined? 'gimp-item-id-is-layer)) (define gimp-item-id-is-layer gimp-item-is-layer)))
(cond ((not (defined? 'gimp-image-get-base-type)) (define gimp-image-get-base-type  gimp-image-base-type )))

(define pi (* 4 (atan 1.0)))

(define multi_points_reported 0)       ; set non-zero once the warning about a path with more than 2 points has been displayed

(define major_version_no 0)
(define minor_version_no 0)
(define release_no 0)

(define
    (script-fu-help-1Arrow
        inPointToX
        inPointToY
        inPointFromX
        inPointFromY
        theWingLength
        WingAngle
        drawable
        image
        FullHead
        MiddlePoint
    )
    (let*
        (
        ; calculate absolute angle of both wings in image from relative angle
        ; between wings and arrow-tail and absolute angle of arrow-tail
        (theArrowAngle (if (= (- inPointToY inPointFromY) 0)
            (/ pi (if (< (- inPointToX inPointFromX) 0) 2 -2))
            (+ (atan (/ (- inPointToX inPointFromX) (- inPointToY inPointFromY))) (if (> inPointToY inPointFromY) pi 0))
        ))
        (theLeftAngle  (+ theArrowAngle WingAngle))
        (theRightAngle (- theArrowAngle WingAngle))

        ; calculate end points of both wings
        (theLeftWingEndPointX  (+ inPointToX (* theWingLength (sin theLeftAngle))))
        (theLeftWingEndPointY  (+ inPointToY (* theWingLength (cos theLeftAngle))))
        (theRightWingEndPointX (+ inPointToX (* theWingLength (sin theRightAngle))))
        (theRightWingEndPointY (+ inPointToY (* theWingLength (cos theRightAngle))))

        (points          (cons-array 4 'double))
        (theMiddleWingEndPointX 0)    (theMiddleWingEndPointY 0)
		(PreviousOpacity 100.0)
		(PreviousPaintMode 0)
        )

        (begin
		(set! PreviousOpacity (car (gimp-context-get-opacity)))
		(gimp-context-set-opacity 100.0)
		(set! PreviousPaintMode (car (gimp-context-get-paint-mode)))
        (gimp-context-set-paint-mode LAYER-MODE-NORMAL)

        ; collect points for arrow-tail and draw them
; Now draw the arrow tail along the path in the higher level function rather than a straight line here
        ; accordingly for left wing
        (aset points 0 inPointToX)               (aset points 1 inPointToY)
        (aset points 2 theLeftWingEndPointX)     (aset points 3 theLeftWingEndPointY)
        (gimp-paintbrush-default drawable 4 points) (set! points (cons-array 4 'double))
        ; accordingly for right wing
        (aset points 0 inPointToX)               (aset points 1 inPointToY)
        (aset points 2 theRightWingEndPointX)    (aset points 3 theRightWingEndPointY)
        (gimp-paintbrush-default drawable 4 points)

        ; only if head is to be filled
        (if (= FullHead 1) (begin
            ; calculate intersection of connection between the wings end points and arrow tail
            ; shrink distance between this point and arrow head if MiddlePoint < 100
            (set! theMiddleWingEndPointX (+ inPointToX
                                            (* (/ MiddlePoint 100) (- (/ (+ theLeftWingEndPointX theRightWingEndPointX) 2) inPointToX))
                                         ))
            (set! theMiddleWingEndPointY (+ inPointToY
                                            (* (/ MiddlePoint 100) (- (/ (+ theLeftWingEndPointY theRightWingEndPointY) 2) inPointToY))
                                         ))

            ; collect points for left wing end - intersection - right wing end & draw it
            (set! points (cons-array 6 'double))
            (aset points 0 theLeftWingEndPointX)      (aset points 1 theLeftWingEndPointY)
            (aset points 2 theMiddleWingEndPointX)    (aset points 3 theMiddleWingEndPointY)
            (aset points 4 theRightWingEndPointX)     (aset points 5 theRightWingEndPointY)
            (gimp-paintbrush-default drawable 6 points)

            ; collect points to create selection which will be filled with FG color
            (set! points (cons-array 8 'double))
            (aset points 0 inPointToX)                (aset points 1 inPointToY)
            (aset points 2 theLeftWingEndPointX)      (aset points 3 theLeftWingEndPointY)
            (aset points 4 theMiddleWingEndPointX)    (aset points 5 theMiddleWingEndPointY)
            (aset points 6 theRightWingEndPointX) (aset points 7 theRightWingEndPointY)
            (gimp-image-select-polygon image CHANNEL-OP-REPLACE 8 points)
            (gimp-drawable-edit-fill drawable FILL-FOREGROUND)
            (gimp-selection-none image)
        ))
		(gimp-context-set-paint-mode PreviousPaintMode)
		(gimp-context-set-opacity PreviousOpacity)
        ) ; begin
    ) ; let
) ; define

;-----------------------------------------------------------------------------------------
;
; Draw an arrow with curved wings
;
; On entry:
;		P0x..P3y = the x,y coordinates of P0, P1, P2 and P3 for the Bézier curve
;		t = the value of t at the back of the arrow
;		half_wing_width = half the width of the back of the arrow (maximum wing width)
;		drawable = the drawable
;		image = the image
;		full_head = 1 if the arrow head is to be filled, 0 otherwise
;		middle_point = the percentage of the arrow length that is to be filled (iff full_head == 1)
;				(75% fills more of the head than 25%)
;		num_points = the number of points to use to construct the wings (3..99) (excludes the tip of the arrow)
;		P0_end = 1 if the arrow is to be drawn at the P0 end of the path, = 0 for the P3 end
;
(define
    (Draw_Curved_Wing_Arrow
        P0x P0y P1x P1y P2x P2y P3x P3y
		t
        half_wing_width
        drawable
        image
        full_head
        middle_point
		num_points
		P0_end
		arrow_length
    )
    (let*
        (
        (points1		(cons-array 200 'double))			; points for one wing ...
        (points2		(cons-array 200 'double))			; ... and the other
        (notch_points	(cons-array 6 'double))
		(in_fill_points (cons-array 406 'double))			; used when filling the head of the arrow
		(PreviousOpacity 100.0)
		(PreviousPaintMode 0)
		(count 1)
		(t_adjustment 0.0)
		(t_middle_point 0.0)
		(bezier_results '(0.0 0.0))
		(arrow_width 0.0)
		(x 0.0)												; poisiton on the path
		(y 0.0)												; poisiton on the path
		(x_deriv 0.0)										; derivative wrt t of x
		(y_deriv 0.0)										; derivative wrt t of y
		(hypot 0.0)											; sqrt( x_deriv^2 + y_deriv^2)
		(x_modifier 0.0)
		(y_modifier 0.0)
		(points_index 0)
		(x_diff 0.0)
		(y_diff 0.0)
        )

		(if (= P0_end 1)
			(begin
				(set! t_adjustment (/ t num_points))
				(set! t_middle_point (* t middle_point))
				(set! t_middle_point (/ t_middle_point 100.0))
				(set! t 0.0)								; start at P0
				(aset points1 0 P0x)						; set first point on one side of the arrowhead ...
				(aset points1 1 P0y)
				(aset points2 0 P0x)						; ... and the other
				(aset points2 1 P0y)
			)
			(begin
				(set! t_middle_point (- 1.0 t))
				(set! t_adjustment (/ t_middle_point num_points))
				(set! t_adjustment (- 0.0 t_adjustment))
				(set! t_middle_point (* t_middle_point middle_point))
				(set! t_middle_point (/ t_middle_point 100.0))
				(set! t_middle_point (- 1.0 t_middle_point))
				(set! t 1.0)								; start at P3
				(aset points1 0 P3x)						; set first point on one side of the arrowhead ...
				(aset points1 1 P3y)
				(aset points2 0 P3x)						; ... and the other
				(aset points2 1 P3y)
			)
		)	; end - if

		; set the middle part of notch points based on t_middle_point in case the head has to be filled

		(aset notch_points 2 (car (Bezier_Coords P0x P1x P2x P3x t_middle_point)))
		(aset notch_points 3 (car (Bezier_Coords P0y P1y P2y P3y t_middle_point)))


 		(set! PreviousOpacity (car (gimp-context-get-opacity)))
		(gimp-context-set-opacity 100.0)
		(set! PreviousPaintMode (car (gimp-context-get-paint-mode)))
        (gimp-context-set-paint-mode LAYER-MODE-NORMAL)

		(set! count 1)
		(set! points_index 2)
		(while (<= count num_points)
			(set! t (+ t t_adjustment))
			(set! bezier_results (Bezier_Coords P0x P1x P2x P3x t))
			(set! x (car bezier_results))
			(set! x_deriv (cadr bezier_results))
			(set! bezier_results (Bezier_Coords P0y P1y P2y P3y t))
			(set! y (car bezier_results))
			(set! y_deriv (cadr bezier_results))

											; calculate the width of the arrow based on the direct distance of
											; x and y from the tip of the arrow (calculating the width with equal
											; steps for each step in t gives a rounded tip to the arrow)
			(set! x_diff (- (aref points1 0) x))
			(set! y_diff (- (aref points1 1) y))
			(set! hypot (sqrt (+ (* x_diff x_diff) (* y_diff y_diff))))
			(set! arrow_width (/ (* hypot half_wing_width) arrow_length))

			(set! hypot (sqrt (+ (* x_deriv x_deriv) (* y_deriv y_deriv))))

			(if (> hypot 0.0)
				(begin
					(set! x_modifier (/ (* y_deriv arrow_width) hypot))
					(set! y_modifier (/ (* x_deriv arrow_width) hypot))
					(aset points1 points_index (+ x x_modifier))
					(aset points2 points_index (- x x_modifier))
					(set! points_index (+ points_index 1))
					(aset points1 points_index (- y y_modifier))
					(aset points2 points_index (+ y y_modifier))
					(set! points_index (+ points_index 1))
				)
				(begin								; avoid division by 0
					(aset points1 points_index x)
					(aset points2 points_index x)
					(set! points_index (+ points_index 1))
					(aset points1 points_index y)
					(aset points2 points_index y)
					(set! points_index (+ points_index 1))
				)
			)	; end - if
 			(set! count (+ count 1))
		)	; end - while

        ; draw the one wing
        (gimp-paintbrush-default drawable points_index points1)


        ; draw the other wing
        (gimp-paintbrush-default drawable points_index points2)

        ; only if head is to be filled
		(if (= full_head 1)
			(begin
				(set! points_index (- points_index 1))
				(aset notch_points 1 (aref points1 points_index))	; y coord
				(aset notch_points 5 (aref points2 points_index))	; y coord
				(set! points_index (- points_index 1))
				(aset notch_points 0 (aref points1 points_index))	; x coord
				(aset notch_points 4 (aref points2 points_index))	; x coord
				(gimp-paintbrush-default drawable 6 notch_points)

				(set! points_index 0)
				(set! x 0)
				(set! num_points (* num_points 2))
				(while (< points_index num_points)
					(aset in_fill_points x (aref points1 points_index))
					(set! x (+ x 1))
					(set! points_index (+ points_index 1))
				)	; end - while

				(set! y 0)
				(while (< y 6)
					(aset in_fill_points x (aref notch_points y))
					(set! y (+ y 1))
					(set! x (+ x 1))
				)	; end - while

				(while (> points_index 0)
					(set! points_index (- points_index 1))
					(set! y (aref points2 points_index))
					(set! points_index (- points_index 1))
					(aset in_fill_points x (aref points2 points_index))
					(set! x (+ x 1))
					(aset in_fill_points x y)
					(set! x (+ x 1))
				)	; end - while

				(set! num_points (* num_points 2))
				(set! num_points (+ num_points 6))
                (gimp-image-select-polygon image CHANNEL-OP-REPLACE num_points in_fill_points)
				(gimp-drawable-edit-fill drawable FILL-FOREGROUND)
				(gimp-selection-none image)
			)	; end -begin
		)	; end - if
		(gimp-context-set-paint-mode PreviousPaintMode)
		(gimp-context-set-opacity PreviousOpacity)
    ) ; let
) ; end - define Draw_Curved_Wing_Arrow()

;---------------------------------------------------------------------------------
;
; Return the x or y coordinate for a given value of t (0..1).
; Also return the first derivative for x or y at that point
;
; The equation for the Bézier curve is:
;
;	B(t) = (1 - t)^3*P0 + 3(1 - t)^2*t*P1 + 3(1-t)*t^2*P2 + t^3*P3
;
; This can be rewritten as:
;
;   t^3(P3 - 3P2 + 3P1 - P0) +
;   t^2(3P2 - 6P1 + 3P0) +
;	t(3P1 - 3P0) +
;	P0
;
; the first derivative is then:
;
;   3t^2(P3 - 3P2 + 3P1 - P0) +
;   2t(3P2 - 6P1 + 3P0) +
;	(3P1 - 3P0) +
;
; The x or y coordinate of the point is returned as the first item of a list and the
; first derivative of the point as the second item.
;

(define (Bezier_Coords P0 P1 P2 P3 t)
	(let* (
		(result 0.0)
		(derivative 0.0)						; first derivative
		(term1 0.0)								; P3 - 3P2 + 3P1 - P0
		(term2 0.0)								; P2 - 2P1 + P0
		(term3 0.0)								; P1 - P0
		(t_cubed 0.0)							; t^3
		(t_squared 0.0)							; t^2
		)
	(set! t_squared (* t t))
	(set! t_cubed (* t_squared t))
	(set! term1 (- P1 P2))
	(set! term1 (* term1 3))
	(set! term1 (+ term1 P3))
	(set! term1 (- term1 P0))

	(set! term2 (* P2 3))
	(set! term2 (- term2 (* P1 6)))
	(set! term2 (+ term2 (* P0 3)))

	(set! term3 (- P1 P0))
	(set! term3 (* term3 3))

	(set! result (* t_cubed term1))
	(set! result (+ result (* t_squared term2)))
	(set! result (+ result (* t term3)))
	(set! result (+ result P0))

	(set! derivative (* t_squared (* term1 3)))
	(set! derivative (+ derivative (* t (* term2 2))))
	(set! derivative (+ derivative term3))

	(list
		result
		derivative
	)
	)	; end - let
)	; define Bezier_Coords

;---------------------------------------------------------------------------------

(define
    (script-fu-draw-arrowV3
        image
		drawable
        WingLengthFactor
        WingLengthType
        WingAngle
        FullHead
        MiddlePoint
        BrushThicknessFactor
        BrushThicknessType
        useFirstPointArrowAsHead
        usePathThenRemove
        useNewLayer
        useDoubleHeadArrow
		CurvedArrowhead
		CurvedArrowheadPoints
    )
    (let*
        (
        (theActiveVector 0)
        (theNumVectors  (car (gimp-image-get-selected-path image)))
        (theFirstStroke  0)          (theStrokePoints 0)
        (theNumPoints    0)
        (inPoint_1X      0)          (inPoint_1Y      0)	; point 1 is for the arrow at the start of the path
															;  - the centre of the arrow lies along the section of the
															;  that joins the first two points (may be the only 2 points)
        (inPoint_2X      0)          (inPoint_2Y      0)    ; point2 is for the arrow at the end of the path
 															;  - the centre of the arrow lies along the section of the
															;  that joins the last two points (may be the only 2 points)
        (x_offset        0)                                 ; x offset of the layer in pixels
        (y_offset        0)                                 ; y offset of the layer in pixels
        (i               0)

		(Bezier_x		 0.0)
		(Bezier_y		 0.0)
		(arrow_depth 0.0)
		(t 0.0)
		(new_length 0.0)
		(i 0.0)
		(adjustment 0.0)
		(x_diff 0.0)
		(y_diff 0.0)
		(half_arrowhead_width 0.0)

        (theArrowLength 0)            (theWingLength 0)
        (oldLayer drawable)                             ; this script will work with just one selected layer which is used
                                                        ; later in the script if the script is not set to use a new layer
                                                        ; for the arrow. We check that the drawable is a layer below.
        (layers_list (cons-array 1 'short))

        (brushName    "2. Hardness 100")
        (version_list (strbreakup (car (gimp-version)) "."))
        )

        (define FACTOR_IN_ABSOLUTE_PIXELS 0)
        (define FACTOR_RELATIVE_TO_PATH_LENGTH 1)

        (set! major_version_no (string->number (car version_list) 10))
        (set! minor_version_no (string->number (cadr version_list) 10))
        (set! release_no (string->number (caddr version_list) 10))

        ;(if (not (or (> major_version_no 2) (and (= minor_version_no 99) (> release_no 12))))
          ;(prog1
            ;(gimp-message "This script requires GIMP V2.99.14 or later to run\nPlease use an earlier verson of the script\nfor GIMP versions up to 2.99.10")
            ;(quit)
         ; )	; end - prog1
        ;)   ; end - if
 
        (if (= (car (gimp-item-id-is-layer drawable)) 0)
          (prog1
            (gimp-message "The drawable must be a layer (not a mask, channel or other\ntype of drawable) for this script to work.")
            (quit)
          )	; end - prog1
        )   ; end - if

        (if (= theNumVectors 0)
          (prog1
            (gimp-message "There must be at least one selected path\nfor this script to work.")
            (quit)
          )	; end - prog1
        )   ; end - if

        (set! theActiveVector (aref (cadr (gimp-image-get-selected-path image)) 0))

        (if (not (= theActiveVector -1)) (begin
            (gimp-image-undo-group-start image)

            (gimp-selection-none image)

            (gimp-context-push)

            ; create new layer if asked to do so
            (if (= useNewLayer 1) (begin
                 (set! drawable (car (gimp-layer-new image (car (gimp-image-get-width     image))
                                                          (car (gimp-image-get-height    image))
                                                          (+ 1 (* 2 (car (gimp-image-get-base-type image))))
                                                          "Arrow" 100 LAYER-MODE-NORMAL )))
                (gimp-image-insert-layer image drawable 0 -1)
                 ; set new layer completely transparent
                (gimp-layer-add-mask drawable (car (gimp-layer-create-mask drawable ADD-MASK-BLACK)))
                (gimp-layer-remove-mask drawable MASK-APPLY)
            ))

            (set! x_offset (car (gimp-drawable-get-offsets drawable)))
            (set! y_offset (cadr (gimp-drawable-get-offsets drawable)))

			(if (> theNumVectors 1)
				(gimp-message "There is more than one path defined -\nthe first active path defines the arrow")
			)	; end - if

            ; get path/vector points
(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
		(begin
            (set! theFirstStroke  (aref  (cadr (gimp-vectors-get-strokes theActiveVector)) 0))
            (set! theStrokePoints (caddr (gimp-vectors-stroke-get-points theActiveVector theFirstStroke)))
            (set! theNumPoints    (cadr  (gimp-vectors-stroke-get-points theActiveVector theFirstStroke))))
(begin
            (set! theFirstStroke  (aref  (cadr (gimp-path-get-strokes theActiveVector)) 0))
            (set! theStrokePoints (caddr (gimp-path-stroke-get-points theActiveVector theFirstStroke)))
            (set! theNumPoints    (cadr  (gimp-path-stroke-get-points theActiveVector theFirstStroke))))
)

			(if (< theNumPoints 12)
				(begin
					(gimp-image-undo-group-end image)
					(error '(This script needs a path with at least two points) (/ theNumPoints 6))
				)	; end - begin
			)	; end - if

			(if (and (> theNumPoints 12) (= 0 multi_points_reported))
                (begin
                    (gimp-message "This script needs a path with at least two points\nto position the arrow head and tail.\n\nThe path has more than two points\nThe first and second points are used")
                    (set! multi_points_reported 1)     ; only report this once per activation of GIMP
                 ) ; end - begin
			)	; end - if

            ; apply the offset of the layer (may be 0,0) to the points
;            (set! i 0)
            (set! i 200) ; diag code - don't seem to need to apply the offset in V2.99 ??!
            (while (< i (- theNumPoints 3))
                (aset theStrokePoints i (- (aref theStrokePoints i) x_offset))
                (set! i (+ i 1))
                (aset theStrokePoints i (- (aref theStrokePoints i) y_offset))
                (set! i (+ i 1))
            )   ; end - while

            ; get position of arrow head and arrow tail from active vector
            (set! inPoint_1X    (aref theStrokePoints 2))	                    ; for the arrow at the start of the path
            (set! inPoint_1Y    (aref theStrokePoints 3))
            (set! inPoint_2X    (aref theStrokePoints (- theNumPoints 4)))		; for the arrow at the end of the path
            (set! inPoint_2Y    (aref theStrokePoints (- theNumPoints 3)))

            ; calculate length of arrows depending on the length of the whole arrow
		(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
			(set! theArrowLength	(car (gimp-vectors-stroke-get-length theActiveVector 1 3.0)))
			(set! theArrowLength	(car (gimp-path-stroke-get-length theActiveVector 1 3.0))))
            (if (= WingLengthType FACTOR_RELATIVE_TO_PATH_LENGTH)
            	(set! theWingLength (/ theArrowLength WingLengthFactor))
            	(set! theWingLength WingLengthFactor)
            )

            ; define new brush for drawing operation
            ;(gimp-brush-new brushName)
            ;(gimp-brush-set-shape brushName BRUSH-GENERATED-CIRCLE)
            ;(gimp-brush-set-spikes brushName 2)
            ;(gimp-brush-set-hardness brushName 1.00)
            ;(gimp-brush-set-aspect-ratio brushName 1.0)
            ;(gimp-brush-set-angle brushName 0.0)
            ;(gimp-brush-set-spacing brushName 1.0)
	    (gimp-context-set-brush-size 11)
	    (gimp-context-set-brush-spacing 0.1)

; Setting the radius of the brush at this time seems to have no effect in GIMP 2.8.14 - it
;       uses the radius of the brush as specified in the toolbox. As a work-around the mod saves the radius of the
;       toolbox brush, sets the new brush to be the default brush and then sets the radius of the toolbox brush. The
;       toolbox brush radius is then restored afterwards
;

           
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
		 (gimp-context-set-brush brushName)
		 (gimp-context-set-brush (car(gimp-brush-get-by-name brushName)))	)

            ; set radius of brush according to length of arrow or to a set value
            (if (= BrushThicknessType FACTOR_RELATIVE_TO_PATH_LENGTH)
                (gimp-context-set-brush-size (/ theArrowLength BrushThicknessFactor))
                (gimp-context-set-brush-size BrushThicknessFactor)
            )

			(set! arrow_depth (* theWingLength (cos (* (/ WingAngle 180) pi))))	; the depth of the arrowhead

			(set! half_arrowhead_width (sqrt (- (* theWingLength theWingLength) (* arrow_depth arrow_depth))))

			; now find the line that is the arrowhead depth with one end at the first end of the path and the other
			; on the path

			(set! i 0.0)
			(set! t 0.5)
			(set! adjustment 0.25)
			(while (< i 16.0)
				(set! Bezier_x (car (Bezier_Coords (aref theStrokePoints 2)
										  (aref theStrokePoints 4)
										  (aref theStrokePoints 6)
										  (aref theStrokePoints 8)
										  t)))

				(set! Bezier_y (car (Bezier_Coords (aref theStrokePoints 3)
										  (aref theStrokePoints 5)
										  (aref theStrokePoints 7)
										  (aref theStrokePoints 9)
										  t)))
				(set! x_diff (- (aref theStrokePoints 2) Bezier_x))
				(set! y_diff (- (aref theStrokePoints 3) Bezier_y))
				(set! new_length (sqrt (+ (* x_diff x_diff) (* y_diff y_diff))))
				(if (< new_length arrow_depth)
					(set! t (+ t adjustment))
					(set! t (- t adjustment))
				)
				(set! adjustment (/ adjustment 2))
				(set! i (+ i 1.0))
			)	; end - while

			(if (or (= useFirstPointArrowAsHead 1) (= useDoubleHeadArrow 1))
				(if (= CurvedArrowhead 1)
					(begin
						(Draw_Curved_Wing_Arrow (aref theStrokePoints 2)
												(aref theStrokePoints 3)
												(aref theStrokePoints 4)
												(aref theStrokePoints 5)
												(aref theStrokePoints 6)
												(aref theStrokePoints 7)
												(aref theStrokePoints 8)
												(aref theStrokePoints 9)
												t
												half_arrowhead_width
												drawable image
												FullHead
												MiddlePoint
												CurvedArrowheadPoints
												1
												arrow_depth)
					)	; end - begin
					(begin
                		(script-fu-help-1Arrow inPoint_1X inPoint_1Y Bezier_x Bezier_y theWingLength (* (/ WingAngle 180) pi) drawable image FullHead MiddlePoint)
					)	; end - begin
				) ; end - if
			) ; end - if

			; now find the line that is the arrowhead depth with one end at the second end of the path and the other
			; on the path

			(set! i 0.0)
			(set! t 0.5)
			(set! adjustment 0.25)
			(while (< i 16.0)
				(set! Bezier_x (car (Bezier_Coords (aref theStrokePoints (- theNumPoints 10))
										  (aref theStrokePoints (- theNumPoints 8))
										  (aref theStrokePoints (- theNumPoints 6))
										  (aref theStrokePoints (- theNumPoints 4))
										  t)))

				(set! Bezier_y (car (Bezier_Coords (aref theStrokePoints (- theNumPoints 9))
										  (aref theStrokePoints (- theNumPoints 7))
										  (aref theStrokePoints (- theNumPoints 5))
										  (aref theStrokePoints (- theNumPoints 3))
										  t)))
				(set! x_diff (- (aref theStrokePoints (- theNumPoints 4)) Bezier_x))
				(set! y_diff (- (aref theStrokePoints (- theNumPoints 3)) Bezier_y))
				(set! new_length (sqrt (+ (* x_diff x_diff) (* y_diff y_diff))))
				(if (< new_length arrow_depth)
					(set! t (- t adjustment))
					(set! t (+ t adjustment))
				)
				(set! adjustment (/ adjustment 2))
				(set! i (+ i 1.0))
			)	; end - while


            (if (or (= useFirstPointArrowAsHead 0) (= useDoubleHeadArrow 1))
				(if (= CurvedArrowhead 1)
					(begin
						(Draw_Curved_Wing_Arrow (aref theStrokePoints (- theNumPoints 10))
												(aref theStrokePoints (- theNumPoints 9))
												(aref theStrokePoints (- theNumPoints 8))
												(aref theStrokePoints (- theNumPoints 7))
												(aref theStrokePoints (- theNumPoints 6))
												(aref theStrokePoints (- theNumPoints 5))
												(aref theStrokePoints (- theNumPoints 4))
												(aref theStrokePoints (- theNumPoints 3))
												t
												half_arrowhead_width
												drawable image
												FullHead
												MiddlePoint
												CurvedArrowheadPoints
												0
												arrow_depth)
					)	; end - begin
					(begin
                		(script-fu-help-1Arrow inPoint_2X inPoint_2Y Bezier_x Bezier_y theWingLength (* (/ WingAngle 180) pi) drawable image FullHead MiddlePoint)
					) ; end - begin
				) ; end - if
			) ; end - if

			(gimp-drawable-edit-stroke-item drawable theActiveVector)		; draw the shaft of the arrow along the path

         ;   (gimp-brush-delete brushName)
	 

            (gimp-context-pop)
		(if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
            (if (= usePathThenRemove 1) (gimp-image-remove-vectors image theActiveVector))
            (if (= usePathThenRemove 1) (gimp-image-remove-path image theActiveVector)))

            (if (= useNewLayer 1) (begin
                (plug-in-autocrop-layer TRUE image drawable)
                ;(aset layers_list 0 oldLayer)
                ;(gimp-image-set-selected-layers image 1 layers_list)
		 (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10)
		(gimp-image-set-active-layer image oldLayer)
		(gimp-image-set-selected-layers image 1 (vector oldLayer))	
)
                
            ))
            (gimp-displays-flush)
            (gimp-image-undo-group-end image)
        )	; end - begin
		(gimp-message "This script needs a path with at least two points\nto position the arrow head and tail (first and second points of the path are used)")
	  )	; end - if
    ) ; let*
); define

; Register the function with GIMP:

(script-fu-register
    "script-fu-draw-arrowV3"
    "ArrowV3"
    "Draw a nearly arbitrary arrow in your image" 
    "Berengar W. Lehr <B-Ranger@web.de>"
    "2009, Berengar W. Lehr / MPG@IDIR, UH Jena, Germany."
    "19th November 2009"
    "*"
    SF-IMAGE       "The image"   0
    SF-DRAWABLE    "The drawable"   0
;SF-ONE-DRAWABLE
    SF-ADJUSTMENT  "Length of wings (LoW)" '(20.0 1 500 1 10 1 1)
    SF-OPTION      "Length of wings type"            (list "LoW Pixels" "Path length divided by LoW value")
    SF-ADJUSTMENT  "Angle between arrow and wing in degrees" '(25 5 85 5 15 0 1)
    SF-TOGGLE      "Fill head of arrow?" TRUE
    SF-ADJUSTMENT  "Percentage size of notch of arrow head\n(only valid if head of arrow is filled)" '(75 0 100 1 10 0 1)
    SF-ADJUSTMENT  "Brush thickness (BT)" '(6 1 500 1 10 0 1)
    SF-OPTION      "Brush thickness type"            (list "BT Pixels" "Path length divided by BT value")
    SF-TOGGLE      "Use first path point as arrow head?\n(if not the last path point of is used as arrow head)" TRUE
    SF-TOGGLE      "Delete path after arrow is drawn?" TRUE
    SF-TOGGLE      "Use new layer for arrow?" TRUE
    SF-TOGGLE      "Draw double headed arrow?" FALSE
    SF-TOGGLE      "Curved arrow wings? (only for curved paths)" FALSE
    SF-ADJUSTMENT  "Points for curved arrow wing (2 to 99)" '(20 2 99 1 10 0 1)
    )
(script-fu-menu-register "script-fu-draw-arrowV3" "<Image>/Tools/ArrowV3...")

