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

/// Negatively affects plants on `target_turf`, because Nar'Sie is not the Geometer of Sap.
/obj/structure/destructible/cult/pylon/proc/wither_plants(turf/target_turf)
	// If this is TRUE then we do a flash of light and a sound at the end.
	var/hit_something = FALSE
	for(var/obj/structure/flora/plant in target_turf)
		var/static/list/unwitherables = typecacheof(list(
			/obj/structure/flora/rock,
			/obj/structure/flora/tree/dead,
		))
		if(is_type_in_typecache(plant, unwitherables))
			continue

		var/damage = plant.max_integrity / PYLON_PLANT_LETHALITY
		// The plant will leave no produce behind ONLY if the pylon deals the final blow.
		if(plant.get_integrity() - damage <= 0)
			plant.harvested = TRUE

		plant.play_attack_sound(ignore_walls = FALSE)
		plant.visible_message(span_cult("[plant] shrivels as an air of crimson envelops it."),
			blind_message = span_warning("You hear a violent and decaying rustle."))
		plant.take_damage(damage, BRUTE, sound_effect = FALSE, armour_penetration = 100)
		hit_something = TRUE

	for(var/obj/machinery/hydroponics/plant_tray in target_turf)
		if(plant_tray.plant_status == HYDROTRAY_NO_PLANT || plant_tray.plant_status == HYDROTRAY_PLANT_DEAD)
			continue
		var/obj/item/seeds/tray_seed = plant_tray.myseed

		if(plant_tray.reagents.has_reagent(/datum/reagent/blood, 1))
			if(plant_tray.pestlevel)
				// Blood promotes pests and pylons kill them for health. It's a very evil arrangement.
				plant_tray.visible_message(span_cult("A faint scarlet courses through [tray_seed.plantname]."),
					blind_message = span_warning("A chorus of chittering quickly rises and falls silent."),
					vision_distance = COMBAT_MESSAGE_RANGE)
				plant_tray.adjust_pestlevel(-plant_tray.pestlevel)
				plant_tray.adjust_plant_health(2 * plant_tray.pestlevel)
				hit_something = TRUE // It hits the worms
			continue

		if(istype(tray_seed, /obj/item/seeds/watermelon/holy))
			plant_tray.flash_lighting_fx(2, 2, COLOR_VIVID_YELLOW, 0.5 SECONDS)
			plant_tray.visible_message(span_warning("The [tray_seed.plantname] glow against an air of encroaching crimson."))
			continue

		plant_tray.adjust_plant_health(-(plant_tray.plant_health / PYLON_PLANT_LETHALITY) - 25)
		hit_something = TRUE

	for(var/mob/living/carbon/human/species/pod/podperson in target_turf)
		if(IS_CULTIST(podperson))
			continue

		if(podperson.can_block_magic(MAGIC_RESISTANCE_HOLY, 0))
			continue

		podperson.playsound_local(podperson, pick(GLOB.creepy_ambience), 25)
		podperson.visible_message(span_warning("[podperson] hunches over."),
			span_cult_large("\"You will wilt now, sapling.\""),
			span_warning("You hear a lowering rustle."))
		podperson.adjust_stamina_loss(50)
		hit_something = TRUE

	for(var/obj/structure/spacevine/kudzu in range(1, target_turf))
		kudzu.Destroy()
		hit_something = TRUE

	for(var/obj/item/kirbyplants/potted_plant in target_turf)
		if(potted_plant.dead)
			continue

		potted_plant.wither()
		hit_something = TRUE

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
