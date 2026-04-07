# Inteligencia Artificial: Práctica de Planificación (Agencia de Viajes)

## Descripción
Esta es la práctica de la asignatura de Inteligencia Artificial (IA) centrada en el diseño y resolución de problemas de **Planificación Automática** utilizando **PDDL** (Planning Domain Definition Language). El dominio principal modelado durante toda la práctica es la gestión de una **Agencia de Viajes**.

El objetivo es modelar, mediante estados y acciones formales, diferentes niveles de complejidad para la planificación de viajes (controlando orígenes, destinos, transportes, alojamientos y demás restricciones lógicas).

---

## Autores
* Sara Buceta
* Pol Casacuberta
* Alejandro Espinosa

---

## Estructura del Proyecto

El repositorio está dividido de forma incremental. Se comienza por una versión básica del dominio de la agencia de viajes, y se le van añadiendo extensiones de forma progresiva para abarcar nuevas restricciones. Cada directorio es auto-contenido y dispone de su correspondiente dominio, problemas de prueba y generadores.

```text
Practica_de_Planificacion/
├── Basico/          # Dominio base de la agencia de viajes y juegos de prueba iniciales
├── Extension_1/     # Dominio con la 1ª extensión implementada (nuevas variables/acciones)
├── Extension_2/     # Dominio con la 2ª extensión implementada
├── Extension_3/     # Dominio con la 3ª extensión implementada
├── Extension_4/     # Dominio con la 4ª extensión implementada
├── Extra_2/         # Resolución y problemas asociados al "Extra 2" de la práctica
├── docs/            # Documentación adicional de la práctica
├── practica_de_planificacion.pdf # Memoria técnica detallada de la práctica
├── Makefile         # Utilidad para compilar y empaquetar la entrega final
└── README.md        # Este archivo
```

---

## Contenido de las Carpetas

Dentro de cada directorio (`Basico/`, `Extension_X/`), encontrarás los siguientes archivos clave:
1. `agencia_de_viajes_domain.pddl`: Archivo que define el **dominio**: los tipos, predicados básicos y acciones posibles (ej: volar, alojarse, desplazarse).
2. `agencia_de_viajes_problem.pddl` o `*juegoprueba*.pddl`: Archivos de **problema**. Definen el estado inicial (ciudades, hoteles o vuelos disponibles) y los objetivos a cumplir (pasajeros que deben llegar y alojarse a ciertos destinos).
3. `scriptinstancias.py`: Script en Python encargado de **generar problemas PDDL** de forma automática y aleatoria, ideal para realizar pruebas de escalabilidad sobre los planificadores evaluados.

---

## Uso y Pruebas

Para probar los dominios y problemas, necesitas ejecutar un **Planificador PDDL** compatible (como *Metric-FF*, *Fast Downward*, *LPG-td*, etc.).

**Ejemplo genérico de ejecución:**
```shell
./planificador -o Basico/agencia_de_viajes_domain.pddl -f Basico/agencia_de_viajes_juegoprueba1.pddl
```

### Generación de Problemas
Si quieres generar de cero un nuevo escenario de prueba, utiliza el generador en Python incluido en la carpeta correspondiente:
```shell
python3 Basico/scriptinstancias.py
```
*(Consulta el script Python para verificar los argumentos posicionales esperados, como el número de pasajeros, ciudades o vuelos)*.

---

## Empaquetado y Entrega

El proyecto incluye un `Makefile` para generar los archivos de la entrega de forma estandarizada. 

Para empaquetar todo el código fuente y el PDF en un archivo `.zip` con los nombres de los autores:
```bash
make
```

Para limpiar el entorno y borrar los archivos `.zip` generados:
```bash
make clean
```

---

## Web App

An interactive web frontend for the travel agency planning domain: configure passengers, cities, flights, hotels, and optimization objectives, then run the Metric-FF planner and visualize the resulting plan.

**Stack:** SvelteKit (static) + FastAPI + Metric-FF planner (compiled in Docker)

### Quick Start

```bash
# Docker (recommended)
docker build -t practica-planificacion . && docker run -p 3000:3000 practica-planificacion
# http://localhost:3000
```

### Features

- Visual PDDL problem builder — configure passengers, cities, flights, and hotels through a form UI
- Automatic PDDL problem file generation from user inputs
- Run Metric-FF planner and display the resulting action plan
- Support for all 4 domain extensions (basic through numeric optimization)
- Interactive plan timeline visualization

### Web Structure

```
web/
├── src/               # SvelteKit application
├── static/            # Static assets
├── tools/             # Metric-FF planner binary
├── generator.py       # PDDL problem generator
├── svelte.config.js
├── vite.config.ts
└── package.json
```
