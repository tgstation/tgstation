//reforming
/obj/item/ectoplasm/phantom
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "phantomEctoplasm"
	w_class = WEIGHT_CLASS_SMALL
	/// Are we currently reforming?
	var/reforming = TRUE
	/// Are we inert (aka distorted such that we can't reform)?
	var/inert = FALSE
	/// The key of the phantom that we started the reform as
	var/old_ckey
	/// The phantom we're currently storing
	var/mob/living/basic/phantom/phantom

/obj/item/ectoplasm/phantom/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(try_reform)), 1 MINUTES)

/obj/item/ectoplasm/phantom/Destroy()
	if(!QDELETED(phantom))
		qdel(phantom)
	return ..()

/obj/item/ectoplasm/phantom/attack_self(mob/user)
	if(!reforming || inert)
		return ..()
	user.visible_message(
		span_notice("[user] scatters [src] in all directions."),
		span_notice("You scatter [src] across the area. The particles slowly fade away."),
	)
	user.dropItemToGround(src)
	qdel(src)

/obj/item/ectoplasm/phantom/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(inert)
		return
	visible_message(span_notice("[src] breaks into particles upon impact, which fade away to nothingness."))
	qdel(src)

/obj/item/ectoplasm/phantom/examine(mob/user)
	. = ..()
	if(inert)
		. += span_phantomnotice("It seems inert.")
	else if(reforming)
		. += span_phantomwarning("It is shifting and distorted. It would be wise to destroy this.")

/obj/item/ectoplasm/phantom/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is inhaling [src]! It looks like [user.p_theyre()] trying to visit the shadow realm!"))
	qdel(src)
	return OXYLOSS

/obj/item/ectoplasm/phantom/proc/try_reform()
	if(reforming)
		reforming = FALSE
		reform()
	else
		inert = TRUE
		visible_message(span_warning("[src] settles down and seems lifeless."))

/// Actually moves the phantom out of ourself
/obj/item/ectoplasm/phantom/proc/reform()
	if(QDELETED(src) || QDELETED(phantom) || inert)
		return

	message_admins("Phantom ectoplasm was left undestroyed for 1 minute and is reforming into a new phantom.")
	forceMove(drop_location()) //In case it's in a backpack or someone's hand

	var/user_name = old_ckey
	if(isnull(phantom.client))
		var/mob/potential_user = get_new_user()
		phantom.PossessByPlayer(potential_user.key)
		user_name = potential_user.ckey
		qdel(potential_user)

	message_admins("[user_name] has been [old_ckey == user_name ? "re":""]made into a phantom by reforming ectoplasm.")
	phantom.log_message("was [old_ckey == user_name ? "re":""]made as a phantom by reforming ectoplasm.", LOG_GAME)
	visible_message(span_phantomboldnotice("[src] suddenly rises into the air before fading away."))

	phantom.death_reset()
	phantom = null
	qdel(src)

/// Handles giving the phantom a new client to control it
/obj/item/ectoplasm/phantom/proc/get_new_user()
	message_admins("The new phantom's old client either could not be found or is in a new, living mob - grabbing a random candidate instead...")
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target("Do you want to be [span_notice(phantom.name)] (reforming)?", check_jobban = ROLE_PHANTOM, role = ROLE_PHANTOM, poll_time = 5 SECONDS, checked_target = phantom, alert_pic = phantom, role_name_text = "reforming phantom", chat_text_border_icon = phantom)
	if(isnull(chosen_one))
		message_admins("No candidates were found for the new phantom.")
		inert = TRUE
		visible_message(span_phantomwarning("[src] settles down and seems lifeless."))
		qdel(phantom)
		return null
	return chosen_one
