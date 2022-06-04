(define (problem agencia_viaje)
	(:domain agencia_viaje)
	(:objects 
		cg1 c1 c2 c3 - ciudad
	    vg1 v1 v2 v3 - vuelo
		h1 h2 h3 - hotel
	)
	(:init 
		(= (num_ciudades_escogidas) 0)
		(= (min_ciudades_a_recoger) 3)
		(current_ciudad cg1)
		(ciudad_visitada cg1)
		(va_a vg1 cg1 c1)
		(va_a vg1 cg1 c2)
		(va_a vg1 cg1 c3)
		(va_a v1 c1 c2)
		(va_a v2 c2 c3)
		(va_a v3 c3 c1)
		(esta_en h1 c1)
		(esta_en h2 c2)
		(esta_en h3 c3)
	)

	(:goal (and
		(<= (min_ciudades_a_recoger) (num_ciudades_escogidas))
	))

)
