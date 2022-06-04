(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects
        cg1  c1  c2  c3  c4  c5  c6  c7   - ciudad
        vg1  v1  v2  v3  v4  v5  v6  v7  v8   - vuelo
        h1  h2  h3  h4  h5  h6  h7  h8  h9  - hotel
    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger) 5 )
        (current_ciudad cg1)
        (ciudad_visitada cg1)
        (va_a vg1 cg1 c1)
        (va_a vg1 cg1 c2)
        (va_a vg1 cg1 c3)
        (va_a vg1 cg1 c4)
        (va_a vg1 cg1 c5)
        (va_a vg1 cg1 c6)
        (va_a vg1 cg1 c7)
        (va_a v1 c4 c3 )
        (va_a v2 c3 c2 )
        (va_a v3 c2 c5 )
        (va_a v4 c5 c1 )
        (va_a v5 c1 c7 )
        (va_a v6 c7 c6 )
        (va_a v7 c6 c4 )
        (va_a v8 c4 c3 )
        (esta_en h1 c6 )
        (esta_en h2 c4 )
        (esta_en h3 c3 )
        (esta_en h4 c2 )
        (esta_en h5 c5 )
        (esta_en h6 c1 )
        (esta_en h7 c7 )
        (esta_en h8 c6 )
        (esta_en h9 c4 )
 
    )
        
    (:goal (and
    (<= (min_ciudades_a_recoger) (num_ciudades_escogidas))
    ))
)