# Obsidian Glass Live Wallpaper

This directory is the current Lively Wallpaper source used by Obsidian Glass Desktop. Import the directory through `index.html`; do not open an individual layer as the wallpaper entry point.

## Current layers

- `space-environment/`: stars, nebulae, constellations, galaxies and meteors.
- `ambient-light/`: the real bottom-edge cyan/violet light, horizon and ribbons behind the Dock.
- `animal-trail/`: pointer trail, autonomous animals, starter sprite sets and the Petdex metadata catalogue.
- `js/`: the adapted WebGL fluid simulation and the shared Lively playback, audio and property bridge.

The bottom ambient module is loaded between the space background and the animal canvas. Its continuous motion is CSS compositor based; JavaScript has no independent render loop and only coalesces pointer movement into one pending animation frame. Lively settings expose enable, intensity, palette, pointer response, audio response and reset controls.

## Lively import

1. Add this directory as a web wallpaper in Lively Wallpaper.
2. Use `index.html` as the entry file.
3. Open the wallpaper customization panel to adjust the bottom ambient-light controls.

The public package does not include personal wallpaper media or the full community sprite cache. Missing optional sprites do not prevent the starter animals, fluid layer, space layer or bottom ambient light from running.

## Upstream fluid simulation

The fluid base was modified to work with the [Lively Wallpaper](https://github.com/rocksdanister/lively) audio interface. The upstream v3 package is available from [WebGL Fluid Simulation releases](https://github.com/rocksdanister/WebGL-Fluid-Simulation/releases/download/v3/Fluids_v3.zip).

## References

- [GPU Gems, Chapter 38](http://developer.download.nvidia.com/books/HTML/gpugems/gpugems_ch38.html)
- [fluids-2d](https://github.com/mharrys/fluids-2d)
- [GPU Fluid Experiments](https://github.com/haxiomic/GPU-Fluid-Experiments)

## License

The fluid simulation code is available under the [MIT license](LICENSE).
