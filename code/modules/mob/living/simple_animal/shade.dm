/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	gender = PLURAL
	icon = 'icons/mob/nonhuman-player/cult.dmi'
	icon_state = "shade_cult"
	icon_living = "shade_cult"
	mob_biotypes = MOB_SPIRIT
	maxHealth = 40
	health = 40
	speak_emote = list("hisses")
	emote_hear = list("wails.","screeches.")
	response_help_continuous = "puts their hand through"
	response_help_simple = "put your hand through"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	speak_chance = 1
	melee_damage_lower = 5
	melee_damage_upper = 12
	attack_verb_continuous = "metaphysically strikes"
	attack_verb_simple = "metaphysically strike"
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	speed = -1 //they don't have to lug a body made of runed metal around
	stop_automated_movement = 1
	faction = list(FACTION_CULT)
	status_flags = CANPUSH
	loot = list(/obj/item/ectoplasm)
	del_on_death = TRUE
	initial_language_holder = /datum/language_holder/construct

/mob/living/simple_animal/shade/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	add_traits(list(TRAIT_HEALS_FROM_CULT_PYLONS, TRAIT_SPACEWALK, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)

/mob/living/simple_animal/shade/death()
	if(death_message == initial(death_message))
		death_message = "lets out a contented sigh as [p_their()] form unwinds."
	..()

/mob/living/simple_animal/shade/can_suicide()
	if(istype(loc, /obj/item/soulstone)) //do not suicide inside the soulstone
		return FALSE
	return ..()

/mob/living/simple_animal/shade/attackby(obj/item/item, mob/user, params)  //Marker -Agouri
	if(istype(item, /obj/item/soulstone))
		var/obj/item/soulstone/stone = item
		stone.capture_shade(src, user)
	else
		. = ..()
