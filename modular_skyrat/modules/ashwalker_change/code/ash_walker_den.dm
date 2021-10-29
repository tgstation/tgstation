/obj/item/flashlight/lantern/ashwalker_variant
	name = "ash-corrupted lantern"
	uses_battery = FALSE
	light_range = 8

/obj/structure/lavaland/ash_walker/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/organ/regenerative_core) && user.mind.has_antag_datum(/datum/antagonist/ashwalker))
		var/obj/item/organ/regenerative_core/regen_core = I
		regen_core.preserved()
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		to_chat(user, span_notice("The tendril revitalizes [regen_core]."))
		return
	if(istype(I, /obj/item/flashlight/lantern))
		var/obj/item/flashlight/lantern/corrupted_lanter = I
		new /obj/item/flashlight/lantern/ashwalker_variant(get_turf(user))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		to_chat(user, span_notice("The tendril corrupts [corrupted_lanter]."))
		qdel(corrupted_lanter)
		return
	return ..()

/obj/structure/lavaland/ash_walker/attack_hand(mob/living/user, list/modifiers)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(istype(human_user.dna.species, /datum/species/lizard/ashwalker))
		return
	var/allow_transform = 0
	for(var/mob/living/carbon/human/count_human in range(1, src))
		if(istype(count_human.dna.species, /datum/species/lizard/ashwalker))
			allow_transform++
	if(allow_transform < 2)
		to_chat(human_user, span_warning("The tendril consumes a part of your flesh... you are not worthy!"))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		human_user.adjustBruteLoss(10)
		return
	else
		to_chat(human_user, span_warning("The tendril consumes a part of your flesh... you have a chance!"))
		var/choice = tgui_alert(human_user, "Become an Ashwalker? You will abandon your previous life and body.", "Major Choice", list("Yes", "No"))
		if(choice != "Yes")
			to_chat(human_user, span_warning("You will live long enough to regret this..."))
			playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
			human_user.adjustBruteLoss(10)
			return
		to_chat(human_user, span_notice("The tendril is pleased with your choice..."))
		human_user.unequip_everything()
		human_user.set_species(/datum/species/lizard/ashwalker)
		human_user.underwear = "Nude"
		human_user.update_body()
		human_user.mind.add_antag_datum(/datum/antagonist/ashwalker)
		ADD_TRAIT(human_user, TRAIT_PRIMITIVE, ROUNDSTART_TRAIT)
		playsound(src, 'sound/magic/demon_dies.ogg', 50, TRUE)
		meat_counter++
	return ..()
