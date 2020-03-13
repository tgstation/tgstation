///Hud type with targetting dol and a nutrition bar
/datum/hud/ooze/New(mob/living/owner)
	..()
	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.hud = src
	zone_select.update_icon()
	static_inventory += zone_select

///Sets the right hud type for the ooze
/mob/living/simple_animal/hostile/ooze/create_mob_hud()
	hud_type = /datum/hud/ooze
