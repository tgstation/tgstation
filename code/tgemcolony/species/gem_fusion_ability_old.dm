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
		F.setCloneLoss(9001) //FUCK 'EM UP!
	if(H.isfusion == TRUE)
		H.setCloneLoss(9001) //POOF SELF

/datum/action/innate/gem/fusion/proc/createfusion(var/mob/living/carbon/human/fuser,var/mob/living/carbon/human/fusee,var/datum/species/gem/species,fusionname)
	var/mob/living/carbon/human/species/gem/fusion = new/mob/living/carbon/human/species/gem
	fusion.loc = fuser.loc
	fusion.set_species(species)
	fusion.fully_replace_character_name(null, "[fusionname] Fusion ([fuser.gemcut]+[fusee.gemcut])")
	fusion.visible_message("<b>[fuser]</b> fuses with <b>[fusee]</b> to become <b>[fusion]</b>!")
	fusion.maxHealth = fuser.maxHealth+fusee.maxHealth*1.5 //a fusion has the same power as a prime gem.
	fusion.fused_with.Add(fuser)
	fuser.forceMove(fusion)
	fusion.fused_with.Add(fusee)
	fusee.forceMove(fusion)
	fusion.isfusion = TRUE
	fusee.myfusion = fusion
	fuser.myfusion = fusion
	var/obj/item/clothing/under/chameleon/gem/underfuse = new/obj/item/clothing/under/chameleon/gem
	var/obj/item/clothing/shoes/chameleon/gem/undershoes = new/obj/item/clothing/shoes/chameleon/gem
	fusion.equip_to_slot_or_del(underfuse, SLOT_W_UNIFORM)
	fusion.equip_to_slot_or_del(undershoes, SLOT_SHOES)
	if(fuser.gemstatus == "offcolor" || fusee.gemstatus == "offcolor") //defective gems make defective fusions.
		fusion.gemstatus = "offcolor"
	var/dominant = pick("offer","not")
	if(dominant == "offer")
		fusion.key = fuser.key
		fusion.dominantfuse = fuser
		to_chat(fuser, "<span class='notice'>You are the dominant gem in this fusion.</span>")
		to_chat(fusee, "<span class='notice'>[fuser] is the dominant gem in this fusion.</span>")
	else
		fusion.key = fusee.key
		fusion.dominantfuse = fusee
		to_chat(fusee, "<span class='notice'>You are the dominant gem in this fusion.</span>")
		to_chat(fuser, "<span class='notice'>[fusee] is the dominant gem in this fusion.</span>")

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
				if(T.mind.assigned_role == "Crystal Gem" && H.mind.assigned_role == "Freemason")
					to_chat(H, "<span class='notice'>Fuse with the Human lover? No way!</span>")
					return
				else if(T.mind.assigned_role == "Freemason" && H.mind.assigned_role == "Crystal Gem")
					to_chat(H, "<span class='notice'>They're just as bad as Homeworld, You won't fuse with them!</span>")
					return
				else if(T.mind.assigned_role == "Crystal Gem" && H.mind.assigned_role != "Crystal Gem")
					to_chat(H, "<span class='notice'>You aren't fusing with a Traitor!</span>")
					return
				else if(T.mind.assigned_role == "Freemason" && H.mind.assigned_role != "Freemason")
					to_chat(H, "<span class='notice'>You aren't fusing with a Traitor!</span>")
					return
				else if(T.mind.assigned_role != "Freemason" && H.mind.assigned_role == "Freemason")
					to_chat(H, "<span class='notice'>You aren't fusing with a Homeworld Gem!</span>")
					return
				else if(T.mind.assigned_role != "Crystal Gem" && H.mind.assigned_role == "Crystal Gem")
					to_chat(H, "<span class='notice'>You aren't fusing with a Homeworld Gem!</span>")
					return
				else if(target.getStaminaLoss() > 50)
					to_chat(H, "<span class='notice'>They're too exhausted to fuse!</span>")
					return
				if(H.dna.species.id == target.dna.species.id)
					if(H.isfusion == FALSE && target.isfusion == FALSE)
						createfusion(H,target,H.dna.species.type,H.dna.species.name)
					else
						to_chat(H, "<span class='notice'>The fusion won't be stable enough (Fusions of 3 gems or more not added yet.)</span>")
				else
					if(H.mind.assigned_role == "Crystal Gem" || H.mind.assigned_role == "Freemason")
						if(H.dna.species.id == "ruby" && target.dna.species.id == "sapphire" || H.dna.species.id == "sapphire" && target.dna.species.id == "ruby")
							createfusion(H,target,/datum/species/gem/fusion/garnet, "Garnet")
							if(prob(30))
								var/randommessage = pick("You are made of love.","Where did we go, what did we do? I think we made something entirely new.","We are an experience.")
								to_chat(target, "<span class='danger'>[randommessage]</span>")
								to_chat(H, "<span class='danger'>[randommessage]</span>")
						else
							to_chat(H, "<span class='danger'>The fusion won't be stable enough (This fusion hasn't been added yet.)</span>")
					else
						to_chat(H, "<span class='danger'>You can't fuse with them, Homeworld would shatter you!</span>")
			else
				to_chat(H, "<span class='notice'>You cannot fuse with a non-gem.</span>")
		else
			to_chat(H, "<span class='notice'>You must be grabbing someone to offer a fusion.</span>")
	else
		to_chat(H, "<span class='notice'>You cannot fuse.</span>")
		del(src)