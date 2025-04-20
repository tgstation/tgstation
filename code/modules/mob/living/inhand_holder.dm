//Generic system for picking up mobs.
//Currently works for head and hands.
/obj/item/clothing/head/mob_holder
	name = "bugged mob"
	desc = "Yell at coderbrush."
	icon = null
	icon_state = ""
	slot_flags = NONE
	/// Mob inside of us
	var/mob/living/held_mob
	/// True if we've started being destroyed
	var/destroying = FALSE

/obj/item/clothing/head/mob_holder/Initialize(mapload, mob/living/held_mob, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
	if(head_icon)
		worn_icon = head_icon
	if(worn_state)
		inhand_icon_state = worn_state
	if(lh_icon)
		lefthand_file = lh_icon
	if(rh_icon)
		righthand_file = rh_icon
	if(worn_slot_flags)
		slot_flags = worn_slot_flags
	update_weight_class(held_mob.held_w_class)
	insert_mob(held_mob)
	return ..()

/obj/item/clothing/head/mob_holder/Destroy()
	destroying = TRUE
	if(held_mob)
		release()
	return ..()

/obj/item/clothing/head/mob_holder/proc/insert_mob(mob/living/new_prisoner)
	if(!istype(new_prisoner))
		return FALSE
	new_prisoner.setDir(SOUTH)
	update_visuals(new_prisoner)
	held_mob = new_prisoner
	RegisterSignal(held_mob, COMSIG_QDELETING, PROC_REF(on_mob_deleted))
	new_prisoner.forceMove(src)
	name = new_prisoner.name
	desc = new_prisoner.desc
	return TRUE

/obj/item/clothing/head/mob_holder/proc/on_mob_deleted()
	SIGNAL_HANDLER
	held_mob = null
	if (isliving(loc))
		var/mob/living/holder = loc
		holder.temporarilyRemoveItemFromInventory(src, force = TRUE)
	qdel(src)

/obj/item/clothing/head/mob_holder/proc/update_visuals(mob/living/held_guy)
	appearance = held_guy.appearance

/obj/item/clothing/head/mob_holder/on_thrown(mob/living/carbon/user, atom/target)
	if((item_flags & ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You set [src] down gently on the ground."))
		release()
		return

	var/mob/living/throw_mob = held_mob
	release()
	return throw_mob

/obj/item/clothing/head/mob_holder/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(held_mob && isturf(loc))
		release()

/obj/item/clothing/head/mob_holder/proc/release(display_messages = TRUE)
	if(!held_mob)
		if(!destroying)
			qdel(src)
		return FALSE
	var/mob/living/released_mob = held_mob
	held_mob = null // stops the held mob from being release()'d twice.
	if(isliving(loc))
		var/mob/living/captor = loc
		if(display_messages)
			to_chat(captor, span_warning("[released_mob] wriggles free!"))
		captor.dropItemToGround(src)
	released_mob.forceMove(drop_location())
	released_mob.reset_perspective()
	released_mob.setDir(SOUTH)
	if(display_messages)
		released_mob.visible_message(span_warning("[released_mob] uncurls!"))
	if(!destroying)
		qdel(src)
	return TRUE

/obj/item/clothing/head/mob_holder/relaymove(mob/living/user, direction)
	release()

/obj/item/clothing/head/mob_holder/container_resist_act()
	release()

/obj/item/clothing/head/mob_holder/Exited(atom/movable/gone, direction)
	. = ..()
	if(held_mob == gone)
		release()

/obj/item/clothing/head/mob_holder/on_found(mob/finder)
	if(held_mob?.will_escape_storage())
		to_chat(finder, span_warning("\A [held_mob.name] pops out! "))
		finder.visible_message(span_warning("\A [held_mob.name] pops out of the container [finder] is opening!"), ignored_mobs = finder)
		release(display_messages = FALSE)
		return

/obj/item/clothing/head/mob_holder/drone/Initialize(mapload, mob/living/M, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
	//If we're not being put onto a drone, end it all
	if(!isdrone(M))
		return INITIALIZE_HINT_QDEL
	return ..()

/obj/item/clothing/head/mob_holder/drone/insert_mob(mob/living/new_prisoner)
	. = ..()
	if(!isdrone(new_prisoner))
		qdel(src)
		return
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball!"

/obj/item/clothing/head/mob_holder/drone/update_visuals(mob/living/contained)
	var/mob/living/basic/drone/drone = contained
	if(!drone)
		return ..()
	icon = 'icons/mob/silicon/drone.dmi'
	icon_state = "[drone.visualAppearance]_hat"

/obj/item/clothing/head/mob_holder/destructible

/obj/item/clothing/head/mob_holder/destructible/Destroy()
	if(held_mob)
		release(display_messages = TRUE, delete_mob = TRUE)
	return ..()

/obj/item/clothing/head/mob_holder/destructible/release(display_messages = TRUE, delete_mob = FALSE)
	if(delete_mob && held_mob)
		QDEL_NULL(held_mob)
	return ..()

/obj/item/clothing/head/mob_holder/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !held_mob) //overriden or mob missing
		return
	user.UnarmedAttack(held_mob, proximity_flag = TRUE, modifiers = modifiers)

/obj/item/clothing/head/mob_holder/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(. || !held_mob) // Another interaction was performed
		return
	tool.melee_attack_chain(user, held_mob, modifiers) //Interact with the mob with our tool
