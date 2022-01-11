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
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/dna_lock, /obj/item/mod/module/eradication_lock)
	cooldown_time = 0.5 SECONDS
	removable = FALSE //copy paste this comment - no timeline modules should be removable
	/// The ckey we lock with, to allow all alternate versions of the user, huhehuehe
	var/true_owner_ckey

/obj/item/mod/module/eradication_lock/on_install()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, .proc/on_mod_activation)
	RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL, .proc/on_mod_removal)

/obj/item/mod/module/eradication_lock/on_uninstall()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	UnregisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL)

/obj/item/mod/module/eradication_lock/on_use()
	. = ..()
	if(!.)
		return
	true_owner_ckey = mod.wearer.ckey
	balloon_alert(mod.wearer, "user remembered")
	drain_power(use_power_cost)

/obj/item/mod/module/eradication_lock/proc/eradication_check(mob/user)
	if(user.ckey == true_owner_ckey)
		return TRUE
	balloon_alert(user, "timeline inhabitant detected! eradicating...")
	return FALSE

/obj/item/mod/module/eradication_lock/proc/on_mod_activation(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!eradication_check(user))
		new /obj/structure/chrono_field(user.loc, user)
		return MOD_CANCEL_ACTIVATE

/obj/item/mod/module/eradication_lock/proc/on_mod_removal(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!eradication_check(user))
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
	complexity = 1
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/rewinder)
	cooldown_time = 30 SECONDS
	removable = FALSE //copy paste this comment - no timeline modules should be removable

/obj/item/mod/module/rewinder/on_use()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/modsuits/time_anchor_set.ogg', 50, TRUE)
	mod.wearer.AddComponent(/datum/component/dejavu/timeline, 1, 10 SECONDS)
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, .proc/on_activate_block)
	addtimer(CALLBACK(src, .proc/unblock_suit_activation), 10 SECONDS)

///unregisters the modsuit deactivation blocking signal, after dejavu functionality finishes.
/obj/item/mod/module/rewinder/proc/unblock_suit_activation()
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

///Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/rewinder/proc/on_activate_block(datum/source, user)
	SIGNAL_HANDLER
	balloon_alert(user, "not while rewinding!")
	return MOD_CANCEL_ACTIVATE

///timestopper - Need I really explain? It's the wizard's time stop, but the user channels it by not moving instead of a duration.
/obj/item/mod/module/timestopper
	name = "MOD timestopper module"
	desc = "A module that can halt time in a small radius around the user... for as long as they \
	want! Great for monologues or lunch breaks. Keep in mind moving will end the stop, and the \
	module has a hefty cooldown period to avoid reality errors."
	icon_state = "timestop"
	module_type = MODULE_USABLE
	complexity = 3
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/timestopper)
	cooldown_time = 60 SECONDS
	removable = FALSE //copy paste this comment - no timeline modules should be removable
	///the current timestop in progress
	var/obj/effect/timestop/channelled/timestop

/obj/item/mod/module/timestopper/on_use()
	. = ..()
	if(!.)
		return
	if(timestop)
		mod.balloon_alert(mod.wearer, "already freezing time!")
		return
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, .proc/on_activate_block)
	timestop = new /obj/effect/timestop/channelled(get_turf(mod.wearer), 2, INFINITY, list(mod.wearer))
	RegisterSignal(timestop, COMSIG_PARENT_QDELETING, .proc/unblock_suit_activation)

///unregisters the modsuit deactivation blocking signal, after timestop functionality finishes.
/obj/item/mod/module/timestopper/proc/unblock_suit_activation(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	on_deactivation()

///Signal fired when wearer attempts to activate/deactivate suits
/obj/item/mod/module/timestopper/proc/on_activate_block(datum/source, user)
	SIGNAL_HANDLER
	balloon_alert(user, "not while channelling timestop!")
	return MOD_CANCEL_ACTIVATE

///TEM - Lets you eradicate people.
/obj/item/mod/module/tem
	name = "MOD timestream eradication module"
	desc = "The correction device of a fourth dimensional group outside time itself used to \
	change the destination of a timeline. this device is capable of wiping a being from the \
	timestream. They never are, they never were, they never will be."
	icon_state = "chronogun"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/tem)
	cooldown_time = 0.5 SECONDS
	removable = FALSE //copy paste this comment - no timeline modules should be removable
	///reference to the chrono field being controlled by this module
	var/obj/structure/chrono_field/field = null
	///where the chronofield maker was when the field went up
	var/turf/startpos

/obj/item/mod/module/tem/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	//trying to fire again, so disconnect what we have
	if(field)
		field_disconnect(field)
	//fire projectile
	var/obj/projectile/energy/chrono_beam/projectile = new /obj/projectile/energy/chrono_beam(get_turf(src))
	playsound(src, 'sound/items/modsuits/time_anchor_set.ogg', 50, TRUE)
	projectile.tem = src
	projectile.firer = mod.wearer
	projectile.fired_from = src
	projectile.fire(get_angle(mod.wearer, target), target)

/obj/item/mod/module/tem/on_uninstall()
	if(field)
		field_disconnect(field)

/obj/item/mod/module/tem/proc/field_connect(obj/structure/chrono_field/F)
	var/mob/living/user = loc
	if(F.tem)
		if(isliving(user) && F.captured)
			to_chat(user, span_alert("<b>FAIL: <i>[F.captured]</i> already has an existing connection.</b>"))
		field_disconnect(F)
	else
		startpos = get_turf(mod.wearer)
		field = F
		F.tem = src
		if(isliving(user) && F.captured)
			to_chat(user, span_notice("Connection established with target: <b>[F.captured]</b>"))

/obj/item/mod/module/tem/proc/field_disconnect(obj/structure/chrono_field/F)
	if(F && field == F)
		var/mob/living/user = loc
		if(F.tem == src)
			F.tem = null
		if(isliving(user) && F.captured)
			to_chat(user, span_alert("Disconnected from target: <b>[F.captured]</b>"))
	field = null
	startpos = null

/obj/item/mod/module/tem/proc/field_check(obj/structure/chrono_field/F)
	if(F)
		if(field == F)
			var/turf/currentpos = get_turf(src)
			var/mob/living/user = loc
			if(currentpos == startpos && isliving(user) && user.body_position == STANDING_UP && !HAS_TRAIT(user, TRAIT_INCAPACITATED) && (field in view(CHRONO_BEAM_RANGE, currentpos)))
				return TRUE
		field_disconnect(F)
		return FALSE

/obj/projectile/energy/chrono_beam
	name = "eradication beam"
	icon_state = "chronobolt"
	range = CHRONO_BEAM_RANGE
	nodamage = TRUE
	///reference to the tem... given by the tem!
	var/obj/item/mod/module/tem/tem

/obj/projectile/energy/chrono_beam/on_hit(atom/target)
	if(target && tem && isliving(target))
		var/obj/structure/chrono_field/F = new(target.loc, target, tem)
		tem.field_connect(F)

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
	var/mob/living/captured
	var/obj/item/mod/module/tem/tem
	var/timetokill = 30
	var/mutable_appearance/mob_underlay
	var/RPpos = null
	var/attached = TRUE //if the tem arg isn't included initially, then the chronofield will work without one

/obj/structure/chrono_field/Initialize(mapload, mob/living/target, obj/item/mod/module/tem/tem)
	if(target && isliving(target))
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
	if(tem?.field_check(src))
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

/obj/structure/chrono_field/process(delta_time)
	if(!captured)
		qdel(src)
		return

	if(timetokill > initial(timetokill))
		for(var/atom/movable/AM in contents)
			AM.forceMove(drop_location())
		qdel(src)
	else if(timetokill <= 0)
		to_chat(captured, span_boldnotice("As the last essence of your being is erased from time, you are taken back to your most enjoyable memory. You feel happy..."))
		var/mob/dead/observer/ghost = captured.ghostize(1)
		if(captured.mind)
			if(ghost)
				ghost.mind = null
		qdel(captured)
		qdel(src)
	else
		captured.Unconscious(80)
		if(captured.loc != src)
			captured.forceMove(src)
		update_appearance()
		if(tem)
			if(tem.field_check(src))
				timetokill -= delta_time
			else
				tem = null
				return .()
		else if(!attached)
			timetokill -= delta_time
		else
			timetokill += delta_time


/obj/structure/chrono_field/bullet_act(obj/projectile/P)
	if(istype(P, /obj/projectile/energy/chrono_beam))
		var/obj/projectile/energy/chrono_beam/beam = P
		var/obj/item/mod/module/tem/Ptem = beam.tem
		if(Ptem && istype(Ptem))
			Ptem.field_connect(src)
	else
		return BULLET_ACT_HIT

/obj/structure/chrono_field/assume_air()
	return 0

/obj/structure/chrono_field/return_air() //we always have nominal air and temperature
	var/datum/gas_mixture/GM = new
	GM.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	GM.gases[/datum/gas/oxygen][MOLES] = MOLES_O2STANDARD
	GM.gases[/datum/gas/nitrogen][MOLES] = MOLES_N2STANDARD
	GM.temperature = T20C
	return GM

/obj/structure/chrono_field/singularity_act()
	return

/obj/structure/chrono_field/singularity_pull()
	return

/obj/structure/chrono_field/ex_act()
	return FALSE

/obj/structure/chrono_field/blob_act(obj/structure/blob/B)
	return

#undef CHRONO_BEAM_RANGE
#undef CHRONO_FRAME_COUNT
