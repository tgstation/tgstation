
/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_message="You feel no need to breathe."
	mutation=mNobreath

	initialize()
		block=NOBREATHBLOCK

/datum/dna/gene/basic/remoteview
	name="Remote Viewing"
	activation_message="Your mind expands."
	mutation=mRemote

	initialize()
		block=REMOTEVIEWBLOCK

	activate(var/mob/M)
		..(M)
		M.verbs += /mob/living/carbon/human/proc/remoteobserve

/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_message="You feel better."
	mutation=mRegen

	initialize()
		block=REGENERATEBLOCK

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_message="Your leg muscles pulsate."
	mutation=mRun

	initialize()
		block=INCREASERUNBLOCK

/datum/dna/gene/basic/remotetalk
	name="Telepathy"
	activation_message="You expand your mind outwards."
	mutation=mRemotetalk

	initialize()
		block=REMOTETALKBLOCK

	activate(var/mob/M)
		..(M)
		M.verbs += /mob/living/carbon/human/proc/remotesay

/datum/dna/gene/basic/morph
	name="Morph"
	activation_message="Your skin feels strange."
	mutation=mMorph

	initialize()
		block=REMOTETALKBLOCK

	activate(var/mob/M)
		..(M)
		M.verbs += /mob/living/carbon/human/proc/morph

/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_message="Your skin is icy to the touch."
	mutation=mHeatres

	initialize()
		block=COLDBLOCK

	can_activate(var/mob/M,var/list/old_mutations,var/flags)
		// Mutation already set?
		if(mutation in old_mutations)
			return 1

		// Probability check
		var/_prob = 15
		if(COLD_RESISTANCE in old_mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FROM_INJECTOR)))
			return 1

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_message="Your body is filled with warmth."
	mutation=COLD_RESISTANCE

	initialize()
		block=FIREBLOCK

	can_activate(var/mob/M,var/list/old_mutations,var/flags)
		// Mutation already set?
		if(mutation in old_mutations)
			return 1

		// Probability check
		var/_prob=30
		if(mHeatres in old_mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FROM_INJECTOR)))
			return 1

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_message="Your fingers feel numb."
	mutation=mFingerprints

	initialize()
		block=NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_message="Your skin feels strange."
	mutation=mShock

	initialize()
		block=SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_message="Your skin feels rubbery."
	mutation=mSmallsize

	initialize()
		block=SMALLSIZEBLOCK

	can_activate(var/mob/M,var/list/old_mutations,var/flags)
		// Can't be big and small.
		if(HULK in old_mutations)
			return 0
		return ..(M,old_mutations,flags)

	activate(var/mob/M)
		..(M)
		M.pass_flags |= 1

/datum/dna/gene/basic/hulk
	name="Hulk"
	activation_message="Your muscles hurt."
	mutation=HULK

	initialize()
		block=HULKBLOCK

	can_activate(var/mob/M,var/list/old_mutations,var/flags)
		// Can't be big and small.
		if(mSmallsize in old_mutations)
			return 0
		return ..(M,old_mutations,flags)