#!/usr/bin/env python3
"""
Unified PDDL problem generator for all extension levels.
Ports Basico/scriptinstancias.py through Extension_4/scriptinstancias_extextension4.py
into a single CLI tool with argparse (no interactive input).
"""

import argparse
import copy
import random
import sys


LEVELS = ("basico", "ext1", "ext2", "ext3", "ext4")


def build_objects(nciu: int, nvuelos: int, nalojamientos: int):
    ciudades = ["cg1"] + [f"c{i+1}" for i in range(nciu)]
    vuelos = ["vg1"] + [f"v{i+1}" for i in range(nvuelos)]
    alojamientos = [f"h{i+1}" for i in range(nalojamientos)]
    return ciudades, vuelos, alojamientos


def assign_flights(ciudades: list, vuelos: list, nciu: int):
    ghost = [f"        (va_a vg1 cg1 c{i+1})" for i in range(nciu)]

    aux = ciudades[1:]
    random.shuffle(aux)
    routes = []
    found = False
    for i, v in enumerate(vuelos):
        if v == "vg1":
            continue
        if i > nciu and not found:
            random.shuffle(aux)
            found = True
        i1 = i % nciu
        i2 = (i + 1) % nciu
        routes.append(f"        (va_a {v} {aux[i1]} {aux[i2]})")

    return ghost, routes, aux


def assign_hotels(alojamientos: list, aux: list, nciu: int, nalojamientos: int):
    hotel_preds = []
    found = False
    for i, h in enumerate(alojamientos):
        if i > nalojamientos and not found:
            random.shuffle(aux)
            found = True
        ciualoja = aux[i % nciu]
        hotel_preds.append(f"        (esta_en {h} {ciualoja})")
    return hotel_preds


def generate(level: str, nciu: int, nciumin: int, nvuelos: int, nalojamientos: int,
             min_days: int = 1, max_days: int = 3, min_total_days: int = 5,
             min_price: int = 100, max_price: int = 500,
             seed: int | None = None) -> str:
    if seed is not None:
        random.seed(seed)

    ciudades, vuelos, alojamientos = build_objects(nciu, nvuelos, nalojamientos)
    ghost, routes, aux = assign_flights(ciudades, vuelos, nciu)
    hotel_preds = assign_hotels(alojamientos, aux, nciu, nalojamientos)

    has_days = level in ("ext1", "ext2", "ext3", "ext4")
    has_interest = level in ("ext2", "ext4")
    has_price = level in ("ext3", "ext4")

    lines = []
    lines.append("(define (problem agencia_viaje)")
    lines.append("    (:domain agencia_viaje)")
    lines.append("    (:objects")

    lines.append("        " + " ".join(ciudades) + " - ciudad")
    lines.append("        " + " ".join(vuelos) + " - vuelo")
    lines.append("        " + " ".join(alojamientos) + " - hotel")

    if has_days:
        dias_objs = [f"dias{d}" for d in range(min_days, max_days + 1)]
        lines.append("        " + " ".join(dias_objs) + " - dias_por_ciudad")

    lines.append("    )")
    lines.append("    (:init")
    lines.append("        (= (num_ciudades_escogidas) 0)")
    lines.append(f"        (= (min_ciudades_a_recoger) {nciumin})")

    if has_days:
        lines.append(f"        (= (min_dias_por_ciudad) {min_days})")
        lines.append(f"        (= (max_dias_por_ciudad) {max_days})")
        lines.append("        (= (num_dias_recorrido) 0)")
        lines.append(f"        (= (min_dias_recorrido) {min_total_days})")
        for d in range(min_days, max_days + 1):
            lines.append(f"        (= (dias_por_ciudad dias{d}) {d})")

    if has_interest:
        lines.append("        (= (interes_actual) 0)")
        for c in ciudades:
            val = 0 if c == "cg1" else random.randint(0, nciu)
            lines.append(f"        (= (interes_ciudad {c}) {val})")

    if has_price:
        lines.append(f"        (= (min_precio_plan) {min_price})")
        lines.append(f"        (= (max_precio_plan) {max_price})")
        lines.append("        (= (precio_plan) 0)")
        for h in alojamientos:
            lines.append(f"        (= (precio_hotel {h}) {random.randint(10, 300)})")
        for v in vuelos:
            if v == "vg1":
                lines.append("        (= (precio_vuelo vg1) 0)")
            else:
                lines.append(f"        (= (precio_vuelo {v}) {random.randint(10, 300)})")

    lines.append("        (current_ciudad cg1)")
    lines.append("        (ciudad_visitada cg1)")
    lines.extend(ghost)
    lines.extend(routes)
    lines.extend(hotel_preds)

    lines.append("    )")
    lines.append("")

    # Goal
    goals = ["(<= (min_ciudades_a_recoger) (num_ciudades_escogidas))"]
    if has_days:
        goals.append("(<= (min_dias_recorrido) (num_dias_recorrido))")
    if has_price:
        goals.append("(<= (min_precio_plan) (precio_plan))")
        goals.append("(>= (max_precio_plan) (precio_plan))")

    lines.append("    (:goal (and")
    for g in goals:
        lines.append(f"        {g}")
    lines.append("    ))")

    # Metric
    if level == "ext2":
        lines.append("    (:metric minimize")
        lines.append("        (interes_actual)")
        lines.append("    )")
    elif level == "ext3":
        lines.append("    (:metric minimize")
        lines.append("        (precio_plan)")
        lines.append("    )")
    elif level == "ext4":
        lines.append("    (:metric minimize")
        lines.append("        (+ (precio_plan) (* (interes_actual) 400))")
        lines.append("    )")

    lines.append(")")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Generate PDDL problem instances")
    parser.add_argument("--level", choices=LEVELS, required=True)
    parser.add_argument("--cities", type=int, required=True, help="Number of cities")
    parser.add_argument("--min-cities", type=int, required=True, help="Min cities to visit")
    parser.add_argument("--flights", type=int, required=True, help="Number of flights (>= cities)")
    parser.add_argument("--hotels", type=int, required=True, help="Number of hotels (>= cities)")
    parser.add_argument("--min-days", type=int, default=1, help="Min days per city (ext1+)")
    parser.add_argument("--max-days", type=int, default=3, help="Max days per city (ext1+)")
    parser.add_argument("--min-total-days", type=int, default=5, help="Min total trip days (ext1+)")
    parser.add_argument("--min-price", type=int, default=100, help="Min trip price (ext3+)")
    parser.add_argument("--max-price", type=int, default=500, help="Max trip price (ext3+)")
    parser.add_argument("--seed", type=int, default=None, help="Random seed for reproducibility")
    args = parser.parse_args()

    if args.flights < args.cities:
        print(f"Error: flights ({args.flights}) must be >= cities ({args.cities})", file=sys.stderr)
        sys.exit(1)
    if args.hotels < args.cities:
        print(f"Error: hotels ({args.hotels}) must be >= cities ({args.cities})", file=sys.stderr)
        sys.exit(1)

    pddl = generate(
        level=args.level,
        nciu=args.cities,
        nciumin=args.min_cities,
        nvuelos=args.flights,
        nalojamientos=args.hotels,
        min_days=args.min_days,
        max_days=args.max_days,
        min_total_days=args.min_total_days,
        min_price=args.min_price,
        max_price=args.max_price,
        seed=args.seed,
    )
    print(pddl)


if __name__ == "__main__":
    main()
