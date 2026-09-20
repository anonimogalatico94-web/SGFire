# SGFire — Vertical Slice 2.0

Protótipo FPS mobile Android, primeira pessoa, com mapa ficcional inspirado na Zona Sul de São Gabriel/RS.

## Etapa 2.0
- Vertical slice jogável de uma missão completa.
- Cronômetro de 3 minutos.
- Sprint baseado no movimento do joystick.
- Recuo visual das armas.
- HUD com vida, abates, munição, arma, tempo e FPS.
- Coberturas e blocos adicionais para criar rotas de combate.
- Vitória com 5 eliminações e derrota por morte ou tempo esgotado.
- Reinício da partida.
- Revolver: 20 corpo / 40 cabeça.
- .44: 50 corpo / 100 cabeça.
- Puma: 34 corpo / 68 cabeça.
- Facão: 34 corpo / 100 cabeça.
- Renderer GL Compatibility, sem assets externos e com geometria simples para reduzir custo.

## Android
Use Godot 4.7.2 Android e importe `project.godot`. O editor Android é capaz de criar, desenvolver e exportar projetos diretamente no aparelho. Para melhor desempenho no A03 Core, o projeto permanece em Compatibility/GL.

## Limitação importante
Esta entrega é uma vertical slice técnica. A execução física no Galaxy A03 Core ainda precisa ser feita no aparelho para medir FPS real, toque, temperatura e estabilidade.
