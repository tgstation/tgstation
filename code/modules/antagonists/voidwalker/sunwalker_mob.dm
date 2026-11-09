/// Voidwalker murderbone variant focused around the sun (wow yet another fire element antag!!)
/mob/living/basic/voidwalker/sunwalker
	name = "Heliarch"
	desc = "A cosmic entity covered in stellar corona. You DEFINITELY shouldn't stare."

	icon_state = "sunwalker"

	melee_damage_type = BURN
	melee_damage_lower = 25
	melee_damage_upper = 25

	health = 200
	maxHealth = 200

	obj_damage = 50
	speed = 0.2

	maximum_survivable_temperature = INFINITY
	pressure_resistance = INFINITY

	charge = /datum/action/cooldown/mob_cooldown/charge/sunwalker
	telepathy = /datum/action/cooldown/spell/list_target/telepathy/voidwalker/sunwalker
	can_do_abductions = FALSE

	regenerate_colour = COLOR_BLUE
	light_range = 7

	/// Temperature we move our surroundings towards
	var/hotspot_temperature = 1000
	/// Gas volume passively exposed to our temperature
	var/hotspot_volume = 100

	/// Water damage we take on any exposure
	var/water_damage = 10
	/// Below this health threshold, we dont take water damage
	var/water_damage_cutoff = 10

/mob/living/basic/voidwalker/sunwalker/unique_setup()
	AddComponent(/datum/component/igniter)
	AddComponent(/datum/component/vision_hurting, damage_per_second = 0.1, message = null, silent = TRUE)
	AddComponent(/datum/component/space_dive, /obj/effect/dummy/phased_mob/space_dive/sunwalker)

	create_reagents(1) // Needed for the water reagent interactions to work

	var/static/list/ray_filter = list(type = "rays", size = 32, color = COLOR_BLUE_VERY_LIGHT)
	add_filter("sunwalker_rays", 3, ray_filter)
	animate(get_filter("sunwalker_rays"), offset = 1, time = 3 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)

/mob/living/basic/voidwalker/sunwalker/examine(mob/user)
	. = ..()

	if(!iscarbon(user))
		return

	// MY EYEESSS!!!
	var/mob/living/carbon/carbon = user
	if(carbon.get_eye_protection() < 1)
		var/obj/item/organ/eyes/burning_orbs = locate() in carbon.organs
		burning_orbs?.apply_organ_damage(5)

/mob/living/basic/voidwalker/sunwalker/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	. = ..()

	do_sparks(rand(1, 4), source = target)

/mob/living/basic/voidwalker/sunwalker/process(seconds_per_tick)
	. = ..()
	if(isopenturf(loc))
		var/turf/location = loc
		location.hotspot_expose(hotspot_temperature, hotspot_volume)

		if(prob(2))
			new /obj/effect/hotspot(location)

/mob/living/basic/voidwalker/sunwalker/reagent_expose(datum/reagent/chem, methods, reac_volume, show_message, touch_protection)
	. = ..()

	if(istype(chem, /datum/reagent/water) && health > water_damage_cutoff)
		take_overall_damage(water_damage)
		playsound(src, 'sound/items/tools/welder.ogg', 80, TRUE, 1)
		do_sparks(rand(4, 8), source = src)
