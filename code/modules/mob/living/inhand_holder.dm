//Generic system for picking up mobs.
//Currently works for head and hands.
/obj/item/clothing/head/mob_holder
	name = "bugged mob"
	desc = "Yell at coderbrush."
	icon = null
	icon_state = ""
	var/mob/living/held_mob
	var/can_head = FALSE

/obj/item/clothing/head/mob_holder/Initialize(mapload, mob/living/M, _worn_state, head_icon, lh_icon, rh_icon, _can_head_override = FALSE)
	. = ..()
	if(_can_head_override)
		can_head = _can_head_override
	if(head_icon)
		alternate_worn_icon = head_icon
	if(_worn_state)
		item_state = _worn_state
	if(lh_icon)
		lefthand_file = lh_icon
	if(rh_icon)
		righthand_file = rh_icon
	if(!can_head)
		slot_flags = NONE
	deposit(M)

/obj/item/clothing/head/mob_holder/Destroy()
	if(held_mob)
		release()
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
	release()

/obj/item/clothing/head/mob_holder/proc/release(del_on_release = TRUE)//set true when not relying on DROPDEL_1
	if(held_mob)
		var/mob/living/m = held_mob
		m.forceMove(get_turf(m))
		m.reset_perspective()
		m.setDir(SOUTH)
		held_mob = null
	if(isliving(loc))
		var/mob/living/L = loc
		L.dropItemToGround(src)
	if(del_on_release)
		qdel(src)

/obj/item/clothing/head/mob_holder/relaymove(mob/user)
	release(TRUE)

/obj/item/clothing/head/mob_holder/container_resist()
	release(TRUE)