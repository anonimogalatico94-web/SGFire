# SGFire

Protótipo de FPS mobile offline em Godot 4.4.1, com destino Android 9+ (API mínima 28).

## Estado atual — playtest 179

- Cena de inicialização configurada em `project.godot`: `Prototype.tscn`.
- Protótipo 3D noturno inspirado em São Gabriel–RS, com jogador em primeira pessoa, bots, cenário com coberturas, HUD e controles de toque.
- Controles de movimento, mira por arraste, disparo e recarga.
- Efeitos visuais de disparo e suporte a efeitos sonoros quando os arquivos de áudio estiverem presentes.
- Exportação Android para ARMv7 e ARM64; API mínima 28 (Android 9).
- O teste é offline. Multiplayer, lobby completo, campeonatos e publicação ficam para depois da validação no aparelho.

## Controles

- Setas na tela: movimentação.
- Toque em FIRE: disparar.
- Botão R: recarregar.
- Arraste no lado direito da tela: mirar.

## Build e validação

O workflow `.github/workflows/test.yml` faz:

1. Preparação do Android SDK e Godot 4.4.1.
2. Validação dos arquivos do projeto.
3. Execução headless da cena inicial por 120 frames, verificando erros de GDScript.
4. Exportação e verificação da assinatura/alinhamento da APK.
5. Publicação do artefato `SGFire-Android9Plus-APK-179`, com a APK e os logs de validação.

A compilação verde confirma que a APK foi exportada e passou pelas verificações automatizadas. **Não substitui o teste físico de instalação, abertura, imagem e controles no Moto E6i.**

## Arquivos principais

- `project.godot` — configuração e cena inicial.
- `Prototype.tscn` / `prototype.gd` — protótipo 3D e lógica do jogo.
- `A03Test.tscn` / `A03Test.gd` — diagnóstico 2D legado.
- `export_presets.cfg` — preset Android.
- `.github/workflows/test.yml` — automação de validação e build.

## Próxima meta

Validar a inicialização real da cena 3D e instalar a APK no Moto E6i. Se aparecer tela preta ou erro, usar o log de inicialização para corrigir o problema antes de adicionar novas funcionalidades.
