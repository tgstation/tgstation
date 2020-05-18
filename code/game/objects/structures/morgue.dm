/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue tray
 *		Crematorium
 *		Crematorium tray
 *		Crematorium button
 */

/*
 * Bodycontainer
 * Parent class for morgue and crematorium
 * For overriding only
 */
GLOBAL_LIST_EMPTY(bodycontainers) //Let them act as spawnpoints for revenants and other ghosties.

/obj/structure/bodycontainer
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = TRUE
	anchored = TRUE
	max_integrity = 400

	var/obj/structure/tray/connected = null
	var/locked = FALSE
	dir = SOUTH
	var/message_cooldown
	var/breakout_time = 600

/obj/structure/bodycontainer/Initialize()
	. = ..()
	GLOB.bodycontainers += src
	recursive_organ_check(src)

/obj/structure/bodycontainer/Destroy()
	GLOB.bodycontainers -= src
	open()
	if(connected)
		qdel(connected)
		connected = null
	return ..()

/obj/structure/bodycontainer/on_log(login)
	..()
	update_icon()

/obj/structure/bodycontainer/update_icon()
	return

/obj/structure/bodycontainer/relaymove(mob/user)
	if(user.stat || !isturf(loc))
		return
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
		return
	open()

/obj/structure/bodycontainer/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/bodycontainer/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(locked)
		to_chat(user, "<span class='danger'>It's locked.</span>")
		return
	if(!connected)
		to_chat(user, "That doesn't appear to have a tray.")
		return
	if(connected.loc == src)
		open()
	else
		close()
	add_fingerprint(user)

/obj/structure/bodycontainer/attack_robot(mob/user)
	if(!user.Adjacent(src))
		return
	return attack_hand(user)

/obj/structure/bodycontainer/attackby(obj/P, mob/user, params)
	add_fingerprint(user)
	if(istype(P, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, "<span class='notice'>You scribble illegibly on the side of [src]!</span>")
			return
		var/t = stripped_input(user, "What would you like the label to be?", text("[]", name), null)
		if (user.get_active_held_item() != P)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if (t)
			name = text("[]- '[]'", initial(name), t)
		else
			name = initial(name)
	else
		return ..()

/obj/structure/bodycontainer/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 5)
	recursive_organ_check(src)
	qdel(src)

/obj/structure/bodycontainer/container_resist(mob/living/user)
	if(!locked)
		open()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(null, \
		"<span class='notice'>You lean on the back of [src] and start pushing the tray open... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='hear'>You hear a metallic creaking from [src].</span>")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src )
			return
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open()

/obj/structure/bodycontainer/proc/open()
	recursive_organ_check(src)
	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
	playsound(src, 'sound/effects/roll.ogg', 5, TRUE)
	var/turf/T = get_step(src, dir)
	connected.setDir(dir)
	for(var/atom/movable/AM in src)
		AM.forceMove(T)
	update_icon()

/obj/structure/bodycontainer/proc/close()
	playsound(src, 'sound/effects/roll.ogg', 5, TRUE)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	for(var/atom/movable/AM in connected.loc)
		if(!AM.anchored || AM == connected)
			if(ismob(AM) && !isliving(AM))
				continue
			AM.forceMove(src)
	recursive_organ_check(src)
	update_icon()

/obj/structure/bodycontainer/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 2)
/*
 * Morgue
 */
/obj/structure/bodycontainer/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them. Now includes a high-tech alert system."
	icon_state = "morgue1"
	dir = EAST
	var/beeper = TRUE
	var/beep_cooldown = 50
	var/next_beep = 0

/obj/structure/bodycontainer/morgue/Initialize()
	. = ..()
	connected = new/obj/structure/tray/m_tray(src)
	connected.connected = src

/obj/structure/bodycontainer/morgue/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The speaker is [beeper ? "enabled" : "disabled"]. Alt-click to toggle it.</span>"

/obj/structure/bodycontainer/morgue/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	beeper = !beeper
	to_chat(user, "<span class='notice'>You turn the speaker function [beeper ? "on" : "off"].</span>")

/obj/structure/bodycontainer/morgue/update_icon()
	if (!connected || connected.loc != src) // Open or tray is gone.
		icon_state = "morgue0"
	else
		if(contents.len == 1)  // Empty
			icon_state = "morgue1"
		else
			icon_state = "morgue2" // Dead, brainded mob.
			var/list/compiled = GetAllContents(/mob/living) // Search for mobs in all contents.
			if(!length(compiled)) // No mobs?
				icon_state = "morgue3"
				return

			for(var/mob/living/M in compiled)
				var/mob/living/mob_occupant = get_mob_or_brainmob(M)
				if(mob_occupant.client && !mob_occupant.suiciding && !(HAS_TRAIT(mob_occupant, TRAIT_BADDNA)) && !mob_occupant.hellbound)
					icon_state = "morgue4" // Revivable
					if(mob_occupant.stat == DEAD && beeper)
						if(world.time > next_beep)
							playsound(src, 'sound/weapons/gun/general/empty_alarm.ogg', 50, FALSE) //Revive them you blind fucks
							next_beep = world.time + beep_cooldown
					break


/obj/item/paper/guides/jobs/medical/morgue
	name = "morgue memo"
	info = "<font size='2'>Since this station's medbay never seems to fail to be staffed by the mindless monkeys meant for genetics experiments, I'm leaving a reminder here for anyone handling the pile of cadavers the quacks are sure to leave.</font><BR><BR><font size='4'><font color=red>Red lights mean there's a plain ol' dead body inside.</font><BR><BR><font color=orange>Yellow lights mean there's non-body objects inside.</font><BR><font size='2'>Probably stuff pried off a corpse someone grabbed, or if you're lucky it's stashed booze.</font><BR><BR><font color=green>Green lights mean the morgue system detects the body may be able to be brought back to life.</font></font><BR><font size='2'>I don't know how that works, but keep it away from the kitchen and go yell at the geneticists.</font><BR><BR>- CentCom medical inspector"

/*
 * Crematorium
 */
GLOBAL_LIST_EMPTY(crematoriums)
/obj/structure/bodycontainer/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbecue nights."
	icon_state = "crema1"
	dir = SOUTH
	///If the crematorium is currently cremating its contents
	var/cremating = FALSE
	///Checks if this is currently the first tick of cremation, used to avoid repeating ceratin logs and actions
	var/first_cremation_tick = TRUE
	///Last user to turn on the crematorium
	var/last_user = null
	var/id = 1

/obj/structure/bodycontainer/crematorium/attack_robot(mob/user) //Borgs can't use crematoriums without help
	to_chat(user, "<span class='warning'>[src] is locked against you.</span>")
	return

/obj/structure/bodycontainer/crematorium/Destroy()
	GLOB.crematoriums.Remove(src)
	return ..()

/obj/structure/bodycontainer/crematorium/New()
	GLOB.crematoriums.Add(src)
	..()

/obj/structure/bodycontainer/crematorium/Initialize()
	. = ..()
	connected = new /obj/structure/tray/c_tray(src)
	connected.connected = src

/obj/structure/bodycontainer/crematorium/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	id = "[idnum][id]"

/obj/structure/bodycontainer/crematorium/update_icon()
	if(!connected || connected.loc != src)
		icon_state = "crema0"
	else

		if(src.contents.len > 1)
			src.icon_state = "crema2"
		else
			src.icon_state = "crema1"

		if(cremating)
			src.icon_state = "crema_active"

	return

/obj/structure/bodycontainer/crematorium/process()
	if(cremating)
		cremate()

///Toggles cremation. The cremate parameter can be used to set a specific value instead of toggling.
/obj/structure/bodycontainer/crematorium/proc/toggle_cremation(set_cremate, mob/user)
	if(cremating && set_cremate != TRUE)
		cremating = FALSE
		locked = FALSE
		STOP_PROCESSING(SSobj, src)
		update_icon()

		audible_message("<span class='hear'>You hear a roar as [src] activates.</span>")
		return
	if(!cremating && set_cremate != FALSE)
		if(user)
			last_user = user
		else
			last_user = null //let's not blame the previous guy
		cremating = TRUE
		first_cremation_tick = TRUE
		locked = TRUE
		START_PROCESSING(SSobj, src)
		update_icon()

		audible_message("<span class='hear'>The roar of [src]'s flames gradually dies down.</span>")
		return

///Ignites and causes heavy burn damage to mobs and objects inside. Non-immune mobs will quickly be incinerated.
/obj/structure/bodycontainer/crematorium/proc/cremate()
	if(!cremating)
		return
	// Make sure we don't burn the actual morgue and its tray
	var/list/conts = GetAllContents() - src - connected
	for(var/mob/living/L in conts)
		if(first_cremation_tick)
			if(L.stat != DEAD)
				L.emote("scream")
			if(last_user)
				log_combat(last_user, L, "cremated")
			else
				L.log_message("was cremated", LOG_ATTACK)

		L.apply_damage(90, BURN, spread_damage = TRUE)
		L.adjust_fire_stacks(10)
		L.IgniteMob()

		//Artificially speed up the cremation process
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			C.adjust_cremation(25)

	for(var/obj/O in conts) //conts defined above, ignores crematorium and tray
		O.fire_act()
		O.take_damage(50, BURN, null, FALSE)

	first_cremation_tick = FALSE

/*
 * Generic Tray
 * Parent class for morguetray and crematoriumtray
 * For overriding only
 */
/obj/structure/tray
	icon = 'icons/obj/stationobjs.dmi'
	density = TRUE
	var/obj/structure/bodycontainer/connected = null
	anchored = TRUE
	pass_flags = LETPASSTHROW
	max_integrity = 350

/obj/structure/tray/Destroy()
	if(connected)
		connected.connected = null
		connected.update_icon()
		connected = null
	return ..()

/obj/structure/tray/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/structure/tray/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/tray/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if (src.connected)
		connected.close()
		add_fingerprint(user)
	else
		to_chat(user, "<span class='warning'>That's not connected to anything!</span>")

/obj/structure/tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user)
	if(!ismovable(O) || O.anchored || !Adjacent(user) || !user.Adjacent(O) || O.loc == user)
		return
	if(!ismob(O))
		if(!istype(O, /obj/structure/closet/body_bag))
			return
	else
		var/mob/M = O
		if(M.buckled)
			return
	if(!ismob(user) || user.incapacitated())
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	O.forceMove(src.loc)
	if (user != O)
		visible_message("<span class='warning'>[user] stuffs [O] into [src].</span>")
	return

/*
 * Crematorium tray
 */
/obj/structure/tray/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon_state = "cremat"

/*
 * Morgue tray
 */
/obj/structure/tray/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon_state = "morguet"

/obj/structure/tray/m_tray/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE

/obj/structure/tray/m_tray/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovable(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSTABLE)
