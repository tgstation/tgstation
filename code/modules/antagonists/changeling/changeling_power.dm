/*
 * Don't use the apostrophe in name or desc. Causes script errors.//probably no longer true
 */

/datum/action/changeling
	name = "Prototype Sting - Debug button, ahelp this"
	background_icon_state = "bg_changeling"
	overlay_icon_state = "bg_changeling_border"
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	/// Details displayed in fine print within the changling emporium
	var/helptext = ""
	/// How many changeling chems it costs to use
	var/chemical_cost = 0
	/**
	 * Cost of the ability in dna points, negative values are not valid
	 *
	 * Special numbers include [CHANGELING_POWER_INNATE], which are given to changeling for free without bring prompted
	 * and [CHANGELING_POWER_UNOBTAINABLE], which are not available for purchase in the changeling emporium
	 */
	var/dna_cost = CHANGELING_POWER_UNOBTAINABLE
	/// Amount of dna needed to use this ability. Note, changelings always have atleast 1
	var/req_dna = 0
	/// If you need to be humanoid to use this ability (disincludes monkeys)
	var/req_human = FALSE
	/// Similar to req_dna, but only gained from absorbing, not DNA sting
	var/req_absorbs = 0
	/// Maximum stat before the ability is blocked.
	/// For example, `UNCONSCIOUS` prevents it from being used when in hard crit or dead,
	/// while `DEAD` allows the ability to be used on any stat values.
	var/req_stat = CONSCIOUS
	/// usable when the changeling is in death coma
	var/ignores_fakedeath = FALSE
	/// used by a few powers that toggle
	var/active = FALSE
	/// Does this ability stop working if you are burning?
	var/disabled_by_fire = TRUE

/*
changeling code now relies on on_purchase to grant powers.
if you override it, MAKE SURE you call parent or it will not be usable
the same goes for Remove(). if you override Remove(), call parent or else your power won't be removed on respec
*/

/datum/action/changeling/proc/on_purchase(mob/user, is_respec)
	Grant(user)//how powers are added rather than the checks in mob.dm

/datum/action/changeling/Trigger(trigger_flags)
	var/mob/user = owner
	if(!user || !IS_CHANGELING(user))
		return
	try_to_sting(user)

/**
 *Contrary to the name, this proc isn't just used by changeling stings. It handles the activation of the action and the deducation of its cost.
 *The order of the proc chain is:
 *can_sting(). Should this fail, the process gets aborted early.
 *sting_action(). This proc usually handles the actual effect of the action.
 *Should sting_action succeed the following will be done:
 *sting_feedback(). Produces feedback on the performed action. Don't ask me why this isn't handled in sting_action()
 *The deduction of the cost of this power.
 *Returns TRUE on a successful activation.
 */
/datum/action/changeling/proc/try_to_sting(mob/living/user, mob/living/target)
	if(!can_sting(user, target))
		return FALSE
	if(disabled_by_fire && user.fire_stacks && user.on_fire)
		user.balloon_alert(user, "on fire!")
		return FALSE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(sting_action(user, target))
		sting_feedback(user, target)
		changeling.adjust_chemicals(-chemical_cost)
		user.changeNext_move(CLICK_CD_MELEE)
		return TRUE
	return FALSE

/datum/action/changeling/proc/sting_action(mob/living/user, mob/living/target)
	SHOULD_CALL_PARENT(TRUE)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return FALSE

/datum/action/changeling/proc/sting_feedback(mob/living/user, mob/living/target)
	return FALSE

// Fairly important to remember to return 1 on success >.< // Return TRUE not 1 >.<
/datum/action/changeling/proc/can_sting(mob/living/user, mob/living/target)
	if(!can_be_used_by(user))
		return FALSE
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(user)
	if(changeling.chem_charges < chemical_cost)
		user.balloon_alert(user, "needs [chemical_cost] chemicals!")
		return FALSE
	if(changeling.absorbed_count < req_dna)
		user.balloon_alert(user, "needs [req_dna] dna sample\s!")
		return FALSE
	if(changeling.true_absorbs < req_absorbs)
		user.balloon_alert(user, "needs [req_absorbs] absorption\s!")
		return FALSE
	if(req_stat < user.stat)
		user.balloon_alert(user, "incapacitated!")
		return FALSE
	if(HAS_TRAIT(user, TRAIT_DEATHCOMA) && !ignores_fakedeath)
		user.balloon_alert(user, "playing dead!")
		return FALSE
	return TRUE

/datum/action/changeling/proc/can_be_used_by(mob/living/user)
	if(QDELETED(user))
		return FALSE
	if(!ishuman(user))
		return FALSE
	if(req_human && ismonkey(user))
		user.balloon_alert(user, "become human!")
		return FALSE
	return TRUE
