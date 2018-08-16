// Micro Holders - Extends /obj/item/holder

/obj/item/holder/micro
	name = "micro"
	desc = "Another crewmember, small enough to fit in your hand."
	icon_state = "micro"
	slot_flags = SLOT_FEET | SLOT_HEAD | SLOT_ID
	w_class = 2
	item_icons = null 	// Override value from parent. We don't have magic sprites.
	pixel_y = 0			// Override value from parent.

/obj/item/holder/micro/examine(var/mob/user)
	for(var/mob/living/M in contents)
		M.examine(user)

/obj/item/holder/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(!Adjacent(usr)) return
	if(istype(M,/mob/living/silicon/ai)) return
	for(var/mob/living/carbon/human/O in contents)
		O.show_inv(usr)

/obj/item/holder/micro/attack_self(var/mob/living/user)
	for(var/mob/living/carbon/human/M in contents)
		M.help_shake_act(user)

/obj/item/holder/micro/update_state()
	// If any items have been dropped by contained mob, drop them to floor.
	for(var/obj/O in contents)
		O.forceMove(get_turf(src))
	..()
