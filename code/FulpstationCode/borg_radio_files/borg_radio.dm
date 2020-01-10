/mob/living/silicon/robot/proc/borg_reset_radio()
	qdel(radio.keyslot)
	radio.keyslot = null


/obj/item/robot_module/proc/borg_set_radio(obj/item/encryptionkey/B, frequency)
	if(!loc || !istype(loc, /mob/living/silicon/robot)) //Sanity
		return

	var/mob/living/silicon/robot/R = loc
	R.radio.keyslot = new B
	R.radio.subspace_transmission = TRUE