/obj/item/weapon/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = null
	volume = 50
	apply_type = TOUCH
	apply_method = "apply"

/obj/item/weapon/reagent_containers/pill/patch/New()
	..()
	icon_state = "bandaid" // thanks inheritance

/obj/item/weapon/reagent_containers/pill/patch/attack(mob/living/carbon/human/M, mob/user)
	if(istype(M))
		var/obj/item/organ/limb/affected = canconsume(M, user)
		if(affected && affected.status == ORGAN_ORGANIC)
			user.visible_message("<span class='notice'>[user] manages to [apply_method] [src] on [M].</span>", \
							"<span class='notice'>You [apply_method] [src].</span>")
			user.unEquip(src)
			loc = affected
			SSobj.processing.Add(src)

/obj/item/weapon/reagent_containers/pill/patch/process()
	if(reagents.total_volume)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_touch_apply(loc)
	else
		SSobj.processing.Remove(src)
		qdel(src)

/obj/item/weapon/reagent_containers/pill/patch/afterattack(obj/target, mob/user , proximity)
	return

/obj/item/weapon/reagent_containers/pill/patch/canconsume(mob/living/carbon/human/target, mob/user)
	if(istype(target))
		var/obj/item/organ/limb/affected = target.get_organ(check_zone(user.zone_sel.selecting))
		var/cover = target.check_covered(affected)
		if(!cover)
			var/patches_counter
			for(var/obj/item/weapon/reagent_containers/pill/patch/P in affected)
				patches_counter++
			if(affected.max_patches <= patches_counter)
				user << "<span class='alert'>Theres no free space left on this body part for more patches.</span>"
			else
				return affected
		else
			user << "<span class='alert'>You cant apply [src], remove the [cover] first.</span>"


/obj/item/weapon/reagent_containers/pill/patch/styptic
	name = "brute patch"
	desc = "Helps with brute injuries."
	list_reagents = list("styptic_powder" = 50)

/obj/item/weapon/reagent_containers/pill/patch/silver_sulf
	name = "burn patch"
	desc = "Helps with burn injuries."
	list_reagents = list("silver_sulfadiazine" = 50)
