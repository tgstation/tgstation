///Action from the inky tongue, from fish with the ink production trait.
/datum/action/cooldown/ink_spit
	name = "Spit Ink"
	desc = "Spits ink at someone, blinding them temporarily."
	button_icon = 'icons/hud/radial_fishing.dmi'
	button_icon_state = "oil"
	base_background_icon_state = "bg_default"
	active_background_icon_state = "bg_default_on"
	check_flags = AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	click_to_activate = TRUE
	unset_after_click = TRUE
	cooldown_time = 21 SECONDS

/datum/action/cooldown/ink_spit/IsAvailable(feedback = FALSE)
	var/mob/living/carbon/as_carbon = owner
	if(istype(as_carbon) && as_carbon.is_mouth_covered(ITEM_SLOT_MASK))
		return FALSE
	if(!isturf(owner.loc))
		return FALSE
	return ..()

/datum/action/cooldown/ink_spit/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("You prepare your ink glands. <B>Right-click to fire at a target!</B>"))
	build_all_button_icons()

/datum/action/cooldown/ink_spit/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	build_all_button_icons()

// We do this in InterceptClickOn() instead of Activate()
// because we use the click parameters for aiming the projectile
// (or something like that)
/datum/action/cooldown/ink_spit/InterceptClickOn(mob/living/clicker, params, atom/target)
	if(!LAZYACCESS(params2list(params), RIGHT_CLICK))
		return
	. = ..()
	if(!.)
		return

	var/modifiers = params2list(params)
	clicker.visible_message(
		span_danger("[clicker] spits ink!"),
		span_bold("You spit ink."),
	)
	var/obj/projectile/ink_spit/ink = new /obj/projectile/ink_spit(clicker.loc)
	ink.aim_projectile(target, clicker, modifiers)
	ink.firer = clicker
	ink.fire()
	playsound(clicker, 'sound/items/weapons/pierce.ogg', 20, TRUE, -1)
	clicker.newtonian_move(get_angle(target, clicker))
	StartCooldown()
	return TRUE

// Has to return TRUE, otherwise is skipped.
/datum/action/cooldown/ink_spit/Activate(atom/target)
	return TRUE
