#define ui_honeydisplay "WEST,CENTER-2:15"
#define FORMAT_HONEY_CHARGES_TEXT(charges) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(charges)]</font></div>")

/datum/language_holder/apid
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM))


/obj/item/food/meat/slab/human/mutant/apid
	icon_state = "mothmeat"
	desc = "Unpleasantly powdery and dry. Kind of pretty, though."
	tastes = list("dust" = 1, "powder" = 1, "meat" = 2)
	foodtypes = MEAT | RAW | BUGS | GORE
	venue_value = FOOD_MEAT_MUTANT

/atom/movable/screen/apid
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'


/atom/movable/screen/apid/honey
	name = "honey storage"
	icon_state = "honey_counter"
	screen_loc = ui_honeydisplay


/datum/species/apid
	name = "\improper Apid"
	plural_form = "Apids"
	id = SPECIES_APID
	species_traits = list(HAS_MARKINGS,)

	/*
	mutant_bodyparts = list(
		"apid_stripes" = "None",
		"apid_headstripes" = "None",
	)
	*/

	mutanteyes = /obj/item/organ/internal/eyes/apid

	external_organs = list(
		/obj/item/organ/external/wings/apid = "Normal",
		/obj/item/organ/external/antennae_apid = "Moth",
	)

	inherent_traits = list(
		TRAIT_TACKLING_WINGED_ATTACKER,
		TRAIT_ANTENNAE,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG

	meat = /obj/item/food/meat/slab/human/mutant/apid
	liked_food = VEGETABLES | MEAT | FRUIT
	disliked_food =  GROSS | BUGS | GORE
	toxic_food = RAW | SEAFOOD

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/apid

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/apid,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/apid,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/apid,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/apid,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/apid,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/apid,
	)

	var/obj/structure/beebox/hive/owned_hive

	var/datum/action/cooldown/spell/build_hive/build
	var/datum/action/cooldown/spell/pointed/pollinate/pollinate
	var/datum/action/cooldown/spell/change_pollination_stat/change_stat

	var/stored_honey = 0
	var/current_stat = "potency"

	/// UI displaying how much honey we have
	var/atom/movable/screen/apid/honey/honeydisplay


/datum/species/apid/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	. = ..()
	RegisterSignal(human_who_gained_species, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(damage_weakness))
	build = new
	build.Grant(human_who_gained_species)

	pollinate = new
	pollinate.Grant(human_who_gained_species)

	change_stat = new
	change_stat.Grant(human_who_gained_species)

	if(human_who_gained_species.hud_used)
		var/datum/hud/hud_used = human_who_gained_species.hud_used

		honeydisplay = new /atom/movable/screen/apid/honey()
		honeydisplay.hud = hud_used
		hud_used.infodisplay += honeydisplay
		adjust_honeycount(0)
		hud_used.show_hud(hud_used.hud_version)

/datum/species/apid/proc/adjust_honeycount(amount)
	stored_honey = max(0, amount + stored_honey)
	honeydisplay?.maptext = FORMAT_HONEY_CHARGES_TEXT(stored_honey)

/datum/species/apid/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)
	if(build)
		build.Remove(C)
	if(pollinate)
		pollinate.Remove(C)
	if(change_stat)
		change_stat.Remove(C)

	if(C.hud_used)
		var/datum/hud/hud_used = C.hud_used

		hud_used.infodisplay -= honeydisplay
		QDEL_NULL(honeydisplay)

/datum/species/apid/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	. = ..()
	if(honeydisplay)
		return

	if(H.hud_used)
		var/datum/hud/hud_used = H.hud_used

		honeydisplay = new /atom/movable/screen/apid/honey()
		honeydisplay.hud = hud_used
		hud_used.infodisplay += honeydisplay
		adjust_honeycount(0)
		hud_used.show_hud(hud_used.hud_version)

/datum/species/apid/proc/damage_weakness(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	SIGNAL_HANDLER

	if(istype(attacking_item, /obj/item/melee/flyswatter))
		damage_mods += 10 // Yes, a 10x damage modifier

/datum/species/apid/get_scream_sound(mob/living/carbon/human/human)
	return 'sound/voice/moth/scream_moth.ogg'

/datum/species/apid/get_species_description()
	return "Apids are a race of bipedal bees from the jungle planet of Saltu. Due to their large bodies, they have lost the ability to fly."

#undef ui_honeydisplay
#undef FORMAT_HONEY_CHARGES_TEXT
