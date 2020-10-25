/obj/effect/proc_holder/spell/pointed/barnyardcurse
	name = "Curse of the Barnyard"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."
	school = "transmutation"
	charge_type = "recharge"
	charge_max	= 150
	charge_counter = 0
	clothes_req = FALSE
	stat_allowed = FALSE
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = INVOCATION_SHOUT
	range = 7
	cooldown_min = 30
	ranged_mousepointer = 'icons/effects/mouse_pointers/barn_target.dmi'
	action_icon_state = "barn"
	active_msg = "You prepare to curse a target..."
	deactive_msg = "You dispel the curse..."
	/// List of mobs which are allowed to be a target of the spell
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/carbon/monkey))

/obj/effect/proc_holder/spell/pointed/barnyardcurse/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	var/mob/living/carbon/target = targets[1]
	if(target.anti_magic_check())
		to_chat(user, "<span class='warning'>The spell had no effect!</span>")
		target.visible_message("<span class='danger'>[target]'s face bursts into flames, which instantly burst outward, leaving [target] unharmed!</span>", \
						"<span class='danger'>Your face starts burning up, but the flames are repulsed by your anti-magic protection!</span>")
		return FALSE

	var/choice = pick(GLOB.cursed_animal_masks)
	var/obj/item/clothing/mask/magichead = new choice(get_turf(target))

	target.visible_message("<span class='danger'>[target]'s face bursts into flames, and a barnyard animal's head takes its place!</span>", \
						   "<span class='danger'>Your face burns up, and shortly after the fire you realise you have the face of a barnyard animal!</span>")
	if(!target.dropItemToGround(target.wear_mask))
		qdel(target.wear_mask)
	target.equip_to_slot_if_possible(magichead, ITEM_SLOT_MASK, 1, 1)
	target.flash_act()

/obj/effect/proc_holder/spell/pointed/barnyardcurse/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!is_type_in_typecache(target, compatible_mobs_typecache))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to curse [target]!</span>")
		return FALSE
	return TRUE
