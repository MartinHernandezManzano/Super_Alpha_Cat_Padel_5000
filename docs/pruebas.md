# Pruebas T2.2 – Señales, tiempo y arquitectura

## Escena

```
Main (Node2D + main.gd)
├── Pista        Sprite2D con la imagen de la pista
├── Paredes      4 StaticBody2D con CollisionShape2D
├── Ovillo       instancia de ovillo.tscn (se mueve solo y rebota)
├── Player       instancia de gato.tscn (se mueve con WASD)
└── RoundTimer   Timer (one_shot = true, autostart = false)
```

## Quién emite, quién recibe

| Señal | Emite | Recibe | Reacción |
|---|---|---|---|
| `interact_requested` (propia) | Player, al pulsar `interact` (espacio) | Main → `_on_player_interact_requested()` | Muestra "Interacción recibida" y pausa o reanuda el ovillo |
| `timeout` | RoundTimer, al acabar `wait_time` | Main → `_on_round_timer_timeout()` | Detiene el movimiento y la entrada de Player, para el ovillo y muestra "Fin de la ronda" |

- `gato.gd`: lee el teclado, mueve al gato y emite `interact_requested`. No conoce a Main.
- `ovillo.gd`: mueve el ovillo y lo hace rebotar contra paredes y gato.
- `main.gd`: arranca el RoundTimer en `_ready()` y decide qué pasa al recibir cada señal.

## Resultados

### wait_time = 5

| Prueba | Resultado esperado | Resultado real |
|---|---|---|
| Pulsar interact antes del final | Un mensaje por pulsación | Correcto: un "Interacción recibida" por pulsación; el ovillo se pausa y se reanuda |
| Agotar wait_time | El jugador se detiene y aparece el final | Correcto: a los 5 s el gato y el ovillo se paran y sale "Fin de la ronda" |
| Pulsar interact después | No aparecen nuevos mensajes de interacción | Correcto: no sale ningún mensaje |
| Volver a ejecutar Main | El jugador responde y el tiempo empieza de nuevo | Correcto |

### wait_time = 30

| Prueba | Resultado esperado | Resultado real |
|---|---|---|
| Pulsar interact antes del final | Un mensaje por pulsación |Correcto: funciona igual q antes |
| Agotar wait_time | El jugador se detiene y aparece el final |Correcto: a los 30s se para  |
| Pulsar interact después | No aparecen nuevos mensajes de interacción |Tutto Benne |
| Volver a ejecutar Main | El jugador responde y el tiempo empieza de nuevo |Funciona como Dios manda |
