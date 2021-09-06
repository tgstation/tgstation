/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	inhand_icon_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/weapons/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/flamethrower_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=500)
	resistance_flags = FIRE_PROOF
	trigger_guard = TRIGGER_GUARD_NORMAL
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	var/status = FALSE
	var/lit = FALSE //on or off
	var/operating = FALSE//cooldown
	var/obj/item/weldingtool/weldtool = null
	var/obj/item/assembly/igniter/igniter = null
	var/obj/item/reagent_containers/beaker = null
	var/warned_admins = FALSE //for the message_admins() when lit
	//variables for prebuilt flamethrowers
	var/create_full = FALSE
	var/create_with_tank = FALSE
	var/igniter_type = /obj/item/assembly/igniter
	var/acti_sound = 'sound/items/welderactivate.ogg'
	var/deac_sound = 'sound/items/welderdeactivate.ogg'

/obj/item/flamethrower/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/flamethrower/Destroy()
	if(weldtool)
		QDEL_NULL(weldtool)
	if(igniter)
		QDEL_NULL(igniter)
	if(beaker)
		QDEL_NULL(beaker)
	return ..()

/obj/item/flamethrower/process()
	if(!lit || !igniter)
		STOP_PROCESSING(SSobj, src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.is_holding(src))
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(heat,2)


/obj/item/flamethrower/update_icon_state()
	inhand_icon_state = "flamethrower_[lit]"
	return ..()

/obj/item/flamethrower/update_overlays()
	. = ..()
	if(igniter)
		. += "+igniter[status]"
	if(beaker)
		. += "+ptank"
	if(lit)
		. += "+lit"

/obj/item/flamethrower/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag)
		return // too close
	if(ishuman(user))
		if(!can_trigger_gun(user))
			return
	if(!lit || operating)
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You can't bring yourself to fire \the [src]! You don't want to risk harming anyone...</span>")
		return
	if(user && user.get_active_held_item() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			log_combat(user, target, "flamethrowered", src)
			flame_turf(turflist)

/obj/item/flamethrower/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.forceMove(T)
			weldtool = null
		if(igniter)
			igniter.forceMove(T)
			igniter = null
		if(beaker)
			beaker.forceMove(T)
			beaker = null
		new /obj/item/stack/rods(T)
		qdel(src)
		return

	else if(W.tool_behaviour == TOOL_SCREWDRIVER && igniter && !lit)
		status = !status
		to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
		update_appearance()
		return

	else if(isigniter(W))
		var/obj/item/assembly/igniter/I = W
		if(I.secured)
			return
		if(igniter)
			return
		if(!user.transferItemToLoc(W, src))
			return
		igniter = I
		update_appearance()
		return

	else if(istype(W, /obj/item/reagent_containers) && !(W.item_flags & ABSTRACT) && W.is_open_container())
		if(beaker)
			if(user.transferItemToLoc(W,src))
				beaker.forceMove(get_turf(src))
				beaker = W
				to_chat(user, "<span class='notice'>You swap the fuel container in [src]!</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		beaker = W
		update_appearance()
		return

	else
		return ..()

/obj/item/flamethrower/attack_self(mob/user)
	toggle_igniter(user)

/obj/item/flamethrower/AltClick(mob/user)
	if(beaker && isliving(user) && user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		user.put_in_hands(beaker)
		beaker = null
		to_chat(user, "<span class='notice'>You remove the fuel container from [src]!</span>")
		update_appearance()

/obj/item/flamethrower/examine(mob/user)
	. = ..()
	if(beaker)
		. += "<span class='notice'>\The [src] has \a [beaker] attached. Alt-click to remove it.</span>"

/obj/item/flamethrower/proc/toggle_igniter(mob/user)
	if(!beaker)
		to_chat(user, "<span class='notice'>Attach a fuel container first!</span>")
		return
	if(!status)
		to_chat(user, "<span class='notice'>Secure the igniter first!</span>")
		return
	to_chat(user, "<span class='notice'>You [lit ? "extinguish" : "ignite"] [src]!</span>")
	lit = !lit
	if(lit)
		playsound(loc, acti_sound, 50, TRUE)
		START_PROCESSING(SSobj, src)
		if(!warned_admins)
			message_admins("[ADMIN_LOOKUPFLW(user)] has lit a flamethrower.")
			warned_admins = TRUE
	else
		playsound(loc, deac_sound, 50, TRUE)
		STOP_PROCESSING(SSobj,src)
	set_light_on(lit)
	update_appearance()

/obj/item/flamethrower/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weldingtool) in contents
	igniter = locate(/obj/item/assembly/igniter) in contents
	weldtool.status = FALSE
	igniter.secured = FALSE
	status = TRUE
	update_appearance()

#define REQUIRED_POWER_TO_FIRE_FLAMETHROWER 10
#define FLAMETHROWER_POWER_MULTIPLIER 0.5
#define FLAMETHROWER_RANGE 4

/obj/item/flamethrower/proc/flame_turf(turflist, release_amount = 8, safety = TRUE)
	if(!beaker)
		return
	var/power = 0
	var/datum/reagents/beaker_reagents = beaker.reagents
	var/datum/reagents/my_fraction = new()
	beaker_reagents.trans_to(my_fraction, release_amount, no_react = TRUE)
	power = my_fraction.get_total_accelerant_quality() * FLAMETHROWER_POWER_MULTIPLIER
	if(power < REQUIRED_POWER_TO_FIRE_FLAMETHROWER)
		return
	playsound(src, 'sound/effects/spray.ogg', 10, TRUE, -3)
	operating = TRUE
	var/turfs_flamed = 0
	var/turf/previousturf = get_turf(src)
	for(var/turf/T in turflist)
		if(safety && T == previousturf)
			continue //so we don't burn the tile we be standin on
		var/list/turfs_sharing_with_prev = previousturf.GetAtmosAdjacentTurfs(alldir=1)
		if(!(T in turfs_sharing_with_prev))
			break
		default_ignite(T, power)
		turfs_flamed++
		if(turfs_flamed >= FLAMETHROWER_RANGE)
			break
		sleep(1)
		previousturf = T
	if(!turfs_flamed && beaker)
		my_fraction.trans_to(beaker_reagents, release_amount, no_react = TRUE)
	qdel(my_fraction)
	operating = FALSE

#undef REQUIRED_POWER_TO_FIRE_FLAMETHROWER
#undef FLAMETHROWER_POWER_MULTIPLIER
#undef FLAMETHROWER_RANGE

/obj/item/flamethrower/proc/default_ignite(turf/target, power)
	new /obj/effect/hotspot(target)
	target.hotspot_expose((power*3) + 380,500)
	target.IgniteTurf(power)

/obj/item/flamethrower/Initialize(mapload)
	. = ..()
	if(create_full)
		if(!weldtool)
			weldtool = new /obj/item/weldingtool(src)
		weldtool.status = FALSE
		if(!igniter)
			igniter = new igniter_type(src)
		igniter.secured = FALSE
		status = TRUE
		if(create_with_tank)
			beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
			beaker.reagents.add_reagent(/datum/reagent/fuel, beaker.reagents.maximum_volume)
		update_appearance()
	RegisterSignal(src, COMSIG_ITEM_RECHARGED, .proc/instant_refill)

/obj/item/flamethrower/full
	create_full = TRUE

/obj/item/flamethrower/full/tank
	create_with_tank = TRUE

/obj/item/flamethrower/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/projectile/P = hitby
	if(beaker && damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>\The [attack_text] hits the fuel tank on [owner]'s [name], rupturing it! What a shot!</span>")
		var/turf/target_turf = get_turf(owner)
		log_game("A projectile ([hitby]) detonated a flamethrower tank held by [key_name(owner)] at [COORD(target_turf)]")
		flame_turf(list(get_turf(src)), 100, FALSE)
		QDEL_NULL(beaker)
		return 1 //It hit the flamethrower, not them

/obj/item/flamethrower/proc/instant_refill()
	SIGNAL_HANDLER
	if(!beaker)
		beaker = new /obj/item/reagent_containers/glass/beaker/large(src)
	beaker.reagents.add_reagent(/datum/reagent/fuel, beaker.reagents.total_volume)
	update_appearance()
