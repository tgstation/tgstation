/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	gender = PLURAL
	icon = 'icons/mob/cult.dmi'
	icon_state = "shade_cult"
	icon_living = "shade_cult"
	mob_biotypes = MOB_SPIRIT
	maxHealth = 40
	health = 40
	healable = 0
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
	faction = list("cult")
	status_flags = CANPUSH
	loot = list(/obj/item/ectoplasm)
	del_on_death = TRUE
	initial_language_holder = /datum/language_holder/construct

/mob/living/simple_animal/shade/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	ADD_TRAIT(src, TRAIT_HEALS_FROM_CULT_PYLONS, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/shade/death()
	if(deathmessage == initial(deathmessage))
		deathmessage = "lets out a contented sigh as [p_their()] form unwinds."
	..()

/mob/living/simple_animal/shade/canSuicide()
	if(istype(loc, /obj/item/soulstone)) //do not suicide inside the soulstone
		return FALSE
	return ..()

/mob/living/simple_animal/shade/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(isconstruct(user))
		var/mob/living/simple_animal/hostile/construct/doll = user
		if(!doll.can_repair_constructs)
			return
		if(health < maxHealth)
			adjustHealth(-25)
			Beam(user,icon_state="sendbeam", time = 4)
			user.visible_message(span_danger("[user] heals \the <b>[src]</b>."), \
					   span_cult("You heal <b>[src]</b>, leaving <b>[src]</b> at <b>[health]/[maxHealth]</b> health."))
		else
			to_chat(user, span_cult("You cannot heal <b>[src]</b>, as [p_theyre()] unharmed!"))
	else if(src != user)
		return ..()

/mob/living/simple_animal/shade/attackby(obj/item/item, mob/user, params)  //Marker -Agouri
	if(istype(item, /obj/item/soulstone))
		var/obj/item/soulstone/stone = item
		stone.capture_shade(src, user)
	else
		. = ..()
