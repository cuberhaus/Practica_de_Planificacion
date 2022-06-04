(define (problem agencia_viaje)
	(:domain agencia_viaje)
	(:objects 
		cg1 c1 c2 c3 - ciudad
	    vg1 v1 v2 v3 - vuelo
		h1 h2 h3 - hotel
		dias1 dias2 dias3 dias4 - dias_por_ciudad
	)
	(:init 
		(= (num_ciudades_escogidas) 0)
		(= (min_ciudades_a_recoger) 3)
		(= (min_dias_por_ciudad) 1)
		(= (max_dias_por_ciudad) 4)
		(= (num_dias_recorrido) 0)
		(= (min_dias_recorrido) 10)

		(= (dias_por_ciudad dias1) 1)
		(= (dias_por_ciudad dias2) 2)
		(= (dias_por_ciudad dias3) 3)
		(= (dias_por_ciudad dias4) 4)

		(= (min_precio_plan) 300)
		(= (max_precio_plan) 4000)
		(= (precio_plan) 0)

		(= (interes_actual) 0)
		(= (interes_ciudad c1) 1)
		(= (interes_ciudad c2) 2)
		(= (interes_ciudad c3) 3)
		(= (interes_ciudad cg1) 3) ;; en realidad no se usa ya que se coje el interes de la ciudad 2

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

		(= (precio_hotel h1) 300)
		(= (precio_hotel h2) 150)
		(= (precio_hotel h3) 700)
		(= (precio_vuelo vg1) 0)
		(= (precio_vuelo v1) 100)
		(= (precio_vuelo v2) 150)
		(= (precio_vuelo v3) 150)
	)

	(:goal (and
		(<= (min_precio_plan) (precio_plan))
		(>= (max_precio_plan) (precio_plan))
		(<= (min_ciudades_a_recoger) (num_ciudades_escogidas))
		(<= (min_dias_recorrido) (num_dias_recorrido))
	))

	(:metric minimize 
		(+ (precio_plan) (* (interes_actual) 400))
	)
)