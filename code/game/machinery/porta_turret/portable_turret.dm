#define TURRET_STUN 0
#define TURRET_LETHAL 1

#define POPUP_ANIM_TIME 5
#define POPDOWN_ANIM_TIME 5 //Be sure to change the icon animation at the same time or it'll look bad

/obj/machinery/porta_turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	anchored = TRUE
	layer = OBJ_LAYER
	invisibility = INVISIBILITY_OBSERVER	//the turret is invisible if it's inside its cover
	density = TRUE
	use_power = IDLE_POWER_USE				//this turret uses and requires power
	idle_power_usage = 50		//when inactive, this turret takes up constant 50 Equipment power
	active_power_usage = 300	//when active, this turret takes up constant 300 Equipment power
	req_access = list(ACCESS_SECURITY)
	power_channel = EQUIP	//drains power from the EQUIPMENT channel

	var/base_icon_state = "standard"

	var/emp_vunerable = 1 // Can be empd

	var/scan_range = 7
	var/atom/base = null //for turrets inside other objects

	var/raised = 0			//if the turret cover is "open" and the turret is raised
	var/raising= 0			//if the turret is currently opening or closing its cover

	max_integrity = 160		//the turret's health
	integrity_failure = 80
	armor = list(melee = 50, bullet = 30, laser = 30, energy = 30, bomb = 30, bio = 0, rad = 0, fire = 90, acid = 90)

	var/locked = TRUE			//if the turret's behaviour control access is locked
	var/controllock = 0		//if the turret responds to control panels

	var/installation = /obj/item/gun/energy/e_gun/turret		//the type of weapon installed by default
	var/obj/item/gun/stored_gun = null
	var/gun_charge = 0		//the charge of the gun when retrieved from wreckage

	var/mode = TURRET_STUN

	var/stun_projectile = null		//stun mode projectile type
	var/stun_projectile_sound
	var/lethal_projectile = null	//lethal mode projectile type
	var/lethal_projectile_sound

	var/reqpower = 500		//power needed per shot
	var/always_up = 0		//Will stay active
	var/has_cover = 1		//Hides the cover

	var/obj/machinery/porta_turret_cover/cover = null	//the cover that is covering this turret

	var/last_fired = 0		//world.time the turret last fired
	var/shot_delay = 15		//ticks until next shot (1.5 ?)


	var/check_records = 1	//checks if it can use the security records
	var/criminals = 1		//checks if it can shoot people on arrest
	var/auth_weapons = 0	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/stun_all = 0		//if this is active, the turret shoots everything that isn't security or head of staff
	var/check_anomalies = 1	//checks if it can shoot at unidentified lifeforms (ie xenos)

	var/attacked = 0		//if set to 1, the turret gets pissed off and shoots at people nearby (unless they have sec access!)

	var/on = TRUE				//determines if the turret is on

	var/faction = "turret" // Same faction mobs will never be shot at, no matter the other settings

	var/datum/effect_system/spark_spread/spark_system	//the spark system, used for generating... sparks?

	var/obj/machinery/turretid/cp = null

/obj/machinery/porta_turret/Initialize()
	. = ..()
	if(!base)
		base = src
	update_icon()
	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	setup()
	if(has_cover)
		cover = new /obj/machinery/porta_turret_cover(loc)
		cover.parent_turret = src
		var/mutable_appearance/base = mutable_appearance('icons/obj/turrets.dmi', "basedark")
		base.layer = NOT_HIGH_OBJ_LAYER
		underlays += base
	if(!has_cover)
		INVOKE_ASYNC(src, .proc/popUp)

/obj/machinery/porta_turret/update_icon()
	cut_overlays()
	if(!anchored)
		icon_state = "turretCover"
		return
	if(stat & BROKEN)
		icon_state = "[base_icon_state]_broken"
	else
		if(powered())
			if(on && raised)
				switch(mode)
					if(TURRET_STUN)
						icon_state = "[base_icon_state]_stun"
					if(TURRET_LETHAL)
						icon_state = "[base_icon_state]_lethal"
			else
				icon_state = "[base_icon_state]_off"
		else
			icon_state = "[base_icon_state]_unpowered"


/obj/machinery/porta_turret/proc/setup(obj/item/gun/turret_gun)
	if(stored_gun)
		qdel(stored_gun)
		stored_gun = null

	if(installation && !turret_gun)
		stored_gun = new installation(src)
	else if (turret_gun)
		stored_gun = turret_gun

	var/list/gun_properties = stored_gun.get_turret_properties()

	//required properties
	stun_projectile = gun_properties["stun_projectile"]
	stun_projectile_sound = gun_properties["stun_projectile_sound"]
	lethal_projectile = gun_properties["lethal_projectile"]
	lethal_projectile_sound = gun_properties["lethal_projectile_sound"]
	base_icon_state = gun_properties["base_icon_state"]

	//optional properties
	if(gun_properties["shot_delay"])
		shot_delay = gun_properties["shot_delay"]
	if(gun_properties["reqpower"])
		reqpower = gun_properties["reqpower"]

	update_icon()
	return gun_properties

/obj/machinery/porta_turret/Destroy()
	//deletes its own cover with it
	QDEL_NULL(cover)
	base = null
	if(cp)
		cp.turrets -= src
		cp = null
	QDEL_NULL(stored_gun)
	QDEL_NULL(spark_system)
	return ..()


/obj/machinery/porta_turret/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/porta_turret/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	interact(user)

/obj/machinery/porta_turret/interact(mob/user)
	var/dat
	dat += "Status: <a href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</a><br>"
	dat += "Behaviour controls are [locked ? "locked" : "unlocked"]<br>"

	if(!locked)
		dat += "Check for Weapon Authorization: <A href='?src=\ref[src];operation=authweapon'>[auth_weapons ? "Yes" : "No"]</A><BR>"
		dat += "Check Security Records: <A href='?src=\ref[src];operation=checkrecords'>[check_records ? "Yes" : "No"]</A><BR>"
		dat += "Neutralize Identified Criminals: <A href='?src=\ref[src];operation=shootcrooks'>[criminals ? "Yes" : "No"]</A><BR>"
		dat += "Neutralize All Non-Security and Non-Command Personnel: <A href='?src=\ref[src];operation=shootall'>[stun_all ? "Yes" : "No"]</A><BR>"
		dat += "Neutralize All Unidentified Life Signs: <A href='?src=\ref[src];operation=checkxenos'>[check_anomalies ? "Yes" : "No"]</A><BR>"

	var/datum/browser/popup = new(user, "autosec", "Automatic Portable Turret Installation", 300, 300)
	popup.set_content(dat)
	popup.open()

/obj/machinery/porta_turret/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["power"] && !locked)
		if(anchored)	//you can't turn a turret on/off if it's not anchored/secured
			on = !on	//toggle on/off
		else
			to_chat(usr, "<span class='notice'>It has to be secured first!</span>")
		interact(usr)
		return

	if(href_list["operation"])
		switch(href_list["operation"])	//toggles customizable behavioural protocols
			if("authweapon")
				auth_weapons = !auth_weapons
			if("checkrecords")
				check_records = !check_records
			if("shootcrooks")
				criminals = !criminals
			if("shootall")
				stun_all = !stun_all
			if("checkxenos")
				check_anomalies = !check_anomalies
		interact(usr)

/obj/machinery/porta_turret/power_change()
	if(!anchored)
		update_icon()
		return
	if(stat & BROKEN)
		update_icon()
	else
		if( powered() )
			stat &= ~NOPOWER
			update_icon()
		else
			spawn(rand(0, 15))
				stat |= NOPOWER
				update_icon()


/obj/machinery/porta_turret/attackby(obj/item/I, mob/user, params)
	if(stat & BROKEN)
		if(istype(I, /obj/item/crowbar))
			//If the turret is destroyed, you can remove it with a crowbar to
			//try and salvage its components
			to_chat(user, "<span class='notice'>You begin prying the metal coverings off...</span>")
			if(do_after(user, 20*I.toolspeed, target = src))
				if(prob(70))
					if(stored_gun)
						stored_gun.forceMove(loc)
					to_chat(user, "<span class='notice'>You remove the turret and salvage some components.</span>")
					if(prob(50))
						new /obj/item/stack/sheet/metal(loc, rand(1,4))
					if(prob(50))
						new /obj/item/device/assembly/prox_sensor(loc)
				else
					to_chat(user, "<span class='notice'>You remove the turret but did not manage to salvage anything.</span>")
				qdel(src)

	else if((istype(I, /obj/item/wrench)) && (!on))
		if(raised)
			return

		//This code handles moving the turret around. After all, it's a portable turret!
		if(!anchored && !isinspace())
			anchored = TRUE
			invisibility = INVISIBILITY_MAXIMUM
			update_icon()
			to_chat(user, "<span class='notice'>You secure the exterior bolts on the turret.</span>")
			if(has_cover)
				cover = new /obj/machinery/porta_turret_cover(loc) //create a new turret. While this is handled in process(), this is to workaround a bug where the turret becomes invisible for a split second
				cover.parent_turret = src //make the cover's parent src
		else if(anchored)
			anchored = FALSE
			to_chat(user, "<span class='notice'>You unsecure the exterior bolts on the turret.</span>")
			update_icon()
			invisibility = 0
			qdel(cover) //deletes the cover, and the turret instance itself becomes its own cover.

	else if(I.GetID())
		//Behavior lock/unlock mangement
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
		else
			to_chat(user, "<span class='notice'>Access denied.</span>")
	else if(istype(I, /obj/item/device/multitool) && !locked)
		var/obj/item/device/multitool/M = I
		M.buffer = src
		to_chat(user, "<span class='notice'>You add [src] to multitool buffer.</span>")
	else
		return ..()

/obj/machinery/porta_turret/emag_act(mob/user)
	if(emagged)
		return
	to_chat(user, "<span class='warning'>You short out [src]'s threat assessment circuits.</span>")
	visible_message("[src] hums oddly...")
	emagged = TRUE
	controllock = 1
	on = FALSE //turns off the turret temporarily
	update_icon()
	sleep(60) //6 seconds for the traitor to gtfo of the area before the turret decides to ruin his shit
	on = TRUE //turns it back on. The cover popUp() popDown() are automatically called in process(), no need to define it here


/obj/machinery/porta_turret/emp_act(severity)
	if(on && emp_vunerable)
		//if the turret is on, the EMP no matter how severe disables the turret for a while
		//and scrambles its settings, with a slight chance of having an emag effect
		check_records = pick(0, 1)
		criminals = pick(0, 1)
		auth_weapons = pick(0, 1)
		stun_all = pick(0, 0, 0, 0, 1)	//stun_all is a pretty big deal, so it's least likely to get turned on

		on=0
		spawn(rand(60,600))
			if(!on)
				on=1

	..()

/obj/machinery/porta_turret/take_damage(damage, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(.) //damage received
		if(prob(30))
			spark_system.start()
		if(on && !attacked && !emagged)
			attacked = TRUE
			addtimer(CALLBACK(src, .proc/reset_attacked), 60)

/obj/machinery/porta_turret/proc/reset_attacked()
	attacked = FALSE

/obj/machinery/porta_turret/deconstruct(disassembled = TRUE)
	qdel(src)

/obj/machinery/porta_turret/obj_break(damage_flag)
	if(!(flags_1 & NODECONSTRUCT_1) && !(stat & BROKEN))
		stat |= BROKEN	//enables the BROKEN bit
		update_icon()
		invisibility = 0
		spark_system.start()	//creates some sparks because they look cool
		qdel(cover)	//deletes the cover - no need on keeping it there!



/obj/machinery/porta_turret/process()
	//the main machinery process
	set background = BACKGROUND_ENABLED

	if(cover == null && anchored)	//if it has no cover and is anchored
		if(stat & BROKEN)	//if the turret is borked
			qdel(cover)	//delete its cover, assuming it has one. Workaround for a pesky little bug
		else
			if(has_cover)
				cover = new /obj/machinery/porta_turret_cover(loc)	//if the turret has no cover and is anchored, give it a cover
				cover.parent_turret = src	//assign the cover its parent_turret, which would be this (src)

	if(stat & (NOPOWER|BROKEN))
		if(!always_up)
			//if the turret has no power or is broken, make the turret pop down if it hasn't already
			popDown()
		return

	if(!on)
		if(!always_up)
			//if the turret is off, make it pop down
			popDown()
		return

	var/list/targets = list()
	var/static/things_to_scan = typecacheof(list(/mob/living, /obj/mecha))

	for(var/A in typecache_filter_list(view(scan_range, base), things_to_scan))
		var/atom/AA = A

		if(AA.invisibility > SEE_INVISIBLE_LIVING)
			continue

		if(check_anomalies)//if it's set to check for simple animals
			if(isanimal(A))
				var/mob/living/simple_animal/SA = A
				if(SA.stat || in_faction(SA)) //don't target if dead or in faction
					continue
				targets += SA

		if(iscarbon(A))
			var/mob/living/carbon/C = A
			//If not emagged, only target non downed carbons
			if(mode != TURRET_LETHAL && (C.stat || C.handcuffed || C.lying))
				continue

			//If emagged, target all but dead carbons
			if(mode == TURRET_LETHAL && C.stat == DEAD)
				continue

			//if the target is a human and not in our faction, analyze threat level
			if(ishuman(C) && !in_faction(C))
				if(assess_perp(C) >= 4)
					targets += C

			else if(check_anomalies) //non humans who are not simple animals (xenos etc)
				if(!in_faction(C))
					targets += C

		if(istype(A, /obj/mecha))
			var/obj/mecha/M = A
			//If there is a user and they're not in our faction
			if(M.occupant && !in_faction(M.occupant))
				if(assess_perp(M.occupant) >= 4)
					targets += M

	if(!tryToShootAt(targets))
		if(!always_up)
			popDown() // no valid targets, close the cover

/obj/machinery/porta_turret/proc/tryToShootAt(list/atom/movable/targets)
	while(targets.len > 0)
		var/atom/movable/M = pick(targets)
		targets -= M
		if(target(M))
			return 1


/obj/machinery/porta_turret/proc/popUp()	//pops the turret up
	if(!anchored)
		return
	if(raising || raised)
		return
	if(stat & BROKEN)
		return
	invisibility = 0
	raising = 1
	if(cover)
		flick("popup", cover)
	sleep(POPUP_ANIM_TIME)
	raising = 0
	if(cover)
		cover.icon_state = "openTurretCover"
	raised = 1
	layer = MOB_LAYER

/obj/machinery/porta_turret/proc/popDown()	//pops the turret down
	if(raising || !raised)
		return
	if(stat & BROKEN)
		return
	layer = OBJ_LAYER
	raising = 1
	if(cover)
		flick("popdown", cover)
	sleep(POPDOWN_ANIM_TIME)
	raising = 0
	if(cover)
		cover.icon_state = "turretCover"
	raised = 0
	invisibility = 2
	update_icon()

/obj/machinery/porta_turret/proc/assess_perp(mob/living/carbon/human/perp)
	var/threatcount = 0	//the integer returned

	if(emagged)
		return 10	//if emagged, always return 10.

	if((stun_all || attacked) && !allowed(perp))
		//if the turret has been attacked or is angry, target all non-sec people
		if(!allowed(perp))
			return 10

	if(auth_weapons)	//check for weapon authorization
		if(isnull(perp.wear_id) || istype(perp.wear_id.GetID(), /obj/item/card/id/syndicate))

			if(allowed(perp)) //if the perp has security access, return 0
				return 0

			if(perp.is_holding_item_of_type(/obj/item/gun) ||  perp.is_holding_item_of_type(/obj/item/melee/baton))
				threatcount += 4

			if(istype(perp.belt, /obj/item/gun) || istype(perp.belt, /obj/item/melee/baton))
				threatcount += 2

	if(check_records)	//if the turret can check the records, check if they are set to *Arrest* on records
		var/perpname = perp.get_face_name(perp.get_id_name())
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(!R || (R.fields["criminal"] == "*Arrest*"))
			threatcount += 4

	return threatcount


/obj/machinery/porta_turret/proc/in_faction(mob/target)
	if(!(faction in target.faction))
		return 0
	return 1

/obj/machinery/porta_turret/proc/target(atom/movable/target)
	if(target)
		popUp()				//pop the turret up if it's not already up.
		setDir(get_dir(base, target))//even if you can't shoot, follow the target
		shootAt(target)
		return 1
	return

/obj/machinery/porta_turret/proc/shootAt(atom/movable/target)
	if(!raised) //the turret has to be raised in order to fire - makes sense, right?
		return

	if(!emagged)	//if it hasn't been emagged, cooldown before shooting again
		if(last_fired + shot_delay > world.time)
			return
		last_fired = world.time

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return

	update_icon()
	var/obj/item/projectile/A
	//any emagged turrets drains 2x power and uses a different projectile?
	if(mode == TURRET_STUN)
		use_power(reqpower)
		A = new stun_projectile(T)
		playsound(loc, stun_projectile_sound, 75, 1)
	else
		use_power(reqpower * 2)
		A = new lethal_projectile(T)
		playsound(loc, lethal_projectile_sound, 75, 1)


	//Shooting Code:
	A.original = target
	A.starting = T
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.fire()
	return A


/obj/machinery/porta_turret/proc/setState(on, mode)
	if(controllock)
		return
	src.on = on
	src.mode = mode
	power_change()

/obj/machinery/porta_turret/stationary //is this even used anywhere
	mode = TURRET_LETHAL
	emagged = TRUE
	installation = /obj/item/gun/energy/laser

/obj/machinery/porta_turret/syndicate
	installation = null
	always_up = 1
	use_power = NO_POWER_USE
	has_cover = 0
	scan_range = 9
	req_access = list(ACCESS_SYNDICATE)
	stun_projectile = /obj/item/projectile/bullet
	lethal_projectile = /obj/item/projectile/bullet
	lethal_projectile_sound = 'sound/weapons/gunshot.ogg'
	stun_projectile_sound = 'sound/weapons/gunshot.ogg'
	icon_state = "syndie_off"
	base_icon_state = "syndie"
	faction = "syndicate"
	emp_vunerable = 0

/obj/machinery/porta_turret/syndicate/energy
	icon_state = "standard_stun"
	base_icon_state = "standard"
	stun_projectile = /obj/item/projectile/energy/electrode
	stun_projectile_sound = 'sound/weapons/taser.ogg'
	lethal_projectile = /obj/item/projectile/beam/laser/heavylaser
	lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/machinery/porta_turret/syndicate/setup()
	return

/obj/machinery/porta_turret/syndicate/assess_perp(mob/living/carbon/human/perp)
	return 10 //Syndicate turrets shoot everything not in their faction

/obj/machinery/porta_turret/syndicate/pod
	integrity_failure = 20
	max_integrity = 40
	stun_projectile = /obj/item/projectile/bullet/syndicate_turret
	lethal_projectile = /obj/item/projectile/bullet/syndicate_turret

/obj/machinery/porta_turret/ai
	faction = "silicon"

/obj/machinery/porta_turret/ai/assess_perp(mob/living/carbon/human/perp)
	return 10 //AI turrets shoot at everything not in their faction

/obj/machinery/porta_turret/aux_base
	name = "perimeter defense turret"
	desc = "A plasma beam turret calibrated to defend outposts against non-humanoid fauna. It is more effective when exposed to the environment."
	installation = null
	lethal_projectile = /obj/item/projectile/plasma/turret
	lethal_projectile_sound = 'sound/weapons/plasma_cutter.ogg'
	mode = TURRET_LETHAL //It would be useless in stun mode anyway
	faction = "neutral" //Minebots, medibots, etc that should not be shot.

/obj/machinery/porta_turret/aux_base/assess_perp(mob/living/carbon/human/perp)
	return 0 //Never shoot humanoids. You are on your own if Ashwalkers or the like attack!

/obj/machinery/porta_turret/aux_base/setup()
	return

/obj/machinery/porta_turret/aux_base/interact(mob/user) //Controlled solely from the base console.
	return

/obj/machinery/porta_turret/aux_base/Initialize()
	. = ..()
	cover.name = name
	cover.desc = desc

/obj/machinery/porta_turret/centcom_shuttle
	installation = null
	max_integrity = 260
	always_up = 1
	use_power = NO_POWER_USE
	has_cover = 0
	scan_range = 9
	stun_projectile = /obj/item/projectile/beam/laser
	lethal_projectile = /obj/item/projectile/beam/laser
	lethal_projectile_sound = 'sound/weapons/plasma_cutter.ogg'
	stun_projectile_sound = 'sound/weapons/plasma_cutter.ogg'
	icon_state = "syndie_off"
	base_icon_state = "syndie"
	faction = "turret"
	emp_vunerable = 0
	mode = TURRET_LETHAL

/obj/machinery/porta_turret/centcom_shuttle/assess_perp(mob/living/carbon/human/perp)
	return 0

/obj/machinery/porta_turret/centcom_shuttle/setup()
	return

////////////////////////
//Turret Control Panel//
////////////////////////

/obj/machinery/turretid
	name = "turret control panel"
	desc = "Used to control a room's automated defenses."
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control_standby"
	anchored = TRUE
	density = FALSE
	var/enabled = 1
	var/lethal = 0
	var/locked = TRUE
	var/control_area = null //can be area name, path or nothing.
	var/ailock = 0 // AI cannot use this
	req_access = list(ACCESS_AI_UPLOAD)
	var/list/obj/machinery/porta_turret/turrets = list()
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/turretid/Initialize(mapload, ndir = 0, built = 0)
	. = ..()
	if(built)
		setDir(ndir)
		locked = FALSE
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
	power_change() //Checks power and initial settings

/obj/machinery/turretid/Destroy()
	turrets.Cut()
	return ..()

/obj/machinery/turretid/Initialize(mapload) //map-placed turrets autolink turrets
	. = ..()
	if(!mapload)
		return

	if(control_area)
		control_area = get_area_instance_from_text(control_area)
		if(control_area == null)
			control_area = get_area(src)
			stack_trace("Bad control_area path for [src], [src.control_area]")
	else if(!control_area)
		control_area = get_area(src)

	for(var/obj/machinery/porta_turret/T in control_area)
		turrets |= T
		T.cp = src

/obj/machinery/turretid/attackby(obj/item/I, mob/user, params)
	if(stat & BROKEN)
		return

	if (istype(I, /obj/item/device/multitool))
		var/obj/item/device/multitool/M = I
		if(M.buffer && istype(M.buffer, /obj/machinery/porta_turret))
			turrets |= M.buffer
			to_chat(user, "You link \the [M.buffer] with \the [src]")
			return

	if (issilicon(user))
		return attack_hand(user)

	if ( get_dist(src, user) == 0 )		// trying to unlock the interface
		if (allowed(usr))
			if(emagged)
				to_chat(user, "<span class='notice'>The turret control is unresponsive.</span>")
				return

			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the panel.</span>")
			if (locked)
				if (user.machine==src)
					user.unset_machine()
					user << browse(null, "window=turretid")
			else
				if (user.machine==src)
					src.attack_hand(user)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/machinery/turretid/emag_act(mob/user)
	if(emagged)
		return
	to_chat(user, "<span class='danger'>You short out the turret controls' access analysis module.</span>")
	emagged = TRUE
	locked = FALSE
	if(user && user.machine == src)
		attack_hand(user)

/obj/machinery/turretid/attack_ai(mob/user)
	if(!ailock || IsAdminGhost(user))
		return attack_hand(user)
	else
		to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")

/obj/machinery/turretid/attack_hand(mob/user as mob)
	if ( get_dist(src, user) > 0 )
		if ( !(issilicon(user) || IsAdminGhost(user)) )
			to_chat(user, "<span class='notice'>You are too far away.</span>")
			user.unset_machine()
			user << browse(null, "window=turretid")
			return

	user.set_machine(src)
	var/area/area = get_area(src)
	var/t = ""

	if(locked && !(issilicon(user) || IsAdminGhost(user)))
		t += "<div class='notice icon'>Swipe ID card to unlock interface</div>"
	else
		if(!issilicon(user) && !IsAdminGhost(user))
			t += "<div class='notice icon'>Swipe ID card to lock interface</div>"
		t += "Turrets [enabled?"activated":"deactivated"] - <A href='?src=\ref[src];toggleOn=1'>[enabled?"Disable":"Enable"]?</a><br>"
		t += "Currently set for [lethal?"lethal":"stun repeatedly"] - <A href='?src=\ref[src];toggleLethal=1'>Change to [lethal?"Stun repeatedly":"Lethal"]?</a><br>"

	var/datum/browser/popup = new(user, "turretid", "Turret Control Panel ([area.name])")
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/turretid/Topic(href, href_list)
	if(..())
		return
	if (locked)
		if(!(issilicon(usr) || IsAdminGhost(usr)))
			to_chat(usr, "Control panel is locked!")
			return
	if (href_list["toggleOn"])
		toggle_on()
	else if (href_list["toggleLethal"])
		toggle_lethal()
	src.attack_hand(usr)

/obj/machinery/turretid/proc/toggle_lethal()
	lethal = !lethal
	updateTurrets()

/obj/machinery/turretid/proc/toggle_on()
	enabled = !enabled
	updateTurrets()

/obj/machinery/turretid/proc/updateTurrets()
	for (var/obj/machinery/porta_turret/aTurret in turrets)
		aTurret.setState(enabled, lethal)
	update_icon()

/obj/machinery/turretid/power_change()
	..()
	update_icon()

/obj/machinery/turretid/update_icon()
	..()
	if(stat & NOPOWER)
		icon_state = "control_off"
	else if (enabled)
		if (lethal)
			icon_state = "control_kill"
		else
			icon_state = "control_stun"
	else
		icon_state = "control_standby"

/obj/item/wallframe/turret_control
	name = "turret control frame"
	desc = "Used for building turret control panels"
	icon_state = "apc"
	result_path = /obj/machinery/turretid
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)

/obj/item/gun/proc/get_turret_properties()
	. = list()
	.["lethal_projectile"] = null
	.["lethal_projectile_sound"] = null
	.["stun_projectile"] = null
	.["stun_projectile_sound"] = null
	.["base_icon_state"] = "standard"

/obj/item/gun/energy/get_turret_properties()
	. = ..()

	var/obj/item/ammo_casing/primary_ammo = ammo_type[1]

	.["stun_projectile"] = initial(primary_ammo.projectile_type)
	.["stun_projectile_sound"] = initial(primary_ammo.fire_sound)

	if(ammo_type.len > 1)
		var/obj/item/ammo_casing/secondary_ammo = ammo_type[2]
		.["lethal_projectile"] = initial(secondary_ammo.projectile_type)
		.["lethal_projectile_sound"] = initial(secondary_ammo.fire_sound)
	else
		.["lethal_projectile"] = .["stun_projectile"]
		.["lethal_projectile_sound"] = .["stun_projectile_sound"]

/obj/item/gun/ballistic/get_turret_properties()
	. = ..()
	var/obj/item/ammo_box/mag = mag_type
	var/obj/item/ammo_casing/primary_ammo = initial(mag.ammo_type)

	.["base_icon_state"] = "syndie"
	.["stun_projectile"] = initial(primary_ammo.projectile_type)
	.["stun_projectile_sound"] = initial(primary_ammo.fire_sound)
	.["lethal_projectile"] = .["stun_projectile"]
	.["lethal_projectile_sound"] = .["stun_projectile_sound"]


/obj/item/gun/energy/laser/bluetag/get_turret_properties()
	. = ..()
	.["stun_projectile"] = /obj/item/projectile/beam/lasertag/bluetag
	.["lethal_projectile"] = /obj/item/projectile/beam/lasertag/bluetag
	.["base_icon_state"] = "blue"
	.["shot_delay"] = 30
	.["team_color"] = "blue"

/obj/item/gun/energy/laser/redtag/get_turret_properties()
	. = ..()
	.["stun_projectile"] = /obj/item/projectile/beam/lasertag/redtag
	.["lethal_projectile"] = /obj/item/projectile/beam/lasertag/redtag
	.["base_icon_state"] = "red"
	.["shot_delay"] = 30
	.["team_color"] = "red"

/obj/item/gun/energy/e_gun/turret/get_turret_properties()
	. = ..()

/obj/machinery/porta_turret/lasertag
	req_access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	check_records = 0
	criminals = 0
	auth_weapons = 1
	stun_all = 0
	check_anomalies = 0
	var/team_color

/obj/machinery/porta_turret/lasertag/assess_perp(mob/living/carbon/human/perp)
	. = 0
	if(team_color == "blue")	//Lasertag turrets target the opposing team, how great is that? -Sieve
		. = 0		//But does not target anyone else
		if(istype(perp.wear_suit, /obj/item/clothing/suit/redtag))
			. += 4
		if(perp.is_holding_item_of_type(/obj/item/gun/energy/laser/redtag))
			. += 4
		if(istype(perp.belt, /obj/item/gun/energy/laser/redtag))
			. += 2

	if(team_color == "red")
		. = 0
		if(istype(perp.wear_suit, /obj/item/clothing/suit/bluetag))
			. += 4
		if(perp.is_holding_item_of_type(/obj/item/gun/energy/laser/bluetag))
			. += 4
		if(istype(perp.belt, /obj/item/gun/energy/laser/bluetag))
			. += 2

/obj/machinery/porta_turret/lasertag/setup(obj/item/gun/gun)
	var/list/properties = ..()
	if(properties["team_color"])
		team_color = properties["team_color"]

/obj/machinery/porta_turret/lasertag/interact(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(team_color == "blue" && istype(H.wear_suit, /obj/item/clothing/suit/redtag))
			return
		if(team_color == "red" && istype(H.wear_suit, /obj/item/clothing/suit/bluetag))
			return

	var/dat = "Status: <a href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</a>"

	var/datum/browser/popup = new(user, "autosec", "Automatic Portable Turret Installation", 300, 300)
	popup.set_content(dat)
	popup.open()

//lasertag presets
/obj/machinery/porta_turret/lasertag/red
	installation = /obj/item/gun/energy/laser/redtag
	team_color = "red"

/obj/machinery/porta_turret/lasertag/blue
	installation = /obj/item/gun/energy/laser/bluetag
	team_color = "blue"

/obj/machinery/porta_turret/lasertag/bullet_act(obj/item/projectile/P)
	. = ..()
	if(on)
		if(team_color == "blue")
			if(istype(P, /obj/item/projectile/beam/lasertag/redtag))
				on = FALSE
				spawn(100)
					on = TRUE
		else if(team_color == "red")
			if(istype(P, /obj/item/projectile/beam/lasertag/bluetag))
				on = FALSE
				spawn(100)
					on = TRUE
