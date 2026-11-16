/mob/living/basic/pet
	abstract_type = /mob/living/basic/pet
	icon = 'icons/mob/simple/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	default_blood_volume = BLOOD_VOLUME_NORMAL
	basic_mob_flags = SENDS_DEATH_MOODLETS
	melee_damage_lower = 5
	melee_damage_upper = 5
	/// if the mob is protected from being renamed by collars.
	var/unique_pet = FALSE
