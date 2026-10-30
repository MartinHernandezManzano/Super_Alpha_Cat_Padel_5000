# Super Alpha Cat Air Padel 5000

Un 1 contra 1 que mezcla el **air hockey** con las **reglas del pádel**, protagonizado por gatetes en pixel art y un ovillo de lana.

Proyecto de la asignatura **Motores de Videojuegos** (2.º DAM, IES Ribera de Castilla), hecho con **Godot 4.7**.

## Cómo jugar

1. **Selección:** cada jugador elige su gato y marca *listo*. No se puede elegir el mismo gato.
2. **Partido:** gana quien llega antes a **10 puntos**.
3. Al terminar, se vuelve a la pantalla de selección.

### Controles

| Acción | Jugador 1 | Jugador 2 |
|---|---|---|
| Moverse | W A S D | Flechas |
| Elegir gato | A / D | ← / → |
| Listo / Sacar | Espacio | Enter |

## Reglas

El ovillo no bota en el suelo, solo rebota en paredes y gatos. Cada campo tiene un **dueño** (el gato de ese lado), y es **punto para el rival** cuando:

1. El ovillo toca **2 paredes** del campo sin que su dueño lo golpee entre medias.
2. El ovillo **sale del campo sin que su dueño lo haya golpeado**. Por ejemplo, entra, pega en el fondo y vuelve a cruzar la red.
3. El dueño lo golpea **dos veces seguidas** (doble toque).

El contador de paredes vuelve a 0 cuando el ovillo cruza la red o cuando lo golpea el dueño. Así se puede jugar con la pared propia, como en el pádel.

Otros detalles:

- **Saque:** el que saca cambia cada 2 puntos y la esquina alterna en cada punto. El que resta se coloca en la diagonal contraria.
- **Velocidad:** el ovillo acelera un 3,5 % con cada golpe de gato, hasta un máximo.
- **Golpe estilo air hockey:** el ovillo sale en la dirección del centro del gato hacia el ovillo, así que se puede apuntar.

## Estructura

```
res://
├── scenes/
│   ├── main.tscn          partido: pista, paredes, red, gatos, ovillo y HUD
│   ├── ovillo.tscn
│   ├── player/gato.tscn   un mismo gato reutilizado para los dos jugadores
│   └── ui/seleccion.tscn  pantalla de selección (escena principal)
├── scripts/
│   ├── main.gd            reglas, saque, marcador y fin de partido
│   ├── gato.gd            movimiento, teclas según jugador, señal de saque
│   ├── ovillo.gd          movimiento, rebotes, aceleración; avisa con señales
│   ├── seleccion.gd       elección de gatos
│   └── global.gd          Autoload: lista de gatos y elección de cada jugador
├── assets/                sprites, fuente e imagen de la pista
└── docs/pruebas.md        pruebas de la práctica T2.2
```

### Comunicación entre nodos

- **El ovillo** emite `toca_pared` y `toca_gato(jugador)`. No sabe nada de reglas.
- **Los gatos** emiten `interact_requested(jugador)` al pulsar su tecla de saque.
- **Main** escucha todas las señales y decide: aplica las reglas, cuenta los puntos y gestiona el saque.
- **Global** (Autoload) guarda qué gato ha elegido cada jugador entre escenas.

## Versiones (tags)

- `T2.2`: entrega de la práctica 2.2 (señales, tiempo y arquitectura).
- `prototipo`: prototipo jugable completo.

## Créditos

Ver [CREDITS.md](CREDITS.md).
