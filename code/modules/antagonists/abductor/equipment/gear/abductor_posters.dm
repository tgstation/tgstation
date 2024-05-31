
/obj/item/poster/random_abductor
	name = "random abductor poster"
	poster_type = /obj/structure/sign/poster/abductor/random
	icon = 'icons/obj/poster.dmi'
	icon_state = "rolled_abductor"

/obj/structure/sign/poster/abductor
	icon = 'icons/obj/poster.dmi'
	poster_item_name = "abductor poster"
	poster_item_desc = "A sheet of holofiber resin, with a nanospike perforation on the back end for maximum adhesion."
	poster_item_icon_state = "rolled_abductor"

/obj/structure/sign/poster/abductor/tear_poster(mob/user)
	if(!isabductor(user))
		balloon_alert(user, "it won't budge!")
		return
	return ..()

/obj/structure/sign/poster/abductor/attackby(obj/item/tool, mob/user, params)
	if(tool.toolspeed >= 0.2)
		balloon_alert(user, "tool too weak!")
		return FALSE
	return ..()

/obj/structure/sign/poster/abductor/random
	name = "random abductor poster"
	icon_state = "random_abductor"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/abductor

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/random, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/random, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/random, 32)
#endif
#endif

/obj/structure/sign/poster/abductor/ayylian
	name = "Ayylian"
	desc = "Man, Ian sure is looking strange these days."
	icon_state = "ayylian"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayylian, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayylian, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/ayylian, 32)
#endif
#endif

/obj/structure/sign/poster/abductor/ayy
	name = "Abductor"
	desc = "Hey, that's not a lizard!"
	icon_state = "ayy"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/ayy, 32)
#endif
#endif

/obj/structure/sign/poster/abductor/ayy_over_tizira
	name = "Abductors Over Tizira"
	desc = "A poster for an experimental adaptation of a movie about the Human-Lizard war. Production was greatly hindered by the leading pair's refusal to speak any lines."
	icon_state = "ayy_over_tizira"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_over_tizira, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_over_tizira, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/ayy_over_tizira, 32)
#endif
#endif

/obj/structure/sign/poster/abductor/ayy_recruitment
	name = "Abductor Recruitment"
	desc = "Enlist in the Mothership Probing Division today!"
	icon_state = "ayy_recruitment"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_recruitment, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_recruitment, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/ayy_recruitment, 32)
#endif
#endif

/obj/structure/sign/poster/abductor/ayy_cops
	name = "Abductor Cops"
	desc = "A poster advertising the polarizing 'Abductor Cops' series. Some critics claimed that it stunned them, while others said it put them to sleep."
	icon_state = "ayyce_cops"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_cops, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_cops, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/ayy_cops, 32)
#endif
#endif

/obj/structure/sign/poster/abductor/ayy_no
	name = "Uayy No"
	desc = "This thing is all in Japanese, AND they got rid of the anime girl on the poster. Outrageous."
	icon_state = "ayy_no"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_no, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_no, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/ayy_no, 32)
#endif
#endif

/obj/structure/sign/poster/abductor/ayy_piping
	name = "Safety Abductor - Piping"
	desc = "Safety Abductor has nothing to say. Not because it cannot speak, but because Abductors don't have to deal with atmos stuff."
	icon_state = "ayy_piping"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_piping, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_piping, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/ayy_piping, 32)
#endif
#endif

/obj/structure/sign/poster/abductor/ayy_fancy
	name = "Abductor Fancy"
	desc = "Abductors are the best at doing everything. That includes looking good!"
	icon_state = "ayy_fancy"

#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_fancy, 32)
#else
#ifdef EXPERIMENT_WALLENING_SIGNS
NORTH_MAPPING_DIRECTIONAL_HELPER(/obj/structure/sign/poster/abductor/ayy_fancy, 32)
#else
MAPPING_DIRECTIONAL_HELPERS_ALL_CARDINALS(/obj/structure/sign/poster/abductor/ayy_fancy, 32)
#endif
#endif
