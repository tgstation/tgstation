/**
 * Note that we can stack explosive implants and thus increase the payload's devastation radius. (https://github.com/tgstation/tgstation/pull/50674)
 * That's why the three devastation values for the microbomb implant are balanced around in such a way
 * that buying one macrobomb equals to buying 10 microbombs and stacking them.
 */

#define MICROBOMB_DELAY 0.7 SECONDS

#define MICROBOMB_EXPLOSION_LIGHT 2
#define MICROBOMB_EXPLOSION_HEAVY 0.8
#define MICROBOMB_EXPLOSION_DEVASTATE 0.4

/obj/item/implant/explosive
	name = "microbomb implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	actions_types = list(/datum/action/item_action/explosive_implant) //Explosive implant action is always available.
	///Whether the implant's explosion sequence has been activated or not
	var/active = FALSE
	///The final countdown (delay before we explode)
	var/delay = MICROBOMB_DELAY
	///Radius of weak devastation explosive impact
	var/explosion_light = MICROBOMB_EXPLOSION_LIGHT
	///Radius of medium devastation explosive impact
	var/explosion_heavy = MICROBOMB_EXPLOSION_HEAVY
	///Radius of heavy devastation explosive impact
	var/explosion_devastate = MICROBOMB_EXPLOSION_DEVASTATE
	///Whether the confirmation UI popup is active or not
	var/popup = FALSE


/obj/item/implant/explosive/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER

	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish. Also, the "delayed explosion"
	// uses sleeps, which is bad for signal handlers to do.
	INVOKE_ASYNC(src, PROC_REF(activate), "death")

/obj/item/implant/explosive/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-78 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Explodes<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Explodes<BR>
				"}
	return dat

/obj/item/implant/explosive/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/response = tgui_alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to explode!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes")
			return FALSE
	if(cause == "death" && HAS_TRAIT(imp_in, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION))
		return FALSE
	explosion_devastate = round(explosion_devastate)
	explosion_heavy = round(explosion_heavy)
	explosion_light = round(explosion_light)
	to_chat(imp_in, span_notice("You activate your [name]."))
	active = TRUE
	var/turf/boomturf = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(boomturf)], with cause of [cause].")
	//If the delay is shorter or equal to the default delay, just blow up already jeez
	if(delay <= MICROBOMB_DELAY)
		explosion(src, devastation_range = explosion_devastate, heavy_impact_range = explosion_heavy, light_impact_range = explosion_light, flame_range = explosion_light, flash_range = explosion_light, explosion_cause = src)
		if(imp_in)
			imp_in.investigate_log("has been gibbed by an explosive implant.", INVESTIGATE_DEATHS)
			imp_in.gib(TRUE)
		qdel(src)
		return
	timed_explosion()

/obj/item/implant/explosive/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	for(var/target_implant in target.implants)
		if(istype(target_implant, /obj/item/implant/explosive)) //we don't use our own type here, because macrobombs inherit this proc and need to be able to upgrade microbombs
			//We merge the two implants into a single bigger, badder one by adding the injected implant's values into the already present implant
			var/obj/item/implant/explosive/implant_to_upgrade = target_implant
			implant_to_upgrade.explosion_devastate += explosion_devastate
			implant_to_upgrade.explosion_heavy += explosion_heavy
			implant_to_upgrade.explosion_light += explosion_light
			implant_to_upgrade.delay += delay
			qdel(src)
			return TRUE

	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/implant/explosive/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/**
 * Explosive activation sequence for implants with a delay longer than 0.7 seconds.
 * Make the implantee beep a few times, keel over and explode. Usually to a devastating effect.
 */
/obj/item/implant/explosive/proc/timed_explosion()
	imp_in.visible_message(span_warning("[imp_in] starts beeping ominously!"))

	notify_ghosts(
		"[imp_in] is about to detonate their explosive implant!",
		source = src,
		action = NOTIFY_ORBIT,
		flashwindow = FALSE,
		ghost_sound = 'sound/machines/warning-buzzer.ogg',
		header = "Tick Tick Tick...",
		notify_volume = 75
	)

	playsound(loc, 'sound/items/timer.ogg', 30, FALSE)
	sleep(delay * 0.25)
	if(imp_in && !imp_in.stat)
		imp_in.visible_message(span_warning("[imp_in] doubles over in pain!"))
		imp_in.Paralyze(14 SECONDS)
	//total of 4 bomb beeps, and we've already beeped once
	var/bomb_beeps_until_boom = 3
	while(bomb_beeps_until_boom > 0)
		//for extra spice
		var/beep_volume = 35
		playsound(loc, 'sound/items/timer.ogg', beep_volume, FALSE)
		sleep(delay * 0.25)
		bomb_beeps_until_boom--
		beep_volume += 5
	explosion(src, devastation_range = explosion_devastate, heavy_impact_range = explosion_heavy, light_impact_range = explosion_light, flame_range = explosion_light, flash_range = explosion_light, explosion_cause = src)
	if(imp_in)
		imp_in.investigate_log("has been gibbed by an explosive implant.", INVESTIGATE_DEATHS)
		imp_in.gib(TRUE)
	qdel(src)

//Macrobomb has the strength and delay of 10 microbombs
/obj/item/implant/explosive/macro
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	delay = 10 * MICROBOMB_DELAY
	explosion_light = 10 * MICROBOMB_EXPLOSION_LIGHT
	explosion_heavy = 10 * MICROBOMB_EXPLOSION_HEAVY
	explosion_devastate = 10 * MICROBOMB_EXPLOSION_DEVASTATE

/obj/item/implanter/explosive
	name = "implanter (microbomb)"
	imp_type = /obj/item/implant/explosive

/obj/item/implantcase/explosive
	name = "implant case - 'Explosive'"
	desc = "A glass case containing an explosive implant."
	imp_type = /obj/item/implant/explosive

/obj/item/implanter/explosive_macro
	name = "implanter (macrobomb)"
	imp_type = /obj/item/implant/explosive/macro

/datum/action/item_action/explosive_implant
	check_flags = NONE
	name = "Activate Explosive Implant"

#undef MICROBOMB_DELAY
#undef MICROBOMB_EXPLOSION_LIGHT
#undef MICROBOMB_EXPLOSION_HEAVY
#undef MICROBOMB_EXPLOSION_DEVASTATE
