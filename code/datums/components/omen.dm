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

/datum/component/omen/Initialize(silent=FALSE, vessel)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/person = parent
	if(!silent)
		to_chat(person, "<span class='warning'>You get a bad feeling...</span>")
	src.vessel = vessel

/datum/component/omen/Destroy(force, silent)
	if(vessel)
		vessel.visible_message("<span class='warning'>[vessel] burns up in a sinister flash, taking an evil energy with it...</span>")
		vessel = null
	return ..()

/datum/component/omen/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_accident)
	RegisterSignal(parent, COMSIG_LIVING_STATUS_KNOCKDOWN, .proc/check_slip)
	RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT, .proc/check_bless)

/datum/component/omen/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_MOVABLE_MOVED, COMSIG_ADD_MOOD_EVENT))

/**
  * check_accident() is called each step we take
  *
  * While we're walking around, roll to see if there's any environmental hazards (currently only vending machines) on one of the adjacent tiles we can trigger.
  * We do the prob() at the beginning to A. add some tension for /when/ it will strike, and B. (more importantly) ameliorate the fact that we're checking up to 5 turfs's contents each time
  */
/datum/component/omen/proc/check_accident(atom/movable/our_guy)
	SIGNAL_HANDLER_DOES_SLEEP

	if(!prob(15))
		return
	for(var/t in get_adjacent_open_turfs(our_guy))
		var/turf/the_turf = t
		for(var/obj/machinery/vending/darth_vendor in the_turf)
			if(darth_vendor.tiltable)
				darth_vendor.tilt(our_guy)
				qdel(src)
				return

/// If we get knocked down, see if we have a really bad slip and bash our head hard
/datum/component/omen/proc/check_slip(mob/living/our_guy, amount)
	SIGNAL_HANDLER

	if(amount <= 0 || prob(50)) // 50% chance to bonk our head
		return

	var/obj/item/bodypart/the_head = our_guy.get_bodypart(BODY_ZONE_HEAD)
	if(!the_head)
		return

	playsound(get_turf(our_guy), 'sound/effects/tableheadsmash.ogg', 90, TRUE)
	our_guy.visible_message("<span class='danger'>[our_guy] hits [our_guy.p_their()] head really badly falling down!</span>", "<span class='userdanger'>You hit your head really badly falling down!</span>")
	the_head.receive_damage(75)
	our_guy.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100)
	qdel(src)

/// Hijack the mood system to see if we get the blessing mood event to cancel the omen
/datum/component/omen/proc/check_bless(mob/living/our_guy, category)
	SIGNAL_HANDLER

	if(category != "blessing")
		return
	to_chat(our_guy, "<span class='nicegreen'>You feel a horrible omen lifted off your shoulders!</span>")
	qdel(src)
