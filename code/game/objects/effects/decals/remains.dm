/obj/effect/decal/remains
	name = "remains"
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'

/obj/effect/decal/remains/acid_act()
	visible_message(span_warning("[src] dissolve[gender == PLURAL?"":"s"] into a puddle of sizzling goop!"))
	playsound(src, 'sound/items/tools/welder.ogg', 150, TRUE)
	new /obj/effect/decal/cleanable/greenglow(drop_location())
	qdel(src)
	return TRUE

/obj/effect/decal/remains/human
	desc = "They look like human remains. They have a strange aura about them."
	icon_state = "remains"

/obj/effect/decal/remains/human/NeverShouldHaveComeHere(turf/here_turf)
	return !istype(here_turf, /obj/structure/closet/crate/grave/filled) && ..()

/obj/effect/decal/remains/human/smokey
	name = "remains of Charles Morlbaro"
	desc = "I guess we figured out what happened to the guy who lives here. You'd best tread lightly around this..."
	///Our proximity monitor, for detecting nearby looters.
	var/datum/proximity_monitor/proximity_monitor
	///The reagent we will release when our remains are disturbed.
	var/datum/reagent/that_shit_that_killed_saddam
	///A cooldown for how frequently the gas is released when disturbed.
	COOLDOWN_DECLARE(gas_cooldown)
	///The length of the aforementioned cooldown.
	var/gas_cooldown_length = (20 SECONDS)

/obj/effect/decal/remains/human/smokey/Initialize(mapload)
	. = ..()

	proximity_monitor = new(src, 1)
	var/list/blocked_reagents = subtypesof(/datum/reagent/medicine) + subtypesof(/datum/reagent/consumable) //Boooooriiiiing
	that_shit_that_killed_saddam = get_random_reagent_id(blacklist = blocked_reagents)

/obj/effect/decal/remains/human/smokey/HasProximity(atom/movable/tomb_raider)
	if(!COOLDOWN_FINISHED(src, gas_cooldown))
		return

	if(iscarbon(tomb_raider))
		var/mob/living/carbon/nearby_carbon = tomb_raider
		if(nearby_carbon.move_intent != MOVE_INTENT_WALK || prob(5))
			release_smoke(nearby_carbon)
			COOLDOWN_START(src, gas_cooldown, gas_cooldown_length)

///Releases a cloud of smoke based on the randomly generated reagent in Initialize().
/obj/effect/decal/remains/human/smokey/proc/release_smoke(mob/living/smoke_releaser)
	visible_message(span_warning("[smoke_releaser] disturbs the [src], which releases a huge cloud of gas!"))
	var/datum/effect_system/fluid_spread/smoke/chem/cigarette_puff = new()
	cigarette_puff.chemholder.add_reagent(that_shit_that_killed_saddam, 15)
	cigarette_puff.attach(get_turf(src))
	cigarette_puff.set_up(range = 2, amount = DIAMOND_AREA(2), holder = src, location = get_turf(src), silent = TRUE)
	cigarette_puff.start()

///Subtype of smokey remains used for rare maintenance spawns.
/obj/effect/decal/remains/human/smokey/maintenance
	name = "smokey remains"
	desc = "They look like human remains. They have a strange, smokey aura about them... You should tread lightly when walking near this."

/obj/effect/decal/remains/human/smokey/maintenance/Initialize(mapload)
	. = ..()
	gas_cooldown_length = rand(4 MINUTES, 6 MINUTES)

/obj/effect/decal/remains/plasma
	icon_state = "remainsplasma"

/obj/effect/decal/remains/plasma/NeverShouldHaveComeHere(turf/here_turf)
	return isclosedturf(here_turf)

/obj/effect/decal/remains/xeno
	desc = "They look like the remains of something... alien. They have a strange aura about them."
	icon_state = "remainsxeno"

/obj/effect/decal/remains/xeno/larva
	icon_state = "remainslarva"

/obj/effect/decal/remains/robot
	desc = "They look like the remains of something mechanical. They have a strange aura about them."
	icon = 'icons/mob/silicon/robots.dmi'
	icon_state = "remainsrobot"

/obj/effect/decal/cleanable/blood/gibs/robot_debris/old
	name = "dusty robot debris"
	desc = "Looks like nobody has touched this in a while."
