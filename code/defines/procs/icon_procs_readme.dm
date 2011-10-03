/*
IconProcs README

A BYOND library for manipulating icons and colors

by Lummox JR

version 1.0

The IconProcs library was made to make a lot of common icon operations much easier. BYOND's icon manipulation
routines are very capable but some of the advanced capabilities like using alpha transparency can be unintuitive to beginners.

CHANGING ICONS

Several new procs have been added to the /icon datum to simplify working with icons. To use them,
remember you first need to setup an /icon var like so:

var/icon/my_icon = new('iconfile.dmi')

icon/ChangeOpacity(amount = 1)
    A very common operation in DM is to try to make an icon more or less transparent. Making an icon more
    transparent is usually much easier than making it less so, however. This proc basically is a frontend
    for MapColors() which can change opacity any way you like, in much the same way that SetIntensity()
    can make an icon lighter or darker. If amount is 0.5, the opacity of the icon will be cut in half.
    If amount is 2, opacity is doubled and anything more than half-opaque will become fully opaque.
icon/GrayScale()
    Converts the icon to grayscale instead of a fully colored icon. Alpha values are left intact.
icon/ColorTone(tone)
    Similar to GrayScale(), this proc converts the icon to a range of black -> tone -> white, where tone is an
    RGB color (its alpha is ignored). This can be used to create a sepia tone or similar effect.
    See also the global ColorTone() proc.
icon/MinColors(icon)
    The icon is blended with a second icon where the minimum of each RGB pixel is the result.
    Transparency may increase, as if the icons were blended with ICON_ADD. You may supply a color in place of an icon.
icon/MaxColors(icon)
    The icon is blended with a second icon where the maximum of each RGB pixel is the result.
    Opacity may increase, as if the icons were blended with ICON_OR. You may supply a color in place of an icon.
icon/Opaque(background = "#000000")
    All alpha values are set to 255 throughout the icon. Transparent pixels become black, or whatever background color you specify.
icon/BecomeAlphaMask()
    You can convert a simple grayscale icon into an alpha mask to use with other icons very easily with this proc.
    The black parts become transparent, the white parts stay white, and anything in between becomes a translucent shade of white.
icon/AddAlphaMask(mask)
    The alpha values of the mask icon will be blended with the current icon. Anywhere the mask is opaque,
    the current icon is untouched. Anywhere the mask is transparent, the current icon becomes transparent.
    Where the mask is translucent, the current icon becomes more transparent.
icon/UseAlphaMask(mask, mode)
    Sometimes you may want to take the alpha values from one icon and use them on a different icon.
    This proc will do that. Just supply the icon whose alpha mask you want to use, and src will change
    so it has the same colors as before but uses the mask for opacity.

COLOR MANAGEMENT AND HSV

RGB isn't the only way to represent color. Sometimes it's more useful to work with a model called HSV, which stands for hue, saturation, and value.

    * The hue of a color describes where it is along the color wheel. It goes from red to yellow to green to
    cyan to blue to magenta and back to red.
    * The saturation of a color is how much color is in it. A color with low saturation will be more gray,
    and with no saturation at all it is a shade of gray.
    * The value of a color determines how bright it is. A high-value color is vivid, moderate value is dark,
    and no value at all is black.

Just as BYOND uses "#rrggbb" to represent RGB values, a similar format is used for HSV: "#hhhssvv". The hue is three
hex digits because it ranges from 0 to 0x5FF.

    * 0 to 0xFF - red to yellow
    * 0x100 to 0x1FF - yellow to green
    * 0x200 to 0x2FF - green to cyan
    * 0x300 to 0x3FF - cyan to blue
    * 0x400 to 0x4FF - blue to magenta
    * 0x500 to 0x5FF - magenta to red

Knowing this, you can figure out that red is "#000ffff" in HSV format, which is hue 0 (red), saturation 255 (as colorful as possible),
value 255 (as bright as possible). Green is "#200ffff" and blue is "#400ffff".

More than one HSV color can match the same RGB color.

Here are some procs you can use for color management:

ReadRGB(rgb)
    Takes an RGB string like "#ffaa55" and converts it to a list such as list(255,170,85). If an RGBA format is used
    that includes alpha, the list will have a fourth item for the alpha value.
hsv(hue, sat, val, apha)
    Counterpart to rgb(), this takes the values you input and converts them to a string in "#hhhssvv" or "#hhhssvvaa"
    format. Alpha is not included in the result if null.
ReadHSV(rgb)
    Takes an HSV string like "#100FF80" and converts it to a list such as list(256,255,128). If an HSVA format is used that
    includes alpha, the list will have a fourth item for the alpha value.
RGBtoHSV(rgb)
    Takes an RGB or RGBA string like "#ffaa55" and converts it into an HSV or HSVA color such as "#080aaff".
HSVtoRGB(hsv)
    Takes an HSV or HSVA string like "#080aaff" and converts it into an RGB or RGBA color such as "#ff55aa".
BlendRGB(rgb1, rgb2, amount)
    Blends between two RGB or RGBA colors using regular RGB blending. If amount is 0, the first color is the result;
    if 1, the second color is the result. 0.5 produces an average of the two. Values outside the 0 to 1 range are allowed as well.
    The returned value is an RGB or RGBA color.
BlendHSV(hsv1, hsv2, amount)
    Blends between two HSV or HSVA colors using HSV blending, which tends to produce nicer results than regular RGB
    blending because the brightness of the color is left intact. If amount is 0, the first color is the result; if 1,
    the second color is the result. 0.5 produces an average of the two. Values outside the 0 to 1 range are allowed as well.
    The returned value is an HSV or HSVA color.
BlendRGBasHSV(rgb1, rgb2, amount)
    Like BlendHSV(), but the colors used and the return value are RGB or RGBA colors. The blending is done in HSV form.
HueToAngle(hue)
    Converts a hue to an angle range of 0 to 360. Angle 0 is red, 120 is green, and 240 is blue.
AngleToHue(hue)
    Converts an angle to a hue in the valid range.
RotateHue(hsv, angle)
    Takes an HSV or HSVA value and rotates the hue forward through red, green, and blue by an angle from 0 to 360.
    (Rotating red by 60° produces yellow.) The result is another HSV or HSVA color with the same saturation and value
    as the original, but a different hue.
GrayScale(rgb)
    Takes an RGB or RGBA color and converts it to grayscale. Returns an RGB or RGBA string.
ColorTone(rgb, tone)
    Similar to GrayScale(), this proc converts an RGB or RGBA color to a range of black -> tone -> white instead of
    using strict shades of gray. The tone value is an RGB color; any alpha value is ignored.
*/

/*
Get Flat Icon DEMO by DarkCampainger

This is a test for the get flat icon proc, modified approprietly for icons and their states.
Probably not a good idea to run this unless you want to see how the proc works in detail.
mob
	icon = 'old_or_unused.dmi'
	icon_state = "green"

	Login()
		// Testing image underlays
		underlays += image(icon='old_or_unused.dmi',icon_state="red")
		underlays += image(icon='old_or_unused.dmi',icon_state="red", pixel_x = 32)
		underlays += image(icon='old_or_unused.dmi',icon_state="red", pixel_x = -32)

		// Testing image overlays
		overlays += image(icon='old_or_unused.dmi',icon_state="green", pixel_x = 32, pixel_y = -32)
		overlays += image(icon='old_or_unused.dmi',icon_state="green", pixel_x = 32, pixel_y = 32)
		overlays += image(icon='old_or_unused.dmi',icon_state="green", pixel_x = -32, pixel_y = -32)

		// Testing icon file overlays (defaults to mob's state)
		overlays += '_flat_demoIcons2.dmi'

		// Testing icon_state overlays (defaults to mob's icon)
		overlays += "white"

		// Testing dynamic icon overlays
		var/icon/I = icon('old_or_unused.dmi', icon_state="aqua")
		I.Shift(NORTH,16,1)
		overlays+=I

		// Testing dynamic image overlays
		I=image(icon=I,pixel_x = -32, pixel_y = 32)
		overlays+=I

		// Testing object types (and layers)
		overlays+=/obj/effect/overlayTest

		loc = locate (10,10,1)
	verb
		Browse_Icon()
			set name = "1. Browse Icon"
			// Give it a name for the cache
			var/iconName = "[ckey(src.name)]_flattened.dmi"
			// Send the icon to src's local cache
			src<<browse_rsc(getFlatIcon(src), iconName)
			// Display the icon in their browser
			src<<browse("<body bgcolor='#000000'><p><img src='[iconName]'></p></body>")

		Output_Icon()
			set name = "2. Output Icon"
			src<<"Icon is: \icon[getFlatIcon(src)]"

		Label_Icon()
			set name = "3. Label Icon"
			// Give it a name for the cache
			var/iconName = "[ckey(src.name)]_flattened.dmi"
			// Copy the file to the rsc manually
			var/icon/I = fcopy_rsc(getFlatIcon(src))
			// Send the icon to src's local cache
			src<<browse_rsc(I, iconName)
			// Update the label to show it
			winset(src,"imageLabel","image='\ref[I]'");

		Add_Overlay()
			set name = "4. Add Overlay"
			overlays += image(icon='old_or_unused.dmi',icon_state="yellow",pixel_x = rand(-64,32), pixel_y = rand(-64,32))

		Stress_Test()
			set name = "5. Stress Test"
			for(var/i = 0 to 1000)
				// The third parameter forces it to generate a new one, even if it's already cached
				getFlatIcon(src,0,2)
				if(prob(5))
					Add_Overlay()
			Browse_Icon()

		Cache_Test()
			set name = "6. Cache Test"
			for(var/i = 0 to 1000)
				getFlatIcon(src)
			Browse_Icon()

obj/effect/overlayTest
	icon = 'old_or_unused.dmi'
	icon_state = "blue"
	pixel_x = -24
	pixel_y = 24
	layer = TURF_LAYER // Should appear below the rest of the overlays

world
	view = "7x7"
	maxx = 20
	maxy = 20
	maxz = 1
*/