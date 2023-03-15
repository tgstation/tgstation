//Created by Pass.
/obj/item/umbral_tendrils
	name = "umbral tendrils"
	desc = "A mass of pulsing, chitonous tendrils with exposed violet flesh."
	force = 15
	icon = 'massmeta/icons/obj/darkspawn_items.dmi'
	icon_state = "umbral_tendrils"
	worn_icon_state= "umbral_tendrils"
	lefthand_file = 'massmeta/icons/mob/inhands/antag/darkspawn_lefthand.dmi'
	righthand_file = 'massmeta/icons/mob/inhands/antag/darkspawn_righthand.dmi'
	hitsound = 'massmeta/sounds/magic/pass_attack.ogg'
	attack_verb_continuous = list("impales", "tentacles", "torns")
	attack_verb_simple = list("impale", "tentacle", "torn")
	item_flags = ABSTRACT | DROPDEL
	var/datum/antagonist/darkspawn/darkspawn
	var/obj/item/umbral_tendrils/twin
	var/ranged_mode = FALSE

/obj/item/umbral_tendrils/Initialize(mapload, new_darkspawn)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	AddComponent(/datum/component/light_eater)
	darkspawn = new_darkspawn
	for(var/obj/item/umbral_tendrils/U in loc)
		if(U != src)
			twin = U
			U.twin = src
			force = 12
			U.force = 12
			U.ranged_mode = ranged_mode

/obj/item/umbral_tendrils/Destroy()
	if(!QDELETED(twin))
		qdel(twin)
	. = ..()

/obj/item/umbral_tendrils/examine(mob/user)
	. = ..()
	if(isobserver(user) || isdarkspawn(user))
		. += "<span class='velvet bold'>Functions:<span>"
		. += span_velvet("<b>Rightclick:</b> Click on an airlock to force it open for 15 Psi (or 30 if it's bolted.)")
		. += span_velvet("The tendrils will break any lights hit in melee,")
		. += span_velvet("The tendrils will shatter light fixtures instantly, as opposed to in several attacks.")
		. += span_velvet("Also functions to pry open depowered airlocks if combat mode is off")
		. += span_velvet("Use [src] inhand to toggle ranged attacks. Ranged attacks are currently [ranged_mode ? "on" : "off"]")
		. += span_velvet("<b>Ranged, combat mode off:</b> Click on an open tile within seven tiles to jump to it for 10 Psi.")
		. += span_velvet("<b>Ranged, combat mode on:</b> Fire a projectile that travels up to five tiles, knocking down[twin ? " and pulling forwards" : ""] the first creature struck.")

/obj/item/umbral_tendrils/attack_self(mob/user)
	ranged_mode = !ranged_mode
	user.balloon_alert(user, "ranged mode [ranged_mode ? "on" : "off"]")

/obj/item/umbral_tendrils/attack(mob/living/target, mob/living/user, twinned_attack = TRUE)
	set waitfor = FALSE
	..()
	sleep(0.1 SECONDS)
	if(twin && twinned_attack && user.Adjacent(target))
		twin.attack(target, user, FALSE)

/obj/item/umbral_tendrils/afterattack(atom/target, mob/living/user, proximity)
	if(!darkspawn)
		return ..()
	if(proximity)
		if(istype(target, /obj/structure/table))
			var/obj/structure/table/T = target
			T.deconstruct(FALSE)
			return
		else if(istype(target, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/opening = target

			if((!opening.requiresID() || opening.allowed(user)) && opening.hasPower()) //This is to prevent stupid shit like hitting a door with an arm blade, the door opening because you have acces and still getting a "the airlocks motors resist our efforts to force it" message, power requirement is so this doesn't stop unpowered doors from being pried open if you have access
				return
			if(opening.locked || opening.welded)
				if(!user.combat_mode)
					opening.balloon_alert(user, "bolted!")
					return
				while(opening.atom_integrity > opening.max_integrity * 0.25 && !QDELETED(src))
					if(twin)
						if(!do_after(user, rand(4, 6), target = opening))
							darkspawn.use_psi(30)
							qdel(src)
							return
					else
						if(!do_after(user, rand(8, 10), target = opening))
							darkspawn.use_psi(30)
							qdel(src)
							return
					playsound(src, 'massmeta/sounds/magic/pass_smash_door.ogg', 50, TRUE)
					opening.take_damage(max_integrity / rand(8, 15))
					to_chat(user, "<span class='velvet bold'>klaj.</span>")
				opening.ex_act(EXPLODE_DEVASTATE)
				user.visible_message("<span class='boldwarning'>[user] slams down [opening]!</span>", "<span class='velvet bold'>KLAJ.</span>")
				darkspawn.use_psi(30)
				qdel(src)
				return

			if(opening.hasPower())
				if(!user.combat_mode) //Don't pry forced without combat mode
					return
				user.visible_message(span_warning("[user] jams [src] into the airlock and starts prying it open!"), span_warning("We start forcing the [opening] open."), \
				span_hear("You hear a metal screeching sound."))
				playsound(opening, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
				if(!twin)
					if(!do_after(user, 75, target = opening))
						return
				else
					if(!do_after(user, 50, target = opening))
						return
				darkspawn.use_psi(15)
			//user.say("Heeeeeeeeeerrre's Johnny!")
			user.visible_message(span_warning("[user] forces the airlock to open with [user.p_their()] [src]!"), span_warning("We force the [opening] to open."), \
			span_hear("You hear a metal screeching sound."))
			opening.open(BYPASS_DOOR_CHECKS)
		// Double hit structures if duality
		if(!QDELETED(target) && (isstructure(target) || ismachinery(target)) && twin && user.get_active_held_item() == src)
			target.attackby(twin, user)
		return ..()

	if(ranged_mode)
		if(!user.combat_mode)
			if(isopenturf(target))
				tendril_jump(user, target)
		if(user.combat_mode)
			tendril_swing(user, target)

/obj/item/umbral_tendrils/proc/tendril_jump(mob/living/user, turf/open/target) //throws the user towards the target turf
	if(!darkspawn.has_psi(10))
		to_chat(user, span_warning("You need at least 10 Psi to jump!"))
		return
	if(!(target in view(7, user)))
		to_chat(user, span_warning("You can't access that area, or it's too far away!"))
		return
	to_chat(user, span_velvet("You pull yourself towards [target]."))
	playsound(user, 'sound/magic/tail_swing.ogg', 10, TRUE)
	user.throw_at(target, 5, 3)
	darkspawn.use_psi(10)

/obj/item/umbral_tendrils/proc/tendril_swing(mob/living/user, mob/living/target) //swing the tendrils to knock someone down
	if(isliving(target) && target.body_position == LYING_DOWN)
		to_chat(user, span_warning("[target] is already knocked down!"))
		return
	user.visible_message(span_warning("[user] draws back [src] and swings them towards [target]!"), \
	span_velvet("<b>opehhjaoo</b><br>You swing your tendrils towards [target]!"))
	playsound(user, 'sound/magic/tail_swing.ogg', 50, TRUE)
	var/obj/projectile/umbral_tendrils/T = new(get_turf(user))
	T.preparePixelProjectile(target, user)
	T.twinned = twin
	T.firer = user
	T.fire()
	qdel(src)

/obj/projectile/umbral_tendrils
	name = "umbral tendrils"
	icon_state = "cursehand0"
	hitsound = 'massmeta/sounds/magic/pass_attack.ogg'
	layer = LARGE_MOB_LAYER
	damage = 0
	knockdown = 40
	speed = 1
	range = 5
	var/twinned = FALSE
	var/beam

/obj/projectile/umbral_tendrils/fire(setAngle)
	beam = firer.Beam(src, icon_state = "curse0", time = INFINITY, maxdistance = INFINITY)
	..()

/obj/projectile/umbral_tendrils/Destroy()
	qdel(beam)
	. = ..()

/obj/projectile/umbral_tendrils/on_hit(atom/movable/target, blocked = FALSE)
	if(blocked >= 100)
		return
	. = TRUE
	if(isliving(target))
		var/mob/living/L = target
		if(!iscyborg(target))
			playsound(target, 'massmeta/sounds/magic/pass_attack.ogg', 50, TRUE)
			if(!twinned)
				target.visible_message(span_warning("[firer]'s [name] slam into [target], knocking them off their feet!"), \
				span_userdanger("You're knocked off your feet!"))
				L.Knockdown(6 SECONDS)
			else
				L.Immobilize(0.15 SECONDS) // so they cant cancel the throw by moving
				target.throw_at(get_step_towards(firer, target), 7, 2) //pull them towards us!
				target.visible_message(span_warning("[firer]'s [name] slam into [target] and drag them across the ground!"), \
				span_userdanger("You're suddenly dragged across the floor!"))
				L.Knockdown(8 SECONDS) //these can't hit people who are already on the ground but they can be spammed to all shit
				addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, target, 'massmeta/sounds/magic/pass_attack.ogg', 50, TRUE), 1)
		else
			var/mob/living/silicon/robot/R = target
			R.toggle_headlamp(TRUE) //disable headlamps
			target.visible_message(span_warning("[firer]'s [name] smashes into [target]'s chassis!"), \
			span_userdanger("Heavy percussive impact detected. Recalibrating motor input."))
			R.playsound_local(target, 'sound/misc/interference.ogg', 25, FALSE)
			playsound(R, 'sound/effects/bang.ogg', 50, TRUE)
			R.Paralyze(40) //this is the only real anti-borg spell  get
			R.adjustBruteLoss(10)

