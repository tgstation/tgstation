/obj/item/organ/internal/cyberimp/leg
	name = "leg implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_LEG
	icon_state = "implant-leg"
	w_class = WEIGHT_CLASS_NORMAL

	//to determine what type of implant for checking if both legs are the same
	var/implant_type = "leg implant"
	COOLDOWN_DECLARE(emp_notice)

/obj/item/organ/internal/cyberimp/leg/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)
	SetSlotFromZone()

/obj/item/organ/internal/cyberimp/leg/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	var/obj/item/bodypart/L = owner.get_bodypart(zone)
	if(!L)	//how did you get an implant in a limb you don't have?
		return

	L.receive_damage(severity / 2, 0, severity)	//always take a least a little bit of damage to the leg

	if(prob(50))	//you're forced to use two of these for them to work so let's give em a chance to not get completely fucked
		if(COOLDOWN_FINISHED(src, emp_notice))
			to_chat(owner, span_warning("The EMP causes the [src] in your [L] to twitch randomly!"))
			COOLDOWN_START(src, emp_notice, 30 SECONDS)
		return

	L.set_disabled(TRUE)	//disable the bodypart
	addtimer(CALLBACK(src, PROC_REF(reenableleg)), (severity / 2) SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

	if(severity > EMP_LIGHT && prob(5))	//put probabilities into a calculator before you try fucking with this
		to_chat(owner, span_warning("[src] malfunctions and thrashes your [L] around wildly, breaking it!"))
		var/datum/wound/blunt/bone/severe/breakdown = new
		breakdown.apply_wound(L)
		L.receive_damage(20)
	else if(COOLDOWN_FINISHED(src, emp_notice))
		to_chat(owner, span_warning("[src] malfunctions and causes your muscles to seize up, preventing your [L] from moving!"))
		COOLDOWN_START(src, emp_notice, 30 SECONDS)

/obj/item/organ/internal/cyberimp/leg/proc/reenableleg()
	var/obj/item/bodypart/L = owner.get_bodypart(zone)
	if(!L)	//You got emped and then lost the leg in those 10 seconds? impressive
		return

	L.set_disabled(FALSE)

/obj/item/organ/internal/cyberimp/leg/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_LEG)
			slot = ORGAN_SLOT_LEFT_LEG_AUG
		if(BODY_ZONE_R_LEG)
			slot = ORGAN_SLOT_RIGHT_LEG_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/internal/cyberimp/leg/update_icon(updates=ALL)
	. = ..()
	if(zone == BODY_ZONE_R_LEG)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/leg/examine(mob/user)
	. = ..()
	. += span_info("[src] is assembled in the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg configuration. You can use a screwdriver to reassemble it.")
	. += span_info("You will need two of the same type of implant for them to properly function.")

/obj/item/organ/internal/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return .
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_LEG)
		zone = BODY_ZONE_L_LEG
	else
		zone = BODY_ZONE_R_LEG
	SetSlotFromZone()
	to_chat(user, span_notice("You modify [src] to be installed on the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg."))
	update_appearance(UPDATE_ICON)

/obj/item/organ/internal/cyberimp/leg/Insert(mob/living/carbon/M, special, drop_if_replaced, special_zone)
	. = ..()
	if(HasBoth())
		AddEffect()

/obj/item/organ/internal/cyberimp/leg/Remove(mob/living/carbon/M, special)
	RemoveEffect()
	. = ..()

/obj/item/organ/internal/cyberimp/leg/proc/HasBoth()
	if(owner.get_organ_slot(ORGAN_SLOT_RIGHT_LEG_AUG) && owner.get_organ_slot(ORGAN_SLOT_LEFT_LEG_AUG))
		var/obj/item/organ/internal/cyberimp/leg/left = owner.get_organ_slot(ORGAN_SLOT_LEFT_LEG_AUG)
		var/obj/item/organ/internal/cyberimp/leg/right = owner.get_organ_slot(ORGAN_SLOT_RIGHT_LEG_AUG)
		if(left.implant_type == right.implant_type)
			return TRUE
	return FALSE

/obj/item/organ/internal/cyberimp/leg/proc/AddEffect()
	return

/obj/item/organ/internal/cyberimp/leg/proc/RemoveEffect()
	return

//------------water noslip implant
/obj/item/organ/internal/cyberimp/leg/galosh
	name = "antislip implant"
	desc = "An implant that uses sensors and motors to detect when you are slipping and attempt to prevent it. It probably won't help if the floor is too slippery."
	implant_type = "noslipwater"

/obj/item/organ/internal/cyberimp/leg/galosh/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/internal/cyberimp/leg/galosh/AddEffect()
	ADD_TRAIT(owner, TRAIT_NO_SLIP_WATER, "Antislip_implant")
	ADD_TRAIT(owner, TRAIT_NO_SLIP_ICE, "Antislip_implant")

/obj/item/organ/internal/cyberimp/leg/galosh/RemoveEffect()
	REMOVE_TRAIT(owner, TRAIT_NO_SLIP_WATER, "Antislip_implant")
	REMOVE_TRAIT(owner, TRAIT_NO_SLIP_ICE, "Antislip_implant")

/obj/item/organ/internal/cyberimp/leg/galosh/syndicate/l
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/leg/galosh/syndicate/l
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	zone = BODY_ZONE_L_LEG

//------------true noslip implant
/obj/item/organ/internal/cyberimp/leg/noslip
	name = "advanced antislip implant"
	desc = "An implant that uses advanced sensors to detect when you are slipping and utilize motors in order to prevent it."
	implant_type = "noslipall"

/obj/item/organ/internal/cyberimp/leg/noslip/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/internal/cyberimp/leg/noslip/AddEffect()
	ADD_TRAIT(owner, TRAIT_NO_SLIP_ALL, "Noslip_implant")

/obj/item/organ/internal/cyberimp/leg/noslip/RemoveEffect()
	REMOVE_TRAIT(owner, TRAIT_NO_SLIP_ALL, "Noslip_implant")

/obj/item/organ/internal/cyberimp/leg/noslip/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/leg/noslip/syndicate/l
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	zone = BODY_ZONE_L_LEG

//------------dash boots implant
/obj/item/organ/internal/cyberimp/leg/jumpboots
	name = "jumpboots implant"
	desc = "An implant with a specialized propulsion system for rapid foward movement."
	implant_type = "jumpboots"
	var/datum/action/cooldown/boost/implant_ability

/obj/item/organ/internal/cyberimp/leg/jumpboots/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/internal/cyberimp/leg/jumpboots/AddEffect()
	ADD_TRAIT(owner, TRAIT_NO_SLIP_ICE, "Jumpboot_implant")
	implant_ability = new(src)
	implant_ability.Grant(owner)

/obj/item/organ/internal/cyberimp/leg/jumpboots/RemoveEffect()
	REMOVE_TRAIT(owner, TRAIT_NO_SLIP_ICE, "Jumpboot_implant")
	if(implant_ability)
		implant_ability.Remove(owner)

/obj/item/organ/internal/cyberimp/leg/jumpboots/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/leg/jumpboots/syndicate/l
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	zone = BODY_ZONE_L_LEG

//surf_ss13
/datum/action/cooldown/boost
	name = "Dash"
	desc = "Dash forward."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	cooldown_time = 6 SECONDS
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3

/datum/action/cooldown/boost/link_to(target)
	..()
	if(target && isitem(target)) // Imitate an item_action
		var/obj/item/I = target
		LAZYINITLIST(I.actions)
		I.actions += src

/datum/action/cooldown/boost/Activate()
	var/atom/target = get_edge_target_turf(owner, owner.dir) //gets the user's direction

	if(!owner.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(unstun), owner)))
		to_chat(owner, span_warning("Something prevents you from dashing forward!"))
		return

	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))

	addtimer(CALLBACK(src, PROC_REF(unstun), owner), 1 SECONDS) // in case the throw callback fails/lags for whatever reason

	playsound(owner, 'sound/effects/stealthoff.ogg', 50, TRUE, 1)
	owner.visible_message(span_warning("[owner] dashes forward into the air!"))
	StartCooldown()

/datum/action/cooldown/boost/proc/unstun(mob/living/stunned)
	REMOVE_TRAIT(stunned, TRAIT_IMMOBILIZED, REF(src))


//------------Airshoes implant
/obj/item/organ/internal/cyberimp/leg/airshoes
	name = "advanced propulsion implant"
	desc = "An implant that uses propulsion technology to keep you above the ground and let you move faster."
	implant_type = "airshoes"
	var/datum/action/cooldown/airshoes/implant_dash

/obj/item/organ/internal/cyberimp/leg/airshoes/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/internal/cyberimp/leg/airshoes/AddEffect()
	ADD_TRAIT(owner, TRAIT_NO_SLIP_ICE, "Airshoes_implant")
	implant_dash = new
	implant_dash.Grant(owner)
	implant_dash.jumpdistance = 7
	implant_dash.jumpspeed = 5//this makes it function like the airshoes

/obj/item/organ/internal/cyberimp/leg/airshoes/RemoveEffect()
	REMOVE_TRAIT(owner, TRAIT_NO_SLIP_ICE, "Airshoes_implant")
	if(implant_dash)
		implant_dash.Remove(owner)

/obj/item/organ/internal/cyberimp/leg/airshoes/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/leg/airshoes/syndicate/l
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	zone = BODY_ZONE_L_LEG


/datum/action/cooldown/airshoes
	name = "Dash"
	desc = "Dash forward."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "thrust"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	cooldown_time = 4 SECONDS
	var/jumpdistance = 7 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 5

/datum/action/cooldown/airshoes/link_to(target)
	..()
	if(target && isitem(target)) // Imitate an item_action
		var/obj/item/I = target
		LAZYINITLIST(I.actions)
		I.actions += src

/datum/action/cooldown/airshoes/Activate()
	var/atom/target = get_edge_target_turf(owner, owner.dir) //gets the user's direction

	if(!owner.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(unstun), owner)))
		to_chat(owner, span_warning("Something prevents you from dashing forward!"))
		return

	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))

	addtimer(CALLBACK(src, PROC_REF(unstun), owner), 1 SECONDS) // in case the throw callback fails/lags for whatever reason

	playsound(owner, 'sound/effects/airshoesdash.ogg', 50, TRUE, 1)
	owner.visible_message(span_warning("[owner] dashes forward into the air!"))
	StartCooldown()

/datum/action/cooldown/airshoes/proc/unstun(mob/living/stunned)
	REMOVE_TRAIT(stunned, TRAIT_IMMOBILIZED, REF(src))

//------------magboot implant
/obj/item/organ/internal/cyberimp/leg/magboot
	name = "magboot implant"
	desc = "Integrated maglock implant, allows easy movement in a zero-gravity environment."
	implant_type = "magboot"
	var/datum/action/innate/magboots/implant_ability

/obj/item/organ/internal/cyberimp/leg/magboot/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/internal/cyberimp/leg/magboot/AddEffect()
	implant_ability = new
	implant_ability.Grant(owner)

/obj/item/organ/internal/cyberimp/leg/magboot/RemoveEffect()
	if(implant_ability)
		implant_ability.Remove(owner)
	owner.remove_movespeed_modifier("Magbootimplant")

/datum/action/innate/magboots
	var/lockdown = FALSE
	name = "Maglock"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "magboots0"
	button_icon = 'icons/obj/clothing/shoes.dmi'
	background_icon_state = "bg_default"

/datum/action/innate/magboots/Grant(mob/M)
	if(!ishuman(M))
		return
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(UpdateSpeed))

/datum/action/innate/magboots/Remove(mob/M)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
	. = ..()

/datum/action/innate/magboots/Activate()
	if(!lockdown)
		ADD_TRAIT(owner, TRAIT_NO_SLIP_WATER, "maglock implant")
		ADD_TRAIT(owner, TRAIT_NO_SLIP_ICE, "maglock_implant")
		ADD_TRAIT(owner, TRAIT_NEGATES_GRAVITY, "maglock implant")
		button_icon_state = "magboots1"
	else
		REMOVE_TRAIT(owner, TRAIT_NO_SLIP_WATER, "maglock implant")
		REMOVE_TRAIT(owner, TRAIT_NO_SLIP_ICE, "maglock_implant")
		REMOVE_TRAIT(owner, TRAIT_NEGATES_GRAVITY, "maglock implant")
		button_icon_state = "magboots0"
	build_all_button_icons()
	lockdown = !lockdown
	to_chat(owner, span_notice("You [lockdown ? "enable" : "disable"] your mag-pulse traction system."))

/datum/action/innate/magboots/proc/UpdateSpeed()
	if(lockdown && !HAS_TRAIT(owner, TRAIT_IGNORESLOWDOWN) && owner.has_gravity())
		owner.add_movespeed_modifier(/datum/movespeed_modifier/magbootimplant, update=TRUE)
	else if(owner.has_movespeed_modifier(/datum/movespeed_modifier/magbootimplant))
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/magbootimplant)

/obj/item/organ/internal/cyberimp/leg/magboot/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

/obj/item/organ/internal/cyberimp/leg/magboot/syndicate/l
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	zone = BODY_ZONE_L_LEG
