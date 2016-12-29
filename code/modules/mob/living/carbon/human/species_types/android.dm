/datum/species/android
	name = "Android"
	id = "android"
	say_mod = "states"
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOFIRE,NOBLOOD,VIRUSIMMUNE,PIERCEIMMUNE,NOHUNGER,EASYLIMBATTACHMENT)
	meat = null
	damage_overlay_type = "synth"
	limbs_id = "synth"

/datum/species/android/on_species_gain(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ROBOTIC)

/datum/species/android/on_species_loss(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ORGANIC)