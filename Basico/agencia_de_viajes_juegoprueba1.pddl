(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects
        cg1  c1  c2  c3  c4   - ciudad
        vg1  v1  v2  v3  v4   - vuelo
        h1  h2  h3  h4  - hotel
    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger) 4 )
        (current_ciudad cg1)
        (ciudad_visitada cg1)
        (va_a vg1 cg1 c1)
        (va_a vg1 cg1 c2)
        (va_a vg1 cg1 c3)
        (va_a vg1 cg1 c4)
        (va_a v1 c2 c1 )
        (va_a v2 c1 c3 )
        (va_a v3 c3 c4 )
        (va_a v4 c4 c2 )
        (esta_en h1 c4 )
        (esta_en h2 c2 )
        (esta_en h3 c1 )
        (esta_en h4 c3 )
 
    )
        
    (:goal (and
    (<= (min_ciudades_a_recoger) (num_ciudades_escogidas))
    ))
)