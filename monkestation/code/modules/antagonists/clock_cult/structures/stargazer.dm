//Stargazer structure
/obj/structure/destructible/clockwork/gear_base/stargazer
	name = "stargazer"
	desc = "A small pedestal, glowing with a divine energy."
	clockwork_desc = "Place a weapon upon it to provide special powers and abilities to the weapon."
	reebe_desc = "The energies of reebe are interfering with it's abilites, making it only be able to to enchant things at the lowest level."
	icon_state = "stargazer"
	base_icon_state = "stargazer"
	anchored = TRUE
	break_message = span_warning("The stargazer collapses.")
	///ref to our visual effect, migtht be able to make this just be an overlay
	var/obj/effect/stargazer_light/light_effect
	///how long is our use cooldown
	var/stargazer_cooldown = 3 MINUTES

/obj/structure/destructible/clockwork/gear_base/stargazer/Initialize(mapload)
	. = ..()
	light_effect = new /obj/effect/stargazer_light(get_turf(src))
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/gear_base/stargazer/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(!QDELETED(light_effect))
		QDEL_NULL(light_effect)
	return ..()

/obj/structure/destructible/clockwork/gear_base/stargazer/process()
	if(QDELETED(light_effect))
		return
	for(var/mob/living/viewing_mob in viewers(2, get_turf(src)))
		if(IS_CLOCK(viewing_mob))
			if(!light_effect.is_open)
				light_effect.open()
			return
	if(light_effect.is_open)
		light_effect.close()

/obj/structure/destructible/clockwork/gear_base/stargazer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!.)
		return

	if(anchored && !light_effect)
		light_effect = new /obj/effect/stargazer_light(get_turf(src))
	else if(light_effect)
		QDEL_NULL(light_effect)

/obj/structure/destructible/clockwork/gear_base/stargazer/attackby(obj/item/attacking_item, mob/living/user, params)
	if(user.istate)
		. = ..()
		return

	if(!anchored)
		to_chat(user, span_brass("You need to anchor \the [src] to the floor first."))
		return

	if(!enchanting_checks(attacking_item, user))
		return

	to_chat(user, span_brass("You begin placing \the [attacking_item] onto [src]."))
	if(do_after(user, 6 SECONDS, src))
		if(!enchanting_checks(attacking_item, user))
			return

		if(istype(attacking_item, /obj/item) && !istype(attacking_item, /obj/item/clothing) && attacking_item.force)
			upgrade_weapon(attacking_item, user)
			COOLDOWN_START(src, use_cooldown, stargazer_cooldown)
			return
		to_chat(user, span_brass("You cannot upgrade \the [attacking_item]."))

/obj/structure/destructible/clockwork/gear_base/stargazer/proc/enchanting_checks(obj/item/checked_item, mob/living/user)
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_brass("\The [src] is still warming up, it will be ready in [DisplayTimeText(COOLDOWN_TIMELEFT(src, use_cooldown))]."))
		return FALSE

	if(HAS_TRAIT(checked_item, TRAIT_STARGAZED))
		to_chat(user, span_brass("\The [checked_item] has already been enchanted!"))
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/gear_base/stargazer/proc/upgrade_weapon(obj/item/upgraded_item, mob/living/user)
	//Prevent re-enchanting
	ADD_TRAIT(upgraded_item, TRAIT_STARGAZED, STARGAZER_TRAIT)
	//Add a glowy colour
	upgraded_item.add_atom_colour(rgb(243, 227, 183), ADMIN_COLOUR_PRIORITY)
	//Pick a random effect
	var/static/list/possible_components
	if(!possible_components)
		possible_components = subtypesof(/datum/component/enchantment)
	upgraded_item.AddComponent(pick(possible_components))
	to_chat(user, span_notice("\The [upgraded_item] glows with a brilliant light!"))


//The visual effect of the stargazer
/obj/effect/stargazer_light
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "stargazer_closed"
	pixel_y = 10
	layer = ABOVE_OBJ_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 160
	///are we open or closed
	var/is_open = FALSE
	///ref to our timer if we have one
	var/active_timer

/obj/effect/stargazer_light/ex_act()
	return

/obj/effect/stargazer_light/Destroy(force)
	cancel_timer()
	return ..()

/obj/effect/stargazer_light/proc/finish_opening()
	icon_state = "stargazer_light"
	active_timer = null

/obj/effect/stargazer_light/proc/finish_closing()
	icon_state = "stargazer_closed"
	active_timer = null

/obj/effect/stargazer_light/proc/open()
	icon_state = "stargazer_opening"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, PROC_REF(finish_opening)), 2, TIMER_STOPPABLE | TIMER_UNIQUE)
	is_open = TRUE

/obj/effect/stargazer_light/proc/close()
	icon_state = "stargazer_closing"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, PROC_REF(finish_closing)), 2, TIMER_STOPPABLE | TIMER_UNIQUE)
	is_open = FALSE

/obj/effect/stargazer_light/proc/cancel_timer()
	if(active_timer)
		deltimer(active_timer)
