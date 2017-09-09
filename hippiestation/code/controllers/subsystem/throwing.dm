/atom/movable/var/unlimitedthrow = FALSE

/obj/var/prev_throwforce

/obj/item/var/specthrow_sound
/obj/item/var/list/specthrow_msg
/obj/item/var/specthrow_forcemult = 1.0
/obj/item/var/specthrow_maxwclass = WEIGHT_CLASS_SMALL

/proc/check_reset_throwforce(atom/movable/AM)
	if(istype(AM, /obj))
		var/obj/I = AM
		if(I.prev_throwforce)
			I.throwforce = I.prev_throwforce
			I.prev_throwforce = null
