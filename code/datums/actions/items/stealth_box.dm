///MGS BOX!
/datum/action/item_action/agent_box
	name = "Deploy Box"
	desc = "Find inner peace, here, in the box."
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS
	background_icon_state = "bg_agent"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "deploy_box"
	///The type of closet this action spawns.
	var/boxtype = /obj/structure/closet/cardboard/agent
	COOLDOWN_DECLARE(box_cooldown)

///Handles opening and closing the box.
/datum/action/item_action/agent_box/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(istype(owner.loc, /obj/structure/closet/cardboard/agent))
		var/obj/structure/closet/cardboard/agent/box = owner.loc
		if(box.open())
			owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
		return
	//Box closing from here on out.
	if(!isturf(owner.loc)) //Don't let the player use this to escape mechs/welded closets.
		to_chat(owner, span_warning("You need more space to activate this implant!"))
		return
	if(!COOLDOWN_FINISHED(src, box_cooldown))
		return
	COOLDOWN_START(src, box_cooldown, 10 SECONDS)
	var/box = new boxtype(owner.drop_location())
	owner.forceMove(box)
	owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)

/datum/action/item_action/agent_box/Grant(mob/grant_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_HUMAN_SUICIDE_ACT, .proc/suicide_act)

/datum/action/item_action/agent_box/Remove(mob/M)
	if(owner)
		UnregisterSignal(owner, COMSIG_HUMAN_SUICIDE_ACT)
	return ..()

/datum/action/item_action/agent_box/proc/suicide_act(datum/source)
	SIGNAL_HANDLER

	if(!istype(owner.loc, /obj/structure/closet/cardboard/agent))
		return

	var/obj/structure/closet/cardboard/agent/box = owner.loc
	owner.playsound_local(box, 'sound/misc/box_deploy.ogg', 50, TRUE)
	box.open()
	owner.visible_message(span_suicide("[owner] falls out of [box]! It looks like [owner.p_they()] committed suicide!"))
	owner.throw_at(get_turf(owner))
	return OXYLOSS
