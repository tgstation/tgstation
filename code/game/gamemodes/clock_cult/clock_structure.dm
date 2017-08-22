//The base clockwork structure. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/structure/destructible/clockwork
	name = "meme structure"
	desc = "Some frog or something, the fuck?"
	var/clockwork_desc //Shown to servants when they examine
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	var/unanchored_icon //icon for when this structure is unanchored, doubles as the var for if it can be unanchored
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/can_be_repaired = TRUE //if a fabricator can repair it
	break_message = "<span class='warning'>The frog isn't a meme after all!</span>" //The message shown when a structure breaks
	break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/medium = 2, \
	/obj/item/clockwork/alloy_shards/small = 3) //Parts left behind when a structure breaks
	var/construction_value = 0 //How much value the structure contributes to the overall "power" of the structures on the station
	var/immune_to_servant_attacks = FALSE //if we ignore attacks from servants of ratvar instead of taking damage

/obj/structure/destructible/clockwork/Initialize()
	. = ..()
	change_construction_value(construction_value)
	GLOB.all_clockwork_objects += src

/obj/structure/destructible/clockwork/Destroy()
	change_construction_value(-construction_value)
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/structure/destructible/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens || GLOB.clockwork_gateway_activated)
		obj_integrity = max_integrity

/obj/structure/destructible/clockwork/narsie_act()
	if(take_damage(rand(25, 50), BRUTE) && src) //if we still exist
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/obj/structure/destructible/clockwork/examine(mob/user)
	var/can_see_clockwork = is_servant_of_ratvar(user) || isobserver(user)
	if(can_see_clockwork && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)
	if(unanchored_icon)
		to_chat(user, "<span class='notice'>[src] is [anchored ? "":"not "]secured to the floor.</span>")

/obj/structure/destructible/clockwork/examine_status(mob/user)
	if(is_servant_of_ratvar(user) || isobserver(user))
		var/t_It = p_they(TRUE)
		var/t_is = p_are()
		var/heavily_damaged = FALSE
		var/healthpercent = (obj_integrity/max_integrity) * 100
		if(healthpercent < 50)
			heavily_damaged = TRUE
		return "<span class='[heavily_damaged ? "alloy":"brass"]'>[t_It] [t_is] at <b>[obj_integrity]/[max_integrity]</b> integrity[heavily_damaged ? "!":"."]</span>"
	return ..()

/obj/structure/destructible/clockwork/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(is_servant_of_ratvar(user) && immune_to_servant_attacks)
		return FALSE
	return ..()

/obj/structure/destructible/clockwork/hulk_damage()
	return 20

/obj/structure/destructible/clockwork/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(is_servant_of_ratvar(user) && immune_to_servant_attacks)
		return FALSE
	return ..()

/obj/structure/destructible/clockwork/mech_melee_attack(obj/mecha/M)
	if(M.occupant && is_servant_of_ratvar(M.occupant) && immune_to_servant_attacks)
		return FALSE
	return ..()

/obj/structure/destructible/clockwork/proc/get_efficiency_mod(increasing)
	if(GLOB.ratvar_awakens)
		if(increasing)
			return 0.5
		return 2
	. = max(sqrt(obj_integrity/max(max_integrity, 1)), 0.5)
	if(increasing)
		. *= min(max_integrity/max(obj_integrity, 1), 4)
	. = round(., 0.01)

/obj/structure/destructible/clockwork/attack_ai(mob/user)
	if(is_servant_of_ratvar(user))
		attack_hand(user)

/obj/structure/destructible/clockwork/attack_animal(mob/living/simple_animal/M)
	if(is_servant_of_ratvar(M))
		attack_hand(M)
		return FALSE
	else
		return ..()

/obj/structure/destructible/clockwork/attackby(obj/item/I, mob/user, params)
	if(is_servant_of_ratvar(user) && istype(I, /obj/item/wrench) && unanchored_icon)
		if(default_unfasten_wrench(user, I, 50) == SUCCESSFUL_UNFASTEN)
			update_anchored(user)
		return 1
	return ..()

/obj/structure/destructible/clockwork/attacked_by(obj/item/I, mob/living/user)
	if(is_servant_of_ratvar(user) && immune_to_servant_attacks)
		return FALSE
	return ..()

/obj/structure/destructible/clockwork/proc/update_anchored(mob/user, do_damage)
	if(anchored)
		icon_state = initial(icon_state)
	else
		icon_state = unanchored_icon
		if(do_damage)
			playsound(src, break_sound, 10 * get_efficiency_mod(TRUE), 1)
			take_damage(round(max_integrity * 0.25, 1), BRUTE)
			to_chat(user, "<span class='warning'>As you unsecure [src] from the floor, you see cracks appear in its surface!</span>")

/obj/structure/destructible/clockwork/emp_act(severity)
	if(anchored && unanchored_icon)
		anchored = FALSE
		update_anchored(null, obj_integrity > max_integrity * 0.25)
		new /obj/effect/temp_visual/emp(loc)


//for the ark and Ratvar
/obj/structure/destructible/clockwork/massive
	name = "massive construct"
	desc = "A very large construction."
	layer = MASSIVE_OBJ_LAYER
	density = FALSE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/structure/destructible/clockwork/massive/Initialize()
	. = ..()
	GLOB.poi_list += src

/obj/structure/destructible/clockwork/massive/Destroy()
	GLOB.poi_list -= src
	return ..()

/obj/structure/destructible/clockwork/massive/singularity_pull(S, current_size)
	return


//the base clockwork machinery, which is not actually machines, but happens to use power
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
		var/sigil_number = LAZYLEN(check_apc_and_sigils())
		to_chat(user, "<span class='[powered ? "brass":"alloy"]'>It has access to <b>[powered == INFINITY ? "INFINITY":"[powered]"]W</b> of power, \
		and <b>[sigil_number]</b> Sigil[sigil_number == 1 ? "":"s"] of Transmission [sigil_number == 1 ? "is":"are"] in range.</span>")

/obj/structure/destructible/clockwork/powered/Destroy()
	SSfastprocess.processing -= src
	SSobj.processing -= src
	return ..()

/obj/structure/destructible/clockwork/powered/process()
	var/powered = total_accessable_power()
	return powered == PROCESS_KILL ? 25 : powered //make sure we don't accidentally return the arbitrary PROCESS_KILL define

/obj/structure/destructible/clockwork/powered/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] needs to be disabled before it can be unsecured!</span>")
		return FAILED_UNFASTEN
	return ..()

/obj/structure/destructible/clockwork/powered/proc/toggle(fast_process, mob/living/user)
	if(user)
		if(!is_servant_of_ratvar(user))
			return FALSE
		if(!anchored && !active)
			to_chat(user, "<span class='warning'>[src] needs to be secured to the floor before it can be activated!</span>")
			return FALSE
		visible_message("<span class='notice'>[user] [active ? "dis" : "en"]ables [src].</span>", "<span class='brass'>You [active ? "dis" : "en"]able [src].</span>")
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
	return TRUE

/obj/structure/destructible/clockwork/powered/proc/forced_disable(bad_effects)
	if(active)
		toggle()

/obj/structure/destructible/clockwork/powered/emp_act(severity)
	if(forced_disable(TRUE))
		new /obj/effect/temp_visual/emp(loc)

/obj/structure/destructible/clockwork/powered/proc/total_accessable_power() //how much power we have and can use
	if(!needs_power || GLOB.ratvar_awakens)
		return INFINITY //oh yeah we've got power why'd you ask

	var/power = 0
	power += accessable_apc_power()
	power += accessable_sigil_power()
	return power

/obj/structure/destructible/clockwork/powered/proc/accessable_apc_power()
	var/power = 0
	var/area/A = get_area(src)
	var/area/targetAPCA
	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
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
	for(var/obj/effect/clockwork/sigil/transmission/T in range(SIGIL_ACCESS_RANGE, src))
		power += T.power_charge
	return power


/obj/structure/destructible/clockwork/powered/proc/try_use_power(amount) //try to use an amount of power
	if(!needs_power || GLOB.ratvar_awakens)
		return 1
	if(amount <= 0)
		return FALSE
	var/power = total_accessable_power()
	if(!power || power < amount)
		return FALSE
	return use_power(amount)

/obj/structure/destructible/clockwork/powered/proc/use_power(amount) //we've made sure we had power, so now we use it
	var/sigilpower = accessable_sigil_power()
	var/list/sigils_in_range = list()
	for(var/obj/effect/clockwork/sigil/transmission/T in range(SIGIL_ACCESS_RANGE, src))
		sigils_in_range += T
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
			target_apc.charging = 1
			target_apc.chargemode = TRUE
			target_apc.update()
			target_apc.update_icon()
			target_apc.updateUsrDialog()
		else
			apcpower = 0
	if(amount)
		return FALSE
	else
		return TRUE

/obj/structure/destructible/clockwork/powered/proc/return_power(amount) //returns a given amount of power to all nearby sigils or if there are no sigils, to the APC
	if(amount <= 0)
		return FALSE
	var/list/sigils_in_range = check_apc_and_sigils()
	if(!istype(sigils_in_range))
		return FALSE
	if(sigils_in_range.len)
		while(amount >= MIN_CLOCKCULT_POWER)
			for(var/S in sigils_in_range)
				var/obj/effect/clockwork/sigil/transmission/T = S
				if(amount >= MIN_CLOCKCULT_POWER && T.modify_charge(-MIN_CLOCKCULT_POWER))
					amount -= MIN_CLOCKCULT_POWER
	if(target_apc && target_apc.cell && target_apc.cell.give(amount))
		target_apc.charging = 1
		target_apc.chargemode = TRUE
		target_apc.update()
		target_apc.update_icon()
		target_apc.updateUsrDialog()
	return TRUE

/obj/structure/destructible/clockwork/powered/proc/check_apc_and_sigils() //checks for sigils and an APC, returning FALSE if it finds neither, and a list of sigils otherwise
	. = list()
	for(var/obj/effect/clockwork/sigil/transmission/T in range(SIGIL_ACCESS_RANGE, src))
		. += T
	var/list/L = .
	if(!L.len && (!target_apc || !target_apc.cell))
		return FALSE
