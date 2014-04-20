
var/list/bioUids = new/list() //Global list of all uids and their respective mobs

var/numbersAndLetters = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" , "0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
var/list/bioEffectList = null

/proc/biodbg()
	usr:bioHolder:AddEffect("cryokinesis")
	usr:bioHolder:AddEffect("mattereater")
	usr:bioHolder:AddEffect("glowy")
	usr:bioHolder:AddEffect("jumpy")
	usr:bioHolder:AddEffect("polymorphism")
	usr:bioHolder:AddEffect("chameleon")
	usr:bioHolder:AddEffect("telepathy")
	return

/proc/addBio()
	var/mob/M = input(usr, "Select Mob:") as mob in world
	if(!M) return
	//if(hasvar(M, "bioHolder"))
	var/id = input(usr, "Effect ID:")
	M:bioHolder.AddEffect(id)
	return

/datum/appearanceHolder //Holds all the appearance information.
	var/r_hair = 0.0
	var/g_hair = 0.0
	var/b_hair = 0.0
	var/h_style = "Trimmed"

	var/r_facial = 0.0
	var/g_facial = 0.0
	var/b_facial = 0.0
	var/f_style = "Shaved"

	var/r_detail = 0.0
	var/g_detail = 0.0
	var/b_detail = 0.0
	var/d_style = "None"

	var/r_eyes = 0.0
	var/g_eyes = 0.0
	var/b_eyes = 0.0

	var/s_tone = 0.0

	var/mob/owner = null
	var/mob/parentHolder = null

	var/gender = NEUTER

	proc/CopyOther(var/datum/appearanceHolder/toCopy) //Copies settings of another given holder. Used for the bioholder copy proc and such things.
		r_hair = toCopy.r_hair
		g_hair = toCopy.g_hair
		b_hair = toCopy.b_hair
		h_style = toCopy.h_style

		r_facial = toCopy.r_facial
		g_facial = toCopy.g_facial
		b_facial = toCopy.b_facial
		f_style = toCopy.f_style

		r_detail = toCopy.r_detail
		g_detail = toCopy.g_detail
		b_detail = toCopy.b_detail
		d_style = toCopy.d_style

		r_eyes = toCopy.r_eyes
		g_eyes = toCopy.g_eyes
		b_eyes = toCopy.b_eyes

		s_tone = toCopy.s_tone
		gender = toCopy.gender
		return

	proc/StaggeredCopyOther(var/datum/appearanceHolder/toCopy, var/progress = 1)
		var/adjust_denominator = 11 - progress
		r_hair += (toCopy.r_hair - r_hair) / adjust_denominator
		g_hair += (toCopy.g_hair - g_hair) / adjust_denominator
		b_hair += (toCopy.b_hair - b_hair) / adjust_denominator
		if (progress >= 9 || prob(progress * 10))
			h_style = toCopy.h_style
			f_style = toCopy.f_style
			d_style = toCopy.d_style

		r_facial += (toCopy.r_facial - r_facial) / adjust_denominator
		g_facial += (toCopy.g_facial - g_facial) / adjust_denominator
		b_facial += (toCopy.b_facial - b_facial) / adjust_denominator

		r_detail += (toCopy.r_detail - r_detail) / adjust_denominator
		g_detail += (toCopy.g_detail - g_detail) / adjust_denominator
		b_detail += (toCopy.b_detail - b_detail) / adjust_denominator

		r_eyes += (toCopy.r_eyes - r_eyes) / adjust_denominator
		g_eyes += (toCopy.g_eyes - g_eyes) / adjust_denominator
		b_eyes += (toCopy.b_eyes - b_eyes) / adjust_denominator

		s_tone += (toCopy.s_tone - s_tone) / adjust_denominator

		if (progress > 7 || prob(progress * 10))
			gender = toCopy.gender
		return

	proc/UpdateMob() //Rebuild the appearance of the mob from the settings in this holder.
		if(!owner)
			return
		if(hasvar(owner, "hair_icon_state"))
			var/list/hair_list = hair_styles + hair_styles_gimmick
			owner:hair_icon_state = hair_list[h_style]
		if(hasvar(owner, "face_icon_state"))
			var/list/beard_list = fhair_styles + fhair_styles_gimmick
			owner:face_icon_state = beard_list[f_style]
		if(hasvar(owner, "detail_icon_state"))
			var/list/detail_list = detail_styles + detail_styles_gimmick
			owner:detail_icon_state = detail_list[d_style]
		owner.gender = src.gender

		if(hascall(owner, "set_face_icon_dirty")) owner:set_face_icon_dirty()
		if(hascall(owner, "set_body_icon_dirty")) owner:set_body_icon_dirty()
		if(hascall(owner, "set_clothing_icon_dirty")) owner:set_clothing_icon_dirty()
		return

/datum/bioHolder //Holds the apperanceholder aswell as the effects. Controls adding and removing of effects.
	var/list/effects = new/list()
	var/mob/owner = null
	var/ownerName = null

	var/bloodType = "AB+-"
	var/age = 30.0

	var/datum/appearanceHolder/mobAppearance = null

	var/list/effectPool = new/list()

	var/Uid = "not initialized" //Unique id for the mob. Used for fingerprints and whatnot.

	New(var/mob/owneri)
		owner = owneri
		Uid = CreateUid()
		bioUids.Add(Uid)
		bioUids[Uid] = owner
		mobAppearance = new/datum/appearanceHolder()

		mobAppearance.owner = owner
		mobAppearance.parentHolder = src

		if(owner)
			reg_dna[Uid] = owner:real_name
			ownerName = owner:real_name

		BuildEffectPool()
		return ..()

	proc/ActivatePoolEffect(var/datum/bioEffect/E)
		if(!effectPool.Find(E) || !E.dnaBlocks.sequenceCorrect() || HasEffect(E.id))
			return 0

		if(genResearch.researchedMutations[E.id] < 3) //Activating also instantly researches.
			genResearch.researchedMutations[E.id] += 1

		AddEffect(E.id)
		effectPool.Remove(E)
		return 1

	proc/AddNewPoolEffect(var/idToAdd)
		for(var/datum/bioEffect/D in effectPool)
			if(lowertext(D.id) == lowertext(idToAdd))
				return 0
		for(var/datum/bioEffect/D in effects)
			// i guess we wouldnt want it in here either
			if(lowertext(D.id) == lowertext(idToAdd))
				return 0

		for(var/bioEffect in bioEffectList)
			var/datum/bioEffect/newEffect = new bioEffect()
			if (lowertext(newEffect.id) == lowertext(idToAdd))
				effectPool.Add(newEffect)
				return 1

		return 0

	proc/AddRandomNewPoolEffect()
		var/list/filteredList = list()

		if (!bioEffectList || !bioEffectList.len)
			debug_log.Add("<b>Genetics:</b> Tried to add new random effect to pool for [owner ? "\ref[owner] [owner.name]" : "*NULL*"], but bioEffectList is empty!")
			return 0

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(HasEffect(instance.id) || HasEffectInPool(instance.id) || instance.isHidden)
				continue
			filteredList.Add(instance)
			filteredList[instance] = instance.probability

		if(!filteredList.len)
			debug_log.Add("<b>Genetics:</b> Unable to get effects for new random effect for [owner ? "\ref[owner] [owner.name]" : "*NULL*"]. (filteredList.len = [filteredList.len])")
			return 0

		var/datum/bioEffect/selectedG = pickweight(filteredList)
		var/datum/bioEffect/selectedNew = selectedG.GetCopy()
		selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
		effectPool.Add(selectedNew)
		return 1

	proc/RemovePoolEffect(var/datum/bioEffect/E)
		if(!effectPool.Find(E))
			return 0
		effectPool.Remove(E)
		return 1

	proc/BuildEffectPool()
		var/list/filteredGood = new/list()
		var/list/filteredBad = new/list()

		effectPool.Cut()

		if (!bioEffectList || !bioEffectList.len)
			debug_log.Add("<b>Genetics:</b> Tried to build effect pool for [owner ? "\ref[owner] [owner.name]" : "*NULL*"], but bioEffectList is empty!")

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(HasEffect(instance.id) || instance.isHidden) continue
			if(src.owner)
				if (src.owner.type in instance.mob_exclusion)
					continue
				if (instance.mob_exclusive && src.owner.type != instance.mob_exclusive)
					continue
			if(instance.isBad)
				filteredBad.Add(instance)
				filteredBad[instance] = instance.probability
			else
				filteredGood.Add(instance)
				filteredGood[instance] = instance.probability

		if(!filteredGood.len || !filteredBad.len)
			debug_log.Add("<b>Genetics:</b> Unable to build effect pool for [owner ? "\ref[owner] [owner.name]" : "*NULL*"]. (filteredGood.len = [filteredGood.len], filteredBad.len = [filteredBad.len])")
			return

		for(var/g=0, g<5, g++)
			var/datum/bioEffect/selectedG = pickweight(filteredGood)
			var/datum/bioEffect/selectedNew = selectedG.GetCopy()
			selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
			effectPool.Add(selectedNew)
			filteredGood.Remove(selectedG)

		for(var/b=0, b<5, b++)
			var/datum/bioEffect/selectedB = pickweight(filteredBad)
			var/datum/bioEffect/selectedNew = selectedB.GetCopy()
			selectedNew.dnaBlocks.ModBlocks() //Corrupt the local copy
			effectPool.Add(selectedNew)
			filteredBad.Remove(selectedB)

		effectPool = shuffle(effectPool)

	proc/OnLife()
		for(var/datum/bioEffect/curr in effects)
			curr.OnLife()
			if(curr.timeLeft != -1) curr.timeLeft--
			if(curr.timeLeft == 0)
				RemoveEffect(curr.id)
		return

	proc/OnMobDraw()
		for(var/datum/bioEffect/curr in effects)
			curr.OnMobDraw()
		return

	proc/CreateUid() //Creates a new uid and returns it.
		var/newUid = ""

		do
			for(var/i = 1 to 20)
				newUid += "[pick(numbersAndLetters)]"
		while(bioUids.Find(newUid))

		return newUid

	proc/CopyOther(var/datum/bioHolder/toCopy, var/copyAppearance = 1, var/copyPool = 1, var/copyEffectBlocks = 0, var/copyActiveEffects = 1) //Copies the settings of another given holder. Used for syringes, the dna spread virus and such things.
		if(copyAppearance)
			mobAppearance.CopyOther(toCopy.mobAppearance)
			mobAppearance.UpdateMob()

			bloodType = toCopy.bloodType
			age = toCopy.age

		if(copyActiveEffects)
			effects.Cut()

			for(var/datum/bioEffect/curr in toCopy.effects)
				if (!curr.can_copy)
					continue

				if(HasEffect(curr.id))
					var/datum/bioEffect/newCopy = GetEffect(curr.id)
					if(!newCopy) continue

					newCopy.timeLeft = curr.timeLeft
					newCopy.variant = curr.variant
					newCopy.data = curr.data
				else
					var/datum/bioEffect/newCopy = AddEffect(curr.id)
					if(!newCopy) continue

					newCopy.timeLeft = curr.timeLeft
					newCopy.variant = curr.variant
					newCopy.data = curr.data
		return

	proc/StaggeredCopyOther(var/datum/bioHolder/toCopy, progress = 1)
		if (progress >= 10)
			return CopyOther(toCopy)

		if (mobAppearance)
			mobAppearance.StaggeredCopyOther(toCopy.mobAppearance, progress)
			mobAppearance.UpdateMob()

		if (progress >= 5)
			bloodType = toCopy.bloodType

		age += (toCopy.age - age) / (11 - progress)

	proc/AddEffect(var/idToAdd, var/variant = 0, var/timeleft = 0) //Adds an effect to this holder. Returns the newly created effect if succesful else 0.
		if(!owner) return

		for(var/datum/bioEffect/D in effects)
			if(lowertext(D.id) == lowertext(idToAdd))
				return 0

		for(var/bioEffect in bioEffectList)
			var/datum/bioEffect/newEffect = new bioEffect()
			if (lowertext(newEffect.id) == lowertext(idToAdd))

				for(var/datum/bioEffect/curr in effects)
					if(curr.type == effectTypeMutantRace && newEffect.type == effectTypeMutantRace) //Can only have one mutant race.
						RemoveEffect(curr.id)

				if(variant) newEffect.variant = variant
				if(timeleft) newEffect.timeLeft = timeleft

				effects.Add(newEffect)
				newEffect.owner = owner
				newEffect.holder = src
				newEffect.OnAdd()
				if(lentext(newEffect.msgGain) > 0) owner << "\blue [newEffect.msgGain]"
				mobAppearance.UpdateMob()
				return newEffect

		return 0

	proc/RemoveEffect(var/id) //Removes an effect from this holder. Returns 1 on success else 0.
		for(var/datum/bioEffect/D in effects)
			if(lowertext(D.id) == lowertext(id))
				D.OnRemove()
				if(lentext(D.msgLose) > 0) owner << "\red [D.msgLose]"
				return effects.Remove(D)
		return 0

	proc/RemoveAllEffects(var/type = null)
		for(var/datum/bioEffect/D in effects)
			if(D.isHidden) continue
			if(type != null)
				if(D.effectType == type)
					RemoveEffect(D.id)
			else
				RemoveEffect(D.id)
		return 1

	proc/HasAnyEffect(var/type = null)
		if(type)
			for(var/datum/bioEffect/D in effects)
				if(D.effectType == type)
					return 1
		else
			return (effects.len ? 1 : 0)
		return 0

	proc/HasEffect(var/id) //Returns variant if this holder has an effect with the given ID else 0. Returns 1 if it has the effect with variant 0, special case for limb tone.
		for(var/datum/bioEffect/D in effects)
			if(lowertext(D.id) == lowertext(id))
				if(D.variant == 0) return 1
				return D.variant
		return 0

	proc/HasEffectInPool(var/id)
		for(var/datum/bioEffect/D in effectPool)
			if(lowertext(D.id) == lowertext(id))
				return 1
		return 0

	proc/HasOneOfTheseEffects() //HasAnyEffect() was already taken :I
		for (var/datum/bioEffect/D in effects)
			if (lowertext(D.id) in args)
				return (D.variant == 0 ? 1 : D.variant)

		return 0

	proc/HasAllOfTheseEffects()
		var/tally = 0 //We cannot edit the args list directly, so just keep a count.
		for (var/datum/bioEffect/D in effects)
			if (lowertext(D.id) in args)
				tally++

		return tally >= args.len

	proc/GetEffect(var/id) //Returns the effect with the given ID if it exists else returns null.
		for(var/datum/bioEffect/D in effects)
			if(lowertext(D.id) == lowertext(id))
				return D
		return null

	proc/GetCooldownForEffect(var/id)
		var/divider = 1
		for(var/datum/bioEffect/cooldown_reducer/D in effects)
			divider = D.divider
		for(var/datum/bioEffect/D in effects)
			if(lowertext(D.id) == lowertext(id))
				return D.cooldown * divider
		return 0

	proc/RandomEffect(var/type = "either", var/useProbability = 1) //Adds a random effect to this holder. Argument controls which type. bad , good, either.
		var/list/filtered = new/list()

		for(var/T in bioEffectList)
			var/datum/bioEffect/instance = bioEffectList[T]
			if(HasEffect(instance.id) || instance.isHidden) continue
			switch(lowertext(type))
				if("good")
					if(instance.isBad)
						continue
				if("bad")
					if(!instance.isBad)
						continue
			filtered.Add(instance)
			filtered[instance] = instance.probability

		if(!filtered.len) return

		var/datum/bioEffect/E = null

		if(useProbability)
			E = pickweight(filtered)
		else
			E = pick(filtered)

		AddEffect(E.id)

		return E.id
