(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects
        cg1  c1  c2  c3  c4   - ciudad
        vg1  v1  v2  v3  v4  v5  v6  v7  v8  v9  v10   - vuelo
        h1  h2  h3  h4  h5  h6  h7  h8  h9  h10  - hotel
        dias1  dias2  dias3  - dias_por_ciudad
    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger) 3 )
        (= (min_dias_por_ciudad) 1 )
        (= (max_dias_por_ciudad) 3 )
        (= (num_dias_recorrido) 0)
        (= (min_dias_recorrido) 4 )
        (= (dias_por_ciudad dias1) 1)
        (= (dias_por_ciudad dias2) 2)
        (= (dias_por_ciudad dias3) 3)
         (= (interes_actual) 0)
        (= (interes_ciudad cg1) 3)
        (= (interes_ciudad c1) 4)
        (= (interes_ciudad c2) 0)
        (= (interes_ciudad c3) 0)
        (current_ciudad cg1)
        (= (interes_ciudad cg1) 0)
        (ciudad_visitada cg1)
        (va_a vg1 cg1 c1)
        (va_a vg1 cg1 c2)
        (va_a vg1 cg1 c3)
        (va_a vg1 cg1 c4)
        (va_a v1 c4 c1 )
        (va_a v2 c1 c2 )
        (va_a v3 c2 c3 )
        (va_a v4 c3 c4 )
        (va_a v5 c4 c3 )
        (va_a v6 c3 c2 )
        (va_a v7 c2 c1 )
        (va_a v8 c1 c4 )
        (va_a v9 c4 c3 )
        (va_a v10 c3 c2 )
        (esta_en h1 c1 )
        (esta_en h2 c4 )
        (esta_en h3 c3 )
        (esta_en h4 c2 )
        (esta_en h5 c1 )
        (esta_en h6 c4 )
        (esta_en h7 c3 )
        (esta_en h8 c2 )
        (esta_en h9 c1 )
        (esta_en h10 c4 )
 
    )
        
    (:goal (and
    (<= (min_ciudades_a_recoger) (num_ciudades_escogidas))
    (<= (min_dias_recorrido) (num_dias_recorrido))
    ))
    ;; maximize negativo minimize negativo o viceversa
	;; minimize va DESPUES del goal
	(:metric minimize 
		(interes_actual)
	)
)