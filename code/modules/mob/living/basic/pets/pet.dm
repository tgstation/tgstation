/mob/living/basic/pet
	icon = 'icons/mob/simple/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	blood_volume = BLOOD_VOLUME_NORMAL

	/// if the mob is protected from being renamed by collars.
	var/unique_pet = FALSE
	/// If the mob has collar sprites, this is the base of the icon states.
	var/collar_icon_state

/mob/living/basic/pet/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/pet_collar, collar_icon_state, can_rename = !unique_pet)
	AddElement(/datum/element/atmos_requirements, list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0), 1)
	AddElement(/datum/element/basic_body_temp_sensitive)

/mob/living/basic/pet/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/newspaper))
		if(!stat)
			user.visible_message(span_notice("[user] baps [name] on the nose with the rolled up [O]."))
			dance_rotate(src)
	else
		..()

/mob/living/basic/pet/death(gibbed)
	. = ..()
	add_memory_in_range(src, 7, MEMORY_PET_DEAD, list(DETAIL_DEUTERAGONIST = src), story_value = STORY_VALUE_AMAZING, memory_flags = MEMORY_CHECK_BLIND_AND_DEAF) //Protagonist is the person memorizing it
