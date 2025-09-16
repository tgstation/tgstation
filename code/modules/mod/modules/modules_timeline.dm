/// range of the chrono beam!
#define CHRONO_BEAM_RANGE 3
/// how many frames the chronofield needs before it eradicates someone.
#define CHRONO_FRAME_COUNT 22

///Eradication lock - Prevents people who aren't the owner of the suit from existing on the timeline via eradicating the suit with the intruder inside
/obj/item/mod/module/eradication_lock
	name = "MOD eradication lock module"
	desc = "A module which remembers the original owner of the suit, even alternate universe \
			versions. When a non-owner enters, the eradication lock will begin eradicating the suit \
			from the timeline... with the intruder inside. Not the way you want to go, so it turns \
			out to be a good deterrent."
	icon_state = "eradicationlock"
	module_type = MODULE_USABLE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/eradication_lock, /obj/item/mod/module/dna_lock)
	cooldown_time = 0.5 SECONDS
	/// The ckey we lock with, to allow all alternate versions of the user.
	var/true_owner_ckey

/obj/item/mod/module/eradication_lock/on_install()
	. = ..()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_mod_activation))
	RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL, PROC_REF(on_mod_removal))

/obj/item/mod/module/eradication_lock/on_uninstall(deleting = FALSE)
	. = ..()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	UnregisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL)

/obj/item/mod/module/eradication_lock/on_use(mob/activator)
	true_owner_ckey = mod.wearer.ckey
	balloon_alert(activator, "user remembered")
	playsound(src, 'sound/items/pshoom/pshoom.ogg', 25, TRUE)
	drain_power(use_energy_cost)

///Signal fired when the modsuit tries activating
/obj/item/mod/module/eradication_lock/proc/on_mod_activation(datum/source, mob/user)
	SIGNAL_HANDLER

	if(true_owner_ckey && user.ckey != true_owner_ckey)
		to_chat(mod.wearer, span_userdanger("\"MODsuit compromised by timeline inhabitant! Eradicating...\""))
		new /obj/structure/chrono_field(user.loc, user)
		return MOD_CANCEL_ACTIVATE

///Signal fired when the modsuit tries removing a module.
/obj/item/mod/module/eradication_lock/proc/on_mod_removal(datum/source, mob/user)
	SIGNAL_HANDLER

	if(true_owner_ckey && user.ckey != true_owner_ckey)
		to_chat(mod.wearer, span_userdanger("\"Timeline inhabitant tampering detected! Eradicating...\""))
		new /obj/structure/chrono_field(user.loc, user)
		return MOD_CANCEL_REMOVAL

///Rewinder - Activating saves a point in time, after 10 seconds you will jump back to that state.
/obj/item/mod/module/rewinder
	name = "MOD rewinder module"
	desc = "A module that can pull the user back through time given an anchor point to \
			pull to. Very useful tool to get the job done, but keep in mind the suit locks for \
			safety reasons while preparing a rewind."
	icon_state = "rewinder"
	module_type = MODULE_USABLE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/rewinder)
	cooldown_time = 20 SECONDS
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/rewinder/on_use(mob/activator)
	balloon_alert(activator, "anchor point set")
	playsound(src, 'sound/items/modsuit/time_anchor_set.ogg', 50, TRUE)
	//stops all mods from triggering during rewinding
	for(var/obj/item/mod/module/module as anything in mod.modules)
		RegisterSignal(module, COMSIG_MODULE_TRIGGERED, PROC_REF(on_module_triggered))
	mod.wearer.AddComponent(/datum/component/dejavu/timeline, 1, 10 SECONDS)
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_activate_block))
	addtimer(CALLBACK(src, PROC_REF(unblock_suit_activation)), 10 SECONDS)

///Unregisters the modsuit deactivation blocking signal, after dejavu functionality finishes.
/obj/item/mod/module/rewinder/proc/unblock_suit_activation()
	for(var/obj/item/mod/module/module as anything in mod.modules)
		UnregisterSignal(module, COMSIG_MODULE_TRIGGERED)
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

///Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/rewinder/proc/on_activate_block(datum/source, user)
	SIGNAL_HANDLER
	balloon_alert(user, "not while rewinding!")
	return MOD_CANCEL_ACTIVATE

///Signal fired when wearer attempts to trigger modules, if attempting while time is stopped
/obj/item/mod/module/rewinder/proc/on_module_triggered(datum/source, mob/user)
	SIGNAL_HANDLER
	balloon_alert(user, "not while rewinding!")
	return MOD_ABORT_USE

///Timestopper - Need I really explain? It's the wizard's time stop, but the user channels it by not moving instead of a duration.
/obj/item/mod/module/timestopper
	name = "MOD timestopper module"
	desc = "A module that can halt time in a small radius around the user... for as long as they \
			want! Great for monologues or lunch breaks. Keep in mind moving will end the stop, and the \
			module has a hefty cooldown period to avoid reality errors."
	icon_state = "timestop"
	module_type = MODULE_USABLE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/timestopper)
	cooldown_time = 60 SECONDS
	required_slots = list(ITEM_SLOT_BACK)
	///The current timestop in progress.
	var/obj/effect/timestop/channelled/timestop

/obj/item/mod/module/timestopper/used(mob/activator)
	if(timestop)
		mod.balloon_alert(activator, "already freezing time!")
		return FALSE
	return ..()

/obj/item/mod/module/timestopper/on_use(mob/activator)
	//stops all mods from triggering during timestop- including timestop itself
	for(var/obj/item/mod/module/module as anything in mod.modules)
		RegisterSignal(module, COMSIG_MODULE_TRIGGERED, PROC_REF(on_module_triggered))
	timestop = new /obj/effect/timestop/channelled(get_turf(mod.wearer), 2, INFINITY, list(mod.wearer))
	RegisterSignal(timestop, COMSIG_QDELETING, PROC_REF(unblock_suit_activation))

///Unregisters the modsuit deactivation blocking signal, after timestop functionality finishes.
/obj/item/mod/module/timestopper/proc/unblock_suit_activation(datum/source)
	SIGNAL_HANDLER
	for(var/obj/item/mod/module/module as anything in mod.modules)
		UnregisterSignal(module, COMSIG_MODULE_TRIGGERED)
	UnregisterSignal(source, COMSIG_QDELETING)
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	timestop = null

///Signal fired when wearer attempts to trigger modules, if attempting while time is stopped
/obj/item/mod/module/timestopper/proc/on_module_triggered(datum/source)
	SIGNAL_HANDLER
	balloon_alert(mod.wearer, "not while stopping time!")
	return MOD_ABORT_USE

///Signal fired when wearer attempts to activate/deactivate suits, if attempting while time is stopped
/obj/item/mod/module/timestopper/proc/on_activate_block(datum/source, user)
	SIGNAL_HANDLER
	balloon_alert(user, "not while stopping time!")
	return MOD_CANCEL_ACTIVATE

///Timeline Jumper - Infinite phasing. needs some special effects
/obj/item/mod/module/timeline_jumper
	name = "MOD timeline jumper module"
	desc = "A module used to traverse timelines, phasing the user in and out of the stream of events."
	icon_state = "timeline_jumper"
	module_type = MODULE_USABLE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/timeline_jumper)
	cooldown_time = 5 SECONDS
	allow_flags = MODULE_ALLOW_PHASEOUT
	required_slots = list(ITEM_SLOT_BACK)
	///The dummy for phasing from this module, the wearer is phased out while this exists.
	var/obj/effect/dummy/phased_mob/chrono/phased_mob

/obj/item/mod/module/timeline_jumper/used(mob/activator)
	var/area/noteleport_check = get_area(mod.wearer)
	if(noteleport_check && !check_teleport_valid(mod.wearer, get_turf(mod.wearer)))
		to_chat(activator, span_danger("Some dull, universal force is between you and the [phased_mob ? "current timeline" : "stream between timelines"]."))
		return FALSE
	return ..()

/obj/item/mod/module/timeline_jumper/on_use(mob/activator)
	if(!phased_mob)
		//phasing out
		mod.visible_message(span_warning("[mod.wearer] leaps out of the timeline!"))
		mod.wearer.SetAllImmobility(0)
		mod.wearer.setStaminaLoss(0)
		phased_mob = new(get_turf(mod.wearer.loc), mod.wearer)
		RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(on_activate_block))
	else
		//phasing in
		phased_mob.eject_jaunter()
		phased_mob = null
		UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
		mod.visible_message(span_warning("[mod.wearer] drops into the timeline!"))

	//probably justifies its own sound but whatever
	playsound(src, 'sound/items/modsuit/time_anchor_set.ogg', 50, TRUE)

///Signal fired when wearer attempts to activate/deactivate suits while phased out
/obj/item/mod/module/timeline_jumper/proc/on_activate_block(datum/source, user)
	SIGNAL_HANDLER
	//has to be a to_chat because you're phased out.
	to_chat(user, span_warning("Deactivating your suit while inbetween timelines would be a very bad idea."))
	return MOD_CANCEL_ACTIVATE

///special subtype for phased mobs.
/obj/effect/dummy/phased_mob/chrono
	name = "reality static"
	verb_say = "echoes"

///TEM - Lets you eradicate people.
/obj/item/mod/module/tem
	name = "MOD timestream eradication module"
	desc = "The correction device of a fourth dimensional group outside time itself used to \
			change the destination of a timeline. this device is capable of wiping a being from the \
			timestream. They never are, they never were, they never will be."
	icon_state = "chronogun"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/tem)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_BACK)
	///Reference to the chrono field being controlled by this module
	var/obj/structure/chrono_field/field = null
	///Where the chronofield maker was when the field went up
	var/turf/startpos

/obj/item/mod/module/tem/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	//trying to fire again, so disconnect what we have
	if(field)
		field_disconnect(field)
	//fire projectile
	var/obj/projectile/energy/chrono_beam/chrono_beam = new /obj/projectile/energy/chrono_beam(get_turf(src))
	chrono_beam.tem_weakref = WEAKREF(src)
	chrono_beam.aim_projectile(target, mod.wearer)
	chrono_beam.firer = mod.wearer
	playsound(src, 'sound/items/modsuit/time_anchor_set.ogg', 50, TRUE)
	INVOKE_ASYNC(chrono_beam, TYPE_PROC_REF(/obj/projectile, fire))

/obj/item/mod/module/tem/on_uninstall(deleting = FALSE)
	. = ..()
	if(!field)
		return
	field_disconnect(field)

/**
 * ### field_connect
 *
 * Links a chrono field to this module. The chrono field will keep track of the eradication process.
 * Unlinks a chrono field if it is connected to a tem already.
 *
 * Arguments:
 * * field: chronofield we are attempting to link to this module.
 */
/obj/item/mod/module/tem/proc/field_connect(obj/structure/chrono_field/field)
	if(field.tem)
		if(field.captured)
			balloon_alert(mod.wearer, "already has connection!")
		field_disconnect(field)
		return
	startpos = get_turf(mod.wearer)
	src.field = field
	field.tem = src
	if(field.captured)
		balloon_alert(mod.wearer, "connection estabilished")

/**
 * ### field_disconnect
 *
 * Unlinks a chrono field from this module.
 *
 * Arguments:
 * * field: chronofield we are attempting to unlink from this module.
 */
/obj/item/mod/module/tem/proc/field_disconnect(obj/structure/chrono_field/field)
	if(field)
		if(field.tem == src)
			field.tem = null
		if(field.captured)
			balloon_alert(mod.wearer, "connection lost!")
	field = null
	startpos = null

/**
 * ### field_check
 *
 * Checks to see if  our field can still be linked to the tem. If it isn't, it will unlink the field.
 *
 * Arguments:
 * * field: chronofield we're checking the connection's validity on.
 */
/obj/item/mod/module/tem/proc/field_check(obj/structure/chrono_field/field)
	if(!field)
		return FALSE
	var/turf/currentpos = get_turf(src)
	if(currentpos == startpos && mod.wearer.body_position == STANDING_UP && !HAS_TRAIT(mod.wearer, TRAIT_INCAPACITATED) && (field in view(CHRONO_BEAM_RANGE, currentpos)))
		return TRUE
	field_disconnect(field)
	return FALSE

/obj/projectile/energy/chrono_beam
	name = "eradication beam"
	icon_state = "chronobolt"
	range = CHRONO_BEAM_RANGE
	///Reference to the tem... given by the tem! weakref because back in the day we didn't know about harddels- or maybe we didn't care.
	var/datum/weakref/tem_weakref

/obj/projectile/energy/chrono_beam/on_hit(atom/target, blocked = 0, pierce_hit)
	var/obj/item/mod/module/tem/tem = tem_weakref.resolve()
	if(target && tem && isliving(target))
		var/obj/structure/chrono_field/field = new(target.loc, target, tem)
		tem.field_connect(field)
		return BULLET_ACT_HIT

	return ..()

/obj/structure/chrono_field
	name = "eradication field"
	desc = "An aura of time-bluespace energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "chronofield"
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	interaction_flags_atom = NONE
	/// Mob being eradicated by this field
	var/mob/living/captured
	/// Linked module. while this exists, the field will progress towards eradication. while it isn't, the field progresses away until it disappears. see attached for a special case
	var/obj/item/mod/module/tem/tem
	/// Time in seconds before someone is eradicated, assuming progress isn't interrupted
	var/timetokill = 3 SECONDS
	/// The eradication appearance
	var/mutable_appearance/mob_underlay
	/// The actual frame the animation is at in eradication, only changing when the progress towards eradication progresses enough to move to the next frame.
	var/RPpos = null
	/// If a TEM to link to isn't provided initially, this chrono field will progress towards eradication by itself without one.
	var/attached = TRUE

/obj/structure/chrono_field/Initialize(mapload, mob/living/target, obj/item/mod/module/tem/tem)
	if(isliving(target))
		if(!tem)
			attached = FALSE
		target.forceMove(src)
		captured = target
		var/icon/mob_snapshot = getFlatIcon(target)
		var/icon/cached_icon = new()

		for(var/i in 1 to CHRONO_FRAME_COUNT)
			var/icon/removing_frame = icon('icons/obj/chronos.dmi', "erasing", SOUTH, i)
			var/icon/mob_icon = icon(mob_snapshot)
			mob_icon.Blend(removing_frame, ICON_MULTIPLY)
			cached_icon.Insert(mob_icon, "frame[i]")

		mob_underlay = mutable_appearance(cached_icon, "frame1")
		update_appearance()

		desc = initial(desc) + "<br>[span_info("It appears to contain [target.name].")]"
	START_PROCESSING(SSobj, src)
	return ..()

/obj/structure/chrono_field/Destroy()
	if(tem)
		tem.field_disconnect(src)
	return ..()

/obj/structure/chrono_field/update_overlays()
	. = ..()
	var/ttk_frame = 1 - (timetokill / initial(timetokill))
	ttk_frame = clamp(CEILING(ttk_frame * CHRONO_FRAME_COUNT, 1), 1, CHRONO_FRAME_COUNT)
	if(ttk_frame != RPpos)
		RPpos = ttk_frame
		underlays -= mob_underlay
		mob_underlay.icon_state = "frame[RPpos]"
		underlays += mob_underlay

/obj/structure/chrono_field/process(seconds_per_tick)
	if(!captured)
		qdel(src)
		return

	if(timetokill > initial(timetokill))
		for(var/atom/movable/freed_movable in contents)
			freed_movable.forceMove(drop_location())
		qdel(src)
	else if(timetokill <= 0)
		to_chat(captured, span_notice("As the last essence of your being is erased from time, you are taken back to your most enjoyable memory. You feel happy..."))
		var/mob/dead/observer/ghost = captured.ghostize(can_reenter_corpse = TRUE)
		if(captured.mind)
			if(ghost)
				ghost.mind = null
		qdel(captured)
		qdel(src)
	else
		captured.Unconscious(8 SECONDS)
		if(captured.loc != src)
			captured.forceMove(src)
		update_appearance()
		if(tem)
			if(tem.field_check(src))
				timetokill -= seconds_per_tick
			else
				tem = null
				return
		else if(!attached)
			timetokill -= seconds_per_tick
		else
			timetokill += seconds_per_tick


/obj/structure/chrono_field/bullet_act(obj/projectile/projectile)
	if(istype(projectile, /obj/projectile/energy/chrono_beam))
		var/obj/projectile/energy/chrono_beam/beam = projectile
		var/obj/item/mod/module/tem/linked_tem = beam.tem_weakref.resolve()
		if(linked_tem && istype(linked_tem))
			linked_tem.field_connect(src)
		return BULLET_ACT_HIT

	return ..()

/obj/structure/chrono_field/assume_air()
	return FALSE

/obj/structure/chrono_field/return_air() //we always have nominal air and temperature
	var/datum/gas_mixture/fresh_air = new
	fresh_air.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	fresh_air.gases[/datum/gas/oxygen][MOLES] = MOLES_O2STANDARD
	fresh_air.gases[/datum/gas/nitrogen][MOLES] = MOLES_N2STANDARD
	fresh_air.temperature = T20C
	return fresh_air

/obj/structure/chrono_field/singularity_act()
	return

/obj/structure/chrono_field/singularity_pull(atom/singularity, current_size)
	return

/obj/structure/chrono_field/ex_act()
	return FALSE

/obj/structure/chrono_field/blob_act(obj/structure/blob/B)
	return

#undef CHRONO_BEAM_RANGE
#undef CHRONO_FRAME_COUNT
