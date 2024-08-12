/datum/smite/rattle_he_bones
	name = "Rattle me bones!"

/datum/smite/rattle_he_bones/effect(client/user, mob/living/target)
	. = ..()
	if(!is_species(target, /datum/species/skeleton))
		for(var/obj/item/W in target)
			target.dropItemToGround(W, TRUE)

		var/turf/epicenter = get_turf(target)
		epicenter.add_liquid(/datum/reagent/blood, 40, FALSE, 300)
		new /obj/effect/gibspawner/generic(target.drop_location(), target)
		new /obj/item/stack/sheet/animalhide/human(target.loc)
		target.set_species(/datum/species/skeleton)
		to_chat(target, span_warning("You feel RATTLED!"))
		playsound(target, 'monkestation/sound/misc/spinal_laugh.ogg', 80)
