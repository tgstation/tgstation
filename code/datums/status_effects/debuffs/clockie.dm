/*/datum/status_effect/maniamotor
	id = "maniamotor"
	duration = -1
	tick_interval = 10
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/obj/structure/destructible/clockwork/powered/mania_motor/motor
	var/severity = 0 //goes up to a maximum of MAX_MANIA_SEVERITY
	var/warned_turnoff = FALSE //if we've warned that the motor is off
	var/warned_outofsight = FALSE //if we've warned that the target is out of sight of the motor
	var/static/list/mania_messages = list("Go nuts.", "Take a crack at crazy.", "Make a bid for insanity.", "Get kooky.", "Move towards mania.", "Become bewildered.", "Wax wild.", \
	"Go round the bend.", "Land in lunacy.", "Try dementia.", "Strive to get a screw loose.", "Advance forward.", "Approach the transmitter.", "Touch the antennae.", \
	"Move towards the mania motor.", "Come closer.", "Get over here already!", "Keep your eyes on the motor.")
	var/static/list/flee_messages = list("Oh, NOW you flee.", "Get back here!", "If you were smarter, you'd come back.", "Only fools run.", "You'll be back.")
	var/static/list/turnoff_messages = list("Why would they turn it-", "What are these idi-", "Fools, fools, all of-", "Are they trying to c-", "All this effort just f-")
	var/static/list/powerloss_messages = list("\"Oh, the id**ts di***t s***e en**** pow**...\"" = TRUE, "\"D*dn't **ey mak* an **te***c*i*n le**?\"" = TRUE, "\"The** f**ls for**t t* make a ***** *f-\"" = TRUE, \
	"\"No, *O, you **re so cl***-\"" = TRUE, "You hear a yell of frustration, cut off by static." = FALSE)

/datum/status_effect/maniamotor/on_creation(mob/living/new_owner, obj/structure/destructible/clockwork/powered/mania_motor/new_motor)
	. = ..()
	if(.)
		motor = new_motor

/datum/status_effect/maniamotor/Destroy()
	motor = null
	return ..()

/datum/status_effect/maniamotor/tick()
	var/is_servant = is_servant_of_ratvar(owner)
	var/span_part = severity > 50 ? "" : "_small" //let's save like one check
	if(QDELETED(motor))
		if(!is_servant)
			to_chat(owner, "<span class='sevtug[span_part]'>You feel a frustrated voice quietly fade from your mind...</span>")
		qdel(src)
		return
	if(!motor.active) //it being off makes it fall off much faster
		if(!is_servant && !warned_turnoff)
			if(can_access_clockwork_power(motor, motor.mania_cost))
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar(pick(turnoff_messages))]\"</span>")
			else
				var/pickedmessage = pick(powerloss_messages)
				to_chat(owner, "<span class='sevtug[span_part]'>[powerloss_messages[pickedmessage] ? "[text2ratvar(pickedmessage)]" : pickedmessage]</span>")
			warned_turnoff = TRUE
		severity = max(severity - 2, 0)
		if(!severity)
			qdel(src)
			return
	else
		if(prob(severity * 2))
			warned_turnoff = FALSE
		if(!(owner in viewers(7, motor))) //not being in range makes it fall off slightly faster
			if(!is_servant && !warned_outofsight)
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar(pick(flee_messages))]\"</span>")
				warned_outofsight = TRUE
			severity = max(severity - 1, 0)
			if(!severity)
				qdel(src)
				return
		else if(prob(severity * 2))
			warned_outofsight = FALSE
	if(is_servant) //heals servants of braindamage, hallucination, druggy, dizziness, and confusion
		if(owner.has_status_effect(/datum/status_effect/hallucination))
			owner.remove_status_effect(/datum/status_effect/hallucination)
		if(owner.has_status_effect(/datum/status_effect/drugginess))
			owner.remove_status_effect(/datum/status_effect/drugginess)
		if(owner.has_status_effect(/datum/status_effect/dizziness))
			owner.remove_status_effect(/datum/status_effect/dizziness)
		if(owner.has_status_effect(/datum/status_effect/confusion))
			owner.remove_status_effect(/datum/status_effect/confusion)
		severity = 0
	else if(!owner.can_block_magic(MAGIC_RESISTANCE) && owner.stat != DEAD && severity)
		var/static/hum = get_sfx('sound/effects/screech.ogg') //same sound for every proc call
		if(owner.getToxLoss() > MANIA_DAMAGE_TO_CONVERT)
			if(is_eligible_servant(owner))
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar("You are mine and his, now.")]\"</span>")
				if(add_servant_of_ratvar(owner))
					owner.log_message("conversion was done with a Mania Motor", LOG_ATTACK, color="#BE8700")
			owner.Unconscious(100)
		else
			if(prob(severity * 0.15))
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar(pick(mania_messages))]\"</span>")
			owner.playsound_local(get_turf(motor), hum, severity, 1)
			owner.adjust_drugginess(5 SECONDS)
			owner.set_dizzy_if_lower(5 SECONDS)
			owner.set_hallucinations_if_lower(5 SECONDS)
			owner.set_confusion_if_lower(2.5 SECONDS)
			owner.adjustToxLoss(severity * 0.02, TRUE, TRUE) //2% of severity per second
		severity--
*/

//Kindle: Used by servants of Ratvar. 10-second knockdown, reduced by 1 second per 5 damage taken while the effect is active.
/datum/status_effect/kindle
	id = "kindle"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5
	duration = 100
	alert_type = /atom/movable/screen/alert/status_effect/kindle
	var/old_health

/datum/status_effect/kindle/tick()
	owner.Paralyze(15)
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.adjust_silence_up_to(2 SECONDS, 5 SECONDS)
		C.adjust_stutter_up_to(4 SECONDS, 10 SECONDS)
	if(!old_health)
		old_health = owner.health
	var/health_difference = old_health - owner.health
	if(!health_difference)
		return
	owner.visible_message("<span class='warning'>The light in [owner]'s eyes dims as [owner.p_theyre()] harmed!</span>", \
	"<span class='boldannounce'>The dazzling lights dim as you're harmed!</span>")
	health_difference *= 2 //so 10 health difference translates to 20 deciseconds of stun reduction
	duration -= health_difference
	old_health = owner.health

/datum/status_effect/kindle/on_remove()
	owner.visible_message("<span class='warning'>The light in [owner]'s eyes fades!</span>", \
	"<span class='boldannounce'>You snap out of your daze!</span>")

/atom/movable/screen/alert/status_effect/kindle
	name = "Dazzling Lights"
	desc = "Blinding light dances in your vision, stunning and silencing you. <i>Any damage taken will shorten the light's effects!</i>"
	icon_state = "kindle"
	alerttooltipstyle = "clockcult"


//Ichorial Stain: Applied to servants revived by a vitality matrix. Prevents them from being revived by one again until the effect fades.
/datum/status_effect/ichorial_stain
	id = "ichorial_stain"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 600
	alert_type = /atom/movable/screen/alert/status_effect/ichorial_stain

/datum/status_effect/ichorial_stain/get_examine_text()
    return span_warning("[owner.p_they(TRUE)] is drenched in thick, blue ichor!")

/datum/status_effect/ichorial_stain/on_apply()
	owner.visible_message("<span class='danger'>[owner] gets back up, [owner.p_their()] body dripping blue ichor!</span>", \
	"<span class='userdanger'>Thick blue ichor covers your body; you can't be revived like this again until it dries!</span>")
	return TRUE

/datum/status_effect/ichorial_stain/on_remove()
	owner.visible_message("<span class='danger'>The blue ichor on [owner]'s body dries out!</span>", \
	"<span class='boldnotice'>The ichor on your body is dry - you can now be revived by vitality matrices again!</span>")

/atom/movable/screen/alert/status_effect/ichorial_stain
	name = "Ichorial Stain"
	desc = "Your body is covered in blue ichor! You can't be revived by vitality matrices."
	icon_state = "ichorial_stain"
	alerttooltipstyle = "clockcult"

//Clock cult
/datum/status_effect/interdiction
	id = "interdicted"
	duration = 25
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 1
	alert_type = /atom/movable/screen/alert/status_effect/interdiction
	var/running_toggled = FALSE

/datum/status_effect/interdiction/tick()
	if(owner.m_intent == MOVE_INTENT_RUN)
		owner.toggle_move_intent(owner)
		running_toggled = TRUE
		to_chat(owner, "<span class='warning'>You know you shouldn't be running here...</span>")
	owner.add_movespeed_modifier(/datum/movespeed_modifier/interdiction)

/datum/movespeed_modifier/interdiction
	multiplicative_slowdown = 1.5
	movetypes = GROUND

/datum/status_effect/interdiction/on_remove()
	owner.remove_movespeed_modifier(MOVESPEED_ID_INTERDICTION)
	if(running_toggled && owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent(owner)

/atom/movable/screen/alert/status_effect/interdiction
	name = "Interdicted"
	desc = "I don't think I am meant to go this way..."
	icon_state = "inathneqs_endowment"
