//Generic system for picking up mobs.
//Currently works for head and hands.
/obj/item/clothing/head/mob_holder
	name = "bugged mob"
	desc = "Yell at coderbrush."
	icon = null
	icon_state = ""
	slot_flags = NONE
	var/mob/living/held_mob
	var/destroying = FALSE

/obj/item/clothing/head/mob_holder/Initialize(mapload, mob/living/M, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
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
	atom_size = M.held_atom_size
	deposit(M)
	. = ..()

/obj/item/clothing/head/mob_holder/Destroy()
	destroying = TRUE
	if(held_mob)
		release(FALSE)
	return ..()

/obj/item/clothing/head/mob_holder/proc/deposit(mob/living/L)
	if(!istype(L))
		return FALSE
	L.setDir(SOUTH)
	update_visuals(L)
	held_mob = L
	L.forceMove(src)
	name = L.name
	desc = L.desc
	return TRUE

/obj/item/clothing/head/mob_holder/proc/update_visuals(mob/living/L)
	appearance = L.appearance

/obj/item/clothing/head/mob_holder/dropped()
	..()
	if(held_mob && isturf(loc))
		release()

/obj/item/clothing/head/mob_holder/proc/release(del_on_release = TRUE, display_messages = TRUE)
	if(!held_mob)
		if(del_on_release && !destroying)
			qdel(src)
		return FALSE
	var/mob/living/released_mob = held_mob
	held_mob = null // stops the held mob from being release()'d twice.
	if(isliving(loc))
		var/mob/living/L = loc
		if(display_messages)
			to_chat(L, span_warning("[released_mob] wriggles free!"))
		L.dropItemToGround(src)
	released_mob.forceMove(drop_location())
	released_mob.reset_perspective()
	released_mob.setDir(SOUTH)
	if(display_messages)
		released_mob.visible_message(span_warning("[released_mob] uncurls!"))
	if(del_on_release && !destroying)
		qdel(src)
	return TRUE

/obj/item/clothing/head/mob_holder/relaymove(mob/living/user, direction)
	release()

/obj/item/clothing/head/mob_holder/container_resist_act()
	release()

/obj/item/clothing/head/mob_holder/on_found(mob/finder)
	if(held_mob?.will_escape_storage())
		to_chat(finder, span_warning("\A [held_mob.name] pops out! "))
		finder.visible_message(span_warning("\A [held_mob.name] pops out of the container [finder] is opening!"), ignored_mobs = finder)
		release(TRUE, FALSE)
		return

/obj/item/clothing/head/mob_holder/drone/Initialize(mapload, mob/living/M, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
	//If we're not being put onto a drone, end it all
	if(!isdrone(M))
		return INITIALIZE_HINT_QDEL
	return ..()

/obj/item/clothing/head/mob_holder/drone/deposit(mob/living/L)
	. = ..()
	if(!isdrone(L))
		qdel(src)
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball!"

/obj/item/clothing/head/mob_holder/drone/update_visuals(mob/living/L)
	var/mob/living/simple_animal/drone/D = L
	if(!D)
		return ..()
	icon = 'icons/mob/drone.dmi'
	icon_state = "[D.visualAppearance]_hat"

/obj/item/clothing/head/mob_holder/destructible

/obj/item/clothing/head/mob_holder/destructible/Destroy()
	if(held_mob)
		release(FALSE, TRUE, TRUE)
	return ..()

/obj/item/clothing/head/mob_holder/destructible/release(del_on_release = TRUE, display_messages = TRUE, delete_mob = FALSE)
	if(delete_mob && held_mob)
		QDEL_NULL(held_mob)
	return ..()
