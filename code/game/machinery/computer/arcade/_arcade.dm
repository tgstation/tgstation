/obj/machinery/computer/arcade
	name = "\proper the arcade cabinet which shouldn't exist"
	desc = "This arcade cabinet has no games installed, and in fact, should not exist. \
		Report the location of this machine to your local diety."
	icon_state = "arcade"
	icon_keyboard = null
	icon_screen = "invaders"
	light_color = LIGHT_COLOR_GREEN
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON|INTERACT_MACHINE_REQUIRES_LITERACY
	projectiles_pass_chance = 0 // I guess gambling can save your life huh?

	///If set, will dispense these as prizes instead of the default GLOB.arcade_prize_pool
	///Like prize pool, it must be a list of the prize and the weight of being selected.
	var/list/prize_override

/obj/machinery/computer/arcade/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stack/arcadeticket))
		var/obj/item/stack/arcadeticket/tickets = tool
		if(!tickets.use(2))
			balloon_alert(user, "need 2 tickets!")
			return ITEM_INTERACT_BLOCKING

		prizevend(user)
		balloon_alert(user, "prize claimed")
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/key/displaycase) || istype(tool, /obj/item/access_key))
		var/static/list/radial_menu_options
		if(!radial_menu_options)
			radial_menu_options = list(
				"Reset Cabinet" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_reset"),
				"Cancel" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_close"),
			)
		var/radial_reset_menu = show_radial_menu(user, src, radial_menu_options, require_near = TRUE)
		if(radial_reset_menu != "Reset Cabinet")
			return ITEM_INTERACT_BLOCKING
		playsound(loc, 'sound/items/rattling_keys.ogg', 25, TRUE)
		if(!do_after(user, 10 SECONDS, src))
			return ITEM_INTERACT_BLOCKING
		balloon_alert(user, "cabinet reset")
		reset_cabinet(user)
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/computer/arcade/screwdriver_act(mob/living/user, obj/item/I)
	//you can't stop playing when you start.
	if(obj_flags & EMAGGED)
		return ITEM_INTERACT_BLOCKING
	return ..()

///Performs a factory reset of the cabinet and wipes all its stats.
/obj/machinery/computer/arcade/proc/reset_cabinet(mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	obj_flags &= ~EMAGGED
	SStgui.update_uis(src)

/obj/machinery/computer/arcade/emp_act(severity)
	. = ..()
	if((machine_stat & (NOPOWER|BROKEN)) || (. & EMP_PROTECT_SELF))
		return

	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(var/i = num_of_prizes; i > 0; i--)
		if(prize_override)
			empprize = pick_weight(prize_override)
		else
			empprize = pick_weight(GLOB.arcade_prize_pool)
		new empprize(loc)
	explosion(src, devastation_range = -1, light_impact_range = 1 + num_of_prizes, flame_range = 1 + num_of_prizes)

///Dispenses the proper prizes and gives them a positive mood event. If valid, has a small chance to give a pulse rifle.
/obj/machinery/computer/arcade/proc/prizevend(mob/living/user, prizes = 1)
	SEND_SIGNAL(src, COMSIG_ARCADE_PRIZEVEND, user, prizes)
	if(user.mind?.get_skill_level(/datum/skill/gaming) >= SKILL_LEVEL_LEGENDARY && HAS_TRAIT(user, TRAIT_GAMERGOD))
		visible_message(span_notice("[user] inputs an intense cheat code!"),\
		span_notice("You hear a flurry of buttons being pressed."))
		say("CODE ACTIVATED: EXTRA PRIZES.")
		prizes *= 2
	for(var/i in 1 to prizes)
		user.add_mood_event("arcade", /datum/mood_event/arcade)
		if(prob(0.0001)) //1 in a million
			new /obj/item/gun/energy/pulse/prize(get_turf(src))
			visible_message(span_notice("[src] dispenses.. woah, a gun! Way past cool."), span_notice("You hear a chime and a shot."))
			user.client.give_award(/datum/award/achievement/misc/pulse, user)
			continue

		var/prizeselect
		if(prize_override)
			prizeselect = pick_weight(prize_override)
		else
			prizeselect = pick_weight(GLOB.arcade_prize_pool)
		var/atom/movable/the_prize = new prizeselect(get_turf(src))
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
		visible_message(span_notice("[src] dispenses [the_prize]!"), span_notice("You hear a chime and a clunk."))
