(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects
        cg1  c1  c2  c3  c4  c5   - ciudad
        vg1  v1  v2  v3  v4  v5   - vuelo
        h1  h2  h3  h4  h5  - hotel
        dias2  dias3  dias4  dias5  dias6  - dias_por_ciudad
    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger) 5 )
        (= (min_dias_por_ciudad) 2 )
        (= (max_dias_por_ciudad) 6 )
        (= (num_dias_recorrido) 0)
        (= (min_dias_recorrido) 7 )
        (= (dias_por_ciudad dias2) 2)
        (= (dias_por_ciudad dias3) 3)
        (= (dias_por_ciudad dias4) 4)
        (= (dias_por_ciudad dias5) 5)
        (= (dias_por_ciudad dias6) 6)
        (current_ciudad cg1)
        (ciudad_visitada cg1)
        (va_a vg1 cg1 c1)
        (va_a vg1 cg1 c2)
        (va_a vg1 cg1 c3)
        (va_a vg1 cg1 c4)
        (va_a vg1 cg1 c5)
        (va_a v1 c4 c2 )
        (va_a v2 c2 c3 )
        (va_a v3 c3 c1 )
        (va_a v4 c1 c5 )
        (va_a v5 c5 c4 )
        (esta_en h1 c5 )
        (esta_en h2 c4 )
        (esta_en h3 c2 )
        (esta_en h4 c3 )
        (esta_en h5 c1 )
 
    )
        
    (:goal (and
    (<= (min_ciudades_a_recoger) (num_ciudades_escogidas))
    ))
)