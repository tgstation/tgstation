// Ratwood's water on the Rockhill water of the module (/turf/open/water/rockhill, rockhill/bases.dm) on medieval maps
// (code/game/turfs/open/water.dm, modules/hotspring/hotspring.dm): leaving deep water - rivers, ponds, the sea, the deep bog,
// the dyed pond of the bathhouse - costs a swimmer stamina by the heaviest armour on them and their Swimming, which they learn
// by it; one who can hold on to the shore swims for free, and the river carries whoever goes with it. Running out of stamina in
// the water stuns. Cold water chills whoever wades in it, the bog sets leeches on waders, blood bloodies them, Abyssor's cursed
// are burnt by any water, and the healing hot spring mends whoever soaks in it. The hot springs of the baths steam. Washing and
// bathing are survival/washing.dm, drawing water survival/vessels.dm, drinking survival/thirst.dm, fishing rockhill/fishing.dm.

/// Ratwood water this cold or colder chills whoever wades in it and cools whoever washes in it (turf temperature <= 250).
#define WATER_COLD 250
/// Ratwood water this warm or warmer is a bath: washing in it warms the cold and cools the hot (temperature >= 300).
#define WATER_WARM 300

/turf/open/water/rockhill
	/// Ratwood temperature: the water's own temperature in kelvin, which chills (WATER_COLD) or soothes (WATER_WARM).
	var/rogue_water_temperature = 210
	/// Ratwood swim_skill: deep enough to swim, which costs stamina and teaches Swimming.
	var/rogue_swim = FALSE
	/// Ratwood wash_in: washing here cleans (sewage and blood leave one as dirty as before).
	var/rogue_wash_in = TRUE
	/// Ratwood: washing here may leave a leech on the washer (sewers and bogs).
	var/rogue_foul_wash = FALSE
	/// Ratwood sewer: washing here leaves one reeking of it (sewertouched).
	var/rogue_sewage = FALSE
	/// Ratwood bloody water: it bloodies whoever wades or washes in it, and what is washed in it.
	var/rogue_bloody = FALSE
	/// Ratwood bath: an empty-handed wash while standing in it is a relaxing soak (survival/washing.dm).
	var/rogue_bath = FALSE

/turf/open/water/bath
	rogue_water_temperature = 300
	rogue_bath = TRUE

/turf/open/water/bath/fakepond
	rogue_swim = TRUE

/turf/open/water/bloody
	rogue_water_temperature = 300
	rogue_wash_in = FALSE
	rogue_bloody = TRUE

/turf/open/water/ocean
	rogue_swim = TRUE

/turf/open/water/ocean/deep/thermalwater
	rogue_water_temperature = 300
	/// When it last mended those soaking in it (Ratwood last_heal).
	var/rogue_last_heal = 0

/turf/open/water/pond
	rogue_swim = TRUE

/turf/open/water/river
	rogue_swim = TRUE

/turf/open/water/sewer
	rogue_water_temperature = 300
	rogue_wash_in = FALSE
	rogue_foul_wash = TRUE
	rogue_sewage = TRUE

/turf/open/water/swamp
	rogue_water_temperature = 275
	rogue_foul_wash = TRUE

/turf/open/water/swamp/deep
	rogue_swim = TRUE

/// The water is cold enough to chill (Ratwood temperature <= 250).
/turf/open/water/rockhill/proc/rogue_cold_water()
	return rogue_water_temperature <= WATER_COLD

/// Washing in it cools the washer down (Ratwood temperature < 250).
/turf/open/water/rockhill/proc/rogue_cooling_water()
	return rogue_water_temperature < WATER_COLD

/// The water is warm enough to soothe (Ratwood temperature >= 300).
/turf/open/water/rockhill/proc/rogue_warm_water()
	return rogue_water_temperature >= WATER_WARM

// --- Into the water and out of it

/turf/open/water/rockhill/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	arrived.rogue_entered_water(src, old_loc)

/// Something came into Ratwood water (turf/open/water Entered()); fish swim off (rockhill/fishing.dm), the living wade.
/atom/movable/proc/rogue_entered_water(turf/open/water/rockhill/water, atom/old_loc)
	return

/mob/living/rogue_entered_water(turf/open/water/rockhill/water, atom/old_loc)
	if(throwing || (movement_type & FLYING) || !rogue_survival_enabled())
		return
	water.rogue_wade(src)

/// Ratwood Entered() of a living one: Abyssor's cursed burn, blood bloodies, cold water chills, the bog may leave a leech. In a
/// boat or on a mount only the curse reaches.
/turf/open/water/rockhill/proc/rogue_wade(mob/living/wader)
	if(HAS_TRAIT(wader, TRAIT_CURSE_ABYSSOR))
		wader.visible_message(span_warning("[wader] spasms violently upon touching the water!"), span_danger("The water... it burns me!"))
		wader.adjust_fire_loss(rogue_value("swim_cursed_burn"))
		return
	if(wader.buckled)
		return
	if(rogue_bloody)
		wader.add_blood_DNA(wader.get_blood_dna_list())
	if(rogue_cold_water())
		wader.rogue_chill(rogue_value("swim_cold_chill"), HAS_TRAIT(wader, TRAIT_WATERLOVING) ? BODYTEMP_NORMAL : rogue_value("swim_cold_floor"))
	var/chance = rogue_leech_chance(wader)
	if(chance && prob(chance))
		rogue_set_wild_leech(wader, rogue_leech_zones())

/turf/open/water/rockhill/Exited(atom/movable/gone, direction)
	. = ..()
	if(!rogue_swim || !ishuman(gone) || gone.throwing || !rogue_survival_enabled())
		return
	var/mob/living/carbon/human/swimmer = gone
	var/drain = rogue_swim_drain(swimmer, direction)
	if(drain <= 0)
		return
	swimmer.adjust_stamina_loss(drain)
	if(swimmer.get_stamina_loss() < swimmer.max_stamina)
		return
	// Ratwood: out of stamina in the water - held fast, then under.
	var/stun = rogue_value("swim_exhausted_stun")
	swimmer.Immobilize(stun)
	addtimer(CALLBACK(swimmer, TYPE_PROC_REF(/mob/living, Knockdown), stun), rogue_value("swim_exhausted_delay"))

/// Ratwood get_stamina_drain(): what leaving this water in travel_dir costs a swimmer. Nothing to one carried, pulled, in a boat
/// or flying, going with the river, or holding on to the shore; otherwise the heaviest armour's toll less their Swimming, more if
/// they are untrained for that armour - and every stroke teaches Swimming, less in heavier armour.
/turf/open/water/rockhill/proc/rogue_swim_drain(mob/living/carbon/human/swimmer, travel_dir)
	if(!rogue_swim || swimmer.pulledby || swimmer.buckled || (swimmer.movement_type & (FLYING|FLOATING)))
		return 0
	if(rockhill_flow && travel_dir == dir)
		return 0
	. = swimmer.rogue_swim_cost()
	for(var/direction in GLOB.cardinals)
		if(isfloorturf(get_step(src, direction)))
			return 0

/// Ratwood get_stamina_drain() without the water's part: the stroke's cost by armour and Swimming, and the Swimming it teaches.
/mob/living/carbon/human/proc/rogue_swim_cost()
	var/drain = rogue_value("swim_drain")
	var/learning = rogue_value("swim_xp")
	switch(rogue_swim_armor_class())
		if(ARMOR_CLASS_HEAVY)
			drain = rogue_value("swim_drain_heavy")
			learning = rogue_value("swim_xp_heavy")
		if(ARMOR_CLASS_MEDIUM)
			drain = rogue_value("swim_drain_medium")
			learning = rogue_value("swim_xp_medium")
	var/blessing = HAS_TRAIT(src, TRAIT_ABYSSOR_SWIM) ? rogue_value("swim_abyssor_bonus") : 0
	. = max(drain - rogue_skill_rank(/datum/attribute/skill/misc/swimming) * rogue_value("swim_drain_per_rank") - blessing, rogue_value("swim_drain_min"))
	rogue_craft_experience(/datum/attribute/skill/misc/swimming, rogue_stat(ROGUE_STAT_INTELLIGENCE) * learning, silent = TRUE)
	if(!rogue_armor_trained())
		. += rogue_value("swim_drain_untrained")

/// Ratwood highest_ac_worn(check_hands = TRUE): armour carried in the hands weighs on a swimmer too.
/mob/living/carbon/human/proc/rogue_swim_armor_class()
	. = rogue_highest_armor_class()
	for(var/obj/item/clothing/held in held_items)
		. = max(., held.armor_class)

/// Cools the body by the amount, never below the floor.
/mob/living/proc/rogue_chill(amount, floor)
	if(bodytemperature > floor)
		adjust_bodytemperature(-min(amount, bodytemperature - floor))

/// Warms the body by the amount, never above the ceiling.
/mob/living/proc/rogue_warm(amount, ceiling)
	if(bodytemperature < ceiling)
		adjust_bodytemperature(min(amount, ceiling - bodytemperature))

// --- Wild leeches (Ratwood swamp Entered(), attack_right() in foul water)

/// The chance a wader picks up a leech here.
/turf/open/water/rockhill/proc/rogue_leech_chance(mob/living/wader)
	return 0

/// The limbs a leech of this water takes to.
/turf/open/water/rockhill/proc/rogue_leech_zones()
	return list(BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, BODY_ZONE_CHEST)

/// Ratwood swamp: a running wader picks up leeches twice as often, a sneaking one a third as often.
/turf/open/water/swamp/rogue_leech_chance(mob/living/wader)
	if(!rogue_leech_wader(wader))
		return 0
	var/mob/living/carbon/human/human_wader = wader
	if(human_wader.rogue_sneaking)
		return rogue_value("leech_swamp_sneak_chance")
	return human_wader.move_intent == MOVE_INTENT_RUN ? rogue_value("leech_swamp_run_chance") : rogue_value("leech_swamp_chance")

/turf/open/water/swamp/deep/rogue_leech_chance(mob/living/wader)
	if(!rogue_leech_wader(wader))
		return 0
	var/mob/living/carbon/human/human_wader = wader
	if(human_wader.rogue_sneaking)
		return rogue_value("leech_deep_sneak_chance")
	return human_wader.move_intent == MOVE_INTENT_RUN ? rogue_value("leech_deep_run_chance") : rogue_value("leech_deep_chance")

/turf/open/water/swamp/deep/rogue_leech_zones()
	return list(BODY_ZONE_CHEST, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)

/// Ratwood: leeches take to humans with blood in them, never to the unleechable.
/proc/rogue_leech_wader(mob/living/wader)
	return ishuman(wader) && !HAS_TRAIT(wader, TRAIT_LEECHIMMUNE) && wader.get_blood_volume() > 0

/// Ratwood add_embedded_object() of a new leech: it takes hold of a fleshy limb of the zones (a few tries; a missing or bony
/// limb is passed over). Returns the leech, or null.
/proc/rogue_set_wild_leech(mob/living/carbon/human/host, list/zones)
	for(var/attempt in 1 to length(zones) + 1)
		var/obj/item/bodypart/limb = host.get_bodypart(pick(zones))
		if(!limb || !(limb.biological_state & BIO_FLESH))
			continue
		var/obj/item/natural/worms/leech/leech = new(limb)
		leech.rogue_latch(limb)
		return leech
	return null

// --- The healing hot spring (Ratwood thermalwater): whoever soaks in it mends every few seconds.

/turf/open/water/ocean/deep/thermalwater/rogue_wade(mob/living/wader)
	. = ..()
	if(iscarbon(wader))
		START_PROCESSING(SSobj, src)

/turf/open/water/ocean/deep/thermalwater/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/open/water/ocean/deep/thermalwater/process(seconds_per_tick)
	var/list/soakers = list()
	for(var/mob/living/carbon/soaker in src)
		if(soaker.stat != DEAD)
			soakers += soaker
	if(!length(soakers))
		return PROCESS_KILL
	if(world.time < rogue_last_heal + rogue_value("thermal_heal_interval"))
		return
	rogue_last_heal = world.time
	for(var/mob/living/carbon/soaker as anything in soakers)
		rogue_thermal_heal(soaker)

/// Ratwood thermalwater process(): brute, burn and toxins mend, breath twice as much.
/turf/open/water/ocean/deep/thermalwater/proc/rogue_thermal_heal(mob/living/carbon/soaker)
	var/amount = rogue_value("thermal_heal")
	var/need_update = FALSE
	need_update += soaker.adjust_brute_loss(-amount, updating_health = FALSE)
	need_update += soaker.adjust_fire_loss(-amount, updating_health = FALSE)
	need_update += soaker.adjust_tox_loss(-amount, updating_health = FALSE)
	need_update += soaker.adjust_oxy_loss(-amount * 2, updating_health = FALSE)
	if(need_update)
		soaker.updatehealth()

// --- The hot springs of the baths (Ratwood /obj/structure/hotspring): steam rises from them; the bath is survival/washing.dm.

/// Ratwood hotspring_steam.
/particles/rogue_hotspring_steam
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_cloud_1" = 5, "steam_cloud_2" = 5, "steam_cloud_3" = 5, "steam_cloud_4" = 5, "steam_cloud_5" = 5)
	color = "#FFFFFF8A"
	count = 2
	spawning = 0.3
	lifespan = 3 SECONDS
	fade = 1.2 SECONDS
	fadein = 0.4 SECONDS
	position = generator(GEN_BOX, list(-17, -15, 0), list(24, 15, 0), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.9, 0.9), list(1.1, 1.1), NORMAL_RAND)
	drift = generator(GEN_SPHERE, list(-0.01, 0), list(0.01, 0.01), UNIFORM_RAND)
	spin = generator(GEN_NUM, list(-2, 2), NORMAL_RAND)
	gravity = list(0.05, 0.28)
	friction = 0.3
	grow = 0.037

/// A steam holder that shows the shared steam instead of a steam of its own.
/obj/effect/abstract/particle_holder/rogue_steam
	/// The one steam every hot spring shows (Ratwood particle_holder/cached): a hundred and eighty tiles share it.
	var/static/particles/rogue_hotspring_steam/shared_steam

/obj/effect/abstract/particle_holder/rogue_steam/Initialize(mapload, particle_path = /particles/rogue_hotspring_steam, particle_flags = NONE)
	. = ..()
	QDEL_NULL(particles)
	if(!shared_steam)
		shared_steam = new
	particles = shared_steam

/obj/effect/abstract/particle_holder/rogue_steam/Destroy(force)
	particles = null
	return ..()

/obj/structure/hotspring
	/// The steam over it.
	var/obj/effect/abstract/particle_holder/rogue_steam/rogue_steam

/obj/structure/hotspring/Initialize(mapload)
	. = ..()
	rogue_steam = new(src)

/obj/structure/hotspring/Destroy(force)
	QDEL_NULL(rogue_steam)
	return ..()

#undef WATER_COLD
#undef WATER_WARM
