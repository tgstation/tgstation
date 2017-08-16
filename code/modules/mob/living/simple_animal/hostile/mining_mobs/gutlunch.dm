//Gutlunches, passive mods that devour blood and gibs
/mob/living/simple_animal/hostile/asteroid/gutlunch
	name = "gutlunch"
	desc = "A scavenger that eats raw meat, often found alongside ash walkers. Produces a thick, nutritious milk."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "gutlunch"
	icon_living = "gutlunch"
	icon_dead = "gutlunch"
	speak_emote = list("warbles", "quavers")
	emote_hear = list("trills.")
	emote_see = list("sniffs.", "burps.")
	weather_immunities = list("lava","ash")
	faction = list("mining", "ashwalker")
	density = FALSE
	speak_chance = 1
	turns_per_move = 8
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	move_to_delay = 15
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "squishes"
	friendly = "pinches"
	a_intent = INTENT_HELP
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = 2
	stat_attack = UNCONSCIOUS
	gender = NEUTER
	stop_automated_movement = FALSE
	stop_automated_movement_when_pulled = TRUE
	stat_exclusive = TRUE
	robust_searching = TRUE
	search_objects = TRUE
	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	deathmessage = "is pulped into bugmash."

	animal_species = /mob/living/simple_animal/hostile/asteroid/gutlunch
	childtype = list(/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck = 45, /mob/living/simple_animal/hostile/asteroid/gutlunch/guthen = 55)

	wanted_objects = list(/obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/blood/gibs/)
	var/obj/item/udder/gutlunch/udder = null

/mob/living/simple_animal/hostile/asteroid/gutlunch/Initialize()
	udder = new()
	. = ..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/regenerate_icons()
	cut_overlays()
	if(udder.reagents.total_volume == udder.reagents.maximum_volume)
		add_overlay("gl_full")
	..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/attackby(obj/item/O, mob/user, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/reagent_containers/glass))
		udder.milkAnimal(O, user)
		regenerate_icons()
	else
		..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/AttackingTarget()
	if(is_type_in_typecache(target,wanted_objects)) //we eats
		udder.generateMilk()
		regenerate_icons()
		visible_message("<span class='notice'>[src] slurps up [target].</span>")
		qdel(target)
	return ..()

//Male gutlunch. They're smaller and more colorful!
/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck
	name = "gubbuck"
	gender = MALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck/Initialize()
	..()
	add_atom_colour(pick("#E39FBB", "#D97D64", "#CF8C4A"), FIXED_COLOUR_PRIORITY)
	resize = 0.85
	update_transform()

//Lady gutlunch. They make the babby.
/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen
	name = "guthen"
	gender = FEMALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen/Life()
	..()
	if(udder.reagents.total_volume == udder.reagents.maximum_volume) //Only breed when we're full.
		make_babies()

/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen/make_babies()
	. = ..()
	if(.)
		udder.reagents.clear_reagents()
		regenerate_icons()

//Gutlunch udder
/obj/item/udder/gutlunch
	name = "nutrient sac"

/obj/item/udder/gutlunch/New()
	reagents = new(50)
	reagents.my_atom = src

/obj/item/udder/gutlunch/generateMilk()
	if(prob(60))
		reagents.add_reagent("cream", rand(2, 5))
	if(prob(45))
		reagents.add_reagent("salglu_solution", rand(2,5))

