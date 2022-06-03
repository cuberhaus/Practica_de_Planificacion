(define (domain agencia_viaje)
	(:requirements :strips :typing :fluents)
	(:types
		ciudad - ciudad
		hotel - hotel
		vuelo - vuelo
		dias_por_ciudad - dias_por_ciudad
		precio_hotel - precio_hotel
		precio_vuelo - precio_vuelo
		; precio_plan - precio_plan
	)
	(:functions
		(num_ciudades_escogidas)
		(num_dias_recorrido)

		(min_ciudades_a_recoger)
		(min_dias_recorrido)
		(min_dias_por_ciudad)
		(max_dias_por_ciudad)

		(dias_por_ciudad ?x - dias_por_ciudad)

		(min_precio_plan)
		(max_precio_plan)
		(precio_plan)

		(precio_hotel ?h - hotel)
		(precio_vuelo ?v - vuelo)
	)
	(:predicates
		(va_a ?v - vuelo ?c1 - ciudad ?c2 - ciudad)
		(esta_en ?h - hotel ?c - ciudad)
		(ciudad_visitada ?c - ciudad)
		(alojamiento_escogido ?h - hotel)
		(vuelo_escogido ?v - vuelo)
		(current_ciudad ?c - ciudad)
	)

	(:action anadir_ciudad
		:parameters (?c1 - ciudad ?c2 - ciudad ?v - vuelo ?h - hotel ?d - dias_por_ciudad)
		:precondition (and
			(<= (+ (precio_vuelo ?v) (* (precio_hotel ?h) (dias_por_ciudad ?d))) (max_precio_plan) )
			(<= (min_dias_por_ciudad) (dias_por_ciudad ?d))
			(>= (max_dias_por_ciudad) (dias_por_ciudad ?d))
			(not (ciudad_visitada ?c2)) (current_ciudad ?c1) (va_a ?v ?c1 ?c2)
			(esta_en ?h ?c2) (not(alojamiento_escogido ?h)) 
			(not (vuelo_escogido ?v))
			)
		:effect (and
			(ciudad_visitada ?c2) (alojamiento_escogido ?h) (vuelo_escogido ?v)
			(not (current_ciudad ?c1)) (current_ciudad ?c2)
			(increase (num_ciudades_escogidas) 1)
			(increase (num_dias_recorrido) (dias_por_ciudad ?d))
			(increase (precio_plan) (+ (precio_vuelo ?v) (* (precio_hotel ?h) (dias_por_ciudad ?d))) 
			)

			)
	)
	
)