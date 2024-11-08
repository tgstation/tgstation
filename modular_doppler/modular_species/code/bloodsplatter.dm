///	In this .dm we make a green bloodsplatter subtype
//	Using the xenoblood icons
/obj/effect/decal/cleanable/blood/hitsplatter/green
	icon = 'modular_doppler/modular_species/icons/blood.dmi'
	icon_state = "xhitsplatter1"
	random_icon_states = list("xhitsplatter1", "xhitsplatter2", "xhitsplatter3")
	blood_state = BLOOD_STATE_XENO

/obj/effect/decal/cleanable/blood/hitsplatter/blue
	icon = 'modular_doppler/modular_species/icons/blood.dmi'
	icon_state = "xhitsplatter1"
	random_icon_states = list("bhitsplatter1", "bhitsplatter2", "bhitsplatter3")
	blood_state = BLOOD_STATE_NOT_BLOODY

/obj/effect/temp_visual/dir_setting/bloodsplatter/green
	splatter_type = "xsplatter"

/obj/effect/temp_visual/dir_setting/bloodsplatter/blue
	icon = 'modular_doppler/modular_species/icons/blood.dmi'
	splatter_type = "bsplatter"

/obj/effect/decal/cleanable/blood/green
	name = "insect blood"
	desc = "It's green... And it looks like... <i>blood?</i>"
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	should_dry = FALSE
	blood_state = BLOOD_STATE_XENO
	beauty = -250
	clean_type = CLEAN_TYPE_BLOOD

/obj/effect/decal/cleanable/blood/blue
	name = "robot blood"
	desc = "It's blue... And it looks like... <i>blood?</i>"
	icon = 'modular_doppler/modular_species/icons/blood.dmi'
	icon_state = "bfloor1"
	random_icon_states = list("bfloor1", "bfloor2", "bfloor3", "bfloor4", "bfloor5", "bfloor6", "bfloor7")
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	should_dry = FALSE
	blood_state = BLOOD_STATE_NOT_BLOODY
	clean_type = CLEAN_TYPE_BLOOD

//// splatter
// green
/obj/effect/decal/cleanable/blood/green/splatter
	random_icon_states = list("xgibbl1", "xgibbl2", "xgibbl3", "xgibbl4", "xgibbl5")

/obj/effect/decal/cleanable/blood/green/splatter/over_window
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE
	alpha = 180

/obj/effect/decal/cleanable/blood/green/splatter/over_window/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf)

// blue
/obj/effect/decal/cleanable/blood/blue/splatter
	random_icon_states = list("bgibbl1", "bgibbl2", "bgibbl3", "bgibbl4", "bgibbl5")

/obj/effect/decal/cleanable/blood/blue/splatter/over_window
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE
	alpha = 180

/obj/effect/decal/cleanable/blood/blue/splatter/over_window/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf)

//// drips
// green
/obj/effect/decal/cleanable/blood/drip/green
	name = "drips of insect blood"
	desc = "It's green."
	icon = 'modular_doppler/modular_species/icons/blood.dmi'
	icon_state = "xdrip5"
	random_icon_states = list("xdrip1","xdrip2","xdrip3","xdrip4","xdrip5")
	should_dry = FALSE
	blood_state = BLOOD_STATE_XENO
	beauty = -150

// blue
/obj/effect/decal/cleanable/blood/drip/blue
	name = "drips of robot blood"
	desc = "It's blue."
	icon = 'modular_doppler/modular_species/icons/blood.dmi'
	icon_state = "bdrip5"
	random_icon_states = list("bdrip1","bdrip2","bdrip3","bdrip4","bdrip5")
	should_dry = FALSE
	blood_state = BLOOD_STATE_NOT_BLOODY
	beauty = -100

//create_splatter overwrite
/mob/living/create_splatter(splatter_dir)
	if(hasblueblood(src))
		new /obj/effect/temp_visual/dir_setting/bloodsplatter/blue(get_turf(src), splatter_dir)
	else if(hasgreenblood(src))
		new /obj/effect/temp_visual/dir_setting/bloodsplatter/green(get_turf(src), splatter_dir)
	else
		new /obj/effect/temp_visual/dir_setting/bloodsplatter(get_turf(src), splatter_dir)

//getTrail overwrite
/mob/living/carbon/human/getTrail()
	if((hasgreenblood(src)))
		if(getBruteLoss() < 300)
			return pick (list("xltrails_1", "xltrails2"))
		else
			return pick (list("xttrails_1", "xttrails2"))
	if((hasblueblood(src)))
		return pick (list("btrails_1", "btrails2"))
	return ..()
