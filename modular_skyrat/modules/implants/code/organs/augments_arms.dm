/obj/item/melee/implantarmblade
	name = "implanted arm blade"
	desc = "A long, sharp, mantis-like blade implanted into someones arm. Cleaves through flesh like its particularly strong butter."
	icon = 'modular_skyrat/modules/implants/icons/item/implanted_blade.dmi'
	righthand_file = 'modular_skyrat/modules/implants/icons/mob/implanted_blade_righthand.dmi'
	lefthand_file = 'modular_skyrat/modules/implants/icons/mob/implanted_blade_lefthand.dmi'
	icon_state = "mantis_blade"
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 25
	armour_penetration = 20
	item_flags = NEEDS_PERMIT //Beepers gets angry if you get caught with this.
	hitsound = 'modular_skyrat/master_files/sound/weapons/bloodyslice.ogg'

/obj/item/melee/implantarmblade/energy
	name = "energy arm blade"
	desc = "A long mantis-like blade made entirely of blazing-hot energy. Stylish and EXTRA deadly!"
	icon_state = "energy_mantis_blade"
	force = 30
	armour_penetration = 10 //Energy isn't as good at going through armor as it is through flesh alone.
	hitsound = 'sound/weapons/blade1.ogg'

/obj/item/organ/cyberimp/arm/armblade
	name = "arm blade implant"
	desc = "An integrated blade implant designed to be installed into a persons arm. Stylish and deadly; Although, being caught with this without proper permits is sure to draw unwanted attention."
	contents = newlist(/obj/item/melee/implantarmblade)
	icon = 'modular_skyrat/modules/implants/icons/item/implanted_blade.dmi'
	icon_state = "mantis_blade"

/obj/item/organ/cyberimp/arm/armblade/emag_act()
	. = ..()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(usr, "<span class='notice'>You unlock [src]'s integrated energy arm blade! You madman!</span>")
	items_list += new /obj/item/melee/implantarmblade/energy(src)
	return TRUE

/obj/item/organ/cyberimp/arm/hacker
	name = "hacking arm implant"
	desc = "An small arm implant containing an advanced screwdriver, wirecutters, and multitool designed for engineers and on-the-field machine modification. Actually legal, despite what the name may make you think."
	icon ='icons/obj/items_cyborg.dmi'
	icon_state = "multitool_cyborg"
	contents = newlist(/obj/item/screwdriver/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool/abductor/implant)

/obj/item/organ/cyberimp/arm/botany
	name = "botany arm implant"
	desc = "A rather simple arm implant containing tools used in gardening and botanical research."
	contents = newlist(/obj/item/cultivator, /obj/item/shovel/spade, /obj/item/hatchet, /obj/item/gun/energy/floragun, /obj/item/plant_analyzer, /obj/item/reagent_containers/glass/beaker/plastic, /obj/item/storage/bag/plants, /obj/item/storage/bag/plants/portaseeder)

/obj/item/multitool/abductor/implant
	name = "multitool"
	desc = "An optimized, highly advanced stripped-down multitool able to interface with electronics far better than its standard counterpart."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "multitool_cyborg"
