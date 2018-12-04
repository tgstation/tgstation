//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS
/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/needs_update_stat = FALSE

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration, updating_canmove)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(.)
		if(updating_canmove)
			owner.update_mobility()
			if(needs_update_stat || issilicon(owner))
				owner.update_stat()

/datum/status_effect/incapacitating/on_remove()
	owner.update_mobility()
	if(needs_update_stat || issilicon(owner)) //silicons need stat updates in addition to normal canmove updates
		owner.update_stat()

//STUN
/datum/status_effect/incapacitating/stun
	id = "stun"

//KNOCKDOWN
/datum/status_effect/incapacitating/knockdown
	id = "knockdown"

//IMMOBILIZED
/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"

//UNCONSCIOUS
/datum/status_effect/incapacitating/unconscious
	id = "unconscious"
	needs_update_stat = TRUE

/datum/status_effect/incapacitating/unconscious/tick()
	if(owner.getStaminaLoss())
		owner.adjustStaminaLoss(-0.3) //reduce stamina loss by 0.3 per tick, 6 per 2 seconds

//SLEEPING
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	alert_type = /obj/screen/alert/status_effect/asleep
	needs_update_stat = TRUE
	var/mob/living/carbon/carbon_owner
	var/mob/living/carbon/human/human_owner

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner, updating_canmove)
	. = ..()
	if(.)
		if(iscarbon(owner)) //to avoid repeated istypes
			carbon_owner = owner
		if(ishuman(owner))
			human_owner = owner

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(owner.getStaminaLoss())
		owner.adjustStaminaLoss(-0.5) //reduce stamina loss by 0.5 per tick, 10 per 2 seconds
	if(human_owner && human_owner.drunkenness)
		human_owner.drunkenness *= 0.997 //reduce drunkenness by 0.3% per tick, 6% per 2 seconds
	if(prob(20))
		if(carbon_owner)
			carbon_owner.handle_dreams()
		if(prob(10) && owner.health > owner.crit_threshold)
			owner.emote("snore")

/obj/screen/alert/status_effect/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

//OTHER DEBUFFS
/datum/status_effect/pacify
	id = "pacify"
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 1
	duration = 100
	
/datum/status_effect/pacify/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()	

/datum/status_effect/pacify/on_apply()
	owner.add_trait(TRAIT_PACIFISM, "status_effect")
	return ..()

/datum/status_effect/pacify/on_remove()
	owner.remove_trait(TRAIT_PACIFISM, "status_effect")

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
	for(var/obj/item/his_grace/HG in owner.held_items)
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
	var/number_legs = owner.get_num_legs(FALSE)
	if(iscarbon(owner) && !is_servant_of_ratvar(owner) && !owner.anti_magic_check() && number_legs)
		if(force_damage || owner.m_intent != MOVE_INTENT_WALK)
			if(GLOB.ratvar_awakens)
				owner.Paralyze(20)
			if(iscultist(owner))
				owner.apply_damage(cultist_damage_on_toggle * 0.5, BURN, BODY_ZONE_L_LEG)
				owner.apply_damage(cultist_damage_on_toggle * 0.5, BURN, BODY_ZONE_R_LEG)
			else
				owner.apply_damage(leg_damage_on_toggle * 0.5, BURN, BODY_ZONE_L_LEG)
				owner.apply_damage(leg_damage_on_toggle * 0.5, BURN, BODY_ZONE_R_LEG)
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
		if(owner.hallucination)
			owner.hallucination = 0
		if(owner.druggy)
			owner.adjust_drugginess(-owner.druggy)
		if(owner.dizziness)
			owner.dizziness = 0
		if(owner.confused)
			owner.confused = 0
		severity = 0
	else if(!owner.anti_magic_check() && owner.stat != DEAD && severity)
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
			owner.adjust_drugginess(CLAMP(max(severity * 0.075, 1), 0, max(0, 50 - owner.druggy))) //7.5% of severity per second, minimum 1
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

/datum/status_effect/cultghost/on_apply()
	owner.see_invisible = SEE_INVISIBLE_OBSERVER
	owner.see_in_dark = 2

/datum/status_effect/cultghost/tick()
	if(owner.reagents)
		owner.reagents.del_reagent("holywater") //can't be deconverted

/datum/status_effect/crusher_mark
	id = "crusher_mark"
	duration = 300 //if you leave for 30 seconds you lose the mark, deal with it
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	var/mutable_appearance/marked_underlay
	var/obj/item/twohanded/required/kinetic_crusher/hammer_synced

/datum/status_effect/crusher_mark/on_creation(mob/living/new_owner, obj/item/twohanded/required/kinetic_crusher/new_hammer_synced)
	. = ..()
	if(.)
		hammer_synced = new_hammer_synced

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

/datum/status_effect/saw_bleed
	id = "saw_bleed"
	duration = -1 //removed under specific conditions
	tick_interval = 6
	alert_type = null
	var/mutable_appearance/bleed_overlay
	var/mutable_appearance/bleed_underlay
	var/bleed_amount = 3
	var/bleed_buildup = 3
	var/delay_before_decay = 5
	var/bleed_damage = 200
	var/needs_to_bleed = FALSE

/datum/status_effect/saw_bleed/Destroy()
	if(owner)
		owner.cut_overlay(bleed_overlay)
		owner.underlays -= bleed_underlay
	QDEL_NULL(bleed_overlay)
	return ..()

/datum/status_effect/saw_bleed/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	bleed_overlay = mutable_appearance('icons/effects/bleed.dmi', "bleed[bleed_amount]")
	bleed_underlay = mutable_appearance('icons/effects/bleed.dmi', "bleed[bleed_amount]")
	var/icon/I = icon(owner.icon, owner.icon_state, owner.dir)
	var/icon_height = I.Height()
	bleed_overlay.pixel_x = -owner.pixel_x
	bleed_overlay.pixel_y = FLOOR(icon_height * 0.25, 1)
	bleed_overlay.transform = matrix() * (icon_height/world.icon_size) //scale the bleed overlay's size based on the target's icon size
	bleed_underlay.pixel_x = -owner.pixel_x
	bleed_underlay.transform = matrix() * (icon_height/world.icon_size) * 3
	bleed_underlay.alpha = 40
	owner.add_overlay(bleed_overlay)
	owner.underlays += bleed_underlay
	return ..()

/datum/status_effect/saw_bleed/tick()
	if(owner.stat == DEAD)
		qdel(src)
	else
		add_bleed(-1)

/datum/status_effect/saw_bleed/proc/add_bleed(amount)
	owner.cut_overlay(bleed_overlay)
	owner.underlays -= bleed_underlay
	bleed_amount += amount
	if(bleed_amount)
		if(bleed_amount >= 10)
			needs_to_bleed = TRUE
			qdel(src)
		else
			if(amount > 0)
				tick_interval += delay_before_decay
			bleed_overlay.icon_state = "bleed[bleed_amount]"
			bleed_underlay.icon_state = "bleed[bleed_amount]"
			owner.add_overlay(bleed_overlay)
			owner.underlays += bleed_underlay
	else
		qdel(src)

/datum/status_effect/saw_bleed/on_remove()
	if(needs_to_bleed)
		var/turf/T = get_turf(owner)
		new /obj/effect/temp_visual/bleed/explode(T)
		for(var/d in GLOB.alldirs)
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(T, d)
		playsound(T, "desceration", 200, 1, -1)
		owner.adjustBruteLoss(bleed_damage)
	else
		new /obj/effect/temp_visual/bleed(get_turf(owner))

/mob/living/proc/apply_necropolis_curse(set_curse)
	var/datum/status_effect/necropolis_curse/C = has_status_effect(STATUS_EFFECT_NECROPOLIS_CURSE)
	if(!set_curse)
		set_curse = pick(CURSE_BLINDING, CURSE_SPAWNING, CURSE_WASTING, CURSE_GRASPING)
	if(QDELETED(C))
		apply_status_effect(STATUS_EFFECT_NECROPOLIS_CURSE, set_curse)
	else
		C.apply_curse(set_curse)
		C.duration += 3000 //additional curses add 5 minutes

/datum/status_effect/necropolis_curse
	id = "necrocurse"
	duration = 6000 //you're cursed for 10 minutes have fun
	tick_interval = 50
	alert_type = null
	var/curse_flags = NONE
	var/effect_last_activation = 0
	var/effect_cooldown = 100
	var/obj/effect/temp_visual/curse/wasting_effect = new

/datum/status_effect/necropolis_curse/on_creation(mob/living/new_owner, set_curse)
	. = ..()
	if(.)
		apply_curse(set_curse)

/datum/status_effect/necropolis_curse/Destroy()
	if(!QDELETED(wasting_effect))
		qdel(wasting_effect)
		wasting_effect = null
	return ..()

/datum/status_effect/necropolis_curse/on_remove()
	remove_curse(curse_flags)

/datum/status_effect/necropolis_curse/proc/apply_curse(set_curse)
	curse_flags |= set_curse
	if(curse_flags & CURSE_BLINDING)
		owner.overlay_fullscreen("curse", /obj/screen/fullscreen/curse, 1)

/datum/status_effect/necropolis_curse/proc/remove_curse(remove_curse)
	if(remove_curse & CURSE_BLINDING)
		owner.clear_fullscreen("curse", 50)
	curse_flags &= ~remove_curse

/datum/status_effect/necropolis_curse/tick()
	if(owner.stat == DEAD)
		return
	if(curse_flags & CURSE_WASTING)
		wasting_effect.forceMove(owner.loc)
		wasting_effect.setDir(owner.dir)
		wasting_effect.transform = owner.transform //if the owner has been stunned the overlay should inherit that position
		wasting_effect.alpha = 255
		animate(wasting_effect, alpha = 0, time = 32)
		playsound(owner, 'sound/effects/curse5.ogg', 20, 1, -1)
		owner.adjustFireLoss(0.75)
	if(effect_last_activation <= world.time)
		effect_last_activation = world.time + effect_cooldown
		if(curse_flags & CURSE_SPAWNING)
			var/turf/spawn_turf
			var/sanity = 10
			while(!spawn_turf && sanity)
				spawn_turf = locate(owner.x + pick(rand(10, 15), rand(-10, -15)), owner.y + pick(rand(10, 15), rand(-10, -15)), owner.z)
				sanity--
			if(spawn_turf)
				var/mob/living/simple_animal/hostile/asteroid/curseblob/C = new (spawn_turf)
				C.set_target = owner
				C.GiveTarget()
		if(curse_flags & CURSE_GRASPING)
			var/grab_dir = turn(owner.dir, pick(-90, 90, 180, 180)) //grab them from a random direction other than the one faced, favoring grabbing from behind
			var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 5)
			if(spawn_turf)
				grasp(spawn_turf)

/datum/status_effect/necropolis_curse/proc/grasp(turf/spawn_turf)
	set waitfor = FALSE
	new/obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse2.ogg', 80, 1, -1)
	var/turf/ownerloc = get_turf(owner)
	var/obj/item/projectile/curse_hand/C = new (spawn_turf)
	C.preparePixelProjectile(ownerloc, spawn_turf)
	C.fire()

/obj/effect/temp_visual/curse
	icon_state = "curse"

/obj/effect/temp_visual/curse/Initialize()
	. = ..()
	deltimer(timerid)


//Kindle: Used by servants of Ratvar. 10-second knockdown, reduced by 1 second per 5 damage taken while the effect is active.
/datum/status_effect/kindle
	id = "kindle"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 5
	duration = 100
	alert_type = /obj/screen/alert/status_effect/kindle
	var/old_health

/datum/status_effect/kindle/tick()
	owner.Paralyze(15)
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		C.silent = max(2, C.silent)
		C.stuttering = max(5, C.stuttering)
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

/obj/screen/alert/status_effect/kindle
	name = "Dazzling Lights"
	desc = "Blinding light dances in your vision, stunning and silencing you. <i>Any damage taken will shorten the light's effects!</i>"
	icon_state = "kindle"
	alerttooltipstyle = "clockcult"


//Ichorial Stain: Applied to servants revived by a vitality matrix. Prevents them from being revived by one again until the effect fades.
/datum/status_effect/ichorial_stain
	id = "ichorial_stain"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 600
	examine_text = "<span class='warning'>SUBJECTPRONOUN is drenched in thick, blue ichor!</span>"
	alert_type = /obj/screen/alert/status_effect/ichorial_stain

/datum/status_effect/ichorial_stain/on_apply()
	owner.visible_message("<span class='danger'>[owner] gets back up, [owner.p_their()] body dripping blue ichor!</span>", \
	"<span class='userdanger'>Thick blue ichor covers your body; you can't be revived like this again until it dries!</span>")
	return TRUE

/datum/status_effect/ichorial_stain/on_remove()
	owner.visible_message("<span class='danger'>The blue ichor on [owner]'s body dries out!</span>", \
	"<span class='boldnotice'>The ichor on your body is dry - you can now be revived by vitality matrices again!</span>")

/obj/screen/alert/status_effect/ichorial_stain
	name = "Ichorial Stain"
	desc = "Your body is covered in blue ichor! You can't be revived by vitality matrices."
	icon_state = "ichorial_stain"
	alerttooltipstyle = "clockcult"

/datum/status_effect/gonbolaPacify
	id = "gonbolaPacify"
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = -1
	alert_type = null

/datum/status_effect/gonbolaPacify/on_apply()
	owner.add_trait(TRAIT_PACIFISM, "gonbolaPacify")
	owner.add_trait(TRAIT_MUTE, "gonbolaMute")
	owner.add_trait(TRAIT_JOLLY, "gonbolaJolly")
	to_chat(owner, "<span class='notice'>You suddenly feel at peace and feel no need to make any sudden or rash actions...</span>")
	return ..()

/datum/status_effect/gonbolaPacify/on_remove()
	owner.remove_trait(TRAIT_PACIFISM, "gonbolaPacify")
	owner.remove_trait(TRAIT_MUTE, "gonbolaMute")
	owner.remove_trait(TRAIT_JOLLY, "gonbolaJolly")

/datum/status_effect/trance
	id = "trance"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 300
	tick_interval = 10
	examine_text = "<span class='warning'>SUBJECTPRONOUN seems slow and unfocused.</span>"
	var/stun = TRUE

/datum/status_effect/trance/tick()
	if(stun)
		owner.Stun(60, TRUE, TRUE)
	owner.dizziness = 20

/datum/status_effect/trance/on_apply()
	if(!iscarbon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_HEAR, .proc/hypnotize)
	owner.add_trait(TRAIT_MUTE, "trance")
	if(!owner.has_quirk(/datum/quirk/monochromatic))
		owner.add_client_colour(/datum/client_colour/monochrome)
	owner.visible_message("[stun ? "<span class='warning'>[owner] stands still as [owner.p_their()] eyes seem to focus on a distant point.</span>" : ""]", \
	"<span class='warning'>[pick("You feel your thoughts slow down...", "You suddenly feel extremely dizzy...", "You feel like you're in the middle of a dream...","You feel incredibly relaxed...")]</span>")
	return TRUE

/datum/status_effect/trance/on_creation(mob/living/new_owner, _duration, _stun = TRUE)
	duration = _duration
	stun = _stun
	return ..()

/datum/status_effect/trance/on_remove()
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)
	owner.remove_trait(TRAIT_MUTE, "trance")
	owner.dizziness = 0
	if(!owner.has_quirk(/datum/quirk/monochromatic))
		owner.remove_client_colour(/datum/client_colour/monochrome)
	to_chat(owner, "<span class='warning'>You snap out of your trance!</span>")

/datum/status_effect/trance/proc/hypnotize(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(!owner.can_hear())
		return
	if(speaker == owner)
		return
	var/mob/living/carbon/C = owner
	C.cure_trauma_type(/datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY) //clear previous hypnosis
	addtimer(CALLBACK(C, /mob/living/carbon.proc/gain_trauma, /datum/brain_trauma/hypnosis, TRAUMA_RESILIENCE_SURGERY, raw_message), 10)
	addtimer(CALLBACK(C, /mob/living.proc/Stun, 60, TRUE, TRUE), 15) //Take some time to think about it
	qdel(src)
