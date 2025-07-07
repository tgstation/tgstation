// Mayhem in a bottle

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	if(tgui_alert(user, "Breaking the bottle will cause nearby crewmembers to go into a murderous frenzy. Be sure you know what you are doing...", "Break the bottle?", list("Break it!", "DON'T")) != "Break it!")
		return

	if(QDELETED(src) || !user.is_holding(src) || user.incapacitated)
		return

	for(var/mob/living/carbon/human/target in range(7, user))
		target.apply_status_effect(/datum/status_effect/mayhem)

	to_chat(user, span_notice("You shatter the bottle!"))
	playsound(user.loc, 'sound/effects/glass/glassbr1.ogg', 100, TRUE)
	message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(user)] has activated a bottle of mayhem!"))
	user.log_message("activated a bottle of mayhem", LOG_ATTACK)
	qdel(src)

// H.E.C.K. Suit

/obj/item/clothing/suit/hooded/hostile_environment
	name = "H.E.C.K. suit"
	desc = "Hostile Environment Cross-Kinetic Suit: A suit designed to withstand the wide variety of hazards from Lavaland. It wasn't enough for its last owner."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/hooded/hostile_environment"
	post_init_icon_state = "hostile_env"
	hoodtype = /obj/item/clothing/head/hooded/hostile_environment
	armor_type = /datum/armor/hooded_hostile_environment
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	clothing_flags = THICKMATERIAL|HEADINTERNALS
	resistance_flags = FIRE_PROOF|LAVA_PROOF|ACID_PROOF
	transparent_protection = HIDESUITSTORAGE|HIDEJUMPSUIT
	allowed = null
	greyscale_colors = "#4d4d4d#808080"
	greyscale_config = /datum/greyscale_config/heck_suit
	greyscale_config_worn = /datum/greyscale_config/heck_suit/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/datum/armor/hooded_hostile_environment
	melee = 70
	bullet = 40
	laser = 10
	energy = 20
	bomb = 50
	fire = 100
	acid = 100

/obj/item/clothing/suit/hooded/hostile_environment/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radiation_protected_clothing)
	AddElement(/datum/element/gags_recolorable)
	allowed = GLOB.mining_suit_allowed

/obj/item/clothing/suit/hooded/hostile_environment/process(seconds_per_tick)
	var/mob/living/carbon/wearer = loc
	if(istype(wearer) && SPT_PROB(1, seconds_per_tick)) //cursed by bubblegum
		if(prob(7.5))
			wearer.cause_hallucination(/datum/hallucination/oh_yeah, "H.E.C.K suit", haunt_them = TRUE)
		else
			if(HAS_TRAIT(wearer, TRAIT_ANOSMIA)) //Anosmia quirk holder cannot fell any smell
				to_chat(wearer, span_warning("[pick("You hear faint whispers.","You feel hot.","You hear a roar in the distance.")]"))
			else
				to_chat(wearer, span_warning("[pick("You hear faint whispers.","You smell ash.","You feel hot.","You hear a roar in the distance.")]"))

/obj/item/clothing/head/hooded/hostile_environment
	name = "H.E.C.K. helmet"
	desc = "Hostile Environment Cross-Kinetic Helmet: A helmet designed to withstand the wide variety of hazards from Lavaland. It wasn't enough for its last owner."
	icon = 'icons/map_icons/clothing/head/_head.dmi'
	icon_state = "/obj/item/clothing/head/hooded/hostile_environment"
	post_init_icon_state = "hostile_env"
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	armor_type = /datum/armor/hooded_hostile_environment
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	clothing_flags = SNUG_FIT|THICKMATERIAL
	resistance_flags = FIRE_PROOF|LAVA_PROOF|ACID_PROOF
	flags_inv = HIDEMASK|HIDEEARS|HIDEFACE|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSMOUTH
	actions_types = list()
	greyscale_colors = "#4d4d4d#808080#ff3300"
	greyscale_config = /datum/greyscale_config/heck_helmet
	greyscale_config_worn = /datum/greyscale_config/heck_helmet/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/hooded/hostile_environment/Initialize(mapload)
	. = ..()
	update_appearance()
	AddComponent(/datum/component/butchering/wearable, \
	speed = 0.5 SECONDS, \
	effectiveness = 150, \
	bonus_modifier = 0, \
	butcher_sound = null, \
	disabled = null, \
	can_be_blunt = TRUE, \
	butcher_callback = CALLBACK(src, PROC_REF(consume)), \
	)
	AddElement(/datum/element/radiation_protected_clothing)
	AddElement(/datum/element/gags_recolorable)

/obj/item/clothing/head/hooded/hostile_environment/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	to_chat(user, span_notice("You feel a bloodlust. You can now butcher corpses with your bare arms."))

/obj/item/clothing/head/hooded/hostile_environment/dropped(mob/user, silent = FALSE)
	. = ..()
	to_chat(user, span_notice("You lose your bloodlust."))

/obj/item/clothing/head/hooded/hostile_environment/proc/consume(mob/living/user, mob/living/butchered)
	if(butchered.mob_biotypes & (MOB_ROBOTIC | MOB_SPIRIT))
		return
	var/health_consumed = butchered.maxHealth * 0.1
	user.heal_ordered_damage(health_consumed, list(BRUTE, BURN, TOX))
	to_chat(user, span_notice("You heal from the corpse of [butchered]."))
	var/datum/client_colour/color_effect = user.add_client_colour(/datum/client_colour/bloodlust, HELMET_TRAIT)
	QDEL_IN(color_effect, 1 SECONDS)

