///How much do we purge reagents down to (purge speed slows as it approaches this value, eventually stopping)
#define PURGE_LIMIT 10

/obj/machinery/purger
	name = "Purge-O-Matic 3000"
	desc = "Purges both the mind and body of chemical afflictions, through the harnessed power of an anomaly."
	icon = 'icons/obj/machines/fat_sucker.dmi'
	icon_state = "fat"
	circuit = /obj/item/circuitboard/machine/purger
	state_open = FALSE
	density = TRUE
	///Our soundloop, for when the machine is running.
	var/datum/looping_sound/microwave/soundloop
	///Is our machine currently running?
	var/purging = FALSE

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
		stop()
	..()

///Reduces addiction points, purges chems until there are only 10 reagents left.
///Purged chems are released as a very small gas cloud.
/obj/machinery/purger/process()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		for(var/datum/addiction in mob_occupant.mind?.active_addictions)
			mob_occupant.mind.remove_addiction_points(addiction, 10)

		if(occupant.reagents)
			for(var/datum/reagent/reagent_to_purge in mob_occupant.reagents.reagent_list)
				var/amount_to_purge = min(reagent_to_purge.volume - PURGE_LIMIT, 30)
				var/datum/effect_system/fluid_spread/smoke/chem/quick/smoke_holder = new()
				occupant.reagents.trans_to(smoke_holder, amount_to_purge)
				smoke_holder.attach(src)
				smoke_holder.set_up(4, holder = src, location = src, silent = TRUE)
				smoke_holder.start()

/obj/machinery/purger/container_resist_act(mob/living/user)
	if(obj_flags & EMAGGED)
		to_chat(user, span_notice("The door seems to be stuck!"))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		user.visible_message(span_notice("You see [user] kicking against the door of [src]!"), \
			span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"), \
			span_hear("You hear a metallic creaking from [src]."))
		if(do_after(user, breakout_time, target = src))
			if(!user || user.stat != CONSCIOUS || user.loc != src || state_open)
				return
			free_exit = TRUE
			user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
				span_notice("You successfully break out of [src]!"))
			open_machine()
		return
	open_machine()

/obj/machinery/purger/emag_act(mob/living/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, span_notice("You quietly disable the safeties on the [src]!"))
	obj_flags |= EMAGGED

/obj/machinery/hypnochair/relaymove(mob/living/user, direction)
	if()
		message_cooldown = world.time + 50
		to_chat(user, span_warning("[src]'s door won't budge!"))

/obj/machinery/purger/proc/stop()
	purging = FALSE
	soundloop.stop()

#undef PURGE_LIMIT
