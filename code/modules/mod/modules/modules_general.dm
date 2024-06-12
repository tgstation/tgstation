//General modules for MODsuits

///Storage - Adds a storage component to the suit.
/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "What amounts to a series of integrated storage compartments and specialized pockets installed across \
		the surface of the suit, useful for storing various bits, and or bobs."
	icon_state = "storage"
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/plate_compression)
	required_slots = list(ITEM_SLOT_BACK)
	/// Max weight class of items in the storage.
	var/max_w_class = WEIGHT_CLASS_NORMAL
	/// Max combined weight of all items in the storage.
	var/max_combined_w_class = 15
	/// Max amount of items in the storage.
	var/max_items = 7
	/// Is nesting same-size storage items allowed?
	var/big_nesting = FALSE

/obj/item/mod/module/storage/Initialize(mapload)
	. = ..()
	create_storage(max_specific_storage = max_w_class, max_total_storage = max_combined_w_class, max_slots = max_items)
	atom_storage.allow_big_nesting = TRUE
	atom_storage.locked = STORAGE_FULLY_LOCKED

/obj/item/mod/module/storage/on_install()
	var/datum/storage/modstorage = mod.create_storage(max_specific_storage = max_w_class, max_total_storage = max_combined_w_class, max_slots = max_items)
	modstorage.set_real_location(src)
	modstorage.allow_big_nesting = big_nesting
	atom_storage.locked = STORAGE_NOT_LOCKED
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		RegisterSignal(suit, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_suit_unequip))

/obj/item/mod/module/storage/on_uninstall(deleting = FALSE)
	atom_storage.locked = STORAGE_FULLY_LOCKED
	QDEL_NULL(mod.atom_storage)
	if(!deleting)
		atom_storage.remove_all(mod.drop_location())
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		UnregisterSignal(suit, COMSIG_ITEM_PRE_UNEQUIP)

/obj/item/mod/module/storage/proc/on_suit_unequip(obj/item/source, force, atom/newloc, no_move, invdrop, silent)
	if(QDELETED(source) || !mod.wearer || newloc == mod.wearer || !mod.wearer.s_store)
		return
	if(!atom_storage?.attempt_insert(mod.wearer.s_store, mod.wearer, override = TRUE))
		balloon_alert(mod.wearer, "storage failed!")
		to_chat(mod.wearer, span_warning("[src] fails to store [mod.wearer.s_store] inside itself!"))
		return
	to_chat(mod.wearer, span_notice("[src] stores [mod.wearer.s_store] inside itself."))
	mod.wearer.temporarilyRemoveItemFromInventory(mod.wearer.s_store)

/obj/item/mod/module/storage/large_capacity
	name = "MOD expanded storage module"
	desc = "Reverse engineered by Nakamura Engineering from Donk Corporation designs, this system of hidden compartments \
		is entirely within the suit, distributing items and weight evenly to ensure a comfortable experience for the user; \
		whether smuggling, or simply hauling."
	icon_state = "storage_large"
	max_combined_w_class = 21
	max_items = 14

/obj/item/mod/module/storage/syndicate
	name = "MOD syndicate storage module"
	desc = "A storage system using nanotechnology developed by Cybersun Industries, these compartments use \
		esoteric technology to compress the physical matter of items put inside of them, \
		essentially shrinking items for much easier and more portable storage."
	icon_state = "storage_syndi"
	max_combined_w_class = 30
	max_items = 21

/obj/item/mod/module/storage/belt
	name = "MOD case storage module"
	desc = "Some concessions had to be made when creating a compressed modular suit core. \
		As a result, Roseus Galactic equipped their suit with a slimline storage case.  \
		If you find this equipped to a standard modular suit, then someone has almost certainly shortchanged you on a proper storage module."
	icon_state = "storage_case"
	complexity = 0
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 21
	max_items = 7
	required_slots = list(ITEM_SLOT_BELT)

/obj/item/mod/module/storage/bluespace
	name = "MOD bluespace storage module"
	desc = "A storage system developed by Nanotrasen, these compartments employ \
		miniaturized bluespace pockets for the ultimate in storage technology; regardless of the weight of objects put inside."
	icon_state = "storage_large"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 60
	max_items = 21
	big_nesting = TRUE

///Ion Jetpack - Lets the user fly freely through space using battery charge.
/obj/item/mod/module/jetpack
	name = "MOD ion jetpack module"
	desc = "A series of electric thrusters installed across the suit, this is a module highly anticipated by trainee Engineers. \
		Rather than using gasses for combustion thrust, these jets are capable of accelerating ions using \
		charge from the suit's charge. Some say this isn't Nakamura Engineering's first foray into jet-enabled suits."
	icon_state = "jetpack"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/jetpack)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_jetpack"
	overlay_state_active = "module_jetpack_on"
	required_slots = list(ITEM_SLOT_BACK)
	/// Do we give the wearer a speed buff.
	var/full_speed = FALSE
	/// Do we have stabilizers? If yes the user won't move from inertia.
	var/stabilize = TRUE
	/// Callback to see if we can thrust the user.
	var/thrust_callback

/obj/item/mod/module/jetpack/Initialize(mapload)
	. = ..()
	thrust_callback = CALLBACK(src, PROC_REF(allow_thrust))
	configure_jetpack(stabilize)

/obj/item/mod/module/jetpack/Destroy()
	thrust_callback = null
	return ..()

/**
 * configures/re-configures the jetpack component
 *
 * Arguments
 * stabilize - Should this jetpack be stabalized
 */
/obj/item/mod/module/jetpack/proc/configure_jetpack(stabilize)
	src.stabilize = stabilize

	AddComponent( \
		/datum/component/jetpack, \
		src.stabilize, \
		COMSIG_MODULE_TRIGGERED, \
		COMSIG_MODULE_DEACTIVATED, \
		MOD_ABORT_USE, \
		thrust_callback, \
		/datum/effect_system/trail_follow/ion/grav_allowed \
	)

/obj/item/mod/module/jetpack/on_activation()
	if(full_speed)
		mod.wearer.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/mod/module/jetpack/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(full_speed)
		mod.wearer.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/mod/module/jetpack/get_configuration()
	. = ..()
	.["stabilizers"] = add_ui_configuration("Stabilizers", "bool", stabilize)

/obj/item/mod/module/jetpack/configure_edit(key, value)
	switch(key)
		if("stabilizers")
			configure_jetpack(text2num(value))

/obj/item/mod/module/jetpack/proc/allow_thrust(use_fuel = TRUE)
	if(!use_fuel)
		return check_power(use_energy_cost)
	if(!drain_power(use_energy_cost))
		return FALSE
	return TRUE

/obj/item/mod/module/jetpack/advanced
	name = "MOD advanced ion jetpack module"
	desc = "An improvement on the previous model of electric thrusters. This one achieves higher speeds through \
		mounting of more jets and application of red paint."
	icon_state = "jetpack_advanced"
	overlay_state_inactive = "module_jetpackadv"
	overlay_state_active = "module_jetpackadv_on"
	full_speed = TRUE

/// Cooldown to use if we didn't actually launch a jump jet
#define FAILED_ACTIVATION_COOLDOWN 3 SECONDS

///Jump Jet - Briefly removes the effect of gravity and pushes you up one z-level if possible.
/obj/item/mod/module/jump_jet
	name = "MOD ionic jump jet module"
	desc = "A specialised ionic thruster which provides a short but powerful boost capable of pushing against gravity, \
		after which time it needs to recharge."
	icon_state = "jump_jet"
	module_type = MODULE_USABLE
	complexity = 3
	cooldown_time = 30 SECONDS
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/jump_jet)
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/jump_jet/on_use()
	. = ..()
	if (!.)
		return FALSE
	if (DOING_INTERACTION(mod.wearer, mod.wearer))
		balloon_alert(mod.wearer, "busy!")
		return
	balloon_alert(mod.wearer, "launching...")
	mod.wearer.Shake(duration = 1 SECONDS)
	if (!do_after(mod.wearer, 1 SECONDS, target = mod.wearer))
		start_cooldown(FAILED_ACTIVATION_COOLDOWN) // Don't go on full cooldown if we failed to launch
		return FALSE
	playsound(mod.wearer, 'sound/vehicles/rocketlaunch.ogg', 100, TRUE)
	mod.wearer.apply_status_effect(/datum/status_effect/jump_jet)
	var/turf/launch_from = get_turf(mod.wearer)
	if (mod.wearer.zMove(UP, z_move_flags = ZMOVE_CHECK_PULLS))
		launch_from.visible_message(span_warning("[mod.wearer] rockets into the air!"))
	new /obj/effect/temp_visual/jet_plume(launch_from)

	var/obj/item/mod/module/jetpack/linked_jetpack = locate() in mod.modules
	if (!isnull(linked_jetpack) && !linked_jetpack.active)
		linked_jetpack.on_activation()
	return TRUE

#undef FAILED_ACTIVATION_COOLDOWN

///Status Readout - Puts a lot of information including health, nutrition, fingerprints, temperature to the suit TGUI.
/obj/item/mod/module/status_readout
	name = "MOD status readout module"
	desc = "A once-common module, this technology unfortunately went out of fashion in the safer regions of space; \
		and found new life in the research networks of the Periphery. This particular unit hooks into the suit's spine, \
		capable of capturing and displaying all possible biometric data of the wearer; sleep, nutrition, fitness, fingerprints, \
		and even useful information such as their overall health and wellness. The vitals monitor also comes with a speaker, loud enough \
		to alert anyone nearby that someone has, in fact, died."
	icon_state = "status"
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/status_readout)
	tgui_id = "status_readout"
	required_slots = list(ITEM_SLOT_BACK)
	/// Does this show damage types, body temp, satiety
	var/display_detailed_vitals = TRUE
	/// Does this show DNA data
	var/display_dna = FALSE
	/// Does this show the round ID and shift time?
	var/display_time = FALSE
	/// Death sound. May or may not be funny. Vareditable at your own risk.
	var/death_sound = 'sound/effects/flatline3.ogg'
	/// Death sound volume. Please be responsible with this.
	var/death_sound_volume = 50

/obj/item/mod/module/status_readout/add_ui_data()
	. = ..()
	.["display_time"] = display_time
	.["shift_time"] = station_time_timestamp()
	.["shift_id"] = GLOB.round_id
	.["health"] = mod.wearer?.health || 0
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	if(display_detailed_vitals)
		.["loss_brute"] = mod.wearer?.getBruteLoss() || 0
		.["loss_fire"] = mod.wearer?.getFireLoss() || 0
		.["loss_tox"] = mod.wearer?.getToxLoss() || 0
		.["loss_oxy"] = mod.wearer?.getOxyLoss() || 0
		.["body_temperature"] = mod.wearer?.bodytemperature || 0
		.["nutrition"] = mod.wearer?.nutrition || 0
	if(display_dna)
		.["dna_unique_identity"] = mod.wearer ? md5(mod.wearer.dna.unique_identity) : null
		.["dna_unique_enzymes"] = mod.wearer?.dna.unique_enzymes
	.["viruses"] = null
	if(!length(mod.wearer?.diseases))
		return .
	var/list/viruses = list()
	for(var/datum/disease/virus as anything in mod.wearer.diseases)
		var/list/virus_data = list()
		virus_data["name"] = virus.name
		virus_data["type"] = virus.spread_text
		virus_data["stage"] = virus.stage
		virus_data["maxstage"] = virus.max_stages
		virus_data["cure"] = virus.cure_text
		viruses += list(virus_data)
	.["viruses"] = viruses

	return .

/obj/item/mod/module/status_readout/get_configuration()
	. = ..()
	.["display_detailed_vitals"] = add_ui_configuration("Detailed Vitals", "bool", display_detailed_vitals)
	.["display_dna"] = add_ui_configuration("DNA Information", "bool", display_dna)

/obj/item/mod/module/status_readout/configure_edit(key, value)
	switch(key)
		if("display_detailed_vitals")
			display_detailed_vitals = text2num(value)
		if("display_dna")
			display_dna = text2num(value)

/obj/item/mod/module/status_readout/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_LIVING_DEATH, PROC_REF(death_sound))

/obj/item/mod/module/status_readout/on_suit_deactivation(deleting)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_DEATH)

/obj/item/mod/module/status_readout/proc/death_sound(mob/living/carbon/human/wearer)
	SIGNAL_HANDLER
	if(death_sound && death_sound_volume)
		playsound(wearer, death_sound, death_sound_volume, FALSE)

///Eating Apparatus - Lets the user eat/drink with the suit on.
/obj/item/mod/module/mouthhole
	name = "MOD eating apparatus module"
	desc = "A favorite by Miners, this modification to the helmet utilizes a nanotechnology barrier infront of the mouth \
		to allow eating and drinking while retaining protection and atmosphere. However, it won't free you from masks, \
		lets pepper spray pass through and it will do nothing to improve the taste of a goliath steak."
	icon_state = "apparatus"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/mouthhole)
	overlay_state_inactive = "module_apparatus"
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// Former flags of the helmet.
	var/former_helmet_flags = NONE
	/// Former visor flags of the helmet.
	var/former_visor_helmet_flags = NONE
	/// Former flags of the mask.
	var/former_mask_flags = NONE
	/// Former visor flags of the mask.
	var/former_visor_mask_flags = NONE

/obj/item/mod/module/mouthhole/on_install()
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		former_helmet_flags = helmet.flags_cover
		former_visor_helmet_flags = helmet.visor_flags_cover
		helmet.flags_cover &= ~(HEADCOVERSMOUTH|PEPPERPROOF)
		helmet.visor_flags_cover &= ~(HEADCOVERSMOUTH|PEPPERPROOF)
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(istype(mask))
		former_mask_flags = mask.flags_cover
		former_visor_mask_flags = mask.visor_flags_cover
		mask.flags_cover &= ~(MASKCOVERSMOUTH |PEPPERPROOF)
		mask.visor_flags_cover &= ~(MASKCOVERSMOUTH |PEPPERPROOF)

/obj/item/mod/module/mouthhole/on_uninstall(deleting = FALSE)
	if(deleting)
		return
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		helmet.flags_cover |= former_helmet_flags
		helmet.visor_flags_cover |= former_visor_helmet_flags
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(istype(mask))
		mask.flags_cover |= former_mask_flags
		mask.visor_flags_cover |= former_visor_mask_flags

///EMP Shield - Protects the suit from EMPs.
/obj/item/mod/module/emp_shield
	name = "MOD EMP shield module"
	desc = "A field inhibitor installed into the suit, protecting it against feedback such as \
		electromagnetic pulses that would otherwise damage the electronic systems of the suit or it's modules. \
		However, it will take from the suit's power to do so."
	icon_state = "empshield"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/emp_shield)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/emp_shield/on_install()
	mod.AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/mod/module/emp_shield/on_uninstall(deleting = FALSE)
	mod.RemoveElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/mod/module/emp_shield/advanced
	name = "MOD advanced EMP shield module"
	desc = "An advanced field inhibitor installed into the suit, protecting it against feedback such as \
		electromagnetic pulses that would otherwise damage the electronic systems of the suit or electronic devices on the wearer, \
		including augmentations. However, it will take from the suit's power to do so."
	complexity = 2

/obj/item/mod/module/emp_shield/advanced/on_suit_activation()
	mod.wearer.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/emp_shield/advanced/on_suit_deactivation(deleting = FALSE)
	mod.wearer.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

///Flashlight - Gives the suit a customizable flashlight.
/obj/item/mod/module/flashlight
	name = "MOD flashlight module"
	desc = "A simple pair of configurable flashlights installed on the left and right sides of the helmet, \
		useful for providing light in a variety of ranges and colors. \
		Some survivalists prefer the color green for their illumination, for reasons unknown."
	icon_state = "flashlight"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/flashlight)
	cooldown_time = 0.5 SECONDS
	overlay_state_inactive = "module_light"
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1
	light_on = FALSE
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// Charge drain per range amount.
	var/base_power = DEFAULT_CHARGE_DRAIN * 0.1
	/// Minimum range we can set.
	var/min_range = 2
	/// Maximum range we can set.
	var/max_range = 5

/obj/item/mod/module/flashlight/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_HIT_BY_SABOTEUR, PROC_REF(on_saboteur))

/obj/item/mod/module/flashlight/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_HIT_BY_SABOTEUR)

/obj/item/mod/module/flashlight/on_activation()
	set_light_flags(light_flags | LIGHT_ATTACHED)
	set_light_on(active)
	active_power_cost = base_power * light_range

/obj/item/mod/module/flashlight/on_deactivation(display_message = TRUE, deleting = FALSE)
	set_light_flags(light_flags & ~LIGHT_ATTACHED)
	set_light_on(active)

/obj/item/mod/module/flashlight/proc/on_saboteur(datum/source, disrupt_duration)
	SIGNAL_HANDLER
	if(active)
		on_deactivation()
		return COMSIG_SABOTEUR_SUCCESS

/obj/item/mod/module/flashlight/on_process(seconds_per_tick)
	active_power_cost = base_power * light_range
	return ..()

/obj/item/mod/module/flashlight/generate_worn_overlay(mutable_appearance/standing)
	. = ..()
	if(!active)
		return
	var/mutable_appearance/light_icon = mutable_appearance(overlay_icon_file, "module_light_on", layer = standing.layer + 0.2)
	light_icon.appearance_flags = RESET_COLOR
	light_icon.color = light_color
	. += light_icon

/obj/item/mod/module/flashlight/get_configuration()
	. = ..()
	.["light_color"] = add_ui_configuration("Light Color", "color", light_color)
	.["light_range"] = add_ui_configuration("Light Range", "number", light_range)

/obj/item/mod/module/flashlight/configure_edit(key, value)
	switch(key)
		if("light_color")
			value = input(usr, "Pick new light color", "Flashlight Color") as color|null
			if(!value)
				return
			if(is_color_dark(value, 50))
				balloon_alert(mod.wearer, "too dark!")
				return
			set_light_color(value)
			mod.wearer.update_clothing(mod.slot_flags)
		if("light_range")
			set_light_range(clamp(value, min_range, max_range))

///Like the flashlight module, except the light color is stuck to black and cannot be changed.
/obj/item/mod/module/flashlight/darkness
	name = "MOD flashdark module"
	desc = "A quirky pair of configurable flashdarks installed on the sides of the helmet, \
		useful for providing darkness at a configurable range."
	light_color = COLOR_BLACK
	light_system = OVERLAY_LIGHT
	light_range = 2
	min_range = 1
	max_range = 3

/obj/item/mod/module/flashlight/darkness/get_configuration()
	. = ..()
	. -= "light_color"

///Dispenser - Dispenses an item after a time passes.
/obj/item/mod/module/dispenser
	name = "MOD burger dispenser module"
	desc = "A rare piece of technology reverse-engineered from a prototype found in a Donk Corporation vessel. \
		This can draw incredible amounts of power from the suit's charge to create edible organic matter in the \
		palm of the wearer's glove; however, research seemed to have entirely stopped at burgers. \
		Notably, all attempts to get it to dispense Earl Grey tea have failed."
	icon_state = "dispenser"
	module_type = MODULE_USABLE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/dispenser)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Path we dispense.
	var/dispense_type = /obj/item/food/burger/plain
	/// Time it takes for us to dispense.
	var/dispense_time = 0 SECONDS

/obj/item/mod/module/dispenser/on_use()
	if(dispense_time && !do_after(mod.wearer, dispense_time, target = mod))
		balloon_alert(mod.wearer, "interrupted!")
		return FALSE
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	balloon_alert(mod.wearer, "[dispensed] dispensed")
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_energy_cost)
	return dispensed

///Longfall - Nullifies fall damage, removing charge instead.
/obj/item/mod/module/longfall
	name = "MOD longfall module"
	desc = "Useful for protecting both the suit and the wearer, \
		utilizing commonplace systems to convert the possible damage from a fall into kinetic charge, \
		as well as internal gyroscopes to ensure the user's safe falling. \
		Useful for mining, monorail tracks, or even skydiving!"
	icon_state = "longfall"
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/longfall)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/longfall/on_suit_activation()
	RegisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT, PROC_REF(z_impact_react))

/obj/item/mod/module/longfall/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT)

/obj/item/mod/module/longfall/proc/z_impact_react(datum/source, levels, turf/fell_on)
	SIGNAL_HANDLER
	if(!drain_power(use_energy_cost * levels))
		return NONE
	new /obj/effect/temp_visual/mook_dust(fell_on)

	/// Boolean that tracks whether we fell more than one z-level. If TRUE, we stagger our wearer.
	var/extreme_fall = FALSE

	if(levels >= 2)
		extreme_fall = TRUE
		mod.wearer.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH * levels, 10 SECONDS)

	mod.wearer.visible_message(
		span_notice("[mod.wearer] lands on [fell_on] safely[extreme_fall ? ", but barely manages to stay on [p_their()] feet." : ", and quite stylishly on [p_their()] feet" ]."),
		span_notice("[src] protects you from the damage!"),
	)
	return ZIMPACT_CANCEL_DAMAGE|ZIMPACT_NO_MESSAGE|ZIMPACT_NO_SPIN

///Thermal Regulator - Regulates the wearer's core temperature.
/obj/item/mod/module/thermal_regulator
	name = "MOD thermal regulator module"
	desc = "Advanced climate control, using an inner body glove interwoven with thousands of tiny, \
		flexible cooling lines. This circulates coolant at various user-controlled temperatures, \
		ensuring they're comfortable; even if they're some that like it hot."
	icon_state = "regulator"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/thermal_regulator)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// The temperature we are regulating to.
	var/temperature_setting = BODYTEMP_NORMAL
	/// Minimum temperature we can set.
	var/min_temp = T20C
	/// Maximum temperature we can set.
	var/max_temp = 318.15

/obj/item/mod/module/thermal_regulator/get_configuration()
	. = ..()
	.["temperature_setting"] = add_ui_configuration("Temperature", "number", temperature_setting - T0C)

/obj/item/mod/module/thermal_regulator/configure_edit(key, value)
	switch(key)
		if("temperature_setting")
			temperature_setting = clamp(value + T0C, min_temp, max_temp)

/obj/item/mod/module/thermal_regulator/on_active_process(seconds_per_tick)
	mod.wearer.adjust_bodytemperature(get_temp_change_amount((temperature_setting - mod.wearer.bodytemperature), 0.08 * seconds_per_tick))

///DNA Lock - Prevents people without the set DNA from activating the suit.
/obj/item/mod/module/dna_lock
	name = "MOD DNA lock module"
	desc = "A module which engages with the various locks and seals tied to the suit's systems, \
		enabling it to only be worn by someone corresponding with the user's exact DNA profile; \
		however, this incredibly sensitive module is shorted out by EMPs. Luckily, cloning has been outlawed."
	icon_state = "dnalock"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/dna_lock, /obj/item/mod/module/eradication_lock)
	cooldown_time = 0.5 SECONDS
	/// The DNA we lock with.
	var/dna = null

/obj/item/mod/module/dna_lock/on_install()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_mod_activation))
	RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL, PROC_REF(on_mod_removal))
	RegisterSignal(mod, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp))
	RegisterSignal(mod, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))

/obj/item/mod/module/dna_lock/on_uninstall(deleting = FALSE)
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	UnregisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL)
	UnregisterSignal(mod, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(mod, COMSIG_ATOM_EMAG_ACT)

/obj/item/mod/module/dna_lock/on_use()
	dna = mod.wearer.dna.unique_enzymes
	balloon_alert(mod.wearer, "dna updated")
	drain_power(use_energy_cost)

/obj/item/mod/module/dna_lock/emp_act(severity)
	. = ..()
	on_emp(src, severity, .)

/obj/item/mod/module/dna_lock/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	return on_emag(src, user, emag_card)

/obj/item/mod/module/dna_lock/proc/dna_check(mob/user)
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/carbon_user = user
	if(!dna  || (carbon_user.has_dna() && carbon_user.dna.unique_enzymes == dna))
		return TRUE
	balloon_alert(user, "dna locked!")
	return FALSE

/obj/item/mod/module/dna_lock/proc/on_emp(datum/source, severity, protection)
	SIGNAL_HANDLER
	if(protection & EMP_PROTECT_SELF)
		return
	dna = null

/obj/item/mod/module/dna_lock/proc/on_emag(datum/source, mob/user, obj/item/card/emag/emag_card)
	SIGNAL_HANDLER

	dna = null
	return TRUE

/obj/item/mod/module/dna_lock/proc/on_mod_activation(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!dna_check(user))
		return MOD_CANCEL_ACTIVATE

/obj/item/mod/module/dna_lock/proc/on_mod_removal(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!dna_check(user))
		return MOD_CANCEL_REMOVAL

///Plasma Stabilizer - Prevents plasmamen from igniting in the suit
/obj/item/mod/module/plasma_stabilizer
	name = "MOD plasma stabilizer module"
	desc = "This system essentially forms an atmosphere of its own, within the suit, \
		efficiently and quickly preventing oxygen from causing the user's head to burst into flame. \
		This allows plasmamen to safely remove their helmet, allowing for easier \
		equipping of any MODsuit-related equipment, or otherwise. \
		The purple glass of the visor seems to be constructed for nostalgic purposes."
	icon_state = "plasma_stabilizer"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/plasma_stabilizer)
	overlay_state_inactive = "module_plasma"
	required_slots = list(ITEM_SLOT_HEAD)

/obj/item/mod/module/plasma_stabilizer/generate_worn_overlay()
	if(locate(/obj/item/mod/module/infiltrator) in mod.modules)
		return list()
	return ..()

/obj/item/mod/module/plasma_stabilizer/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION_HEAD_ONLY, MOD_TRAIT)

/obj/item/mod/module/plasma_stabilizer/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION_HEAD_ONLY, MOD_TRAIT)


//Finally, https://pipe.miroware.io/5b52ba1d94357d5d623f74aa/mspfa/Nuke%20Ops/Panels/0648.gif can be real:
///Hat Stabilizer - Allows displaying a hat over the MOD-helmet, à la plasmamen helmets.
/obj/item/mod/module/hat_stabilizer
	name = "MOD hat stabilizer module"
	desc = "A simple set of deployable stands, directly atop one's head; \
		these will deploy under a hat to keep it from falling off, allowing them to be worn atop the sealed helmet. \
		You still need to take the hat off your head while the helmet deploys, though. \
		This is a must-have for Nanotrasen Captains, enabling them to show off their authoritative hat even while in their MODsuit."
	icon_state = "hat_holder"
	incompatible_modules = list(/obj/item/mod/module/hat_stabilizer)
	required_slots = list(ITEM_SLOT_HEAD)
	/*Intentionally left inheriting 0 complexity and removable = TRUE;
	even though it comes inbuilt into the Magnate/Corporate MODS and spawns in maints, I like the idea of stealing them*/
	/// Currently "stored" hat. No armor or function will be inherited, only the icon and cover flags.
	var/obj/item/clothing/head/attached_hat
	/// Original cover flags for the MOD helmet, before a hat is placed
	var/former_flags
	var/former_visor_flags

/obj/item/mod/module/hat_stabilizer/on_suit_activation()
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(!istype(helmet))
		return
	RegisterSignal(helmet, COMSIG_ATOM_EXAMINE, PROC_REF(add_examine))
	RegisterSignal(helmet, COMSIG_ATOM_ATTACKBY, PROC_REF(place_hat))
	RegisterSignal(helmet, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(remove_hat))

/obj/item/mod/module/hat_stabilizer/on_suit_deactivation(deleting = FALSE)
	if(deleting)
		return
	if(attached_hat)	//knock off the helmet if its on their head. Or, technically, auto-rightclick it for them; that way it saves us code, AND gives them the bubble
		remove_hat(src, mod.wearer)
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(!istype(helmet))
		return
	UnregisterSignal(helmet, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(helmet, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(helmet, COMSIG_ATOM_ATTACK_HAND_SECONDARY)

/obj/item/mod/module/hat_stabilizer/proc/add_examine(datum/source, mob/user, list/base_examine)
	SIGNAL_HANDLER
	if(attached_hat)
		base_examine += span_notice("There's \a [attached_hat] placed on the helmet. Right-click to remove it.")
	else
		base_examine += span_notice("There's nothing placed on the helmet. Yet.")

/obj/item/mod/module/hat_stabilizer/proc/place_hat(datum/source, obj/item/hitting_item, mob/user)
	SIGNAL_HANDLER
	if(!istype(hitting_item, /obj/item/clothing/head))
		return
	var/obj/item/clothing/hat = hitting_item
	if(!mod.active)
		balloon_alert(user, "suit must be active!")
		return
	if(attached_hat)
		balloon_alert(user, "hat already attached!")
		return
	if(hat.clothing_flags & STACKABLE_HELMET_EXEMPT)
		balloon_alert(user, "invalid hat!")
		return
	if(mod.wearer.transferItemToLoc(hitting_item, src, force = FALSE, silent = TRUE))
		attached_hat = hat
		var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
		if(istype(helmet))
			former_flags = helmet.flags_cover
			former_visor_flags = helmet.visor_flags_cover
			helmet.flags_cover |= attached_hat.flags_cover
			helmet.visor_flags_cover |= attached_hat.visor_flags_cover
		balloon_alert(user, "hat attached, right-click to remove")
		mod.wearer.update_clothing(mod.slot_flags)

/obj/item/mod/module/hat_stabilizer/generate_worn_overlay()
	. = ..()
	if(attached_hat)
		. += attached_hat.build_worn_icon(default_layer = ABOVE_BODY_FRONT_HEAD_LAYER-0.1, default_icon_file = 'icons/mob/clothing/head/default.dmi')

/obj/item/mod/module/hat_stabilizer/proc/remove_hat(datum/source, mob/user)
	SIGNAL_HANDLER
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!attached_hat)
		return
	attached_hat.forceMove(drop_location())
	if(user.put_in_active_hand(attached_hat))
		balloon_alert(user, "hat removed")
	else
		balloon_alert_to_viewers("the hat falls to the floor!")
	attached_hat = null
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		helmet.flags_cover = former_flags
		helmet.visor_flags_cover = former_visor_flags
	mod.wearer.update_clothing(mod.slot_flags)

/obj/item/mod/module/hat_stabilizer/syndicate
	name = "MOD elite hat stabilizer module"
	desc = "A simple set of deployable stands, directly atop one's head; \
		these will deploy under a hat to keep it from falling off, allowing them to be worn atop the sealed helmet. \
		You still need to take the hat off your head while the helmet deploys, though. This is a must-have for \
		Syndicate Operatives and Agents alike, enabling them to continue to style on the opposition even while in their MODsuit."
	complexity = 0
	removable = FALSE

///Sign Language Translator - allows people to sign over comms using the modsuit's gloves.
/obj/item/mod/module/signlang_radio
	name = "MOD glove translator module"
	desc = "A module that adds motion sensors into the suit's gloves, \
		which works in tandem with a short-range subspace transmitter, \
		letting the audibly impaired use sign language over comms."
	icon_state = "signlang_radio"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/signlang_radio)
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/signlang_radio/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_CAN_SIGN_ON_COMMS, MOD_TRAIT)

/obj/item/mod/module/signlang_radio/on_suit_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_CAN_SIGN_ON_COMMS, MOD_TRAIT)

///A module that recharges the suit by an itsy tiny bit whenever the user takes a step. Originally called "magneto module" but the videogame reference sounds cooler.
/obj/item/mod/module/joint_torsion
	name = "MOD joint torsion ratchet module"
	desc = "A compact, weak AC generator that charges the suit's internal cell through the power of deambulation. It doesn't work in zero G."
	icon_state = "joint_torsion"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/joint_torsion)
	required_slots = list(ITEM_SLOT_FEET)
	var/power_per_step = DEFAULT_CHARGE_DRAIN * 0.3

/obj/item/mod/module/joint_torsion/on_suit_activation()
	if(!(mod.wearer.movement_type & (FLOATING|FLYING)))
		RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	/// This way we don't even bother to call on_moved() while flying/floating
	RegisterSignal(mod.wearer, COMSIG_MOVETYPE_FLAG_ENABLED, PROC_REF(on_movetype_flag_enabled))
	RegisterSignal(mod.wearer, COMSIG_MOVETYPE_FLAG_DISABLED, PROC_REF(on_movetype_flag_disabled))

/obj/item/mod/module/joint_torsion/on_suit_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVETYPE_FLAG_ENABLED, COMSIG_MOVETYPE_FLAG_DISABLED))

/obj/item/mod/module/joint_torsion/proc/on_movetype_flag_enabled(datum/source, flag, old_state)
	SIGNAL_HANDLER
	if(!(old_state & (FLOATING|FLYING)) && flag & (FLOATING|FLYING))
		UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)

/obj/item/mod/module/joint_torsion/proc/on_movetype_flag_disabled(datum/source, flag, old_state)
	SIGNAL_HANDLER
	if(old_state & (FLOATING|FLYING) && !(mod.wearer.movement_type & (FLOATING|FLYING)))
		RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/mod/module/joint_torsion/proc/on_moved(mob/living/carbon/human/wearer, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	//Shouldn't work if the wearer isn't really walking/running around.
	if(forced || wearer.throwing || wearer.body_position == LYING_DOWN || wearer.buckled || CHECK_MOVE_LOOP_FLAGS(wearer, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	mod.core.add_charge(power_per_step)

/// Module that shoves garbage inside its material container when the user crosses it, and eject the recycled material with MMB.
/obj/item/mod/module/recycler
	name = "MOD recycler module"
	desc = "An innovative garbage collection module that recycles gathered trash into usable material. \
		Doesn't work on debris and some items. May recycle live ammunition. \
		Activate on a nearby turf or storage to unload stored material."
	icon_state = "recycler"
	module_type = MODULE_ACTIVE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/recycler)
	overlay_state_inactive = "module_recycler"
	overlay_state_active = "module_recycler"
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// A multiplier of the amount of material extracted from the item
	var/efficiency = 1
	/// Items that will be collected
	var/list/allowed_item_types = list(
		/obj/item/trash,
		/obj/item/shard,
		/obj/item/light,
		/obj/item/broken_bottle,
		/obj/item/ammo_casing,
		/obj/item/cigbutt,
	)
	/// Materials that will be extracted.
	var/list/accepted_mats
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_obj_entered),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_atom_initialized_on),
	)
	var/datum/component/connect_loc_behalf/connector
	var/datum/component/material_container/container

/obj/item/mod/module/recycler/Initialize(mapload)
	. = ..()

	if(!length(accepted_mats))
		accepted_mats = SSmaterials.materials_by_category[MAT_CATEGORY_SILO]

	container = AddComponent( \
		/datum/component/material_container, \
		accepted_mats, \
		50 * SHEET_MATERIAL_AMOUNT, \
		MATCONTAINER_EXAMINE | MATCONTAINER_NO_INSERT, \
		container_signals = list( \
			COMSIG_MATCONTAINER_SHEETS_RETRIEVED = TYPE_PROC_REF(/obj/item/mod/module/recycler, InsertSheets) \
		) \
	)

/obj/item/mod/module/recycler/Destroy()
	container = null
	return ..()

/obj/item/mod/module/recycler/on_activation()
	. = ..()
	if(!.)
		return
	connector = AddComponent(/datum/component/connect_loc_behalf, mod.wearer, loc_connections)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_wearer_moved))

/obj/item/mod/module/recycler/on_deactivation(display_message, deleting = FALSE)
	. = ..()
	if(!.)
		return
	QDEL_NULL(connector)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_wearer_moved))

/obj/item/mod/module/recycler/proc/on_wearer_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	for(var/obj/item/item in mod.wearer.loc)
		if(!is_type_in_list(item, allowed_item_types))
			return
		insert_trash(item)

/obj/item/mod/module/recycler/proc/on_obj_entered(atom/new_loc, atom/movable/arrived, atom/old_loc)
	SIGNAL_HANDLER

	if(!is_type_in_list(arrived, allowed_item_types))
		return
	insert_trash(arrived)

/obj/item/mod/module/recycler/proc/on_atom_initialized_on(atom/loc, atom/new_atom)
	SIGNAL_HANDLER

	if(!is_type_in_list(new_atom, allowed_item_types))
		return
	//Give the new atom the time to fully initialize and maybe live if the wearer moves away.
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/mod/module/recycler, insert_trash_if_nearby), new_atom), 0.5 SECONDS)

/obj/item/mod/module/recycler/proc/insert_trash_if_nearby(atom/new_atom)
	if(new_atom && mod?.wearer && new_atom.loc == mod.wearer.loc)
		insert_trash(new_atom)

/obj/item/mod/module/recycler/proc/insert_trash(obj/item/item)
	var/retrieved = container.insert_item(item, multiplier = efficiency)
	if(retrieved == MATERIAL_INSERT_ITEM_NO_MATS) //even if it doesn't have any material to give, trash is trash.
		qdel(item)
	playsound(src, SFX_RUSTLE, 50, TRUE, -5)

/obj/item/mod/module/recycler/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!target?.atom_storage)
		target = get_turf(target)
		if(!isopenturf(target) || !mod.wearer.Adjacent(target))
			return FALSE
	dispense(target)

/obj/item/mod/module/recycler/proc/dispense(atom/target)
	if(container.retrieve_all(target))
		balloon_alert(mod.wearer, "material dispensed")
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, TRUE)
		return
	balloon_alert(mod.wearer, "not enough material")
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)

/obj/item/mod/module/recycler/proc/InsertSheets(obj/item/recycler, obj/item/stack/sheets, atom/context)
	SIGNAL_HANDLER

	attempt_insert_storage(sheets)

/obj/item/mod/module/recycler/proc/attempt_insert_storage(obj/item/to_drop)
	if(!isturf(to_drop.loc) && !to_drop.loc.atom_storage?.attempt_insert(to_drop, mod.wearer, override = TRUE))
		to_drop.forceMove(to_drop.loc.drop_location())

///A black market variant of the above that dispenses riot foam dart boxes
/obj/item/mod/module/recycler/donk
	name = "MOD riot foam dart recycler module"
	desc = "A mod module collects and repackages fired foam darts (and garbage) into half-sized boxes of riot foam darts. \
		Activate on a nearby turf or storage to unload stored ammo boxes."
	icon_state = "donk_recycler"
	overlay_state_inactive = "module_donk_recycler"
	overlay_state_active = "module_donk_recycler"
	efficiency = 0.7 // Stops getting as many riot foam darts as one consumes.
	accepted_mats = list(/datum/material/iron)
	///The type of ammo box that it dispenses
	var/ammobox_type = /obj/item/ammo_box/foambox/riot/mini
	///The cost of each dispensed ammo box
	var/required_amount = SHEET_MATERIAL_AMOUNT*12.5

/obj/item/mod/module/recycler/donk/dispense(atom/target)
	if(!container.use_amount_mat(required_amount, /datum/material/iron))
		balloon_alert(mod.wearer, "not enough material")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	var/obj/item/ammo_box/product = new ammobox_type(target)
	attempt_insert_storage(product)
	balloon_alert(mod.wearer, "ammo box dispensed.")
	playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, TRUE)

/obj/item/mod/module/shock_absorber
	name = "MOD shock absorption module"
	desc = "A module that makes the user resistant to the knockdown inflicted by Stun Batons."
	icon_state = "no_baton"
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/shock_absorber)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/shock_absorber/on_suit_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_BATON_RESISTANCE, REF(src))
	RegisterSignal(mod.wearer, COMSIG_MOB_BATONED, PROC_REF(mob_batoned))

/obj/item/mod/module/shock_absorber/on_suit_deactivation(deleting)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_BATON_RESISTANCE, REF(src))
	UnregisterSignal(mod.wearer, COMSIG_MOB_BATONED)

/obj/item/mod/module/shock_absorber/proc/mob_batoned(datum/source)
	SIGNAL_HANDLER
	drain_power(use_energy_cost)
	var/datum/effect_system/lightning_spread/sparks = new /datum/effect_system/lightning_spread
	sparks.set_up(number = 5, cardinals_only = TRUE, location = mod.wearer.loc)
	sparks.start()
