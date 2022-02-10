/obj/effect/proc_holder/spell/pointed/manse_link
	name = "Mansus Link"
	desc = "Piercing through reality, connecting minds. This spell allows you to add people to a Mansus Net, allowing them to communicate with each other from afar."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	action_background_icon_state = "bg_ecult"
	invocation = "PI'RC' TH' M'ND"
	invocation_type = INVOCATION_WHISPER
	school = SCHOOL_FORBIDDEN
	charge_max = 300
	clothes_req = FALSE
	range = 10
	/// A reference to the linker that we'll put people in.
	var/datum/component/mind_linker/linker

/obj/effect/proc_holder/spell/pointed/manse_link/Destroy()
	linker = null
	return ..()

/obj/effect/proc_holder/spell/pointed/manse_link/can_target(atom/target, mob/user, silent)
	return isliving(target)

/obj/effect/proc_holder/spell/pointed/manse_link/cast(list/targets, mob/user)
	if(!istype(linker))
		stack_trace("[name] ([type]) was casted without a mind_linker, this doesn't work.")
		return

	var/mob/living/target = targets[1]

	to_chat(user, span_notice("You begin linking [target]'s mind to yours..."))
	to_chat(target, span_warning("You feel your mind being pulled somewhere... connected... intertwined with the very fabric of reality..."))

	if(!do_after(user, 6 SECONDS, target))
		to_chat(user, span_warning("You fail to link to [target]'s mind."))
		to_chat(target, span_warning("The foreign presence leaves your mind."))
		return

	if(linker.link_mob(target))
		to_chat(user, span_notice("You connect [target]'s mind to your [linker.network_name]!"))
	else
		to_chat(user, span_warning("You can't seem to link to [target]'s mind."))
		to_chat(target, span_warning("The foreign presence leaves your mind."))
