# Sound Test Render V13

Fix for the shared FM6/DAC channel label.

- DAC label is now four characters: `DAC ` instead of `DAC`.
- The trailing space overwrites the previous `6` left by `FM 6`.
- When DAC is not active, the FM6 renderer continues to draw the full `FM 6` label.
- No change to the shared-slot detection logic: DAC wins while active; otherwise FM6 is shown.
