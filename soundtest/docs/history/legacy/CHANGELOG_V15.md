# Sound Test V15

- Fixed ASM68K V14 `if`/`fatal` error at the music table count check.
- Made `$81-$93` an explicit configurable Sound Test range in `_Constants.asm`.
- Removed the fragile build-time table assertion.
- Moved Sound Test source, data, previews, tools, and documentation into `soundtest/`.
- Updated all include paths after the source move.
- Kept the standard project palette under `palette/`.
- Preserved the V14 DAC/FM6, noise, note renderer, and C-only playback behavior.
