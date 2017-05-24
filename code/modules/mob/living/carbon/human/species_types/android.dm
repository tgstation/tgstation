/datum/species/android
	name = "Android"
	id = "android"
	say_mod = "states"
	species_traits = list(NOBREATH,RESISTHOT,RESISTCOLD,RESISTPRESSURE,NOFIRE,NOBLOOD,VIRUSIMMUNE,RADIMMUNE,PIERCEIMMUNE,NOHUNGER,EASYLIMBATTACHMENT)
	meat = null
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = -20, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 0)
	damage_overlay_type = "synth"
	mutanttongue = /obj/item/organ/tongue/robot
	limbs_id = "synth"

/datum/species/android/on_species_gain(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE)

/datum/species/android/on_species_loss(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ORGANIC,FALSE, TRUE)
