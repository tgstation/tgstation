/mob/living/simple_animal/farm/raptor
	name = "\improper raptor"
	desc = "Raptor Racing has been a banned sport since Nanotrasen cracked down on it years ago."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "raptoryellow"
	icon_living = "raptoryellow"
	icon_dead = "raptoryellow"
	speak = list("WARK!","KWEH!")
	speak_emote = list("clucks","croons")
	emote_hear = list("warks.", "kwehs.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = 1
	speak_chance = 2
	turns_per_move = 3
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "pecks at"
	mob_size = MOB_SIZE_LARGE
	gold_core_spawnable = 2
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/raptor/random
	mob_birth_type = /mob/living/simple_animal/farm/raptor_chick/yellow
	default_breeding_trait = null
	default_food_trait = null
	can_buckle = 1
	buckle_lying = 0
	var/next_raptor_move = 0 //used for move delays
	var/raptor_move_delay = 1 //tick delay between movements, lower = faster, higher = slower
	var/pixel_x_offset = 0
	var/pixel_y_offset = 4
	var/auto_door_open = TRUE

//APPEARANCE
/mob/living/simple_animal/farm/raptor/proc/handle_raptor_layer()
	if(dir != NORTH)
		layer = MOB_LAYER+0.1
	else
		layer = OBJ_LAYER


//Override this to set your vehicle's various pixel offsets
//if they differ between directions, otherwise use the
//generic variables
/mob/living/simple_animal/farm/raptor/proc/handle_raptor_offsets()
	if(buckled_mob)
		buckled_mob.dir = dir
		buckled_mob.pixel_x = pixel_x_offset
		buckled_mob.pixel_y = pixel_y_offset

/mob/living/simple_animal/farm/raptor/relaymove(mob/user, direction)
	if(user.incapacitated())
		unbuckle_mob()

	if(!Process_Spacemove(direction) || !has_gravity(src.loc) || world.time < next_raptor_move || !isturf(loc))
		return
	next_raptor_move = world.time + raptor_move_delay

	step(src, direction)

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	handle_raptor_layer()
	handle_raptor_offsets()

/mob/living/simple_animal/farm/raptor/user_buckle_mob(mob/living/M, mob/user)
	if(user.incapacitated())
		return
	for(var/atom/movable/A in get_turf(src))
		if(A.density)
			if(A != src && A != M)
				return
	M.loc = get_turf(src)
	..()
	handle_raptor_offsets()

/mob/living/simple_animal/farm/raptor/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	..()
	handle_raptor_layer()
	handle_raptor_offsets()

/mob/living/simple_animal/farm/raptor/unbuckle_mob(force = 0)
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	. = ..()

/mob/living/simple_animal/farm/raptor/Bump(atom/movable/M)
	. = ..()
	if(auto_door_open)
		if(istype(M, /obj/machinery/door) && buckled_mob)
			M.Bumped(buckled_mob)


/mob/living/simple_animal/farm/raptor/New()
	..()
	handle_raptor_layer()

/mob/living/simple_animal/farm/raptor/yellow
	name = "\improper yellow raptor"
	desc = "Raptor Racing has been a banned sport since Nanotrasen cracked down on it years ago."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "raptoryellow"
	icon_living = "raptoryellow"
	icon_dead = "raptoryellow"
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/raptor/yellow
	mob_birth_type = /mob/living/simple_animal/farm/raptor_chick/yellow
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = null


/mob/living/simple_animal/farm/raptor/green
	name = "\improper green raptor"
	desc = "Raptor Racing has been a banned sport since Nanotrasen cracked down on it years ago. This raptor is suited to eating vegetarian foods."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "raptorgreen"
	icon_living = "raptorgreen"
	icon_dead = "raptorgreen"
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/raptor/green
	mob_birth_type = /mob/living/simple_animal/farm/raptor_chick/green
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/herbivore

/mob/living/simple_animal/farm/raptor/red
	name = "\improper red raptor"
	desc = "Raptor Racing has been a banned sport since Nanotrasen cracked down on it years ago. This raptor is suited to eating meaty foods."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "raptorred"
	icon_living = "raptorred"
	icon_dead = "raptorred"
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/raptor/red
	mob_birth_type = /mob/living/simple_animal/farm/raptor_chick/red
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/carnivore

/*

	BABY RAPTORS

*/

/mob/living/simple_animal/farm/raptor_chick
	name = "\improper raptor chick"
	desc = "Adorable! They make such a racket though."
	icon = 'icons/mob/farm/raptor.dmi'
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	speak = list("WARK!","KWEH!")
	speak_emote = list("clucks","croons")
	emote_hear = list("warks.", "kwehs.")
	emote_see = list("pecks at the ground.","flaps its tiny wings.")
	density = 0
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	attacktext = "pecks"
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = 2
	adult_version = /mob/living/simple_animal/farm/raptor/yellow
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/herbivore



/mob/living/simple_animal/farm/raptor_chick/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)


/mob/living/simple_animal/farm/raptor_chick/yellow
	name = "\improper yellow baby raptor"
	icon_state = "babyellow"
	icon_living = "babyellow"
	icon_dead = "babyellow"
	icon_gib = "babyellow"
	adult_version = /mob/living/simple_animal/farm/raptor/yellow
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = null

/mob/living/simple_animal/farm/raptor_chick/red
	name = "\improper red baby raptor"
	icon_state = "babyred"
	icon_living = "babyred"
	icon_dead = "babyred"
	icon_gib = "babyred"
	adult_version = /mob/living/simple_animal/farm/raptor/red
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/carnivore

/mob/living/simple_animal/farm/raptor_chick/green
	name = "\improper green baby raptor"
	icon_state = "babygreen"
	icon_living = "babygreen"
	icon_dead = "babygreen"
	icon_gib = "babygreen"
	adult_version = /mob/living/simple_animal/farm/raptor/green
	default_breeding_trait = /datum/farm_animal_trait/egg_layer
	default_food_trait = /datum/farm_animal_trait/herbivore