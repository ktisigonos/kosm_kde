# kosm_kde

KDE for kosm: the theme's colors as a KDE color scheme, and in kdeglobals, so KDE and Qt apps
using KDE's platform theme follow the kosmos, inside Plasma or not.

- `~/.local/share/color-schemes/kosm.colors`: the scheme, generated whole; Plasma's settings
  list it under the theme's `name` (`Theme.name`), or the kosmos' name when that is null. With
  the theme's `files = .per_kosmos` the file is named after the kosmos instead
  (`krystallos.dark.colors`), so each kosmos applied keeps its own scheme.
- `~/.config/kdeglobals`: a block between `# kosm:begin kosm` and `# kosm:end` at the end,
  selecting the scheme and holding its colors. Apps outside Plasma read their colors from
  kdeglobals itself, not from the scheme, and KDE reads the last value of a key, so the block
  wins over what the file says earlier. The rest of the file stays yours.

KDE rewrites kdeglobals whenever a KDE settings page saves it, dropping comments: the markers
go, the values stay, and the next apply writes a new block. Running apps read the colors at
start.

`from(theme)` puts windows, tooltips and the complementary set on black (white in light mode),
views sunken and buttons and headers raised (the theme's surface steps), selections on cyan
with readable text from the theme's `contrast.on`. Text is white, inactive text muted by the
theme's emphasis, links blue and visited ones purple, red, yellow and green for bad news,
warnings and good news, focus and hover outlines cyan. Focused title bars are raised.

## Fields

| Field | Default |
|---|---|
| `scheme` | `~/.local/share/color-schemes/{name}.colors`; `{name}` is `kosm`, or the kosmos' name with `files = .per_kosmos`; null writes no scheme |
| `files` | the theme's `files`: `.shared` or `.per_kosmos` |
| `globals` | `~/.config/kdeglobals`, created when missing; null leaves it alone |
| `name` | the theme's `name`, or the name kosm applies the kosmos under: the scheme's `Name`. `ColorScheme` is always the scheme file's name |
| `format` | the adapter's: `r,g,b` |
| `window`, `view`, `button`, `selection`, `tooltip`, `complementary`, `header`, `header_inactive` | each a set of `background_normal`, `background_alternate`, `foreground_normal`, `foreground_inactive`, `foreground_active`, `foreground_link`, `foreground_visited`, `foreground_negative`, `foreground_neutral`, `foreground_positive`, `decoration_focus`, `decoration_hover`; null keys are not written |
| `window_manager` | `[WM]`: `active_background`, `active_foreground`, `active_blend`, `inactive_background`, `inactive_foreground`, `inactive_blend` |
