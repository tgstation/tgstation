#define SLIP_KNOCKDOWN 6 SECONDS

/**
 * omen.dm: For when you want someone to have a really bad day
 *
 * When you attach an omen component to someone, they start running the risk of all sorts of bad environmental injuries, like nearby vending machines randomly falling on you,
 * or hitting your head really hard when you slip and fall, or... well, for now those two are all I have. More will come.
 *
 * Omens are removed once the victim is either maimed by one of the possible injuries, or if they receive a blessing (read: bashing with a bible) from the chaplain.
 */
/datum/component/omen
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Whatever's causing the omen, if there is one. Destroying the vessel won't stop the omen, but we destroy the vessel (if one exists) upon the omen ending
	var/obj/vessel
	/// Whether this is a permanent omen that cannot be removed by any non-admin means.
	var/permanent = FALSE
	/// Whether this was caused by a quirk
	var/quirk = FALSE
	/// The outer light range of the self-gib explosion
	var/explode_outer = 0.8
	/// The force of the self-gib explosion
	var/explode_inner = 0
	/// Luck modifier. Higher means more likely to trigger, more damage, etc. Unfortunate are half as unlucky as smites
	var/luck_mod = 1

/datum/component/omen/Initialize(silent = FALSE, _vessel, _permanent = FALSE, _quirk = FALSE)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	vessel = _vessel
	permanent = _permanent
	if(_quirk)
		quirk = _quirk
		luck_mod = 0.5 // Unfortunate are not as unlucky as smites
	if(!silent)
		var/warning = "You get a bad feeling..."
		if(permanent)
			warning += " A very bad feeling... As if you are surrounded by a twisted aura of pure malevolence..."
		to_chat(parent, span_warning("[warning]"))

/datum/component/omen/Destroy(force, silent)
	if(!silent)
		var/mob/living/person = parent
		to_chat(person, span_nicegreen("You feel a horrible omen lifted off your shoulders!"))
	if(vessel)
		vessel.visible_message(span_warning("[vessel] burns up in a sinister flash, taking an evil energy with it..."))
		vessel = null
	return ..()

/datum/component/omen/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_accident))
	RegisterSignal(parent, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(check_slip))
	RegisterSignal(parent, COMSIG_CARBON_MOOD_UPDATE, PROC_REF(check_bless))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(check_death))

/datum/component/omen/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_MOVABLE_MOVED, COMSIG_CARBON_MOOD_UPDATE, COMSIG_LIVING_DEATH))

/**
 * check_accident() is called each step we take
 *
 * While we're walking around, roll to see if there's any environmental hazards on one of the adjacent tiles we can trigger.
 * We do the prob() at the beginning to A. add some tension for /when/ it will strike, and B. (more importantly) ameliorate the fact that we're checking up to 5 turfs's contents each time
 */
/datum/component/omen/proc/check_accident(atom/movable/our_guy)
	SIGNAL_HANDLER

	if(!isliving(our_guy))
		return
	var/mob/living/living_guy = our_guy

	if(!prob(15 * luck_mod))
		return

	var/our_guy_pos = get_turf(living_guy)
	for(var/turf_content in our_guy_pos)
		if(istype(turf_content, /obj/machinery/door/airlock))
			to_chat(living_guy, span_warning("A malevolent force launches your body to the floor..."))
			var/obj/machinery/door/airlock/darth_airlock = turf_content
			living_guy.apply_status_effect(/datum/status_effect/incapacitating/paralyzed, 10)
			INVOKE_ASYNC(darth_airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, close), TRUE)
			if(!permanent)
				qdel(src)
			return

	for(var/turf/the_turf as anything in get_adjacent_open_turfs(living_guy))
		if(the_turf.zPassOut(living_guy, DOWN) && living_guy.can_z_move(DOWN, the_turf, z_move_flags = ZMOVE_FALL_FLAGS))
			to_chat(living_guy, span_warning("A malevolent force guides you towards the edge..."))
			living_guy.throw_at(the_turf, 1, 10, force = MOVE_FORCE_EXTREMELY_STRONG)
			if(!permanent)
				qdel(src)
			return

		for(var/obj/machinery/vending/darth_vendor in the_turf)
			if(darth_vendor.tiltable)
				to_chat(living_guy, span_warning("A malevolent force tugs at the [darth_vendor]..."))
				INVOKE_ASYNC(darth_vendor, TYPE_PROC_REF(/obj/machinery/vending, tilt), living_guy)
				if(!permanent)
					qdel(src)
				return

/** If we get knocked down, see if we have a really bad slip and bash our head hard */
/datum/component/omen/proc/check_slip(mob/living/our_guy, amount)
	SIGNAL_HANDLER

	if(prob(33)) // AAAA
		var/quote
		if(ishuman(our_guy))
			quote = "scream"
		if(iscyborg(our_guy))
			quote = "buzz"
		if(quote)
			INVOKE_ASYNC(our_guy, TYPE_PROC_REF(/mob, emote), quote)
		to_chat(our_guy, span_warning("What a horrible night... To have a curse!"))

	if(amount <= 0 || prob(50 * luck_mod)) /// Bonk!
		var/obj/item/bodypart/the_head = our_guy.get_bodypart(BODY_ZONE_HEAD)
		if(!the_head)
			return
		playsound(get_turf(our_guy), 'sound/effects/tableheadsmash.ogg', 90, TRUE)
		our_guy.visible_message(span_danger("[our_guy] hits [our_guy.p_their()] head really badly falling down!"), span_userdanger("You hit your head really badly falling down!"))
		the_head.receive_damage(75 * luck_mod)
		our_guy.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100 * luck_mod)
		if(!permanent)
			qdel(src)

	return

/** Hijack the mood system to see if we get the blessing mood event to cancel the omen */
/datum/component/omen/proc/check_bless(mob/living/our_guy, category)
	SIGNAL_HANDLER

	if(quirk || permanent)
		return

	if (!("blessing" in our_guy.mob_mood.mood_events))
		return

	qdel(src)

/** Unfortunate quirk players delimb on death */
/datum/component/omen/proc/check_death(mob/living/our_guy)
	SIGNAL_HANDLER

	if(!permanent)
		qdel(src)
		return

	var/turf/tile = get_turf(our_guy)
	if(tile)
		explosion(tile,  devastation_range = explode_inner, heavy_impact_range = explode_inner, light_impact_range = explode_outer, flame_range = explode_inner, flash_range = explode_inner, explosion_cause = src)

	if(!quirk || !iscarbon(our_guy))
		our_guy.gib()
		return

	var/mob/living/carbon/player = our_guy
	player.spill_organs()
	player.spawn_gibs()

#undef SLIP_KNOCKDOWN
