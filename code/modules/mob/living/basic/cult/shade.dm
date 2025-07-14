/mob/living/basic/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	gender = PLURAL
	icon = 'icons/mob/nonhuman-player/cult.dmi'
	icon_state = "shade_cult"
	icon_living = "shade_cult"
	mob_biotypes = MOB_SPIRIT | MOB_UNDEAD
	maxHealth = 40
	health = 40
	status_flags = CANPUSH
	speak_emote = list("hisses")
	response_help_continuous = "puts their hand through"
	response_help_simple = "put your hand through"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	melee_damage_lower = 5
	melee_damage_upper = 12
	attack_verb_continuous = "metaphysically strikes"
	attack_verb_simple = "metaphysically strike"
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0
	speed = -1
	faction = list(FACTION_CULT)
	basic_mob_flags = DEL_ON_DEATH
	initial_language_holder = /datum/language_holder/construct
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	/// Theme controls color. THEME_CULT is red THEME_WIZARD is purple and THEME_HOLY is blue
	var/theme = THEME_CULT
	/// The different flavors of goop shades can drop, depending on theme.
	var/static/list/remains_by_theme = list(
		THEME_CULT = list(/obj/item/ectoplasm/construct),
		THEME_HOLY = list(/obj/item/ectoplasm/angelic),
		THEME_WIZARD = list(/obj/item/ectoplasm/mystic),
	)

/mob/living/basic/shade/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	add_traits(list(TRAIT_HEALS_FROM_CULT_PYLONS, TRAIT_SPACEWALK, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)
	if(isnull(theme))
		return
	icon_state = "shade_[theme]"
	var/list/remains = string_list(remains_by_theme[theme])
	if(length(remains))
		AddElement(/datum/element/death_drops, remains)

/mob/living/basic/shade/update_icon_state()
	. = ..()
	if(!isnull(theme))
		icon_state = "shade_[theme]"
	icon_living = icon_state

/mob/living/basic/shade/death()
	if(IS_CULTIST(src))
		SSblackbox.record_feedback("tally", "cult_shade_killed", 1)
	if(death_message == initial(death_message))
		death_message = "lets out a contented sigh as [p_their()] form unwinds."
	..()

/mob/living/basic/shade/can_suicide()
	if(istype(loc, /obj/item/soulstone)) //do not suicide inside the soulstone
		return FALSE
	return ..()

/mob/living/basic/shade/suicide_log(obj/item/suicide_tool)
	if(IS_CULTIST(src))
		SSblackbox.record_feedback("tally", "cult_shade_suicided", 1)
	..()

/mob/living/basic/shade/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/soulstone))
		var/obj/item/soulstone/stone = item
		stone.capture_shade(src, user)
	else
		. = ..()
