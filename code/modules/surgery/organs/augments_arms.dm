/obj/item/organ/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = "r_arm"
	slot = "r_arm_device"
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)

	var/list/items_list = list()
	// Used to store a list of all items inside, for multi-item implants.
	// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.

	var/obj/item/holder = null
	// You can use this var for item path, it would be converted into an item on New()

/obj/item/organ/cyberimp/arm/New()
	..()
	if(ispath(holder))
		holder = new holder(src)

	update_icon()
	slot = zone + "_device"
	items_list = contents.Copy()

/obj/item/organ/cyberimp/arm/update_icon()
	if(zone == "r_arm")
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/arm/examine(mob/user)
	..()
	user << "<span class='info'>[src] is assembled in the [zone == "r_arm" ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/cyberimp/arm/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/screwdriver))
		if(zone == "r_arm")
			zone = "l_arm"
		else
			zone = "r_arm"
		slot = zone + "_device"
		user << "<span class='notice'>You modify [src] to be installed on the [zone == "r_arm" ? "right" : "left"] arm.</span>"
		update_icon()
	else if(istype(W, /obj/item/weapon/card/emag))
		emag_act()

/obj/item/organ/cyberimp/arm/Remove(mob/living/carbon/M, special = 0)
	Retract()
	..()

/obj/item/organ/cyberimp/arm/emag_act()
	return 0

/obj/item/organ/cyberimp/arm/gun/emp_act(severity)
	if(prob(15/severity) && owner)
		owner << "<span class='warning'>[src] is hit by EMP!</span>"
		// give the owner an idea about why his implant is glitching
		Retract()
	..()

/obj/item/organ/cyberimp/arm/proc/Retract()
	if(!holder || (holder in src))
		return

	owner.visible_message("<span class='notice'>[owner] retracts [holder] back into [owner.p_their()] [zone == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='notice'>[holder] snaps back into your [zone == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")

	if(istype(holder, /obj/item/device/assembly/flash/armimplant))
		var/obj/item/device/assembly/flash/F = holder
		F.SetLuminosity(0)

	owner.transferItemToLoc(holder, src, TRUE)
	holder = null
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/obj/item/organ/cyberimp/arm/proc/Extend(var/obj/item/item)
	if(!(item in src))
		return

	holder = item

	holder.flags |= NODROP
	holder.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	holder.slot_flags = null
	holder.w_class = WEIGHT_CLASS_HUGE
	holder.materials = null

	if(istype(holder, /obj/item/device/assembly/flash/armimplant))
		var/obj/item/device/assembly/flash/F = holder
		F.SetLuminosity(7)

	var/obj/item/arm_item = owner.get_active_held_item()

	if(arm_item)
		if(!owner.dropItemToGround(arm_item))
			owner << "<span class='warning'>Your [arm_item] interferes with [src]!</span>"
			return
		else
			owner << "<span class='notice'>You drop [arm_item] to activate [src]!</span>"

	var/result = (zone == "r_arm" ? owner.put_in_r_hand(holder) : owner.put_in_l_hand(holder))
	if(!result)
		owner << "<span class='warning'>Your [src] fails to activate!</span>"
		return

	// Activate the hand that now holds our item.
	owner.swap_hand(result)//... or the 1st hand if the index gets lost somehow

	owner.visible_message("<span class='notice'>[owner] extends [holder] from [owner.p_their()] [zone == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='notice'>You extend [holder] from your [zone == "r_arm" ? "right" : "left"] arm.</span>",
		"<span class='italics'>You hear a short mechanical noise.</span>")
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, 1)

/obj/item/organ/cyberimp/arm/ui_action_click()
	if(crit_fail || (!holder && !contents.len))
		owner << "<span class='warning'>The implant doesn't respond. It seems to be broken...</span>"
		return

	// You can emag the arm-mounted implant by activating it while holding emag in it's hand.
	if(istype(owner.get_active_held_item(), /obj/item/weapon/card/emag) && emag_act())
		return

	if(!holder || (holder in src))
		holder = null
		if(contents.len == 1)
			Extend(contents[1])
		else // TODO: make it similar to borg's storage-like module selection
			var/obj/item/choise = input("Activate which item?", "Arm Implant", null, null) as null|anything in items_list
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && !holder && istype(choise) && (choise in contents))
				// This monster sanity check is a nice example of how bad input() is.
				Extend(choise)
	else
		Retract()


/obj/item/organ/cyberimp/arm/gun/emp_act(severity)
	if(prob(30/severity) && owner && !crit_fail)
		Retract()
		owner.visible_message("<span class='danger'>A loud bang comes from [owner]\'s [zone == "r_arm" ? "right" : "left"] arm!</span>")
		playsound(get_turf(owner), 'sound/weapons/flashbang.ogg', 100, 1)
		owner << "<span class='userdanger'>You feel an explosion erupt inside your [zone == "r_arm" ? "right" : "left"] arm as your implant breaks!</span>"
		owner.adjust_fire_stacks(20)
		owner.IgniteMob()
		owner.adjustFireLoss(25)
		crit_fail = 1
	else // The gun will still discharge anyway.
		..()


/obj/item/organ/cyberimp/arm/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	origin_tech = "materials=4;combat=4;biotech=4;powerstorage=4;syndicate=3"
	holder = /obj/item/weapon/gun/energy/laser/mounted

/obj/item/organ/cyberimp/arm/gun/laser/l
	zone = "l_arm"


/obj/item/organ/cyberimp/arm/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	origin_tech = "materials=5;combat=5;biotech=4;powerstorage=4"
	holder = /obj/item/weapon/gun/energy/e_gun/advtaser/mounted

/obj/item/organ/cyberimp/arm/gun/taser/l
	zone = "l_arm"


/obj/item/organ/cyberimp/arm/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm. Contains all neccessary tools."
	origin_tech = "materials=3;engineering=4;biotech=3;powerstorage=4"
	contents = newlist(/obj/item/weapon/screwdriver/cyborg, /obj/item/weapon/wrench/cyborg, /obj/item/weapon/weldingtool/largetank/cyborg,
		/obj/item/weapon/crowbar/cyborg, /obj/item/weapon/wirecutters/cyborg, /obj/item/device/multitool/cyborg)

/obj/item/organ/cyberimp/arm/toolset/l
	zone = "l_arm"

/obj/item/organ/cyberimp/arm/toolset/emag_act()
	if(!(locate(/obj/item/weapon/kitchen/knife/combat/cyborg) in items_list))
		usr << "<span class='notice'>You unlock [src]'s integrated knife!</span>"
		items_list += new /obj/item/weapon/kitchen/knife/combat/cyborg(src)
		return 1
	return 0

/obj/item/organ/cyberimp/arm/esword
	name = "arm-mounted energy blade"
	desc = "An illegal, and highly dangerous cybernetic implant that can project a deadly blade of concentrated enregy."
	contents = newlist(/obj/item/weapon/melee/energy/blade/hardlight)
	origin_tech = "materials=4;combat=5;biotech=3;powerstorage=2;syndicate=5"

/obj/item/organ/cyberimp/arm/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	contents = newlist(/obj/item/weapon/gun/medbeam)
	origin_tech = "materials=5;combat=2;biotech=5;powerstorage=4;syndicate=1"

/obj/item/organ/cyberimp/arm/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm, that is able to be used as a powerful flash."
	contents = newlist(/obj/item/device/assembly/flash/armimplant)
	origin_tech = "materials=4;combat=3;biotech=4;magnets=4;powerstorage=3"

/obj/item/organ/cyberimp/arm/flash/New()
	..()
	if(locate(/obj/item/device/assembly/flash/armimplant) in items_list)
		var/obj/item/device/assembly/flash/armimplant/F = locate(/obj/item/device/assembly/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/cyberimp/arm/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	contents = newlist(/obj/item/borg/stun)
	origin_tech = "materials=3;combat=5;biotech=4;powerstorage=4;syndicate=3"

/obj/item/organ/cyberimp/arm/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm"
	contents = newlist(/obj/item/weapon/melee/energy/blade/hardlight, /obj/item/weapon/gun/medbeam, /obj/item/borg/stun, /obj/item/device/assembly/flash/armimplant)
	origin_tech = "materials=5;combat=7;biotech=5;powerstorage=5;syndicate=6;programming=5"

/obj/item/organ/cyberimp/arm/combat/New()
	..()
	if(locate(/obj/item/device/assembly/flash/armimplant) in items_list)
		var/obj/item/device/assembly/flash/armimplant/F = locate(/obj/item/device/assembly/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/cyberimp/arm/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm"
	contents = newlist(/obj/item/weapon/retractor, /obj/item/weapon/hemostat, /obj/item/weapon/cautery, /obj/item/weapon/surgicaldrill, /obj/item/weapon/scalpel, /obj/item/weapon/circular_saw, /obj/item/weapon/surgical_drapes)
	origin_tech = "materials=3;engineering=3;biotech=3;programming=2;magnets=3"

/obj/item/organ/cyberimp/arm/bluespace_crusher
	name = "bluespace crusher implant"
	desc = "A hand-mounted experimental device that uses bluespace to separate matter from our reality, effectively deleting it. Nobody actually knows where it ends up."
	contents = newlist(/obj/item/weapon/bluespace_crusher)
	origin_tech = "materials=6;bluespace=6;biotech=4;programming=4"
	icon_state = "bscrusher_implant"
	var/crystals = 0
	var/charges = 0
	var/charge_cooldown = 600
	var/next_charge = null

/obj/item/organ/cyberimp/arm/bluespace_crusher/New()
	..()
	for(var/obj/item/weapon/bluespace_crusher/B in items_list)
		B.implant = src

/obj/item/organ/cyberimp/arm/bluespace_crusher/examine(mob/user)
	..()
	if(crystals)
		user << "<span class='notice'>It's loaded with [crystals] crystal[crystals > 1 ? "s":""].</span>"
	else
		user << "<span class='notice'>It's not loaded with any crystals.</span>"

/obj/item/organ/cyberimp/arm/bluespace_crusher/Insert()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/cyberimp/arm/bluespace_crusher/Remove()
	..()
	STOP_PROCESSING(SSobj, src)
	next_charge = null

/obj/item/organ/cyberimp/arm/bluespace_crusher/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/organ/cyberimp/arm/bluespace_crusher/process()
	if(!next_charge && charges < crystals)
		next_charge = world.time + charge_cooldown
	if(world.time > next_charge && charges < crystals)
		charges++
		owner << "<span class='notice'>Your [name] has charged a crystal. It now has [charges] charged crystals.</span>"

/obj/item/organ/cyberimp/arm/bluespace_crusher/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W,/obj/item/weapon/ore/bluespace_crystal))
		if(crystals < 3)
			qdel(W)
			crystals++
			charges++
			user << "<span class='notice'>You insert [W] into [src].</span>"
			return
		else
			user << "<span class='notice'>[src]'s crystal slots are full!</span>"
			return
	..()

/obj/item/organ/cyberimp/arm/bluespace_crusher/loaded
	crystals = 3
	charges = 3

/obj/item/weapon/bluespace_crusher
	name = "bluespace crusher"
	desc = "It appears to erase matter and even space itself."
	icon_state = "bscrusher"
	item_state = "ratvars_flame"
	w_class = WEIGHT_CLASS_HUGE
	flags = ABSTRACT | NODROP
	force = 40 //Only if charged
	armour_penetration = 100 //Same here
	block_chance = 50
	attack_verb = list("swiped")
	var/obj/item/organ/cyberimp/arm/bluespace_crusher/implant

/obj/item/weapon/bluespace_crusher/New()
	..()
	hitsound = null //otherwise it gets the default hitsound

/obj/item/weapon/bluespace_crusher/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W,/obj/item/weapon/ore/bluespace_crystal))
		if(implant.crystals < 3)
			qdel(W)
			implant.crystals++
			implant.charges++
			user << "<span class='notice'>You insert [W] into [src].</span>"
			return
		else
			user << "<span class='notice'>[src]'s crystal slots are full!</span>"
			return
	..()

/obj/item/weapon/bluespace_crusher/examine(mob/user)
	..()
	if(implant.crystals > 1)
		if(implant.charges > 1)
			user << "<span class='notice'>It's loaded with [implant.crystals] crystals, [implant.charges] of which are charged.</span>"
		else
			user << "<span class='notice'>It's loaded with [implant.crystals] crystals, [implant.charges ? "[implant.charges] of which is charged":"none of which are charged"].</span>"
	else if (implant.crystals)
		user << "<span class='notice'>It's loaded with [implant.crystals] crystal, which [implant.charges ? "is charged":"isn't charged"].</span>"
	else
		user << "<span class='notice'>It's not loaded with any crystals.</span>"


/obj/item/weapon/bluespace_crusher/proc/use_charge(mob/user, silent = FALSE)
	if(!implant.charges)
		if(!implant.crystals)
			if(!silent)
				user << "<span class='notice'>[src] requires at least a bluespace crystal to use!</span>"
			return FALSE
		if(!silent)
			user << "<span class='notice'>[src] is still recharging!</span>"
		return FALSE

	implant.charges--
	return TRUE

/obj/item/weapon/bluespace_crusher/proc/attack_effect(turf/T)
	new /obj/effect/overlay/temp/bluespace_swipe(T)
	playsound(T,"sound/weapons/resonator_blast.ogg",50,1)


/obj/item/weapon/bluespace_crusher/afterattack(atom/target, mob/user, proximity)
	if(proximity)
		if(istype(target, /obj/item) && use_charge(user))
			attack_effect(get_turf(target))
			new /obj/effect/overlay/temp/emp/pulse(get_turf(target))
			user.visible_message("<span class='danger'>[user] swipes at [target] with [user.p_their()] [src], erasing it from existence!</span>", \
			"<span class='danger'>You swipe at [target] with [src], erasing it from existence!</span>")
			log_game("[key_name(user)] has deleted [target] with a bluespace crusher.")
			qdel(target)
		return

	if(!use_charge(user))
		return

	attack_effect(get_step_towards(user, target))
	new /obj/effect/overlay/temp/emp/pulse(get_turf(target))

	var/list/targets = list()
	for(var/atom/movable/A in get_turf(target))
		if(!A.anchored)
			targets += A

	if(!isturf(target) && target in targets)
		user.visible_message("<span class='danger'>[user] crushes spacetime, drawing [target] closer to [user.p_them()]!</span>", \
		"<span class='danger'>You crush spacetime, drawing [target] closer to you!</span>")
	else if(targets.len > 1)
		user.visible_message("<span class='danger'>[user] crushes spacetime, attracting several objects!</span>", \
		"<span class='danger'>You crush spacetime, attracting several objects!</span>")
	else if(targets.len)
		user.visible_message("<span class='danger'>[user] crushes spacetime, attracting [targets[1]] closer to [user.p_them()]!</span>", \
		"<span class='danger'>You crush spacetime, drawing [targets[1]] closer to you!</span>")
	else
		user.visible_message("<span class='danger'>[user] crushes spacetime, but nothing happens!</span>", \
		"<span class='danger'>You crush spacetime, but you fail to attract anything!</span>")

	while(targets.len)
		for(var/atom/movable/A in targets)
			if(QDELETED(A) || get_dist(A,user) > 12 || A.anchored) //breaks in case of teleportation
				targets -= A
				continue
			if(!A.Move(get_step_towards(A, user)))
				targets -= A
				continue
			if(get_dist(A,user) <= 1)
				targets -= A
				continue
		sleep(1)

/obj/item/weapon/bluespace_crusher/attack(mob/M, mob/user)
	if(!use_charge(user, silent = TRUE))
		force = 0
		armour_penetration = 0
		..()
	else
		force = 40
		armour_penetration = 100
		attack_effect(get_turf(M))
		..()


/obj/item/weapon/bluespace_crusher/attack_obj(obj/O, mob/living/user)
	if(!use_charge(user))
		return

	user.changeNext_move(CLICK_CD_MELEE)

	attack_effect(get_turf(O))

	user.visible_message("<span class='danger'>[user] swipes at [O] with [user.p_their()] [src], erasing part of it!</span>", \
	"<span class='danger'>You swipe at [O] with [src], erasing part of it from existence!</span>")
	O.take_damage(150, BRUTE, "melee", 0)
	return FALSE

/obj/item/weapon/bluespace_crusher/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance, atom/movable/AM, attack_type)
	if(attack_type == THROWN_PROJECTILE_ATTACK && istype(AM, /obj/item) && prob(block_chance) && use_charge(owner, silent = TRUE))
		owner.visible_message("<span class='danger'>[owner] swipes at [AM] in midair with [owner.p_their()] [src], erasing it!</span>", \
		"<span class='danger'>You swipe at [AM] in midair with [src], erasing it!</span>")
		return TRUE
	else
		return FALSE





