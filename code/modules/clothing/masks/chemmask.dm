//**************************************************************
// Chemical Mask
//**************************************************************
//Icons are in masks.dmi, chempack.dmi (left), chempack.dmi (right), and mask.dmi

//This item is designed to grant support utility to the chemical pack, once the chemical pack's safeties are overridden.
//The chemical pack has a 1200u primary tank, from which it will take a certain amount of each reagent in the pack and
//inject it into the wearer. The amount taken from the primary tank is determined by tank_injection_rate, which defaults
//to 10, and can be altered by the user with a verb. The amount taken from the primary tank is altered slightly per-reagent,
//based on that reagent's custom_metabolism value, in order to avoid taking too much of a reagent just because that reagent
//happens to metabolize more slowly than others.

//Additionally, the chemical pack has an auxiliary chamber which can store any /obj/item/weapon/reagent_containers/glass item.
//While capped at the largest beaker size, currently 300u, this chamber offers more control over the way in which reagents
//are administered from it. It defaults to a threshold-based system, in which it injects 10u of creatine when the user falls
//below 10u of creatine in their body. However, the user can alter the settings and change it to a time-based system, change
//the time interval, the amount injected, and the reagent monitored by the threshold system, through verbs.

//By default, the primary tank is connected to the mask, and the auxiliary beaker is disconnected. The user may toggle these
//connections using verbs. When disconnected, the mask will not take any additional reagents from the primary tank and/or the
//auxiliary beaker. Cycling these verbs will not force injections, the tank is still only capable of one injection per 97 seconds,
//and the beaker has no need to be forced to inject since the user can alter its time interval directly.
#define THRESHOLD "Threshold-based"
#define TIME "Time-based"

/obj/item/clothing/mask/chemmask
	desc = "A rather sinister mask designed for connection to a chemical pack, providing the pack's safeties are disabled."
	name = "chemical mask"
	icon_state = "chemmask0"
	flags = FPRINT | MASKINTERNALS
	w_class = 2
	var/power = 0
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	var/tank_injection_rate = 10
	var/tank_has_injected = 0
	var/beaker_injection_methods = list(TIME,THRESHOLD)
	var/beaker_injection_method = THRESHOLD
	var/injection_method_chosen = 0
	var/beaker_time_interval = 970
	var/beaker_injection_rate = 10
	var/beaker_threshold = 10
	var/beaker_threshold_reagent = "creatine"
	var/beaker_has_injected_time = 0
	var/firstalert_tank = 0
	var/firstalert_beaker = 0
	var/beakeractive = 0
	var/tankactive = 1
	var/time_at_last_tank_inject = 0 //This will ensure that the mask will always inject instantly the first time the user turns it on.
	var/time_at_last_beaker_inject = 0 //It will prevent the chemmask from functioning for the first minute and 37 seconds of the world's existence, but I don't think that'll ever be a problem.
	var/beaker_verbs_time = list(
		/obj/item/clothing/mask/chemmask/verb/set_beaker_time_interval
		)
	var/beaker_verbs_threshold = list(
		/obj/item/clothing/mask/chemmask/verb/set_beaker_threshold,
		/obj/item/clothing/mask/chemmask/verb/set_beaker_threshold_reagent
		)
	species_fit = list("Vox")
	body_parts_covered = HEAD|MOUTH
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/chempack.dmi', "right_hand" = 'icons/mob/in-hand/right/chempack.dmi')
	origin_tech = "biotech=5;materials=5;engineering=5;syndicate=5;combat=5"

/obj/item/clothing/mask/chemmask/New() //Doing this so that these verbs don't show up before there's actually a beaker in the pack.
	..()
	processing_objects.Add(src)
	update_verbs()

/obj/item/clothing/mask/chemmask/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/clothing/mask/chemmask/equipped(M as mob, wear_mask)
	var/mob/living/carbon/human/H = M
	if(H.wear_mask == src)
		update_verbs()

/obj/item/clothing/mask/chemmask/proc/update_verbs()
	var/mob/living/carbon/human/H
	if (power)
		verbs += /obj/item/clothing/mask/chemmask/verb/set_pack_injection
	else
		verbs -= /obj/item/clothing/mask/chemmask/verb/set_pack_injection
	if (istype(loc,/mob/living/carbon/human)) //It runtimes if it calls this on a turf, which it does when it first spawns.
		H = loc
	else
		return
	if (istype(H.back,/obj/item/weapon/reagent_containers/chempack))
		verbs += /obj/item/clothing/mask/chemmask/verb/set_tank_usage
	else
		verbs -= /obj/item/clothing/mask/chemmask/verb/set_tank_usage
	if (has_beaker(H))
		verbs += /obj/item/clothing/mask/chemmask/verb/set_beaker_usage
		verbs += /obj/item/clothing/mask/chemmask/verb/set_beaker_injection_method
		if (injection_method_chosen) //Don't want the user to have to select the beaker injection method more than once per item.
			if (beaker_injection_method == THRESHOLD)
				verbs += beaker_verbs_threshold
				verbs += /obj/item/clothing/mask/chemmask/verb/set_beaker_injection_rate
				verbs -= beaker_verbs_time
			else if (beaker_injection_method == TIME)
				verbs += beaker_verbs_time
				verbs += /obj/item/clothing/mask/chemmask/verb/set_beaker_injection_rate
				verbs -= beaker_verbs_threshold
		else
			verbs -= beaker_verbs_time
			verbs -= beaker_verbs_threshold
			verbs -= /obj/item/clothing/mask/chemmask/verb/set_beaker_injection_rate
	else
		verbs -= /obj/item/clothing/mask/chemmask/verb/set_beaker_usage
		verbs -= /obj/item/clothing/mask/chemmask/verb/set_beaker_injection_method
		verbs -= beaker_verbs_time
		verbs -= beaker_verbs_threshold

/obj/item/clothing/mask/chemmask/proc/can_use_verbs(mob/user)
	var/mob/living/carbon/human/M = user
	if (M.stat == DEAD)
		to_chat(user, "You can't do that while you're dead!")
		return 0
	else if (M.stat == UNCONSCIOUS)
		to_chat(user, "You must be conscious to do this!")
		return 0
	else if (M.handcuffed)
		to_chat(user, "You can't reach the controls while you're restrained!")
		return 0
	else
		return 1

/obj/item/clothing/mask/chemmask/examine(mob/user)
	..()
	if (power)
		to_chat(user, "The mask is active!")
		if (tankactive)
			to_chat(user, "The mask is drawing from the main tank.")
		else
			to_chat(user, "The mask is not drawing from the main tank.")
		if (beakeractive && has_beaker(user))
			to_chat(user, "The mask is drawing from the auxiliary beaker.")
		else if (!beakeractive && has_beaker(user))
			to_chat(user, "The mask is not drawing from the auxiliary beaker.")
	else
		var/mob/living/carbon/human/M = user
		if(M.wear_mask == src)
			to_chat(user, "The mask is inactive.")
			if (tankactive)
				to_chat(user, "The mask is set to draw from the main tank.")
			else
				to_chat(user, "The mask is not set to draw from the main tank.")
			if (beakeractive && has_beaker(user))
				to_chat(user, "The mask is set to draw from the auxiliary beaker.")
			else if (!beakeractive && has_beaker(user))
				to_chat(user, "The mask is not set to draw from the auxiliary beaker.")

/obj/item/clothing/mask/chemmask/verb/toggle_power()
	set name = "Toggle mask power"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	if (!power)
		var/mob/living/M = usr
		if (istype(M.back,/obj/item/weapon/reagent_containers/chempack))
			var/obj/item/weapon/reagent_containers/chempack/P = M.back
			if (P.safety)
				to_chat(usr, "<span class='notice'>You activate \the [src].</span>")
				power = 1
				icon_state = "chemmask1"
//				start_flow(usr)
				usr.update_inv_wear_mask()
				update_verbs()
			else
				to_chat(usr, "<span class='warning'>You must disable \the [P]'s safeties before you can activate \the [src]!</span>")
		else
			to_chat(usr, "<span class='warning'>You need to be wearing a chemical pack before you can activate \the [src]!</span>")
	else
		to_chat(usr, "<span class='notice'>You deactivate \the [src].</span>")
		mask_shutdown(usr)

/obj/item/clothing/mask/chemmask/verb/set_pack_injection()
	set name = "Set main tank injection rate"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	var/N = input("Set the number of units of each reagent in the chemical pack to be injected every 100 seconds. The injection rates of some chemicals will be altered to account for different rates of metabolism. Going over 10u may cause overdosing with some chemicals:","[src]") as null|num
	//It's actually 97 seconds, so that more chems are injected before the user completely runs out. But 100 seconds sounded better and the player won't know the difference.
	if (N)
		tank_injection_rate = N

/obj/item/clothing/mask/chemmask/verb/set_beaker_usage()
	set name = "Toggle auxiliary beaker usage"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	if (!beakeractive)
		beakeractive = 1
		to_chat(usr, "<span class='notice'>You enable connection to the chemical pack's auxiliary beaker chamber.</span>")
	else
		beakeractive = 0
		to_chat(usr, "<span class='notice'>You disable connection to the chemical pack's auxiliary beaker chamber.</span>")

/obj/item/clothing/mask/chemmask/verb/set_tank_usage()
	set name = "Toggle primary tank usage"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	if (!tankactive)
		tankactive = 1
		to_chat(usr, "<span class='notice'>You enable connection to the chemical pack's primary tank system.</span>")
	else
		tankactive = 0
		to_chat(usr, "<span class='notice'>You disable connection to the chemical pack's primary tank system.</span>")

/obj/item/clothing/mask/chemmask/verb/set_beaker_injection_method()
	set name = "Set auxiliary beaker injection method"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	var/N = input("Set the method by which \the [src] determines when to administer more chemicals from the auxiliary beaker:","[src]") as null|anything in beaker_injection_methods
	if (N)
		beaker_injection_method = N
		injection_method_chosen = 1
		update_verbs()

/obj/item/clothing/mask/chemmask/verb/set_beaker_injection_rate()
	set name = "Set auxiliary beaker injection rate"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	var/N = input("Set the amount of chemicals administered from the auxiliary beaker when \the [src] administers more chemicals:","[src]") as null|num
	if (N)
		beaker_injection_rate = N

/obj/item/clothing/mask/chemmask/verb/set_beaker_time_interval()
	set name = "Set auxiliary beaker injection time interval"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	var/N = input("Set the time interval in seconds at which \the [src] will administer more chemicals from the auxiliary beaker:","[src]") as null|num
	if (N)
		beaker_time_interval = N*10

/obj/item/clothing/mask/chemmask/verb/set_beaker_threshold_reagent()
	set name = "Set auxiliary beaker injection threshold reagent"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	var/obj/item/weapon/reagent_containers/chempack/P = usr.back
	var/obj/item/weapon/reagent_containers/glass/B = P.beaker
	var/beaker_threshold_reagents = B.get_reagent_ids()

	var/N = input("Set the reagent for which the minimum threshold must be reached to cause \the [src] to administer more chemicals from the auxiliary beaker:","[src]") as null|anything in beaker_threshold_reagents
	if (N)
		beaker_threshold_reagent = N

/obj/item/clothing/mask/chemmask/verb/set_beaker_threshold()
	set name = "Set auxiliary beaker injection threshold"
	set category = "Object"
	set src in usr

	if (!can_use_verbs(usr))
		return

	var/N = input("Set the minimum threshold of [beaker_threshold_reagent] in your body that must be reached to cause \the [src] to administer more chemicals:","[src]") as null|num
	if (N)
		beaker_threshold = N

/obj/item/clothing/mask/chemmask/proc/pack_check(mob/user) //Shuts off mask if the user is not wearing a chempack.
	var/mob/living/M = user
	if (!(M && M.back && istype(M.back,/obj/item/weapon/reagent_containers/chempack)))
		mask_shutdown(user)
		to_chat(user, "<span class='notice'>\The [src] shuts off!</span>")
		return 0
	else
		return 1

/obj/item/clothing/mask/chemmask/proc/mask_check(mob/user) //Shuts off mask if it is not being worn by someone.
	var/mob/living/M = user
	if (!(M && M.wear_mask && istype(M.wear_mask,/obj/item/clothing/mask/chemmask)))
		mask_shutdown(user)
		to_chat(user, "<span class='notice'>\The [src] shuts off!</span>")
		return 0
	else if (!(M.wear_mask == src))
		mask_shutdown(user)
		to_chat(user, "<span class='notice'>\The [src] shuts off!</span>")
		return 0
	else
		return 1

/obj/item/clothing/mask/chemmask/proc/tank_volume_check(mob/user) //Alerts the user when the tank runs out of reagents. Does not alert them more than once per emptying, it must be refilled and then run dry again to alert them again.
	var/obj/item/weapon/reagent_containers/chempack/P = user.back
	if (P.is_empty() && firstalert_tank == 0 && tankactive)
		firstalert_tank = 1
		to_chat(user, "<span class='warning'>The chemical pack is empty!</span>")
	else if (!P.is_empty())
		firstalert_tank = 0

/obj/item/clothing/mask/chemmask/proc/has_beaker(mob/user) //Checks whether there is a beaker in the pack, in order to determine whether to show the beaker-specific verbs.
	if(user.back && istype(user.back, /obj/item/weapon/reagent_containers/chempack))
		var/obj/item/weapon/reagent_containers/chempack/P = user.back
		return !isnull(P.beaker)

/obj/item/clothing/mask/chemmask/proc/beaker_volume_check(mob/user) //Alerts the user when the auxiliary beaker is empty. Unlike the tank alert, this alert plays a sound, since the auxiliary beaker will most likely have higher-priority chems in it.
	var/obj/item/weapon/reagent_containers/chempack/P = user.back
	var/obj/item/weapon/reagent_containers/glass/B = P.beaker
	if (B.is_empty() && firstalert_beaker == 0)
		firstalert_beaker = 1
		playsound(get_turf(src),'sound/mecha/internaldmgalarm.ogg', 100, 1)
		to_chat(user, "<span class='warning'>The auxiliary beaker is empty!</span>")
	else if (!B.is_empty())
		firstalert_beaker = 0

/obj/item/clothing/mask/chemmask/proc/mask_shutdown(mob/user) //Removes most verbs upon toggling the mask off, but not all. The user keeps access to the verbs to toggle connection to the tank and beaker.
	power = 0
	icon_state = "chemmask0"
	user.update_inv_wear_mask()
	update_verbs()

/obj/item/clothing/mask/chemmask/process()
	var/mob/living/carbon/human/H = loc
	if(power)
		if (!pack_check(H))
			return
		if (!mask_check(H))
			return
		tank_volume_check(H)
		update_verbs()
		if ((world.time - time_at_last_tank_inject) >= 970) //One minute thirty-seven seconds. Roughly the time it takes 10u of anti-toxin to be metabolized.
			tank_has_injected = 0
		if (tankactive)
			if (!tank_has_injected)
				inject(H)
				tank_has_injected = 1
				time_at_last_tank_inject = world.time
		if ((world.time - time_at_last_beaker_inject) >= beaker_time_interval)
			beaker_has_injected_time = 0
		if (has_beaker(H))
			if (beakeractive)
				if (beaker_injection_method == TIME && !beaker_has_injected_time)
					beakerinject(H)
					beaker_has_injected_time = 1
					time_at_last_beaker_inject = world.time
				else if (beaker_injection_method == THRESHOLD)
					beakerinject(H)
				beaker_volume_check(H)

/obj/item/clothing/mask/chemmask/proc/inject(mob/user)
	var/obj/item/weapon/reagent_containers/chempack/P = user.back
	for(var/datum/reagent/R in P.reagents.reagent_list)
		var/custom_injection_rate = (tank_injection_rate/(REAGENTS_METABOLISM/R.custom_metabolism))
		if (R.custom_metabolism == 0.03)
			custom_injection_rate += 0.1
		if (R.custom_metabolism == 0.05)
			custom_injection_rate += R.custom_metabolism
		P.reagents.trans_id_to(user, R.id, custom_injection_rate)

/obj/item/clothing/mask/chemmask/proc/beakerinject(mob/user)
	var/obj/item/weapon/reagent_containers/chempack/P = user.back
	var/obj/item/weapon/reagent_containers/glass/B = P.beaker
	if (beaker_injection_method == TIME)
		B.reagents.trans_to(user, beaker_injection_rate)
	else if (beaker_injection_method == THRESHOLD)
		var/shouldinject = 0
		var/datum/reagent/R1 = null
		var/beakerhasreagent = 0
		var/userhasreagent = 0
		var/shouldnotinject = 0
		for(var/datum/reagent/R in B.reagents.reagent_list) //Cycle through each reagent in the beaker.
			if (R.id == beaker_threshold_reagent)
				R1 = R
				beakerhasreagent = 1
		for(var/datum/reagent/RU in user.reagents.reagent_list) //Cycle through each reagent in the user.
			if (RU.id == beaker_threshold_reagent)
				userhasreagent = 1
				if (RU.volume > beaker_threshold) //If the user has more of the threshold reagent than the threshold, don't inject at all.
					shouldnotinject = 1
			if ((RU.id == beaker_threshold_reagent) && (RU.volume < beaker_threshold))
				shouldinject = 1
				userhasreagent = 1

		if (shouldinject && R1)
			if (R1.volume < beaker_injection_rate)
				var/T = R1.volume
				B.reagents.trans_id_to(user, R1.id, beaker_injection_rate)
				B.reagents.trans_to(user, (beaker_injection_rate - T))
			else
				B.reagents.trans_id_to(user, R1.id, beaker_injection_rate)

		else if (!userhasreagent && beakerhasreagent)
			B.reagents.trans_id_to(user, R1.id, beaker_injection_rate)
		else if (!beakerhasreagent && !shouldnotinject)
			B.reagents.trans_to(user, beaker_injection_rate)