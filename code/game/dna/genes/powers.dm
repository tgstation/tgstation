///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("You feel no need to breathe.")
	mutation=mNobreath

	New()
		block=NOBREATHBLOCK

/datum/dna/gene/basic/remoteview
	name="Remote Viewing"
	activation_messages=list("Your mind expands.")
	mutation=mRemote

	New()
		block=REMOTEVIEWBLOCK

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.verbs += /mob/living/carbon/human/proc/remoteobserve

/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("You feel better.")
	mutation=mRegen

	New()
		block=REGENERATEBLOCK

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_messages=list("Your leg muscles pulsate.")
	mutation=mRun

	New()
		block=INCREASERUNBLOCK

/datum/dna/gene/basic/remotetalk
	name="Telepathy"
	activation_messages=list("You expand your mind outwards.")
	mutation=mRemotetalk

	New()
		block=REMOTETALKBLOCK

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.verbs += /mob/living/carbon/human/proc/remotesay

/datum/dna/gene/basic/morph
	name="Morph"
	activation_messages=list("Your skin feels strange.")
	mutation=mMorph

	New()
		block=MORPHBLOCK

	activate(var/mob/M)
		..(M)
		M.verbs += /mob/living/carbon/human/proc/morph

/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Your skin is icy to the touch.")
	mutation=mHeatres

	New()
		block=COLDBLOCK

	can_activate(var/mob/M,var/flags)
		// Probability check
		var/_prob = 15
		if(COLD_RESISTANCE in M.mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FORCED)))
			return 1

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Your body is filled with warmth.")
	mutation=COLD_RESISTANCE

	New()
		block=FIREBLOCK

	can_activate(var/mob/M,var/flags)

		// Probability check
		var/_prob=30
		if(mHeatres in M.mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FORCED)))
			return 1

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Your fingers feel numb.")
	mutation=mFingerprints

	New()
		block=NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Your skin feels strange.")
	mutation=mShock

	New()
		block=SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("Your skin feels rubbery.")
	mutation=mSmallsize

	New()
		block=SMALLSIZEBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big and small.
		if(HULK in M.mutations)
			return 0
		return ..(M,flags)

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.pass_flags |= 1

/datum/dna/gene/basic/hulk
	name="Hulk"
	activation_messages=list("Your muscles hurt.")
	mutation=HULK

	New()
		block=HULKBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big and small.
		if(mSmallsize in M.mutations)
			return 0
		return ..(M,flags)

/datum/dna/gene/basic/xray
	name="X-Ray Vision"
	activation_messages=list("The walls suddenly disappear.")
	mutation=XRAY

	New()
		block=XRAYBLOCK

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_messages=list("You feel smarter.")
	mutation=TK
	activation_prob=15

	New()
		block=TELEBLOCK