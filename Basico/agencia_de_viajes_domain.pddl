(define (domain agencia_viaje)
	(:requirements :strips :typing :fluents)
	(:types
		ciudad - ciudad
		hotel - hotel
		vuelo - vuelo
	)
	(:functions
		(num_ciudades_escogidas)
		(min_ciudades_a_recoger)
	)
	(:predicates
		(va_a ?x - vuelo ?y - ciudad ?z - ciudad)
		(esta_en ?x - hotel ?y - ciudad)
		(ciudad_visitada ?c - ciudad)
		(current_ciudad ?c - ciudad)
	)

	(:action anadir_ciudad
		:parameters (?c1 - ciudad ?c2 - ciudad ?v - vuelo ?h - hotel)
		:precondition (and
			(not (ciudad_visitada ?c2)) 
			(current_ciudad ?c1)
			(va_a ?v ?c1 ?c2)
			(esta_en ?h ?c2) 
			)
		:effect (and
			(ciudad_visitada ?c2) 
			(not (current_ciudad ?c1))
			(current_ciudad ?c2)
			(increase (num_ciudades_escogidas) 1)
			)
	)
)