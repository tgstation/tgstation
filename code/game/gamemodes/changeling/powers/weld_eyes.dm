//Ocular Shield: Grows a translucent filament over the eyes, protecting them from welding damage and gradually restoring eyesight.

/obj/effect/proc_holder/changeling/ocular_shield
	name = "Ocular Shield"
	desc = "Grows a translucent filament over our eyes, allowing our vision to be protected."
	helptext = "The filament will be obvious to anyone observing. It will protect our eyes from flashes and the glow of welding tools."
	chemical_cost = 10
	dna_cost = 1

/obj/effect/proc_holder/changeling/ocular_shield/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		user << "<span class='warning'>We must be in human form!</span>"
		return
	if(istype(user.glasses, /obj/item/clothing/glasses/changeling_ocular_shield))
		user.visible_message("<span class='warning'>The filament over [user]'s eyes suddenly slides into their skin!</span>", \
							 "<span class='notice'>We retract our ocular shield.</span>")
		qdel(user.glasses)
	else
		if(user.glasses)
			user << "<span class='warning'>[user.glasses] are obstructing our shield!</span>"
			return
		user.visible_message("<span class='warning'>A translucent filament suddenly appears over [user]'s eyes!</span>", \
							 "<span class='notice'>We project a shield over our eyes.</span>")
		user.equip_to_slot_or_del(new /obj/item/clothing/glasses/changeling_ocular_shield(user), slot_glasses)

/obj/item/clothing/glasses/changeling_ocular_shield
	name = "translucent filament"
	desc = "A covering of the eyes that protects and restores eyesight."
	icon_state = "ocular_shield"
	flash_protect = 2
	flags = NODROP
