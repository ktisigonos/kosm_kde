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

- `~/.config/*rc` (`apps`): an app that picked a scheme of its own (Dolphin's
  `[UiSettings] ColorScheme`, Krita's `[theme] Theme`, which Krita picks by the scheme's
  `Name`) would ignore kdeglobals, so that choice becomes kosm's scheme. Only choices already
  in a file change; apps that never picked one follow kdeglobals anyway.

KDE rewrites kdeglobals whenever a KDE settings page saves it, dropping comments: the markers
go, the values stay, and the next apply writes a new block. Running apps read the colors at
start.

`from(theme)` puts windows, tooltips and the complementary set on the theme's background role,
views sunken and buttons and headers raised (the theme's surface steps), selections on the
accent with readable text from the theme's `contrast.on`. Text is the foreground role, inactive
text muted by the theme's emphasis, links the link role and visited ones purple, the error,
warning and success roles for bad news, warnings and good news, focus and hover outlines the
accent. Focused title bars are raised.

## Fields

| Field | Default |
|---|---|
| `scheme` | `~/.local/share/color-schemes/{name}.colors`; `{name}` is `kosm`, or the kosmos' name with `files = .per_kosmos`; null writes no scheme |
| `files` | the theme's `files`: `.shared` or `.per_kosmos` |
| `globals` | `~/.config/kdeglobals`, created when missing; null leaves it alone |
| `apps` | `~/.config/*rc`; null leaves the apps' own choices alone |
| `name` | the theme's `name`, or the name kosm applies the kosmos under: the scheme's `Name`. `ColorScheme` is always the scheme file's name |
| `icon_theme` | null: not written; else `[Icons] Theme` in the kdeglobals block, the icon theme's folder name |
| `format` | the adapter's: `r,g,b` |
| `window`, `view`, `button`, `selection`, `tooltip`, `complementary`, `header`, `header_inactive` | each a set of `background_normal`, `background_alternate`, `foreground_normal`, `foreground_inactive`, `foreground_active`, `foreground_link`, `foreground_visited`, `foreground_negative`, `foreground_neutral`, `foreground_positive`, `decoration_focus`, `decoration_hover`; null keys are not written |
| `window_manager` | `[WM]`: `active_background`, `active_foreground`, `active_blend`, `inactive_background`, `inactive_foreground`, `inactive_blend` |
