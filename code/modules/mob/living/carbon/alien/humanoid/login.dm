/mob/living/carbon/alien/humanoid/Login()
	..()

	update_hud()

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == DEAD)
		src.verbs += /client/proc/ghost

	return
	/*
	src.throw_icon = new /obj/screen(null)
	src.oxygen = new /obj/screen( null )
	src.i_select = new /obj/screen( null )
	src.m_select = new /obj/screen( null )
	src.toxin = new /obj/screen( null )
	src.internals = new /obj/screen( null )
	src.mach = new /obj/screen( null )
	src.fire = new /obj/screen( null )
	src.bodytemp = new /obj/screen( null )
	src.healths = new /obj/screen( null )
	src.pullin = new /obj/screen( null )
	src.blind = new /obj/screen( null )
	src.flash = new /obj/screen( null )
	src.hands = new /obj/screen( null )
	src.sleep = new /obj/screen( null )
	src.rest = new /obj/screen( null )
	src.zone_sel = new /obj/screen/zone_sel( null )

	regenerate_icons()

	src.mach.dir = NORTH

	src.throw_icon.icon_state = "act_throw_off"
	src.oxygen.icon_state = "oxy0"
	src.i_select.icon_state = "selector"
	src.m_select.icon_state = "selector"
	src.toxin.icon_state = "toxin0"
	src.bodytemp.icon_state = "temp1"
	src.internals.icon_state = "internal0"
	src.mach.icon_state = null
	src.fire.icon_state = "fire0"
	src.healths.icon_state = "health0"
	src.pullin.icon_state = "pull0"
	src.blind.icon_state = "black"
	src.hands.icon_state = "hand"
	src.flash.icon_state = "blank"
	src.sleep.icon_state = "sleep0"
	src.rest.icon_state = "rest0"

	src.hands.dir = NORTH

	src.throw_icon.name = "throw"
	src.oxygen.name = "oxygen"
	src.i_select.name = "intent"
	src.m_select.name = "moving"
	src.toxin.name = "toxin"
	src.bodytemp.name = "body temperature"
	src.internals.name = "internal"
	src.mach.name = "Reset Machine"
	src.fire.name = "fire"
	src.healths.name = "health"
	src.pullin.name = "pull"
	src.blind.name = " "
	src.hands.name = "hand"
	src.flash.name = "flash"
	src.sleep.name = "sleep"
	src.rest.name = "rest"

	src.throw_icon.screen_loc = "9,1"
	src.oxygen.screen_loc = "15,12"
	src.i_select.screen_loc = "14:-11,15"
	src.m_select.screen_loc = "14:-11,14"
	src.toxin.screen_loc = "15,10"
	src.internals.screen_loc = "15,14"
	src.mach.screen_loc = "14,1"
	src.fire.screen_loc = "15,8"
	src.bodytemp.screen_loc = "15,6"
	src.healths.screen_loc = "15,5"
	src.sleep.screen_loc = "15,3"
	src.rest.screen_loc = "15,2"
	src.pullin.screen_loc = "15,1"
	src.hands.screen_loc = "1,3"
	src.blind.screen_loc = "1,1 to 15,15"
	src.flash.screen_loc = "1,1 to 15,15"

	src.blind.layer = 0
	src.flash.layer = 17

	src.client.screen.len = null
	src.client.screen -= list( src.throw_icon, src.zone_sel, src.oxygen, src.i_select, src.m_select, src.toxin, src.bodytemp, src.internals, src.fire, src.hands, src.healths, src.pullin, src.blind, src.flash, src.rest, src.sleep, src.mach )
	src.client.screen += list( src.throw_icon, src.zone_sel, src.oxygen, src.i_select, src.m_select, src.toxin, src.bodytemp, src.internals, src.fire, src.hands, src.healths, src.pullin, src.blind, src.flash, src.rest, src.sleep, src.mach )
	src.client.screen -= src.hud_used.adding
	src.client.screen += src.hud_used.adding

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /client/proc/ghost

	return

*/