#define PKBORG_DAMPEN_CYCLE_DELAY (2 SECONDS)
#define POWER_RECHARGE_CYBORG_DRAIN_MULTIPLIER (0.0004 * STANDARD_CELL_RATE)
#define NO_TOOL "deactivated"
#define TOOL_DRAPES "surgical_drapes"

/obj/item/cautery/prt //it's a subtype of cauteries so that it inherits the cautery sprites and behavior and stuff, because I'm too lazy to make sprites for this thing
	name = "plating repair tool"
	desc = "A tiny heating device that's powered by a cyborg's excess heat. Its intended purpose is to repair burnt or damaged hull platings, but it can also be used as a crude lighter or cautery."
	toolspeed = 1.5 //it's not designed to be used as a cautery (although it's close enough to one to be considered to be a proper cautery instead of just a hot object for the purposes of surgery)
	heat = 3800 //this thing is intended for metal-shaping, so it's the same temperature as a lit welder
	resistance_flags = FIRE_PROOF //if it's channeling a cyborg's excess heat, it's probably fireproof
	force = 5
	damtype = BURN
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg') //the usesounds of a lit welder
	hitsound = 'sound/items/welder.ogg' //the hitsound of a lit welder

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
	var/datum/proximity_monitor/advanced/projectile_dampener/peaceborg/dampening_field
	var/projectile_damage_coefficient = 0.5
	/// Energy cost per tracked projectile damage amount per second
	var/projectile_damage_tick_ecost_coefficient = 10
	/**
	 * Speed coefficient
	 * Higher the coefficient slower the projectile.
	*/
	var/projectile_speed_coefficient = 1.5
	/// Energy cost per tracked projectile per second
	var/projectile_tick_speed_ecost = 75
	/// Projectile sent out by the dampener
	var/list/obj/projectile/tracked
	var/image/projectile_effect
	var/field_radius = 3
	var/active = FALSE
	/// activation cooldown
	COOLDOWN_DECLARE(cycle_cooldown)

/obj/item/borg/projectile_dampen/debug
	maxenergy = 50000
	energy = 50000
	energy_recharge = 5000

/obj/item/borg/projectile_dampen/Initialize(mapload)
	projectile_effect = image('icons/effects/fields.dmi', "projectile_dampen_effect")
	tracked = list()
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
	dampening_field = new(owner, field_radius, TRUE, src)
	RegisterSignal(dampening_field, COMSIG_DAMPENER_CAPTURE, PROC_REF(dampen_projectile))
	RegisterSignal(dampening_field, COMSIG_DAMPENER_RELEASE, PROC_REF(restore_projectile))
	owner?.model.allow_riding = FALSE
	active = TRUE

/obj/item/borg/projectile_dampen/proc/deactivate_field()
	QDEL_NULL(dampening_field)
	visible_message(span_warning("\The [src] shuts off!"))
	for(var/projectile in tracked)
		restore_projectile(projectile = projectile)
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

/obj/item/borg/projectile_dampen/dropped()
	host = loc
	return ..()

/obj/item/borg/projectile_dampen/equipped()
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
	for(var/obj/projectile/inner_projectile as anything in tracked)
		if(!inner_projectile.is_hostile_projectile())
			continue
		usage += projectile_tick_speed_ecost * seconds_per_tick
		usage += tracked[inner_projectile] * projectile_damage_tick_ecost_coefficient * seconds_per_tick
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

	tracked[projectile] = projectile.damage
	projectile.damage *= projectile_damage_coefficient
	projectile.speed *= projectile_speed_coefficient
	projectile.add_overlay(projectile_effect)

/obj/item/borg/projectile_dampen/proc/restore_projectile(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	tracked -= projectile
	projectile.damage *= (1 / projectile_damage_coefficient)
	projectile.speed *= (1 / projectile_speed_coefficient)
	projectile.cut_overlay(projectile_effect)

//////////////////////
///CYBORG OMNITOOLS///
//////////////////////

/**
	Onmi Toolboxs act as a cache of tools for a particular borg's omnitools. Not all borg
	get a toolbox (as not all borgs use omnitools), and those that do can only have one
	toolbox. The toolbox keeps track of a borg's omnitool arms, and handles speed upgrades.

	Omnitools are the actual tool arms for the cyborg to interact with. When attack_self
	is called, they can select a tool from the toolbox. The tool is not moved, and instead
	only referenced in place of the omnitool's own attacks. The omnitool also takes on
	the tool's sprite, which completes the illusion. In this way, multiple tools are
	shared between multiple omnitool arms. A multitool's buffer, for example, will not
	depend on which omnitool arm was used to set it.
*/
/obj/item/cyborg_omnitoolbox
	name = "broken cyborg toolbox"
	desc = "Some internal part of a broken cyborg."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "lollipop"
	toolspeed = 10
	///List of Omnitool "arms" that the borg has.
	var/list/omnitools = list()
	///List of paths for tools. These will be created during Initialize()
	var/list/toolpaths = list()
	///Target Toolspeed to set after reciving an omnitool upgrade
	var/upgraded_toolspeed = 10
	///Whether we currently have the upgraded speed
	var/currently_upgraded = FALSE

/obj/item/cyborg_omnitoolbox/Initialize(mapload)
	. = ..()
	if(!toolpaths.len)
		return

	var/obj/item/newitem
	for(var/newpath in toolpaths)
		newitem = new newpath(src)
		newitem.toolspeed = toolspeed //In case thse have different base speeds as stand-alone tools on other borgs
		ADD_TRAIT(newitem, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/cyborg_omnitoolbox/proc/set_upgrade(upgrade = FALSE)
	for(var/obj/item/tool in contents)
		if(upgrade)
			tool.toolspeed = upgraded_toolspeed
		else
			tool.toolspeed = toolspeed
	currently_upgraded = upgrade

/obj/item/cyborg_omnitoolbox/engineering
	toolspeed = 0.5
	upgraded_toolspeed = 0.3
	toolpaths = list(
		/obj/item/wrench/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/multitool/cyborg,
	)

/obj/item/cyborg_omnitoolbox/medical
	toolspeed = 1
	upgraded_toolspeed = 0.7
	toolpaths = list(
		/obj/item/scalpel/cyborg,
		/obj/item/surgicaldrill/cyborg,
		/obj/item/hemostat/cyborg,
		/obj/item/retractor/cyborg,
		/obj/item/cautery/cyborg,
		/obj/item/circular_saw/cyborg,
		/obj/item/bonesetter/cyborg,
	)

/obj/item/borg/cyborg_omnitool
	name = "broken cyborg tool arm"
	desc = "Some internal part of a broken cyborg."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "lollipop"
	///Ref to the toolbox, since our own loc will be changing
	var/obj/item/cyborg_omnitoolbox/toolbox
	///Ref to currently selected tool, if any
	var/obj/item/selected

/obj/item/borg/cyborg_omnitool/Initialize(mapload)
	. = ..()
	if(!iscyborg(loc.loc))
		return
	var/obj/item/robot_model/model = loc
	var/obj/item/cyborg_omnitoolbox/chassis_toolbox = model.toolbox
	if(!chassis_toolbox)
		return
	toolbox = chassis_toolbox
	toolbox.omnitools += src

/obj/item/borg/cyborg_omnitool/attack_self(mob/user)
	var/list/radial_menu_options = list()
	for(var/obj/item/borgtool in toolbox.contents)
		radial_menu_options[borgtool] = image(icon = borgtool.icon, icon_state = borgtool.icon_state)
	var/obj/item/potential_new_tool = show_radial_menu(user, src, radial_menu_options, require_near = TRUE, tooltips = TRUE)
	if(!potential_new_tool)
		return ..()
	if(potential_new_tool == selected)
		return ..()
	for(var/obj/item/borg/cyborg_omnitool/coworker in toolbox.omnitools)
		if(coworker.selected == potential_new_tool)
			coworker.deselect() //Can I borrow that please
			break
	selected = potential_new_tool
	icon_state = selected.icon_state
	playsound(src, 'sound/items/change_jaws.ogg', 50, TRUE)
	return ..()

/obj/item/borg/cyborg_omnitool/proc/deselect()
	if(!selected)
		return
	selected = null
	icon_state = initial(icon_state)
	playsound(src, 'sound/items/change_jaws.ogg', 50, TRUE)

/obj/item/borg/cyborg_omnitool/cyborg_unequip()
	deselect()
	return ..()

/obj/item/borg/cyborg_omnitool/melee_attack_chain(mob/user, atom/target, params)
	if(selected)
		return selected.melee_attack_chain(user, target, params)
	return ..()

/obj/item/borg/cyborg_omnitool/engineering
	name = "engineering omni-toolset"
	desc = "A set of engineering tools used by cyborgs to conduct various engineering tasks."
	icon_state = "toolkit_engiborg"

/obj/item/borg/cyborg_omnitool/medical
	name = "surgical omni-toolset"
	desc = "A set of surgical tools used by cyborgs to operate on various surgical operations."
	icon_state = "toolkit_medborg"

#undef PKBORG_DAMPEN_CYCLE_DELAY
#undef POWER_RECHARGE_CYBORG_DRAIN_MULTIPLIER
#undef NO_TOOL
#undef TOOL_DRAPES
