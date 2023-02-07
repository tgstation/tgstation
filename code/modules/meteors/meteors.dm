#define DEFAULT_METEOR_LIFETIME 1800
#define MAP_EDGE_PAD 5

GLOBAL_VAR_INIT(meteor_wave_delay, 625) //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round
// This spelling mistake? Name? is older then git, I'm scared to touch it

//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(/obj/effect/meteor/dust=3, /obj/effect/meteor/medium=8, /obj/effect/meteor/big=3, \
						  /obj/effect/meteor/flaming=1, /obj/effect/meteor/irradiated=3, /obj/effect/meteor/carp=1, /obj/effect/meteor/bluespace=1, \
						  /obj/effect/meteor/banana=1, /obj/effect/meteor/emp = 1)) //for normal meteor event

GLOBAL_LIST_INIT(meteors_threatening, list(/obj/effect/meteor/medium=4, /obj/effect/meteor/big=8, /obj/effect/meteor/flaming=3, \
						  /obj/effect/meteor/irradiated=3, /obj/effect/meteor/cluster=1, /obj/effect/meteor/carp=1, /obj/effect/meteor/bluespace=2, /obj/effect/meteor/emp = 2)) //for threatening meteor event

GLOBAL_LIST_INIT(meteors_catastrophic, list(/obj/effect/meteor/medium=5, /obj/effect/meteor/big=75, \
						  /obj/effect/meteor/flaming=10, /obj/effect/meteor/irradiated=10, /obj/effect/meteor/cluster=8, /obj/effect/meteor/tunguska=1, \
						  /obj/effect/meteor/carp=2, /obj/effect/meteor/bluespace=10, /obj/effect/meteor/emp = 8)) //for catastrophic meteor event

GLOBAL_LIST_INIT(meateors, list(/obj/effect/meteor/meaty=5, /obj/effect/meteor/meaty/xeno=1)) //for meaty ore event

GLOBAL_LIST_INIT(meteors_dust, list(/obj/effect/meteor/dust=1)) //for space dust event

GLOBAL_LIST_INIT(meteors_stray, list(/obj/effect/meteor/medium=15, /obj/effect/meteor/big=10, \
						  /obj/effect/meteor/flaming=25, /obj/effect/meteor/irradiated=30, /obj/effect/meteor/carp=25, /obj/effect/meteor/bluespace=30, \
						  /obj/effect/meteor/banana=25, /obj/effect/meteor/meaty=10, /obj/effect/meteor/meaty/xeno=8, /obj/effect/meteor/emp = 30, \
						  /obj/effect/meteor/cluster=20, /obj/effect/meteor/tunguska=1)) //for stray meteor event (bigger numbers for a bit finer weighting)

GLOBAL_LIST_INIT(meteors_sandstorm, list(/obj/effect/meteor/sand=45, /obj/effect/meteor/dust=5)) //for sandstorm event

///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(number = 10, list/meteor_types, direction)
	for(var/i in 1 to number)
		spawn_meteor(meteor_types, direction)

/proc/spawn_meteor(list/meteor_types, direction)
	if (SSmapping.is_planetary())
		stack_trace("Tried to spawn meteors in a map which isn't in space.")
		return // We're not going to find any space turfs here
	var/turf/picked_start
	var/turf/picked_goal
	var/max_i = 10//number of tries to spawn meteor.
	while(!isspaceturf(picked_start))
		var/start_side
		if(direction) //If a direction has been specified, we set start_side to it. Otherwise, pick randomly
			start_side = direction
		else
			start_side = pick(GLOB.cardinals)
		var/start_Z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
		picked_start = spaceDebrisStartLoc(start_side, start_Z)
		picked_goal = spaceDebrisFinishLoc(start_side, start_Z)
		max_i--
		if(max_i <= 0)
			return
	var/new_meteor = pick_weight(meteor_types)
	new new_meteor(picked_start, picked_goal)

/proc/spaceDebrisStartLoc(start_side, Z)
	var/starty
	var/startx
	switch(start_side)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			starty = rand((TRANSITIONEDGE + MAP_EDGE_PAD),world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			starty = (TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			starty = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = (TRANSITIONEDGE + MAP_EDGE_PAD)
	. = locate(startx, starty, Z)

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = (TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			endy = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = (TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			endy = world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			endy = rand((TRANSITIONEDGE + MAP_EDGE_PAD),world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD)
	. = locate(endx, endy, Z)

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "\proper the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = TRUE
	anchored = TRUE
	pass_flags = PASSTABLE

	///The resilience of our meteor
	var/hits = 4
	///Level of ex_act to be called on hit.
	var/hitpwr = EXPLODE_HEAVY
	//Should we shake people's screens on impact
	var/heavy = FALSE
	///Sound to play when you hit something
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	///Our starting z level, prevents infinite meteors
	var/z_original
	///Used for determining which meteors are most interesting
	var/threat = 0

	//Potential items to spawn when you die
	var/list/meteordrop = list(/obj/item/stack/ore/iron)
	///How much stuff to spawn when you die
	var/dropamt = 2

	///The thing we're moving towards, usually a turf
	var/atom/dest
	///Lifetime in seconds
	var/lifetime = DEFAULT_METEOR_LIFETIME

	///Used by Stray Meteor event to indicate meteor type (the type of sensor that "detected" it) in announcement
	var/signature = "motion"

/obj/effect/meteor/Initialize(mapload, turf/target)
	. = ..()
	z_original = z
	GLOB.meteor_list += src
	SSaugury.register_doom(src, threat)
	SpinAnimation()
	chase_target(target)

/obj/effect/meteor/Destroy()
	GLOB.meteor_list -= src
	return ..()

/obj/effect/meteor/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(QDELETED(src))
		return

	if(old_loc != loc)//If did move, ram the turf we get in
		var/turf/T = get_turf(loc)
		ram_turf(T)

		if(prob(10) && !isspaceturf(T))//randomly takes a 'hit' from ramming
			get_hit()

	if(z != z_original || loc == get_turf(dest))
		qdel(src)
		return

/obj/effect/meteor/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE //Keeps us from drifting for no reason

/obj/effect/meteor/Bump(atom/A)
	. = ..() //What could go wrong
	if(A)
		ram_turf(get_turf(A))
		playsound(src.loc, meteorsound, 40, TRUE)
		get_hit()

/obj/effect/meteor/proc/chase_target(atom/chasing, delay, home)
	if(!isatom(chasing))
		return
	var/datum/move_loop/new_loop = SSmove_manager.move_towards(src, chasing, delay, home, lifetime)
	if(!new_loop)
		return

	RegisterSignal(new_loop, COMSIG_PARENT_QDELETING, PROC_REF(handle_stopping))

///Deals with what happens when we stop moving, IE we die
/obj/effect/meteor/proc/handle_stopping()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/effect/meteor/proc/ram_turf(turf/T)
	//first yell at mobs about them dying horribly
	for(var/mob/living/thing in T)
		thing.visible_message(span_warning("[src] slams into [thing]."), span_userdanger("[src] slams into you!."))

	//then, ram the turf
	switch(hitpwr)
		if(EXPLODE_DEVASTATE)
			SSexplosions.highturf += T
		if(EXPLODE_HEAVY)
			SSexplosions.medturf += T
		if(EXPLODE_LIGHT)
			SSexplosions.lowturf += T

//process getting 'hit' by colliding with a dense object
//or randomly when ramming turfs
/obj/effect/meteor/proc/get_hit()
	hits--
	if(hits <= 0)
		make_debris()
		meteor_effect()
		qdel(src)

/obj/effect/meteor/examine(mob/user)
	. = ..()

	check_examine_award(user)

/obj/effect/meteor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MINING)
		make_debris()
		qdel(src)
	else
		. = ..()

/obj/effect/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/thing_to_spawn = pick(meteordrop)
		new thing_to_spawn(get_turf(src))

/obj/effect/meteor/proc/meteor_effect()
	if(heavy)
		var/sound/meteor_sound = sound(meteorsound)
		var/random_frequency = get_rand_frequency()

		for(var/mob/M in GLOB.player_list)
			if((M.orbiting) && (SSaugury.watchers[M]))
				continue
			var/turf/T = get_turf(M)
			if(!T || T.z != src.z)
				continue
			var/dist = get_dist(M.loc, src.loc)
			shake_camera(M, dist > 20 ? 2 : 4, dist > 20 ? 1 : 3)
			M.playsound_local(src.loc, null, 50, 1, random_frequency, 10, sound_to_use = meteor_sound)

/**
 * Used to check if someone who has examined a meteor will recieve an award.
 *
 * Checks the criteria to recieve the "examine a meteor" award.
 * Admin spawned meteors will not grant the user an achievement.
 *
 * Arguments:
 * * user - the person who will be recieving the examine award.
 */

/obj/effect/meteor/proc/check_examine_award(mob/user)
	if(!(flags_1 & ADMIN_SPAWNED_1) && isliving(user))
		user.client.give_award(/datum/award/achievement/misc/meteor_examine, user)

///////////////////////
//Meteor types
///////////////////////

//Sand
/obj/effect/meteor/sand
	name = "space sand"
	icon_state = "dust"
	hits = 2
	hitpwr = EXPLODE_LIGHT
	meteorsound = 'sound/items/dodgeball.ogg'
	threat = 1

/obj/effect/meteor/sand/make_debris()
	return //We drop NOTHING

/obj/effect/meteor/sand/ram_turf(turf/turf_to_ram)
	if(istype(turf_to_ram, /turf/closed/wall)) //sand is too weak to affect rwalls or walls with similar durability.
		var/turf/closed/wall/wall_to_ram = turf_to_ram
		if(wall_to_ram.hardness <= 25)
			return

	var/area/area_to_check = get_area(turf_to_ram)
	if(area_to_check.area_flags & EVENT_PROTECTED) //This event absolutely destroys arrivals, and putting latejoiners into firelock hell is cringe
		return

	return ..()

/obj/effect/meteor/sand/check_examine_award(mob/user) //Too insignificant and predictable to warrant an award.
	return

//Dust
/obj/effect/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = EXPLODE_LIGHT
	meteorsound = 'sound/weapons/gun/smg/shot.ogg'
	meteordrop = list(/obj/item/stack/ore/glass)
	threat = 1

//Medium-sized
/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 3
	threat = 5

/obj/effect/meteor/medium/meteor_effect()
	..()
	explosion(src, heavy_impact_range = 1, light_impact_range = 2, flash_range = 3, adminlog = FALSE)

//Large-sized
/obj/effect/meteor/big
	name = "big meteor"
	icon_state = "large"
	hits = 6
	heavy = TRUE
	dropamt = 4
	threat = 10

/obj/effect/meteor/big/meteor_effect()
	..()
	explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 4, adminlog = FALSE)

//Flaming meteor
/obj/effect/meteor/flaming
	name = "flaming meteor"
	desc = "An veritable shooting star, both beautiful and frightening. You should probably keep your distance from this."
	icon_state = "flaming"
	hits = 5
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 20
	signature = "thermal"

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flame_range = 5, flash_range = 4, adminlog = FALSE)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	desc = "An irradiated chunk of space rock. You could probably stop and appreciate its incandescent green glow, if it weren't moving so fast."
	icon_state = "glowing"
	heavy = TRUE
	meteordrop = list(/obj/item/stack/ore/uranium)
	threat = 15
	signature = "radiation"

/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(src, light_impact_range = 4, flash_range = 3, adminlog = FALSE)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	radiation_pulse(src, max_range = 3, threshold = RAD_MEDIUM_INSULATION, chance = 80)

//Cluster meteor
/obj/effect/meteor/cluster
	name = "cluster meteor"
	desc = "A cluster of densely packed rocks, with a volatile core. You should probably get out of the way."
	icon_state = "sharp"
	hits = 9
	heavy = TRUE
	meteorsound = 'sound/effects/break_stone.ogg'
	threat = 25
	signature = "ordnance"
	///Number of fragmentation meteors to be spawned
	var/cluster_count = 8

/obj/effect/meteor/cluster/meteor_effect()
	..()

	var/start_turf = get_turf(src)

	while(cluster_count > 0)
		var/startSide = pick(GLOB.cardinals)
		var/turf/destination = spaceDebrisStartLoc(startSide, z)
		new /obj/effect/meteor/cluster_fragment(start_turf, destination)
		cluster_count--

	explosion(src, heavy_impact_range = 2, light_impact_range = 3, flash_range = 4, adminlog = FALSE)

/obj/effect/meteor/cluster_fragment
	name = "cluster meteor fragment"
	desc = "A fast-moving fragment of exploded cluster-rock."
	icon_state = "dust"

//frozen carp "meteor"
/obj/effect/meteor/carp
	name = "frozen carp"
	icon_state = "carp"
	desc = "Am I glad he's frozen in there, and that we're out here."
	hits = 4
	meteorsound = 'sound/effects/ethereal_revive_fail.ogg'
	meteordrop = list(/mob/living/basic/carp)
	dropamt = 1
	threat = 5
	signature = "fishing and trawling"

/obj/effect/meteor/carp/Initialize(mapload)
	if(prob(2))
		meteordrop = list(/mob/living/basic/carp/mega) //hehe
	return ..()

//bluespace meteor
/obj/effect/meteor/bluespace
	name = "bluespace meteor"
	desc = "A large geode containing bluespace dust at its core, hurtling through space. That's the stuff the crew are here to research. How convenient for them."
	icon_state = "bluespace"
	dropamt = 3
	hits = 12
	meteordrop = list(/obj/item/stack/ore/bluespace_crystal)
	threat = 15
	signature = "bluespace flux"

/obj/effect/meteor/bluespace/Bump()
	..()
	if(prob(35))
		do_teleport(src, get_turf(src), 6, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/effect/meteor/banana
	name = "bananium meteor"
	desc = "Maybe it's a chunk blasted off of the legendary Clown Planet... How annoying."
	icon_state = "bananium"
	dropamt = 4
	hits = 175 //Honks everything, including space tiles. Depending on the angle/how much stuff it hits, there's a fair chance that it will spare the station from the actual explosion
	meteordrop = list(/obj/item/stack/ore/bananium)
	meteorsound = 'sound/items/bikehorn.ogg'
	threat = 15
	movement_type = PHASING
	signature = "comedy"

/obj/effect/meteor/banana/meteor_effect()
	..()
	playsound(src, 'sound/items/AirHorn.ogg', 100, TRUE, -1)
	for(var/atom/movable/object in view(4, get_turf(src)))
		var/turf/throwtarget = get_edge_target_turf(get_turf(src), get_dir(get_turf(src), get_step_away(object, get_turf(src))))
		object.safe_throw_at(throwtarget, 5, 1, force = MOVE_FORCE_STRONG)

/obj/effect/meteor/banana/ram_turf(turf/bumped)
	for(var/mob/living/slipped in get_turf(bumped))
		slipped.slip(100, slipped.loc,- GALOSHES_DONT_HELP|SLIDE, 0, FALSE)
		slipped.visible_message(span_warning("[src] honks [slipped] to the floor!"), span_userdanger("[src] harmlessly passes through you, knocking you over."))
	get_hit()

/obj/effect/meteor/emp
	name = "electromagnetically charged meteor"
	desc = "It radiates with captive energy, ready to be let loose upon the world."
	icon_state = "bluespace"
	hits = 6
	threat = 10
	signature = "electromagnetic interference"

/obj/effect/meteor/emp/Move()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/impact_effect/ion(get_turf(src))

/obj/effect/meteor/emp/meteor_effect()
	..()
	playsound(src, 'sound/weapons/zapbang.ogg', 100, TRUE, -1)
	empulse(src, 3, 8)

//Meaty Ore
/obj/effect/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	hits = 2
	heavy = TRUE
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = list(/obj/item/food/meat/slab/human, /obj/item/food/meat/slab/human/mutant, /obj/item/organ/internal/heart, /obj/item/organ/internal/lungs, /obj/item/organ/internal/tongue, /obj/item/organ/internal/appendix/)
	var/meteorgibs = /obj/effect/gibspawner/generic
	threat = 2
	signature = "culinary material"

/obj/effect/meteor/meaty/Initialize(mapload)
	for(var/path in meteordrop)
		if(path == /obj/item/food/meat/slab/human/mutant)
			meteordrop -= path
			meteordrop += pick(subtypesof(path))

	for(var/path in meteordrop)
		if(path == /obj/item/organ/internal/tongue)
			meteordrop -= path
			meteordrop += pick(typesof(path))
	return ..()

/obj/effect/meteor/meaty/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/effect/meteor/meaty/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/blood(T)

/obj/effect/meteor/meaty/Bump(atom/A)
	EX_ACT(A, hitpwr)
	get_hit()

//Meaty Ore Xeno edition
/obj/effect/meteor/meaty/xeno
	color = "#5EFF00"
	meteordrop = list(/obj/item/food/meat/slab/xeno, /obj/item/organ/internal/tongue/alien)
	meteorgibs = /obj/effect/gibspawner/xeno
	signature = "exotic culinary material"

/obj/effect/meteor/meaty/xeno/Initialize(mapload)
	meteordrop += subtypesof(/obj/item/organ/internal/alien)
	return ..()

/obj/effect/meteor/meaty/xeno/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/xenoblood(T)

//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstrosity."
	hits = 30
	hitpwr = EXPLODE_DEVASTATE
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)
	threat = 50
	signature = "armageddon"

/obj/effect/meteor/tunguska/Move()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/revenant(get_turf(src))

/obj/effect/meteor/tunguska/meteor_effect()
	..()
	explosion(src, devastation_range = 5, heavy_impact_range = 10, light_impact_range = 15, flash_range = 20, adminlog = FALSE)

/obj/effect/meteor/tunguska/Bump()
	..()
	if(prob(20))
		explosion(src, devastation_range = 2, heavy_impact_range = 4, light_impact_range = 6, flash_range = 8, adminlog = FALSE)

//////////////////////////
//Spookoween meteors
/////////////////////////

GLOBAL_LIST_INIT(meteorsSPOOKY, list(/obj/effect/meteor/pumpkin))

/obj/effect/meteor/pumpkin
	name = "PUMPKING"
	desc = "THE PUMPKING'S COMING!"
	icon = 'icons/obj/meteor_spooky.dmi'
	icon_state = "pumpkin"
	hits = 10
	heavy = TRUE
	dropamt = 1
	meteordrop = list(/obj/item/clothing/head/utility/hardhat/pumpkinhead, /obj/item/food/grown/pumpkin)
	threat = 100

/obj/effect/meteor/pumpkin/Initialize(mapload)
	. = ..()
	meteorsound = pick('sound/hallucinations/im_here1.ogg','sound/hallucinations/im_here2.ogg')
//////////////////////////
#undef DEFAULT_METEOR_LIFETIME
#undef MAP_EDGE_PAD
