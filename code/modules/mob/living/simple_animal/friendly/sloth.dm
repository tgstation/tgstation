GLOBAL_DATUM(cargo_sloth, /mob/living/simple_animal/sloth)

/mob/living/simple_animal/sloth
	name = "sloth"
	desc = "An adorable, sleepy creature."
	icon = 'icons/mob/simple/pets.dmi'
	icon_state = "sloth"
	icon_living = "sloth"
	icon_dead = "sloth_dead"
	speak_emote = list("yawns")
	emote_hear = list("snores.","yawns.")
	emote_see = list("dozes off.", "looks around sleepily.")
	speak_chance = 1
	turns_per_move = 5
	can_be_held = TRUE
	butcher_results = list(/obj/item/food/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	gold_core_spawnable = FRIENDLY_SPAWN
	melee_damage_lower = 18
	melee_damage_upper = 18
	health = 50
	maxHealth = 50
	speed = 10
	held_state = "sloth"
	///In the case 'melee_damage_upper' is somehow raised above 0
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/sloth/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "slowly smiles!")
	// If someone adds non-cargo sloths to maps we'll have a problem but we're fine for now
	if(!GLOB.cargo_sloth && mapload && is_station_level(z))
		GLOB.cargo_sloth = src

/mob/living/simple_animal/sloth/Destroy()
	if(GLOB.cargo_sloth == src)
		GLOB.cargo_sloth = null

	return ..()

//Cargo Sloth
/mob/living/simple_animal/sloth/paperwork
	name = "Paperwork"
	desc = "Cargo's pet sloth. About as useful as the rest of the techs."
	gold_core_spawnable = NO_SPAWN

//Cargo Sloth 2

/mob/living/simple_animal/sloth/citrus
	name = "Citrus"
	desc = "Cargo's pet sloth. She's dressed in a horrible sweater."
	icon_state = "cool_sloth"
	icon_living = "cool_sloth"
	icon_dead = "cool_sloth_dead"
	gender = FEMALE
	butcher_results = list(/obj/item/toy/spinningtoy = 1)
	gold_core_spawnable = NO_SPAWN
