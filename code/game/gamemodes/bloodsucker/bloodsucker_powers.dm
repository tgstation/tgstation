
// NOTE: FOR ICONS! 	Looks up:   /datums/action.dm   and   _onclick/hud/action_buttons.dm
//				 		Also: carbon/life.dm has handle_changeling(), where the Changeling's displayed chem_charges are updated via its icon.

// 		Spells
// - Added in mob.dm AND mind.dm under AddSpell() (depending on if the spell follows the BODY or the MIND) as obj/effect/proc_holder/spell
// - Spells keep a /datum/action called "action" which attaches to its owner through Grant(), under action.dm

// NOTE : proc_holder lives in modules/spell.dm

// Am I able to use my powers? Do I have all the things needed?
/mob/living/proc/HaveBloodsuckerBodyparts(var/displaymessage="") // displaymessage can be something such as "rising from death" for Torpid Sleep. givewarningto is the person receiving messages.
	if (!getorganslot("heart"))
		if (displaymessage != "")
			to_chat(src, "<span class='warning'>Without a heart, you are incapable of [displaymessage].</span>")
		return 0
	if (!get_bodypart("head"))
		if (displaymessage != "")
			to_chat(src, "<span class='warning'>Without a head, you are incapable of [displaymessage].</span>")
		return 0
	if (!getorgan(/obj/item/organ/brain)) // NOTE: This is mostly just here so we can do one scan for all needed parts when creating a vamp. You probably won't be trying to use powers w/out a brain.
		if (displaymessage != "")
			to_chat(src, "<span class='warning'>Without a brain, you are incapable of [displaymessage].</span>")
		return 0
	return 1



// 			proc_holder VS. action
//
//	/obj/effect/proc_holder - An effect that takes place
//
//	/datum/action - handles the usage of the effect.
//
// NOTE: Check "spell_types" folder for MANY variations (conjure items, )




/obj/effect/proc_holder/spell/bloodsucker
	invocation = ""
	school = "vampiric"
	//action_icon = 'icons/obj/bloodpack.dmi'			// File containing icon
	action_icon = 'icons/Fulpstation/fulpicons.dmi'	// File containing icon
	action_icon_state = "frame"						// State for that image inside icon
	var/action_background_icon = 'icons/Fulpstation/fulpicons.dmi'	// File containing icon background.
	action_background_icon_state = "vamp_power_off"							// Background when OFF
	var/action_background_icon_state_active = "vamp_power_on"				// Background when ON
	charge_max = 0 // NOTE: Bloodsucker Powers do not use charges. Blood is the currency used.
	range = -1
	clothes_req = 0
	still_recharging_msg = "That power is not ready yet."
	//BS_background_state_enabled = "bg_alien"	// Background: Selected
	var/bloodcost = 0				// Cost to use this power.
	var/bloodcost_constant = 0		// Cost to keep this power on.
	var/amToggleable = FALSE						// When used, does this power flip its background ON and OFF to match its ACTIVE state?
	var/amTargetted = FALSE							// When used, does this power require you to click a target? Forces this to use InterceptClickOn().
	var/targetmessage_ON =  "<span class='notice'>The power of your blood flares forth!</span>"
	var/targetmessage_OFF = "<span class='notice'>Your power subsides...</span>"



	// REFERENCE: Base Variables
	//var/panel = "Debug"//What panel the proc holder needs to go on.
	//var/active = FALSE //Used by toggle based abilities.						<------------------- Important! For toggle powers!
	//var/ranged_mousepointer
	//var/mob/living/ranged_ability_user
	//var/ranged_clickcd_override = -1
	//var/has_action = TRUE
	//var/datum/action/spell_action/action = null
	//var/action_icon = 'icons/mob/actions/actions_spells.dmi'
	//var/action_icon_state = "spell_default"
	//var/action_background_icon_state = "bg_spell"

////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/bloodsucker/Initialize()
	. = ..()
	action.button_icon = action_background_icon // Set background to approptiate file.

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// PROCESS: Recharges Spell in spell.dm
/obj/effect/proc_holder/spell/bloodsucker/process()
	..() // DEFAULT: Handles recharge of power.

	// Can Maintain Spell? (constant blood cost)
	//if (active && usr && bloodcost_constant > 0)
	//	var/mob/living/carbon/C = usr
	//	if (C.blood_volume > 0)
	//		pay_blood_cost(C,bloodcost_constant) // Spend Blood to Leave On
	//	else
	//		cancel_spell(usr,"<span class='warning'>You have run out of the blood needed to sustain [src]!</span>")

	// Power RECHARGE
	update_icon(1) // process() fires every 2 seconds I think?

////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/bloodsucker/update_icon(only_recharge=FALSE)
	if(!action)
		return
	// Is this a soft update (for icon alpha)?
	if (!only_recharge)
		// Power ON / OFF
		action.background_icon_state = active ? action_background_icon_state_active : action_background_icon_state
		// Action/Button
		action.UpdateButtonIcon()
		// Description (Blood Cost)
		//if (bloodcost > 0)
		//	action.button.name += " \n<span class='warning'>\[Cost:</span> [bloodcost]\]"
		//if (bloodcost_constant > 0)
		//	action.button.desc += "<span class='warning'> (+</span>[bloodcost_constant]<span class='warning'>/sec)</span> "

	// Power RECHARGING
	//action.button.alpha = (charge_counter < charge_max && !active) ? 100 : 255 // Alpha partly invis when not recharged yet.  // MOVED: to action.dm
	// NOTE: only_recharge is only true when called from process() above, which is like the spell's TICK for recharging.

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CLICK ICON //	// USE THIS WHEN CLICKING ON THE ICON //
/obj/effect/proc_holder/spell/bloodsucker/Click()
	//to_chat(usr, "<span class='warning'>DEBUG: Click() [name]</span>")

	// Power Already On? Cancel.
	if (active)
		if (cancel_check())
			//message_admins("DEBUG1: Click() Casting [name], completed cancel_check()")
			SetActive(FALSE)
			//message_admins("DEBUG2: Click() Casting [name], completed SetActive(FALSE)")
			end_active_spell()
			//message_admins("DEBUG3: Click() Casting [name], completed end_active_spell()")
		return 0

	// Can We Cast?
	else attempt_cast()

	return 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// ATTEMPT ENTIRE CASTING OF SPELL //
/obj/effect/proc_holder/spell/bloodsucker/proc/attempt_cast(mob/living/user = usr) // This is done so that Frenzy can try to Feed (usr is EMPTY if called automatically)
	//to_chat(user, "<span class='warning'>DEBUG: AttemptCast() [name] by [user]</span>")

	//message_admins("DEBUG: attempt_cast() Casting [name]: usr = '[usr]'  //  user = '[user]'")

	if(cast_check(1, user))	// 1) Can we cast?
		//message_admins("DEBUG1: attempt_cast() Casting [name], completed cast_check()")
		SetActive(TRUE)		// 2) Set spell ACTIVE
		//message_admins("DEBUG2: attempt_cast() Casting [name], completed SetActive(TRUE)")
		choose_targets(user)// 3) Pick targets (which will then have affects applied) 		** NOTE: This does NOT fire for Targetted powers. Clicking is how you find targets.
		//message_admins("DEBUG3: attempt_cast() Casting [name], completed choose_targets()")
		return 1

	return 0
////////////////////////////////////////////////////////////////////////////////////////////////////////////

// SET TOGGLE ACTIVE //	// SETS POWER ON AND OFF, ADDS/REMOVES CLICK INTERCEPTION, AND CAN APPLY EFFECTS/CHECKS TO SEE IF YOU CAN TURN IT OFF
/obj/effect/proc_holder/spell/bloodsucker/proc/SetActive(setActive = 0)//, displayMessage = 1)
	//to_chat(user, "<span class='warning'>DEBUG: SetActive() [name]</span>")
	// WARNING: Do NOT call cancel_spell from here. Infinite loop! //

	// Set Toggleables Active
	if (amToggleable)
		// Just a regular toggle?
		if (!amTargetted)
			active = setActive
			update_icon()
		// Click-to-Target? Add/Remove InterceptClickOn() action
		else
			if (setActive)
				add_ranged_ability(usr, targetmessage_ON) // NOTE: These two things set active and update_icon(). //  NOTE: The FALSE is what forces your power, meaning you cannot use one til another is off.
			else
				remove_ranged_ability(targetmessage_OFF)

		// NOTE ON TOGGLEABLE SPELLS:
		// user add_ranged_ability  and   remove_ranged_ability  in spell.dm to toggle whether or not your next click will use InterceptClickOn

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CAST CHECK //	// USE THIS TO SEE IF WE CAN EVEN ACTIVATE THIS POWER //  Called from Click()
/obj/effect/proc_holder/spell/bloodsucker/cast_check(skipcharge = 0, mob/living/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	//to_chat(user, "<span class='warning'>DEBUG: cast_check() [name] / [charge_max] </span>")
	// Not Bloodsucker
	if (!user.mind)// || !user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		//to_chat(user, "<span class='warning'>You are not a Bloodsucker.</span>")
		return 0
	// Timer/Charges? - Replaces the built-in check in cast_check()
	if(charge_counter < charge_max)
		to_chat(user, still_recharging_msg + " <span class='notice'><span class='italics'>([(charge_max - charge_counter)/10] seconds)</span></span>")
		return 0
	// Recharge Time, Incapacitation // NO LONGER CHECKING RECHARGE TIME!
	if  (!..())
		return 0
	// Am in Frenzy!
	//var/datum/antagonist/bloodsucker/bloodsucker = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	if (user.IsFrenzied() && !user.castDuringFrenzy)// && usr == user) // This means, if I am in FRENZY and this power was called by someone CLICKING on me...(otherwise usr would be NULL if called from code)
		to_chat(user, "<span class='warning'>You're lost to Frenzy...you cannot activate powers!</span>")
		return 0
	// Have enough blood?
	if (user.blood_volume < bloodcost)
		to_chat(user, "You need at least [bloodcost] blood to activate [name]!</span>")
		return 0
	// DEFAULT VALID!
	return 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CANCEL CAST CHECK //	// USE THIS WHEN CLICKING ON AN ALREADY-ON ICON //
/obj/effect/proc_holder/spell/bloodsucker/proc/cancel_check(mob/living/user = usr) // Checks if a toggleable power can be cancelled.
	// We're not even on.
	if (!active)
		return 0
	if (user.IsFrenzied() && !user.castDuringFrenzy)
		to_chat(user, "<span class='warning'>You're lost to Frenzy...you cannot disable powers!</span>")
		return 0

	// Reset Cast Time for  Targetting Spells on Cancel
	if (amTargetted)
		revert_cast() // charge_counter = charge_max
		update_icon()

	return 1
	// NOTE: Used by Torpid Sleep to disable use if appropriate.

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// DECIDE TARGET //	// USE THIS TO SELECT TURF, PERSON, OR CONTAINER //  Called from attempt_cast()
/obj/effect/proc_holder/spell/bloodsucker/choose_targets(mob/living/user = usr)
	//to_chat(user, "<span class='warning'>DEBUG: choose_targets() [name] by [user]</span>")
	// Targetted Spell? Cancel out. InterceptClickOn() will do the targetting work
	if (amTargetted)
		return
	var/list/targets = list()
	// targets += ADD_TARGET_HERE
	// if (!can_target(ADD_TARGET_HERE)) // Do a LOOP through targets to see if they're valid
	//	return
	// CAST SPELL
	perform(targets, TRUE, user) // Runs: before_cast(), invocation() [say a line], playMagSound() [aka play the spell's sound], critfail(), cast() [seen BELOW], after_cast(), and updates the button icon.

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CLICK ON TARGET //	// USE THIS WHEN CLICKING ON A TARGET //  Called from action, when add_ranged_ability is on.
/obj/effect/proc_holder/spell/bloodsucker/InterceptClickOn(mob/living/caller, params, atom/A)
	//to_chat(user, "<span class='warning'>DEBUG: InterceptClickOn() [name]</span>")
	if (..())			// For SOME REASON, we return FALSE if ..() returns TRUE. Go figure.
		return 0
	if (!cast_check(1)) // One more Cast Check (this time with Charged disabled...countdown timer has already been affected to get here)
		SetActive(FALSE)
		revert_cast()
		return 1
	if (!can_target(A)) // Now let's see if we picked a valid target. If not, we need to tell the calling function we're not done with InterceptClickOn, and can keep trying targets.
		return 1
	var/list/targets = list()
	targets += A
	// CAST SPELL
	perform(targets, TRUE, caller) // Runs: before_cast(), invocation() [say a line], playMagSound() [aka play the spell's sound], critfail(), cast() [seen BELOW], after_cast(), and updates the button icon.
	return 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// TARGET VALID? //	// USE THIS TO DETERMINE IF TARGET IS VALID //
/obj/effect/proc_holder/spell/bloodsucker/can_target(atom/A)//mob/living/target)
	//to_chat(user, "<span class='warning'>DEBUG: can_target() [name]</span>")
	return TRUE

////////////////////////////////////////////////////////////////////////////////////////////////////////////

	// REMOVED: We don't spend blood when you CAST the spell, we spend it when it's done! //
// APPLY EFFECT //	// USE THIS FOR THE SPELL EFFECT //
/obj/effect/proc_holder/spell/bloodsucker/cast(list/targets, mob/living/user = usr) 		// NOTE: Called from perform() in /proc_holder/spell
	//to_chat(user, "<span class='warning'>DEBUG1: cast() [name] by [user]</span>")

	..() // Does Nothing.

	// Cast Time
	charge_counter = 0 // DONE HERE since spell was actually SUCCESSFUL (not done in cast_check() like an IDIOT)
	start_recharge()
	update_icon()

////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/bloodsucker/proc/pay_blood_cost(mob/living/user = usr, cost = bloodcost)
	if (cost <= 0 || !user)
		return
	// Spend Blood
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	bloodsuckerdatum.set_blood_volume(-cost)
	//message_admins("DEBUG: pay_blood_cost() for [name], cost was [cost]")

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// ABORT SPELL //	// USE THIS WHEN FAILING MID-SPELL. NOT THE SAME AS DISABLING BY CLICKING BUTTON //
/obj/effect/proc_holder/spell/bloodsucker/proc/cancel_spell(mob/living/user = usr, dispmessage="")
	//to_chat(user, "<span class='warning'>DEBUG: cancel_spell() [name]</span>")
	// Disable Icon
	SetActive(FALSE)

	end_active_spell(user,dispmessage)

	// USE THIS FOR: Disabling a power and also firing off its end_active_spell() effects.

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// END SPELL //	// WHEN A SPELL COMES TO AN END, NO MATTER HOW IT HAPPENED.
/obj/effect/proc_holder/spell/bloodsucker/proc/end_active_spell(mob/living/user = usr, dispmessage="")
	//to_chat(user, "<span class='warning'>DEBUG: cancel_spell() [name]</span>")

	// Called from cancel_spell()...   and Click() (after SetActive(FALSE) is called)

	// Cast Time
	charge_counter = 0 // DONE HERE since successful toggle spell has just ended (not done in cast_check() like an IDIOT)
	start_recharge()
	update_icon()

	if (dispmessage != "")
		to_chat(user, dispmessage)

	// USE THIS FOR: Restoring stats and returning character to normal.


////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CONTINUE CHECK //	// USE THIS WITH do_mob() TO KEEP SPELL ACTIVE
/obj/effect/proc_holder/spell/bloodsucker/proc/continue_valid(mob/living/user = usr)
	//to_chat(user, "<span class='warning'>DEBUG: continue_valid() [name]</span>")
	//charge_counter = 0 // Reset timer continuously.
	return 1

////////////////////////////////////////////////////////////////////////////////////////////////////////////

// CAST EFFECT //	// General effect (poof, splat, etc) when you cast. Doesn't happen automatically!
/obj/effect/proc_holder/spell/bloodsucker/proc/cast_effect(mob/living/user = usr)
	return

////////////////////////////////////////////////////////////////////////////////////////////////////////////


































/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
/obj/effect/proc_holder/spell/bloodsucker/humandisguise
	name = "Mortal Disguise"
	desc = "Compel your corpselike physiology to imitate a human's. Low blood will make you faint, your wounds will stop healing automatically, your body temperature will return to normal, and you can stomach human food."
	invocation = ""
	school = "vampiric"
	amToggleable = TRUE
	//include_user = 1
	stat_allowed = UNCONSCIOUS
	charge_max = 50
	action_icon_state = "power_human"				// State for that image inside icon
	targetmessage_ON =  "<span class='notice'>Your pulse starts again. You feel...almost human.</span>"
	targetmessage_OFF = "<span class='notice'>You shrug off the disguise of frail human weakness. You are powerful once more.</span>"


// SET TOGGLE ACTIVE
/obj/effect/proc_holder/spell/bloodsucker/humandisguise/SetActive(setActive = 0)
	..() // DEFAULT
	// WARNING: Do NOT call cancel_spell from here. Infinite loop! //

		// Set Values
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = usr.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	bloodsuckerdatum.poweron_humandisguise = active

	// Display Message Line
	to_chat(usr, "<span class='notice'>[active ? targetmessage_ON : targetmessage_OFF]</span>")
*/




