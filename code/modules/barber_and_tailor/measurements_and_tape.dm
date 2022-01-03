/obj/item/measurements_paper
	name = "measurements"
	desc = "A set of measurements for John Nanotrasen."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "measurements"
	var/human_ref

/obj/item/clothing/neck/measuring_tape
	name = "measuring tape"
	desc = "Measuring tape for measuring people and getting their sizes."
	icon_state = "measuretape"

/obj/item/clothing/neck/measuring_tape/attack(mob/living/M, mob/living/user)
	if(!ishuman(M) || !isliving(user))
		return ..()
	if(user.combat_mode)
		return

	var/mob/living/carbon/human/measurement_target = M
	var/reference = REF(measurement_target)
	var/obj/item/measurements_paper/measurements = new(get_turf(measurement_target))
	measurements.human_ref = reference
	measurements.name = "[measurement_target]'s measurements"
	measurements.desc = "A set of measurements for [measurement_target]."
	to_chat(user, "You take down [measurement_target]'s measurements.")
