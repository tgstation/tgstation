//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS
/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/update_canmove = TRUE

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, updating_canmove)
	..()
	if(isnum(updating_canmove))
		update_canmove = updating_canmove
	if(update_canmove)
		owner.update_canmove()
		if(issilicon(owner))
			owner.update_stat()

/datum/status_effect/incapacitating/on_apply()
	. = ..()
	update_canmove = TRUE

/datum/status_effect/incapacitating/on_remove()
	if(update_canmove)
		owner.update_canmove()
		if(issilicon(owner)) //silicons need stat updates in addition to normal canmove updates
			owner.update_stat()

//STUN
/datum/status_effect/incapacitating/stun
	id = "stun"

//KNOCKDOWN
/datum/status_effect/incapacitating/knockdown
	id = "knockdown"

//UNCONSCIOUS
/datum/status_effect/incapacitating/unconscious
	id = "unconscious"

//SLEEPING
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	alert_type = /obj/screen/alert/status_effect/asleep
	var/mob/living/carbon/carbon_owner
	var/mob/living/carbon/human/human_owner

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner, updating_canmove)
	..()
	if(update_canmove)
		owner.update_stat()
	if(iscarbon(owner)) //to avoid repeated istypes
		carbon_owner = owner
	if(ishuman(owner))
		human_owner = owner

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(owner.staminaloss)
		owner.adjustStaminaLoss(-0.35) //reduce stamina loss by 0.35 per tick, 7 per 2 seconds
	if(human_owner && human_owner.drunkenness)
		human_owner.drunkenness *= 0.997 //reduce drunkenness by 0.3% per tick, 6% per 2 seconds
	if(prob(20))
		if(carbon_owner)
			carbon_owner.handle_dreams()
		if(prob(10) && owner.health > HEALTH_THRESHOLD_CRIT)
			owner.emote("snore")

/datum/status_effect/incapacitating/sleeping/on_remove()
	..()
	if(update_canmove)
		owner.update_stat()

/obj/screen/alert/status_effect/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

//OTHER DEBUFFS
/datum/status_effect/his_wrath //does minor damage over time unless holding His Grace
	id = "his_wrath"
	duration = -1
	tick_interval = 4
	alert_type = /obj/screen/alert/status_effect/his_wrath

/obj/screen/alert/status_effect/his_wrath
	name = "His Wrath"
	desc = "You fled from His Grace instead of feeding Him, and now you suffer."
	icon_state = "his_grace"
	alerttooltipstyle = "hisgrace"

/datum/status_effect/his_wrath/tick()
	for(var/obj/item/weapon/his_grace/HG in owner.held_items)
		qdel(src)
		return
	owner.adjustBruteLoss(0.1)
	owner.adjustFireLoss(0.1)
	owner.adjustToxLoss(0.2, TRUE, TRUE)

/datum/status_effect/belligerent
	id = "belligerent"
	duration = 70
	tick_interval = 0 //tick as fast as possible
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /obj/screen/alert/status_effect/belligerent
	var/leg_damage_on_toggle = 2 //damage on initial application and when the owner tries to toggle to run
	var/cultist_damage_on_toggle = 10 //damage on initial application and when the owner tries to toggle to run, but to cultists

/obj/screen/alert/status_effect/belligerent
	name = "Belligerent"
	desc = "<b><font color=#880020>Kneel, her-eti'c.</font></b>"
	icon_state = "belligerent"
	alerttooltipstyle = "clockcult"

/datum/status_effect/belligerent/on_apply()
	return do_movement_toggle(TRUE)

/datum/status_effect/belligerent/tick()
	if(!do_movement_toggle())
		qdel(src)

/datum/status_effect/belligerent/proc/do_movement_toggle(force_damage)
	var/number_legs = owner.get_num_legs()
	if(iscarbon(owner) && !is_servant_of_ratvar(owner) && !owner.null_rod_check() && number_legs)
		if(force_damage || owner.m_intent != MOVE_INTENT_WALK)
			if(GLOB.ratvar_awakens)
				owner.Knockdown(20)
			if(iscultist(owner))
				owner.apply_damage(cultist_damage_on_toggle * 0.5, BURN, "l_leg")
				owner.apply_damage(cultist_damage_on_toggle * 0.5, BURN, "r_leg")
			else
				owner.apply_damage(leg_damage_on_toggle * 0.5, BURN, "l_leg")
				owner.apply_damage(leg_damage_on_toggle * 0.5, BURN, "r_leg")
		if(owner.m_intent != MOVE_INTENT_WALK)
			if(!iscultist(owner))
				to_chat(owner, "<span class='warning'>Your leg[number_legs > 1 ? "s shiver":" shivers"] with pain!</span>")
			else //Cultists take extra burn damage
				to_chat(owner, "<span class='warning'>Your leg[number_legs > 1 ? "s burn":" burns"] with pain!</span>")
			owner.toggle_move_intent()
		return TRUE
	return FALSE

/datum/status_effect/belligerent/on_remove()
	if(owner.m_intent == MOVE_INTENT_WALK)
		owner.toggle_move_intent()


/datum/status_effect/maniamotor
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
	var/static/list/powerloss_messages = list("\"Oh, the id**ts di***t s***e en**** pow**...\"", "\"D*dn't **ey mak* an **te***c*i*n le**?\"", "\"The** f**ls for**t t* make a ***** *f-\"", \
	"\"No, *O, you **re so cl***-\"", "You hear a yell of frustration, cut off by static.")

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
			if(motor.total_accessable_power() > motor.mania_cost)
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar(pick(turnoff_messages))]\"</span>")
			else
				to_chat(owner, "<span class='sevtug[span_part]'>[text2ratvar(pick(powerloss_messages))]</span>")
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
		if(owner.hallucination)
			owner.hallucination = 0
		if(owner.druggy)
			owner.adjust_drugginess(-owner.druggy)
		if(owner.dizziness)
			owner.dizziness = 0
		if(owner.confused)
			owner.confused = 0
		severity = 0
	else if(!owner.null_rod_check() && owner.stat != DEAD && severity)
		var/static/hum = get_sfx('sound/effects/screech.ogg') //same sound for every proc call
		if(owner.getToxLoss() > MANIA_DAMAGE_TO_CONVERT)
			if(is_eligible_servant(owner))
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar("You are mine and his, now.")]\"</span>")
				add_servant_of_ratvar(owner)
			owner.Unconscious(100)
		else
			if(prob(severity * 0.15))
				to_chat(owner, "<span class='sevtug[span_part]'>\"[text2ratvar(pick(mania_messages))]\"</span>")
			owner.playsound_local(get_turf(motor), hum, severity, 1)
			owner.adjust_drugginess(Clamp(max(severity * 0.075, 1), 0, max(0, 50 - owner.druggy))) //7.5% of severity per second, minimum 1
			if(owner.hallucination < 50)
				owner.hallucination = min(owner.hallucination + max(severity * 0.075, 1), 50) //7.5% of severity per second, minimum 1
			if(owner.dizziness < 50)
				owner.dizziness = min(owner.dizziness + round(severity * 0.05, 1), 50) //5% of severity per second above 10 severity
			if(owner.confused < 25)
				owner.confused = min(owner.confused + round(severity * 0.025, 1), 25) //2.5% of severity per second above 20 severity
			owner.adjustToxLoss(severity * 0.02, TRUE, TRUE) //2% of severity per second
		severity--

/datum/status_effect/cultghost //is a cult ghost and can't use manifest runes
	id = "cult_ghost"
	duration = -1
	alert_type = null

/datum/status_effect/crusher_mark
	id = "crusher_mark"
	duration = 300 //if you leave for 30 seconds you lose the mark, deal with it
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/mutable_appearance/marked_underlay
	var/obj/item/weapon/twohanded/required/mining_hammer/hammer_synced

/datum/status_effect/crusher_mark/on_apply()
	if(owner.mob_size >= MOB_SIZE_LARGE)
		marked_underlay = mutable_appearance('icons/effects/effects.dmi', "shield2")
		marked_underlay.pixel_x = -owner.pixel_x
		marked_underlay.pixel_y = -owner.pixel_y
		owner.underlays += marked_underlay
		return TRUE
	return FALSE

/datum/status_effect/crusher_mark/Destroy()
	hammer_synced = null
	if(owner)
		owner.underlays -= marked_underlay
	QDEL_NULL(marked_underlay)
	return ..()

/datum/status_effect/crusher_mark/be_replaced()
	owner.underlays -= marked_underlay //if this is being called, we should have an owner at this point.
	..()
