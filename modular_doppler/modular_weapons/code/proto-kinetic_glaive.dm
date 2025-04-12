//modularly adds a glaive reskin to the crusher. code credit due to hatterhat via https://github.com/Skyrat-SS13/Skyrat-tg/pull/22626 for lines 3 - 33 and ephe for 35 - 40

/obj/item/kinetic_crusher
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Crusher" = list(
			RESKIN_ICON = 'icons/obj/mining.dmi',
			RESKIN_ICON_STATE = "crusher",
			RESKIN_INHAND_L = 'icons/mob/inhands/weapons/hammers_lefthand.dmi',
			RESKIN_INHAND_R = 'icons/mob/inhands/weapons/hammers_righthand.dmi',
			RESKIN_INHAND_STATE = "crusher0",
		),
		"Glaive" = list(
			RESKIN_ICON = 'modular_doppler/modular_weapons/icons/obj/proto-kinetic_glaive.dmi',
			RESKIN_ICON_STATE = "crusher-glaive",
			RESKIN_WORN_ICON = 'modular_doppler/modular_weapons/icons/mob/worn/weapons_onback.dmi',
			RESKIN_WORN_ICON_STATE = "crusher-glaive",
			RESKIN_INHAND_L = 'modular_doppler/modular_weapons/icons/mob/64x64_lefthand.dmi',
			RESKIN_INHAND_R = 'modular_doppler/modular_weapons/icons/mob/64x64_righthand.dmi',
		),
	)

/obj/item/kinetic_crusher/post_reskin(mob/our_mob)
	if(icon_state == "crusher-glaive")
		name = "proto-kinetic glaive"
		desc = "A modified proto-kinetic crusher, it is still little more than various mining tools cobbled together \
			into a high-tech knife on a stick with a handguard and goliath-leather grip. While equally as effective as its unmodified compatriots, \
		it still does little to aid any but the most skilled - or suicidal."
		attack_verb_continuous = list("slices", "slashes", "cleaves", "chops", "stabs")
		attack_verb_simple = list("slice", "slash", "cleave", "chop", "stab")
		inhand_x_dimension = 64
		inhand_y_dimension = 64
		our_mob.update_held_items()

/obj/item/kinetic_crusher/setup_reskinning()
    if(!check_setup_reskinning())
        return

    // We already register context regardless in Initialize.
    RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(on_click_alt_reskin))
