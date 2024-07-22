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
	var/item_recycle_sound = 'sound/items/welder.ogg'
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
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/recycler/can_be_unfasten_wrench(mob/user, silent)
	if(!(isfloorturf(loc) || isindestructiblefloor(loc)) && !anchored)
		to_chat(user, span_warning("[src] needs to be on the floor to be secured!"))
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/machinery/recycler/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return

	if(default_pry_open(I, close_after_pry = TRUE))
		return

	if(default_deconstruction_crowbar(I))
		return
	return ..()

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
	icon_state = icon_name + "[is_powered]" + "[(bloody ? "bld" : "")]" // add the blood tag at the end
	return ..()

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
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(safety_mode)
		return
	if(iseffect(morsel))
		return
	if(!isturf(morsel.loc))
		return //I don't know how you called Crossed() but stop it.
	if(morsel.resistance_flags & INDESTRUCTIBLE)
		return
	if(morsel.flags_1 & HOLOGRAM_1)
		visible_message(span_notice("[morsel] fades away!"))
		qdel(morsel)
		return

	var/list/to_eat = (issilicon(morsel) ? list(morsel) : morsel.get_all_contents()) //eating borg contents leads to many bad things

	var/living_detected = FALSE //technically includes silicons as well but eh
	var/list/nom = list()
	var/list/crunchy_nom = list() //Mobs have to be handled differently so they get a different list instead of checking them multiple times.

	for(var/thing in to_eat)
		var/obj/as_object = thing
		if(istype(as_object))
			if(as_object.resistance_flags & INDESTRUCTIBLE)
				if(!isturf(as_object.loc) && !isliving(as_object.loc))
					as_object.forceMove(loc) // so you still cant shove it in a locker
				continue
			var/obj/item/bodypart/head/as_head = thing
			var/obj/item/mmi/as_mmi = thing
			if(istype(thing, /obj/item/organ/internal/brain) || (istype(as_head) && locate(/obj/item/organ/internal/brain) in as_head) || (istype(as_mmi) && as_mmi.brain) || istype(thing, /obj/item/dullahan_relay))
				living_detected = TRUE
			if(isitem(as_object))
				var/obj/item/as_item = as_object
				if(as_item.item_flags & ABSTRACT) //also catches organs and bodyparts *stares*
					continue
			nom += thing
		else if(isliving(thing))
			living_detected = TRUE
			crunchy_nom += thing

	var/not_eaten = to_eat.len - nom.len - crunchy_nom.len
	if(living_detected) // First, check if we have any living beings detected.
		if(obj_flags & EMAGGED)
			for(var/CRUNCH in crunchy_nom) // Eat them and keep going because we don't care about safety.
				if(isliving(CRUNCH)) // MMIs and brains will get eaten like normal items
					if(!is_operational) //we ran out of power after recycling a large amount to living stuff, time to stop
						break
					crush_living(CRUNCH)
					use_energy(active_power_usage)
		else // Stop processing right now without eating anything.
			emergency_stop()
			return

	/**
	 * we process the list in reverse so that atoms without parents/contents are deleted first & their parents are deleted next & so on.
	 * this is the reverse order in which get_all_contents() returns its list
	 * if we delete an atom containing stuff then all its stuff are deleted with it as well so we will end recycling deleted items down the list and gain nothing from them
	 */
	for(var/i = length(nom); i >= 1; i--)
		if(!is_operational) //we ran out of power after recycling a large amount to items, time to stop
			break
		use_energy(active_power_usage / (recycle_item(nom[i]) ? 1 : 2)) //recycling stuff that produces no material takes just half the power
	if(nom.len && sound)
		playsound(src, item_recycle_sound, (50 + nom.len * 5), TRUE, nom.len, ignore_walls = (nom.len - 10)) // As a substitute for playing 50 sounds at once.
	if(not_eaten)
		playsound(src, 'sound/machines/buzz-sigh.ogg', (50 + not_eaten * 5), FALSE, not_eaten, ignore_walls = (not_eaten - 10)) // Ditto.

/obj/machinery/recycler/proc/recycle_item(obj/item/weapon)
	. = FALSE
	var/obj/item/grown/log/wood = weapon
	if(istype(wood))
		var/seed_modifier = 0
		if(wood.seed)
			seed_modifier = round(wood.seed.potency / 25)
		new wood.plank_type(loc, 1 + seed_modifier)
		. = TRUE
	else
		var/retrieved = materials.insert_item(weapon, multiplier = (amount_produced / 100))
		if(retrieved > 0) //item was salvaged i.e. deleted
			materials.retrieve_all()
			return TRUE
	qdel(weapon)

/obj/machinery/recycler/proc/emergency_stop()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
	safety_mode = TRUE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(reboot)), SAFETY_COOLDOWN)

/obj/machinery/recycler/proc/reboot()
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
	safety_mode = FALSE
	update_appearance()

/obj/machinery/recycler/proc/crush_living(mob/living/L)
	L.forceMove(loc)

	if(issilicon(L))
		playsound(src, 'sound/items/welder.ogg', 50, TRUE)
	else
		playsound(src, 'sound/effects/splat.ogg', 50, TRUE)

	if(iscarbon(L))
		if(L.stat == CONSCIOUS)
			L.say("ARRRRRRRRRRRGH!!!", forced="recycler grinding")
		add_mob_blood(L)

	if(!bloody && !issilicon(L))
		bloody = TRUE
		update_appearance()

	// Instantly lie down, also go unconscious from the pain, before you die.
	L.Unconscious(100)
	L.adjustBruteLoss(crush_damage)

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
