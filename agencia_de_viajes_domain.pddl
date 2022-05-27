(define (domain vector_typed)
	(:requirements :strips :typing)
	(:types
		ciudad - ciudad
		hotel - hotel
		vuelo - vuelo
	)

	(:predicates
		(va_a ?x - vuelo ?y - ciudad ?z - ciudad)
		(esta_en ?x - hotel ?y - ciudad)
		(ciudad_visitada ?c - ciudad)
		(alojamiento_escogido ?h - ciudad)
		(current_ciudad ?c - ciudad)
	)

	(:action anadir_ciudad
		:parameters (?c1 - ciudad ?c2 - ciudad ?v - vuelo ?h - hotel)
		:precondition (and
			(not (ciudad_visitada ?c2)) (current_ciudad ?c1) (va_a ?v ?c1 ?c2)
			(esta_en ?h ?c2) (not(alojamiento_escogido ?h)) )
		:effect (and
			(ciudad_visitada ?c2) (vuelo ?v ?c1 ?c2) (alojamiento_escogido ?h)
			)
	)

	; (:action move_adjacent
	; 	:parameters (?v1 - valor ?v2 - valor 
	; 	?p1 - posicio ?p2 - posicio)
	; 	:precondition (and
	; 		(Posicio ?v1 ?p1) (Posicio ?v2 ?p2))
	; 	:effect (and(and (Posicio ?v1 ?p2) (Posicio ?v2 ?p1))
	; 		(and(not (Posicio ?v1 ?p1)) (not (Posicio ?v2 ?p2)))
	; 		)
	; )

)