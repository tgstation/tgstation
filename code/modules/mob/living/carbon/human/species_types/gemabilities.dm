/datum/action/innate/gem/fusion
	name = "Fuse"
	desc = "A cheap tactic to make weak gems stronger."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "fuse"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/unfuse
	name = "Unfuse"
	desc = "Break up the fusion."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "unfuse"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/unfuse/Activate()
	var/mob/living/carbon/human/H = owner
	if(H.myfusion != null)
		var/mob/living/carbon/human/F = H.myfusion
		F.willingunfuse = TRUE
		F.setCloneLoss(9001) //FUCK 'EM UP!
	if(H.isfusion == TRUE)
		H.willingunfuse = TRUE
		H.setCloneLoss(9001) //POOF SELF

/datum/action/innate/gem/fusion/Activate()
	var/mob/living/carbon/human/H = owner
	if(isgem(H))
		if(H.gemstatus == "prime")
			to_chat(H, "<span class='notice'>Fusion is just a cheap tactic to make weak gems stronger. Quit embarassing yourself!</span>")
			return
		if(H.getStaminaLoss() > 50)
			to_chat(H, "<span class='notice'>You're too exhausted to fuse!</span>")
			return
		if(H.pulling)
			var/mob/living/T = H.pulling
			if(isgem(T))
				var/mob/living/carbon/human/target = T
				if(target.gemstatus == "prime")
					to_chat(H, "<span class='notice'>They seem too prideful to fuse with you.</span>")
					return
				if(target.getStaminaLoss() > 50)
					to_chat(H, "<span class='notice'>They're too exhausted to fuse!</span>")
					return
				if(H.dna.species.id == target.dna.species.id)
					if(H.isfusion == FALSE && target.isfusion == FALSE)
						var/mob/living/carbon/human/species/gem/fusion = new/mob/living/carbon/human/species/gem
						fusion.loc = H.loc
						fusion.set_species(H.dna.species.type)
						fusion.fully_replace_character_name(null, "[H.dna.species.name] Fusion ([H.gemcut]+[target.gemcut])")
						fusion.visible_message("<b>[H]</b> fuses with <b>[target]</b> to become <b>[fusion]</b>!")
						fusion.maxHealth = H.maxHealth+target.maxHealth*1.5 //a fusion has the same power as a prime gem.
						fusion.fused_with.Add(H)
						H.forceMove(fusion)
						fusion.fused_with.Add(target)
						target.forceMove(fusion)
						fusion.isfusion = TRUE
						target.myfusion = fusion
						H.myfusion = fusion
						fusion.equip_to_slot_or_del(new/obj/item/clothing/under/gem(null), SLOT_W_UNIFORM)
						fusion.equip_to_slot_or_del(new/obj/item/clothing/shoes/chameleon/gem(null), SLOT_SHOES)
						var/dominant = pick("offer","not")
						if(dominant == "offer")
							fusion.key = H.key
							fusion.dominantfuse = H
							to_chat(H, "<span class='notice'>You are the dominant gem in this fusion.</span>")
							to_chat(target, "<span class='notice'>[H] is the dominant gem in this fusion.</span>")
						else
							fusion.key = target.key
							fusion.dominantfuse = target
							to_chat(target, "<span class='notice'>You are the dominant gem in this fusion.</span>")
							to_chat(H, "<span class='notice'>[target] is the dominant gem in this fusion.</span>")
					else
						to_chat(H, "<span class='notice'>The fusion won't be stable enough (Fusions of 3 gems or more not added yet.)</span>")
				else
					if(H.mind.assigned_role == "Crystal Gem" || H.mind.assigned_role == "Freemason")
						to_chat(H, "<span class='danger'>The fusion won't be stable enough (Fusions between different gems not added yet.)</span>")
					else
						to_chat(H, "<span class='danger'>You can't fuse with them, Homeworld would shatter you!</span>")
			else
				to_chat(H, "<span class='notice'>You cannot fuse with a non-gem.</span>")
		else
			to_chat(H, "<span class='notice'>You must be grabbing someone to offer a fusion.</span>")
	else
		to_chat(H, "<span class='notice'>You cannot fuse.</span>")
		del(src)