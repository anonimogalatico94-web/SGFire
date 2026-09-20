# SGFire 2.1 — Áudio do Lobby

Esta etapa adiciona uma faixa **original** de som ambiente para o lobby, sem reproduzir música de terceiros.

- `audio/lobby_ambient.wav`: ambiente escuro/urbano, 30 s, baixo volume e preparado para tocar em loop posteriormente.
- O `AudioStreamPlayer` inicia automaticamente ao carregar a cena.
- HUD: `SGFIRE • CAPÍTULO 4 — 4 VS 3`.
- A faixa é original e não é uma imitação de Racionais MC's ou de outra gravação comercial.

O Godot usa `AudioStreamPlayer` para reprodução não-posicional; arquivos WAV/OGG/MP3 podem ser importados como AudioStreams. Para loop contínuo, a propriedade de loop pode ser ativada no recurso de áudio. Consulte a documentação oficial de áudio.
