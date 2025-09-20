#define PKBORG_DAMPEN_CYCLE_DELAY (2 SECONDS)
#define POWER_RECHARGE_CYBORG_DRAIN_MULTIPLIER (0.0004 * STANDARD_CELL_RATE)

/obj/item/cautery/prt //it's a subtype of cauteries so that it inherits the cautery sprites and behavior and stuff, because I'm too lazy to make sprites for this thing
	name = "plating repair tool"
	desc = "A tiny heating device that's powered by a cyborg's excess heat. Its intended purpose is to repair burnt or damaged hull platings, but it can also be used as a crude lighter or cautery."
	toolspeed = 1.5 //it's not designed to be used as a cautery (although it's close enough to one to be considered to be a proper cautery instead of just a hot object for the purposes of surgery)
	heat = 3800 //this thing is intended for metal-shaping, so it's the same temperature as a lit welder
	resistance_flags = FIRE_PROOF //if it's channeling a cyborg's excess heat, it's probably fireproof
	force = 5
	damtype = BURN
	usesound = list('sound/items/tools/welder.ogg', 'sound/items/tools/welder2.ogg') //the usesounds of a lit welder
	hitsound = 'sound/items/tools/welder.ogg' //the hitsound of a lit welder

//Peacekeeper Cyborg Projectile Dampenening Field
/obj/item/borg/projectile_dampen
	name = "\improper Hyperkinetic Dampening projector"
	desc = "A device that projects a dampening field that weakens kinetic energy above a certain threshold. <span class='boldnotice'>Projects a field that drains power per second while active, that will weaken and slow damaging projectiles inside its field.</span> Still being a prototype, it tends to induce a charge on ungrounded metallic surfaces."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "shield0"
	base_icon_state = "shield"
	/// Max energy this dampener can hold
	var/maxenergy = 1500
	/// Current energy level
	var/energy = 1500
	/// Recharging rate in energy per second
	var/energy_recharge = 37.5
	/// Critical power level percentage
	var/cyborg_cell_critical_percentage = 0.05
	/// The owner of the dampener
	var/mob/living/silicon/robot/host = null
	/// The field
	var/datum/proximity_monitor/advanced/bubble/projectile_dampener/peaceborg/dampening_field
	/// Energy cost per tracked projectile damage amount per second
	var/projectile_damage_tick_ecost_coefficient = 10
	/// Energy cost per tracked projectile per second
	var/projectile_tick_speed_ecost = 75
	/// Projectiles dampened by our dampener
	var/list/tracked_bullet_cost = list()
	/// the radius of our field
	var/field_radius = 3
	var/active = FALSE
	/// activation cooldown
	COOLDOWN_DECLARE(cycle_cooldown)

/obj/item/borg/projectile_dampen/debug
	maxenergy = 50000
	energy = 50000
	energy_recharge = 5000

/obj/item/borg/projectile_dampen/Initialize(mapload)
	START_PROCESSING(SSfastprocess, src)
	host = loc
	RegisterSignal(host, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	return ..()

/obj/item/borg/projectile_dampen/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	deactivate_field()

/obj/item/borg/projectile_dampen/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/borg/projectile_dampen/attack_self(mob/user)
	if (!COOLDOWN_FINISHED(src, cycle_cooldown))
		to_chat(user, span_boldwarning("[src] is still recycling its projectors!"))
		return
	COOLDOWN_START(src, cycle_cooldown, PKBORG_DAMPEN_CYCLE_DELAY)
	if(!active)
		if(!user.has_buckled_mobs())
			activate_field()
		else
			to_chat(user, span_warning("[src]'s safety cutoff prevents you from activating it due to living beings being ontop of you!"))
	else
		deactivate_field()
	update_appearance()
	to_chat(user, span_boldnotice("You [active ? "activate":"deactivate"] [src]."))

/obj/item/borg/projectile_dampen/update_icon_state()
	icon_state = "[base_icon_state][active]"
	return ..()

/obj/item/borg/projectile_dampen/proc/activate_field()
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	var/mob/living/silicon/robot/owner = get_host()
	dampening_field = new(owner, field_radius, TRUE, src, /datum/dampener_projectile_effects/peacekeeper)
	RegisterSignal(dampening_field, COMSIG_DAMPENER_CAPTURE, PROC_REF(dampen_projectile))
	RegisterSignal(dampening_field, COMSIG_DAMPENER_RELEASE, PROC_REF(restore_projectile))
	owner?.model.allow_riding = FALSE
	active = TRUE

/obj/item/borg/projectile_dampen/proc/deactivate_field()
	QDEL_NULL(dampening_field)
	visible_message(span_warning("\The [src] shuts off!"))
	tracked_bullet_cost.Cut()
	active = FALSE

	var/mob/living/silicon/robot/owner = get_host()
	if(owner)
		owner.model.allow_riding = TRUE

/obj/item/borg/projectile_dampen/proc/get_host()
	if(istype(host))
		return host
	else
		if(iscyborg(host.loc))
			return host.loc
	return null

/obj/item/borg/projectile_dampen/equipped()
	host = loc
	return ..()

/obj/item/borg/projectile_dampen/dropped()
	host = loc
	return ..()

/obj/item/borg/projectile_dampen/cyborg_unequip(mob/user)
	deactivate_field()
	return ..()

/obj/item/borg/projectile_dampen/process(seconds_per_tick)
	process_recharge(seconds_per_tick)
	process_usage(seconds_per_tick)

/obj/item/borg/projectile_dampen/proc/process_usage(seconds_per_tick)
	var/usage = 0
	for(var/projectile as anything in tracked_bullet_cost)
		usage += projectile_tick_speed_ecost * seconds_per_tick
		usage += tracked_bullet_cost[projectile] * projectile_damage_tick_ecost_coefficient * seconds_per_tick
	energy = clamp(energy - usage, 0, maxenergy)
	if(energy <= 0)
		deactivate_field()
		visible_message(span_warning("[src] blinks \"ENERGY DEPLETED\"."))

/obj/item/borg/projectile_dampen/proc/process_recharge(seconds_per_tick)
	if(!istype(host))
		if(iscyborg(host.loc))
			host = host.loc
		else
			energy = clamp(energy + energy_recharge * seconds_per_tick, 0, maxenergy)
			return
	if(host.cell && (host.cell.charge >= (host.cell.maxcharge * cyborg_cell_critical_percentage)) && (energy < maxenergy))
		host.cell.use(energy_recharge * seconds_per_tick * POWER_RECHARGE_CYBORG_DRAIN_MULTIPLIER)
		energy += energy_recharge * seconds_per_tick

/obj/item/borg/projectile_dampen/proc/dampen_projectile(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(projectile.is_hostile_projectile())
		tracked_bullet_cost[REF(projectile)] = projectile.damage

/obj/item/borg/projectile_dampen/proc/restore_projectile(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER
	tracked_bullet_cost -= REF(projectile)

//bare minimum omni-toolset for modularity
/obj/item/borg/cyborg_omnitool
	name = "cyborg omni-toolset"
	desc = "You shouldn't see this in-game normally."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "toolkit_medborg"

	///our tools (list of item typepaths)
	var/list/obj/item/omni_toolkit = list()
	///Map of solid objects internally used by the omni tool
	var/list/obj/item/atoms = list()
	///object we are referencing to for force, sharpness and sound
	var/obj/item/reference
	//is the toolset upgraded or not
	var/upgraded = FALSE

/obj/item/borg/cyborg_omnitool/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/borg/cyborg_omnitool/Destroy(force)
	for(var/obj/item/tool_path as anything in atoms)
		var/obj/item/tool = atoms[tool_path]
		if(!QDELETED(tool)) //if we are sharing tools from our other omnitool brothers we don't want to re delete them if they got deleted first
			qdel(tool)
	atoms.Cut()

	return ..()

/obj/item/borg/cyborg_omnitool/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if (!issilicon(user))
		return
	var/mob/living/silicon/robot/as_cyborg = user
	if (!(src in as_cyborg.held_items))
		context[SCREENTIP_CONTEXT_RMB] = "Select Tool"
	return CONTEXTUAL_SCREENTIP_SET

/**
 * Sets the new internal tool to be used
 * Arguments
 *
 * * obj/item/ref - typepath for the new internal omnitool
 */
/obj/item/borg/cyborg_omnitool/proc/set_internal_tool(obj/item/tool)
	SHOULD_NOT_OVERRIDE(TRUE)

	for(var/obj/item/internal_tool as anything in omni_toolkit)
		if(internal_tool == tool)
			reference = internal_tool
			tool_behaviour = initial(internal_tool.tool_behaviour)
			break

/obj/item/borg/cyborg_omnitool/get_all_tool_behaviours()
	. = list()
	for(var/obj/item/tool as anything in omni_toolkit)
		. += initial(tool.tool_behaviour)

///The omnitool interacts with real world objects based on the state it has assumed
/obj/item/borg/cyborg_omnitool/get_proxy_attacker_for(atom/target, mob/user)
	if(!reference)
		return src

	//first check if we have the tool
	var/obj/item/tool = atoms[reference]
	if(!QDELETED(tool))
		return tool

	//else try to borrow an in-built tool from our other omnitool brothers to save & share memory & such
	var/mob/living/silicon/robot/borg = user
	for(var/obj/item/borg/cyborg_omnitool/omni_tool in borg.model.basic_modules)
		if(omni_tool == src)
			continue
		tool = omni_tool.atoms[reference]
		if(!QDELETED(tool))
			atoms[reference] = tool
			return tool

	//if all else fails just make a new one from scratch
	tool = new reference(user)
	//the internal tool is considered part of the tool itself, so don't let it be dropped.
	tool.item_flags |= ABSTRACT
	ADD_TRAIT(tool, TRAIT_NODROP, INNATE_TRAIT)
	atoms[reference] = tool
	return tool

/obj/item/borg/cyborg_omnitool/attack_self(mob/user)
	//build the radial menu options
	var/list/radial_menu_options = list()
	var/list/tool_map = list()
	for(var/obj/item as anything in omni_toolkit)
		var/tool_name = initial(item.name)
		radial_menu_options[tool_name] = image(icon = initial(item.icon), icon_state = initial(item.icon_state))
		tool_map[tool_name] = item

	//assign the new tool behaviour
	var/internal_tool_name = show_radial_menu(user, src, radial_menu_options, require_near = TRUE, tooltips = TRUE)
	if(!internal_tool_name)
		return

	//set the reference & update icons
	set_internal_tool(tool_map[internal_tool_name])
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'sound/items/tools/change_jaws.ogg', 50, TRUE)

/obj/item/borg/cyborg_omnitool/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(!LAZYACCESS(modifiers, RIGHT_CLICK) || !iscyborg(usr))
		return ..()
	var/mob/living/silicon/robot/user = usr
	if (!(src in user.held_items))
		attack_self(user)
	return ..()

/obj/item/borg/cyborg_omnitool/update_icon_state()
	if (reference)
		icon_state = reference.icon_state
	return ..()

/**
 * Is this omni tool upgraded or not
 * Arguments
 *
 * * upgrade - TRUE/FALSE for upgraded
 */
/obj/item/borg/cyborg_omnitool/proc/set_upgraded(upgrade)
	upgraded = upgraded

	playsound(src, 'sound/items/tools/change_jaws.ogg', 50, TRUE)

/obj/item/borg/cyborg_omnitool/medical
	name = "surgical omni-toolset"
	desc = "A set of surgical tools used by cyborgs to operate on various surgical operations."

	omni_toolkit = list(
		/obj/item/surgical_drapes/cyborg,
		/obj/item/scalpel/cyborg,
		/obj/item/surgicaldrill/cyborg,
		/obj/item/hemostat/cyborg,
		/obj/item/retractor/cyborg,
		/obj/item/cautery/cyborg,
		/obj/item/circular_saw/cyborg,
		/obj/item/bonesetter/cyborg,
	)

//Toolset for engineering cyborgs, this is all of the tools except for the welding tool. since it's quite hard to implement (read:can't be arsed to)
/obj/item/borg/cyborg_omnitool/engineering
	name = "engineering omni-toolset"
	desc = "A set of engineering tools used by cyborgs to conduct various engineering tasks."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "toolkit_engiborg"

	omni_toolkit = list(
		/obj/item/wrench/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/multitool/cyborg,
	)

/obj/item/borg/cyborg_omnitool/engineering/examine(mob/user)
	. = ..()

	if(tool_behaviour == TOOL_MULTITOOL)
		for(var/obj/item/multitool/tool in atoms)
			. += "Its multitool buffer contains [tool.buffer]"
			break

/obj/item/borg/cyborg_omnitool/botany
	name = "botanical omni-toolset"
	desc = "A set of botanical tools used by cyborgs to do gardening."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "sili"

	omni_toolkit = list(
		/obj/item/secateurs/cyborg,
		/obj/item/cultivator/cyborg,
		/obj/item/hatchet/cyborg,
		/obj/item/shovel/spade/cyborg,
	)


#undef PKBORG_DAMPEN_CYCLE_DELAY
#undef POWER_RECHARGE_CYBORG_DRAIN_MULTIPLIER
