# Super Alpha Cat Air Padel 5000

Un 1 contra 1 que mezcla el **air hockey** con las **reglas del pádel**, protagonizado por gatetes en pixel art.

Proyecto de la asignatura **Motores de Videojuegos** (2.º DAM, IES Ribera de Castilla), hecho con **Godot 4.7**.

## Cómo jugar

1. **Elige tu gatete:** cada jugador elige el suyo y marca *listo*. No se puede repetir gato.
2. **Elige la pelota:** cualquiera de los dos la cambia y la confirma.
3. **Partido:** gana quien llega antes a **10 puntos**.
4. Al terminar, se vuelve a la elección de gatos.

### Controles

| Acción | Jugador 1 | Jugador 2 |
|---|---|---|
| Moverse | W A S D | Flechas |
| Elegir gato / pelota | A / D | ← / → |
| Listo / Sacar / Dash | Espacio | Enter |

## Reglas

La pelota no bota en el suelo, solo rebota en paredes y gatos. Cada campo tiene un **dueño** (el gato de ese lado), y es **punto para el rival** cuando:

1. La pelota toca **más de 2 paredes** del campo sin que su dueño la golpee entre medias.
2. La pelota **sale del campo sin que su dueño la haya golpeado**. Por ejemplo, entra, pega en el fondo y vuelve a cruzar la red.
3. El dueño la golpea **dos veces seguidas** (doble toque).

El contador de paredes vuelve a 0 cuando la pelota cruza la red o cuando la golpea el dueño. Así se puede jugar con la pared propia, como en el pádel.

Otros detalles:

- **Saque:** el que saca cambia cada 2 puntos y la esquina alterna en cada punto. El que resta se coloca en la diagonal contraria.
- **Golpe estilo air hockey:** la pelota sale en la dirección del centro del gato hacia la pelota, así que se puede apuntar.
- **Velocidad:** la pelota acelera un poco con cada golpe de gato, hasta un tope que depende de la pelota.

## Dash, estamina y siesta

- Durante el punto, la tecla de saque hace un **dash**: un acelerón corto en la dirección en la que te mueves. Si estás quieto, no hace nada.
- Cada dash gasta **60 de 100** de estamina. Encima del gato aparece una barra:
  - **verde:** puedes hacer otro dash;
  - **roja:** si haces otro dash, te duermes.
- La estamina se recupera sola: **rápido si estás quieto** y lento si te mueves.
- Intentar un dash sin estamina deja al gato **dormido 1 segundo**: no se mueve y pone cara de dormido. Si la pelota le da, rebota en él y cuenta como toque.
- Cada punto empieza con los gatos descansados.

## Pelotas

| Pelota | Carácter | Tamaño | Salida | Tope | Acelera |
|---|---|---|---|---|---|
| Ovillo | El de toda la vida | 32 px | 380 | 600 | 3,5 % |
| Fútbol | Sale disparado pero acelera poco | 32 px | 430 | 600 | 2 % |
| Basket | Grande y pesado | 40 px | 330 | 520 | 3 % |
| Béisbol | Pequeña y se desboca | 24 px | 380 | 720 | 5 % |

Velocidades en píxeles por segundo; la aceleración es por cada golpe de gato. Se ajustan en `scripts/global.gd`.

## Estructura

```
res://
├── scenes/
│   ├── main.tscn                 partido: pista, paredes, red, gatos, pelota y HUD
│   ├── ovillo.tscn               la pelota (cambia de aspecto según la elegida)
│   ├── player/gato.tscn          un mismo gato reutilizado para los dos jugadores
│   └── ui/
│       ├── seleccion.tscn        elección de gatos (escena principal)
│       └── seleccion_pelota.tscn elección de pelota
├── scripts/
│   ├── main.gd                   reglas, saque, marcador y fin de partido
│   ├── gato.gd                   movimiento, dash, estamina y siesta
│   ├── ovillo.gd                 movimiento, rebotes y aceleración; avisa con señales
│   ├── seleccion.gd              elección de gatos
│   ├── seleccion_pelota.gd       elección de pelota y sus estrellas
│   └── global.gd                 Autoload: datos de gatos y pelotas, y lo elegido
├── assets/                       sprites, fuente e imagen de la pista
└── docs/pruebas.md               pruebas de la práctica T2.2
```

### Comunicación entre nodos

- **La pelota** emite `toca_pared` y `toca_gato(jugador)`. No sabe nada de reglas.
- **Los gatos** emiten `interact_requested(jugador)` al pulsar su tecla. Cada gato gestiona su propia estamina y su siesta.
- **Main** escucha todas las señales y decide: si estamos esperando el saque, saca; si estamos en juego, le pide al gato un dash. También aplica las reglas, cuenta los puntos y gestiona el saque.
- **Global** (Autoload) guarda los datos de gatos y pelotas, y lo que se ha elegido, entre escenas.

## Versiones (tags)

- `T2.2`: entrega de la práctica 2.2 (señales, tiempo y arquitectura).
- `prototipo`: prototipo jugable completo.

## Créditos

Ver [CREDITS.md](CREDITS.md).
