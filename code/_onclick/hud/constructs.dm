
/datum/hud/construct
	ui_style_icon = 'icons/mob/screen_construct.dmi'
	
/datum/hud/construct/New(mob/owner)
	..()
	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style_icon
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_pull_resist
	static_inventory += pull_icon
	
	healths = new /obj/screen/healths/construct()
	infodisplay += healths
	
/mob/living/simple_animal/hostile/construct/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/construct(src)
