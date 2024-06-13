/datum/component/shearable
	///the atom we create
	var/atom/movable/created
	///the amount we make
	var/created_amount = 1
	///the respawn time of the wool coat
	var/respawn = 5 MINUTES
	///the icon and icon state of the overlay
	var/wool_icon
	var/wool_icon_state
	///wool regrow callback
	var/datum/callback/regrow
	///post shear callback
	var/datum/callback/post_shear
	///our cooldown
	COOLDOWN_DECLARE(regrown)
	///are we grown?
	var/grown = TRUE
	///our unique timer
	var/timer_id

/datum/component/shearable/Initialize(created, amount, regrow_time, wool_icon, wool_icon_state, datum/callback/regrow, datum/callback/on_shear)
	. = ..()
	if(!created)
		return COMPONENT_INCOMPATIBLE
	post_shear = on_shear
	src.regrow = regrow

	src.wool_icon = wool_icon
	src.wool_icon_state = wool_icon_state

	respawn = regrow_time

	created_amount = amount
	src.created = created

/datum/component/shearable/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_SHEARED, PROC_REF(try_shear))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))

/datum/component/shearable/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_MOB_SHEARED)

/datum/component/shearable/proc/try_shear(datum/source, toolspeed, obj/item/tool, mob/user)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, regrown))
		return FALSE

	INVOKE_ASYNC(src, PROC_REF(shear_doafter), toolspeed, tool, user)
	return TRUE

/datum/component/shearable/proc/shear_doafter(toolspeed, obj/item/tool, mob/user)
	var/shear_time = 3 SECONDS / toolspeed

	if(!do_after(user, shear_time, parent))
		return
	user.visible_message("[user] shears the [parent].")
	for(var/i = 1 to created_amount)
		new created(get_turf(user))
	grown = FALSE
	COOLDOWN_START(src, regrown, respawn)
	var/atom/parent_atom = parent
	parent_atom.update_appearance()
	timer_id = addtimer(CALLBACK(src, PROC_REF(regrow_wool)), respawn, TIMER_UNIQUE | TIMER_STOPPABLE)

/datum/component/shearable/proc/regrow_wool()
	grown = TRUE
	var/atom/parent_atom = parent
	parent_atom.update_appearance()

/datum/component/shearable/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	if(!wool_icon || !wool_icon_state)
		return
	if(grown)
		overlays += mutable_appearance(wool_icon, wool_icon_state, parent_atom.layer + 0.1, parent_atom, appearance_flags = RESET_COLOR)
