//Wraith spectacles: Grants x-ray and night vision at the eventual cost of the wearer's sight if worn too long. Nar-Sian cultists are instantly blinded.
/obj/item/clothing/glasses/wraith_spectacles
	name = "antique spectacles"
	desc = "Unnerving glasses with opaque yellow lenses."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "wraith_specs"
	item_state = "glasses"
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_cover = GLASSESCOVERSEYES
	visor_flags_inv = HIDEEYES
	visor_vars_to_toggle = NONE //we don't actually toggle anything we just set it
	tint = 3 //this'll get reset, but it won't handle vision updates properly otherwise

/obj/item/clothing/glasses/wraith_spectacles/New()
	..()
	all_clockwork_objects += src

/obj/item/clothing/glasses/wraith_spectacles/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/clothing/glasses/wraith_spectacles/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/glasses/wraith_spectacles/visor_toggling()
	..()
	set_vision_vars(FALSE)

/obj/item/clothing/glasses/wraith_spectacles/weldingvisortoggle(mob/user)
	. = ..()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(src == H.glasses && !up)
			if(H.disabilities & BLIND)
				to_chat(H, "<span class='heavy_brass'>\"You're blind, idiot. Stop embarrassing yourself.\"</span>")
				return
			if(blind_cultist(H))
				return
			if(is_servant_of_ratvar(H))
				to_chat(H, "<span class='heavy_brass'>You push the spectacles down, and all is revealed to you.[ratvar_awakens ? "" : " Your eyes begin to itch - you cannot do this for long."]</span>")
				var/datum/status_effect/wraith_spectacles/WS = H.has_status_effect(STATUS_EFFECT_WRAITHSPECS)
				if(WS)
					WS.apply_eye_damage(H)
				H.apply_status_effect(STATUS_EFFECT_WRAITHSPECS)
			else
				to_chat(H, "<span class='heavy_brass'>You push the spectacles down, but you can't see through the glass.</span>")

/obj/item/clothing/glasses/wraith_spectacles/proc/blind_cultist(mob/living/victim)
	if(iscultist(victim))
		to_chat(victim, "<span class='heavy_brass'>\"It looks like Nar-Sie's dogs really don't value their eyes.\"</span>")
		to_chat(victim, "<span class='userdanger'>Your eyes explode with horrific pain!</span>")
		victim.emote("scream")
		victim.become_blind()
		victim.adjust_blurriness(30)
		victim.adjust_blindness(30)
		return TRUE

/obj/item/clothing/glasses/wraith_spectacles/proc/set_vision_vars(update_vision)
	invis_view = SEE_INVISIBLE_LIVING
	tint = 0
	vision_flags = NONE
	darkness_view = 2
	if(!up)
		if(is_servant_of_ratvar(loc))
			invis_view = SEE_INVISIBLE_NOLIGHTING
			vision_flags = SEE_MOBS | SEE_TURFS | SEE_OBJS
			darkness_view = 3
		else
			tint = 3
	if(update_vision && iscarbon(loc))
		var/mob/living/carbon/C = loc
		C.head_update(src, forced = 1)

/obj/item/clothing/glasses/wraith_spectacles/equipped(mob/living/user, slot)
	..()
	if(slot != slot_glasses || up)
		return
	if(user.disabilities & BLIND)
		to_chat(user, "<span class='heavy_brass'>\"You're blind, idiot. Stop embarrassing yourself.\"</span>" )
		return
	if(blind_cultist(user)) //Cultists instantly go blind
		return
	set_vision_vars(TRUE)
	if(is_servant_of_ratvar(user))
		to_chat(user, "<span class='heavy_brass'>As you put on the spectacles, all is revealed to you.[ratvar_awakens ? "" : " Your eyes begin to itch - you cannot do this for long."]</span>")
		var/datum/status_effect/wraith_spectacles/WS = user.has_status_effect(STATUS_EFFECT_WRAITHSPECS)
		if(WS)
			WS.apply_eye_damage(user)
		user.apply_status_effect(STATUS_EFFECT_WRAITHSPECS)
	else
		to_chat(user, "<span class='heavy_brass'>You put on the spectacles, but you can't see through the glass.</span>")

//The effect that causes/repairs the damage the spectacles cause.
/datum/status_effect/wraith_spectacles
	id = "wraith_spectacles"
	duration = -1 //remains until eye damage done reaches 0 while the glasses are not worn
	tick_interval = 20
	alert_type = /obj/screen/alert/status_effect/wraith_spectacles
	var/eye_damage_done = 0
	var/nearsight_breakpoint = 30
	var/blind_breakpoint = 45

/obj/screen/alert/status_effect/wraith_spectacles
	name = "Wraith Spectacles"
	desc = "You shouldn't actually see this, as it should be procedurally generated."
	icon_state = "wraithspecs"
	alerttooltipstyle = "clockcult"

/obj/screen/alert/status_effect/wraith_spectacles/MouseEntered(location,control,params)
	var/mob/living/carbon/human/L = usr
	if(istype(L)) //this is probably more safety than actually needed
		var/datum/status_effect/wraith_spectacles/W = attached_effect
		var/glasses_right = istype(L.glasses, /obj/item/clothing/glasses/wraith_spectacles)
		var/obj/item/clothing/glasses/wraith_spectacles/WS = L.glasses
		desc = "[glasses_right && !WS.up ? "<font color=#DAAA18><b>":""]You are [glasses_right ? "":"not "]wearing wraith spectacles[glasses_right && !WS.up ? "!</b></font>":"."]<br>\
		You have taken <font color=#DAAA18><b>[W.eye_damage_done]</b></font> eye damage from them.<br>"
		if(L.disabilities & NEARSIGHT)
			desc += "<font color=#DAAA18><b>You are nearsighted!</b></font><br>"
		else if(glasses_right && !WS.up)
			desc += "You will become nearsighted at <font color=#DAAA18><b>[W.nearsight_breakpoint]</b></font> eye damage.<br>"
		if(L.disabilities & BLIND)
			desc += "<font color=#DAAA18><b>You are blind!</b></font>"
		else if(glasses_right && !WS.up)
			desc += "You will become blind at <font color=#DAAA18><b>[W.blind_breakpoint]</b></font> eye damage."
	..()

/datum/status_effect/wraith_spectacles/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		apply_eye_damage(H)

/datum/status_effect/wraith_spectacles/tick()
	if(!ishuman(owner))
		qdel(src)
		return
	var/mob/living/carbon/human/H = owner
	var/glasses_right = istype(H.glasses, /obj/item/clothing/glasses/wraith_spectacles)
	var/obj/item/clothing/glasses/wraith_spectacles/WS = H.glasses
	if(glasses_right && !WS.up && !ratvar_awakens)
		apply_eye_damage(H)
	else
		if(ratvar_awakens)
			H.cure_nearsighted()
			H.cure_blind()
			H.adjust_eye_damage(-eye_damage_done)
			eye_damage_done = 0
		else if(prob(50) && eye_damage_done)
			H.adjust_eye_damage(-1)
			eye_damage_done--
		if(!eye_damage_done)
			qdel(src)

/datum/status_effect/wraith_spectacles/proc/apply_eye_damage(mob/living/carbon/human/H)
	if(H.disabilities & BLIND)
		return
	H.adjust_eye_damage(1)
	eye_damage_done++
	if(eye_damage_done >= 20)
		H.adjust_blurriness(2)
	if(eye_damage_done >= nearsight_breakpoint)
		if(H.become_nearsighted())
			to_chat(H, "<span class='nzcrentr'>Your vision doubles, then trebles. Darkness begins to close in. You can't keep this up!</span>")
	if(eye_damage_done >= blind_breakpoint)
		if(H.become_blind())
			to_chat(H, "<span class='nzcrentr_large'>A piercing white light floods your vision. Suddenly, all goes dark!</span>")
	if(prob(min(20, 5 + eye_damage_done)))
		to_chat(H, "<span class='nzcrentr_small'><i>Your eyes continue to burn.</i></span>")
