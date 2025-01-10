Due to the fact browse_rsc can't create subdirectories, every time you update font-awesome you'll need to ensure the relative webfont references in all.min.css
are correct eg ../webfonts/fa-regular-400.ttf => fa-regular-400.ttf (or whatever you call it in asset datum)

Finally, removing brand related css. You can do this by formatting the css, removing them manually (or some regex?) and then minifying it.
