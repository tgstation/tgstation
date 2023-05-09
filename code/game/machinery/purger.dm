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
	processing_flags = START_PROCESSING_MANUALLY //We only process when we have an occupant.
	///Our soundloop, for when the machine is running.
	var/datum/looping_sound/tape_recorder_hiss/soundloop
	///Is our machine currently closed with an occupant
	var/purging = FALSE
	///The cooldown for sending escape alerts.
	COOLDOWN_DECLARE(alert_cooldown)
	///The number of addiction points to remove per process.
	var/addiction_purge_amount = 20
	///The lowest volume we can purge reagents down to.
	var/chemical_purge_amount = 3

/obj/machinery/purger/Initialize(mapload)
	. = ..()
	soundloop = new(src,  FALSE)
	open_machine()
	update_appearance()

/obj/machinery/purger/Destroy()
	QDEL_NULL(soundloop)
	. = ..()

/obj/machinery/purger/RefreshParts()
	. = ..()

	var/addiction_rating = 0
	for(var/datum/stock_part/scanning_module/scanner_module in component_parts)
		addiction_rating += scanner_module.tier

	var/purge_rating = 0
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		purge_rating += micro_laser.tier

	addiction_purge_amount = initial(addiction_purge_amount) + addiction_rating * 10
	chemical_purge_amount = initial(chemical_purge_amount) + purge_rating * 3

/obj/machinery/purger/attackby(obj/item/attacking_item, mob/user, params)
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, attacking_item))
		update_appearance()
		return
	if(default_deconstruction_crowbar(attacking_item))
		return
	return ..()

/obj/machinery/purger/interact(mob/user)
	if(state_open)
		close_machine()
	else
		if(!(obj_flags & EMAGGED) && powered())
			open_machine()
		else
			to_chat(user, span_warning("The door seems to be stuck. Find something to pry it open with!"))

/obj/machinery/purger/close_machine(mob/user, density_to_set = TRUE)
	if(panel_open)
		to_chat(user, span_warning("You need to close the maintenance hatch first!"))
		return
	..()
	if(occupant)
		if(!iscarbon(occupant))
			occupant.forceMove(drop_location())
			set_occupant(null)
			return
		to_chat(occupant, span_notice("You enter [src]."))
		update_appearance()
		purging = TRUE
		soundloop.start()
		START_PROCESSING(SSobj, src)

/obj/machinery/purger/open_machine(mob/user, density_to_set = FALSE)
	playsound(src, 'sound/machines/click.ogg', 50)
	if(purging)
		purging = FALSE
		soundloop.stop()
		STOP_PROCESSING(SSobj, src)

	..()

///Reduces addiction points, purges chems until there are only a floor of reagents are left.
///Purged chems are released as a very small gas cloud. Parts can lower the purge floor amount.
/obj/machinery/purger/process()
	var/mob/living/mob_occupant = occupant
	if(istype(mob_occupant))
		if(obj_flags & EMAGGED) //If we're emagged, we worsen addictions, poison our user, and release a large cloud of acid.
			for(var/datum/addiction/addiction in mob_occupant.mind?.addiction_points)
				mob_occupant.mind.add_addiction_points(addiction, addiction_purge_amount)
				if(prob(20))
					to_chat(mob_occupant, span_alert("You feel your [addiction] cravings worsen..."))

			if(mob_occupant.reagents)
				mob_occupant.reagents.add_reagent(/datum/reagent/toxin/amanitin, 1)
				var/datum/effect_system/fluid_spread/smoke/chem/quick/smoke_holder = new()
				smoke_holder.attach(src)
				smoke_holder.set_up(3, holder = src, location = src, silent = TRUE)
				smoke_holder.chemholder.add_reagent(/datum/reagent/toxin/acid/fluacid, 10)
				smoke_holder.start()
			return

		for(var/datum/addiction in mob_occupant.mind?.active_addictions)
			mob_occupant.mind.remove_addiction_points(addiction, addiction_purge_amount)

		if(occupant.reagents && length(occupant.reagents.reagent_list))
			var/datum/effect_system/fluid_spread/smoke/chem/quick/smoke_holder = new()
			smoke_holder.attach(src)
			smoke_holder.set_up(1, holder = src, location = src, silent = TRUE)
			for(var/datum/reagent/reagent_to_purge in mob_occupant.reagents.reagent_list)
				var/amount_to_purge = clamp(reagent_to_purge.volume - PURGE_LIMIT, 0, chemical_purge_amount)
				mob_occupant.reagents.trans_to(smoke_holder.chemholder, amount_to_purge)
			smoke_holder.start()

/obj/machinery/purger/container_resist_act(mob/living/user)
	if(obj_flags & EMAGGED || !powered())
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

/obj/machinery/purger/crowbar_act(mob/living/user, obj/item/tool)
	if((obj_flags & EMAGGED || !powered()) && purging)
		to_chat(user, span_warning("You begin prying at the [src] door..."))
		if(do_after(user, 5 SECONDS, target = src))
			if(!user || user.stat != CONSCIOUS || state_open)
				return
			open_machine()
			return TOOL_ACT_TOOLTYPE_SUCCESS

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

/obj/machinery/purger/update_overlays()
	. = ..()
	if(powered())
		. += "ready_blue"

/obj/machinery/purger/MouseDrop_T(mob/target, mob/user)
	if(HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !isliving(target) || !ISADVANCEDTOOLUSER(user))
		return

	close_machine(target)

#undef PURGE_LIMIT
