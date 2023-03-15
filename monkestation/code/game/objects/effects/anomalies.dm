//Radioactive Anomaly (Radioactive Goo)

/obj/effect/anomaly/radioactive
	name = "Radioactive Anomaly"
	desc = "A highly unstable mass of charged particles leaving waste material in it's wake."
	icon_state = "shield-grey"
	color = "#86c4dd"
	var/active = TRUE

/obj/effect/anomaly/radioactive/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/radioactive/Destroy()
	. = ..()
	RemoveElement(/datum/element/connect_loc)

/obj/effect/anomaly/radioactive/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER
	if(active && isliving(atom_movable))
		var/mob/living/victim = atom_movable
		active = FALSE
		victim.Paralyze(1 SECONDS)
		var/atom/target = get_edge_target_turf(victim, get_dir(src, get_step_away(victim, src)))
		victim.throw_at(target, 3, 1)
		radiation_pulse(victim, 100)
		to_chat(victim, "<span class='danger'>You're hit with a force of atomic energy!</span>")

/obj/effect/anomaly/radioactive/anomalyEffect(delta_time)
	..()
	active = TRUE

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	radiation_pulse(src, 50)
	if(!locate(/obj/effect/decal/nuclear_waste) in src.loc)
		playsound(src, pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg', 'sound/misc/desecration-03.ogg'), vol = 50, vary = 1)
		new /obj/effect/decal/nuclear_waste(src.loc)
		if(prob(33))
			new /obj/effect/decal/nuclear_waste/epicenter(src.loc)

/obj/effect/anomaly/radioactive/detonate()
	playsound(src, 'sound/effects/empulse.ogg', vol = 100, vary = 1)
	radiation_pulse(src, 500)


//Fluid Anomaly (Random Fluid)

#define NORMAL_FLUID_AMOUNT 25
#define DANGEROUS_FLUID_AMOUNT 100

/obj/effect/anomaly/fluid
	name = "Fluidic Anomaly"
	desc = "An anomaly pulling in liquids from places unknown. Better get the mop."
	icon_state = "bluestream_fade"
	var/dangerous = FALSE
	var/list/fluid_choices = list()

/obj/effect/anomaly/fluid/Initialize(mapload, new_lifespan)
	. = ..()
	if(prob(10))
		dangerous = TRUE //Unrestricts the reagent choice and increases fluid amounts

	for(var/i = 1, i <= rand(1,5), i++) //Between 1 and 5 random chemicals
		fluid_choices += dangerous ? get_unrestricted_random_reagent_id() : get_random_reagent_id()

/obj/effect/anomaly/fluid/anomalyEffect(delta_time)
	..()

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	var/turf/spawn_point = get_turf(src)
	spawn_point.add_liquid(pick(fluid_choices), dangerous ? DANGEROUS_FLUID_AMOUNT : NORMAL_FLUID_AMOUNT, chem_temp = rand(BODYTEMP_COLD_DAMAGE_LIMIT, BODYTEMP_HEAT_DAMAGE_LIMIT))

/obj/effect/anomaly/fluid/detonate()

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	var/turf/spawn_point = get_turf(src)
	spawn_point.add_liquid(pick(fluid_choices), (dangerous ? DANGEROUS_FLUID_AMOUNT : NORMAL_FLUID_AMOUNT) * 5, chem_temp = rand(BODYTEMP_COLD_DAMAGE_LIMIT, BODYTEMP_HEAT_DAMAGE_LIMIT))

#undef NORMAL_FLUID_AMOUNT
#undef DANGEROUS_FLUID_AMOUNT

//Storm Anomaly (Lightning)

#define STORM_MIN_RANGE 2
#define STORM_MAX_RANGE 4
#define STORM_POWER_LEVEL 1000


/obj/effect/anomaly/storm
	name = "Storm Anomaly"
	desc = "The power of a tesla contained in an anomalous crackling orb."
	icon_state = "electricity2"
	lifespan = 30 SECONDS //Way too strong to give a full 99 seconds.
	var/active = TRUE


/obj/effect/anomaly/storm/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/storm/Destroy()
	. = ..()
	RemoveElement(/datum/element/connect_loc)

/obj/effect/anomaly/storm/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER

	if(active && iscarbon(atom_movable))
		var/mob/living/carbon/target = atom_movable
		active = FALSE
		target.electrocute_act(10, "[name]", flags = SHOCK_NOGLOVES)
		target.adjustFireLoss(10)

/obj/effect/anomaly/storm/anomalyEffect(delta_time)
	..()
	if(!active) //Only works every other tick
		active = TRUE
		return
	active = FALSE

	tesla_zap(src, rand(STORM_MIN_RANGE, STORM_MAX_RANGE), STORM_POWER_LEVEL)

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	var/turf/location = get_turf(src)
	location.atmos_spawn_air("water_vapor=10;TEMP=340")

//No detonation because it's strong enough as it is


#undef STORM_MIN_RANGE
#undef STORM_MAX_RANGE
#undef STORM_POWER_LEVEL


//Frost Anomaly (Freezing)
//THE STATION MUST SURVIVE

#define MIN_REPLACEMENT 2
#define MAX_REPLACEMENT 7
#define MAX_RANGE 7

/obj/effect/anomaly/frost
	name = "Freezing Anomaly"
	desc = "An frigid anomaly that coats all in thick snow. Prepare the furnace, the station must survive."
	icon_state = "impact_laser_blue"

/obj/effect/anomaly/frost/anomalyEffect(delta_time)
	..()

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	var/turf/current_location = get_turf(src)
	var/list/valid_turfs = list()
	var/static/list/blacklisted_turfs = typecacheof(list(
		/turf/closed,
		/turf/open/space,
		/turf/open/lava,
		/turf/open/chasm,
		/turf/open/floor/plating/asteroid/snow))

	current_location.atmos_spawn_air("water_vapor=10;TEMP=180")

	for(var/searched_turfs in circle_view_turfs(src, MAX_RANGE))
		if(is_type_in_typecache(searched_turfs, blacklisted_turfs))
			continue
		else
			valid_turfs |= searched_turfs
	for(var/i = 1, i <= rand(MIN_REPLACEMENT, MAX_REPLACEMENT), i++) //Replace 2-7 tiles with snow
		var/turf/searched_turfs = safepick(valid_turfs)
		if(searched_turfs)
			if(istype(searched_turfs, /turf/open/floor/plating))
				searched_turfs.PlaceOnTop(/turf/open/floor/plating/asteroid/snow)
			else
				searched_turfs.ChangeTurf(/turf/open/floor/plating/asteroid/snow)

/obj/effect/anomaly/frost/detonate()
	//The station holds its breath, waiting for whatever the end will bring.

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	var/turf/current_location = get_turf(src)
	current_location.atmos_spawn_air("water_vapor=400;TEMP=140") //The cold will be brutal. The water in hydroponics will freeze. We'll have to make do with the food we've stockpiled.

#undef MIN_REPLACEMENT
#undef MAX_REPLACEMENT
#undef MAX_RANGE

//Pet Anomaly (Random Pets)
//Amazingly, this could be the ultimate powergamer's anomaly.
//Your mood will shoot sky high petting all of these animals.

/obj/effect/anomaly/petsplosion //LMAO 2CAT
	name = "Lifebringer Anomaly"
	desc = "An anomalous gateway that seemingly creates new life out of nowhere. Known by Lavaland Dwarves as the \"Petsplosion\"."
	icon_state = "bluestream_fade"
	lifespan = 30 SECONDS //I don't want too many mobs swarming the area
	var/active = TRUE
	var/list/pet_type_cache

/obj/effect/anomaly/petsplosion/Initialize(mapload, new_lifespan)
	. = ..()
	pet_type_cache = subtypesof(/mob/living/simple_animal/pet)
	pet_type_cache -= list(/mob/living/simple_animal/pet/penguin, //Removing the risky and broken ones.
		/mob/living/simple_animal/pet/dog/corgi/narsie,
		/mob/living/simple_animal/pet/gondola/gondolapod,
		/mob/living/simple_animal/pet/gondola,
		/mob/living/simple_animal/pet/dog)

	pet_type_cache += list(/mob/living/simple_animal/cow, //Adding the ones that should be under /pet, but aren't. Maybe I need to fix that.
		/mob/living/simple_animal/sloth,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/cockroach,
		/mob/living/simple_animal/crab)

/obj/effect/anomaly/petsplosion/anomalyEffect(delta_time)
	..()

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	if(active)
		var/mob/living/simple_animal/pet/chosen_pet = pick(pet_type_cache)
		new chosen_pet(src.loc)
		active = FALSE
		return

	active = TRUE

//Clown Anomaly (H O N K)
#define HONK_RANGE 3

/obj/effect/anomaly/clown
	name = "Honking Anomaly"
	desc = "An anomaly that smells faintly of bananas and lubricant."
	icon_state = "static"
	lifespan = 40 SECONDS //Rapid, chaotic and slippery.
	var/active = TRUE
	var/static/list/clown_spawns = list(
		/mob/living/simple_animal/hostile/retaliate/clown/clownhulk/chlown = 6,
		/mob/living/simple_animal/hostile/retaliate/clown = 66,
		/obj/item/grown/bananapeel = 33,
		/obj/item/stack/ore/bananium = 12,
		/obj/item/bikehorn = 15)


/obj/effect/anomaly/clown/Initialize(mapload, new_lifespan)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/anomaly/clown/Destroy()
	. = ..()
	RemoveElement(/datum/element/connect_loc)

/obj/effect/anomaly/clown/proc/on_entered(datum/source, atom/movable/atom_movable)
	SIGNAL_HANDLER

	if(active && iscarbon(atom_movable))
		var/mob/living/carbon/target = atom_movable
		active = FALSE
		target.slip(2 SECONDS, src)
		playsound(src, 'sound/effects/laughtrack.ogg', vol = 50, vary = 1)

/obj/effect/anomaly/clown/anomalyEffect(delta_time)
	..()

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	var/turf/open/current_location = get_turf(src)
	current_location.MakeSlippery(TURF_WET_LUBE, min_wet_time = 20 SECONDS, wet_time_to_add = 5 SECONDS)
	if(active)
		active = FALSE
		playsound(src, 'sound/items/bikehorn.ogg', vol = 50)
		var/selected_spawn = pickweight(clown_spawns)
		new selected_spawn(src.loc)
		return
	active = TRUE

/obj/effect/anomaly/clown/detonate()

	playsound(src, 'sound/items/airhorn.ogg', vol = 100, vary = 1)

	for(var/mob/living/carbon/target in (hearers(HONK_RANGE, src)))
		to_chat(target, "<font color='red' size='7'>HONK</font>")
		target.SetSleeping(0)
		target.stuttering += 2 SECONDS
		target.adjustEarDamage(ddmg = 0, ddeaf = 2 SECONDS)
		target.Knockdown(2 SECONDS)
		target.Jitter(50)

#undef HONK_RANGE

//Monkey Anomaly (Random Chimp Event)

#define MONKEY_SOUNDS list('sound/creatures/monkey/monkey_screech_1.ogg', 'sound/creatures/monkey/monkey_screech_2.ogg', 'sound/creatures/monkey/monkey_screech_3.ogg','sound/creatures/monkey/monkey_screech_4.ogg','sound/creatures/monkey/monkey_screech_5.ogg','sound/creatures/monkey/monkey_screech_6.ogg','sound/creatures/monkey/monkey_screech_7.ogg')

/obj/effect/anomaly/monkey
	name = "Screeching Anomaly"
	desc = "An anomalous one-way gateway that leads straight to some sort of a planet of apes"
	icon_state = "bhole3"
	lifespan = 35 SECONDS //Rapid swarm of maybe ten monkeys.
	var/active = TRUE

/obj/effect/anomaly/monkey/anomalyEffect(delta_time)
	..()

	playsound(src, pick(MONKEY_SOUNDS), vol = 33, vary = 1, mixer_channel = CHANNEL_MOB_SOUNDS)

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	if(!active)
		active = TRUE
		return

	if(prob(10))
		new /mob/living/carbon/monkey/angry(src.loc)
	else
		new /mob/living/carbon/monkey(src.loc)
	active = FALSE

/obj/effect/anomaly/monkey/detonate()
	if(prob(10))
		new /mob/living/simple_animal/hostile/gorilla(src.loc)


#undef MONKEY_SOUNDS

//Walter Anomaly (The Walterverse Opens...)

/obj/effect/anomaly/walterverse
	name = "Walter Anomaly"
	desc = "An anomaly that summons Walters from all throughout the walterverse"
	icon_state = "bhole3"
	lifespan = 20 SECONDS //about maybe 5 walters
	var/active = TRUE
	var/static/list/walter_spawns = list(
		/mob/living/simple_animal/pet/dog/bullterrier/walter/saulter = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/negative = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/syndicate = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/doom = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/space = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/clown = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/french = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/british = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/wizard = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/smallter = 5,
		/mob/living/simple_animal/pet/dog/bullterrier/walter/sus = 1, //:(
		)

/obj/effect/anomaly/walterverse/anomalyEffect(delta_time)
	..()

	if(isinspace(src) || !isopenturf(get_turf(src)))
		return

	if(active)
		active = FALSE
		var/selected_spawn = pickweight(walter_spawns)
		new selected_spawn(src.loc)
		return
	active = TRUE

/obj/effect/anomaly/walterverse/detonate()
	if(prob(10))
		new /mob/living/simple_animal/pet/dog/bullterrier/walter(src.loc)
