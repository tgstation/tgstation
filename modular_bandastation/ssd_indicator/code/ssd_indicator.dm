GLOBAL_VAR_INIT(ssd_indicator_overlay, mutable_appearance('modular_bandastation/ssd_indicator/icons/ssd_indicator.dmi', "zzz_glow", FLY_LAYER))

/datum/element/ssd
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/ssd/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	if(istype(target, /mob/living/silicon/robot/shell))
		Detach(target)
		return
	RegisterSignal(target, COMSIG_MOB_LOGOUT, PROC_REF(on_mob_logout))
	RegisterSignal(target, COMSIG_MOB_LOGIN, PROC_REF(on_mob_login))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
	RegisterSignal(target, COMSIG_LIVING_REVIVE, PROC_REF(on_mob_revive))
	RegisterSignal(target, COMSIG_MOB_ADMIN_GHOSTED, PROC_REF(on_mob_admin_ghost))
	if(isAI(target))
		RegisterSignal(target, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF, PROC_REF(on_ai_mind_transfer))
	if(iscyborg(target))
		RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_cyborg_update_overlays))
	if(isslimeperson(target))
		RegisterSignal(target, COMSIG_SLIMEMAN_SWAPPED_BODY, PROC_REF(on_slimeman_swap_body))

/datum/element/ssd/Detach(datum/source, ...)
	. = ..()
	if(istype(source, /mob/living/silicon/robot/shell))
		return
	UnregisterSignal(source, list(
		COMSIG_MOB_LOGIN,
		COMSIG_MOB_LOGOUT,
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_REVIVE,
		COMSIG_MOB_ADMIN_GHOSTED,
	))
	if(isAI(source))
		UnregisterSignal(source, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF)
	if(iscyborg(source))
		UnregisterSignal(source, COMSIG_ATOM_UPDATE_OVERLAYS)
	if(isslimeperson(source))
		UnregisterSignal(source, COMSIG_SLIMEMAN_SWAPPED_BODY)

/datum/element/ssd/proc/on_mob_logout(mob/living/source)
	SIGNAL_HANDLER

	if(source.stat != DEAD)
		source.add_overlay(GLOB.ssd_indicator_overlay)
	source.player_logged = FALSE

/datum/element/ssd/proc/handle_detach(mob/living/source)
	source.cut_overlay(GLOB.ssd_indicator_overlay)
	source.player_logged = TRUE
	Detach(source)

/datum/element/ssd/proc/on_mob_login(mob/living/source)
	SIGNAL_HANDLER

	handle_detach(source)

/datum/element/ssd/proc/on_mob_death(mob/living/source)
	SIGNAL_HANDLER

	source.cut_overlay(GLOB.ssd_indicator_overlay)

/datum/element/ssd/proc/on_mob_revive(mob/living/source)
	SIGNAL_HANDLER

	source.add_overlay(GLOB.ssd_indicator_overlay)

/datum/element/ssd/proc/on_mob_admin_ghost(mob/living/source)
	SIGNAL_HANDLER

	if(!source.key || source.key[1] != "@")
		return

	handle_detach(source)

/datum/element/ssd/proc/on_ai_mind_transfer(mob/living/silicon/ai/source)
	SIGNAL_HANDLER

	handle_detach(source)

/datum/element/ssd/proc/on_cyborg_update_overlays(mob/living/silicon/robot/cyborg)
	SIGNAL_HANDLER

	if(cyborg.stat == DEAD)
		return
	if(GLOB.ssd_indicator_overlay in cyborg.overlays)
		return
	cyborg.add_overlay(GLOB.ssd_indicator_overlay)

/datum/element/ssd/proc/on_slimeman_swap_body(mob/living/source)
	SIGNAL_HANDLER

	handle_detach(source)

/mob/living/Logout()
	if(!QDELETED(src))
		AddElement(/datum/element/ssd)
	. = ..()

/mob/living
	var/player_logged = TRUE
