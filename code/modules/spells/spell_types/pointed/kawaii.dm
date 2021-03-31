/obj/effect/proc_holder/spell/pointed/catcurse
	name = "Curse of the Feline"
	desc = "This spell dooms an unlucky(?) soul to become a kawaii catgirl. Nyaa~"
	school = "transmutation"
	charge_type = "recharge"
	charge_max = 150
	charge_counter = 0
	clothes_req = FALSE
	stat_allowed = FALSE
	invocation = "KA'WAI NE-KO N'YANYAN!"
	invocation_type = INVOCATION_SHOUT
	range = 7
	cooldown_min = 0
	ranged_mousepointer = 'icons/effects/mouse_pointers/override_machine_target.dmi'
	action_icon_state = "sacredflame"
	active_msg = "You prepare to curse a target..."
	deactive_msg = "You dispel the curse..."
	/// List of mobs which are allowed to be a target of the spell
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human))

/obj/effect/proc_holder/spell/pointed/catcurse/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	var/mob/living/carbon/target = targets[1]
	if(target.anti_magic_check())
		to_chat(user, "<span class='warning'>The spell had no effect!</span>")
		target.visible_message("<span class='danger'>[target]'s ears burst into flames, which instantly burst outward, leaving [target] unharmed!</span>", \
						"<span class='danger'>Your ears starts burning up, but the flames are repulsed by your anti-magic protection!</span>")
		return FALSE

	target.visible_message("<span class='danger'>[target]'s ears bursts into flames, and are replaced by cat ears!</span>", \
						   "<span class='danger'>Your ears burn up, and shortly after the fire you realise you have the ears and tail of a kawaii catgirl! Nya~!</span>")
	purrbation_apply(target)
	target.flash_act()

/obj/effect/proc_holder/spell/pointed/catcurse/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!is_type_in_typecache(target, compatible_mobs_typecache))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to curse [target]!</span>")
		return FALSE
	return TRUE
