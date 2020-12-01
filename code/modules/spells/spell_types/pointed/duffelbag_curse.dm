/obj/effect/proc_holder/spell/pointed/duffelbagcurse
	name = "Duffelbag Curse"
	desc = "A spell that summons a duffelbag demon in the target's back, slowing him down and slowly eating him."
	school = "transmutation"
	charge_type = "recharge"
	charge_max	= 80
	charge_counter = 0
	clothes_req = FALSE
	stat_allowed = FALSE
	invocation = "BA'R A'RP!"
	invocation_type = INVOCATION_SHOUT
	range = 7
	cooldown_min = 20
	ranged_mousepointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'
	action_icon_state = "duffelbag_curse"
	active_msg = "You prepare to curse a target..."
	deactive_msg = "You dispel the curse..."
	/// List of mobs which are allowed to be a target of the spell
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/carbon/monkey))

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
						"<span class='danger'>Your feel something whispering in your back but it's sent to the shadow realm!</span>")
		return FALSE

	var/obj/item/storage/backpack/duffelbag/cursed/C = new get_turf(target)

	target.visible_message("<span class='danger'>A stinky duffelbag appears in [target]'s back!</span>", \
						   "<span class='danger'>You feel something attaching itself to your back!</span>")
	if(!target.dropItemToGround(target.back))
		qdel(target.back)
	target.equip_to_slot_if_possible(C, ITEM_SLOT_BACK, 1, 1)
	target.flash_act()

/obj/effect/proc_holder/spell/pointed/duffelbagcurse/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!is_type_in_typecache(target, compatible_mobs_typecache))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to curse [target]!</span>")
		return FALSE
	return TRUE
