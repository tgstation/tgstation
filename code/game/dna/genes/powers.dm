///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("You feel no need to breathe.")
	deactivation_messages=list("The need to breathe returns.")
	mutation=M_NO_BREATH

	New()
		block=NOBREATHBLOCK

/datum/dna/gene/basic/grant_spell/remoteview
	name="Remote Viewing"
	activation_messages=list("Your mind expands.")
	deactivation_messages=list("Your mind is no longer expanded.")
	mutation=M_REMOTE_VIEW

	spelltype = /spell/targeted/remoteobserve

	New()
		block=REMOTEVIEWBLOCK

/spell/targeted/remoteobserve
	name = "Remote View"
	panel = "Mutant Powers"

	charge_type = Sp_RECHARGE
	charge_max = 50

	invocation_type = SpI_NONE
	range = -2
	max_targets = 1
	spell_flags = SELECTABLE | INCLUDEUSER

	override_base = "genetic"
	hud_state = "gen_rmind"

/spell/targeted/remoteobserve/cast(var/list/targets, mob/living/carbon/human/user)
	if(!targets || !targets.len || !user || !istype(user))
		return

	if(user.stat!=CONSCIOUS)
		user.remoteview_target = null
		user.reset_view(0)
		return

	if(istype(user.l_hand, /obj/item/tk_grab) || istype(user.r_hand, /obj/item/tk_grab/))
		user << "<span class='warning'>Your mind is too busy with that telekinetic grab.</span>"
		user.remoteview_target = null
		user.reset_view(0)
		return

	if(user.client.eye != user.client.mob)
		user.remoteview_target = null
		user.reset_view(0)
		return

	for(var/mob/living/target in targets)
		if (target)
			if(target == user)
				user.remoteview_target = null
				user.reset_view(0)
			else
				user.remoteview_target = target
				user.reset_view(target)
			break

/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("You feel better.")
	deactivation_messages=list("You stop feeling better.")
	mutation=M_REGEN

	New()
		block=REGENERATEBLOCK

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_messages=list("Your leg muscles pulsate.")
	deactivation_messages=list("Your leg muscles no longer pulsate.")
	mutation=M_RUN

	New()
		block=INCREASERUNBLOCK

/datum/dna/gene/basic/grant_spell/remotetalk
	name="Telepathy"
	activation_messages=list("You feel your voice can penetrate other minds.")
	deactivation_messages=list("Your mind can no longer project your voice onto others.")
	mutation=M_REMOTE_TALK

	spelltype = /spell/targeted/remotesay

	New()
		..()
		block=REMOTETALKBLOCK

/spell/targeted/remotesay
	name = "Project Mind"
	desc = "Speak into the minds of others."
	panel = "Mutant Powers"

	charge_type = Sp_RECHARGE
	charge_max = 50

	invocation_type = SpI_NONE
	range = -2 //the world
	max_targets = 1
	selection_type = "view"
	spell_flags = SELECTABLE

	override_base = "genetic"
	hud_state = "gen_project"

	compatible_mobs = list(/mob/living/carbon/human)

/spell/targeted/remotesay/choose_targets(var/mob/living/carbon/human/user)
	if(!istype(user))
		return list()

	var/list/targets = ..()
	for(var/mob/living/carbon/human/M in targets)
		if(!user.can_mind_interact(M))
			targets -= M

	return targets

/spell/targeted/remotesay/cast(var/list/targets, mob/living/carbon/human/user)
	if(!targets || !targets.len || !user || !istype(user))
		return

	var/say = stripped_input(user, "What do you wish to say?", "Project Mind")
	if(!say)
		return

	for(var/mob/living/carbon/human/target in targets)
		if(M_REMOTE_TALK in target.mutations)
			target.show_message("<span class='notice'>You hear [user.real_name]'s voice: [say]</span>")
		else
			target.show_message("<span class='notice'>You hear a voice that seems to echo around the room: [say]</span>")
		user.show_message("<span class='notice'>You project your mind into [target.real_name]: [say]</span>")
		for(var/mob/dead/observer/G in dead_mob_list)
			G.show_message("<i>Telepathic message from <b>[user]</b> to <b>[target]</b>: [say]</i>")

/datum/dna/gene/basic/morph
	name="Morph"
	activation_messages=list("Your skin feels strange.")
	deactivation_messages=list("Your skin no longer feels strange.")
	mutation=M_MORPH

	New()
		block=MORPHBLOCK

	activate(var/mob/M)
		..(M)
		M.verbs += /mob/living/carbon/human/proc/morph

/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Your skin is icy to the touch.")
	deactivation_messages=list("Your skin stops feeling icy.")
	mutation=M_RESIST_HEAT

	New()
		block=COLDBLOCK

	can_activate(var/mob/M,var/flags)
		if(flags & MUTCHK_FORCED)
			return !(/datum/dna/gene/basic/cold_resist in M.active_genes)
		// Probability check
		var/_prob = 15
		if(M_RESIST_COLD in M.mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FORCED)))
			return 1

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "cold[fat]_s"

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Your body is filled with warmth.")
	deactivation_messages=list("Your body is no longer filled with warmth.")
	mutation=M_RESIST_COLD

	New()
		block=FIREBLOCK

	can_activate(var/mob/M,var/flags)
		if(flags & MUTCHK_FORCED)
			return !(/datum/dna/gene/basic/heat_resist in M.active_genes)
		// Probability check
		var/_prob=30
		if(M_RESIST_HEAT in M.mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FORCED)))
			return 1

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Your fingers feel numb.")
	deactivation_messages=list("Your fingers stop feeling numb.")
	mutation=M_FINGERPRINTS

	New()
		block=NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Your skin feels electric.")
	deactivation_messages=list("Your skin no longer feels electric.")
	mutation=M_NO_SHOCK

	New()
		block=SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("You feel small.")
	deactivation_messages=list("You stop feeling small.")
	mutation=M_DWARF

	New()
		block=SMALLSIZEBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big and small.
		if(M_HULK in M.mutations)
			return 0
		return ..(M,flags)

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.pass_flags |= 1

/* OLD HULK BEHAVIOR
/datum/dna/gene/basic/hulk
	name="Hulk"
	activation_messages=list("Your muscles hurt.")
	mutation=M_HULK

	New()
		block=HULKBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big AND small.
		if(M_DWARF in M.mutations)
			return 0
		return ..(M,flags)

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		if(M_HULK in M.mutations)
			if(fat)
				return "hulk_[fat]_s"
			else
				return "hulk_[g]_s"
		return 0

	OnMobLife(var/mob/living/carbon/human/M)
		if(!istype(M)) return
		if(M.health <= 25 && M_HULK in M.mutations)
			M.mutations.Remove(M_HULK)
			M.dna.SetSEState(HULKBLOCK,0)
			M.update_mutations()		//update our mutation overlays
			M.update_body()
			M << "\red You suddenly feel very weak."
			M.Weaken(3)
			M.emote("collapse")
*/
/datum/dna/gene/basic/xray
	name="X-Ray Vision"
	activation_messages=list("The walls suddenly disappear.")
	deactivation_messages=list("The walls suddenly appear.")
	mutation=M_XRAY

	New()
		block=XRAYBLOCK

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_messages=list("You feel smarter.")
	deactivation_messages=list("You feel less smart.")
	mutation=M_TK
	activation_prob=15

	New()
		block=TELEBLOCK

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "telekinesishead[fat]_s"