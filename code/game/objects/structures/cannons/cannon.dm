/obj/structure/cannon
	name = "cannon"
	desc = "Holemaker Deluxe: A sporty model with a good stop power. Any cannon enthusiast should be expected to start here."
	density = TRUE
	anchored = TRUE
	icon_state = "falconet_patina"
	max_integrity = 300
	var/obj/item/stack/cannonball/loaded_cannonball = null
	var/charge_ignited = FALSE
	var/fire_delay = 15
	var/charge_size = 15
	var/fire_sound = 'sound/weapons/gun/general/cannon.ogg'

/obj/structure/cannon/Initialize()
	. = ..()
	create_reagents(charge_size)

/obj/structure/cannon/proc/fire()
	for(var/mob/shaken_mob in urange(10, src))
		if(shaken_mob.stat == CONSCIOUS)
			shake_camera(shaken_mob, 3, 1)

		playsound(src, fire_sound, 50, TRUE)
	if(loaded_cannonball)
		var/obj/projectile/fired_projectile = new loaded_cannonball.projectile_type(get_turf(src))
		QDEL_NULL(loaded_cannonball)
		fired_projectile.firer = src
		fired_projectile.fired_from = src
		fired_projectile.fire(dir2angle(dir))
	reagents.remove_all()
	charge_ignited = FALSE

/obj/structure/cannon/attackby(obj/item/W, mob/user, params)
	if(charge_ignited)
		to_chat(user, span_danger("[src] is about to fire!"))
		return
	var/ignition_message = W.ignition_effect(src, user)

	if(istype(W, /obj/item/stack/cannonball))
		if(loaded_cannonball)
			to_chat(user, span_warning("[src] is already loaded!"))
		else
			var/obj/item/stack/cannonball/cannoneers_balls = W
			loaded_cannonball = new cannoneers_balls.type(src, 1)
			loaded_cannonball.copy_evidences(cannoneers_balls)
			to_chat(user, span_notice("You load a [cannoneers_balls.singular_name] into [src]."))
			cannoneers_balls.use(1, transfer = TRUE)
		return

	else if(ignition_message)
		if(!reagents.has_reagent(/datum/reagent/gunpowder,15))
			to_chat(user, span_warning("[src] needs at least 15u of gunpowder to fire!"))
			return
		visible_message(ignition_message)
		log_game("Cannon fired by [key_name(user)] in [AREACOORD(src)]")
		addtimer(CALLBACK(src, .proc/fire), fire_delay)
		charge_ignited = TRUE
		return

	else if(istype(W, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/powder_keg = W
		if(!(powder_keg.reagent_flags & OPENCONTAINER))
			return ..()
		if(istype(powder_keg, /obj/item/reagent_containers/glass/rag))
			return ..()

		if(!powder_keg.reagents.total_volume)
			to_chat(user, span_warning("[powder_keg] is empty!"))
			return
		else if(!powder_keg.reagents.has_reagent(/datum/reagent/gunpowder, charge_size))
			to_chat(user, span_warning("[powder_keg] doesn't have at least 15u of gunpowder to fill [src]!"))
			return
		if(reagents.has_reagent(/datum/reagent/gunpowder, charge_size))
			to_chat(user, span_warning("[src] already contains a full charge of powder! It would be unwise to add more."))
			return
		powder_keg.reagents.trans_id_to(src, /datum/reagent/gunpowder, amount = charge_size)
		to_chat(user, span_notice("You load [src] with a charge of powder from [powder_keg]."))
		return
	if(W.tool_behaviour == TOOL_WRENCH)
		if(default_unfasten_wrench(user, W, time = 2 SECONDS))
			return
	..()
