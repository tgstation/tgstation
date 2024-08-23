/obj/item/mod/core
	name = "MOD core"
	desc = "A non-functional MOD core. Inform the admins if you see this."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "mod-core"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	/// MOD unit we are powering.
	var/obj/item/mod/control/mod

/obj/item/mod/core/Destroy()
	if(mod)
		uninstall()
	return ..()

/obj/item/mod/core/proc/install(obj/item/mod/control/mod_unit)
	mod = mod_unit
	mod.core = src
	forceMove(mod)
	mod.update_charge_alert()

/obj/item/mod/core/proc/uninstall()
	mod.core = null
	mod.update_charge_alert()
	mod = null

/obj/item/mod/core/proc/charge_source()
	return

/obj/item/mod/core/proc/charge_amount()
	return 0

/obj/item/mod/core/proc/max_charge_amount()
	return 1

/obj/item/mod/core/proc/add_charge(amount)
	return FALSE

/obj/item/mod/core/proc/subtract_charge(amount)
	return FALSE

/obj/item/mod/core/proc/check_charge(amount)
	return FALSE

/**
 * Gets what icon state to display on the HUD for the charge level of this core
 */
/obj/item/mod/core/proc/get_charge_icon_state()
	return "0"

/obj/item/mod/core/infinite
	name = "MOD infinite core"
	icon_state = "mod-core-infinite"
	desc = "A fusion core using the rare Fixium to sustain enough energy for the lifetime of the MOD's user. \
		This might be because of the slowly killing poison inside, but those are just rumors."

/obj/item/mod/core/infinite/charge_source()
	return src

/obj/item/mod/core/infinite/charge_amount()
	return INFINITY

/obj/item/mod/core/infinite/max_charge_amount()
	return INFINITY

/obj/item/mod/core/infinite/add_charge(amount)
	return TRUE

/obj/item/mod/core/infinite/subtract_charge(amount)
	return amount

/obj/item/mod/core/infinite/check_charge(amount)
	return TRUE

/obj/item/mod/core/infinite/get_charge_icon_state()
	return "high"

/obj/item/mod/core/standard
	name = "MOD standard core"
	icon_state = "mod-core-standard"
	desc = "Growing in the most lush, fertile areas of the planet Sprout, there is a crystal known as the Heartbloom. \
		These rare, organic piezoelectric crystals are of incredible cultural significance to the artist castes of the \
		Ethereals, owing to their appearance; which is exactly similar to that of an Ethereal's heart.\n\
		Which one you have in your suit is unclear, but either way, \
		it's been repurposed to be an internal power source for a Modular Outerwear Device."
	/// Installed cell.
	var/obj/item/stock_parts/power_store/cell

/obj/item/mod/core/standard/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/mod/core/standard/install(obj/item/mod/control/mod_unit)
	. = ..()
	if(cell)
		install_cell(cell)
	RegisterSignal(mod, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(mod, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(mod, COMSIG_ATOM_STORAGE_ITEM_INTERACT_INSERT, PROC_REF(on_mod_storage_insert))
	RegisterSignal(mod, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_mod_interaction))
	RegisterSignal(mod, COMSIG_MOD_WEARER_SET, PROC_REF(on_wearer_set))
	if(mod.wearer)
		on_wearer_set(mod, mod.wearer)

/obj/item/mod/core/standard/uninstall()
	if(!QDELETED(cell))
		cell.forceMove(drop_location())
	UnregisterSignal(mod, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_STORAGE_ITEM_INTERACT_INSERT,
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_MOD_WEARER_SET,
	))
	if(mod.wearer)
		on_wearer_unset(mod, mod.wearer)
	return ..()

/obj/item/mod/core/standard/charge_source()
	return cell

/obj/item/mod/core/standard/charge_amount()
	var/obj/item/stock_parts/power_store/charge_source = charge_source()
	return charge_source?.charge || 0

/obj/item/mod/core/standard/max_charge_amount(amount)
	var/obj/item/stock_parts/power_store/charge_source = charge_source()
	return charge_source?.maxcharge || 1

/obj/item/mod/core/standard/add_charge(amount)
	var/obj/item/stock_parts/power_store/charge_source = charge_source()
	if(isnull(charge_source))
		return FALSE
	. = charge_source.give(amount)
	if(.)
		mod.update_charge_alert()
	return .

/obj/item/mod/core/standard/subtract_charge(amount)
	var/obj/item/stock_parts/power_store/charge_source = charge_source()
	if(isnull(charge_source))
		return FALSE
	. = charge_source.use(amount, TRUE)
	if(.)
		mod.update_charge_alert()
	return .

/obj/item/mod/core/standard/check_charge(amount)
	return charge_amount() >= amount

/obj/item/mod/core/standard/get_charge_icon_state()
	if(isnull(charge_source()))
		return "missing"

	switch(round(charge_amount() / max_charge_amount(), 0.01))
		if(0.75 to INFINITY)
			return "high"
		if(0.5 to 0.75)
			return "mid"
		if(0.25 to 0.5)
			return "low"
		if(0.02 to 0.25)
			return "very_low"

	return "empty"

/obj/item/mod/core/standard/proc/install_cell(new_cell)
	cell = new_cell
	cell.forceMove(src)
	mod.update_charge_alert()

/obj/item/mod/core/standard/proc/uninstall_cell()
	if(!cell)
		return
	cell = null
	mod.update_charge_alert()

/obj/item/mod/core/standard/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		uninstall_cell()

/obj/item/mod/core/standard/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(!mod.open)
		return
	examine_text += cell ? "You could remove the cell with an empty hand." : "You could use a cell on it to install one."

/obj/item/mod/core/standard/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if(mod.seconds_electrified && charge_amount() && mod.shock(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(mod.open && mod.loc == user)
		INVOKE_ASYNC(src, PROC_REF(mod_uninstall_cell), user)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/obj/item/mod/core/standard/proc/mod_uninstall_cell(mob/living/user)
	if(!cell)
		mod.balloon_alert(user, "no cell!")
		return
	mod.balloon_alert(user, "removing cell...")
	if(!do_after(user, 1.5 SECONDS, target = mod))
		mod.balloon_alert(user, "interrupted!")
		return
	mod.balloon_alert(user, "cell removed")
	playsound(mod, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	var/obj/item/cell_to_move = cell
	cell_to_move.forceMove(drop_location())
	user.put_in_hands(cell_to_move)

/obj/item/mod/core/standard/proc/on_mod_storage_insert(datum/source, obj/item/thing, mob/living/user)
	SIGNAL_HANDLER

	return replace_cell(thing, user) ? BLOCK_STORAGE_INSERT : NONE

/obj/item/mod/core/standard/proc/on_mod_interaction(datum/source, mob/living/user, obj/item/thing)
	SIGNAL_HANDLER

	if(mod.atom_storage) // handled by the storage signal
		return NONE

	return item_interaction(user, thing)

/obj/item/mod/core/standard/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return replace_cell(tool, user) ? ITEM_INTERACT_SUCCESS : NONE

/obj/item/mod/core/standard/proc/replace_cell(obj/item/attacking_item, mob/user)
	if(!istype(attacking_item, /obj/item/stock_parts/power_store/cell))
		return FALSE
	if(!mod.open)
		mod.balloon_alert(user, "open the cover first!")
		playsound(mod, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(cell)
		mod.balloon_alert(user, "cell already installed!")
		playsound(mod, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	install_cell(attacking_item)
	mod.balloon_alert(user, "cell installed")
	playsound(mod, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	return TRUE

/obj/item/mod/core/standard/proc/on_wearer_set(datum/source, mob/user)
	SIGNAL_HANDLER

	RegisterSignal(mod.wearer, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	RegisterSignal(mod, COMSIG_MOD_WEARER_UNSET, PROC_REF(on_wearer_unset))

/obj/item/mod/core/standard/proc/on_wearer_unset(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(mod.wearer, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(mod, COMSIG_MOD_WEARER_UNSET)

/obj/item/mod/core/standard/proc/on_borg_charge(datum/source, datum/callback/charge_cell, seconds_per_tick)
	SIGNAL_HANDLER

	var/obj/item/stock_parts/power_store/target_cell = charge_source()
	if(isnull(target_cell))
		return

	if(charge_cell.Invoke(target_cell, seconds_per_tick))
		mod.update_charge_alert()

/obj/item/mod/core/ethereal
	name = "MOD ethereal core"
	icon_state = "mod-core-ethereal"
	desc = "A reverse engineered core of a Modular Outerwear Device. Using natural liquid electricity from Ethereals, \
		preventing the need to use external sources to convert electric charge."
	/// A modifier to all charge we use, ethereals don't need to spend as much energy as normal suits.
	var/charge_modifier = 0.1

/obj/item/mod/core/ethereal/charge_source()
	var/obj/item/organ/internal/stomach/ethereal/ethereal_stomach = mod.wearer.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!istype(ethereal_stomach))
		return
	return ethereal_stomach

/obj/item/mod/core/ethereal/charge_amount()
	var/obj/item/organ/internal/stomach/ethereal/charge_source = charge_source()
	return charge_source?.cell.charge() || ETHEREAL_CHARGE_NONE

/obj/item/mod/core/ethereal/max_charge_amount()
	return ETHEREAL_CHARGE_FULL

/obj/item/mod/core/ethereal/add_charge(amount)
	var/obj/item/organ/internal/stomach/ethereal/charge_source = charge_source()
	if(!charge_source)
		return FALSE
	charge_source.adjust_charge(amount*charge_modifier)
	return TRUE

/obj/item/mod/core/ethereal/subtract_charge(amount)
	var/obj/item/organ/internal/stomach/ethereal/charge_source = charge_source()
	if(!charge_source)
		return FALSE
	return -charge_source.adjust_charge(-amount*charge_modifier)

/obj/item/mod/core/ethereal/check_charge(amount)
	return charge_amount() >= amount*charge_modifier

/obj/item/mod/core/ethereal/get_charge_icon_state()
	return charge_source() ? "0" : "missing"

#define PLASMA_CORE_ORE_CHARGE (1.5 * STANDARD_CELL_CHARGE)
#define PLASMA_CORE_SHEET_CHARGE (2 * STANDARD_CELL_CHARGE)

/obj/item/mod/core/plasma
	name = "MOD plasma core"
	icon_state = "mod-core-plasma"
	desc = "Nanotrasen's attempt at capitalizing on their plasma research. These plasma cores are refueled \
		through plasma fuel, allowing for easy continued use by their mining squads."
	/// How much charge we can store.
	var/maxcharge = 10 * STANDARD_CELL_CHARGE
	/// How much charge we are currently storing.
	var/charge = 10 * STANDARD_CELL_CHARGE
	/// Associated list of charge sources and how much they charge, only stacks allowed.
	var/list/charger_list = list(/obj/item/stack/ore/plasma = PLASMA_CORE_ORE_CHARGE, /obj/item/stack/sheet/mineral/plasma = PLASMA_CORE_SHEET_CHARGE)

/obj/item/mod/core/plasma/install(obj/item/mod/control/mod_unit)
	. = ..()
	RegisterSignal(mod, COMSIG_ATOM_STORAGE_ITEM_INTERACT_INSERT, PROC_REF(on_mod_storage_insert))
	RegisterSignal(mod, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_mod_interaction))

/obj/item/mod/core/plasma/uninstall()
	UnregisterSignal(mod, list(COMSIG_ATOM_STORAGE_ITEM_INTERACT_INSERT, COMSIG_ATOM_ITEM_INTERACTION))
	return ..()

/obj/item/mod/core/plasma/charge_source()
	return src

/obj/item/mod/core/plasma/charge_amount()
	return charge

/obj/item/mod/core/plasma/max_charge_amount()
	return maxcharge

/obj/item/mod/core/plasma/add_charge(amount)
	charge = min(maxcharge, charge + amount)
	mod.update_charge_alert()
	return TRUE

/obj/item/mod/core/plasma/subtract_charge(amount)
	amount = min(amount, charge)
	charge -= amount
	mod.update_charge_alert()
	return amount

/obj/item/mod/core/plasma/check_charge(amount)
	return charge_amount() >= amount

/obj/item/mod/core/plasma/get_charge_icon_state()
	switch(round(charge_amount() / max_charge_amount(), 0.01))
		if(0.75 to INFINITY)
			return "high"
		if(0.5 to 0.75)
			return "mid"
		if(0.25 to 0.5)
			return "low"
		if(0.02 to 0.25)
			return "very_low"

	return "empty"

/obj/item/mod/core/plasma/proc/on_mod_storage_insert(datum/source, obj/item/thing, mob/living/user)
	SIGNAL_HANDLER

	return charge_plasma(thing, user) ? BLOCK_STORAGE_INSERT : NONE

/obj/item/mod/core/plasma/proc/on_mod_interaction(datum/source, mob/living/user, obj/item/thing)
	SIGNAL_HANDLER

	if(mod.atom_storage) // handled by the storage signal
		return NONE

	return item_interaction(thing, user)

/obj/item/mod/core/plasma/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	return charge_plasma(tool, user) ? ITEM_INTERACT_SUCCESS : NONE

/obj/item/mod/core/plasma/proc/charge_plasma(obj/item/stack/plasma, mob/user)
	var/charge_given = is_type_in_list(plasma, charger_list, zebra = TRUE)
	if(!charge_given)
		return FALSE
	var/uses_needed = min(plasma.amount, ROUND_UP((max_charge_amount() - charge_amount()) / charge_given))
	if(uses_needed <= 0 || !plasma.use(uses_needed))
		return FALSE
	add_charge(uses_needed * charge_given)
	balloon_alert(user, "core refueled")
	return TRUE

#undef PLASMA_CORE_ORE_CHARGE
#undef PLASMA_CORE_SHEET_CHARGE

/obj/item/mod/core/plasma/lavaland
	name = "MOD plasma flower core"
	icon_state = "mod-core-plasma-flower"
	desc = "A strange flower from the desolate wastes of lavaland. It pulses with a strange purple glow.  \
		The wires coming out of it could be hooked into a MODsuit."
	light_system = OVERLAY_LIGHT
	light_color = "#cc00cc"
	light_range = 2.5
	light_power = 1.5
	// Slightly better than the normal plasma core.
	// Not super sure if this should just be the same, but will see.
	maxcharge = 15 * STANDARD_CELL_CHARGE
	charge = 15 * STANDARD_CELL_CHARGE
	/// The mob to be spawned by the core
	var/mob/living/spawned_mob_type = /mob/living/basic/butterfly/lavaland/temporary
	/// Max number of mobs it can spawn
	var/max_spawns = 3
	/// Mob spawner for the core
	var/datum/component/spawner/mob_spawner
	/// Particle holder for pollen particles
	var/obj/effect/abstract/particle_holder/particle_effect

/obj/item/mod/core/plasma/lavaland/Destroy()
	QDEL_NULL(particle_effect)
	return ..()

/obj/item/mod/core/plasma/lavaland/install(obj/item/mod/control/mod_unit)
	. = ..()
	RegisterSignal(mod_unit, COMSIG_MOD_TOGGLED, PROC_REF(on_toggle))

/obj/item/mod/core/plasma/lavaland/uninstall(obj/item/mod/control/mod_unit)
	. = ..()
	UnregisterSignal(mod_unit, COMSIG_MOD_TOGGLED)

/obj/item/mod/core/plasma/lavaland/proc/on_toggle()
	SIGNAL_HANDLER
	if(mod.active)
		particle_effect = new(mod.wearer, /particles/pollen, PARTICLE_ATTACH_MOB)
		mob_spawner = mod.wearer.AddComponent(/datum/component/spawner, spawn_types=list(spawned_mob_type), spawn_time=5 SECONDS, max_spawned=3, faction=mod.wearer.faction)
		RegisterSignal(mob_spawner, COMSIG_SPAWNER_SPAWNED, PROC_REF(new_mob))
		RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(spread_flowers))

	else
		QDEL_NULL(particle_effect)
		UnregisterSignal(mob_spawner, COMSIG_SPAWNER_SPAWNED)
		UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
		for(var/datum/mob in mob_spawner.spawned_things)
			qdel(mob)
		qdel(mob_spawner)

/obj/item/mod/core/plasma/lavaland/proc/new_mob(spawner, mob/living/basic/butterfly/lavaland/temporary/spawned)
	SIGNAL_HANDLER
	if(spawned)
		spawned.source = src

/obj/item/mod/core/plasma/lavaland/proc/spread_flowers(atom/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER
	var/static/list/possible_flower_types = list(
		/obj/structure/flora/bush/lavendergrass/style_random,
		/obj/structure/flora/bush/flowers_yw/style_random,
		/obj/structure/flora/bush/flowers_br/style_random,
		/obj/structure/flora/bush/flowers_pp/style_random,
	)
	var/chosen_type = pick(possible_flower_types)
	var/flower_boots = new chosen_type(get_turf(mod.wearer))
	animate(flower_boots, alpha = 0, 1 SECONDS)
	QDEL_IN(flower_boots, 1 SECONDS)
