//Wraith spectacles: Grants x-ray and night vision at the eventual cost of the wearer's sight if worn too long. Nar-Sian cultists are instantly blinded.
/obj/item/clothing/glasses/wraith_spectacles
	name = "antique spectacles"
	desc = "Unnerving glasses with opaque yellow lenses."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "wraith_specs"
	item_state = "glasses"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	vision_flags = SEE_MOBS | SEE_TURFS | SEE_OBJS
	invis_view = 2
	darkness_view = 3

/obj/item/clothing/glasses/wraith_spectacles/New()
	..()
	all_clockwork_objects += src

/obj/item/clothing/glasses/wraith_spectacles/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/clothing/glasses/wraith_spectacles/equipped(mob/living/user, slot)
	..()
	if(slot != slot_glasses)
		return
	if(user.disabilities & BLIND)
		user << "<span class='heavy_brass'>\"You're blind, idiot. Stop embarassing yourself.\"</span>" //Ratvar with the sick burns yo
		return
	if(iscultist(user)) //Cultists instantly go blind
		user << "<span class='heavy_brass'>\"It looks like Nar-Sie's dogs really don't value their eyes.\"</span>"
		user << "<span class='userdanger'>Your eyes explode with horrific pain!</span>"
		user.emote("scream")
		user.become_blind()
		user.adjust_blurriness(30)
		user.adjust_blindness(30)
		return
	if(is_servant_of_ratvar(user))
		tint = 0
		user << "<span class='heavy_brass'>As you put on the spectacles, all is revealed to you.[ratvar_awakens ? "" : " Your eyes begin to itch - you cannot do this for long."]</span>"
		user.apply_status_effect(STATUS_EFFECT_WRAITHSPECS)
	else
		tint = 3
		user << "<span class='heavy_brass'>You put on the spectacles, but you can't see through the glass.</span>"

//The effect that causes/repairs the damage the spectacles cause.
/datum/status_effect/wraith_spectacles
	id = "wraith_spectacles"
	duration = -1 //remains until eye damage done reaches 0 while the glasses are not worn
	tick_interval = 2
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
		desc = "[glasses_right ? "<font color=#DAAA18><b>":""]You are [glasses_right ? "":"not "]wearing wraith spectacles[glasses_right ? "!</b></font>":"."]<br>\
		You have taken <font color=#DAAA18><b>[W.eye_damage_done]</b></font> eye damage from them.<br>"
		if(L.disabilities & NEARSIGHT)
			desc += "<font color=#DAAA18><b>You are nearsighted!</b></font><br>"
		else if(glasses_right)
			desc += "You will become nearsighted at <font color=#DAAA18><b>[W.nearsight_breakpoint]</b></font> eye damage.<br>"
		if(L.disabilities & BLIND)
			desc += "<font color=#DAAA18><b>You are blind!</b></font>"
		else if(glasses_right)
			desc += "You will become blind at <font color=#DAAA18><b>[W.blind_breakpoint]</b></font> eye damage."
	..()

/datum/status_effect/wraith_spectacles/tick()
	if(!ishuman(owner))
		cancel_effect()
		return
	var/mob/living/carbon/human/H = owner
	if(istype(H.glasses, /obj/item/clothing/glasses/wraith_spectacles) && !ratvar_awakens)
		if(H.disabilities & BLIND)
			return
		H.adjust_eye_damage(1)
		eye_damage_done++
		if(eye_damage_done >= 20)
			H.adjust_blurriness(2)
		if(eye_damage_done >= nearsight_breakpoint)
			if(H.become_nearsighted())
				H << "<span class='nzcrentr'>Your vision doubles, then trebles. Darkness begins to close in. You can't keep this up!</span>"
		if(eye_damage_done >= blind_breakpoint)
			if(H.become_blind())
				H << "<span class='nzcrentr_large'>A piercing white light floods your vision. Suddenly, all goes dark!</span>"
		if(prob(min(20, 5 + eye_damage_done)))
			H << "<span class='nzcrentr_small'><i>Your eyes continue to burn.</i></span>"
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
			cancel_effect()
