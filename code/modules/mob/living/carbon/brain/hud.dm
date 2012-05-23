/obj/hud/proc/brain_hud(var/ui_style='screen1_old.dmi')

	//ui_style='screen1_old.dmi' //Overriding the parameter. Only this UI style is acceptable with the 'sleek' layout.

	blurry = new h_type( src )
	blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blurry.name = "Blurry"
	blurry.icon = ui_style
	blurry.icon_state = "blurry"
	blurry.layer = 17
	blurry.mouse_opacity = 0

	druggy = new h_type( src )
	druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	druggy.name = "Druggy"
	druggy.icon = ui_style
	druggy.icon_state = "druggy"
	druggy.layer = 17
	druggy.mouse_opacity = 0

	mymob.blind = new /obj/screen( null )
	mymob.blind.icon = ui_style
	mymob.blind.icon_state = "blackanimate"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1 to 15,15"
	mymob.blind.layer = 0