/// VERY ROUGHLY the number of "hits" it should take for a pylon to
/// down a plant on a given turf (excepting kirbyplants and kudzu).
#define PYLON_PLANT_LETHALITY 2

// Cult pylon. Heals nearby cultists, converts turfs to cult turfs, and withers plants.
/obj/structure/destructible/cult/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	light_range = 1.5
	light_color = COLOR_SOFT_RED
	break_sound = 'sound/effects/glass/glassbr2.ogg'
	break_message = span_warning("The blood-red crystal falls to the floor and shatters!")
	/// Length of the cooldown in between tile corruptions. Doubled if no turfs are found.
	custom_materials = list(/datum/material/runedmetal = SHEET_MATERIAL_AMOUNT * 4)
	var/corruption_cooldown_duration = 5 SECONDS
	/// The cooldown for corruptions.
	COOLDOWN_DECLARE(corruption_cooldown)

/obj/structure/destructible/cult/pylon/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/aura_healing, \
		range = 5, \
		brute_heal = 0.4, \
		burn_heal = 0.4, \
		blood_heal = 0.4, \
		simple_heal = 1.2, \
		wound_clotting = 0.1, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_HEALS_FROM_CULT_PYLONS, \
		healing_color = COLOR_CULT_RED, \
	)

	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/cult/pylon/process()
	if(!anchored)
		return
	if(!COOLDOWN_FINISHED(src, corruption_cooldown))
		return

	var/list/validturfs = list()
	var/list/cultturfs = list()
	for(var/nearby_turf in circle_view_turfs(src, 5))
		if(istype(nearby_turf, /turf/open/floor/engine/cult))
			cultturfs |= nearby_turf
			continue
		var/static/list/blacklisted_pylon_turfs = typecacheof(list(
			/turf/closed,
			/turf/open/floor/engine/cult,
			/turf/open/misc/asteroid,
		))
		if(isgroundlessturf(nearby_turf) || is_type_in_typecache(nearby_turf, blacklisted_pylon_turfs))
			continue
		validturfs |= nearby_turf

	if(length(validturfs))
		var/turf/converted_turf = pick(validturfs)
		wither_plants(converted_turf)
		if(isplatingturf(converted_turf))
			converted_turf.place_on_top(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		else
			converted_turf.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)

	else if (length(cultturfs))
		var/turf/open/floor/engine/cult/cult_turf = pick(cultturfs)
		wither_plants(cult_turf)
		new /obj/effect/temp_visual/cult/turf/floor(cult_turf)

	else
		// Are we in space or something? No cult turfs or convertable turfs? Double the cooldown
		COOLDOWN_START(src, corruption_cooldown, corruption_cooldown_duration * 2)
		return

	COOLDOWN_START(src, corruption_cooldown, corruption_cooldown_duration)

/// Destroys or otherwise harms plants on `target_turf`, because Nar'Sie is not the Geometer of Sap.
/obj/structure/destructible/cult/pylon/proc/wither_plants(turf/target_turf)
	// If this is TRUE then we do a flash of light and a sound at the end.
	var/hit_something = FALSE

	// Flora structures
	for(var/obj/structure/flora/plant in target_turf)
		hit_something = plant.cult_wither(plant.max_integrity / PYLON_PLANT_LETHALITY)

	// Hydroponics plants
	for(var/obj/machinery/hydroponics/plant_tray in target_turf)
		hit_something = plant_tray.cult_wither(-(plant_tray.plant_health / PYLON_PLANT_LETHALITY) - 15)

	// Plant mobs
	for(var/mob/living/plant_mob in target_turf)
		hit_something = plant_mob.cult_wither(plant_mob.max_stamina / PYLON_PLANT_LETHALITY)

	// Kudzu
	for(var/obj/structure/spacevine/kudzu in range(1, target_turf))
		kudzu.Destroy()
		hit_something = TRUE

	// Potted kirbyplants
	for(var/obj/item/kirbyplants/potted_plant in target_turf)
		hit_something = potted_plant.cult_wither()

	// Effects on hit
	if(hit_something)
		target_turf.flash_lighting_fx(1.5, 2, COLOR_SOFT_RED, 0.5 SECONDS)
		playsound(target_turf, SFX_SEAR, 20, ignore_walls = FALSE)

/obj/structure/destructible/cult/pylon/conceal()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/pylon/reveal()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

#undef PYLON_PLANT_LETHALITY
