(define (domain vector_typed)
	(:requirements :strips :typing)
	(:types
		valor - valor
		posicio - posicio
	)

	(:predicates
		;   (Value ?x)
		(Posicio ?x - valor ?y - posicio)
	)

	; (:action swap
	; 	:parameters (?v1 - valor ?v2 - valor 
	; 	?p1 - posicio ?p2 - posicio)
	; 	:precondition (and
	; 		(Posicio ?v1 ?p1) (Posicio ?v2 ?p2))
	; 	:effect (and(and (Posicio ?v1 ?p2) (Posicio ?v2 ?p1))
	; 		(and(not (Posicio ?v1 ?p1)) (not (Posicio ?v2 ?p2)))
	; 		)
	; )

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