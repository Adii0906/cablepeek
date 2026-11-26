# CablePeek

A small Mac app that shows the USB-C link speed, or the charging power, at the screen edge next to the port when you plug something in. It stays for four seconds. Hover at that edge to see it again or eject the drive.

![Animation: a slow cable shows 480 Mb/s, a fast one 10 Gb/s, a charger 96 W, then the drive is ejected from the card](docs/cablepeek.gif)

*Illustration, not a screen recording. The texts are the ones the app shows.*

Download: https://cablepeek.pages.dev or the [latest release](../../releases/latest).

Or with Homebrew:

```sh
brew install --cask diegobruegger-prog/tap/cablepeek
```

## Good to know

- Apple Silicon, macOS 14 or later. Liquid Glass on macOS 26, frosted glass before that.
- **Not signed and not notarized.** The build has only an ad hoc signature, so macOS warns you on first launch. You can build it yourself instead.
- Tested on a MacBook Pro with M2 Pro. A user reported 0.1 working on a Mac mini with M4 Pro. Macs without `usb-c-port-number` are supported since 0.2, not yet confirmed on real hardware. Reports are welcome.
- SD card slot (since 0.5): shows the speed of the card's bus mode, for example 100 MB/s for UHS-I SDR104, with a card icon instead of the bolt. That is the limit of the slot connection, a slow card can be slower.
- Thunderbolt (since 0.5): shows the negotiated link speed, for example 40 Gb/s, when macOS reports it. Not yet confirmed with real Thunderbolt hardware. If it only says "Thunderbolt", the value could not be read. Reports are welcome.
- USB-A ports are not shown. On desktop Macs the card appears at the edge of the main screen.
- Link speed depends on cable, plug and device. If the cable has a readable chip, CablePeek uses it. If it cannot tell what is slow, it says so.
- Copy times are best-case estimates from the link speed, not measurements.
- It reads port information, drive names and the pointer position. It does not open your files.
- **Automatic updates are on by default.** Once a day, and shortly after launch, it asks GitHub for a newer release and installs it. Updates must carry an Ed25519 signature made with a key that is not on GitHub. Nothing about your Mac is sent, GitHub sees the request like any other. Turn it off in the menu. There is no other network use.
- It ejects only when you click the button and never forces an eject.

## Build

Needs the Xcode command line tools with a macOS 26 SDK.

```sh
./build.sh
open CablePeek.app
```

`CablePeek.app/Contents/MacOS/CablePeek --dump` prints what it reads, which is handy for bug reports. It includes your drive names.

## How it works

Everything comes from the IORegistry: the port position (`port-location`), the USB link speed (`UsbLinkSpeed`) the cable's e-marker data, the SD card mode (`AppleSDXCSlot`) and the Thunderbolt lane speed (`IOThunderboltPort`). Ejecting uses DiskArbitration. Charging power comes from `IOPortFeaturePowerSource`, contributed by [@MohammadAG](https://github.com/MohammadAG). Code comments are in German.

## Contributing

Bug reports and pull requests are welcome, see [CONTRIBUTING.md](CONTRIBUTING.md).

For deeper cable and power diagnostics, use [WhatCable](https://github.com/darrylmorley/whatcable).

Built with help from Claude. MIT license. Not affiliated with Apple.

CablePeek is free. If it helps, you can [buy me a coffee](https://buymeacoffee.com/diegoespresso).
