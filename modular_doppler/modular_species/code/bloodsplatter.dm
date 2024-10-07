///	Green blood reagent
/datum/reagent/blood/green
	data = list("viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null,"quirks"=null)
	name = "insect blood"
	color = "#50c034" // rgb: 0, 200, 0
	metabolization_rate = 12.5 * REAGENTS_METABOLISM //fast rate so it disappears fast.
	taste_description = "iron"
	taste_mult = 1.3
	penetrates_skin = NONE
	ph = 7.4
	default_container = /obj/item/reagent_containers/blood

///	In this .dm we make a green bloodsplatter subtype
//	Using the xenoblood icons
/obj/effect/decal/cleanable/blood/hitsplatter/green
	icon = 'modular_doppler/modular_species/icons/blood.dmi'
	icon_state = "xhitsplatter1"
	random_icon_states = list("xhitsplatter1", "xhitsplatter2", "xhitsplatter3")
	blood_state = BLOOD_STATE_XENO

/obj/effect/temp_visual/dir_setting/bloodsplatter/green
	splatter_type = "xsplatter"

/obj/effect/decal/cleanable/blood/green
	name = "insect blood"
	desc = "It's green... And it looks like... <i>blood?</i>"
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	blood_state = BLOOD_STATE_XENO
	beauty = -250
	clean_type = CLEAN_TYPE_BLOOD

/obj/effect/decal/cleanable/blood/green/splatter
	random_icon_states = list("xgibbl1", "xgibbl2", "xgibbl3", "xgibbl4", "xgibbl5")

/obj/effect/decal/cleanable/blood/green/splatter/over_window
	layer = ABOVE_WINDOW_LAYER
	plane = GAME_PLANE
	vis_flags = VIS_INHERIT_PLANE
	alpha = 180

/obj/effect/decal/cleanable/blood/green/splatter/over_window/NeverShouldHaveComeHere(turf/here_turf)
	return isgroundlessturf(here_turf)

/obj/effect/decal/cleanable/blood/drip/green
	name = "drips of blood"
	desc = "It's green."
	icon = 'modular_doppler/modular_species/icons/blood.dmi'
	icon_state = "xdrip5"
	random_icon_states = list("xdrip1","xdrip2","xdrip3","xdrip4","xdrip5")
	should_dry = FALSE //human only thing
	blood_state = BLOOD_STATE_XENO
	beauty = -150


//getTrail overwrite
/mob/living/carbon/human/getTrail()
	if(!(hasgreenblood(src)))
		return ..()
	if(getBruteLoss() < 300)
		return pick (list("xltrails_1", "xltrails2"))
	else
		return pick (list("xttrails_1", "xttrails2"))
