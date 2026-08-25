# V2 prototype asset sources

- `turntable-deck-cc0.svg`, `turntable-tonearm-cc0.svg` — legacy CC0 path groups extracted from “Turntable” on [SVG Repo](https://www.svgrepo.com/svg/2471/turntable). They are retained only as a recoverable reference and are no longer rendered by PLAYER-01A.
- `vinyl-record-public-domain.png` — “Vinyl Record” by Andrikkos from [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Vinyl_Record.png), released into the public domain by its author. The local transparent PNG supplies realistic grooves and reflections while remaining an independently rotating playback layer.
- `turntable-tonearm-photoreal.png` — legacy three-quarter-view OpenAI ImageGen render retained only for visual comparison; it is no longer rendered because perspective distortion made the parked state look upright.
- `turntable-tonearm-topdown-v2.png` — project-local transparent product render generated with OpenAI ImageGen for PLAYER-01A. It uses a strict 90-degree top plan view so the pivot, counterweight, arm, headshell, and stylus can rotate as one mechanically coherent layer between playback and parked states; no third-party asset license or runtime network dependency is introduced.
- `web-eq-playing.svg` — exact local reuse of Scopify Web's `apps/web/resources/eq-playing.svg` playback indicator so playlist active-row feedback remains cross-platform consistent.
