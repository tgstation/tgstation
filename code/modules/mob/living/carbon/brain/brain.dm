/mob/living/carbon/brain
	var/obj/item/device/mmi/container = null

	New()
		spawn(1)
			var/datum/reagents/R = new/datum/reagents(1000)
			reagents = R
			R.my_atom = src

	say_understands(var/other)
		if (istype(other, /mob/living/silicon/ai))
			return 1
		if (istype(other, /mob/living/silicon/aihologram))
			return 1
		if (istype(other, /mob/living/silicon/robot))
			return 1
		if (istype(other, /mob/living/carbon/human))
			return 1
		return ..()

//	verb
//		body_jump()
//			set category = "Special Verbs"
//			set name = "Check on Original Body"


/obj/hud/proc/brain_hud(var/ui_style='screen1_old.dmi')
	src.station_explosion = new src.h_type( src )
	src.station_explosion.icon = 'station_explosion.dmi'
	src.station_explosion.icon_state = "start"
	src.station_explosion.layer = 20
	src.station_explosion.mouse_opacity = 0
	src.station_explosion.screen_loc = "1,3"

	src.blurry = new src.h_type( src )
	src.blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.blurry.name = "Blurry"
	src.blurry.icon = ui_style
	src.blurry.icon_state = "blurry"
	src.blurry.layer = 17
	src.blurry.mouse_opacity = 0

	src.druggy = new src.h_type( src )
	src.druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	src.druggy.name = "Druggy"
	src.druggy.icon = ui_style
	src.druggy.icon_state = "druggy"
	src.druggy.layer = 17
	src.druggy.mouse_opacity = 0

	mymob.blind = new /obj/screen( null )
	mymob.blind.icon = ui_style
	mymob.blind.icon_state = "black"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1 to 15,15"
	mymob.blind.layer = 0