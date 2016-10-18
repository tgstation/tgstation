////////////////////////
// CLOCKWORK MACHINES //
////////////////////////
//not-actually-machines

/obj/structure/destructible/clockwork/powered
	var/obj/machinery/power/apc/target_apc
	var/active = FALSE
	var/needs_power = TRUE
	var/active_icon = null //icon_state while process() is being called
	var/inactive_icon = null //icon_state while process() isn't being called

/obj/structure/destructible/clockwork/powered/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		var/powered = total_accessable_power()
		user << "<span class='[powered ? "brass":"alloy"]'>It has access to <b>[powered == INFINITY ? "INFINITY":"[powered]"]W</b> of power.</span>"

/obj/structure/destructible/clockwork/powered/Destroy()
	SSfastprocess.processing -= src
	SSobj.processing -= src
	return ..()

/obj/structure/destructible/clockwork/powered/process()
	var/powered = total_accessable_power()
	return powered == PROCESS_KILL ? 25 : powered //make sure we don't accidentally return the arbitrary PROCESS_KILL define

/obj/structure/destructible/clockwork/powered/proc/toggle(fast_process, mob/living/user)
	if(user)
		if(!is_servant_of_ratvar(user))
			return 0
		user.visible_message("<span class='notice'>[user] [active ? "dis" : "en"]ables [src].</span>", "<span class='brass'>You [active ? "dis" : "en"]able [src].</span>")
	active = !active
	if(active)
		icon_state = active_icon
		if(fast_process)
			START_PROCESSING(SSfastprocess, src)
		else
			START_PROCESSING(SSobj, src)
	else
		icon_state = inactive_icon
		if(fast_process)
			STOP_PROCESSING(SSfastprocess, src)
		else
			STOP_PROCESSING(SSobj, src)


/obj/structure/destructible/clockwork/powered/proc/total_accessable_power() //how much power we have and can use
	if(!needs_power || ratvar_awakens)
		return INFINITY //oh yeah we've got power why'd you ask

	var/power = 0
	power += accessable_apc_power()
	power += accessable_sigil_power()
	return power

/obj/structure/destructible/clockwork/powered/proc/accessable_apc_power()
	var/power = 0
	var/area/A = get_area(src)
	var/area/targetAPCA
	for(var/obj/machinery/power/apc/APC in apcs_list)
		var/area/APCA = get_area(APC)
		if(APCA == A)
			target_apc = APC
	if(target_apc)
		targetAPCA = get_area(target_apc)
		if(targetAPCA != A)
			target_apc = null
		else if(target_apc.cell)
			var/apccharge = target_apc.cell.charge
			if(apccharge >= MIN_CLOCKCULT_POWER)
				power += apccharge
	return power

/obj/structure/destructible/clockwork/powered/proc/accessable_sigil_power()
	var/power = 0
	for(var/obj/effect/clockwork/sigil/transmission/T in range(1, src))
		power += T.power_charge
	return power


/obj/structure/destructible/clockwork/powered/proc/try_use_power(amount) //try to use an amount of power
	if(!needs_power || ratvar_awakens)
		return 1
	if(amount <= 0)
		return 0
	var/power = total_accessable_power()
	if(!power || power < amount)
		return 0
	return use_power(amount)

/obj/structure/destructible/clockwork/powered/proc/use_power(amount) //we've made sure we had power, so now we use it
	var/sigilpower = accessable_sigil_power()
	var/list/sigils_in_range = list()
	for(var/obj/effect/clockwork/sigil/transmission/T in range(1, src))
		sigils_in_range |= T
	while(sigilpower && amount >= MIN_CLOCKCULT_POWER)
		for(var/S in sigils_in_range)
			var/obj/effect/clockwork/sigil/transmission/T = S
			if(amount >= MIN_CLOCKCULT_POWER && T.modify_charge(MIN_CLOCKCULT_POWER))
				sigilpower -= MIN_CLOCKCULT_POWER
				amount -= MIN_CLOCKCULT_POWER
	var/apcpower = accessable_apc_power()
	while(apcpower >= MIN_CLOCKCULT_POWER && amount >= MIN_CLOCKCULT_POWER)
		if(target_apc.cell.use(MIN_CLOCKCULT_POWER))
			apcpower -= MIN_CLOCKCULT_POWER
			amount -= MIN_CLOCKCULT_POWER
			target_apc.update()
			target_apc.update_icon()
		else
			apcpower = 0
	if(amount)
		return 0
	else
		return 1

/obj/structure/destructible/clockwork/powered/proc/return_power(amount) //returns a given amount of power to all nearby sigils
	if(amount <= 0)
		return 0
	var/list/sigils_in_range = list()
	for(var/obj/effect/clockwork/sigil/transmission/T in range(1, src))
		sigils_in_range |= T
	if(!sigils_in_range.len)
		return 0
	while(amount >= MIN_CLOCKCULT_POWER)
		for(var/S in sigils_in_range)
			var/obj/effect/clockwork/sigil/transmission/T = S
			if(amount >= MIN_CLOCKCULT_POWER && T.modify_charge(-MIN_CLOCKCULT_POWER))
				amount -= MIN_CLOCKCULT_POWER
	return 1


/obj/structure/destructible/clockwork/powered/mending_motor //Mending motor: A prism that consumes replicant alloy to repair nearby mechanical servants at a quick rate.
	name = "mending motor"
	desc = "A dark onyx prism, held in midair by spiraling tendrils of stone."
	clockwork_desc = "A powerful prism that rapidly repairs nearby mechanical servants and clockwork structures."
	icon_state = "mending_motor_inactive"
	active_icon = "mending_motor"
	inactive_icon = "mending_motor_inactive"
	construction_value = 20
	max_integrity = 125
	obj_integrity = 125
	break_message = "<span class='warning'>The prism collapses with a heavy thud!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/small = 5, \
	/obj/item/clockwork/alloy_shards/medium = 1, \
	/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/component/vanguard_cogwheel = 1)
	var/stored_alloy = 0
	var/max_alloy = REPLICANT_ALLOY_POWER * 10
	var/mob_cost = 200
	var/structure_cost = 250
	var/cyborg_cost = 300

/obj/structure/destructible/clockwork/powered/mending_motor/prefilled
	stored_alloy = REPLICANT_ALLOY_POWER //starts with 1 replicant alloy's worth of power

/obj/structure/destructible/clockwork/powered/mending_motor/total_accessable_power()
	. = ..()
	if(. != INFINITY)
		. += accessable_alloy_power()

/obj/structure/destructible/clockwork/powered/mending_motor/proc/accessable_alloy_power()
	return stored_alloy

/obj/structure/destructible/clockwork/powered/mending_motor/use_power(amount)
	var/alloypower = accessable_alloy_power()
	while(alloypower >= MIN_CLOCKCULT_POWER && amount >= MIN_CLOCKCULT_POWER)
		stored_alloy -= MIN_CLOCKCULT_POWER
		alloypower -= MIN_CLOCKCULT_POWER
		amount -= MIN_CLOCKCULT_POWER
	return ..()

/obj/structure/destructible/clockwork/powered/mending_motor/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='alloy'>It contains <b>[stored_alloy*CLOCKCULT_POWER_TO_ALLOY_MULTIPLIER]/[max_alloy*CLOCKCULT_POWER_TO_ALLOY_MULTIPLIER]</b> units of liquified alloy, \
		which is equivalent to <b>[stored_alloy]W/[max_alloy]W</b> of power.</span>"
		user << "<span class='inathneq_small'>It requires <b>[mob_cost]W</b> to heal clockwork mobs, <b>[structure_cost]W</b> for clockwork structures, and <b>[cyborg_cost]W</b> for cyborgs.</span>"

/obj/structure/destructible/clockwork/powered/mending_motor/process()
	if(..() < mob_cost)
		visible_message("<span class='warning'>[src] emits an airy chuckling sound and falls dark!</span>")
		toggle()
		return
	for(var/atom/movable/M in range(5, src))
		if(isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab))
			var/mob/living/simple_animal/hostile/clockwork/W = M
			var/fatigued = FALSE
			if(istype(M, /mob/living/simple_animal/hostile/clockwork/marauder))
				var/mob/living/simple_animal/hostile/clockwork/marauder/E = M
				if(E.fatigue)
					fatigued = TRUE
			if((!fatigued && W.health == W.maxHealth) || W.stat)
				continue
			if(!try_use_power(mob_cost))
				break
			W.adjustHealth(-20)
		else if(istype(M, /obj/structure/destructible/clockwork))
			var/obj/structure/destructible/clockwork/C = M
			if(C.obj_integrity == C.max_integrity)
				continue
			if(!try_use_power(structure_cost))
				break
			C.obj_integrity = min(C.obj_integrity + 20, C.max_integrity)
		else if(issilicon(M))
			var/mob/living/silicon/S = M
			if(S.health == S.maxHealth || S.stat == DEAD || !is_servant_of_ratvar(S))
				continue
			if(!try_use_power(cyborg_cost))
				break
			S.adjustBruteLoss(-20)
			S.adjustFireLoss(-10)
	return 1

/obj/structure/destructible/clockwork/powered/mending_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE))
		if(total_accessable_power() < mob_cost)
			user << "<span class='warning'>[src] needs more power or replicant alloy to function!</span>"
			return 0
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/mending_motor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user))
		if(stored_alloy + REPLICANT_ALLOY_POWER > max_alloy)
			user << "<span class='warning'>[src] is too full to accept any more alloy!</span>"
			return 0
		playsound(user, 'sound/machines/click.ogg', 50, 1)
		clockwork_say(user, text2ratvar("Transmute into fuel."), TRUE)
		user << "<span class='brass'>You force [I] to liquify and pour it into [src]'s compartments. \
		It now contains <b>[stored_alloy*CLOCKCULT_POWER_TO_ALLOY_MULTIPLIER]/[max_alloy*CLOCKCULT_POWER_TO_ALLOY_MULTIPLIER]</b> units of liquified alloy.</span>"
		stored_alloy = stored_alloy + REPLICANT_ALLOY_POWER
		user.drop_item()
		qdel(I)
		return 1
	else
		return ..()



/obj/structure/destructible/clockwork/powered/mania_motor //Mania motor: A pair of antenna that, while active, cause braindamage and hallucinations in nearby human mobs.
	name = "mania motor"
	desc = "A pair of antenna with what appear to be sockets around the base. It reminds you of an antlion."
	clockwork_desc = "A transmitter that allows Sevtug to whisper into the minds of nearby non-servants, causing hallucinations and brain damage as long as it remains powered."
	icon_state = "mania_motor_inactive"
	active_icon = "mania_motor"
	inactive_icon = "mania_motor_inactive"
	construction_value = 20
	max_integrity = 80
	obj_integrity = 80
	break_message = "<span class='warning'>The antenna break off, leaving a pile of shards!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/small = 3, \
	/obj/item/clockwork/component/guvax_capacitor/antennae = 1)
	var/mania_cost = 200
	var/convert_attempt_cost = 200
	var/convert_cost = 200

	var/mania_messages = list("\"Go nuts.\"", "\"Take a crack at crazy.\"", "\"Make a bid for insanity.\"", "\"Get kooky.\"", "\"Move towards mania.\"", "\"Become bewildered.\"", "\"Wax wild.\"", \
	"\"Go round the bend.\"", "\"Land in lunacy.\"", "\"Try dementia.\"", "\"Strive to get a screw loose.\"")
	var/compel_messages = list("\"Come closer.\"", "\"Approach the transmitter.\"", "\"Touch the antennae.\"", "\"I always have to deal with idiots. Move towards the mania motor.\"", \
	"\"Advance forward and place your head between the antennae - that's all it's good for.\"", "\"If you were smarter, you'd be over here already.\"", "\"Move FORWARD, you fool.\"")
	var/convert_messages = list("\"You won't do. Go to sleep while I tell these nitwits how to convert you.\"", "\"You are insufficient. I must instruct these idiots in the art of conversion.\"", \
	"\"Oh of course, someone we can't convert. These servants are fools.\"", "\"How hard is it to use a Sigil, anyway? All it takes is dragging someone onto it.\"", \
	"\"How do they fail to use a Sigil of Accession, anyway?\"", "\"Why is it that all servants are this inept?\"", "\"It's quite likely you'll be stuck here for a while.\"")
	var/close_messages = list("\"Well, you can't reach the motor from THERE, you moron.\"", "\"Interesting location. I'd prefer if you went somewhere you could ACTUALLY TOUCH THE ANTENNAE!\"", \
	"\"Amazing. You somehow managed to wedge yourself somewhere you can't actually reach the motor from.\"", "\"Such a show of idiocy is unparalleled. Perhaps I should put you on display?\"", \
	"\"Did you do this on purpose? I can't imagine you doing so accidentally. Oh, wait, I can.\"", "\"How is it that such smart creatures can still do something AS STUPID AS THIS!\"")


/obj/structure/destructible/clockwork/powered/mania_motor/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='sevtug_small'>It requires <b>[mania_cost]W</b> to run, and <b>[convert_attempt_cost + convert_cost]W</b> to convert humans adjecent to it.</span>"

/obj/structure/destructible/clockwork/powered/mania_motor/process()
	if(!..())
		visible_message("<span class='warning'>[src] hums loudly, then the sockets at its base fall dark!</span>")
		playsound(src, 'sound/effects/screech.ogg', 40, 1)
		toggle(0)
		return
	if(try_use_power(mania_cost))
		var/turf/T = get_turf(src)
		var/hum = get_sfx('sound/effects/screech.ogg') //like playsound, same sound for everyone affected
		for(var/mob/living/carbon/human/H in view(1, src))
			if(is_servant_of_ratvar(H))
				continue
			if(H.Adjacent(src) && try_use_power(convert_attempt_cost))
				if(is_eligible_servant(H) && try_use_power(convert_cost))
					H << "<span class='sevtug'>\"[text2ratvar("You are mine and his, now.")]\"</span>"
					H.playsound_local(T, hum, 80, 1)
					add_servant_of_ratvar(H)
				else if(!H.stat)
					if(H.getBrainLoss() >= 100)
						H.Paralyse(5)
						H << "<span class='sevtug'>[text2ratvar(pick(convert_messages))]</span>"
					else
						H.adjustBrainLoss(100)
						H.visible_message("<span class='warning'>[H] reaches out and touches [src].</span>", "<span class='sevtug'>You touch [src] involuntarily.</span>")
			else
				visible_message("<span class='warning'>[src]'s antennae fizzle quietly.</span>")
				playsound(src, 'sound/effects/light_flicker.ogg', 50, 1)
		for(var/mob/living/carbon/human/H in range(10, src))
			if(is_servant_of_ratvar(H))
				if(H.getBrainLoss() || H.hallucination || H.druggy || H.dizziness || H.confused)
					H.adjustBrainLoss(-H.getBrainLoss()) //heals servants of braindamage, hallucination, druggy, dizziness, and confusion
					H.hallucination = 0
					H.adjust_drugginess(-H.druggy)
					H.dizziness = 0
					H.confused = 0
			else if(!H.null_rod_check() && H.stat == CONSCIOUS)
				var/distance = get_dist(T, get_turf(H))
				var/falloff_distance = min((110) - distance * 10, 80)
				var/sound_distance = falloff_distance * 0.5
				var/targetbrainloss = H.getBrainLoss()
				if(distance >= 4 && prob(falloff_distance * 0.5))
					H << "<span class='sevtug_small'>[text2ratvar(pick(mania_messages))]</span>"
				H.playsound_local(T, hum, sound_distance, 1)
				switch(distance)
					if(2 to 3)
						if(prob(falloff_distance * 0.5))
							if(prob(falloff_distance))
								H << "<span class='sevtug_small'>[text2ratvar(pick(mania_messages))]</span>"
							else
								H << "<span class='sevtug'>[text2ratvar(pick(compel_messages))]</span>"
						if(targetbrainloss <= 50)
							H.adjustBrainLoss(50 - targetbrainloss) //got too close had brain eaten
						H.adjust_drugginess(Clamp(7, 0, 100 - H.druggy))
						H.hallucination = min(H.hallucination + 7, 100)
						H.dizziness = min(H.dizziness + 3, 45)
						H.confused = min(H.confused + 3, 45)
					if(4 to 5)
						if(targetbrainloss <= 50)
							H.adjustBrainLoss(1)
						H.adjust_drugginess(Clamp(5, 0, 80 - H.druggy))
						H.hallucination = min(H.hallucination + 5, 80)
						H.dizziness = min(H.dizziness + 2, 30)
						H.confused = min(H.confused + 2, 30)
					if(6 to 7)
						if(targetbrainloss <= 30)
							H.adjustBrainLoss(1)
						H.adjust_drugginess(Clamp(2, 0, 60 - H.druggy))
						H.hallucination = min(H.hallucination + 2, 60)
						H.dizziness = min(H.dizziness + 2, 15)
						H.confused = min(H.confused + 2, 15)
					if(8 to 9)
						if(targetbrainloss <= 10)
							H.adjustBrainLoss(1)
						H.adjust_drugginess(Clamp(2, 0, 40 - H.druggy))
						H.hallucination = min(H.hallucination + 2, 40)
					if(10 to INFINITY)
						H.adjust_drugginess(Clamp(2, 0, 20 - H.druggy))
						H.hallucination = min(H.hallucination + 2, 20)
					else //if it's a distance of 1 and they can't see it/aren't adjacent or they're on top of it(how'd they get on top of it and still trigger this???)
						if(prob(falloff_distance * 0.5))
							if(prob(falloff_distance))
								H << "<span class='sevtug'>[text2ratvar(pick(compel_messages))]</span>"
							else if(prob(falloff_distance * 0.5))
								H << "<span class='sevtug'>[text2ratvar(pick(close_messages))]</span>"
							else
								H << "<span class='sevtug_small'>[text2ratvar(pick(mania_messages))]</span>"
						if(targetbrainloss <= 99)
							H.adjustBrainLoss(99 - targetbrainloss)
						H.adjust_drugginess(Clamp(10, 0, 150 - H.druggy))
						H.hallucination = min(H.hallucination + 10, 150)
						H.dizziness = min(H.dizziness + 5, 60)
						H.confused = min(H.confused + 5, 60)

	else
		visible_message("<span class='warning'>[src] hums loudly, then the sockets at its base fall dark!</span>")
		playsound(src, 'sound/effects/screech.ogg', 40, 1)
		toggle(0)

/obj/structure/destructible/clockwork/powered/mania_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE))
		if(!total_accessable_power() >= mania_cost)
			user << "<span class='warning'>[src] needs more power to function!</span>"
			return 0
		toggle(0, user)



/obj/structure/destructible/clockwork/powered/interdiction_lens //Interdiction lens: A powerful artifact that constantly disrupts electronics but, if it fails to find something to disrupt, turns off.
	name = "interdiction lens"
	desc = "An ominous, double-pronged brass totem. There's a strange gemstone clasped between the pincers."
	clockwork_desc = "A powerful totem that constantly drains nearby electronics and funnels the power drained into nearby Sigils of Transmission."
	icon_state = "interdiction_lens"
	construction_value = 25
	active_icon = "interdiction_lens_active"
	inactive_icon = "interdiction_lens"
	break_message = "<span class='warning'>The lens flares a blinding violet before shattering!</span>"
	break_sound = 'sound/effects/Glassbr3.ogg'
	var/recharging = 0 //world.time when the lens was last used
	var/recharge_time = 1200 //if it drains no power and affects no objects, it turns off for two minutes
	var/disabled = FALSE //if it's actually usable
	var/interdiction_range = 14 //how large an area it drains and disables in

/obj/structure/destructible/clockwork/powered/interdiction_lens/examine(mob/user)
	..()
	user << "<span class='[recharging > world.time ? "nezbere_small":"brass"]'>Its gemstone [recharging > world.time ? "has been breached by writhing tendrils of blackness that cover the totem" \
	: "vibrates in place and thrums with power"].</span>"
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='nezbere_small'>If it fails to drain any electronics, it will disable itself for <b>[round(recharge_time/600, 1)]</b> minutes.</span>"

/obj/structure/destructible/clockwork/powered/interdiction_lens/toggle(fast_process, mob/living/user)
	..()
	if(active)
		SetLuminosity(4,2)
	else
		SetLuminosity(0)

/obj/structure/destructible/clockwork/powered/interdiction_lens/attack_hand(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE))
		if(disabled)
			user << "<span class='warning'>As you place your hand on the gemstone, cold tendrils of black matter crawl up your arm. You quickly pull back.</span>"
			return 0
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/interdiction_lens/process()
	if(recharging > world.time)
		return
	if(disabled)
		visible_message("<span class='warning'>The writhing tendrils return to the gemstone, which begins to glow with power!</span>")
		flick("interdiction_lens_recharged", src)
		disabled = FALSE
		toggle(0)
	else
		var/successfulprocess = FALSE
		var/power_drained = 0
		var/list/atoms_to_test = list()
		for(var/A in spiral_range_turfs(interdiction_range, src))
			var/turf/T = A
			for(var/M in T)
				atoms_to_test |= M

			CHECK_TICK

		for(var/M in atoms_to_test)
			var/atom/movable/A = M
			power_drained += A.power_drain(TRUE)

			if(istype(A, /obj/machinery/camera))
				var/obj/machinery/camera/C = A
				if(C.isEmpProof() || !C.status)
					continue
				successfulprocess = TRUE
				if(C.emped)
					continue
				C.emp_act(1)
			else if(istype(A, /obj/item/device/radio))
				var/obj/item/device/radio/O = A
				successfulprocess = TRUE
				if(O.emped || !O.on)
					continue
				O.emp_act(1)
			else if((isliving(A) && !is_servant_of_ratvar(A)) || istype(A, /obj/structure/closet) || istype(A, /obj/item/weapon/storage)) //other things may have radios in them but we don't care
				for(var/obj/item/device/radio/O in A.GetAllContents())
					successfulprocess = TRUE
					if(O.emped || !O.on)
						continue
					O.emp_act(1)

			CHECK_TICK

		if(power_drained && power_drained >= MIN_CLOCKCULT_POWER && return_power(power_drained))
			successfulprocess = TRUE
			playsound(src, 'sound/items/PSHOOM.ogg', 50, 1, interdiction_range-7, 1)

		if(!successfulprocess)
			visible_message("<span class='warning'>The gemstone suddenly turns horribly dark, writhing tendrils covering it!</span>")
			recharging = world.time + recharge_time
			flick("interdiction_lens_discharged", src)
			icon_state = "interdiction_lens_inactive"
			SetLuminosity(2,1)
			disabled = TRUE



/obj/structure/destructible/clockwork/powered/clockwork_obelisk
	name = "clockwork obelisk"
	desc = "A large brass obelisk hanging in midair."
	clockwork_desc = "A powerful obelisk that can send a message to all servants or open a gateway to a target servant or clockwork obelisk."
	icon_state = "obelisk_inactive"
	active_icon = "obelisk"
	inactive_icon = "obelisk_inactive"
	construction_value = 20
	max_integrity = 150
	obj_integrity = 150
	break_message = "<span class='warning'>The obelisk falls to the ground, undamaged!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/small = 3, \
	/obj/item/clockwork/component/hierophant_ansible/obelisk = 1)
	var/hierophant_cost = MIN_CLOCKCULT_POWER //how much it costs to broadcast with large text
	var/gateway_cost = 2000 //how much it costs to open a gateway
	var/gateway_active = FALSE

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/New()
	..()
	toggle(1)

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='nzcrentr_small'>It requires <b>[hierophant_cost]W</b> to broadcast over the Hierophant Network, and <b>[gateway_cost]W</b> to open a Spatial Gateway.</span>"

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/process()
	if(locate(/obj/effect/clockwork/spatial_gateway) in loc)
		icon_state = active_icon
		density = 0
		gateway_active = TRUE
	else
		icon_state = inactive_icon
		density = 1
		gateway_active = FALSE

/obj/structure/destructible/clockwork/powered/clockwork_obelisk/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user) || !total_accessable_power() >= hierophant_cost)
		user << "<span class='warning'>You place your hand on the obelisk, but it doesn't react.</span>"
		return
	var/choice = alert(user,"You place your hand on the obelisk...",,"Hierophant Broadcast","Spatial Gateway","Cancel")
	switch(choice)
		if("Hierophant Broadcast")
			if(gateway_active)
				user << "<span class='warning'>The obelisk is sustaining a gateway and cannot broadcast!</span>"
				return
			var/input = stripped_input(usr, "Please choose a message to send over the Hierophant Network.", "Hierophant Broadcast", "")
			if(!input || !user.canUseTopic(src, BE_CLOSE))
				return
			if(gateway_active)
				user << "<span class='warning'>The obelisk is sustaining a gateway and cannot broadcast!</span>"
				return
			if(!try_use_power(hierophant_cost))
				user << "<span class='warning'>The obelisk lacks the power to broadcast!</span>"
				return
			clockwork_say(user, text2ratvar("Hierophant Broadcast, activate!"))
			titled_hierophant_message(user, input, "big_brass", "large_brass")
		if("Spatial Gateway")
			if(gateway_active)
				user << "<span class='warning'>The obelisk is already sustaining a gateway!</span>"
				return
			if(!try_use_power(gateway_cost))
				user << "<span class='warning'>The obelisk lacks the power to open a gateway!</span>"
				return
			if(procure_gateway(user, 100, 5, 1) && !gateway_active)
				clockwork_say(user, text2ratvar("Spatial Gateway, activate!"))
			else
				return_power(gateway_cost)
		if("Cancel")
			return
