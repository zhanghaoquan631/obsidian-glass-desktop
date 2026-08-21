# Bottom Ambient Light

This module renders the real bottom-edge ambient light used by the UI Desktop wallpaper.

- `bottom-ambient-light.css` contains the cyan, violet and accent light pools, horizon and slow ribbons.
- `bottom-ambient-light.js` handles Lively properties, pause state, pointer focus, audio response and low-power mode.
- The module uses CSS transforms and opacity for continuous animation. JavaScript only schedules one frame for a pending pointer update and does not add a render loop.
- It is loaded between the space layer and the animal canvas, so it stays behind the animals, widgets and Dock.

Lively controls:

- `bottomAmbientEnabled`
- `bottomAmbientIntensity`
- `bottomAmbientPalette`
- `bottomAmbientPointerReactive`
- `bottomAmbientAudioReactive`
- `bottomAmbientReset`
