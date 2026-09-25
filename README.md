# SGFire

Protótipo de FPS mobile para Android, desenvolvido em Godot 4.4.x e preparado para testes no Samsung Galaxy A03.

## Estado atual

- Projeto Godot 4.4.x.
- Cena inicial: `A03Test.tscn`.
- Tela inicial com botão **INICIAR TESTE 3D COM BOTS**.
- Protótipo 3D carregado por `Prototype.tscn`.
- Teste focado primeiro em jogar no Android, antes das etapas de multiplayer completo, campeonatos e sistemas de publicação.
- Exportação Android configurada para gerar APK de teste.
- Arquitetura Android preparada para **ARMv7 (armeabi-v7a)** e **ARM64 (arm64-v8a)**.
- Build de teste configurada como **versão 153** no preset Android.
- Nome do pacote de teste: `com.sgfire.game.a03test153`.

## Controles do teste

A interface e os controles devem priorizar tela sensível ao toque no Android.

O objetivo desta etapa é validar:

1. abertura do APK;
2. carregamento da tela inicial;
3. entrada no teste 3D;
4. movimentação do jogador;
5. interação com os bots;
6. estabilidade no Galaxy A03;
7. desempenho e erros de inicialização.

## Bots e protótipo

O protótipo atual contém a base de teste 3D e lógica de inimigos/bots. O teste inicial é offline e serve para validar a jogabilidade antes da integração do multiplayer online.

O multiplayer planejado posteriormente inclui partidas por equipes, com formação 5x5.

## Mapa e direção visual

A direção do projeto prevê um cenário urbano noturno inspirado em São Gabriel–RS, com áreas de bairros, centro e Zona Sul. A versão de teste pode usar cenário simplificado enquanto a jogabilidade e a estabilidade são validadas.

## Armas do protótipo

O protótipo de referência inclui:

- Revólver .38;
- Rifle Puma;
- Facão com desenho de três listras.

Os valores de dano e balanceamento ainda são de protótipo e podem ser ajustados durante os testes.

## Android / GitHub Actions

O projeto possui workflow em `.github/workflows/test.yml`.

O workflow:

- verifica os arquivos essenciais;
- prepara Android SDK;
- instala Godot 4.4.1;
- instala os templates de exportação Android correspondentes;
- configura a assinatura de debug;
- valida o projeto em modo headless;
- exporta o APK Android;
- verifica a assinatura do APK;
- gera informações de identificação do APK;
- publica o APK como artefato do GitHub Actions.

O APK gerado pelo workflow é:

`build/SGFire-A03.apk`

O artefato publicado pelo Actions é:

`SGFire-A03-APK`

## Observação importante sobre o APK

A existência da configuração de exportação e do workflow **não significa que cada execução já tenha produzido um APK funcional**. O resultado precisa ser confirmado pelo GitHub Actions e, depois, instalado e executado fisicamente no aparelho.

## Versões

- Projeto Godot: `0.63.1`
- Preset Android / build: `153`
- Nome da versão Android: `0.63.0-a03-playtest`

A diferença entre a versão interna do projeto e o nome da build é intencional nesta fase de teste e poderá ser unificada posteriormente.

## Arquivos principais

- `project.godot` — configuração do projeto.
- `A03Test.tscn` — cena inicial do teste Android.
- `A03Test.gd` — botão de entrada no teste 3D.
- `Prototype.tscn` — cena do protótipo 3D.
- `prototype.gd` — lógica principal do protótipo.
- `export_presets.cfg` — configuração de exportação Android.
- `.github/workflows/test.yml` — automação da build Android.
- `.github/android/sgfire-debug.keystore.b64` — material de assinatura de debug usado pelo workflow.

## Próximas etapas

1. Confirmar uma execução verde do GitHub Actions.
2. Baixar o artefato APK.
3. Instalar no Galaxy A03.
4. Confirmar abertura sem encerramento.
5. Testar controles, bots e desempenho.
6. Corrigir qualquer erro encontrado.
7. Repetir a build e o teste.
8. Só depois avançar para mapas mais completos, multiplayer online, lobby e demais sistemas.

## Objetivo desta fase

**Primeiro: fazer o SGFire abrir e ser jogável no Android.**

Depois da validação do primeiro teste, o projeto pode avançar gradualmente para as funcionalidades maiores.
