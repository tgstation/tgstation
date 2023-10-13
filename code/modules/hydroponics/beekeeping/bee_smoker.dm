/// multiplier to decide how much fuel we add to a smoker
#define WEED_WINE_MULTIPLIER 0.2
/// how much using it costs
#define SINGLE_USE_COST 5

/obj/item/bee_smoker
	name = "bee smoker"
	desc = "A device which can be used to entrance bees!"
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "bee_smoker"
	inhand_icon_state = "bee_smoker"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	item_flags = NOBLUDGEON
	/// current level of fuel we have
	var/current_herb_fuel = 50
	/// maximum amount of fuel we can hold
	var/max_herb_fuel = 50
	/// are we currently activated?
	var/activated = FALSE
	/// sound to play when releasing smoke
	var/datum/looping_sound/beesmoke/beesmoke_loop

/obj/item/bee_smoker/Initialize(mapload)
	. = ..()
	beesmoke_loop = new(src)

/obj/item/bee_smoker/attack_self(mob/user)
	if(!activated && current_herb_fuel <= 0)
		user.balloon_alert(user, "no fuel")
		return
	alter_state()
	user.balloon_alert(user, "[activated ? "activated!" : "deactivated!"]")

/obj/item/bee_smoker/afterattack(atom/attacked_atom, mob/living/user, proximity)
	. = ..()

	if(!proximity)
		return

	if(!activated)
		user.balloon_alert(user, "not activated")
		return

	if(current_herb_fuel < SINGLE_USE_COST)
		user.balloon_alert(user, "not enough fuel")
		return

	current_herb_fuel -= SINGLE_USE_COST
	playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
	var/turf/target_turf = get_turf(attacked_atom)
	new /obj/effect/temp_visual/mook_dust(target_turf)

	if(istype(attacked_atom, /obj/structure/beebox))
		befriend_hive(attacked_atom, user)
		return

	for(var/mob/living/basic/bee/friend in target_turf)
		friend.befriend(user)

/obj/item/bee_smoker/attackby(obj/item/herb, mob/living/carbon/human/user, list/modifiers)
	if(!istype(herb, /obj/item/food/grown/cannabis))
		return
	var/obj/item/food/grown/cannabis/weed = herb
	if(isnull(weed.wine_power))
		return
	if(current_herb_fuel == max_herb_fuel)
		user.balloon_alert(user, "already at maximum fuel")
		return
	var/fuel_worth = weed.wine_power * WEED_WINE_MULTIPLIER
	current_herb_fuel = (current_herb_fuel + fuel_worth > max_herb_fuel) ? max_herb_fuel : current_herb_fuel + fuel_worth
	user.balloon_alert(user, "fuel added")
	qdel(weed)
	return ..()

/obj/item/bee_smoker/process(seconds_per_tick)
	current_herb_fuel--
	if(current_herb_fuel <= 0)
		alter_state()

/obj/item/bee_smoker/proc/alter_state()
	activated = !activated
	playsound(src, 'sound/items/welderdeactivate.ogg', 50, TRUE)

	if(!activated)
		beesmoke_loop.stop()
		QDEL_NULL(particles)
		STOP_PROCESSING(SSobj, src)
		return

	beesmoke_loop.start()
	START_PROCESSING(SSobj, src)
	particles = new /particles/smoke
	particles.position = list(-14, 12, 0)
	particles.velocity = list(0, 0.2, 0)
	particles.fadein = 6

/obj/item/bee_smoker/proc/befriend_hive(obj/structure/beebox/hive, mob/living/user)
	for(var/mob/living/bee as anything in hive.bees)
		bee.befriend(user)

#undef WEED_WINE_MULTIPLIER
#undef SINGLE_USE_COST
