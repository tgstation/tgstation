//entirely neutral or internal status effects go here

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target

/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target

/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()

/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)

/datum/status_effect/syphon_mark/tick()
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)

/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/obj/screen/alert/status_effect/in_love
	name = "In Love"
	desc = "You feel so wonderfully in love!"
	icon_state = "in_love"

/datum/status_effect/in_love
	id = "in_love"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /obj/screen/alert/status_effect/in_love
	var/mob/living/date

/datum/status_effect/in_love/on_creation(mob/living/new_owner, mob/living/love_interest)
	. = ..()
	if(.)
		date = love_interest
		linked_alert.desc = "You're in love with [date.real_name]! How lovely."

/datum/status_effect/in_love/tick()
	if(date)
		new /obj/effect/temp_visual/love_heart/invisible(date.drop_location(), owner)

/datum/status_effect/throat_soothed
	id = "throat_soothed"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/throat_soothed/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/throat_soothed/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SOOTHED_THROAT, "[STATUS_EFFECT_TRAIT]_[id]")

/datum/status_effect/bounty
	id = "bounty"
	status_type = STATUS_EFFECT_UNIQUE
	var/mob/living/rewarded

/datum/status_effect/bounty/on_creation(mob/living/new_owner, mob/living/caster)
	. = ..()
	if(.)
		rewarded = caster

/datum/status_effect/bounty/on_apply()
	to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>You have been marked for death by [rewarded]. If you die, they will be rewarded.</span>")
	playsound(owner, 'sound/weapons/gun/shotgun/rack.ogg', 75, FALSE)
	return ..()

/datum/status_effect/bounty/tick()
	if(owner.stat == DEAD)
		rewards()
		qdel(src)

/datum/status_effect/bounty/proc/rewards()
	if(rewarded && rewarded.mind && rewarded.stat != DEAD)
		to_chat(owner, "<span class='boldnotice'>You hear something behind you talking...</span> <span class='notice'>Bounty claimed.</span>")
		playsound(owner, 'sound/weapons/gun/shotgun/shot.ogg', 75, FALSE)
		to_chat(rewarded, "<span class='greentext'>You feel a surge of mana flow into you!</span>")
		for(var/obj/effect/proc_holder/spell/spell in rewarded.mind.spell_list)
			spell.charge_counter = spell.charge_max
			spell.recharging = FALSE
			spell.update_icon()
		rewarded.adjustBruteLoss(-25)
		rewarded.adjustFireLoss(-25)
		rewarded.adjustToxLoss(-25)
		rewarded.adjustOxyLoss(-25)
		rewarded.adjustCloneLoss(-25)

// heldup is for the person being aimed at
/datum/status_effect/heldup
	id = "heldup"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = /obj/screen/alert/status_effect/heldup

/obj/screen/alert/status_effect/heldup
	name = "Held Up"
	desc = "Making any sudden moves would probably be a bad idea!"
	icon_state = "aimed"

// holdup is for the person aiming
/datum/status_effect/holdup
	id = "holdup"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /obj/screen/alert/status_effect/holdup

/obj/screen/alert/status_effect/holdup
	name = "Holding Up"
	desc = "You're currently pointing a gun at someone."
	icon_state = "aimed"

/datum/status_effect/aegis
	id = "protected"
	duration = 15 SECONDS
	examine_text = "<span class='notice'>They are being guarded closely.</span>"
	alert_type = /obj/screen/alert/status_effect/protected
	var/alert_type_protector = /obj/screen/alert/status_effect/protector
	var/obj/screen/alert/status_effect/linked_alert_protector
	var/mob/living/protector
	var/original_alpha = 255
	var/defensive_buff_factor = 0.75
	var/paralyze_duration = 1.5 SECONDS

/obj/screen/alert/status_effect/protected
	name = "Protected"
	desc = "Someone is covering and leading you while protecting you from attacks. You can click here to make them release you."
	icon_state = "aimed"

/obj/screen/alert/status_effect/protector
	name = "Protecting"
	desc = "You're currently leading and defending someone from attacks, while benefiting from a defensive buff. You can click here to manually release them."
	icon_state = "aimed"

/obj/screen/alert/status_effect/protected/Click()
	var/mob/living/L = usr
	if(L != owner)
		return
	QDEL_NULL(attached_effect)
	qdel(src)

/obj/screen/alert/status_effect/protector/Click()
	var/mob/living/L = usr
	if(L != owner)
		return
	QDEL_NULL(attached_effect)
	qdel(src)

/datum/status_effect/aegis/on_creation(mob/living/new_owner, mob/living/protector)
	src.protector = protector
	linked_alert_protector = protector.throw_alert(id, alert_type_protector)
	linked_alert_protector.attached_effect = src
	RegisterSignal(new_owner, COMSIG_CARBON_ATTACKED_BY, .proc/interrupt_hit)
	RegisterSignal(new_owner, COMSIG_MOVABLE_MOVED, .proc/check_protectee_dist)
	RegisterSignal(new_owner, list(COMSIG_PROJECTILE_PREHIT, COMSIG_PROJECTILE_POINT_BLANK), .proc/interrupt_bullet)
	RegisterSignal(protector, COMSIG_MOVABLE_MOVED, .proc/take_me_with_you)
	RegisterSignal(protector, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), .proc/cancel_protection)
	..()

/datum/status_effect/aegis/on_apply()
	owner.visible_message("<span class='notice'><b>[protector] covers [owner] with [protector.p_their()] body, guarding against attacks!</b></span>", "<span class='notice'><b>[protector] covers you with [protector.p_their()] body, guarding against attacks!</b></span>")
	examine_text = "<span class='notice'><b>[owner.p_they(TRUE)] [owner.p_are()] being guarded closely by [protector].</b></span>"
	original_alpha = owner.alpha
	owner.alpha = 100
	playsound(owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	protector.forceMove(owner.loc)
	owner.SetKnockdown(duration)
	owner.SetImmobilized(paralyze_duration)
	apply_defensive_buff()
	return ..()

/datum/status_effect/aegis/on_remove()
	if(owner && protector)
		owner.visible_message("<span class='notice'>[protector] ceases guarding [owner].</span>", "<span class='notice'><b>[protector] ceases guarding you.</b></span>")

	if(owner)
		owner.alpha = original_alpha
		UnregisterSignal(owner, list(COMSIG_CARBON_ATTACKED_BY, COMSIG_MOVABLE_MOVED, COMSIG_PROJECTILE_PREHIT, COMSIG_PROJECTILE_POINT_BLANK))
		owner.SetKnockdown(0)
		owner.SetImmobilized(0)

	if(protector)
		protector.clear_alert(id)
		remove_defensive_buff()
		UnregisterSignal(protector, list(COMSIG_MOVABLE_MOVED, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED)))

/datum/status_effect/aegis/proc/apply_defensive_buff()
	protector.SetKnockdown(0)
	protector.add_movespeed_modifier(/datum/movespeed_modifier/mob_protector)
	var/obj/screen/alert/status_effect/A = owner.throw_alert(id, alert_type)
	protector.throw_alert()
	if(ishuman(protector))
		var/mob/living/carbon/human/H = protector
		H.physiology.brute_mod *= defensive_buff_factor
		H.physiology.burn_mod *= defensive_buff_factor
		H.physiology.stamina_mod *= defensive_buff_factor

/datum/status_effect/aegis/proc/remove_defensive_buff()
	protector.remove_movespeed_modifier(/datum/movespeed_modifier/mob_protector)
	if(ishuman(protector))
		if(owner)
			protector.start_pulling(owner, GRAB_PASSIVE, supress_message=TRUE)
		var/mob/living/carbon/human/H = protector
		H.physiology.brute_mod /= defensive_buff_factor
		H.physiology.burn_mod /= defensive_buff_factor
		H.physiology.stamina_mod /= defensive_buff_factor

/datum/status_effect/aegis/proc/interrupt_hit(mob/living/carbon/C, obj/item/I, mob/living/user, obj/item/bodypart/affecting)
	if(!I.force || user == C)
		return

	owner.visible_message("<span class='danger'>[protector] throws [protector.p_them()]self in front of an attack meant for [owner]!</span>", "<span class='danger'><b>[protector] throws [protector.p_them()]self in front of an attack meant for you!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=protector)
	to_chat(protector, "<span class='danger'><b>You throw yourself in front of an attack meant for [owner]!</b></span>")
	protector.attacked_by(I, user)
	return COMSIG_ATTACK_INTERRUPT

/datum/status_effect/aegis/proc/interrupt_bullet(atom/source, list/signal_args)
	owner.visible_message("<span class='danger'>[protector] throws [protector.p_them()]self in front of an attack meant for [owner]!</span>", "<span class='danger'><b>[protector] throws [protector.p_them()]self in front of an attack meant for you!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=protector)
	to_chat(protector, "<span class='danger'><b>You throw yourself in front of an attack meant for [owner]!</b></span>")
	signal_args[2] = protector

/datum/status_effect/aegis/proc/check_protectee_dist()
	if(get_dist(owner.loc, protector.loc) > 1)
		cancel_protection()

/datum/status_effect/aegis/proc/cancel_protection()
	qdel(src)

/datum/status_effect/aegis/proc/take_me_with_you()
	owner.forceMove(protector.loc)
