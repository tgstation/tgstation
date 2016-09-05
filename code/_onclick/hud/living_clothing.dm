/datum/hud/living_clothing/New(mob/living/simple_animal/clothing/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()
	var/obj/screen/using

	using = new /obj/screen/act_intent()
	using.icon = ui_style
	using.icon_state = mymob.a_intent
	using.screen_loc = ui_acti
	static_inventory += using
	action_intent = using

	blooddisplay = new()
	infodisplay += blooddisplay

	zone_select = new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.update_icon(mymob)
	static_inventory += zone_select

	mymob.client.screen = list()

	using = new /obj/screen/resist()
	using.icon = ui_style
	using.screen_loc = ui_pull_resist

/mob/living/simple_animal/clothing/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/living_clothing(src, ui_style2icon(client.prefs.UI_style))
