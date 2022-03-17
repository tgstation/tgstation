/obj/item/bodypart/head/vox
	static_icon = 'icons/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	bodytype = BODYTYPE_VOX | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/vox
	static_icon = 'icons/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	is_dimorphic = FALSE
	bodytype = BODYTYPE_VOX | BODYTYPE_ORGANIC
	acceptable_bodytype = BODYTYPE_VOX
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/vox/on_life()
	. = ..()
	if(owner.stat != DEAD)
		owner.adjust_bodytemperature(length(owner.bodyparts) * 2, 0, owner.dna.species.bodytemp_heat_damage_limit + 50) //More meat = more heat

/obj/item/bodypart/l_arm/vox
	static_icon = 'icons/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	bodytype = BODYTYPE_VOX | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE

/obj/item/bodypart/r_arm/vox
	static_icon = 'icons/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	bodytype = BODYTYPE_VOX | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE

/obj/item/bodypart/l_leg/vox
	static_icon = 'icons/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	bodytype = BODYTYPE_VOX | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE
	dismemberable = FALSE //BIG MEATY THIGHS

/obj/item/bodypart/r_leg/vox
	static_icon = 'icons/mob/species/vox/bodyparts.dmi'
	limb_id = SPECIES_VOX
	bodytype = BODYTYPE_VOX | BODYTYPE_ORGANIC
	should_draw_greyscale = FALSE
	dismemberable = FALSE
