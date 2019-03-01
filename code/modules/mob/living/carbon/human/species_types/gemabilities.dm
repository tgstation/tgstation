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

/datum/action/innate/gem/fusion/Activate()
	var/mob/living/carbon/human/H = owner
	if(isgem(H))
		if(H.pulling)
			var/mob/living/T = H.pulling
			if(isgem(T))
				var/mob/living/carbon/human/species/gem/target = T
				if(H.dna.species.id == target.dna.species.id)
					if(H.isfusion == FALSE && target.isfusion == FALSE)
						var/mob/living/carbon/human/species/gem/fusion = new/mob/living/carbon/human/species/gem
						fusion.loc = H.loc
						fusion.set_species(H.dna.species.type)
						fusion.fully_replace_character_name(null, "[H.dna.species.name] Fusion ([H.gemcut]+[target.gemcut])")
						fusion.visible_message("<b>[H]</b> fuses with <b>[target]</b> to become <b>[fusion]</b>!")
						fusion.maxHealth = H.maxHealth+target.maxHealth
						fusion.fused_with.Add(H)
						H.forceMove(fusion)
						fusion.fused_with.Add(target)
						target.forceMove(fusion)
						fusion.isfusion = TRUE
						target.myfusion = fusion
						H.myfusion = fusion
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
					to_chat(H, "<span class='danger'>You can't fuse with them, Homeworld would shatter you!</span>")
			else
				to_chat(H, "<span class='notice'>You cannot fuse with a non-gem.</span>")
		else
			to_chat(H, "<span class='notice'>You must be grabbing someone to offer a fusion.</span>")
	else
		to_chat(H, "<span class='notice'>You cannot fuse.</span>")
		del(src)