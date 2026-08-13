# Homebrew tap for airules

This is the official Homebrew tap for
[airules](https://github.com/jstruk/airules), the unified local instruction
manager for AI coding assistants.

## Install

```sh
brew install --cask jstruk/airules/airules
```

This installs `airules.app` in Applications and makes the same bundled
executable available as the `airules` terminal command. The app supports Apple
silicon and Intel Macs running macOS 13 or newer.

airules is currently unsigned and not notarized. If macOS blocks the first
launch, open Applications in Finder, Control-click **airules**, choose
**Open**, then confirm **Open** once. Future launches work normally.

If the older source-built Formula is already installed, migrate with:

```sh
brew uninstall --formula airules
brew install --cask jstruk/airules/airules
```

## Launch

```sh
airules
```

A bare `airules` command opens or focuses the desktop workbench. The same
executable also provides the `airules init` and `airules sync` CLI workflows.

## Upgrade

```sh
brew update
brew upgrade --cask airules
```

## Uninstall

```sh
brew uninstall --cask airules
```

Uninstalling leaves the user's configuration and synchronized project files in
place.
