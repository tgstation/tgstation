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
	icon_state = null
	material_flags = MATERIAL_EFFECTS
	rust_resistance = RUST_RESISTANCE_BASIC
	var/list/icons
	tiled_turf = FALSE



/turf/open/floor/mineral/Initialize(mapload)
	. = ..()
	icons = typelist("icons", icons)

/turf/open/floor/mineral/broken_states()
	return isnull(icon_state) ? list() : list("[initial(icon_state)]_dam")

/turf/open/floor/mineral/update_icon_state()
	if(!broken && !burnt && !(icon_state in icons))
		icon_state = initial(icon_state)
	return ..()

//PLASMA

/turf/open/floor/mineral/plasma
	name = "plasma floor"
	icon_state = "plasma"
	floor_tile = /obj/item/stack/tile/mineral/plasma
	icons = list("plasma","plasma_dam")
	custom_materials = list(/datum/material/plasma = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_BASIC

//Plasma floor that can't be removed, for disco inferno

/turf/open/floor/mineral/plasma/disco/crowbar_act(mob/living/user, obj/item/I)
	return

/turf/open/floor/mineral/plasma/tiled
	name = "tiled plasma floor"
	icon_state = "plasma_tiled"
	floor_tile = /obj/item/stack/tile/mineral/plasma/tiled

/turf/open/floor/mineral/plasma/tiled/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

//GOLD

/turf/open/floor/mineral/gold
	name = "gold floor"
	icon_state = "gold"
	floor_tile = /obj/item/stack/tile/mineral/gold
	icons = list("gold","gold_dam")
	custom_materials = list(/datum/material/gold = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/open/floor/mineral/gold/tiled
	name = "tiled gold floor"
	icon_state = "gold_tiled"
	floor_tile = /obj/item/stack/tile/mineral/gold/tiled

/turf/open/floor/mineral/gold/tiled/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/gold/sun
	name = "gold sun floor"
	icon_state = "gold_sun"
	floor_tile = /obj/item/stack/tile/mineral/gold/sun

/turf/open/floor/mineral/gold/sun/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

//SILVER

/turf/open/floor/mineral/silver
	name = "silver floor"
	icon_state = "silver"
	floor_tile = /obj/item/stack/tile/mineral/silver
	icons = list("silver","silver_dam")
	custom_materials = list(/datum/material/silver = SMALL_MATERIAL_AMOUNT*5)

/turf/open/floor/mineral/silver/tiled
	name = "tiled silver floor"
	icon_state = "silver_tiled"
	floor_tile = /obj/item/stack/tile/mineral/silver/tiled

/turf/open/floor/mineral/silver/tiled/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/silver/moon
	name = "silver moon floor"
	icon_state = "silver_moon"
	floor_tile = /obj/item/stack/tile/mineral/silver/moon

/turf/open/floor/mineral/silver/moon/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

//PLASTEEL

/turf/open/floor/mineral/plasteel
	name = "plasteel floor"
	icon_state = "plasteel"
	floor_tile = /obj/item/stack/tile/plasteel
	custom_materials = list(/datum/material/alloy/plasteel = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/open/floor/mineral/plasteel/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/plasteel/straight
	name = "straight plasteel floor"
	icon_state = "plasteel_straight"
	floor_tile = /obj/item/stack/tile/plasteel/straight

/turf/open/floor/mineral/plasteel/corner
	name = "corner plasteel floor"
	icon_state = "plasteel_corner"
	floor_tile = /obj/item/stack/tile/plasteel/corner

/turf/open/floor/mineral/plasteel/block
	name = "blocky plasteel floor"
	icon_state = "block"
	floor_tile = /obj/item/stack/tile/plasteel/block

/turf/open/floor/mineral/plasteel/lock
	name = "locked plasteel floor"
	icon_state = "lock"
	floor_tile = /obj/item/stack/tile/plasteel/lock

/turf/open/floor/mineral/plasteel/tiled
	name = "tiled plasteel floor"
	icon_state = "alienvault"
	floor_tile = /obj/item/stack/tile/plasteel/tiled

//TITANIUM (shuttle)

/turf/open/floor/mineral/titanium
	name = "shuttle floor"
	icon_state = "titanium"
	floor_tile = /obj/item/stack/tile/mineral/titanium
	custom_materials = list(/datum/material/titanium = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/open/floor/mineral/titanium/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

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

/turf/open/floor/mineral/titanium/blue/lavaland_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE

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

/turf/open/floor/mineral/titanium/tiled/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

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
	custom_materials = list(/datum/material/alloy/plastitanium = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/open/floor/mineral/plastitanium/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/plastitanium/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/red
	icon_state = "plastitanium_red"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium/red

/turf/open/floor/mineral/plastitanium/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/mineral/plastitanium/pod
	name = "pod floor"
	icon_state = "podfloor"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium/pod

/turf/open/floor/mineral/plastitanium/pod/light
	icon_state = "podfloor_light"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium/pod/light

/turf/open/floor/mineral/plastitanium/pod/dark
	icon_state = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium/pod/dark

/turf/open/floor/mineral/plastitanium/pod/redlight
	icon_state = "podfloor_red_light"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium/pod/redlight

/turf/open/floor/mineral/plastitanium/pod/red
	icon_state = "podfloor_red"
	floor_tile = /obj/item/stack/tile/mineral/plastitanium/pod/red

//Used in SnowCabin.dm
/turf/open/floor/mineral/plastitanium/red/snow_cabin
	temperature = ICEBOX_MIN_TEMPERATURE

//BANANIUM

/turf/open/floor/mineral/bananium
	name = "bananium floor"
	icon_state = "bananium"
	floor_tile = /obj/item/stack/tile/mineral/bananium
	icons = list("bananium","bananium_dam")
	custom_materials = list(/datum/material/bananium = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_BASIC
	var/sound_cooldown = 0

/turf/open/floor/mineral/bananium/tiled
	name = "tiled bananium floor"
	icon_state = "bananium_tiled"
	floor_tile = /obj/item/stack/tile/mineral/bananium/tiled

/turf/open/floor/mineral/bananium/tiled/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/bananium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(.)
		return
	if(isliving(arrived))
		squeak()

/turf/open/floor/mineral/bananium/attackby(obj/item/W, mob/user, list/modifiers)
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

/turf/open/floor/mineral/bananium/airless
	initial_gas_mix = AIRLESS_ATMOS

//DIAMOND

/turf/open/floor/mineral/diamond
	name = "diamond floor"
	icon_state = "diamond"
	floor_tile = /obj/item/stack/tile/mineral/diamond
	icons = list("diamond","diamond_dam")
	custom_materials = list(/datum/material/diamond = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/mineral/diamond/tiled
	name = "tiled diamond floor"
	icon_state = "diamond_tiled"
	floor_tile = /obj/item/stack/tile/mineral/diamond/tiled

/turf/open/floor/mineral/diamond/tiled/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

//URANIUM

/turf/open/floor/mineral/uranium
	article = "a"
	name = "uranium floor"
	icon_state = "uranium"
	floor_tile = /obj/item/stack/tile/mineral/uranium
	icons = list("uranium","uranium_dam")
	custom_materials = list(/datum/material/uranium = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_REINFORCED
	var/last_event = 0
	var/active = null

/turf/open/floor/mineral/uranium/tiled
	name = "tiled uranium floor"
	icon_state = "uranium_tiled"
	floor_tile = /obj/item/stack/tile/mineral/uranium/tiled

/turf/open/floor/mineral/uranium/tiled/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/uranium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(.)
		return
	if(isliving(arrived))
		radiate()

/turf/open/floor/mineral/uranium/attackby(obj/item/W, mob/user, list/modifiers)
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

//BLUESPACE

/turf/open/floor/mineral/bluespace
	name = "bluespace floor"
	icon_state = "bluespacecrystal"
	floor_tile = /obj/item/stack/tile/mineral/bluespace
	custom_materials = list(/datum/material/bluespace = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/mineral/bluespace/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/bluespace/tiled
	name = "tiled bluespace floor"
	icon_state = "bluespacecrystal_tiled"
	floor_tile = /obj/item/stack/tile/mineral/bluespace/tiled

/turf/open/floor/mineral/bluespace/n
	name = "N-marked bluespace floor"
	icon_state = "bluespacecrystal_n"
	floor_tile = /obj/item/stack/tile/mineral/bluespace/n

//TELECRYSTAL

/turf/open/floor/mineral/telecrystal
	name = "telecrystal floor"
	icon_state = "telecrystal"
	floor_tile = /obj/item/stack/tile/mineral/telecrystal
	custom_materials = list(/datum/material/telecrystal = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/mineral/telecrystal/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/telecrystal/tiled
	name = "tiled telecrystal floor"
	icon_state = "telecrystal_tiled"
	floor_tile = /obj/item/stack/tile/mineral/telecrystal/tiled

/turf/open/floor/mineral/telecrystal/s
	name = "S-marked telecrystal floor"
	icon_state = "telecrystal_s"
	floor_tile = /obj/item/stack/tile/mineral/telecrystal/s

//ADAMANTINE
/turf/open/floor/mineral/adamantine
	name = "adamantine floor"
	icon_state = "adamantium"
	floor_tile = /obj/item/stack/tile/mineral/adamantine
	custom_materials = list(/datum/material/adamantine = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/open/floor/mineral/adamantine/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/adamantine/alt
	name = "adamantine plating"
	icon_state = "adamantium_alt"
	floor_tile = /obj/item/stack/tile/mineral/adamantine/alt

//METAL HYDROGEN
/turf/open/floor/mineral/metal_hydrogen
	name = "metal hydrogen floor"
	icon_state = "metalhydrogen"
	floor_tile = /obj/item/stack/tile/mineral/metal_hydrogen
	custom_materials = list(/datum/material/metalhydrogen = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_TITANIUM

/turf/open/floor/mineral/metal_hydrogen/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/mineral/metal_hydrogen/tiled
	name = "tiled metalhydrogen floor"
	icon_state = "metalhydrogen_tiled"
	floor_tile = /obj/item/stack/tile/mineral/metal_hydrogen/tiled

//RUNITE
/turf/open/floor/mineral/runite
	name = "runite floor"
	icon_state = "runite"
	floor_tile = /obj/item/stack/tile/mineral/runite
	custom_materials = list(/datum/material/runite = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/mineral/runite/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

//MYTHRIL
/turf/open/floor/mineral/mythril
	name = "mythril floor"
	icon_state = "mythril"
	floor_tile = /obj/item/stack/tile/mineral/mythril
	custom_materials = list(/datum/material/mythril = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_REINFORCED

/turf/open/floor/mineral/mythril/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")


// ALIEN ALLOY
/turf/open/floor/mineral/abductor
	name = "alien floor"
	icon_state = "alienpod1"
	floor_tile = /obj/item/stack/tile/mineral/abductor
	icons = list("alienpod1", "alienpod2", "alienpod3", "alienpod4", "alienpod5", "alienpod6", "alienpod7", "alienpod8", "alienpod9")
	baseturfs = /turf/open/floor/plating/abductor2
	custom_materials = list(/datum/material/alloy/alien = SMALL_MATERIAL_AMOUNT*5)
	rust_resistance = RUST_RESISTANCE_ORGANIC
	damaged_dmi = null

/turf/open/floor/mineral/abductor/Initialize(mapload)
	. = ..()
	icon_state = "alienpod[rand(1,9)]"

/turf/open/floor/mineral/abductor/break_tile()
	return //unbreakable

/turf/open/floor/mineral/abductor/burn_tile()
	return //unburnable
