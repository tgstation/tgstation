/* In this file:
 *
 * Plasma floor
 * Gold floor
 * Silver floor
 * Bananium floor
 * Diamond floor
 * Uranium floor
 * Shuttle floor (Titanium)
 */

/turf/open/floor/mineral
	name = "mineral floor"
	icon_state = ""
	var/list/icons
	tiled_dirt = FALSE


/turf/open/floor/mineral/Initialize()
	. = ..()
	icons = typelist("icons", icons)

/turf/open/floor/mineral/setup_broken_states()
	return list("[initial(icon_state)]_dam")

/turf/open/floor/mineral/update_icon()
	. = ..()
	if(!.)
		return
	if(!broken && !burnt)
		if( !(icon_state in icons) )
			icon_state = initial(icon_state)

//PLASMA

/turf/open/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_dam")

/turf/open/floor/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/turf/open/floor/mineral/plasma/attackby(obj/item/W, mob/user, params)
	if(W.get_temperature() > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma flooring was ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(src)]")
		log_game("Plasma flooring was ignited by [key_name(user)] in [AREACOORD(src)]")
		ignite(W.get_temperature())
		return
	..()

/turf/open/floor/mineral/plasma/proc/PlasmaBurn(temperature)
	make_plating()
	atmos_spawn_air("plasma=20;TEMP=[temperature]")

/turf/open/floor/mineral/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

//Plasma floor that can't be removed, for disco inferno

/turf/open/floor/mineral/plasma/disco/crowbar_act(mob/living/user, obj/item/I)
	return


//GOLD

/turf/open/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_dam")

//SILVER

/turf/open/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_dam")

//TITANIUM (shuttle)

/turf/open/floor/mineral/titanium
	name = "shuttle floor"
	icon_state = "titanium"
	floor_tile = /obj/item/stack/tile/mineral/titanium

/turf/open/floor/mineral/titanium/setup_broken_states()
	return list("titanium_dam1","titanium_dam2","titanium_dam3","titanium_dam4","titanium_dam5")

/turf/open/floor/mineral/titanium/rust_heretic_act()
	return // titanium does not rust

/turf/open/floor/mineral/titanium/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/yellow
	icon_state = "titanium_yellow"
	floor_tile = /obj/item/stack/tile/mineral/titanium/yellow

/turf/open/floor/mineral/titanium/yellow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/blue
	icon_state = "titanium_blue"
	floor_tile = /obj/item/stack/tile/mineral/titanium/blue

/turf/open/floor/mineral/titanium/blue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/white
	icon_state = "titanium_white"
	floor_tile = /obj/item/stack/tile/mineral/titanium/white

/turf/open/floor/mineral/titanium/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/purple
	icon_state = "titanium_purple"
	floor_tile = /obj/item/stack/tile/mineral/titanium/purple

/turf/open/floor/mineral/titanium/purple/airless
	initial_gas_mix = AIRLESS_ATMOS

// OLD TITANIUM (titanium floor tiles before PR #50454)
/turf/open/floor/mineral/titanium/tiled
	name = "titanium tile"
	icon_state = "titanium_tiled"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled

/turf/open/floor/mineral/titanium/tiled/setup_broken_states()
	return list("titanium_dam1_old","titanium_dam2_old","titanium_dam3_old","titanium_dam4_old","titanium_dam5_old")

/turf/open/floor/mineral/titanium/tiled/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/tiled/yellow
	icon_state = "titanium_tiled_yellow"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled/yellow

/turf/open/floor/mineral/titanium/tiled/yellow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/tiled/blue
	icon_state = "titanium_tiled_blue"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled/blue

/turf/open/floor/mineral/titanium/tiled/blue/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/tiled/white
	icon_state = "titanium_tiled_white"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled/white

/turf/open/floor/mineral/titanium/tiled/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/titanium/tiled/purple
	icon_state = "titanium_tiled_purple"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled/purple

/turf/open/floor/mineral/titanium/tiled/purple/airless
	initial_gas_mix = AIRLESS_ATMOS

//PLASTITANIUM (syndieshuttle)
/turf/open/floor/mineral/plastitanium
	name = "shuttle floor"
	icon_state = "plastitanium"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium

/turf/open/floor/mineral/plastitanium/setup_broken_states()
	return list("plastitanium_dam1","plastitanium_dam2","plastitanium_dam3","plastitanium_dam4","plastitanium_dam5")

/turf/open/floor/mineral/plastitanium/rust_heretic_act()
	return // plastitanium does not rust

/turf/open/floor/mineral/plastitanium/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/red
	icon_state = "plastitanium_red"

/turf/open/floor/mineral/plastitanium/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/red/brig
	name = "brig floor"

//BANANIUM

/turf/open/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_dam")
	var/sound_cooldown = 0

/turf/open/floor/mineral/bananium/Entered(atom/movable/AM)
	.=..()
	if(!.)
		if(isliving(AM))
			squeak()

/turf/open/floor/mineral/bananium/attackby(obj/item/W, mob/user, params)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/attack_hand(mob/user, list/modifiers)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/attack_paw(mob/user, list/modifiers)
	.=..()
	if(!.)
		honk()

/turf/open/floor/mineral/bananium/proc/honk()
	if(sound_cooldown < world.time)
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
		sound_cooldown = world.time + 20

/turf/open/floor/mineral/bananium/proc/squeak()
	if(sound_cooldown < world.time)
		playsound(src, "clownstep", 50, TRUE)
		sound_cooldown = world.time + 10

/turf/open/floor/mineral/bananium/airless
	initial_gas_mix = AIRLESS_ATMOS

//DIAMOND

/turf/open/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_dam")

//URANIUM

/turf/open/floor/mineral/uranium
	article = "a"
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_dam")
	var/last_event = 0
	var/active = null

/turf/open/floor/mineral/uranium/Entered(atom/movable/AM)
	.=..()
	if(!.)
		if(ismob(AM))
			radiate()

/turf/open/floor/mineral/uranium/attackby(obj/item/W, mob/user, params)
	.=..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/attack_hand(mob/user, list/modifiers)
	.=..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/attack_paw(mob/user, list/modifiers)
	.=..()
	if(!.)
		radiate()

/turf/open/floor/mineral/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = TRUE
			radiation_pulse(src, 10)
			for(var/turf/open/floor/mineral/uranium/T in orange(1,src))
				T.radiate()
			last_event = world.time
			active = FALSE
			return

// ALIEN ALLOY
/turf/open/floor/mineral/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/abductor
	icons = list("alienpod1", "alienpod2", "alienpod3", "alienpod4", "alienpod5", "alienpod6", "alienpod7", "alienpod8", "alienpod9")
	baseturfs = /turf/open/floor/plating/abductor2

/turf/open/floor/mineral/abductor/Initialize()
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/open/floor/mineral/abductor/break_tile()
	return //unbreakable

/turf/open/floor/mineral/abductor/burn_tile()
	return //unburnable
