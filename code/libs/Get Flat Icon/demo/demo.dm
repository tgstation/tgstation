
/* *********************************************************************
        _____      _     ______ _       _     _____
       / ____|    | |   |  ____| |     | |   |_   _|
      | |  __  ___| |_  | |__  | | __ _| |_    | |  ___ ___  _ __
      | | |_ |/ _ \ __| |  __| | |/ _` | __|   | | / __/ _ \| '_ \
      | |__| |  __/ |_  | |    | | (_| | |_   _| || (_| (_) | | | |
       \_____|\___|\__| |_|    |_|\__,_|\__| |_____\___\___/|_| |_|

                Created by David "DarkCampainger" Braun

            Released under the Unlicense (see Unlicense.txt)

                   Version 1.2 - August 27, 2013

             Please see 'Documentation.html' for reference

*///////////////////////////////////////////////////////////////////////

#define FILE_DIR demo

mob
	icon = '_flat_demoIcons.dmi'
	icon_state = "green"

	Login()
		// Testing image underlays
		underlays += image(icon='_flat_demoIcons.dmi',icon_state="red", dir = EAST)
		underlays += image(icon='_flat_demoIcons.dmi',icon_state="red", pixel_x = 32)
		underlays += image(icon='_flat_demoIcons.dmi',icon_state="red", pixel_x = -32)

		// Testing image overlays
		overlays += image(icon='_flat_demoIcons.dmi',icon_state="green", pixel_x = 32, pixel_y = -32)
		overlays += image(icon='_flat_demoIcons.dmi',icon_state="green", pixel_x = 32, pixel_y = 32)
		overlays += image(icon='_flat_demoIcons.dmi',icon_state="green", pixel_x = -32, pixel_y = -32)

		// Testing icon file overlays (defaults to mob's state)
		overlays += '_flat_demoIcons2.dmi'

		// Testing icon_state overlays (defaults to mob's icon)
		overlays += "white"

		// Testing dynamic icon overlays
		var/icon/I = icon('_flat_demoIcons.dmi', icon_state="aqua")
		I.Shift(NORTH,16,1)
		overlays+=I

		// Testing dynamic image overlays
		I=image(icon=I,pixel_x = -32, pixel_y = 32)
		overlays+=I

		// Testing object types (and layers)
		overlays+=/obj/overlayTest

		loc = locate (10,10,1)
	verb
		Browse_Icon()
			set name = "1. Browse Icon"

			// Generate the flattened icon
			var/icon/I = getFlatIcon(src)

			// Give it a name for the browser cache
			var/iconName = "[ckey(src.name)]_flattened.dmi"
			// Send the icon to src's browser cache
			src<<browse_rsc(I, iconName)
			// Display the icon in their browser
			src<<browse("<body bgcolor='#000000'><p><img src='[iconName]'></p></body>")

		Browse_Portrait()
			set name = "2. Browse Portrait"

			// Generate the flattened icon, facing south
			var/icon/I = getFlatIcon(src, SOUTH)

			// Give it a name for the browser cache
			var/iconName = "[ckey(src.name)]_flattened.dmi"
			// Send the icon to src's browser cache
			src<<browse_rsc(I, iconName)
			// Display the icon in their browser
			src<<browse("<body bgcolor='#000000'><p><img src='[iconName]'></p></body>")

		Output_Icon()
			set name = "3. Output Icon"
			src<<"\icon[getFlatIcon(src)]"
			src<<"-----------------------------------------"

		Output_Fullsize_Icon()
			set name = "4. Output Fullsize Icon"
			var/icon/I = getFlatIcon(src)
			src<<{"<img class="icon" src="\ref[fcopy_rsc(I)]" style="width: [I.Width()]px; height: [I.Height()]px;">"}
			src<<"-----------------------------------------"

		Label_Icon()
			set name = "5. Label Icon"

			// Generate the flattened icon
			var/icon/I = getFlatIcon(src)

			// Copy the file to the rsc manually
			I = fcopy_rsc(I)
			// Update the label to show it
			winset(src,"imageLabel","image='\ref[I]'");

		Add_Overlay()
			set name = "6. Add Overlay"
			var/image/I

			if(prob(50))
				// Create an overlay with a defined direction
				I = image(icon='_flat_demoIcons.dmi',icon_state="yellow",pixel_x = rand(-64,32), pixel_y = rand(-64,32), dir = pick(NORTH, SOUTH, EAST, WEST))
			else
				// Create an overlay that will inherit the direction
				I = image(icon='_flat_demoIcons.dmi',icon_state="yellow",pixel_x = rand(-64,32), pixel_y = rand(-64,32))

			overlays += I

		Stress_Test()
			set name = "7. Stress Test"
			for(var/i = 0 to 1000)
				// Passing '2' to the third parameter forces it to generate a new icon, even if it's already cached
				getFlatIcon(src,0,2)
				if(prob(5))
					Add_Overlay()
			Browse_Icon()

		Cache_Test()
			set name = "8. Cache Test"
			for(var/i = 0 to 1000)
				getFlatIcon(src)
			Browse_Icon()

obj/overlayTest
	icon = '_flat_demoIcons.dmi'
	icon_state = "blue"
	pixel_x = -24
	pixel_y = 24
	layer = TURF_LAYER // Should appear below the rest of the overlays

world
	view = "7x7"
	maxx = 20
	maxy = 20
	maxz = 1