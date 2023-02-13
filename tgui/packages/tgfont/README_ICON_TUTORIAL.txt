The following is the process to implement your own icon using an svg.

If you plan on making your own SVG, consider [Inkscape](https://inkscape.org/). It is free and pretty powerful for vector graphics.

1. Get whatever SVG you plan on using and put it in the `tgstation\tgui\packages\tgfont\icons` folder.

2. In VS Code, press Ctrl+Shift+B, and select "tgui: rebuild tgfont". Wait for it to comlpete.

Now your SVG will be able to be used in the game.

When you reference your icon that you prefix it with "tg-", otherwise it will not find it. For example, with an SVG named "prosthetic-leg.svg", you would reference it with `icon_state = "tg-prosthetic-leg"`.

Keep your SVG as simple as possible, the engine has trouble rendering SVGs that have a lot of little disconnected parts.
