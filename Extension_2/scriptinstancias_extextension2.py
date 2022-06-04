import copy
import random

if __name__ == "__main__":
    nvuelos = 0
    nalojamientos = 0

    print("Inserte el numero de ciudades a generar")
    nciu = int(input())

    print("Inserte el número mínimo de ciudades a visitar")
    nciumin = input()

    print("Inserte el numero de vuelos a generar")
    while nvuelos < nciu:
        print("Tiene que ser mayor o igual al numero de ciudades")
        nvuelos = int(input())
    print("Inserte el numero de alojamientos a generar")

    while nalojamientos < nciu:
        print("Tiene que ser mayor o igual al numero de ciudades")
        nalojamientos = int(input())
    ciudades = ["cg1"]
    vuelos = ["vg1"]
    alojamientos = []
    vuelosfantasma = []
    vuelosentreciu = []

    for i in range(nciu):
        ciudades.append("c" + str(i + 1))
        vuelosfantasma.append('        (' + "va_a vg1 cg1 c" + str(i + 1) + ')')

    for i in range(nvuelos):
        vuelos.append("v" + str(i + 1))

    for i in range(nalojamientos):
        alojamientos.append("h" + str(i + 1))

    aux = copy.copy(ciudades)
    aux.pop(0)
    random.shuffle(aux)
    found = False
    for i in range(len(vuelos)):
        if vuelos[i] != "vg1":
            if i > nciu:
                if not found:
                    random.shuffle(aux)
                    found = True
            i1 = i % nciu
            i2 = (i + 1) % nciu
            corigen = aux[i1]
            cdest = aux[i2]
            vuelosentreciu.append('        (' + "va_a " + vuelos[i] + " " + corigen + " " + cdest + ' )')

    found = False
    for i in range(len(alojamientos)):
        if i > nalojamientos:
            if not found:
                random.shuffle(aux)
                found = True
        i1 = i % nciu
        ciualoja = aux[i1]
        vuelosentreciu.append('        (' + "esta_en " + alojamientos[i] + " " + ciualoja + ' )')

    # Script ampliado para extensión1:
    print("Introduce el numero de dias mínimos por ciudad")
    diasminporciudad = int(input())
    print("Introduce el numero de dias máximos por ciudad")
    diasmaxporciudad = int(input())

    print("Introduce el mínimo número de dias del recorrido")
    mindiasrecorrido = int(input())

    print("""(define (problem agencia_viaje)
    (:domain agencia_viaje)
    (:objects""")
    print("        ", end='')
    for i in ciudades:
        print(i, ' ', end='')
    print(" - ciudad")
    print("        ", end='')
    for i in vuelos:
        print(i, ' ', end='')

    print(" - vuelo")
    print("        ", end='')
    for i in alojamientos:
        print(i, ' ', end='')
    print("- hotel")

    print("        ", end='')
    for i in range(diasminporciudad, diasmaxporciudad + 1):
        print("dias" + str(i), ' ', end='')
    print("- dias_por_ciudad")

    print("""    )
    (:init
        (= (num_ciudades_escogidas) 0)
        (= (min_ciudades_a_recoger)""", nciumin, """)
        (= (min_dias_por_ciudad)""", diasminporciudad, """)
        (= (max_dias_por_ciudad)""", diasmaxporciudad, """)
        (= (num_dias_recorrido) 0)
        (= (min_dias_recorrido)""", mindiasrecorrido, ')')

    for i in range(diasminporciudad, diasmaxporciudad + 1):
        print("        (= (dias_por_ciudad dias" + str(i) + ') ' + str(i) + ')')
    print("         (= (interes_actual) 0)")
    for i in range(nciu):
        interes = random.randint(0,nciu)
        print("        (= (interes_ciudad " + ciudades[i] + ') ' + str(interes) + ')')
    print("""        (current_ciudad cg1)
        (= (interes_ciudad cg1) 0)
        (ciudad_visitada cg1)""")
    for i in vuelosfantasma:
        print(i)
    for i in vuelosentreciu:
        print(i)
    print(""" 
    )
        
    (:goal (and
    (<= (min_ciudades_a_recoger) (num_ciudades_escogidas))
    ))
    ;; maximize negativo minimize negativo o viceversa
	;; minimize va DESPUES del goal
	(:metric minimize 
		(interes_actual)
	)
)
    """)
