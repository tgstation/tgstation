#define SAFETY_COOLDOWN 100

/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine used to recycle small items inefficiently. There are lights on the side."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "grinder-o0"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	plane = ABOVE_GAME_PLANE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/recycler
	var/safety_mode = FALSE // Temporarily stops machine if it detects a mob
	var/icon_name = "grinder-o"
	var/bloody = FALSE
	var/amount_produced = 50
	var/crush_damage = 1000
	var/eat_victim_items = TRUE
	var/item_recycle_sound = 'sound/items/tools/welder.ogg'
	var/datum/component/material_container/materials

/obj/machinery/recycler/Initialize(mapload)
	materials = AddComponent(
		/datum/component/material_container, \
		SSmaterials.materials_by_category[MAT_CATEGORY_SILO], \
		INFINITY, \
		MATCONTAINER_NO_INSERT \
	)
	AddComponent(/datum/component/simple_rotation)
	AddComponent(
		/datum/component/butchering/recycler, \
		speed = 0.1 SECONDS, \
		effectiveness = amount_produced, \
		bonus_modifier = amount_produced / 5, \
	)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/recycler/post_machine_initialize()
	. = ..()
	update_appearance(UPDATE_ICON)
	req_one_access = SSid_access.get_region_access_list(list(REGION_ALL_STATION, REGION_CENTCOM))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/recycler/Destroy()
	materials = null
	return ..()

/obj/machinery/recycler/RefreshParts()
	. = ..()
	var/amt_made = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		amt_made = 12.5 * servo.tier //% of materials salvaged
	amount_produced = min(50, amt_made) + 50
	var/datum/component/butchering/butchering = GetComponent(/datum/component/butchering/recycler)
	butchering.effectiveness = amount_produced
	butchering.bonus_modifier = amount_produced/5

/obj/machinery/recycler/examine(mob/user)
	. = ..()
	. += span_notice("Reclaiming <b>[amount_produced]%</b> of materials salvaged.")
	. += {"The power light is [(machine_stat & NOPOWER) ? "off" : "on"].
	The safety-mode light is [safety_mode ? "on" : "off"].
	The safety-sensors status light is [obj_flags & EMAGGED ? "off" : "on"]."}

/obj/machinery/recycler/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/recycler/can_be_unfasten_wrench(mob/user, silent)
	if(!(isfloorturf(loc) || isindestructiblefloor(loc)) && !anchored)
		to_chat(user, span_warning("[src] needs to be on the floor to be secured!"))
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/machinery/recycler/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/recycler/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/recycler/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	if(safety_mode)
		safety_mode = FALSE
		update_appearance()
	playsound(src, SFX_SPARKS, 75, TRUE, SILENCED_SOUND_EXTRARANGE)
	balloon_alert(user, "safeties disabled")
	return FALSE

/obj/machinery/recycler/update_icon_state()
	var/is_powered = !(machine_stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = FALSE
	icon_state = icon_name + "[is_powered]"
	return ..()

/obj/machinery/recycler/update_overlays()
	. = ..()
	if(!bloody || !GET_ATOM_BLOOD_DECAL_LENGTH(src))
		return

	var/mutable_appearance/blood_overlay = mutable_appearance(icon, "[icon_state]bld", appearance_flags = RESET_COLOR|KEEP_APART)
	blood_overlay.color = get_blood_dna_color()
	. += blood_overlay

/obj/machinery/recycler/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	if(border_dir == dir)
		return TRUE

/obj/machinery/recycler/proc/on_entered(datum/source, atom/movable/enterer, old_loc)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(eat), enterer)

/obj/machinery/recycler/proc/eat(atom/movable/morsel, sound=TRUE)
	if(machine_stat & (BROKEN|NOPOWER) || safety_mode)
		return
	if(!isturf(morsel.loc))
		stack_trace("on_entered() called with invalid location: [morsel.loc]") // I don't know how you called Entered() but stop it.
		return
	if(morsel.resistance_flags & INDESTRUCTIBLE)
		return

	/// Queue of objects to process.
	var/list/atom/to_eat = list(morsel)
	/// Regular items to be recycled.
	var/list/nom = list()
	/// Living mobs to be crushed.
	var/list/crunchy_nom = list() // Mobs have to be handled differently so they get a different list instead of checking them multiple times.
	/// Count of items that couldn't be processed.
	var/not_eaten = 0

	while(LAZYLEN(to_eat))
		var/atom/movable/thing = popleft(to_eat)

		if(triggers_safety_shutdown(thing))
			emergency_stop()
			return

		if(thing.resistance_flags & INDESTRUCTIBLE)
			if(!isturf(thing.loc) && !recursive_loc_check(thing, /mob/living))
				thing.forceMove(loc)
			not_eaten++
			continue

		if(thing.flags_1 & HOLOGRAM_1)
			for(var/atom/movable/hologram_content as anything in thing.contents)
				hologram_content.forceMove(loc) // we shouldn't qdel() the non-holographic content of the hologram.
			visible_message(span_notice("[thing] fades away!"))
			qdel(thing)
			continue

		if(isliving(thing))
			LAZYADD(crunchy_nom, thing)
			if(!issilicon(thing))
				LAZYOR(to_eat, thing.contents)
			continue

		if(!isobj(thing))
			not_eaten++
			continue

		if(isitem(thing))
			var/obj/item/item_thing = thing
			if(item_thing.item_flags & ABSTRACT)
				not_eaten++
				continue

		if(iscloset(thing))
			var/obj/structure/closet/closet_thing = thing
			if(closet_thing.secure && closet_thing.locked) // Prevent blindly deconstructing locked secure closets (head closets, important departmental orders, etc.)
				not_eaten++                                // unless they have already been unlocked to prevent exploiting the recycler to bypass closet access.
				continue

		LAZYADD(nom, thing)
		LAZYOR(to_eat, thing.contents)

	for(var/mob/living/living_mob in crunchy_nom)
		if(!is_operational) //we ran out of power after recycling a large amount to living stuff, time to stop
			break
		if(living_mob.incorporeal_move)
			continue

		crush_living(living_mob)
		use_energy(active_power_usage)

	var/nom_length = LAZYLEN(nom)

	/**
	 * we process the list in reverse so that atoms without parents/contents are deleted first & their parents are deleted next & so on.
	 * this is the reverse order in which get_all_contents() returns its list
	 * if we delete an atom containing stuff then all its stuff are deleted with it as well so we will end recycling deleted items down the list and gain nothing from them
	 */
	for(var/i = nom_length; i >= 1; i--)
		if(!is_operational) //we ran out of power after recycling a large amount to items, time to stop
			break

		var/full_power_usage = TRUE
		var/obj/nom_obj = nom[i]

		if(isitem(nom_obj))
			// Whether or not items consume full power depends on if they produced a material when recycled.
			full_power_usage = recycle_item(nom_obj)
		else
			// When a non-item is eaten, we deconstruct it with dismantled = FALSE so that
			// it and its contents aren't just deleted. These always consume full power.
			nom_obj.deconstruct(FALSE)

		use_energy(active_power_usage / (full_power_usage ? 1 : 2))

	if(nom_length && sound)
		var/sound_volume = clamp(nom_length * 5, 50, 100)
		var/walls_ignoring = max(nom_length - 10, 0)
		playsound(src, item_recycle_sound, sound_volume, TRUE, nom_length, ignore_walls = walls_ignoring) // As a substitute for playing 50 sounds at once.

	if(not_eaten)
		var/sound_volume = clamp(not_eaten * 5, 50, 100)
		var/walls_ignoring = max(not_eaten - 10, 0)
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', sound_volume, FALSE, not_eaten, ignore_walls = walls_ignoring) // Ditto.

/// Determines if the target should trigger an emergency stop due to safety concerns.
/obj/machinery/recycler/proc/triggers_safety_shutdown(atom/movable/target)
	if(obj_flags & EMAGGED)
		return FALSE // Emagged recycler ignores all safety checks.

	if(isliving(target))
		return TRUE

	if(isbrain(target) || istype(target, /obj/item/dullahan_relay))
		return TRUE

	if(istype(target, /obj/item/mmi))
		var/obj/item/mmi/mmi_thing = target
		return !!(mmi_thing.brain)

	return FALSE

/obj/machinery/recycler/proc/recycle_item(obj/item/target)
	if(istype(target, /obj/item/grown/log))
		var/obj/item/grown/log/wood = target
		var/seed_modifier = wood.seed ? round(wood.seed.potency / 25) : 0
		new wood.plank_type(loc, 1 + seed_modifier)
		qdel(target)
		return TRUE

	var/retrieved = materials.insert_item(target, multiplier = (amount_produced / 100))
	if(retrieved > 0) //item was salvaged i.e. deleted
		materials.retrieve_all()
		qdel(target)
		return TRUE

	qdel(target)
	return FALSE

/obj/machinery/recycler/proc/emergency_stop()
	playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, FALSE)
	safety_mode = TRUE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(reboot)), SAFETY_COOLDOWN)

/obj/machinery/recycler/proc/reboot()
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
	safety_mode = FALSE
	update_appearance()

/obj/machinery/recycler/proc/crush_living(mob/living/living_mob)
	if(issilicon(living_mob))
		playsound(src, 'sound/items/tools/welder.ogg', 50, TRUE)
	else
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	if(iscarbon(living_mob) && living_mob.stat == CONSCIOUS)
		living_mob.say("ARRRRRRRRRRRGH!!!", forced= "recycler grinding")

	if(!issilicon(living_mob))
		add_mob_blood(living_mob)
		bloody = TRUE

	// Instantly lie down, also go unconscious from the pain, before you die.
	living_mob.Unconscious(100)
	living_mob.adjust_brute_loss(crush_damage)
	update_appearance()

/obj/machinery/recycler/on_deconstruction(disassembled)
	safety_mode = TRUE

/obj/machinery/recycler/deathtrap
	name = "dangerous old crusher"
	obj_flags = CAN_BE_HIT | EMAGGED
	crush_damage = 120

/obj/machinery/recycler/deathtrap/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/recycler/deathtrap/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/item/paper/guides/recycler
	name = "paper - 'garbage duty instructions'"
	default_raw_text = "<h2>New Assignment</h2> You have been assigned to collect garbage from trash bins, located around the station. The crewmembers will put their trash into it and you will collect said trash.<br><br>There is a recycling machine near your closet, inside maintenance; use it to recycle the trash for a small chance to get useful minerals. Then, deliver these minerals to cargo or engineering. You are our last hope for a clean station. Do not screw this up!"

#undef SAFETY_COOLDOWN
