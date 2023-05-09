///How much do we purge reagents down to (purge speed slows as it approaches this value, eventually stopping)
#define PURGE_LIMIT 5

/obj/machinery/purger
	name = "Purge-O-Matic 3000"
	desc = "Purges both the mind and body of chemical afflictions, through the harnessed power of an anomaly."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	base_icon_state = "implantchair"
	circuit = /obj/item/circuitboard/machine/purger
	density = TRUE
	opacity = FALSE
	///Our soundloop, for when the machine is running.
	var/datum/looping_sound/microwave/soundloop
	///Is our machine currently running?
	var/purging = FALSE
	///The cooldown for sending escape alerts.
	COOLDOWN_DECLARE(alert_cooldown)

/obj/machinery/purger/Initialize(mapload)
	. = ..()
	soundloop = new(src,  FALSE)
	open_machine()
	update_appearance()

/obj/machinery/purger/Destroy()
	QDEL_NULL(soundloop)
	. = ..()

/obj/machinery/purger/attackby(obj/item/I, mob/user, params)
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_appearance()
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/purger/interact(mob/user)
	if(state_open)
		close_machine()
	else if(!purging || obj_flags & EMAGGED)
		open_machine()

/obj/machinery/purger/close_machine(mob/user, density_to_set = TRUE)
	if(panel_open)
		to_chat(user, span_warning("You need to close the maintenance hatch first!"))
		return
	..()
	playsound(src, 'sound/machines/click.ogg', 50)
	if(occupant)
		if(!iscarbon(occupant))
			occupant.forceMove(drop_location())
			set_occupant(null)
			return
		to_chat(occupant, span_notice("You enter [src]."))
		update_appearance()

/obj/machinery/purger/open_machine(mob/user, density_to_set = FALSE)
	playsound(src, 'sound/machines/click.ogg', 50)
	if(purging)
		purging = FALSE
		soundloop.stop()
		STOP_PROCESSING(SSobj, src)

	..()

///Reduces addiction points, purges chems until there are only 10 reagents left.
///Purged chems are released as a very small gas cloud.
/obj/machinery/purger/process()
	var/mob/living/mob_occupant = occupant
	if(istype(mob_occupant))
		for(var/datum/addiction in mob_occupant.mind?.active_addictions)
			mob_occupant.mind.remove_addiction_points(addiction, 10)

		if(occupant.reagents && length(occupant.reagents.reagent_list))
			var/datum/effect_system/fluid_spread/smoke/chem/quick/smoke_holder = new()
			smoke_holder.attach(src)
			smoke_holder.set_up(1, holder = src, location = src, silent = TRUE)
			for(var/datum/reagent/reagent_to_purge in mob_occupant.reagents.reagent_list)
				var/amount_to_purge = clamp(reagent_to_purge.volume - PURGE_LIMIT, 0, 30)
				mob_occupant.reagents.trans_to(smoke_holder.chemholder, amount_to_purge)
			smoke_holder.start()

/obj/machinery/purger/container_resist_act(mob/living/user)
	if(obj_flags & EMAGGED) // !powered(ignore_use_power = TRUE) add this too maybe
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		user.visible_message(span_notice("You see [user] kicking against the door of [src]!"), \
			span_notice("You begin trying to force the door open."), \
			span_hear("You hear a metallic creaking from [src]."))
		if(do_after(user, 30 SECONDS, target = src))
			if(!user || user.stat != CONSCIOUS || user.loc != src || state_open)
				return
			open_machine()
		return
	open_machine()

/obj/machinery/purger/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, span_notice("You quietly disable the safeties on the [src]!"))
	obj_flags |= EMAGGED

/obj/machinery/purger/relaymove(mob/living/user, direction)
	if(COOLDOWN_FINISHED(src, alert_cooldown) && obj_flags & EMAGGED)
		to_chat(user, span_warning("The door seems to be stuck!"))
		COOLDOWN_START(src, alert_cooldown, 10 SECONDS)

/obj/machinery/purger/update_icon_state()
	icon_state = "[base_icon_state][state_open ? "_open" : null]"
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state += "_unpowered"
		if((machine_stat & MAINT) || panel_open)
			icon_state += "_maintenance"
		return ..()

	if((machine_stat & MAINT) || panel_open)
		icon_state += "_maintenance"
		return ..()

	if(occupant)
		icon_state += "_occupied"
	return ..()

/obj/machinery/purger/MouseDrop_T(mob/target, mob/user)
	if(HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !isliving(target) || !ISADVANCEDTOOLUSER(user))
		return

	close_machine(target)

#undef PURGE_LIMIT
