/obj/mecha/combat/nerchen
	desc = "Old mecha used back when mechas were deemed a two person required vehicle. The extra plating, internals, and other whathaveyou to make this run have made it extremely tanky."
	name = "\improper Nerchen"
	icon = 'icons/mecha/mecha_tall.dmi'
	icon_state = "nerchen"
	step_in = 3
	dir_in = 2 //Facing South.
	max_integrity = 450 //really tanky
	deflect_chance = 25
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100)
	max_temperature = 25000
	infra_luminosity = 3
	wreckage = /obj/structure/mecha_wreckage/nerchen
	melee_can_hit = FALSE
	add_req_access = 1
	internal_damage_threshold = 25
	var/leaping = FALSE
	var/obj/mecha/combat/chen/chen //keeps the other internal mech in check

/obj/mecha/combat/nerchen/Initialize()
	. = ..()
	chen = new(src, src)
	rebuild_icon()

/obj/mecha/combat/nerchen/obj_destruction()
	chen.Destroy()
	..()
/obj/mecha/combat/nerchen/Destroy()
	chen.Destroy()
	..()

/obj/mecha/combat/nerchen/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Grant(user, src)

/obj/mecha/combat/nerchen/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Remove(user)

//leaping interactions with living mobs and mechas
/obj/mecha/combat/nerchen/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!leaping)
		return ..()
	leaping = FALSE
	rebuild_icon()
	if(ismecha(hit_atom) || isliving(hit_atom))
		var/atom/movable/AM = hit_atom
		var/turf/throwbackwards = get_step(src, turn(dir, 180)) //get the turf behind the mecha
		visible_message("<span class='danger'>[src] throws [AM] over their head, smashing them into [throwbackwards]!")
		if(!isopenturf(throwbackwards))
			AM.forceMove(loc)//prevents them from getting put into a wall
		else
			AM.forceMove(throwbackwards)
			if(isfloorturf(throwbackwards))
				var/turf/open/floor/plating = throwbackwards
				plating.break_tile()
		if(isliving(AM))
			var/mob/living/L = AM
			L.Knockdown(5 SECONDS)
			L.adjustBruteLoss(10) //not meant as a huge damage dealer
		else
			var/obj/mecha/mech = AM //but for mechs it is
			mech.take_damage(50)
			mech.emp_act(EMP_LIGHT)
			for(var/i in 1 to 3)
				mech.spark_system.start()
				sleep(2)

/obj/mecha/combat/nerchen/mmi_move_inside(obj/item/mmi/mmi_as_oc, mob/user) //no cheese
	to_chat(user, "<span class='warning'>There doesn't seem to be any way to interface with the mech!</span>")
	return FALSE

/obj/mecha/combat/nerchen/proc/rebuild_icon() //icon proc, will also reset to arms down (and used as such)
	icon_state = initial(icon_state) //lowers arms
	icon_state += build_cockpit_state()

/obj/mecha/combat/nerchen/proc/build_cockpit_state() //checks which cockpits are open
	. = "-"
	if(occupant)
		. += "closed"
	else
		. += "open"
	. += "-"
	if(chen.occupant)
		. += "closed"
	else
		. += "open"

/obj/mecha/combat/nerchen/moved_inside(mob/living/carbon/human/H)
	. = ..()
	rebuild_icon()

/obj/mecha/combat/nerchen/go_out(forced, atom/newloc = loc)
	..()
	rebuild_icon()

/obj/mecha/combat/nerchen/click_action(atom/target,mob/user,params, chencommand = FALSE)
	if(!chencommand)
		to_chat(occupant, "<span class='warning'>You need to be in the other cockpit to punch!</span>")
		return FALSE

/obj/mecha/combat/nerchen/MouseDrop_T(mob/M, mob/user) //if chen exists, you can enter that instead.
	switch(alert("Which cockpit would you like to enter?","Mecha","Ner (Movement)","Chen (Weapons)", "Cancel"))
		if("Chen (Weapons)")
			chen.MouseDrop_T(M, user)
			return
		if("Cancel")
			return
	..()

/obj/mecha/combat/chen
	desc = "The second seat for the Nerchen."
	name = "Gunner Seat"
	icon_state = "phazon"
	dir_in = 2 //Facing South. not sure if this one matters?
	deflect_chance = 30
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100)
	max_temperature = 25000
	infra_luminosity = 3
	wreckage = null
	add_req_access = 1
	internal_damage_threshold = 25
	force = 15
	max_equip = 3
	var/obj/mecha/combat/nerchen/ner

/obj/mecha/combat/chen/Initialize(mapload, _ner)
	. = ..()
	ner = _ner

/obj/mecha/combat/chen/GrantActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Grant(user, src)
	if(enclosed)
		internals_action.Grant(user, src)
	cycle_action.Grant(user, src)
	stats_action.Grant(user, src)

/obj/mecha/combat/chen/mmi_move_inside(obj/item/mmi/mmi_as_oc, mob/user) //no cheese
	to_chat(user, "<span class='warning'>There doesn't seem to be any way to interface with the mech!</span>")
	return FALSE

/obj/mecha/combat/chen/MouseDrop_T(mob/M, mob/user) //has some differences here and there, with progress bars too
	if((user != M) || user.incapacitated() || !ner.Adjacent(user))
		return
	if(!ishuman(user)) // no silicons or drones in mechas.
		return
	log_message("[user] tries to move in.", LOG_MECHA)
	if (occupant)
		to_chat(usr, "<span class='warning'>The [name] is already occupied!</span>")
		log_message("Permission denied (Occupied).", LOG_MECHA)
		return
	if(dna_lock)
		var/passed = FALSE
		if(user.has_dna())
			var/mob/living/carbon/C = user
			if(C.dna.unique_enzymes==dna_lock)
				passed = TRUE
		if (!passed)
			to_chat(user, "<span class='warning'>Access denied. [name] is secured with a DNA lock.</span>")
			log_message("Permission denied (DNA LOCK).", LOG_MECHA)
			return
	if(!operation_allowed(user))
		to_chat(user, "<span class='warning'>Access denied. Insufficient operation keycodes.</span>")
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return
	if(user.buckled)
		to_chat(user, "<span class='warning'>You are currently buckled and cannot move.</span>")
		log_message("Permission denied (Buckled).", LOG_MECHA)
		return
	if(user.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>You can't enter the exosuit with other creatures attached to you!</span>")
		log_message("Permission denied (Attached mobs).", LOG_MECHA)
		return

	ner.visible_message("<span class='notice'>[user] starts to climb into [name].</span>")

	if(do_after(user, enter_delay, target = ner)) //chen will be where ner is, so this lets the progressbar be shown
		if(obj_integrity <= 0)
			to_chat(user, "<span class='warning'>You cannot get in the [name], it has been destroyed!</span>")
		else if(occupant)
			to_chat(user, "<span class='danger'>[occupant] was faster! Try better next time, loser.</span>")
		else if(user.buckled)
			to_chat(user, "<span class='warning'>You can't enter the exosuit while buckled.</span>")
		else if(user.has_buckled_mobs())
			to_chat(user, "<span class='warning'>You can't enter the exosuit with other creatures attached to you!</span>")
		else
			moved_inside(user)
	else
		to_chat(user, "<span class='warning'>You stop entering the exosuit!</span>")
	return

/obj/mecha/combat/chen/moved_inside(mob/living/carbon/human/H)
	. = ..()
	ner.rebuild_icon()

/obj/mecha/combat/chen/domove(direction)
	to_chat(occupant, "<span class='warning'>You need to be in the other cockpit to move!</span>")
	return FALSE

/obj/mecha/combat/chen/go_out(forced, atom/newloc = ner.loc)
	..()
	ner.rebuild_icon()

/obj/mecha/combat/chen/click_action(atom/target,mob/user,params, chencommand = FALSE)
	ner.click_action(target, user, params, chencommand = TRUE)

#define LEAP_COOLDOWN 30 SECONDS

//action buttons
/datum/action/innate/mecha/leap
	name = "Mecha Leap"
	desc = "Engages the mech into a leap, throwing yourself a fair distance forward. If you collide with a creature or a mech, you will suplex it over yourself."
	button_icon_state = "mech_leap"
	var/leapcooldown = 0 //i know we have a cooldown action but other mecha action buttons have not used it

/datum/action/innate/mecha/leap/Activate(forced_state = null)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(leapcooldown > world.time)
		chassis.occupant_message("<span class='danger'>Thrusters have not recharged yet!</span>")
		return
	var/obj/mecha/combat/nerchen/ner = chassis
	ner.occupant_message("<span class='danger'>Enagaging thrusters for Mecha Leap!</span>")

	//cooldown icon changes
	leapcooldown = world.time + LEAP_COOLDOWN
	var/mutable_appearance/cooldown_redness
	cooldown_redness = cooldown_redness || mutable_appearance('icons/mob/actions/actions_mecha.dmi')
	cooldown_redness.icon_state = "nerchen_cooldown"
	animate(cooldown_redness, alpha = 0, time = LEAP_COOLDOWN)
	button.add_overlay(cooldown_redness)
	ner.leaping = TRUE
	ner.icon_state = "nerchen-leap" + ner.build_cockpit_state()
	ner.throw_at(get_edge_target_turf(ner, ner.dir), 7, 2)
	ner.log_message("Leaped forward (mech threw itself with ability).", LOG_MECHA)

#undef LEAP_COOLDOWN
