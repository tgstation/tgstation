The following is the process to implement your own icon using an svg.

If you plan on making your own SVG, i suggest Inkscape, as it is free and pretty powerful for vector graphics.

1. Get whatever SVG you plan on using and put it in the ..\tgstation\tgui\packages\tgfont\icons folder.

2. In VScode, at the top, open "Terminal>New Terminal" and run this exact line of code without the quotes -> ".\BUILD.cmd tg-font"
    Wait till its all complete

3. In ..\tgstation\tgui\packages\tgfont\dist you will find 3 files that were generated, a .css, .eot and a .WOFF2 file. Copy and replace all 3 of these files to
    the following directory -> ..\tgstation\tgui\packages\tgfont\static

4. Then we run/double click the BUILD.bat file in ..\tgstation\

Now your SVG will be able to be used in the game.

NOTE; Be sure when you reference your icon that you prefix it with "tg-", otherwise it will not find it.

EXAMPLE;
    for svg named "prosthetic-leg.svg", you would reference it like so;
        vvvvvvvvvvvvvvvvvvvvvvvvvv
        icon = "tg-prosthetic-leg"
        ^^^^^^^^^^^^^^^^^^^^^^^^^^
    The process uses the main filename of your SVG as the icon name, so don't name it something stupid.

    Also try to get your SVG as simple as possible, the engine has trouble rendering SVGs that have a lot of little disconnected parts
