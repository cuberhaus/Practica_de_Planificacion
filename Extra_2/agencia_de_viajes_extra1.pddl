(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects
        cg1  c1  c2  c3   - ciudad
        vg1  v1  v2  v3  v4  v5   - vuelo
        h1  h2  h3  h4  h5  - hotel
        dias1  dias2  - dias_por_ciudad
    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger) 3 )
        (= (min_dias_por_ciudad) 1 )
        (= (max_dias_por_ciudad) 2 )
        (= (num_dias_recorrido) 0)
        (= (min_dias_recorrido) 3 )
        (= (dias_por_ciudad dias1) 1)
        (= (dias_por_ciudad dias2) 2)
        (= (min_precio_plan) 10)
        (= (max_precio_plan) 1000)
        (= (precio_plan) 0)
        (current_ciudad cg1)
        (ciudad_visitada cg1)
        (va_a vg1 cg1 c1)
        (va_a vg1 cg1 c2)
        (va_a vg1 cg1 c3)
        (va_a v1 c3 c1 )
        (va_a v2 c1 c2 )
        (va_a v3 c2 c3 )
        (va_a v4 c3 c1 )
        (va_a v5 c1 c2 )
        (esta_en h1 c2 )
        (esta_en h2 c3 )
        (esta_en h3 c1 )
        (esta_en h4 c2 )
        (esta_en h5 c3 )
        (= (precio_hotel h1) 50)
        (= (precio_hotel h2) 35)
        (= (precio_hotel h3) 245)
        (= (precio_hotel h4) 73)
        (= (precio_hotel h5) 294)
        (= (precio_vuelo v1) 119)
        (= (precio_vuelo v2) 157)
        (= (precio_vuelo v3) 198)
        (= (precio_vuelo v4) 240)
        (= (precio_vuelo v5) 99)
        (= (precio_vuelo vg1) 0)
 
    )
        
    (:goal (and
        (<= (min_precio_plan) (precio_plan))
        (>= (max_precio_plan) (precio_plan))
        (<= (min_ciudades_a_recoger) (num_ciudades_escogidas))
        (<= (min_dias_recorrido) (num_dias_recorrido))
    ))
    ;; maximize negativo minimize negativo o viceversa
    ;; minimize va DESPUES del goal
    (:metric minimize 
        (precio_plan)
    )
)