Sound Test Render V12

- FM/PSG note renderer now passes the channel Y row correctly; notes overwrite the three-character note placeholders on the same channel row.
- FM/PSG frequency renderer uses the same row and overwrites the four-character frequency placeholders.
- Fixed duplicate PSG octave division introduced in an earlier patch.
- NOISE (PSG3 with VoiceControl=$E0) now renders N-0..N-3 from PSGNoise bits 0-1 and the full four-digit PSGNoise control value.
- Left/Right/A/B only change the selected music entry. They do not play it.
- Entering Sound Test does not auto-play.
- C is the explicit play/replay button and immediately refreshes the channel display.
- Sound Test palette corrected to Mega Drive BGR word format; palette line 1 remains selected for Tile_Pal1.
