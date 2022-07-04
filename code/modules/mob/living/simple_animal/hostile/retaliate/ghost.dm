/mob/living/simple_animal/hostile/retaliate/ghost
	name = "ghost"
	desc = "A soul of the dead, spooky."
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	icon_living = "ghost"
	mob_biotypes = MOB_SPIRIT
	speak_chance = 0
	turns_per_move = 5
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	combat_mode = TRUE
	healable = 0
	speed = 0
	maxHealth = 40
	health = 40
	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 15
	del_on_death = 1
	emote_see = list("weeps silently", "groans", "mumbles")
	attack_verb_continuous = "grips"
	attack_verb_simple = "grip"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	speak_emote = list("weeps")
	deathmessage = "wails, disintegrating into a pile of ectoplasm!"
	loot = list(/obj/item/ectoplasm)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	pressure_resistance = 300
	gold_core_spawnable = NO_SPAWN //too spooky for science
	light_system = MOVABLE_LIGHT
	light_range = 1 // same glowing as visible player ghosts
	light_power = 2
	var/ghost_hairstyle
	var/ghost_hair_color
	var/mutable_appearance/ghost_hair
	var/ghost_facial_hairstyle
	var/ghost_facial_hair_color
	var/mutable_appearance/ghost_facial_hair
	var/random = TRUE //if you want random names for ghosts or not

/mob/living/simple_animal/hostile/retaliate/ghost/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	give_hair()
	if(random)
		switch(rand(0,1))
			if(0)
				name = "ghost of [pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			if(1)
				name = "ghost of [pick(GLOB.first_names_female)] [pick(GLOB.last_names)]"


/mob/living/simple_animal/hostile/retaliate/ghost/proc/give_hair()
	if(ghost_hairstyle != null)
		ghost_hair = mutable_appearance('icons/mob/human_face.dmi', "hair_[ghost_hairstyle]", -HAIR_LAYER)
		ghost_hair.alpha = 200
		ghost_hair.color = ghost_hair_color
		add_overlay(ghost_hair)
	if(ghost_facial_hairstyle != null)
		ghost_facial_hair = mutable_appearance('icons/mob/human_face.dmi', "facial_[ghost_facial_hairstyle]", -HAIR_LAYER)
		ghost_facial_hair.alpha = 200
		ghost_facial_hair.color = ghost_facial_hair_color
		add_overlay(ghost_facial_hair)

/mob/living/simple_animal/hostile/retaliate/ghost/obsessed_spirit
	random = FALSE
	name = "Malign Spirit of Obsession"
	desc = "The chip on one's shoulder, the voice of obsession in their head, made manifest!"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "curseblob"
	icon_living = "curseblob"
	turns_per_move = 5
	healable = 0
	speed = 0
	maxHealth = 275
	health = 275
	harm_intent_damage = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_sound = 'sound/hallucinations/growl3.ogg'
	speak_emote = list("wails")
	light_range = 0 //Spawns into darkness. Its cooler with no glow.

/mob/living/simple_animal/hostile/retaliate/ghost/obsessed_spirit/Initialize(mapload) //maybe find a way to make this player controllable when summoned via exorcism?
	. = ..()
	AddElement(/datum/element/knockback, 3, FALSE, TRUE)
	Retaliate()

/mob/living/simple_animal/hostile/retaliate/ghost/obsessed_spirit/on_hit()
	. = ..()

	if(prob(25)) //Oh boy its time to go ghost hunting!
		var/list/around = view(src, vision_range)
		for(var/obj/item/candle/anchor in around)
			if(anchor.lit)
				if(prob(20)) //spamming the message would get annoying
					src.visible_message(span_warning("The [src] attempts to flee into the astral plane, but is confined to this realm by the [anchor]!"), span_warning("You channel your might to escape into the astral plane, but are confined by the [anchor]!"))
				return

		var/turf/destination = find_safe_turf(extended_safety_checks = TRUE)
		do_teleport(src, destination, 1, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_FREE) //please, future rhials, improve this
		playsound(get_turf(src),'sound/hallucinations/wail.ogg', 50, TRUE, TRUE)
		src.visible_message(span_warning("The [src] wails and dives through the astral plane, fleeing the area!"), span_warning("You begin to panic and channel your might to dive into the astral plane, fleeing the area!"))
