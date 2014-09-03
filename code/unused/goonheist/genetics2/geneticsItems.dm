/obj/item/genetics_injector
	name = "genetics injector"
	desc = "A special injector designed to interact with one's genetic structure."
	icon = 'syringe.dmi'
	inhand_image_icon = 'hand_medical.dmi'
	item_state = "syringe_0"
	icon_state = "b10"
	force = 3
	throwforce = 3
	var/uses = 1

	attack(mob/M as mob, mob/user as mob)
		if(!M || !user)
			return
		if(src.uses < 1)
			// just shank them with it i guess?
			..()
			return

		if(M == user)
			user.visible_message("\red <b>[user.name] injects \himself with [src]!</b>")
			src.injected(user,user)
		else
			user.visible_message("\red <b>[user.name] is trying to inject [M.name] with [src]!</b>")
			if (do_mob(user,M,30))
				user.visible_message("\red <b>[user.name] injects [M.name] with [src].</b>")
				src.injected(user,M)
			else
				user << "\red You failed to inject [M.name]."

		if(src.uses < 1)
			src.icon_state = "b0"
			src.desc = "A [src.name] that has been used up. It should be recycled or disposed of."
			src.name = "expended " + src.name

	proc/injected(var/mob/living/carbon/user,var/mob/living/carbon/target)
		if(!istype(user,/mob/living/carbon/) || !istype(target,/mob/living/carbon/))
			return 1
		if(!istype(target.bioHolder,/datum/bioHolder/))
			return 1
		combat_log.Add("<b>[round(((world.time / 10) / 60))]M:</b> [user.real_name] ([user.client ? "[user.client]" : "No Client"]) injects [target:real_name] ([target:client ? "[target:client]" : "No Client"]) with [src.name]")
		return 0

	dna_scrambler
		name = "dna scrambler"
		desc = "An illegal retroviral genetic serum designed to randomize the user's identity."

		injected(var/mob/living/carbon/user,var/mob/living/carbon/target)
			if (..())
				return
			var/datum/bioHolder/DNA = target.bioHolder
			var/datum/appearanceHolder/ID = DNA.mobAppearance
			if (!istype(ID,/datum/appearanceHolder/))
				return

			target << "\red Your body changes! You feel completely different!"
			ID.gender = pick("male","female")
			if(ID.gender == "female")
				target.real_name = pick(first_names_female)
			else
				target.real_name = pick(first_names_male)
			target.real_name += " [pick(last_names)]"

			DNA.bloodType = pick("A+","A-","B+","B-","AB+","AB-","O+","O-")
			DNA.age = rand(20,60)
			target.underwear = pick(underwear_styles)
			DNA.RemoveAllEffects()
			DNA.BuildEffectPool()

			ID.r_hair = rand(0,255)
			ID.g_hair = rand(0,255)
			ID.b_hair = rand(0,255)
			ID.h_style = pick(hair_styles)
			ID.r_facial = rand(0,255)
			ID.g_facial = rand(0,255)
			ID.b_facial = rand(0,255)
			ID.f_style = pick(fhair_styles)
			ID.r_detail = rand(0,255)
			ID.g_detail = rand(0,255)
			ID.b_detail = rand(0,255)
			ID.d_style = pick(detail_styles)
			ID.r_eyes = rand(0,255)
			ID.g_eyes = rand(0,255)
			ID.b_eyes = rand(0,255)
			ID.s_tone = rand(34,-185)

			ID.UpdateMob()
			src.uses--

	dna_injector
		name = "dna injector"
		desc = "A syringe designed to safely insert or remove genetic structures to and from a living organism."
		var/remover = 0
		var/list/genes = list()

		injected(var/mob/living/carbon/user,var/mob/living/carbon/target)
			if (..())
				return

			if (src.remover)
				for(var/X in src.genes)
					target.bioHolder.RemoveEffect(X)
			else
				for(var/X in src.genes)
					target.bioHolder.AddEffect(X)
			src.uses--