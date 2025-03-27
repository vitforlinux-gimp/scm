;Modernized with ModernizeMatic7 for Gimp 2.10.22 by vitforlinux.wordpress.com - dont remove

; D�but du script-fu sweet_candy_text_gimp_2_8.scm
;
; Acc�s par :   Fichier > Cr�er > Logos > Sweet candy text...
;               File > Create > Logos > Sweet candy text...
;
;
;  adaptation du didacticiel Create sweet candy text! par Coco http://gimpusers.com/tutorials/create-sweet-candy-letters
;
; Ce script-fu utilise le greffon "D�formation interactive ou IWarp" si "Deformation interactive / IWarp (Stripes) " est valid�.
; Pour avoir un bel effet, les d�placements de la souris doivent �tre perpendiculaires aux bandes.
; Les valeurs conseill�es dans l'onglet "param�tres" sont : 
; D�placer = valid�
; Rayon de d�formation = 5 � 100
; Intensit� de d�formation = 0,3
; Bilin�aire = valid�
; Sur�chantillonnage adaptatif = valid� (ou pas)
; Profondeur max = 2
; Seuil = 2
; Dans l'onglet "Animer", aucune option ne doit �tre valid�e.
; 
;
; This script-fu uses the "IWarp" plugin if "Deformation interactive / IWarp (Stripes) " is checked.
; The mouse movement should be perpendicular to the stripes.
; The recommended values in the tab "Settings" are:
; Move = checked
; Deform radius = 5 to 100
; Deform amount = 0.3
; Bilinear = checked
; Adaptive supersample = checked (or no)
; Max depth = 2
; Threshold = 2
; In the tab "Animate" no option should be validated.
;
;
;
;
; Licence GNU/GPL
;
; --------------------------------------------------------------------
; version 1.0 par samj (www.aljacom.com/~gimp) 2010/12/28
; version 2.0 par samj (www.aljacom.com/~gimp) 2010/12/30 pour gimp 2.7.2 (le rendu est diff�rent => voir avec futures versions pour changer brosse "Circle Fuzzy" ou augmenter nettet� sur 1 calque ou param�tre "flou" ou ...)
; version 2.01 par samj (www.aljacom.com/~gimp) 2010/12/30 valeur n�gatives pour d�coupage crop dans version 2.0 => nouveau d�coupage � partir de new_from_visible
; version 2.02 par samj (www.aljacom.com/~gimp) 2011/05/17 pour gimp 2.7.3
; version 2.03 par samj (www.aljacom.com/~gimp) 2012/05/07 pour gimp 2.8.0
; version 299 2021-12 for Gimp 2.10.22 and 2.99.8 by Vitforlinux changed IWarp (removed) with Ripple,  Brush (original removed) and Font (better work), code updated for compatibility with new Gimp Version.
; version 300 2025-1-24 for Gimp 2.10 & 3.0 rc2 + git by Vitforlinux
; --------------------------------------------------------------------
;
;

;

(cond ((not (defined? 'gimp-text-fontname)) (define (gimp-text-fontname fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 PIXELS fn9) (gimp-text-font fn1 fn2 fn3 fn4 fn5 fn6 fn7 fn8 fn9))))
(cond ((not (defined? 'gimp-text-get-extents-fontname)) (define (gimp-text-get-extents-fontname efn1 efn2 PIXELS efn3) (gimp-text-get-extents-font efn1 efn2 efn3))))

(define (gimp-layer-new-ng ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(if (not (defined? 'gimp-drawable-filter-new))
(gimp-layer-new ln1 ln2 ln3 ln4 ln5 ln6 ln7)
(gimp-layer-new ln1 ln5 ln2 ln3 ln4 ln6 ln7)))

  		(define (apply-gauss2 img drawable x y)
       (cond ((not(defined? 'plug-in-gauss))
           (gimp-drawable-merge-new-filter drawable "gegl:gaussian-blur" 0 LAYER-MODE-REPLACE 1.0
                                    "std-dev-x" (* x 0.32) "std-dev-y" (* y 0.32) "filter" "auto"))
       (else
	(plug-in-gauss 1 img drawable x y 0)
)))


(define (
				script-fu-sweet-candy-text300mod
				Couleur_du_fond
				Texte
				Police
				Taille_Police
												 justification
                                 letter-spacing
                                 line-spacing
				Flou
				Inclinaison_Stripes
				Espacement_Stripes
				Couleur_1_Stripes
				Couleur_2_Stripes
				Nettete_Stripes
				IWarp_Stripes
				separation
				couleur_separation
				largeur_separation
				shadow
				couleur_ombre
				x_ombre
				y_ombre

		)



		
	(let*
		(
			; affectation des variables			
			
			; m�moriser les couleurs PP et AP
			(old-fg (car (gimp-context-get-foreground)))
			(old-bg (car (gimp-context-get-background)))
			
			; m�moriser brosse
			(old-brush (car (gimp-context-get-brush)))

			; m�moriser le d�grad� actif
			(old_gradient (car (gimp-context-get-gradient)))

			; caract�ristiques de la surface occup�e par le texte
			(fond_texte (gimp-text-get-extents-fontname Texte Taille_Police 0 Police))


			; largeur de la future image sans Contour
			(width (car fond_texte)) 
			
			; hauteur de la future image sans Contour
			(height (cadr fond_texte)) 
			
			; cr�er une nouvelle image rgb
			(img (car (gimp-image-new (+ width height) (+ width height) 0)))
			
			; d�finir le Contour en pixels
			(contour (/ (+ width height) 20 ))
			
		
			; calques texte
			(calque_texte)
			(copie_texte_desaturate)
			(calque_texte_2)
			(ombre)
			
			; calque stripes
			(stripes)
			
			; calque fond
			(calque_fond)
			
			; largeur rainure en pixels
			(largeur_rainure)
			
			; nombre de rainures
			(nombre_de_rainures)
			
			; index
			(index)
			
			; activer le contour du texte par une brosse
			(Brosse_contour TRUE)
			
			; chemin_texte
			(chemin_texte)
			
			; chemin du texte trac� avec la brosse
			(chemin_texte_trace_avec_brosse)
			
			; chemin_texte_effet
			(chemin_texte_effet)
			
			; calque new from visible
			(new_from_visible)
				  		  (justification (cond ((= justification 0) 2)
						       ((= justification 1) 0)
						       ((= justification 2) 1)
						       ((= justification 3) 3)))
			
		)

	;; Start undo group.
   	(gimp-context-push)
	(gimp-context-set-paint-mode LAYER-MODE-NORMAL-LEGACY )
	;(gimp-layer-set-mode 0)
	(gimp-image-undo-group-start img)		
		

			      (if  (defined? 'gimp-context-enable-dynamics) (gimp-context-enable-dynamics FALSE))
		 (if (not (defined? 'gimp-drawable-filter-new))
(gimp-context-set-dynamics "Pressure Opacity")
(gimp-context-set-dynamics-name "Pressure Opacity"))

		
; calque fond *******************************************************************************		
		
	; cr�er un nouveau calque
	(set! calque_fond (car (gimp-layer-new-ng img (+ width height) (+ width height) 1 "Fond" 100 0)))

	; ajouter le calque
	(gimp-image-insert-layer img calque_fond -1 0)	

	; choisir Couleur_du_fond pp
	(gimp-context-set-foreground Couleur_du_fond)
	
	; remplir de Couleur_du_fond	
	(gimp-drawable-fill calque_fond 0)		
		
	; rendre invisible
	(gimp-item-set-visible calque_fond FALSE)



; calque Texte *******************************************************************************	

	; choisir noir pp
	(gimp-context-set-foreground '(0 0 0))

	; choisir blanc comme ap
	(gimp-context-set-background '(255 255 255))	
	
	; cr�er le calque texte
	;                  (gimp-text-fontname image drawable x y text border antialias size size-type fontname)
	(set! calque_texte (car (gimp-text-fontname img -1 (/ height 2) (/ width 2) Texte 0 TRUE Taille_Police 0 Police)))

      (gimp-text-layer-set-letter-spacing calque_texte letter-spacing)  ; Set Letter Spacing
   (gimp-text-layer-set-justification calque_texte justification) ; Text Justification (Rev Value) 
   (gimp-text-layer-set-line-spacing calque_texte line-spacing)      ; Set Line Spacing
	; activer le contour du texte avec une brosse
	(if 
		(= Brosse_contour TRUE)
			(begin
			
				; cr�er un chemin � partir du texte
				;(set! chemin_texte (car (gimp-vectors-new-from-text-layer img calque_texte)))
				(if (not (defined? 'gimp-drawable-filter-new))   
					(set! chemin_texte (car (gimp-vectors-new-from-text-layer img calque_texte)))
					(set! chemin_texte (car (gimp-path-new-from-text-layer img calque_texte))))
	
				; ajouter le chemin � l'image
				;(gimp-image-insert-vectors img chemin_texte 0 0)
				(if (not (defined? 'gimp-drawable-filter-new))   
					(gimp-image-insert-vectors img chemin_texte 0 0)
					(gimp-image-insert-path img chemin_texte 0 0))
				

				; calque texte aux dimensions de l'image
				(gimp-layer-resize-to-image-size calque_texte)

				
				; opacit� � 100
				(gimp-context-set-opacity 100)
				
				; d�terminer la taille des la brosse Circle Fuzzy en fonction de la Police
				
				;(gimp-context-set-brush "2. Hardness 025") ; 5*5
				         (if (not (defined? 'gimp-drawable-filter-new))   
(gimp-context-set-brush "2. Hardness 025")
(gimp-context-set-brush (car (gimp-brush-get-by-name "2. Hardness 025"))))

				(gimp-context-set-brush-size 4)

				(if (> Taille_Police 90) ; 70
					(begin
						;(gimp-context-set-brush "Circle Fuzzy (05)")
						;(gimp-context-set-brush "2. Hardness 025")
						(gimp-context-set-brush-size 3)
					)
				) ; 7*7
				
				
				(if (> Taille_Police 110) ; 90
					(begin
						;(gimp-context-set-brush "Circle Fuzzy (07)")
						;(gimp-context-set-brush "2. Hardness 025")
						(gimp-context-set-brush-size 7)
					)
				) ;  9*9
				
				
				(if (> Taille_Police 130) ; 110
					(begin
						;(gimp-context-set-brush "Circle Fuzzy (09)")
						;(gimp-context-set-brush "2. Hardness 025")
						(gimp-context-set-brush-size 9)
					)
				) ; 11*11
				
				
				(if (> Taille_Police 150) ; 130 
					(begin
						;(gimp-context-set-brush "Circle Fuzzy (11)")
						;(gimp-context-set-brush "2. Hardness 025")
						(gimp-context-set-brush-size 11)
					)
				) ; 13*13
				
				
				(if (> Taille_Police 170) ; 150
					(begin				
						;(gimp-context-set-brush "Circle Fuzzy (13)")
						;(gimp-context-set-brush "2. Hardness 025")
			
						(gimp-context-set-brush-size 13)
					)
				) ; 15*15
				
				
				(if (> Taille_Police 190) ; 170
					(begin
						;(gimp-context-set-brush "Circle Fuzzy (15)")
						;(gimp-context-set-brush "2. Hardness 025")
						(gimp-context-set-brush-size 15)
					)
				) ; 17*17
				
				
				(if (> Taille_Police 210) ; 190
					(begin
						;(gimp-context-set-brush "Circle Fuzzy (17)")
						;(gimp-context-set-brush "2. Hardness 025")
						(gimp-context-set-brush-size 17)
					)
				) ; 19*19
				
				
				(if (> Taille_Police 230) ; 210 
					(begin
						;(gimp-context-set-brush "Circle Fuzzy (19)")
						;(gimp-context-set-brush "2. Hardness 025")
						(gimp-context-set-brush-size 19)
					)
				) ; 21*21

				; faire contour chemin avec brosse
				(gimp-drawable-edit-stroke-item calque_texte chemin_texte)
				
		)
	)


	; donner un nom au calque
	(gimp-item-set-name calque_texte "Texte et effet")

	; calque texte aux dimensions de l'image
	(gimp-layer-resize-to-image-size calque_texte)

	; obtenir une s�lection � partir du texte trac� avec la brosse
	(gimp-image-select-item img 0 calque_texte)
	
	; s�lection vers chemin
					         (if (not (defined? 'gimp-drawable-filter-new))   
	(set! chemin_texte_trace_avec_brosse (car (plug-in-sel2path 1 img calque_texte)))
	(set! chemin_texte_trace_avec_brosse (car (plug-in-sel2path 1 img (vector calque_texte))))	)

	; ne rien s�lectionner
	(gimp-selection-none img)

; effet****************

	; colorier
	(gimp-drawable-colorize-hsl calque_texte 180 0 70)

	
	; bumpmap
	(cond((not(defined? 'plug-in-bump-map))
	    (let* ((filter (car (gimp-drawable-filter-new calque_texte "gegl:bump-map" ""))))
      (gimp-drawable-filter-configure filter LAYER-MODE-REPLACE 1.0
                                      "azimuth" 250 "elevation" 45 "depth" 50
                                      "offset-x" 0 "offset-y" 0 "waterlevel" 0.0 "ambient" 0
                                      "compensate" TRUE "invert" FALSE "type" "spherical"
                                      "tiled" FALSE)
      (gimp-drawable-filter-set-aux-input filter "aux" calque_texte)
      (gimp-drawable-merge-filter calque_texte filter)
    ))
    (else
	(plug-in-bump-map 
				1 ; run-mode 
				img ; image 
				calque_texte ; drawable 
				calque_texte ; bumpmap 
				250 ; azimuth 
				45 ; elevation 
				50 ; depth 
				0 ; xofs 
				0 ; yofs 
				0 ; waterlevel 
				0 ; ambient 
				1 ; compensate 
				0 ; invert 
				1 ; type
	)))


	; lock canal alpha calque_texte
	(gimp-layer-set-lock-alpha calque_texte TRUE)
	
	; appliquer un flou gaussien
	(apply-gauss2 img calque_texte (* Taille_Police (/ Flou 300)) (* Taille_Police (/ Flou 300)))	
	
	; unlock canal alpha calque_texte
	(gimp-layer-set-lock-alpha calque_texte FALSE)

	; obtenir une s�lection � partir du texte trac� avec la brosse
	(gimp-image-select-item img 0 calque_texte)
	
	; s�lection vers chemin
						         (if (not (defined? 'gimp-drawable-filter-new))   
	(set! chemin_texte_effet (car (plug-in-sel2path 1 img calque_texte)))
	(set! chemin_texte_effet (car (plug-in-sel2path 1 img (vector calque_texte)))))
	
	


; calque copie_texte_desaturate*****************************************************************



	; copier le calque texte , ajouter puis donner un nom
	(set! copie_texte_desaturate (car (gimp-layer-copy calque_texte TRUE)))
	(gimp-image-insert-layer img copie_texte_desaturate -1 0)
	(gimp-item-set-name copie_texte_desaturate "Texte desaturate")

	; appliquer desaturate
	(gimp-drawable-desaturate copie_texte_desaturate 0)
	






; calque Texte 2 *******************************************************************************	

	; choisir noir pp
	(gimp-context-set-foreground '(0 0 0))

	; choisir blanc comme ap
	(gimp-context-set-background '(255 255 255))

	; cr�er un nouveau calque + grand pour pouvoir pivoter en couvrant le texte
	(set! calque_texte_2 (car (gimp-layer-new-ng img (+ width height) (+ width height) 1 "Texte noir" 100 0)))

	; ajouter le calque
	(gimp-image-insert-layer img calque_texte_2 -1 0)
	
	; remplir la s�lection de noir

			(gimp-drawable-edit-fill 
						calque_texte_2 ; drawable 
						0 ; fill-mode 

			)	

	; passer le calque en mode overlay
	(gimp-layer-set-mode calque_texte_2 5)
			
	
	; ne rien s�lectionner
	(gimp-selection-none img)	
	
; calque stripes *****************************************************************************	

	; cr�er un nouveau calque + grand pour pouvoir pivoter en couvrant le texte
	(set! stripes (car (gimp-layer-new-ng img (+ width height) (+ width height) 1 "Stripes" 100 0)))

	; ajouter le calque
	(gimp-image-insert-layer img stripes -1 0)

	; choisir Couleur_1_Stripes pp
	(gimp-context-set-foreground Couleur_1_Stripes)

	; remplir de Couleur_1_Stripes	
	(gimp-drawable-fill stripes 0)	


	; determiner largeur rainure et nombre de rainures
	(set! largeur_rainure  (round (* (/ (car fond_texte) 1000) Espacement_Stripes)))
	; (gimp-message (number->string largeur_rainure))
	(set! nombre_de_rainures (round (/ (+ width height) largeur_rainure)))	
	; (gimp-message (number->string nombre_de_rainures))

	; mettre index � 1
	(set! index 1)
	
	; boucle pour cr�er les rainures
	(while 
		(< index nombre_de_rainures)
		
			; ne rien s�lectionner
			(gimp-selection-none img)
			
			; faire une s�lection rectangulaire
			;(gimp-rect-select 
			;			img ; image 
			;			(* index largeur_rainure) ; x 
			;			0 ; y 
			;			largeur_rainure ; width 
			;			(+ width height) ; height 
			;			0 ; operation 
			;			TRUE ; feather 
			;			Nettete_Stripes ; feather-radius
			;)
			; modifications pour gimp 2.7.3
			;(gimp-context-set-antialias TRUE)
			(gimp-context-set-feather TRUE)
			; (gimp-context-set-feather-radius feather-radius-x feather-radius-y)
			(gimp-context-set-feather-radius Nettete_Stripes Nettete_Stripes)
			(gimp-image-select-rectangle 
						img ; image 
						0 ; operation 
						(* index largeur_rainure) ; x 
						0 ; y 
						largeur_rainure ; width 
						(+ width height) ; height 
			)
						
			
			
			
			; choisir Couleur_2_Stripes pp
			(gimp-context-set-foreground Couleur_2_Stripes)
			
			; remplir la s�lection de Couleur_2_Stripes
			(gimp-drawable-edit-fill 
						stripes ; drawable 
						0 ; fill-mode 
			)

			; voir s'il faut mettre une s�paration de 1 pixel entre les couleurs
			(if 
				(= separation TRUE) ;
					(begin

						; ne rien s�lectionner
						(gimp-selection-none img)
			
						; faire une petite s�lection rectangulaire
						;(gimp-rect-select 
						;			img ; image 
						;			(* (+ 1 index) largeur_rainure) ; x 
						;			0 ; y 
						;			largeur_separation ; width 
						;			(+ width height) ; height 
						;			0 ; operation 
						;			TRUE ; feather 
						;			1 ; feather-radius
						;)
						; modifications pour gimp 2.7.3
						;(gimp-context-set-antialias TRUE)
						(gimp-context-set-feather TRUE)
						; (gimp-context-set-feather-radius feather-radius-x feather-radius-y)
						(gimp-context-set-feather-radius 1 1)
						(gimp-image-select-rectangle 
									img ; image 
									0 ; operation 
									(* (+ 1 index) largeur_rainure) ; x 
									0 ; y 
									largeur_separation ; width 
									(+ width height) ; height 
						)
						
						
					
						; choisir Couleur_2_Stripes pp
						(gimp-context-set-foreground couleur_separation)

						; remplir la s�lection de Couleur_2_Stripes
						(gimp-drawable-edit-fill 
									stripes ; drawable 
									0 ; fill-mode 
			
						)						
					
					)
			)
			
			; ajouter 2 � l'index
			(set! index (+ index 2))
			
			; ne rien s�lectionner
			(gimp-selection-none img)			
		
	)

	; rotation du calque
	(if 
		(= (* Inclinaison_Stripes Inclinaison_Stripes) (* 90 90)) ; v�rifier si angle 90 pour joli rendu
		
			(begin
				(gimp-drawable-transform-rotate-simple 
							stripes ; drawable 
							0 ; rotate-type 
							TRUE ; auto-center 
							(/ (+ width height) 2) ; center-x 
							(/ (+ width height) 2) ; center-y
							1 ; clip-result
				)
			)
			;else
			(begin 	
				(gimp-item-transform-rotate 
							stripes ; drawable 
							( / (* Inclinaison_Stripes (* 2 3.14159265358979323846)) 360); angle 
							TRUE ; auto-center 
							(/ (+ width height) 2) ; center-x 
							(/ (+ width height) 2) ; center-y 
				)
			)
	)


	; d�former les bandes si autoris�
	(if 
		(= IWarp_Stripes TRUE)		
		;	(plug-in-iwarp 0 img stripes)
		    (cond((not(defined? 'plug-in-ripple))
		 		     (gimp-drawable-merge-new-filter stripes "gegl:ripple" 0 LAYER-MODE-REPLACE 1.0
"amplitude" 15 "period" 100 "phi" 1 "angle" 0 "sampler-type" "cubic" "wave-type" "sine" "abyss-policy" "none" "tileable" FALSE))		    
	(else
		(plug-in-ripple 1 img stripes 100 15 1 0 1 TRUE FALSE)))
	)
	

	
; effet *******************************************************************************	

	; obtenir une s�lection � partir du texte
	(gimp-image-select-item img 0 calque_texte)
	
	; s�lection vers chemin
			(if (not (defined? 'gimp-drawable-filter-new))   
	(plug-in-sel2path 1 img calque_texte)
	(plug-in-sel2path 1 img (vector calque_texte)))
	
	; inverser la s�lection
	(gimp-selection-invert img)
	
	; s�lection vers chemin
			(if (not (defined? 'gimp-drawable-filter-new))   
	(plug-in-sel2path 1 img calque_texte)
	(plug-in-sel2path 1 img (vector calque_texte)))


	; supprimer le contenu de la s�lection sur le calque stripes
	(gimp-drawable-edit-clear stripes)

	; mettre en mode Grain merge
	(gimp-layer-set-mode stripes 21)
	
	; ne rien s�lectionner
	(gimp-selection-none img)

;*****************************************************************************************	

	; descendre la calque copie_texte_desaturate
	(gimp-image-lower-item img copie_texte_desaturate)
				
	; appliquer shadow
	(if 
		(= shadow TRUE)		
			(begin
				; copier le calque copie_texte_desaturate , ajouter puis donner un nom
				(set! ombre (car (gimp-layer-copy copie_texte_desaturate TRUE)))
				(gimp-image-insert-layer img ombre -1 4)
				(gimp-item-set-name ombre "Ombre")
		
				; s�lection du texte
				(gimp-image-select-item img 0 ombre)
		
				; choisir couleur_ombre pp
				(gimp-context-set-foreground couleur_ombre)
			
				; remplir la s�lection de gris
				(gimp-drawable-edit-fill 
							ombre ; drawable 
							0 ; fill-mode BUCKET-FILL-FG

				)		

				; ne rien s�lectionner
				(gimp-selection-none img)
				
				; flou
				(apply-gauss2 img ombre (/ Taille_Police 8) (/ Taille_Police 8) )
				
				; d�caler le calque
				(gimp-layer-set-offsets ombre (/ Taille_Police x_ombre) (/ Taille_Police y_ombre))
				
				
			)
	)					

	
	

; calque new_from_visible******************************************************************

	; version 1.02
	; ajuster l'image aux calques
	(gimp-image-resize-to-layers img)

	; ajouter un nouveau calque � partir de visible en haut de la pile
	(set! new_from_visible (car (gimp-layer-new-from-visible img img "Rendu final" )))
	(gimp-image-insert-layer img new_from_visible -1 0)
	
	; d�coupage calque new_from_visible pour d�terminer dimensions image
	(cond ((defined? 'plug-in-autocrop)(plug-in-autocrop 1 img new_from_visible))
	(else (gimp-image-autocrop img new_from_visible)))

	
	

	; d�coupage de l'image
	; version 2.0 ne fonctionne pas (gimp-image-crop img (+ width (* 2 contour)) (+ height (* 2 contour)) (- (/ height 2) contour) (- (/ width 2) contour) )	
	


	
;*****************************************************************************************	
	
	
	
	; restaurer PP et AP
	(gimp-context-set-foreground  old-fg)
	(gimp-context-set-background old-bg)
	
	; restaurer brosse
	(gimp-context-set-brush old-brush)

	; restaurer ancien d�grad�
	(gimp-context-set-gradient old_gradient)
    
	; ne rien s�lectionner
	(gimp-selection-none img)
	
	; afficher l'image
	(gimp-display-new img)

	;; End undo group.
	(gimp-image-undo-group-end img)
	(gimp-context-pop)

	)
		
)

(script-fu-register "script-fu-sweet-candy-text300mod"
	"Sweet candy text 300 mod..."
	"Ecriture bonbon / Sweet candy text "
	"samj"
	"samj"
	"2010-12-28"
	""
	SF-COLOR "Couleur du fond / Background color " '(255 255 255)
	SF-TEXT "Texte / Text " "Sweet Candy"
	SF-FONT "Police / Font " "QTBookmann Bold" ;"URW Bookman Semi-Bold Italic" ; Serif Bold Italic
	SF-ADJUSTMENT "Taille Police / Font Size [pixels] " '(300 12 480 1 10 0 1) 
			                        SF-OPTION     _"Text Justification"    '("Centered" "Left" "Right" "Fill") 
				    SF-ADJUSTMENT _"Letter Spacing"        '(0 -50 50 1 5 0 1)
                    SF-ADJUSTMENT _"Line Spacing"          '(-5 -300 300 1 10 0 1)
	SF-ADJUSTMENT "Flou Texte / Text Blur [%] " '(12 1 20 1 10 0 1) 
	SF-ADJUSTMENT "Inclinaison Bandes / Stripes Angle [degres] " '(30 -180 180 1 10 0 0) 
	SF-ADJUSTMENT "Espacement Bandes / Stripes Spacing [1/1000] " '(20 10 100 1 10 0 0) 
	SF-COLOR "Couleur 1 Bandes / Stripes color 1 " '(255 255 255)
	SF-COLOR "Couleur 2 Bandes / Stripes color 2 " '(255 0 0)
	SF-ADJUSTMENT "Nettete Bandes / Stripes Sharpness " '(1 0 50 1 10 0 0) 
	SF-TOGGLE "Deformation Bandes / Ripple Stripes "    TRUE
	SF-TOGGLE "Separation Bandes / Stripes Borderline "    TRUE
	SF-COLOR "Couleur Separation / Borderline Color " '(0 165 0)
	SF-ADJUSTMENT "Largeur Separation / Width Borderline [pixels] " '(7 1 50 1 10 0 0) 
	SF-TOGGLE "Ombre / Shadow "    FALSE
	SF-COLOR "Couleur Ombre / Shadow color " '(127 127 127)
	SF-ADJUSTMENT "X Decalage Ombre / X Shift Shadow [% Font] " '(-8 -20 20 1 10 0 0) 
	SF-ADJUSTMENT "Y Decalage Ombre / Y Shift Shadow [% Font] " '(8 -20 20 1 10 0 0) 
)
(script-fu-menu-register "script-fu-sweet-candy-text300mod" "<Image>/File/Create/Logos/" )
; FIN du script

