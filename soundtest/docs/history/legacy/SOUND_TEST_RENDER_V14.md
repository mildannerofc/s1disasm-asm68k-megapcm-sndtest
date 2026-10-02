# Sound Test V14 render update

- Shared FM6/DAC row now clears all stale DAC/FM fields on mode switches.
- DAC sample names are resolved from the live `SavedDAC` byte.
- DAC IDs are shown as two hexadecimal digits.
- `$80` is treated as a DAC rest.
- Noise renders `N-0..N-3` and its raw control byte.
- The dash glyph is explicitly generated instead of accidentally extracting the `W` glyph from the reference sheet.
- Sound Test palette uses Mega Drive mode-5 BGR ordering; the dark-red background is in palette entry 0.
