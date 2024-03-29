(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects
        cg1  c1  c2  c3  c4  c5  c6  c7  c8   - ciudad
        vg1  v1  v2  v3  v4  v5  v6  v7  v8  v9  v10  v11  v12  v13  v14  v15  v16   - vuelo
        h1  h2  h3  h4  h5  h6  h7  h8  h9  h10  - hotel
        dias1  dias2  dias3  - dias_por_ciudad
    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger) 3 )
        (= (min_dias_por_ciudad) 1 )
        (= (max_dias_por_ciudad) 3 )
        (= (num_dias_recorrido) 0)
        (= (min_dias_recorrido) 5 )
        (= (dias_por_ciudad dias1) 1)
        (= (dias_por_ciudad dias2) 2)
        (= (dias_por_ciudad dias3) 3)
         (= (interes_actual) 0)
        (= (interes_ciudad cg1) 3)
        (= (interes_ciudad c1) 7)
        (= (interes_ciudad c2) 4)
        (= (interes_ciudad c3) 3)
        (= (interes_ciudad c4) 4)
        (= (interes_ciudad c5) 1)
        (= (interes_ciudad c6) 0)
        (= (interes_ciudad c7) 1)
        (current_ciudad cg1)
        (= (interes_ciudad cg1) 0)
        (ciudad_visitada cg1)
        (va_a vg1 cg1 c1)
        (va_a vg1 cg1 c2)
        (va_a vg1 cg1 c3)
        (va_a vg1 cg1 c4)
        (va_a vg1 cg1 c5)
        (va_a vg1 cg1 c6)
        (va_a vg1 cg1 c7)
        (va_a vg1 cg1 c8)
        (va_a v1 c2 c8 )
        (va_a v2 c8 c5 )
        (va_a v3 c5 c6 )
        (va_a v4 c6 c3 )
        (va_a v5 c3 c4 )
        (va_a v6 c4 c1 )
        (va_a v7 c1 c7 )
        (va_a v8 c7 c2 )
        (va_a v9 c3 c6 )
        (va_a v10 c6 c4 )
        (va_a v11 c4 c7 )
        (va_a v12 c7 c2 )
        (va_a v13 c2 c5 )
        (va_a v14 c5 c1 )
        (va_a v15 c1 c8 )
        (va_a v16 c8 c3 )
        (esta_en h1 c8 )
        (esta_en h2 c3 )
        (esta_en h3 c6 )
        (esta_en h4 c4 )
        (esta_en h5 c7 )
        (esta_en h6 c2 )
        (esta_en h7 c5 )
        (esta_en h8 c1 )
        (esta_en h9 c8 )
        (esta_en h10 c3 )
 
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