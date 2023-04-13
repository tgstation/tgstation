//Gutlunches, passive mods that devour blood and gibs
/mob/living/simple_animal/hostile/asteroid/gutlunch
	name = "gutlunch"
	desc = "A scavenger that eats raw meat, often found alongside ash walkers. Produces a thick, nutritious milk."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "gutlunch"
	icon_living = "gutlunch"
	icon_dead = "gutlunch"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_emote = list("warbles", "quavers")
	emote_hear = list("trills.")
	emote_see = list("sniffs.", "burps.")
	weather_immunities = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE)
	faction = list(FACTION_MINING, FACTION_ASHWALKER)
	density = FALSE
	speak_chance = 1
	turns_per_move = 8
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	move_to_delay = 15
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "squishes"
	response_harm_simple = "squish"
	friendly_verb_continuous = "pinches"
	friendly_verb_simple = "pinch"
	combat_mode = FALSE
	gold_core_spawnable = FRIENDLY_SPAWN
	stat_attack = HARD_CRIT
	gender = NEUTER
	stop_automated_movement = FALSE
	stop_automated_movement_when_pulled = TRUE
	stat_exclusive = TRUE
	robust_searching = TRUE
	search_objects = 3 //Ancient simplemob AI shitcode. This makes them ignore all other mobs.
	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	death_message = "is pulped into bugmash."

	animal_species = /mob/living/simple_animal/hostile/asteroid/gutlunch
	childtype = list(/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch = 100)

	wanted_objects = list(/obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/blood/gibs/, /obj/item/organ)

/mob/living/simple_animal/hostile/asteroid/gutlunch/Initialize(mapload)
	. = ..()
	if(wanted_objects.len)
		AddComponent(/datum/component/udder, /obj/item/udder/gutlunch, CALLBACK(src, PROC_REF(regenerate_icons)), CALLBACK(src, PROC_REF(regenerate_icons)))
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/asteroid/gutlunch/CanAttack(atom/the_target) // Gutlunch-specific version of CanAttack to handle stupid stat_exclusive = true crap so we don't have to do it for literally every single simple_animal/hostile except the two that spawn in lavaland
	if(!the_target || !isturf(the_target.loc)) // bail out on invalids
		return FALSE

	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isliving(the_target))
		var/mob/living/L = the_target

		if(faction_check_mob(L) && !attack_same)
			return FALSE
		if(L.stat > stat_attack || L.stat != stat_attack && stat_exclusive)
			return FALSE

		return TRUE

	if(isobj(the_target) && is_type_in_typecache(the_target, wanted_objects))
		return TRUE

	return FALSE

/mob/living/simple_animal/hostile/asteroid/gutlunch/regenerate_icons(new_udder_volume, max_udder_volume)
	cut_overlays()
	var/static/gutlunch_full_overlay
	if(isnull(gutlunch_full_overlay))
		gutlunch_full_overlay = iconstate2appearance(icon, "gl_full")
	if(new_udder_volume == max_udder_volume)
		add_overlay(gutlunch_full_overlay)
	..()

//Male gutlunch. They're smaller and more colorful!
/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck
	name = "gubbuck"
	gender = MALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck/Initialize(mapload)
	. = ..()
	add_atom_colour(pick("#E39FBB", "#D97D64", "#CF8C4A"), FIXED_COLOUR_PRIORITY)
	resize = 0.85
	update_transform()

//Lady gutlunch. They make the babby.
/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen
	name = "guthen"
	gender = FEMALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch
	name = "grublunch"
	wanted_objects = list() //They don't eat.
	gold_core_spawnable = NO_SPAWN
	var/growth = 0

//Baby gutlunch
/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/Initialize(mapload)
	. = ..()
	add_atom_colour("#9E9E9E", FIXED_COLOUR_PRIORITY) //Somewhat hidden
	resize = 0.45
	update_transform()

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/Life(delta_time = SSMOBS_DT, times_fired)
	..()
	growth++
	if(growth > 50) //originally used a timer for this but it was more of a problem than it was worth.
		growUp()

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/proc/growUp()
	var/mob/living/L
	if(prob(45))
		L = new /mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck(loc)
	else
		L = new /mob/living/simple_animal/hostile/asteroid/gutlunch/guthen(loc)
	mind?.transfer_to(L)
	L.faction = faction
	L.setDir(dir)
	L.Stun(20, ignore_canstun = TRUE)
	visible_message(span_notice("[src] grows up into [L]."))
	qdel(src)
