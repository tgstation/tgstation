/datum/action/innate/gem/recruitfreemason
	name = "Recruit Freemason"
	desc = "Invite someone to help save Humanity with you!"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "freemasoninvite"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/recruitfreemason/Activate()
	var/list/nearby = list()
	for(var/atom/A in view(owner,6))
		if(istype(A,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = A
			if(H.mind.assigned_role != "Crystal Gem" && H.mind.assigned_role != "Freemason" && H.gemstatus != "prime") //no primes, nor gems already invited.
				if(isgem(H)) //has to be a gem, no human would be foolish enough to join them!
					nearby.Add(A)
	var/atom/target = input("Who do you want to invite?") as null|anything in nearby
	if(target != null)
		var/isinrange = FALSE
		for(var/atom/A in view(owner,6))
			if(A == target)
				isinrange = TRUE
		if(isinrange == TRUE)
			if(istype(target, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = target
				if(H.mind.assigned_role != "Crystal Gem" && H.mind.assigned_role != "Freemason" && H.gemstatus != "prime") //what did i just say?
					var/answer = input(H, "[usr] invites you to be a Freemason!") as null|anything in list("Yes","No")
					if(answer == "Yes")
						H.mind.assigned_role = "Freemason"
						var/datum/action/recruit = new/datum/action/innate/gem/recruitfreemason
						recruit.Grant(H)
						for(var/mob/living/carbon/human/A in world)
							if(A.mind.assigned_role == "Freemason")
								to_chat(A, "<span class='warning'>[H] joins the Freemasons!</span>")
						to_chat(H, "<span class='warning'>As a Freemason, you must capture Kindergartens!\
						<br>Take the Colony from Homeworld for yourselves.</span>")
					else
						to_chat(usr, "<span class='warning'>[H] denies your invitation.</span>")
		else
			to_chat(usr, "<span class='warning'>You have to be in range.</span>")