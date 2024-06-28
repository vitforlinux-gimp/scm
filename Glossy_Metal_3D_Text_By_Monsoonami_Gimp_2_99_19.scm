
; Début du script-fu script-fu-Glossy-Metal-3D-Text-By-Monsoonami-29919_Gimp_2_8.scm
;
; Accès par :   Fichier > Créer > Logos > Glossy Metal 3D Text By Monsoonami
;               File > Create > Logos > Glossy Metal 3D Text By Monsoonami
;
;                __________________________________________________________
; 
;
; script-fu adapté du didacticiel vidéo : http://www.youtube.com/watch?v=C7t5hsbtwrM
;								motif : http://monsoonami.deviantart.com/art/offset-tiles-pattern-for-gimp-159543647				   
; Merci à Monsoonami, l'auteur.
;
;
;
; Licence GNU/GPL
;
; --------------------------------------------------------------------
; édité avec Notepad++    http://notepad-plus-plus.org/
;
; version 1.0 par samj (  http://www.aljacom.com/~gimp       http://samjcreations.blogspot.com  ) 16 juin 2012
;
; updated for gimp 2.10.22 by vitforlinux
;
; --------------------------------------------------------------------
;
; FONT: https://fontsfree.net/walkway-bold-font-download.html


(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))
(cond ((not (defined? 'gimp-text-get-extents-fontname)) (define (gimp-text-get-extents-fontname efn1 efn2 PIXELS efn3) (gimp-text-get-extents-font efn1 efn2 efn3))))








(define (
				script-fu-Glossy-Metal-3D-Text-By-Monsoonami-29919
				Couleur_fond
				Texte
				Police
				Couleur_encre
				Taille_Police
				Grosseur_du_fond_du_texte
				Couleur_du_fond_du_texte
				Couleur_AP_degrade_fond_du_texte
				Couleur_degrade_limites_texte
				decalage_flou
				Degrade_haut_du_texte_inverse
				flatten

		)
		
	(let*
		(
			; affectation des variables		
	
			; mémoriser les couleurs PP et AP
			(old-fg (car (gimp-context-get-foreground)))
			(old-bg (car (gimp-context-get-background)))
			
			; mémoriser brosse
			(old-brush (car (gimp-context-get-brush)))			
			
			; caractéristiques de la surface occupée par le texte
			(fond_texte (gimp-text-get-extents-fontname Texte Taille_Police 0 Police))
			
			; largeur de la future image
			(width (car fond_texte))
			
			; hauteur de la future image
			(height (cadr fond_texte))
			
			; créer une nouvelle image rgb
			(img (car (gimp-image-new 12 6 0)))
			
			;calque offset_tiles_pattern_by_monsoonami
			(offset_tiles_pattern_by_monsoonami)
			
			;calque_degrade
			(calque_degrade)

			;calque_motif
			(calque_motif)			
			
			; calque Texte
			(calque_texte)

			; calque Texte noir
			(calque_texte_2)
			
			; calque Texte noir
			(calque_texte_2bis)
			
			; calque Texte noir
			(calque_texte_2ter)
			
			; calque Texte dégradé
			(calque_texte_3)
			
			; calque 2 limites du texte
			(limites_texte)
			
			; demi_texte_haut
			(demi_texte_haut)	
		
			
		)

	;; Start undo group.
		(gimp-context-push)
	(gimp-context-set-paint-mode 0)
	(gimp-image-undo-group-start img)	

		

		

	
; calque offset_tiles_pattern_by_monsoonami , créer le motif****************************************************************
	


	; créer calque offset_tiles_pattern_by_monsoonami
	(set! offset_tiles_pattern_by_monsoonami (car (gimp-layer-new img 12 6 1 "offset_tiles_pattern_by_monsoonami" 100 0)))	

	; ajouter le calque calque_motif
	(gimp-image-insert-layer img offset_tiles_pattern_by_monsoonami 0 -1)	
	
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground '(0 0 0))
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background '(255 255 255))

	; remplir de PP	
	(gimp-drawable-fill offset_tiles_pattern_by_monsoonami 0)	

	; modifier couleur de premier plan
	(gimp-context-set-foreground '(255 255 255))	
	
	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		6							; x 
		0							; y 
		6							; width 
		3							; height
	)
	
	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)	

	; ne rien sélectionner
	(gimp-selection-none img)
	
	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		0							; x 
		3							; y 
		6							; width 
		3							; height
	)

	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)


	; ne rien sélectionner
	(gimp-selection-none img)	
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground '(102 102 102))	
	
	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		1							; x 
		0							; y 
		4							; width 
		1							; height
	)

	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)

	; ne rien sélectionner
	(gimp-selection-none img)

	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		7							; x 
		3							; y 
		4							; width 
		1							; height
	)

	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)

	; ne rien sélectionner
	(gimp-selection-none img)	
	
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground '(51 51 51))	
	
	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		1							; x 
		1							; y 
		4							; width 
		1							; height
	)

	
	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)

	; ne rien sélectionner
	(gimp-selection-none img)

	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		7							; x 
		4							; y 
		4							; width 
		1							; height
	)

	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)

	; ne rien sélectionner
	(gimp-selection-none img)	

	; modifier couleur de premier plan
	(gimp-context-set-foreground '(204 204 204))	
	
	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		1							; x 
		4							; y 
		4							; width 
		1							; height
	)

	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)

	; ne rien sélectionner
	(gimp-selection-none img)	
	
	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		7							; x 
		1							; y 
		4							; width 
		1							; height
	)

	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)

	; ne rien sélectionner
	(gimp-selection-none img)
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground '(153 153 153))	
	
	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		1							; x 
		5							; y 
		4							; width 
		1							; height
	)

	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)

	; ne rien sélectionner
	(gimp-selection-none img)	
	
	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		7							; x 
		2							; y 
		4							; width 
		1							; height
	)

	; remplir la sélection de PP	
	(gimp-drawable-edit-fill 
		offset_tiles_pattern_by_monsoonami	; drawable 									; x 
		0									; paint mode
	)

	; ne rien sélectionner
	(gimp-selection-none img)	

	; copier le motif
	(gimp-edit-copy-visible img)
	
	; sauvegarder le motif sous :  samj_pattern_By_Monsoonami (pas utile avec l'astuce de RobA  http://www.gimpchat.com/viewtopic.php?f=8&t=1221&start=40  )
	
			; 		*****************************************************************************************
			; 		*****************************************************************************************
			; 		*****          Extrait du Script-Fu  paste_as_pattern.scm  fourni avec Gimp         *****
			; 		*****  Based on select-to-pattern by Cameron Gregory, http://www.flamingtext.com/   *****
			; 		*****         Auteur Michael Natterer <mitch@gimp.org>  Licence GPL 3 ou +          *****
			; 		*****************************************************************************************
			; 		*****************************************************************************************
			
;				(let* 
;					(
;						(pattern-image (car (gimp-edit-paste-as-new)))
;						(pattern-draw 0)
;						(path 0)
;					)
;
;					(if 
;						(= TRUE (car (gimp-image-is-valid pattern-image)))
;							(begin
;								(set! pattern-draw (car (gimp-image-get-active-drawable pattern-image)))
;								(set! path (string-append gimp-directory "/patterns/" "samj_pattern_By_Monsoonami" (number->string pattern-image) ".pat"))
;								(file-pat-save RUN-NONINTERACTIVE pattern-image pattern-draw path path "samj_pattern_By_Monsoonami")
;								(gimp-image-delete pattern-image)
;								(gimp-patterns-refresh)
;								(gimp-context-set-pattern "samj_pattern_By_Monsoonami")
;							)
;					)
;				)

			; 		*****************************************************************************************
			; 		*****************************************************************************************
			; 		*****     FIN  Extrait du Script-Fu  paste_as_pattern.scm  fourni avec Gimp         *****
			; 		*****************************************************************************************
			; 		*****************************************************************************************	
	
	
	; astuce de RobA  http://www.gimpchat.com/viewtopic.php?f=8&t=1221&start=40 pour que le presse-papiers devienne le motif sans avoir à choisir le nom qui varie selon les langues de Gimp
	;QUI(gimp-context-set-pattern (list-ref (cadr (gimp-patterns-get-list "")) 0)) ; set patten to clipboard (first in list)
	
  (if (= (string->number (substring (car(gimp-version)) 0 3)) 2.10) 
						 (gimp-context-set-pattern (list-ref (cadr (gimp-patterns-get-list "")) 0))
				(gimp-context-set-pattern (car (gimp-pattern-get-by-name (list-ref (car (gimp-patterns-get-list "")) 0))))
				)
	
	; inscrire le nom du motif actif
	;(gimp-message (car (gimp-context-get-pattern)))





; calque_degrade*********************************************************************************
	
	

	; créer calque_degrade
	(set! calque_degrade (car (gimp-layer-new img (round (* width 1.5)) (* height 2) 1 "calque_degrade" 100 0)))	
	
	; ajouter le calque calque_degrade
	(gimp-image-insert-layer img calque_degrade 0 -1)
	
	; mettre l'image aux dimensions du calque calque_degrade
	(gimp-image-resize-to-layers img)

	; modifier couleur de premier plan
	(gimp-context-set-foreground Couleur_fond)
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background '(0 0 0))
;QUI!!
	;(gimp-context-set-gradient-fg-bg-rgb)
	(gimp-drawable-edit-fill 
		calque_degrade						; drawable 									; x 
		0									; paint mode
	)
;(gimp-context-set-gradient-fg-transparent)
(gimp-context-set-gradient-fg-bg-rgb)
(gimp-context-get-gradient-reverse TRUE)
	; appliquer un dégradé sur calque calque_degrade
								(gimp-drawable-edit-gradient-fill 
			calque_degrade
			;BLEND-FG-TRANSPARENT
			;LAYER-MODE-NORMAL-LEGACY
			2 ;GRADIENT-LINEAR
			0 ; 100
			0
			;REPEAT-NONE
			;FALSE
			;FALSE
			1
			0
			0 ;FALSE
		
		    (* width 0.75)
    height 
    0
    0
		)
(gimp-context-set-gradient-fg-bg-rgb)


















	
; calque_motif*********************************************************************************
	
	

	; créer calque_motif
	(set! calque_motif (car (gimp-layer-new img (round (* width 1.5)) (* height 2) 1 "calque_motif" 100 0)))	
	
	; ajouter le calque calque_motif
	(gimp-image-insert-layer img calque_motif 0 -1)

	; modifier couleur de premier plan
	(gimp-context-set-foreground '(0 0 0))
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background '(255 255 255))	

	; créer une sélection rectangulaire
	(gimp-image-select-rectangle
		img							; image 
		0							; operation 
		0							; x 
		0							; y 
		(round (* width 1.5))					; width 
		(* height 2)				; height
	)
		
	; remplir le calque calque_motif avec le motif samj_pattern_By_Monsoonami
	(gimp-drawable-edit-fill 
		calque_motif						; drawable 									; x 
		FILL-PATTERN									; paint mode pattern
	)	

	; ne rien sélectionner
	(gimp-selection-none img)	
	
	; mettre le calque en mode lumière douce
	(gimp-layer-set-mode calque_motif 19)

	; mettre le calque à 60% d'opacité
	(gimp-layer-set-opacity calque_motif 60)
	






	
	
; calque Texte *******************************************************************************		
		
	; mettre pp = couleur de l'encre
	(gimp-context-set-foreground Couleur_encre)
	
	; créer le calque texte
	;                  (gimp-text-fontname image drawable x y text border antialias size size-type fontname)
	(set! calque_texte (car (gimp-text-fontname img -1 (round (* width 0.25)) (round (* height 0.5)) Texte 0 TRUE Taille_Police 0 Police)))
	
	; donner un nom au calque
	(gimp-item-set-name calque_texte "Texte")
	
	; sélectionner le texte
	(gimp-image-select-item img 0 calque_texte)
	
	; sauvegarder cette sélection dans un chemin
	(plug-in-sel2path 1 img calque_texte)
	
	; donner un nom au chemin
	;(gimp-item-set-name (car (gimp-image-get-active-vectors img)) "Texte_1")
(cond ((defined? 'gimp-image-get-selected-vectors) (gimp-item-set-name (aref (cadr (gimp-image-get-selected-vectors img)) 0) "Texte_1"))
(else (gimp-item-set-name (car (gimp-image-get-active-vectors img)) "Texte_1"))
)




; calque_texte_2*********************************************************************************
	
	

	; créer calque_texte_2
	(set! calque_texte_2 (car (gimp-layer-new img (round (* width 1.5)) (* height 2) 1 "calque_texte_2" 100 0)))	
	
	; ajouter le calque calque_texte_2
	(gimp-image-insert-layer img calque_texte_2 0 -1)
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground Couleur_du_fond_du_texte)
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background '(255 255 255))
	
	; grossir la sélection en cours
	(gimp-selection-grow img Grosseur_du_fond_du_texte)
	
	; sauvegarder cette sélection dans un chemin
	(plug-in-sel2path 1 img calque_texte_2)
	
	; donner un nom au chemin
	;(gimp-item-set-name (car (gimp-image-get-active-vectors img)) "Texte_2")
	(cond ((defined? 'gimp-image-get-selected-vectors) (gimp-item-set-name (aref (cadr (gimp-image-get-selected-vectors img)) 0) "Texte_2"))
(else (gimp-item-set-name (car (gimp-image-get-active-vectors img)) "Texte_2"))
)


	; remplir le calque calque_motif avec la couleur de PP
	(gimp-drawable-edit-fill 
		calque_texte_2						; drawable 									; x 
		0									; paint mode
	)



	; déplacer le calque vers le bas
	(gimp-item-transform-translate calque_texte_2 decalage_flou (round (/ Taille_Police 13)))
	

	
	
; calque_texte_2bis*********************************************************************************
	
	

	; créer calque_texte_2bis
	(set! calque_texte_2bis (car (gimp-layer-new img (round (* width 1.5)) (* height 2) 1 "calque_texte_2bis" 100 0)))	
	
	; ajouter le calque calque_texte_2bis
	(gimp-image-insert-layer img calque_texte_2bis 0 -1)
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground Couleur_du_fond_du_texte)
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background '(255 255 255))
	
	; remplir le calque calque_motif avec la couleur de PP
	(gimp-drawable-edit-fill 
		calque_texte_2bis						; drawable 									; x 
		0									; paint mode
	)	
	
	; déplacer le calque vers le bas
	(gimp-item-transform-translate calque_texte_2bis decalage_flou (round (/ Taille_Police 13)))


	
	
; calque_texte_2ter*********************************************************************************
	
	

	; créer calque_texte_2ter
	(set! calque_texte_2ter (car (gimp-layer-new img (round (* width 1.5)) (* height 2) 1 "calque_texte_2ter" 100 0)))	
	
	; ajouter le calque calque_texte_2ter
	(gimp-image-insert-layer img calque_texte_2ter 0 -1)
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground Couleur_du_fond_du_texte)
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background '(255 255 255))

	; remplir le calque calque_motif avec la couleur de PP
	(gimp-drawable-edit-fill 
		calque_texte_2ter						; drawable 									; x 
		0									; paint mode
	)


	
	
	
	
	

; calque_texte_3*********************************************************************************
	
	

	; créer calque_texte_3
	(set! calque_texte_3 (car (gimp-layer-new img (round (* width 1.5)) (* height 2) 1 "calque_texte_3" 100 0)))	
	
	; ajouter le calque calque_texte_3
	(gimp-image-insert-layer img calque_texte_3 0 -1)
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground Couleur_du_fond_du_texte)
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background Couleur_AP_degrade_fond_du_texte)	
	
	; appliquer un dégradé sur calque calque_texte_3
	(gimp-drawable-edit-gradient-fill 
		calque_texte_3 			; drawable
		;0 						; blend-mode
		;0 						; paint-mode
		0 						; gradient-type linéaire
		1 					; opacity
		0 						; offset
		;0 						; repeat
		;FALSE 					; reverse
		;TRUE 					; supersample
		5 						; max-depth
		0.2	 					; threshold
		TRUE 					; dither
		(round (* width 0.5))	; x1 
		(round (* height 1.5))	; y1 
		(round (* width 0.5))	; x2
		(round (* height 0.5))	; y2
	)	
	
	; ne rien sélectionner
	(gimp-selection-none img)
	
	
	; récupérer la première sélection via le chemin
	(gimp-image-select-item 
		img						; image 
		0						; op
		(car (gimp-image-get-vectors-by-name img "Texte_1"))
		;"Texte_1"				; name 
		 
		;TRUE					; antialias 
		;TRUE					; feather 
		;1						; feather-radius-x 
		;1						; feather-radius-y
	)
	
	; grossir la sélection en cours
	(gimp-selection-grow img (round (/ Grosseur_du_fond_du_texte 5)))
	
	; sauvegarder cette sélection dans un chemin
	(plug-in-sel2path 1 img calque_texte_3)

	; donner un nom au chemin
	;(gimp-item-set-name (car (gimp-image-get-active-vectors img)) "Texte_3")
	(cond ((defined? 'gimp-image-get-selected-vectors) (gimp-item-set-name (aref (cadr (gimp-image-get-selected-vectors img)) 0) "Texte_3"))
(else (gimp-item-set-name (car (gimp-image-get-active-vectors img)) "Texte_3"))
)
	
	; remplir le calque calque_motif avec la couleur de PP
	(gimp-drawable-edit-fill 
		calque_texte_3						; drawable 									; x 
		0									; paint mode
	)	

	; ne rien sélectionner
	(gimp-selection-none img)
	
	; sélectionner le texte
	(gimp-image-select-item img 0 calque_texte_3)	
	
	; récupérer la première sélection Texte_3 via le chemin mode différence
	(gimp-image-select-item 
		img						; image 
		1						; op
		(car (gimp-image-get-vectors-by-name img "Texte_3"))
		;"Texte_3"				; name 
		;1						; op 
		;TRUE					; antialias 
		;TRUE					; feather 
		;1						; feather-radius-x 
		;1						; feather-radius-y
	)	
	
	; sauvegarder cette sélection dans un chemin
	(plug-in-sel2path 1 img calque_texte_3)

	; donner un nom au chemin
	;(gimp-item-set-name (car (gimp-image-get-active-vectors img)) "Texte_3_contour")
		(cond ((defined? 'gimp-image-get-selected-vectors) (gimp-item-set-name (aref (cadr (gimp-image-get-selected-vectors img)) 0) "Texte_3_contour"))
(else (gimp-item-set-name (car (gimp-image-get-active-vectors img)) "Texte_3_contour"))
)


	
; calque_limites_texte*********************************************************************************
	
	

	; créer limites_texte
	(set! limites_texte (car (gimp-layer-new img (round (* width 1.5)) (* height 2) 1 "limites_texte" 100 0)))	
	
	; ajouter le calque limites_texte
	(gimp-image-insert-layer img limites_texte 0 -1)
	
	; modifier couleur de premier plan
	(gimp-context-set-foreground '(255 255 255))
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background Couleur_degrade_limites_texte)		
	
	; appliquer un dégradé sur calque calque_texte_3
	(gimp-drawable-edit-gradient-fill 
		limites_texte 			; drawable
		;0 						; blend-mode
		;0 						; paint-mode
		0 						; gradient-type linéaire
		1 					; opacity
		0 						; offset
		;0 						; repeat
		;FALSE 					; reverse
		;TRUE 					; supersample
		5 						; max-depth
		0.2	 					; threshold
		TRUE 					; dither
		(round (* width 0.5))	; x1 
		(round (* height 0.5))	; y1 
		(round (* width 0.5))	; x2
		(round (* height 1.5))	; y2
	)	
	
	; réduire la sélection
	(gimp-selection-shrink img (round (/ Grosseur_du_fond_du_texte 10)))
	
	; effacer
	(gimp-drawable-edit-fill 
		limites_texte						; drawable 									; x 
		0									; paint mode
	)	
	
	; ne rien sélectionner
	(gimp-selection-none img)	
	
	; mettre le calque à 60% d'opacité
	(gimp-layer-set-opacity limites_texte 60)	

	
	
	
	
; calque_texte_2*********************************************************************************	
	
	; appliquer un flou
	(plug-in-gauss 1 img calque_texte_2 (round (/ Taille_Police 10)) (round (/ Taille_Police 10)) 1)	
	
	; déplacer le calque vers le bas
	(gimp-item-transform-translate calque_texte_2 decalage_flou (round (/ Taille_Police 25)))	
	
	; mettre le calque à 80% d'opacité
	(gimp-layer-set-opacity calque_texte_2 80)	
	
	
	
	
	
; calque Texte *******************************************************************************		
		
	; remonter le calque de 4 niveaux
	(gimp-image-raise-item img calque_texte)	
	(gimp-image-raise-item img calque_texte)	
	(gimp-image-raise-item img calque_texte)	
	(gimp-image-raise-item img calque_texte)
	
	; déplacer le calque vers le bas
	(gimp-item-transform-translate calque_texte decalage_flou (round (/ Taille_Police 50)))	
	





	

; demi_texte_haut*********************************************************************************
	
	

	; créer demi_texte_haut
	(set! demi_texte_haut (car (gimp-layer-new img (round (* width 1.5)) (* height 2) 1 "demi_texte_haut" 100 0)))	
	
	; ajouter le calque demi_texte_haut
	(gimp-image-insert-layer img demi_texte_haut 0 -1)

	; modifier couleur de premier plan
	(gimp-context-set-foreground '(255 255 255))
	
	; modifier couleur d'arrière plan
	(gimp-context-set-background '(255 255 255))	
	
	; récupérer la première sélection via le chemin
	(gimp-image-select-item 
		img						; image 
		0						; op
		(car (gimp-image-get-vectors-by-name img "Texte_3_contour"))
		;"Texte_3_contour"		; name 
		;0						; op 
		;TRUE					; antialias 
		;TRUE					; feather 
		;1						; feather-radius-x 
		;1						; feather-radius-y
	)	
	
	; sélection rectangulaire en mode intersection
	(gimp-image-select-rectangle 
		img						; image 
		3						; operation    mode intersection
		0						; x 
		0						; y 
		(round (* width 1.5))	; width 
		height						; height
	)
	
	; sauvegarder cette sélection dans un chemin
	(plug-in-sel2path 1 img demi_texte_haut)

	; donner un nom au chemin
	;(gimp-item-set-name (car (gimp-image-get-active-vectors img)) "demi_texte_haut")
	(cond ((defined? 'gimp-image-get-selected-vectors) (gimp-item-set-name (aref (cadr (gimp-image-get-selected-vectors img)) 0) "demi_texte_haut"))
(else (gimp-item-set-name (car (gimp-image-get-active-vectors img)) "demi_texte_haut"))
)




	; aplatir l'image
	(if
		(= Degrade_haut_du_texte_inverse TRUE)
			; appliquer un dégradé sur calque demi_texte_haut
			(gimp-drawable-edit-gradient-fill 
				demi_texte_haut 		; drawable
				;2 						; blend-mode   PP vers transparent
				;0 						; paint-mode
				0 						; gradient-type 
				1 					; opacity
				0 						; offset
				;0 						; repeat
				;FALSE 					; reverse
				;TRUE 					; supersample
				5 						; max-depth
				0.2	 					; threshold
				TRUE 					; dither
				(round (* width 0.5))	; x1 
				(round (* height 0.5))	; y1 
				(round (* width 0.5))	; x2
				height					; y2
			)
			
			; ELSE
			
			; appliquer un dégradé sur calque demi_texte_haut
			(gimp-drawable-edit-gradient-fill 
				demi_texte_haut 		; drawable
				;2 						; blend-mode   PP vers transparent
				;0 						; paint-mode
				0 						; gradient-type 
				1 					; opacity
				0 						; offset
				;0 						; repeat
				;FALSE 					; reverse
				;TRUE 					; supersample
				5 						; max-depth
				0.2	 					; threshold
				TRUE 					; dither
				(round (* width 0.5))	; x1 
				height					; y1 
				(round (* width 0.5))	; x2
				(round (* height 0.5))	; y2
			)			
	)



	
	

; calque offset_tiles_pattern_by_monsoonami ************************************************

	; enlever la visibilité
	(gimp-item-set-visible offset_tiles_pattern_by_monsoonami FALSE)

	
	
	
;*******************************************************************************************
	
	; aplatir l'image
	(if
		(= flatten TRUE)
			(gimp-image-flatten img)
	)	

	
;*******************************************************************************************
	
	; restaurer PP et AP
	(gimp-context-set-foreground  old-fg)
	(gimp-context-set-background old-bg)
	
	; restaurer brosse
	(gimp-context-set-brush old-brush)

	; ne rien sélectionner
	(gimp-selection-none img)
	
	; afficher l'image
	(gimp-display-new img)

	; End undo group.
		(gimp-context-pop)
	(gimp-image-undo-group-end img)	
	


	)
		
)



(script-fu-register
	"script-fu-Glossy-Metal-3D-Text-By-Monsoonami-29919"
	"Glossy Metal 3D Text By Monsoonami 2.99.19"
	"Logo 3D sur fond avec texture"
	"samj"
	"samj"
	"2010-06-16"
	""
	SF-COLOR "Couleur fond / Background color" '(230 39 19) ; e62712
	SF-STRING "Texte / Text" "Gimp 2.99.19"
	SF-FONT "Police / Font" "Walkyway Bold," ; Serif Bold
	SF-COLOR "Couleur encre / Color ink" '(255 255 255) ; blanc
	SF-ADJUSTMENT "Taille Police / Font Size [pixels]" '(150 48 480 1 10 0 1)
	SF-ADJUSTMENT "Grosseur du fond du texte [pixels]" '(10 10 64 1 4 0 1)
	SF-COLOR "Couleur du fond du texte" '(0 0 0) ; noir
	SF-COLOR "Couleur AP degrade fond du texte" '(128 128 128) ; gris moyen
	SF-COLOR "Couleur degrade limites texte" '(64 64 64) ; gris 
	SF-ADJUSTMENT "Decalage X du flou [pixels]" '(0 -8 8 1 2 0 1)
	SF-TOGGLE "Degrade haut du texte inverse" FALSE	
	SF-TOGGLE "Aplatir / Flatten" FALSE
	
)

(script-fu-menu-register "script-fu-Glossy-Metal-3D-Text-By-Monsoonami-29919"
                         "<Image>/File/Create/Logos")

; FIN du script
