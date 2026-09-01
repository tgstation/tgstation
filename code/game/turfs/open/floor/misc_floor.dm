// Usage for a bar light is 160, let's do a bit less then that since these tend to be used a lot in one place
#define CIRCUIT_FLOOR_POWERUSE 120
//Circuit flooring, glows a little
/turf/open/floor/circuit
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	base_icon_state = "bcircuit"
	light_color = LIGHT_COLOR_BABY_BLUE
	floor_tile = /obj/item/stack/tile/circuit
	rust_resistance = RUST_RESISTANCE_REINFORCED
	/// If we want to ignore our area's power status and just be always off
	/// Mostly for mappers doing asthetic things, or cases where the floor should be broken
	var/always_off = FALSE
	/// If this floor is powered or not
	/// We don't consume any power, but we do require it
	var/on = -1

/turf/open/floor/circuit/Initialize(mapload)
	SSmapping.nuke_tiles += src
	RegisterSignal(loc, COMSIG_AREA_POWER_CHANGE, PROC_REF(handle_powerchange))
	var/area/cur_area = get_area(src)
	if (!isnull(cur_area))
		handle_powerchange(cur_area, TRUE)
	. = ..()

/turf/open/floor/circuit/Destroy()
	SSmapping.nuke_tiles -= src
	UnregisterSignal(loc, COMSIG_AREA_POWER_CHANGE)
	var/area/cur_area = get_area(src)
	if(on && !isnull(cur_area))
		cur_area.removeStaticPower(CIRCUIT_FLOOR_POWERUSE, AREA_USAGE_STATIC_LIGHT)
	return ..()

/turf/open/floor/circuit/update_appearance(updates)
	. = ..()
	if(!on)
		set_light(0)
		return

	set_light_color(LAZYLEN(SSmapping.nuke_threats) ? LIGHT_COLOR_INTENSE_RED : initial(light_color))
	set_light(2, 1.5)

/turf/open/floor/circuit/update_icon_state()
	icon_state = on ? (LAZYLEN(SSmapping.nuke_threats) ? "rcircuitanim" : initial(icon_state)) : "[base_icon_state]off"
	return ..()

/turf/open/floor/circuit/on_change_area(area/old_area, area/new_area)
	. = ..()
	UnregisterSignal(old_area, COMSIG_AREA_POWER_CHANGE)
	RegisterSignal(new_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(handle_powerchange))
	if(on)
		old_area.removeStaticPower(CIRCUIT_FLOOR_POWERUSE, AREA_USAGE_STATIC_LIGHT)
	handle_powerchange(new_area)

/// Enables/disables our lighting based off our source area
/turf/open/floor/circuit/proc/handle_powerchange(area/source, mapload = FALSE)
	SIGNAL_HANDLER
	var/old_on = on
	if(always_off)
		on = FALSE
	else
		on = source.powered(AREA_USAGE_LIGHT)
	if(on == old_on)
		return

	if(on)
		source.addStaticPower(CIRCUIT_FLOOR_POWERUSE, AREA_USAGE_STATIC_LIGHT)
	else if (!mapload)
		source.removeStaticPower(CIRCUIT_FLOOR_POWERUSE, AREA_USAGE_STATIC_LIGHT)
	update_appearance()

#undef CIRCUIT_FLOOR_POWERUSE

/turf/open/floor/circuit/off
	icon_state = "bcircuitoff"
	always_off = TRUE

/turf/open/floor/circuit/no_light
	always_off = TRUE

/turf/open/floor/circuit/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/telecomms/mainframe
	name = "mainframe base"

/turf/open/floor/circuit/telecomms/server
	name = "server base"

/turf/open/floor/circuit/green
	icon_state = "gcircuit"
	base_icon_state = "gcircuit"
	light_color = LIGHT_COLOR_VIVID_GREEN
	floor_tile = /obj/item/stack/tile/circuit/green

/turf/open/floor/circuit/green/off
	icon_state = "gcircuitoff"
	always_off = TRUE

/turf/open/floor/circuit/green/anim
	icon_state = "gcircuitanim"
	floor_tile = /obj/item/stack/tile/circuit/green/anim

/turf/open/floor/circuit/green/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/green/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/green/telecomms/mainframe
	name = "mainframe base"

/turf/open/floor/circuit/red
	icon_state = "rcircuit"
	base_icon_state = "rcircuit"
	light_color = LIGHT_COLOR_INTENSE_RED
	floor_tile = /obj/item/stack/tile/circuit/red

/turf/open/floor/circuit/red/off
	icon_state = "rcircuitoff"
	always_off = TRUE

/turf/open/floor/circuit/red/no_power
	always_off = TRUE

/turf/open/floor/circuit/red/anim
	icon_state = "rcircuitanim"
	floor_tile = /obj/item/stack/tile/circuit/red/anim

/turf/open/floor/circuit/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/red/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/ash
	icon_state = "ash"
	base_icon_state = "ash"
	light_color = LIGHT_COLOR_INTENSE_RED
	floor_tile = /obj/item/stack/tile/circuit/ash

/turf/open/floor/circuit/ash/off
	icon_state = "ash_off"
	always_off = TRUE

/turf/open/floor/circuit/red/no_power
	always_off = TRUE

/turf/open/floor/circuit/red/anim
	icon_state = "ash"

/turf/open/floor/circuit/ash/alt
	icon_state = "ash_alt"
	base_icon_state = "ash_alt"
	floor_tile = /obj/item/stack/tile/circuit/ash/alt

/turf/open/floor/circuit/ash/alt/off
	icon_state = "ash_alt_off"
	always_off = TRUE

/turf/open/floor/circuit/red/alt/no_power
	always_off = TRUE

/turf/open/floor/circuit/red/alt/anim
	icon_state = "ash_alt"

/turf/open/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	slowdown = -0.3

/turf/open/floor/noslip/broken_states()
	return list("noslip-damaged1","noslip-damaged2","noslip-damaged3")

/turf/open/floor/noslip/burnt_states()
	return list("noslip-scorched1","noslip-scorched2")

/turf/open/floor/noslip/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/noslip/tram/Initialize(mapload)
	. = ..()
	var/current_holiday_color = request_decoration_colors(src, PATTERN_VERTICAL_STRIPE)
	if(current_holiday_color)
		color = current_holiday_color
	else
		color = "#EFB341"

/turf/open/floor/oldshuttle
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/iron/base

/turf/open/floor/bluespace
	slowdown = -1
	icon_state = "bluespace"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds."
	floor_tile = /obj/item/stack/tile/bluespace


/turf/open/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Time seems to flow very slowly around these tiles."
	floor_tile = /obj/item/stack/tile/sepia


/turf/open/floor/bronze
	name = "bronze floor"
	desc = "Some heavy bronze tiles."
	icon_state = "clockwork_floor"
	floor_tile = /obj/item/stack/tile/bronze

/turf/open/floor/bronze/flat
	icon_state = "reebe"
	floor_tile = /obj/item/stack/tile/bronze/flat

/turf/open/floor/bronze/filled
	icon_state = "clockwork_floor_filled"
	floor_tile = /obj/item/stack/tile/bronze/filled

/turf/open/floor/bronze/filled/lavaland
	planetary_atmos = TRUE
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/bronze/filled/icemoon
	planetary_atmos = TRUE
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/white
	name = "white floor"
	desc = "A tile in a pure white color."
	icon_state = "pure_white"

/turf/open/floor/black
	name = "black floor"
	icon_state = "black"

/turf/open/floor/greenscreen
	name = "greenscreen"
	icon_state = "green"

/turf/open/floor/plastic
	name = "plastic floor"
	desc = "Cheap, lightweight flooring. Melts easily."
	icon_state = "plastic"
	thermal_conductivity = 0.1
	heat_capacity = 900
	custom_materials = list(/datum/material/plastic=SMALL_MATERIAL_AMOUNT*5)
	floor_tile = /obj/item/stack/tile/plastic

/turf/open/floor/plastic/broken_states()
	return list("plastic-damaged1","plastic-damaged2")

/turf/open/floor/plastic/puzzle
	name = "plastic puzzle floor"
	icon_state = "plastic_puzzle"
	floor_tile = /obj/item/stack/tile/plastic/puzzle

/turf/open/floor/plastic/puzzle/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/meat
	name = "meat floor"
	icon_state = "meat"
	desc = "Floor is meat!"
	custom_materials = list(/datum/material/meat=SMALL_MATERIAL_AMOUNT*5)
	floor_tile = /obj/item/stack/tile/meat

/turf/open/floor/meat/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/meat/fresh
	name = "fresh meat floor"
	icon_state = "meat_fresh"
	floor_tile = /obj/item/stack/tile/meat/fresh

/turf/open/floor/bone
	name = "bone floor"
	icon_state = "bone_tile"
	desc = "Those bones were once creatures with individidual hopes and dreams. Just a thing to think about as you walk on them."
	custom_materials = list(/datum/material/bone=SMALL_MATERIAL_AMOUNT*5)
	floor_tile = /obj/item/stack/tile/bone

/turf/open/floor/bone/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/bone/corner
	name = "bone corner floor"
	icon_state = "bone_corner"
	floor_tile = /obj/item/stack/tile/bone/corner

/turf/open/floor/bone/straight
	name = "bone straight floor"
	icon_state = "bone_straight"
	floor_tile = /obj/item/stack/tile/bone/straight

/turf/open/floor/bone/spine
	name = "spine floor"
	icon_state = "bone_spine"
	floor_tile = /obj/item/stack/tile/bone/spine

/turf/open/floor/bone/meaty
	name = "meaty bone floor"
	icon_state = "meatbone_tile"
	desc = "Spine-crawling, made literal."
	floor_tile = /obj/item/stack/tile/bone/meaty

/turf/open/floor/bone/meaty/corner
	name = "meaty bone corner floor"
	icon_state = "meatbone_corner"
	floor_tile = /obj/item/stack/tile/bone/meaty/corner

/turf/open/floor/bone/meaty/straight
	name = "meaty bone straight floor"
	icon_state = "meatbone_straight"
	floor_tile = /obj/item/stack/tile/bone/meaty/straight

/turf/open/floor/bone/meaty/spine
	name = "meaty spine floor"
	icon_state = "meatbone_spine"
	floor_tile = /obj/item/stack/tile/bone/meaty/spine

/turf/open/floor/hauntium
	name = "hauntium floor"
	icon_state = "hauntium"
	desc = "Now this is one spooky tile."
	custom_materials = list(/datum/material/hauntium=SMALL_MATERIAL_AMOUNT*5)
	floor_tile = /obj/item/stack/tile/hauntium

/turf/open/floor/hauntium/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/hauntium/ghostbricked
	name = "ghostbricked hauntium floor"
	icon_state = "hauntium_ghostbricked"
	floor_tile = /obj/item/stack/tile/hauntium/ghostbricked

/turf/open/floor/neo
	name = "neo tile"
	desc = "It's pink and black because it shouldn't exist!"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*5)
	floor_tile = /obj/item/stack/tile/neo

/turf/open/floor/neo/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/neo/red
	name = "red neo tile"
	icon_state = "neo_red"
	desc = "A neo tile. Radiates with the power of ketchup."
	floor_tile = /obj/item/stack/tile/neo/red

/turf/open/floor/neo/purple
	name = "purple neo tile"
	icon_state = "neo_purple"
	desc = "A neo tile. Radiates with the power of neo. Duh."
	floor_tile = /obj/item/stack/tile/neo/purple

/turf/open/floor/neo/orange
	name = "orange neo tile"
	icon_state = "neo_orange"
	desc = "A neo tile. Radiates with the power of 80s stylized sunset and tequilla."
	floor_tile = /obj/item/stack/tile/neo/orange

/turf/open/floor/neo/cyan
	name = "cyan neo tile"
	icon_state = "neo_cyan"
	desc = "A neo tile. Radiates with the power of being pedantic about colour names."
	floor_tile = /obj/item/stack/tile/neo/cyan

/turf/open/floor/stone
	name = "stone brick floor"
	desc = "Odd, really, how it looks exactly like the iron walls yet is stone instead of iron. Now, if that's really more of a complaint about\
		the ironness of walls or the stoneness of the floors, that's really up to you. But have you really ever seen iron that dull? I mean, it\
		makes sense for the station to have dull metal walls but we're talking how a rudimentary iron wall would be. Medieval ages didn't even\
		use iron walls, iron walls are actually not even something that exists because iron is an expensive and not-so-great thing to build walls\
		out of. It only makes sense in the context of space because you're trying to keep a freezing vacuum out. Is anyone following me on this? \
		The idea of a \"rudimentary\" iron wall makes no sense at all! Is anything i'm even saying here true? Someone's gotta fact check this!"
	icon_state = "stone_floor"
	custom_materials = list(/datum/material/rock=SMALL_MATERIAL_AMOUNT*5)

/turf/open/floor/stone/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/sandstone
	name = "sandstone brick floor"
	desc = "Sandstone tile. Makes you feel quite like a pharoah."
	icon_state = "sandstone_floor"
	custom_materials = list(/datum/material/sandstone=SMALL_MATERIAL_AMOUNT*5)
	floor_tile = /obj/item/stack/tile/mineral/sandstone

/turf/open/floor/sandstone/cobbled
	name = "cobbled sandstone floor"
	icon_state = "sandstone_cobbled"
	floor_tile = /obj/item/stack/tile/mineral/sandstone/cobbled

/turf/open/floor/sandstone/tiled
	name = "sandstone tile"
	icon_state = "sandstonevault"
	floor_tile = /obj/item/stack/tile/mineral/sandstone/tiled

/turf/open/floor/sandstone/basalt
	name = "basalt brick tile"
	icon_state = "basaltbrick_floor"
	floor_tile = /obj/item/stack/tile/mineral/sandstone/basalt

/turf/open/floor/silvergold
	name = "silver and gold floor"
	desc = "Floor made from silver and gold, in scaly pattern. As if just one or the other wasn't lavish enough."
	icon_state = "blade"
	custom_materials = list(/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT / 4, /datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT / 4)
	floor_tile = /obj/item/stack/tile/silvergold

/turf/open/floor/silvergold/sword
	name = "sword floor"
	desc = "Floor made from silver and gold, in scaly pattern, with a sword in the middle."
	icon_state = "blade_sword"
	floor_tile = /obj/item/stack/tile/silvergold/sword

/turf/open/floor/silvergold/void
	name = "stars tile"
	desc = "Floor made from silver and gold, picturing stars. As opposed to the actual stars you are surrounded by."
	icon_state = "void"
	floor_tile = /obj/item/stack/tile/silvergold/void

/turf/open/floor/silvergold/flow
	name = "flowing tile"
	desc = "Floor made from silver and gold, with a flowing pattern. Silver and gold in balance."
	icon_state = "flow"
	floor_tile = /obj/item/stack/tile/silvergold/flow

/turf/open/floor/eighties
	name = "retro floor"
	desc = "This one takes you back."
	icon_state = "eighties"
	floor_tile = /obj/item/stack/tile/eighties
	rust_resistance = RUST_RESISTANCE_BASIC

/turf/open/floor/eighties/broken_states()
	return list("eighties_damaged")

/turf/open/floor/eighties/red
	name = "red retro floor"
	desc = "Totally RED-ICAL!"
	icon_state = "eightiesred"
	floor_tile = /obj/item/stack/tile/eighties/red

/turf/open/floor/eighties/red/broken_states()
	return list("eightiesred_damaged")

/turf/open/floor/plating/rust
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = COLOR_BROWN

/turf/open/floor/plating/rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust)
	color = null

/turf/open/floor/plating/rust/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/heretic_rust
	color = COLOR_GREEN_GRAY

/turf/open/floor/plating/heretic_rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust/heretic)
	color = null

/turf/open/floor/plating/plasma
	initial_gas_mix = ATMOS_TANK_PLASMA

/turf/open/floor/plating/plasma/rust/Initialize(mapload)
	. = ..()
	// Because this is a fluff turf explicitly for KiloStation it doesn't make sense to ChangeTurf like usual
	// Especially since it looks like we don't even change the default icon/iconstate???
	AddElement(/datum/element/rust)

/turf/open/floor/vault
	name = "strange floor"
	desc = "You feel a strange nostalgia from looking at this..."
	icon_state = "rockvault"
	base_icon_state = "rockvault"

/turf/open/floor/vault/rock
	name = "rocky floor"

/turf/open/floor/vault/alien
	name = "alien floor"
	icon_state = "alienvault"
	base_icon_state = "alienvault"

/turf/open/floor/vault/sandstone
	name = "sandstone floor"
	icon_state = "sandstonevault"
	base_icon_state = "sandstonevault"

/turf/open/floor/cult
	name = "engraved floor"
	icon_state = "cult"
	base_icon_state = "cult"
	floor_tile = /obj/item/stack/tile/cult

/turf/open/floor/cult/broken_states()
	return list("cultdamage","cultdamage2","cultdamage3","cultdamage4","cultdamage5","cultdamage6","cultdamage7")

/turf/open/floor/cult/narsie_act()
	return

/turf/open/floor/cult/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/material/meat
	name = "living floor"
	icon_state = "grey"
	baseturfs = /turf/open/misc/asteroid
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/turf/open/floor/material/meat/Initialize(mapload)
	. = ..()
	set_custom_materials(list(SSmaterials.get_material(/datum/material/meat) = SHEET_MATERIAL_AMOUNT))

/turf/open/floor/material/meat/airless
	initial_gas_mix = AIRLESS_ATMOS
	baseturfs = /turf/open/misc/asteroid/airless

/turf/open/floor/iron/tgmcemblem
	name = "TGMC Emblem"
	desc = "The symbol of the Terran Government."
	icon_state = "tgmc_emblem"

/turf/open/floor/iron/tgmcemblem/center
	icon_state = "tgmc_center"

/turf/open/floor/asphalt
	name = "asphalt"
	desc = "Melted down oil can, in some cases, be used to pave road surfaces."
	icon_state = "asphalt"

/turf/open/floor/asphalt/outdoors
	planetary_atmos = TRUE

/turf/open/floor/asphalt/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	baseturfs = /turf/open/misc/asteroid/basalt

/turf/open/floor/asphalt/lavaland/outdoors
	planetary_atmos = TRUE
