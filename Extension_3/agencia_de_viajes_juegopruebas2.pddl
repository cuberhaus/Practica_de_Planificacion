(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects
        cg1  c1  c2  c3  c4  c5  c6   - ciudad
        vg1  v1  v2  v3  v4  v5  v6  v7  v8  v9  v10  v11  v12  v13  v14  v15  v16  v17  v18  v19  v20   - vuelo
        h1  h2  h3  h4  h5  h6  h7  h8  h9  h10  h11  h12  h13  h14  h15  h16  h17  h18  h19  h20  - hotel
        dias2  dias3  dias4  dias5  - dias_por_ciudad
    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger) 5 )
        (= (min_dias_por_ciudad) 2 )
        (= (max_dias_por_ciudad) 5 )
        (= (num_dias_recorrido) 0)
        (= (min_dias_recorrido) 8 )
        (= (dias_por_ciudad dias2) 2)
        (= (dias_por_ciudad dias3) 3)
        (= (dias_por_ciudad dias4) 4)
        (= (dias_por_ciudad dias5) 5)
        (= (min_precio_plan) 10)
        (= (max_precio_plan) 100)
        (= (precio_plan) 0)
        (current_ciudad cg1)
        (ciudad_visitada cg1)
        (va_a vg1 cg1 c1)
        (va_a vg1 cg1 c2)
        (va_a vg1 cg1 c3)
        (va_a vg1 cg1 c4)
        (va_a vg1 cg1 c5)
        (va_a vg1 cg1 c6)
        (va_a v1 c6 c4 )
        (va_a v2 c4 c5 )
        (va_a v3 c5 c2 )
        (va_a v4 c2 c1 )
        (va_a v5 c1 c3 )
        (va_a v6 c3 c6 )
        (va_a v7 c5 c4 )
        (va_a v8 c4 c1 )
        (va_a v9 c1 c6 )
        (va_a v10 c6 c2 )
        (va_a v11 c2 c3 )
        (va_a v12 c3 c5 )
        (va_a v13 c5 c4 )
        (va_a v14 c4 c1 )
        (va_a v15 c1 c6 )
        (va_a v16 c6 c2 )
        (va_a v17 c2 c3 )
        (va_a v18 c3 c5 )
        (va_a v19 c5 c4 )
        (va_a v20 c4 c1 )
        (esta_en h1 c3 )
        (esta_en h2 c5 )
        (esta_en h3 c4 )
        (esta_en h4 c1 )
        (esta_en h5 c6 )
        (esta_en h6 c2 )
        (esta_en h7 c3 )
        (esta_en h8 c5 )
        (esta_en h9 c4 )
        (esta_en h10 c1 )
        (esta_en h11 c6 )
        (esta_en h12 c2 )
        (esta_en h13 c3 )
        (esta_en h14 c5 )
        (esta_en h15 c4 )
        (esta_en h16 c1 )
        (esta_en h17 c6 )
        (esta_en h18 c2 )
        (esta_en h19 c3 )
        (esta_en h20 c5 )
        (= (precio_hotel h1) 128)
        (= (precio_hotel h2) 38)
        (= (precio_hotel h3) 240)
        (= (precio_hotel h4) 19)
        (= (precio_hotel h5) 175)
        (= (precio_hotel h6) 300)
        (= (precio_hotel h7) 277)
        (= (precio_hotel h8) 280)
        (= (precio_hotel h9) 285)
        (= (precio_hotel h10) 243)
        (= (precio_hotel h11) 255)
        (= (precio_hotel h12) 153)
        (= (precio_hotel h13) 183)
        (= (precio_hotel h14) 238)
        (= (precio_hotel h15) 33)
        (= (precio_hotel h16) 138)
        (= (precio_hotel h17) 76)
        (= (precio_hotel h18) 208)
        (= (precio_hotel h19) 58)
        (= (precio_hotel h20) 152)
        (= (precio_vuelo v1) 22)
        (= (precio_vuelo v2) 105)
        (= (precio_vuelo v3) 125)
        (= (precio_vuelo v4) 276)
        (= (precio_vuelo v5) 133)
        (= (precio_vuelo v6) 61)
        (= (precio_vuelo v7) 165)
        (= (precio_vuelo v8) 223)
        (= (precio_vuelo v9) 192)
        (= (precio_vuelo v10) 257)
        (= (precio_vuelo v11) 60)
        (= (precio_vuelo v12) 150)
        (= (precio_vuelo v13) 237)
        (= (precio_vuelo v14) 166)
        (= (precio_vuelo v15) 43)
        (= (precio_vuelo v16) 205)
        (= (precio_vuelo v17) 238)
        (= (precio_vuelo v18) 128)
        (= (precio_vuelo v19) 265)
        (= (precio_vuelo v20) 68)
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