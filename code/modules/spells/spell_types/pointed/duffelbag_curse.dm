/obj/effect/proc_holder/spell/pointed/duffelbagcurse
	name = "Duffel Bag Curse"
	desc = "A spell that summons a duffel bag demon on the target, slowing them down and slowly eating them."
	school = "transmutation"
	charge_type = "recharge"
	charge_max	= 150
	charge_counter = 0
	clothes_req = FALSE
	stat_allowed = FALSE
	invocation = "BA'R A'RP!"
	invocation_type = INVOCATION_SHOUT
	range = 7
	cooldown_min = 50
	ranged_mousepointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'
	action_icon_state = "duffelbag_curse"
	active_msg = "You prepare to curse a target..."
	deactive_msg = "You dispel the curse..."
	/// List of mobs which are allowed to be a target of the spell
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human))

/obj/effect/proc_holder/spell/pointed/duffelbagcurse/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	var/mob/living/carbon/target = targets[1]
	if(target.anti_magic_check())
		to_chat(user, "<span class='warning'>The spell had no effect!</span>")
		target.visible_message("<span class='danger'>[target] was unaffected by the curse!</span>", \
						"<span class='danger'>You feel something whispering behind your back, but it's sent to the shadow realm before it can do anything to you!</span>")
		return FALSE

	var/obj/item/storage/backpack/duffelbag/cursed/C = new get_turf(target)

	target.visible_message("<span class='danger'>A stinky duffel bag appears on you!</span>", \
						   "<span class='danger'>You feel something attaching itself to you!</span>")
	target.flash_act()
	if(target.dropItemToGround(target.back))
		target.equip_to_slot_if_possible(C, ITEM_SLOT_BACK, 1, 1)
	else
		if(!target.put_in_hands(C))
			target.dropItemToGround(target.get_inactive_held_item())
			if(!target.put_in_hands(C))
				target.dropItemToGround(target.get_active_held_item())
				target.put_in_hands(C)
/obj/effect/proc_holder/spell/pointed/duffelbagcurse/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!is_type_in_typecache(target, compatible_mobs_typecache))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to curse [target]!</span>")
		return FALSE
	return TRUE
