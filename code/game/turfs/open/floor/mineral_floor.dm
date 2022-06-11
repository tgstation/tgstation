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
	material_flags = MATERIAL_EFFECTS
	var/list/icons
	tiled_dirt = FALSE


/turf/open/floor/mineral/Initialize(mapload)
	. = ..()
	icons = typelist("icons", icons)

/turf/open/floor/mineral/setup_broken_states()
	return list("[initial(icon_state)]_damaged")

/turf/open/floor/mineral/update_icon_state()
	if(!broken && !burnt && !(icon_state in icons))
		icon_state = initial(icon_state)
	return ..()

//PLASMA

/turf/open/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_damaged")
	custom_materials = list(/datum/material/plasma = 500)

//Plasma floor that can't be removed, for disco inferno

/turf/open/floor/mineral/plasma/disco/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/mineral/plasma/damaged
	broken = TRUE
	icon_state = "plasma_damaged"

//GOLD

/turf/open/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_damaged")
	custom_materials = list(/datum/material/gold = 500)

/turf/open/floor/mineral/gold/damaged
	broken = TRUE
	icon_state = "gold_damaged"

//SILVER

/turf/open/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_damaged")
	custom_materials = list(/datum/material/silver = 500)

/turf/open/floor/mineral/silver
	broken = TRUE
	icon_state = "silver_damaged"

//TITANIUM (shuttle)

/turf/open/floor/mineral/titanium
	name = "shuttle floor"
	icon_state = "titanium"
	floor_tile = /obj/item/stack/tile/mineral/titanium
	custom_materials = list(/datum/material/titanium = 500)

/turf/open/floor/mineral/titanium/setup_broken_states()
	return list(
		"titanium_lightdamage",
		"titanium_heavydamage",
		"titanium_milddamage",
		"titanium_moderatedamage",
		"titanium_highdamage",
	)

/turf/open/floor/mineral/titanium/damaged
	broken = TRUE

/turf/open/floor/mineral/titanium/damaged/light
	icon_state = "titanium_lightdamage"

/turf/open/floor/mineral/titanium/damaged/mild
	icon_state = "titanium_milddamage"

/turf/open/floor/mineral/titanium/damaged/moderate
	icon_state = "titanium_moderatedamage"

/turf/open/floor/mineral/titanium/damaged/high
	icon_state = "titanium_highdamage"

/turf/open/floor/mineral/titanium/damaged/heavy
	icon_state = "titanium_heavydamage"


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
	icon_state = "titanium_tile"
	floor_tile = /obj/item/stack/tile/mineral/titanium/tiled

/turf/open/floor/mineral/titanium/tiled/setup_broken_states()
	return list(
		"titanium_tile-lightdamage",
		"titanium_tile-highdamage",
		"titanium_tile-milddamage",
		"titanium_tile-moderatedamage",
		"titanium_tile-heavydamage",
	)

/turf/open/floor/mineral/titanium/tiled/damaged
	broken = TRUE

/turf/open/floor/mineral/titanium/tiled/damaged/light
	icon_state = "titanium_tile-lightdamage"

/turf/open/floor/mineral/titanium/tiled/damaged/mild
	icon_state = "titanium_tile-milddamage"

/turf/open/floor/mineral/titanium/tiled/damaged/moderate
	icon_state = "titanium_tile-moderatedamage"

/turf/open/floor/mineral/titanium/tiled/damaged/high
	icon_state = "titanium_tile-highdamage"

/turf/open/floor/mineral/titanium/tiled/damaged/heavy
	icon_state = "titanium_tile-heavydamage"

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
	custom_materials = list(/datum/material/alloy/plastitanium = 500)

/turf/open/floor/mineral/plastitanium/setup_broken_states()
	return list(
		"plastitanium_lightdamage",
		"plastitanium_highdamage",
		"plastitanium_milddamage",
		"plastitanium_moderatedamage",
		"plastitanium_heavydamage",
	)

/turf/open/floor/mineral/plastitanium/rust_heretic_act()
	return // plastitanium does not rust

/turf/open/floor/mineral/plastitanium/damaged
	broken = TRUE

/turf/open/floor/mineral/plastitanium/damaged/light
	icon_state = "plastitanium_lightdamage"

/turf/open/floor/mineral/plastitanium/damaged/mild
	icon_state = "plastitanium_milddamage"

/turf/open/floor/mineral/plastitanium/damaged/moderate
	icon_state = "plastitanium_moderatedamage"

/turf/open/floor/mineral/plastitanium/damaged/high
	icon_state = "plastitanium_highdamage"

/turf/open/floor/mineral/plastitanium/damaged/heavy
	icon_state = "plastitanium_heavydamage"

/turf/open/floor/mineral/plastitanium/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/red
	icon_state = "plastitanium_red"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium/red

/turf/open/floor/mineral/plastitanium/red/airless
	initial_gas_mix = AIRLESS_ATMOS

//Used in SnowCabin.dm
/turf/open/floor/mineral/plastitanium/red/snow_cabin
	temperature = 180

/turf/open/floor/mineral/plastitanium/red/brig
	name = "brig floor"

//BANANIUM

/turf/open/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_damaged")
	custom_materials = list(/datum/material/bananium = 500)
	material_flags = NONE //The slippery comp makes it unpractical for good clown decor. The custom mat one should still slip.
	var/sound_cooldown = 0

/turf/open/floor/mineral/bananium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(.)
		return
	if(isliving(arrived))
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
		playsound(src, SFX_CLOWN_STEP, 50, TRUE)
		sound_cooldown = world.time + 10

/turf/open/floor/mineral/bananium/damaged
	broken = TRUE
	icon_state = "bananium_damaged"

/turf/open/floor/mineral/bananium/airless
	initial_gas_mix = AIRLESS_ATMOS

//DIAMOND

/turf/open/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_damaged")
	custom_materials = list(/datum/material/diamond = 500)

//URANIUM

/turf/open/floor/mineral/uranium
	article = "a"
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_damaged")
	custom_materials = list(/datum/material/uranium = 500)
	var/last_event = 0
	var/active = null

/turf/open/floor/mineral/uranium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(.)
		return
	if(isliving(arrived))
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
			radiation_pulse(
				src,
				max_range = 1,
				threshold = RAD_VERY_LIGHT_INSULATION,
				chance = (URANIUM_IRRADIATION_CHANCE / 3),
				minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
			)
			for(var/turf/open/floor/mineral/uranium/T in orange(1,src))
				T.radiate()
			last_event = world.time
			active = FALSE
			return

/turf/open/floor/mineral/uranium/damaged
	broken = TRUE
	icon_state = "uranium_damaged"

// ALIEN ALLOY
/turf/open/floor/mineral/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/abductor
	icons = list(
		"alienpod1",
		"alienpod2",
		"alienpod3",
		"alienpod4",
		"alienpod5",
		"alienpod6",
		"alienpod7",
		"alienpod8",
		"alienpod9",
	)
	baseturfs = /turf/open/floor/plating/abductor2
	custom_materials = list(/datum/material/alloy/alien = 500)

/turf/open/floor/mineral/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/open/floor/mineral/abductor/break_tile()
	return //unbreakable

/turf/open/floor/mineral/abductor/burn_tile()
	return //unburnable
