(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects
        cg1  c1  c2  c3  c4  c5  c6  c7  c8  c9  c10  c11  c12  c13  c14  c15  c16  c17  c18  c19  c20   - ciudad
        vg1  v1  v2  v3  v4  v5  v6  v7  v8  v9  v10  v11  v12  v13  v14  v15  v16  v17  v18  v19  v20  v21  v22  v23  v24  v25  v26  v27  v28  v29  v30  v31  v32  v33  v34  v35  v36  v37  v38  v39  v40   - vuelo
        h1  h2  h3  h4  h5  h6  h7  h8  h9  h10  h11  h12  h13  h14  h15  h16  h17  h18  h19  h20  h21  h22  h23  h24  h25  h26  h27  h28  h29  h30  - hotel
        dias2  dias3  dias4  dias5  dias6  - dias_por_ciudad
    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger) 16 )
        (= (min_dias_por_ciudad) 2 )
        (= (max_dias_por_ciudad) 6 )
        (= (num_dias_recorrido) 0)
        (= (min_dias_recorrido) 45 )
        (= (dias_por_ciudad dias2) 2)
        (= (dias_por_ciudad dias3) 3)
        (= (dias_por_ciudad dias4) 4)
        (= (dias_por_ciudad dias5) 5)
        (= (dias_por_ciudad dias6) 6)
        (= (min_precio_plan) 100)
        (= (max_precio_plan) 10000)
        (= (precio_plan) 0)
        (current_ciudad cg1)
        (ciudad_visitada cg1)
        (va_a vg1 cg1 c1)
        (va_a vg1 cg1 c2)
        (va_a vg1 cg1 c3)
        (va_a vg1 cg1 c4)
        (va_a vg1 cg1 c5)
        (va_a vg1 cg1 c6)
        (va_a vg1 cg1 c7)
        (va_a vg1 cg1 c8)
        (va_a vg1 cg1 c9)
        (va_a vg1 cg1 c10)
        (va_a vg1 cg1 c11)
        (va_a vg1 cg1 c12)
        (va_a vg1 cg1 c13)
        (va_a vg1 cg1 c14)
        (va_a vg1 cg1 c15)
        (va_a vg1 cg1 c16)
        (va_a vg1 cg1 c17)
        (va_a vg1 cg1 c18)
        (va_a vg1 cg1 c19)
        (va_a vg1 cg1 c20)
        (va_a v1 c2 c17 )
        (va_a v2 c17 c10 )
        (va_a v3 c10 c19 )
        (va_a v4 c19 c13 )
        (va_a v5 c13 c12 )
        (va_a v6 c12 c5 )
        (va_a v7 c5 c1 )
        (va_a v8 c1 c6 )
        (va_a v9 c6 c16 )
        (va_a v10 c16 c14 )
        (va_a v11 c14 c15 )
        (va_a v12 c15 c18 )
        (va_a v13 c18 c9 )
        (va_a v14 c9 c7 )
        (va_a v15 c7 c11 )
        (va_a v16 c11 c4 )
        (va_a v17 c4 c20 )
        (va_a v18 c20 c3 )
        (va_a v19 c3 c8 )
        (va_a v20 c8 c2 )
        (va_a v21 c3 c14 )
        (va_a v22 c14 c9 )
        (va_a v23 c9 c12 )
        (va_a v24 c12 c11 )
        (va_a v25 c11 c4 )
        (va_a v26 c4 c13 )
        (va_a v27 c13 c18 )
        (va_a v28 c18 c10 )
        (va_a v29 c10 c20 )
        (va_a v30 c20 c1 )
        (va_a v31 c1 c17 )
        (va_a v32 c17 c7 )
        (va_a v33 c7 c6 )
        (va_a v34 c6 c2 )
        (va_a v35 c2 c15 )
        (va_a v36 c15 c8 )
        (va_a v37 c8 c19 )
        (va_a v38 c19 c16 )
        (va_a v39 c16 c5 )
        (va_a v40 c5 c3 )
        (esta_en h1 c5 )
        (esta_en h2 c3 )
        (esta_en h3 c14 )
        (esta_en h4 c9 )
        (esta_en h5 c12 )
        (esta_en h6 c11 )
        (esta_en h7 c4 )
        (esta_en h8 c13 )
        (esta_en h9 c18 )
        (esta_en h10 c10 )
        (esta_en h11 c20 )
        (esta_en h12 c1 )
        (esta_en h13 c17 )
        (esta_en h14 c7 )
        (esta_en h15 c6 )
        (esta_en h16 c2 )
        (esta_en h17 c15 )
        (esta_en h18 c8 )
        (esta_en h19 c19 )
        (esta_en h20 c16 )
        (esta_en h21 c5 )
        (esta_en h22 c3 )
        (esta_en h23 c14 )
        (esta_en h24 c9 )
        (esta_en h25 c12 )
        (esta_en h26 c11 )
        (esta_en h27 c4 )
        (esta_en h28 c13 )
        (esta_en h29 c18 )
        (esta_en h30 c10 )
        (= (precio_hotel h1) 128)
        (= (precio_hotel h2) 229)
        (= (precio_hotel h3) 88)
        (= (precio_hotel h4) 143)
        (= (precio_hotel h5) 28)
        (= (precio_hotel h6) 113)
        (= (precio_hotel h7) 144)
        (= (precio_hotel h8) 279)
        (= (precio_hotel h9) 241)
        (= (precio_hotel h10) 212)
        (= (precio_hotel h11) 31)
        (= (precio_hotel h12) 222)
        (= (precio_hotel h13) 270)
        (= (precio_hotel h14) 214)
        (= (precio_hotel h15) 245)
        (= (precio_hotel h16) 85)
        (= (precio_hotel h17) 259)
        (= (precio_hotel h18) 102)
        (= (precio_hotel h19) 114)
        (= (precio_hotel h20) 229)
        (= (precio_hotel h21) 112)
        (= (precio_hotel h22) 60)
        (= (precio_hotel h23) 236)
        (= (precio_hotel h24) 275)
        (= (precio_hotel h25) 95)
        (= (precio_hotel h26) 278)
        (= (precio_hotel h27) 93)
        (= (precio_hotel h28) 10)
        (= (precio_hotel h29) 111)
        (= (precio_hotel h30) 24)
        (= (precio_vuelo v1) 73)
        (= (precio_vuelo v2) 152)
        (= (precio_vuelo v3) 275)
        (= (precio_vuelo v4) 155)
        (= (precio_vuelo v5) 24)
        (= (precio_vuelo v6) 170)
        (= (precio_vuelo v7) 136)
        (= (precio_vuelo v8) 277)
        (= (precio_vuelo v9) 244)
        (= (precio_vuelo v10) 159)
        (= (precio_vuelo v11) 205)
        (= (precio_vuelo v12) 209)
        (= (precio_vuelo v13) 180)
        (= (precio_vuelo v14) 103)
        (= (precio_vuelo v15) 77)
        (= (precio_vuelo v16) 206)
        (= (precio_vuelo v17) 264)
        (= (precio_vuelo v18) 270)
        (= (precio_vuelo v19) 130)
        (= (precio_vuelo v20) 153)
        (= (precio_vuelo v21) 49)
        (= (precio_vuelo v22) 44)
        (= (precio_vuelo v23) 202)
        (= (precio_vuelo v24) 167)
        (= (precio_vuelo v25) 178)
        (= (precio_vuelo v26) 26)
        (= (precio_vuelo v27) 101)
        (= (precio_vuelo v28) 84)
        (= (precio_vuelo v29) 69)
        (= (precio_vuelo v30) 113)
        (= (precio_vuelo v31) 271)
        (= (precio_vuelo v32) 127)
        (= (precio_vuelo v33) 181)
        (= (precio_vuelo v34) 251)
        (= (precio_vuelo v35) 182)
        (= (precio_vuelo v36) 293)
        (= (precio_vuelo v37) 16)
        (= (precio_vuelo v38) 144)
        (= (precio_vuelo v39) 262)
        (= (precio_vuelo v40) 89)
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