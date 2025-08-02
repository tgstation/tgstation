

/datum/action/cooldown/spell/conjure_item/invisible_box
	name = "Invisible Box"
	desc = "The mime's performance transmutates a box into physical reality."
	background_icon_state = "bg_mime"
	overlay_icon_state = "bg_mime_border"
	button_icon = 'icons/mob/actions/actions_mime.dmi'
	button_icon_state = "invisible_box"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	panel = "Mime"
	sound = null

	school = SCHOOL_MIME
	cooldown_time = 30 SECONDS
	invocation = span_notice("<b>%CASTER</b> moves %PRONOUN_their hands in the shape of a box, pressing a box out of the air.")
	invocation_self_message = span_notice("You conjure up an invisible box, large enough to store a few things.")
	invocation_type = INVOCATION_EMOTE

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE
	spell_max_level = 1

	delete_old = FALSE
	item_type = /obj/item/storage/box/mime
	/// How long boxes last before going away
	var/box_lifespan = 50 SECONDS

/datum/action/cooldown/spell/conjure_item/invisible_box/make_item(atom/caster)
	. = ..()
	var/obj/item/made_box = .
	made_box.alpha = 255
	addtimer(CALLBACK(src, PROC_REF(cleanup_box), made_box), box_lifespan)

/// Callback that gets rid out of box and removes the weakref from our list
/datum/action/cooldown/spell/conjure_item/invisible_box/proc/cleanup_box(obj/item/storage/box/box)
	if(QDELETED(box) || !istype(box))
		return

	box.emptyStorage()
	LAZYREMOVE(item_refs, WEAKREF(box))
	qdel(box)
