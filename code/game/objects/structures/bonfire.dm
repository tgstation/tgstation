///how many fire stacks are applied when you step into a bonfire
#define BONFIRE_FIRE_STACK_STRENGTH 5

/**
 * ## BONFIRES
 *
 * Structure that makes a big old fire. You can add rods to construct a grill for grilling meat, or a stake for buckling people to the fire,
 * salem style. Keeping the fire on requires oxygen. You can dismantle the bonfire back into logs when it is unignited.
 */
/obj/structure/bonfire
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "bonfire"
	light_color = LIGHT_COLOR_FIRE
	density = FALSE
	anchored = TRUE
	buckle_lying = 0
	pass_flags_self = PASSTABLE | LETPASSTHROW
	///is the bonfire lit?
	var/burning = FALSE
	///icon for the bonfire while on. for a softer more burning embers icon, use "bonfire_warm"
	var/burn_icon = "bonfire_on_fire"
	///if the bonfire has a grill attached
	var/grill = FALSE

/obj/structure/bonfire/dense
	density = TRUE

/obj/structure/bonfire/prelit/Initialize(mapload)
	. = ..()
	start_burning()

/obj/structure/bonfire/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/bonfire/attackby(obj/item/used_item, mob/living/user, params)
	if(istype(used_item, /obj/item/stack/rods) && !can_buckle && !grill)
		var/obj/item/stack/rods/rods = used_item
		var/choice = tgui_alert(user, "What would you like to construct?", "Bonfire", list("Stake","Grill"))
		if(isnull(choice))
			return
		rods.use(1)
		switch(choice)
			if("Stake")
				can_buckle = TRUE
				buckle_requires_restraints = TRUE
				to_chat(user, span_notice("You add a rod to \the [src]."))
				var/mutable_appearance/rod_underlay = mutable_appearance('icons/obj/hydroponics/equipment.dmi', "bonfire_rod")
				rod_underlay.pixel_y = 16
				underlays += rod_underlay
			if("Grill")
				grill = TRUE
				to_chat(user, span_notice("You add a grill to \the [src]."))
				add_overlay("bonfire_grill")
			else
				return ..()
	if(used_item.get_temperature())
		start_burning()
	if(grill)
		if(istype(used_item, /obj/item/melee/roastingstick))
			return FALSE
		if(!user.combat_mode && !(used_item.item_flags & ABSTRACT))
			if(user.temporarilyRemoveItemFromInventory(used_item))
				used_item.forceMove(get_turf(src))
				var/list/modifiers = params2list(params)
				//Center the icon where the user clicked.
				if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
					return
				//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
				used_item.pixel_x = used_item.base_pixel_x + clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
				used_item.pixel_y = used_item.base_pixel_y + clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)
		else
			return ..()


/obj/structure/bonfire/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(burning)
		to_chat(user, span_warning("You need to extinguish [src] before removing the logs!"))
		return
	if(!has_buckled_mobs() && do_after(user, 50, target = src))
		for(var/obj/item/grown/log/bonfire_log in contents)
			bonfire_log.forceMove(drop_location())
			bonfire_log.pixel_x += rand(1,4)
			bonfire_log.pixel_y += rand(1,4)
		if(can_buckle || grill)
			new /obj/item/stack/rods(loc, 1)
		qdel(src)
		return

/obj/structure/bonfire/proc/check_oxygen()
	if(isopenturf(loc))
		var/turf/open/bonfire_turf = loc
		if(bonfire_turf.air)
			var/loc_gases = bonfire_turf.air.gases
			if(loc_gases[/datum/gas/oxygen] && loc_gases[/datum/gas/oxygen][MOLES] >= 5)
				return TRUE
	return FALSE

/obj/structure/bonfire/proc/start_burning()
	if(burning || !check_oxygen())
		return
	icon_state = burn_icon
	burning = TRUE
	set_light(6)
	bonfire_burn()
	particles = new /particles/bonfire()
	START_PROCESSING(SSobj, src)

/obj/structure/bonfire/fire_act(exposed_temperature, exposed_volume)
	start_burning()

/obj/structure/bonfire/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(burning)
		if(!grill)
			bonfire_burn()
		return

	//Not currently burning, let's see if we can ignite it.
	if(isliving(entered))
		var/mob/living/burning_body = entered
		if(burning_body.on_fire)
			start_burning()
			visible_message(span_notice("[entered] runs over [src], starting its fire!"))

	else if(entered.resistance_flags & ON_FIRE)
		start_burning()
		visible_message(span_notice("[entered]'s fire spreads to [src], setting it ablaze!"))

/obj/structure/bonfire/proc/bonfire_burn(delta_time = 2)
	var/turf/current_location = get_turf(src)
	if(!grill)
		current_location.hotspot_expose(1000, 250 * delta_time, 1)
	for(var/burn_target in current_location)
		if(burn_target == src)
			continue
		else if(isliving(burn_target))
			var/mob/living/burn_victim = burn_target
			burn_victim.adjust_fire_stacks(BONFIRE_FIRE_STACK_STRENGTH * 0.5 * delta_time)
			burn_victim.ignite_mob()
		else if(isobj(burn_target))
			var/obj/burned_object = burn_target
			if(grill && isitem(burned_object))
				var/obj/item/grilled_item = burned_object
				SEND_SIGNAL(grilled_item, COMSIG_ITEM_GRILL_PROCESS, src, delta_time) //Not a big fan, maybe make this use fire_act() in the future.
				continue
			burned_object.fire_act(1000, 250 * delta_time)

/obj/structure/bonfire/process(delta_time)
	if(!check_oxygen())
		extinguish()
		return
	bonfire_burn(delta_time)

/obj/structure/bonfire/extinguish()
	if(burning)
		icon_state = "bonfire"
		burning = FALSE
		set_light(0)
		QDEL_NULL(particles)
		STOP_PROCESSING(SSobj, src)

/obj/structure/bonfire/buckle_mob(mob/living/buckled_mob, force = FALSE, check_loc = TRUE)
	if(..())
		buckled_mob.pixel_y += 13

/obj/structure/bonfire/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	if(..())
		buckled_mob.pixel_y -= 13

/particles/bonfire
	icon = 'icons/effects/particles/bonfire.dmi'
	icon_state = "bonfire"
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator(GEN_NUM, -20, 20)
