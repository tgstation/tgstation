/mob/living/basic/pet
	icon = 'icons/mob/simple/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	blood_volume = BLOOD_VOLUME_NORMAL
	/// if the mob is protected from being renamed by collars.
	var/unique_pet = FALSE


/mob/living/basic/pet/death(gibbed)
	. = ..()
	add_memory_in_range(src, 7, /datum/memory/pet_died, deuteragonist = src) //Protagonist is the person memorizing it


