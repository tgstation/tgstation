

// organ_internal.dm   --   /obj/item/organ



// Do I have a stake in my heart?
/mob/living/proc/AmStaked()
	var/obj/item/bodypart/BP = get_bodypart("chest")
	if (!BP)
		return 0
	for(var/obj/item/I in BP.embedded_objects)
		if (istype(I,/obj/item/stake/))
			return 1
	return 0



///obj/item/weapon/melee/stake
/obj/item/stake/
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
