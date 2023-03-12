/// How many seconds between each fuel depletion tick ("use" proc)
#define WELDER_FUEL_BURN_INTERVAL 26
/obj/item/weldingtool
	name = "welding tool"
	desc = "A standard edition welder provided by Nanotrasen."
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	inhand_icon_state = "welder"
	worn_icon_state = "welder"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 3
	throwforce = 5
	hitsound = SFX_SWING_HIT
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	drop_sound = 'sound/items/handling/weldingtool_drop.ogg'
	pickup_sound = 'sound/items/handling/weldingtool_pickup.ogg'
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.75
	light_color = LIGHT_COLOR_FIRE
	light_on = FALSE
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	armor_type = /datum/armor/item_weldingtool
	resistance_flags = FIRE_PROOF
	heat = 3800
	tool_behaviour = TOOL_WELDER
	toolspeed = 1
	wound_bonus = 10
	bare_wound_bonus = 15
	custom_materials = list(/datum/material/iron=70, /datum/material/glass=30)
	/// Whether the welding tool is on or off.
	var/welding = FALSE
	/// Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/status = TRUE
	/// The max amount of fuel the welder can hold
	var/max_fuel = 20
	/// Does the welder start with fuel.
	var/starting_fuel = TRUE
	/// Whether or not we're changing the icon based on fuel left.
	var/change_icons = TRUE
	/// Used in process(), dictates whether or not we're calling STOP_PROCESSING whilst we're not welding.
	var/can_off_process = FALSE
	/// When fuel was last removed.
	var/burned_fuel_for = 0

	var/activation_sound = 'sound/items/welderactivate.ogg'
	var/deactivation_sound = 'sound/items/welderdeactivate.ogg'

/datum/armor/item_weldingtool
	fire = 100
	acid = 30

/obj/item/weldingtool/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_HANDS)
	AddElement(/datum/element/tool_flash, light_range)
	AddElement(/datum/element/falling_hazard, damage = force, wound_bonus = wound_bonus, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

	create_reagents(max_fuel)
	if(starting_fuel)
		reagents.add_reagent(/datum/reagent/fuel, max_fuel)
	update_appearance()

/obj/item/weldingtool/update_icon_state()
	if(welding)
		inhand_icon_state = "[initial(inhand_icon_state)]1"
	else
		inhand_icon_state = "[initial(inhand_icon_state)]"
	return ..()


/obj/item/weldingtool/update_overlays()
	. = ..()
	if(change_icons)
		var/ratio = get_fuel() / max_fuel
		ratio = CEILING(ratio*4, 1) * 25
		. += "[initial(icon_state)][ratio]"
	if(welding)
		. += "[initial(icon_state)]-on"


/obj/item/weldingtool/process(delta_time)
	if(welding)
		force = 15
		damtype = BURN
		burned_fuel_for += delta_time
		if(burned_fuel_for >= WELDER_FUEL_BURN_INTERVAL)
			use(TRUE)
		update_appearance()

	//Welders left on now use up fuel, but lets not have them run out quite that fast
	else
		force = 3
		damtype = BRUTE
		update_appearance()
		if(!can_off_process)
			STOP_PROCESSING(SSobj, src)
		return

	//This is to start fires. process() is only called if the welder is on.
	open_flame()


/obj/item/weldingtool/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] welds [user.p_their()] every orifice closed! It looks like [user.p_theyre()] trying to commit suicide!"))
	return FIRELOSS

/obj/item/weldingtool/screwdriver_act(mob/living/user, obj/item/tool)
	flamethrower_screwdriver(tool, user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/weldingtool/attackby(obj/item/tool, mob/user, params)
	if(istype(tool, /obj/item/stack/rods))
		flamethrower_rods(tool, user)
	else
		. = ..()
	update_appearance()

/obj/item/weldingtool/proc/explode()
	var/plasmaAmount = reagents.get_reagent_amount(/datum/reagent/toxin/plasma)
	dyn_explosion(src, plasmaAmount/5, explosion_cause = src) // 20 plasma in a standard welder has a 4 power explosion. no breaches, but enough to kill/dismember holder
	qdel(src)

/obj/item/weldingtool/use_tool(atom/target, mob/living/user, delay, amount, volume, datum/callback/extra_checks)
	var/mutable_appearance/sparks = mutable_appearance('icons/effects/welding_effect.dmi', "welding_sparks", GASFIRE_LAYER, src, ABOVE_LIGHTING_PLANE)
	target.add_overlay(sparks)
	LAZYADD(update_overlays_on_z, sparks)
	. = ..()
	LAZYREMOVE(update_overlays_on_z, sparks)
	target.cut_overlay(sparks)

/obj/item/weldingtool/attack(mob/living/carbon/human/attacked_humanoid, mob/living/user)
	if(!istype(attacked_humanoid))
		return ..()

	var/obj/item/bodypart/affecting = attacked_humanoid.get_bodypart(check_zone(user.zone_selected))

	if(affecting && !IS_ORGANIC_LIMB(affecting) && !user.combat_mode)
		if(src.use_tool(attacked_humanoid, user, 0, volume=50, amount=1))
			if(user == attacked_humanoid)
				user.visible_message(span_notice("[user] starts to fix some of the dents on [attacked_humanoid]'s [affecting.name]."),
					span_notice("You start fixing some of the dents on [attacked_humanoid == user ? "your" : "[attacked_humanoid]'s"] [affecting.name]."))
				if(!do_after(user, 5 SECONDS, attacked_humanoid))
					return
			item_heal_robotic(attacked_humanoid, user, 15, 0)
	else
		return ..()

/obj/item/weldingtool/afterattack(atom/attacked_atom, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(isOn())
		. |= AFTERATTACK_PROCESSED_ITEM
		if (!QDELETED(attacked_atom) && isliving(attacked_atom)) // can't ignite something that doesn't exist
			handle_fuel_and_temps(1, user)
			var/mob/living/attacked_mob = attacked_atom
			if(attacked_mob.ignite_mob())
				message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(attacked_mob)] on fire with [src] at [AREACOORD(user)]")
				user.log_message("set [key_name(attacked_mob)] on fire with [src].", LOG_ATTACK)

	if(!status && attacked_atom.is_refillable())
		. |= AFTERATTACK_PROCESSED_ITEM
		reagents.trans_to(attacked_atom, reagents.total_volume, transfered_by = user)
		to_chat(user, span_notice("You empty [src]'s fuel tank into [attacked_atom]."))
		update_appearance()

	return .

/obj/item/weldingtool/attack_qdeleted(atom/attacked_atom, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(isOn())
		handle_fuel_and_temps(1, user)

		if(!QDELETED(attacked_atom) && isliving(attacked_atom)) // can't ignite something that doesn't exist
			var/mob/living/attacked_mob = attacked_atom
			if(attacked_mob.ignite_mob())
				message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(attacked_mob)] on fire with [src] at [AREACOORD(user)].")
				user.log_message("set [key_name(attacked_mob)] on fire with [src]", LOG_ATTACK)


/obj/item/weldingtool/attack_self(mob/user)
	if(src.reagents.has_reagent(/datum/reagent/toxin/plasma))
		message_admins("[ADMIN_LOOKUPFLW(user)] activated a rigged welder at [AREACOORD(user)].")
		user.log_message("activated a rigged welder", LOG_VICTIM)
		explode()
	switched_on(user)

	update_appearance()

/obj/item/weldingtool/proc/handle_fuel_and_temps(used = 0, mob/living/user)
	use(used)
	var/turf/location = get_turf(user)
	location.hotspot_expose(700, 50, 1)

/// Returns the amount of fuel in the welder
/obj/item/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount(/datum/reagent/fuel)


/// Uses fuel from the welding tool.
/obj/item/weldingtool/use(used = 0)
	if(!isOn() || !check_fuel())
		return FALSE

	if(used > 0)
		burned_fuel_for = 0

	if(get_fuel() >= used)
		reagents.remove_reagent(/datum/reagent/fuel, used)
		check_fuel()
		return TRUE
	else
		return FALSE


/// Toggles the welding value.
/obj/item/weldingtool/proc/set_welding(new_value)
	if(welding == new_value)
		return
	. = welding
	welding = new_value
	set_light_on(welding)


/// Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weldingtool/proc/check_fuel(mob/user)
	if(get_fuel() <= 0 && welding)
		set_light_on(FALSE)
		switched_on(user)
		update_appearance()
		return FALSE
	return TRUE

// /Switches the welder on
/obj/item/weldingtool/proc/switched_on(mob/user)
	if(!status)
		to_chat(user, span_warning("[src] can't be turned on while unsecured!"))
		return
	set_welding(!welding)
	if(welding)
		if(get_fuel() >= 1)
			playsound(loc, activation_sound, 50, TRUE)
			force = 15
			damtype = BURN
			hitsound = 'sound/items/welder.ogg'
			update_appearance()
			START_PROCESSING(SSobj, src)
		else
			balloon_alert(user, "no fuel!")
			switched_off(user)
	else
		playsound(loc, deactivation_sound, 50, TRUE)
		switched_off(user)

/// Switches the welder off
/obj/item/weldingtool/proc/switched_off(mob/user)
	set_welding(FALSE)

	force = 3
	damtype = BRUTE
	hitsound = SFX_SWING_HIT
	update_appearance()


/obj/item/weldingtool/examine(mob/user)
	. = ..()
	. += "It contains [get_fuel()] unit\s of fuel out of [max_fuel]."

/obj/item/weldingtool/get_temperature()
	return welding * heat

/// Returns whether or not the welding tool is currently on.
/obj/item/weldingtool/proc/isOn()
	return welding

/// If welding tool ran out of fuel during a construction task, construction fails.
/obj/item/weldingtool/tool_use_check(mob/living/user, amount)
	if(!isOn() || !check_fuel())
		to_chat(user, span_warning("[src] has to be on to complete this task!"))
		return FALSE

	if(get_fuel() >= amount)
		return TRUE
	else
		to_chat(user, span_warning("You need more welding fuel to complete this task!"))
		return FALSE

/// Ran when the welder is attacked by a screwdriver.
/obj/item/weldingtool/proc/flamethrower_screwdriver(obj/item/tool, mob/user)
	if(welding)
		to_chat(user, span_warning("Turn it off first!"))
		return
	status = !status
	if(status)
		to_chat(user, span_notice("You resecure [src] and close the fuel tank."))
		reagents.flags &= ~(OPENCONTAINER)
	else
		to_chat(user, span_notice("[src] can now be attached, modified, and refuelled."))
		reagents.flags |= OPENCONTAINER
	add_fingerprint(user)

/// First step of building a flamethrower (when a welder is attacked by rods)
/obj/item/weldingtool/proc/flamethrower_rods(obj/item/tool, mob/user)
	if(!status)
		var/obj/item/stack/rods/used_rods = tool
		if (used_rods.use(1))
			var/obj/item/flamethrower/flamethrower_frame = new /obj/item/flamethrower(user.loc)
			if(!remove_item_from_storage(flamethrower_frame))
				user.transferItemToLoc(src, flamethrower_frame, TRUE)
			flamethrower_frame.weldtool = src
			add_fingerprint(user)
			to_chat(user, span_notice("You add a rod to a welder, starting to build a flamethrower."))
			user.put_in_hands(flamethrower_frame)
		else
			to_chat(user, span_warning("You need one rod to start building a flamethrower!"))

/obj/item/weldingtool/ignition_effect(atom/ignitable_atom, mob/user)
	if(use_tool(ignitable_atom, user, 0, amount=1))
		return span_notice("[user] casually lights [ignitable_atom] with [src], what a badass.")
	else
		return ""

/obj/item/weldingtool/empty
	starting_fuel = FALSE

/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	desc = "A slightly larger welder with a larger tank."
	icon_state = "indwelder"
	max_fuel = 40
	custom_materials = list(/datum/material/glass=60)

/obj/item/weldingtool/largetank/flamethrower_screwdriver()
	return

/obj/item/weldingtool/largetank/empty
	starting_fuel = FALSE

/obj/item/weldingtool/largetank/cyborg
	name = "integrated welding tool"
	desc = "An advanced welder designed to be used in robotic systems. Custom framework doubles the speed of welding."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "indwelder_cyborg"
	toolspeed = 0.5

/obj/item/weldingtool/largetank/cyborg/cyborg_unequip(mob/user)
	if(!isOn())
		return
	switched_on(user)


/obj/item/weldingtool/mini
	name = "emergency welding tool"
	desc = "A miniature welder used during emergencies."
	icon_state = "miniwelder"
	max_fuel = 10
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)
	change_icons = FALSE

/obj/item/weldingtool/mini/flamethrower_screwdriver()
	return

/obj/item/weldingtool/mini/empty
	starting_fuel = FALSE

/obj/item/weldingtool/abductor
	name = "alien welding tool"
	desc = "An alien welding tool. Whatever fuel it uses, it never runs out."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "welder"
	toolspeed = 0.1
	custom_materials = list(/datum/material/iron = 5000, /datum/material/silver = 2500, /datum/material/plasma = 5000, /datum/material/titanium = 2000, /datum/material/diamond = 2000)
	light_system = NO_LIGHT_SUPPORT
	light_range = 0
	change_icons = FALSE

/obj/item/weldingtool/abductor/process()
	if(get_fuel() <= max_fuel)
		reagents.add_reagent(/datum/reagent/fuel, 1)
	..()

/obj/item/weldingtool/hugetank
	name = "upgraded industrial welding tool"
	desc = "An upgraded welder based of the industrial welder."
	icon_state = "upindwelder"
	inhand_icon_state = "upindwelder"
	max_fuel = 80
	custom_materials = list(/datum/material/iron=70, /datum/material/glass=120)

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	desc = "An experimental welder capable of self-fuel generation and less harmful to the eyes."
	icon_state = "exwelder"
	inhand_icon_state = "exwelder"
	max_fuel = 40
	custom_materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/plasma = 1500, /datum/material/uranium = 200)
	change_icons = FALSE
	can_off_process = TRUE
	light_range = 1
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.5
	var/last_gen = 0
	var/nextrefueltick = 0

/obj/item/weldingtool/experimental/process()
	..()
	if(get_fuel() < max_fuel && nextrefueltick < world.time)
		nextrefueltick = world.time + 10
		reagents.add_reagent(/datum/reagent/fuel, 1)

#undef WELDER_FUEL_BURN_INTERVAL
