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
	var/burning = 0
	var/burn_icon = "bonfire_on_fire" //for a softer more burning embers icon, use "bonfire_warm"
	var/grill = FALSE
	var/fire_stack_strength = 5

/obj/structure/bonfire/dense
	density = TRUE

/obj/structure/bonfire/prelit/Initialize()
	. = ..()
	start_burning()

/obj/structure/bonfire/Initialize()
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/bonfire/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/stack/rods) && !can_buckle && !grill)
		var/obj/item/stack/rods/R = W
		var/choice = input(user, "What would you like to construct?", "Bonfire") as null|anything in list("Stake","Grill")
		switch(choice)
			if("Stake")
				R.use(1)
				can_buckle = TRUE
				buckle_requires_restraints = TRUE
				to_chat(user, span_notice("You add a rod to \the [src]."))
				var/mutable_appearance/rod_underlay = mutable_appearance('icons/obj/hydroponics/equipment.dmi', "bonfire_rod")
				rod_underlay.pixel_y = 16
				underlays += rod_underlay
			if("Grill")
				R.use(1)
				grill = TRUE
				to_chat(user, span_notice("You add a grill to \the [src]."))
				add_overlay("bonfire_grill")
			else
				return ..()
	if(W.get_temperature())
		start_burning()
	if(grill)
		if(!user.combat_mode && !(W.item_flags & ABSTRACT))
			if(user.temporarilyRemoveItemFromInventory(W))
				W.forceMove(get_turf(src))
				var/list/modifiers = params2list(params)
				//Center the icon where the user clicked.
				if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
					return
				//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
				W.pixel_x = W.base_pixel_x + clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
				W.pixel_y = W.base_pixel_y + clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)
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
		for(var/obj/item/grown/log/L in contents)
			L.forceMove(drop_location())
			L.pixel_x += rand(1,4)
			L.pixel_y += rand(1,4)
		if(can_buckle || grill)
			new /obj/item/stack/rods(loc, 1)
		qdel(src)
		return

/obj/structure/bonfire/proc/CheckOxygen()
	if(isopenturf(loc))
		var/turf/open/O = loc
		if(O.air)
			var/loc_gases = O.air.gases
			if(loc_gases[/datum/gas/oxygen] && loc_gases[/datum/gas/oxygen][MOLES] >= 5)
				return TRUE
	return FALSE

/obj/structure/bonfire/proc/start_burning()
	if(!burning && CheckOxygen())
		icon_state = burn_icon
		burning = TRUE
		set_light(6)
		bonfire_burn()
		particles = new /particles/bonfire()
		START_PROCESSING(SSobj, src)

/obj/structure/bonfire/fire_act(exposed_temperature, exposed_volume)
	start_burning()

/obj/structure/bonfire/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(burning & !grill)
		bonfire_burn()

/obj/structure/bonfire/proc/bonfire_burn(delta_time = 2)
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000, 250 * delta_time, 1)
	for(var/A in current_location)
		if(A == src)
			continue
		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 250 * delta_time)
		else if(isliving(A))
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength * 0.5 * delta_time)
			L.IgniteMob()

/obj/structure/bonfire/proc/bonfire_cook(delta_time = 2)
	var/turf/current_location = get_turf(src)
	for(var/A in current_location)
		if(A == src)
			continue
		else if(isliving(A)) //It's still a fire, idiot.
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength * 0.5 * delta_time)
			L.IgniteMob()
		else if(istype(A, /obj/item))
			var/obj/item/grilled_item = A
			SEND_SIGNAL(grilled_item, COMSIG_ITEM_GRILLED, src, delta_time) //Not a big fan, maybe make this use fire_act() in the future.

/obj/structure/bonfire/process(delta_time)
	if(!CheckOxygen())
		extinguish()
		return
	if(!grill)
		bonfire_burn(delta_time)
	else
		bonfire_cook(delta_time)

/obj/structure/bonfire/extinguish()
	if(burning)
		icon_state = "bonfire"
		burning = 0
		set_light(0)
		QDEL_NULL(particles)
		STOP_PROCESSING(SSobj, src)

/obj/structure/bonfire/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(..())
		M.pixel_y += 13

/obj/structure/bonfire/unbuckle_mob(mob/living/buckled_mob, force=FALSE)
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
	position = generator("circle", 0, 16, NORMAL_RAND)
	drift = generator("vector", list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator("vector", list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator("num", -20, 20)
