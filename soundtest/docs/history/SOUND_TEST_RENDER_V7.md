# Sound Test Render V7

Correções desta versão:

- Palette do Sound Test corrigida para a ordem BGR real do Mega Drive.
- Fundo = vermelho escuro (`$400`).
- Fonte usa as cores da folha de referência: cinza claro, amarelo, laranja, roxo e roxo escuro.
- Ícone do medidor usa índice 6, com verde separado da cor roxa da fonte.
- Renderer de texto 8x16 mantém mapping explícito para `0-9` e `A-Z`.
- Linhas de canais e valores ficam alinhadas na mesma célula vertical.
- Renderer de notas agora mostra `NOTA` + frequência hexadecimal de 4 dígitos.
- X de canal, nota e frequência são configuráveis em `_Constants.asm`:
  - `SoundTest_ChannelX`
  - `SoundTest_NoteX`
  - `SoundTest_FreqX`
- O sexto slot de canais é dinâmico:
  - DAC tocando -> mostra `DAC`, `PCM` e estado DAC.
  - DAC parado -> mostra `FM 6` e a nota/frequência de `v_music_fm6_track`.
- FM1-FM5 usam os tracks reais do driver.
- PSG1-PSG3 usam `PSGFrequencies` do driver.
- NOISE continua sendo detectado pelo `VoiceControl == $E0`.
- Tilemap continua em 40x28 com stride real de plano de 64 células.

A arte descompactada está em:

`artunc/Sound Test Font Icons.unc`

Ela está em Mega Drive 4 BPP planar e deve ser comprimida com Nemesis se você quiser gerar novamente o `.nem`.
