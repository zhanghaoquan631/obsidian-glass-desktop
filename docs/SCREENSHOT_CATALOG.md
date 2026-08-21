# Screenshot Catalog

The public package contains high-resolution, manually reviewed reference captures. They are visual documentation, not a promise that every optional dependency is installed on every machine. Captures `01`, `04`, `06`, and `08` document the current workspace snapshot; the remaining captures are sanitized feature references retained for areas whose current live screen contained private application content.

| File | Feature | Capture rule |
|---|---|---|
| `assets/screenshots/01-overview.png` | Current Obsidian Glass layout | Privacy-safe composite made from exact current widget and bottom-ambient crops; no private values |
| `assets/screenshots/02-dock.png` | Dock, magnification, running dots, media progress | Show generic app labels only |
| `assets/screenshots/03-sidebar.png` | Left Stage rail and preview card | Do not show chat content or account names |
| `assets/screenshots/04-dashboard.png` | Current independent movable widgets | Exact safe crops of the current animal-framed AI, mode, media, clock and calendar cards |
| `assets/screenshots/05-topbar.png` | Top status bar and media center | Keep network and device identifiers out |
| `assets/screenshots/06-ambient.png` | Live bottom ambient light behind the Dock | Actual current desktop crop showing the cyan/blue light band; no conceptual replacement image |
| `assets/screenshots/07-wallpaper.png` | Fluid, galaxies, meteors, starter animals | No user wallpaper or personal media |
| `assets/screenshots/08-current-wallpaper-live.png` | Current deep-space wallpaper and starter animal layer | Current snapshot capture; no desktop windows or account data |

`capture-screenshots.ps1` captures a new screen without changing state, but a live desktop capture may contain private information. Inspect and sanitize before staging. The raw current desktop capture, application-usage values, personal photos, power history, and media history remain outside the public package; only reviewed crops are published.
