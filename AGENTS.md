# Practica_de_Planificacion

Frozen FIB-UPC AI coursework: a travel-agency domain modelled in PDDL with progressively richer constraints across stages. Plans are produced by the **Metric-FF** planner; a SvelteKit + FastAPI web app wraps the planner for interactive use.

## Architecture
- Six self-contained stage directories, each with its own `agencia_de_viajes_domain.pddl`, several `agencia_de_viajes_problem*.pddl` / `*juegoprueba*.pddl` files, and a `scriptinstancias*.py` random instance generator:
  - [Basico/](Basico/) — base domain
  - [Extension_1/](Extension_1/) … [Extension_4/](Extension_4/) — incremental extensions (added predicates, actions, numeric metrics)
  - [Extra_2/](Extra_2/) — optional extra exercise
- [web/](web/) — SvelteKit static frontend + FastAPI backend that generates problem files and invokes the planner binary in `web/tools/`.
- [Dockerfile](Dockerfile) compiles Metric-FF (gcc/flex/bison) and serves the web app on port 3000.

## Build and Test
- Run a stage manually: `./metric-ff -o Basico/agencia_de_viajes_domain.pddl -f Basico/agencia_de_viajes_juegoprueba1.pddl` (planner is C, not Java).
- Install planner locally: `make planner` (runs `web/install-planner.sh`).
- Web app: `make dev` or `make docker-build && make docker-run` → http://localhost:3000.
- Build submission zip: `make` (produces `Sara_Buceta_Pol_Casacuberta_Alejandro_Espinosa.zip`).

## Pitfalls
- Frozen coursework — do not rework the PDDL domains or rename stage directories; the Makefile zip target and Docker bind-mounts depend on the exact layout.
- Extension_3/4 rely on numeric fluents and metric optimization; only planners supporting numeric PDDL (like Metric-FF) will work — Fast Downward will reject them.
- Each `scriptinstancias*.py` takes positional args (passengers, cities, flights, …); check the script before invoking.

See [README.md](README.md).
