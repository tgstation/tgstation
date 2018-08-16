/*
DOG BORG EQUIPMENT HERE
SLEEPER CODE IS IN game/objects/items/devices/dogborg_sleeper.dm !
*/

/obj/item/dogborg/jaws/big
	name = "combat jaws"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "jaws"
	desc = "The jaws of the law."
	flags_1 = CONDUCT_1
	force = 12
	throwforce = 0
	hitsound = 'sound/weapons/bite.ogg'
	attack_verb = list("chomped", "bit", "ripped", "mauled", "enforced")
	w_class = 3
	sharpness = IS_SHARP

/obj/item/dogborg/jaws/small
	name = "puppy jaws"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "smalljaws"
	desc = "The jaws of a small dog."
	flags_1 = CONDUCT_1
	force = 6
	throwforce = 0
	hitsound = 'sound/weapons/bite.ogg'
	attack_verb = list("nibbled", "bit", "gnawed", "chomped", "nommed")
	w_class = 3
	sharpness = IS_SHARP

/obj/item/dogborg/jaws/attack(atom/A, mob/living/silicon/robot/user)
	..()
	user.do_attack_animation(A, ATTACK_EFFECT_BITE)

/obj/item/dogborg/jaws/small/attack_self(mob/user)
	var/mob/living/silicon/robot.R = user
	if(R.emagged)
		name = "combat jaws"
		icon = 'icons/mob/dogborg.dmi'
		icon_state = "jaws"
		desc = "The jaws of the law."
		flags_1 = CONDUCT_1
		force = 12
		throwforce = 0
		hitsound = 'sound/weapons/bite.ogg'
		attack_verb = list("chomped", "bit", "ripped", "mauled", "enforced")
		w_class = 3
		sharpness = IS_SHARP
	else
		name = "puppy jaws"
		icon = 'icons/mob/dogborg.dmi'
		icon_state = "smalljaws"
		desc = "The jaws of a small dog."
		flags_1 = CONDUCT_1
		force = 5
		throwforce = 0
		hitsound = 'sound/weapons/bite.ogg'
		attack_verb = list("nibbled", "bit", "gnawed", "chomped", "nommed")
		w_class = 3
		sharpness = IS_SHARP
	update_icon()


//Cuffs

/obj/item/restraints/handcuffs/cable/zipties/cyborg/dog/attack(mob/living/carbon/C, mob/user)
	if(!C.handcuffed)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 60, 1, -2)
		C.visible_message("<span class='danger'>[user] is trying to put zipties on [C]!</span>", \
							"<span class='userdanger'>[user] is trying to put zipties on [C]!</span>")
		if(do_mob(user, C, 60))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(C)
				C.update_inv_handcuffed(0)
				to_chat(user,"<span class='notice'>You handcuff [C].</span>")
				playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
				add_logs(user, C, "handcuffed")
		else
			to_chat(user,"<span class='warning'>You fail to handcuff [C]!</span>")


//Boop

/obj/item/analyzer/nose
	name = "boop module"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "nose"
	desc = "The BOOP module"
	flags_1 = CONDUCT_1
	force = 0
	throwforce = 0
	attack_verb = list("nuzzled", "nosed", "booped")
	w_class = 1

/obj/item/analyzer/nose/attack_self(mob/user)
	user.visible_message("[user] sniffs around the air.", "<span class='warning'>You sniff the air for gas traces.</span>")

	var/turf/location = user.loc
	if(!istype(location))
		return

	var/datum/gas_mixture/environment = location.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	to_chat(user, "<span class='info'><B>Results:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(user, "<span class='info'>Pressure: [round(pressure,0.1)] kPa</span>")
	else
		to_chat(user, "<span class='alert'>Pressure: [round(pressure,0.1)] kPa</span>")
	if(total_moles)
		var/list/env_gases = environment.gases

		environment.assert_gases(arglist(GLOB.hardcoded_gases))
		var/o2_concentration = env_gases[/datum/gas/oxygen][MOLES]/total_moles
		var/n2_concentration = env_gases[/datum/gas/nitrogen][MOLES]/total_moles
		var/co2_concentration = env_gases[/datum/gas/carbon_dioxide][MOLES]/total_moles
		var/plasma_concentration = env_gases[/datum/gas/plasma][MOLES]/total_moles
		environment.garbage_collect()

		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(user, "<span class='info'>Nitrogen: [round(n2_concentration*100, 0.01)] %</span>")
		else
			to_chat(user, "<span class='alert'>Nitrogen: [round(n2_concentration*100, 0.01)] %</span>")

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(user, "<span class='info'>Oxygen: [round(o2_concentration*100, 0.01)] %</span>")
		else
			to_chat(user, "<span class='alert'>Oxygen: [round(o2_concentration*100, 0.01)] %</span>")

		if(co2_concentration > 0.01)
			to_chat(user, "<span class='alert'>CO2: [round(co2_concentration*100, 0.01)] %</span>")
		else
			to_chat(user, "<span class='info'>CO2: [round(co2_concentration*100, 0.01)] %</span>")

		if(plasma_concentration > 0.005)
			to_chat(user, "<span class='alert'>Plasma: [round(plasma_concentration*100, 0.01)] %</span>")
		else
			to_chat(user, "<span class='info'>Plasma: [round(plasma_concentration*100, 0.01)] %</span>")


		for(var/id in env_gases)
			if(id in GLOB.hardcoded_gases)
				continue
			var/gas_concentration = env_gases[id][MOLES]/total_moles
			to_chat(user, "<span class='alert'>[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] %</span>")
		to_chat(user, "<span class='info'>Temperature: [round(environment.temperature-T0C)] &deg;C</span>")

/obj/item/analyzer/nose/AltClick(mob/user) //Barometer output for measuring when the next storm happens
	. = ..()

//Delivery

/obj/item/storage/bag/borgdelivery
	name = "fetching storage"
	desc = "Fetch the thing!"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "dbag"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/bag/borgdelivery/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.max_combined_w_class = 5
	STR.max_items = 1
	STR.cant_hold = typecacheof(list(/obj/item/disk/nuclear))
//Tongue stuff

/obj/item/soap/tongue
	name = "synthetic tongue"
	desc = "Useful for slurping mess off the floor before affectionally licking the crew members in the face."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "synthtongue"
	hitsound = 'sound/effects/attackblob.ogg'
	cleanspeed = 80

/obj/item/soap/tongue/scrubpup
	cleanspeed = 25 //slightly faster than a mop.

/obj/item/soap/tongue/New()
	..()
	item_flags |= NOBLUDGEON //No more attack messages

/obj/item/trash/rkibble
	name = "robo kibble"
	desc = "A novelty bowl of assorted mech fabricator byproducts. Mockingly feed this to the sec-dog to help it recharge."
	icon = 'icons/mob/dogborg.dmi'
	icon_state= "kibble"

/obj/item/soap/tongue/attack_self(mob/user)
	var/mob/living/silicon/robot.R = user
	if(R.emagged)
		name = "hacked tongue of doom"
		desc = "Your tongue has been upgraded successfully. Congratulations."
		icon = 'icons/mob/dogborg.dmi'
		icon_state = "syndietongue"
		cleanspeed = 10 //(nerf'd)tator soap stat
	else
		name = "synthetic tongue"
		desc = "Useful for slurping mess off the floor before affectionally licking the crew members in the face."
		icon = 'icons/mob/dogborg.dmi'
		icon_state = "synthtongue"
		cleanspeed = initial(cleanspeed)
	update_icon()

/obj/item/soap/tongue/afterattack(atom/target, mob/user, proximity)
	var/mob/living/silicon/robot.R = user
	if(!proximity || !check_allowed_items(target))
		return
	if(R.client && (target in R.client.screen))
		to_chat(R, "<span class='warning'>You need to take that [target.name] off before cleaning it!</span>")
	else if(is_cleanable(target))
		R.visible_message("[R] begins to lick off \the [target.name].", "<span class='warning'>You begin to lick off \the [target.name]...</span>")
		if(do_after(R, src.cleanspeed, target = target))
			if(!in_range(src, target)) //Proximity is probably old news by now, do a new check.
				return //If they moved away, you can't eat them.
			to_chat(R, "<span class='notice'>You finish licking off \the [target.name].</span>")
			qdel(target)
			R.cell.give(50)
	else if(isobj(target)) //hoo boy. danger zone man
		if(istype(target,/obj/item/trash))
			R.visible_message("[R] nibbles away at \the [target.name].", "<span class='warning'>You begin to nibble away at \the [target.name]...</span>")
			if(do_after(R, src.cleanspeed, target = target))
				if(!in_range(src, target)) //Proximity is probably old news by now, do a new check.
					return //If they moved away, you can't eat them.
				to_chat(R, "<span class='notice'>You finish off \the [target.name].</span>")
				qdel(target)
				R.cell.give(250)
			return
		if(istype(target,/obj/item/stock_parts/cell))
			R.visible_message("[R] begins cramming \the [target.name] down its throat.", "<span class='warning'>You begin cramming \the [target.name] down your throat...</span>")
			if(do_after(R, 50, target = target))
				if(!in_range(src, target)) //Proximity is probably old news by now, do a new check.
					return //If they moved away, you can't eat them.
				to_chat(R, "<span class='notice'>You finish off \the [target.name].</span>")
				var/obj/item/stock_parts/cell.C = target
				R.cell.charge = R.cell.charge + (C.charge / 3) //Instant full cell upgrades op idgaf
				qdel(target)
			return
		var/obj/item/I = target //HAHA FUCK IT, NOT LIKE WE ALREADY HAVE A SHITTON OF WAYS TO REMOVE SHIT
		if(!I.anchored && R.emagged)
			R.visible_message("[R] begins chewing up \the [target.name]. Looks like it's trying to loophole around its diet restriction!", "<span class='warning'>You begin chewing up \the [target.name]...</span>")
			if(do_after(R, 100, target = I)) //Nerf dat time yo
				if(!in_range(src, target)) //Proximity is probably old news by now, do a new check. Even emags don't make you magically eat things at range.
					return //If they moved away, you can't eat them.
				visible_message("<span class='warning'>[R] chews up \the [target.name] and cleans off the debris!</span>")
				to_chat(R, "<span class='notice'>You finish off \the [target.name].</span>")
				qdel(I)
				R.cell.give(500)
			return
		R.visible_message("[R] begins to lick \the [target.name] clean...", "<span class='notice'>You begin to lick \the [target.name] clean...</span>")
		if(do_after(R, src.cleanspeed, target = target))
			if(!in_range(src, target)) //Proximity is probably old news by now, do a new check.
				return //If they moved away, you can't clean them.
			to_chat(R,"<span class='notice'>You clean \the [target.name].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	else if(ishuman(target))
		if(R.emagged)
			var/mob/living/L = target
			if(R.cell.charge <= 666)
				return
			L.Stun(4) // normal stunbaton is force 7 gimme a break good sir!
			L.Knockdown(80)
			L.apply_effect(EFFECT_STUTTER, 4)
			L.visible_message("<span class='danger'>[R] has shocked [L] with its tongue!</span>", \
								"<span class='userdanger'>[R] has shocked you with its tongue! You can feel the betrayal.</span>")
			playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			R.cell.use(666)
		else
			R.visible_message("<span class='warning'>\the [R] affectionally licks \the [target]'s face!</span>", "<span class='notice'>You affectionally lick \the [target]'s face!</span>")
			playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
			var/mob/living/L = target
			if(istype(L) && L.fire_stacks > 0)
				L.adjust_fire_stacks(-10)
			return
	else if(istype(target, /obj/structure/window))
		R.visible_message("[R] begins to lick \the [target.name] clean...", "<span class='notice'>You begin to lick \the [target.name] clean...</span>")
		if(do_after(R, src.cleanspeed, target = target))
			if(!in_range(src, target)) //Proximity is probably old news by now, do a new check.
				return //If they moved away, you can't clean them.
			to_chat(R, "<span class='notice'>You clean \the [target.name].</span>")
			target.color = initial(target.color)
	else
		R.visible_message("[R] begins to lick \the [target.name] clean...", "<span class='notice'>You begin to lick \the [target.name] clean...</span>")
		if(do_after(R, src.cleanspeed, target = target))
			if(!in_range(src, target)) //Proximity is probably old news by now, do a new check.
				return //If they moved away, you can't clean them.
			to_chat(R, "<span class='notice'>You clean \the [target.name].</span>")
			var/obj/effect/decal/cleanable/C = locate() in target
			qdel(C)
			SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	return


//Defibs

/obj/item/twohanded/shockpaddles/cyborg/hound
	name = "Paws of Life"
	desc = "MediHound specific shock paws."
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"

// Pounce stuff for K-9

/obj/item/dogborg/pounce
	name = "pounce"
	icon = 'icons/mob/dogborg.dmi'
	icon_state = "pounce"
	desc = "Leap at your target to momentarily stun them."
	force = 0
	throwforce = 0

/obj/item/dogborg/pounce/New()
	..()
	item_flags |= NOBLUDGEON

/mob/living/silicon/robot
	var/leaping = 0
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 50 //Nearly doubled, u happy?
	var/pounce_spoolup = 3
	var/leap_at
	var/disabler
	var/laser
	var/sleeper_g
	var/sleeper_r

#define MAX_K9_LEAP_DIST 4 //because something's definitely borked the pounce functioning from a distance.

/obj/item/dogborg/pounce/afterattack(atom/A, mob/user)
	var/mob/living/silicon/robot/R = user
	if(R && !R.pounce_cooldown)
		R.pounce_cooldown = !R.pounce_cooldown
		to_chat(R, "<span class ='warning'>Your targeting systems lock on to [A]...</span>")
		addtimer(CALLBACK(R, /mob/living/silicon/robot.proc/leap_at, A), R.pounce_spoolup)
		spawn(R.pounce_cooldown_time)
			R.pounce_cooldown = !R.pounce_cooldown
	else if(R && R.pounce_cooldown)
		to_chat(R, "<span class='danger'>Your leg actuators are still recharging!</span>")

/mob/living/silicon/robot/proc/leap_at(atom/A)
	if(leaping || stat || buckled || lying)
		return

	if(!has_gravity(src) || !has_gravity(A))
		to_chat(src,"<span class='danger'>It is unsafe to leap without gravity!</span>")
		//It's also extremely buggy visually, so it's balance+bugfix
		return

	if(cell.charge <= 500)
		to_chat(src,"<span class='danger'>Insufficent reserves for jump actuators!</span>")
		return

	else
		leaping = 1
		weather_immunities += "lava"
		pixel_y = 10
		update_icons()
		throw_at(A, MAX_K9_LEAP_DIST, 1, spin=0, diagonals_first = 1)
		cell.use(500) //Doubled the energy consumption
		weather_immunities -= "lava"

/mob/living/silicon/robot/throw_impact(atom/A)

	if(!leaping)
		return ..()

	if(A)
		if(isliving(A))
			var/mob/living/L = A
			var/blocked = 0
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(0, "the [name]", src, attack_type = LEAP_ATTACK))
					blocked = 1
			if(!blocked)
				L.visible_message("<span class ='danger'>[src] pounces on [L]!</span>", "<span class ='userdanger'>[src] pounces on you!</span>")
				L.Knockdown(iscarbon(L) ? 450 : 45) // Temporary. If someone could rework how dogborg pounces work to accomodate for combat changes, that'd be nice.
				playsound(src, 'sound/weapons/Egloves.ogg', 50, 1)
				sleep(2)//Runtime prevention (infinite bump() calls on hulks)
				step_towards(src,L)
			else
				Knockdown(45, 1, 1)

			pounce_cooldown = !pounce_cooldown
			spawn(pounce_cooldown_time) //3s by default
				pounce_cooldown = !pounce_cooldown
		else if(A.density && !A.CanPass(src))
			visible_message("<span class ='danger'>[src] smashes into [A]!</span>", "<span class ='userdanger'>You smash into [A]!</span>")
			playsound(src, 'sound/items/trayhit1.ogg', 50, 1)
			Knockdown(45, 1, 1)

		if(leaping)
			leaping = 0
			pixel_y = initial(pixel_y)
			update_icons()
			update_canmove()
