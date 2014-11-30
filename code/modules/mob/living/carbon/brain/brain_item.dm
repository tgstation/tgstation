/obj/item/organ/brain
	name = "brain"
	health = 400 //They need to live awhile longer than other organs.
	desc = "A piece of juicy meat found in a person's head."
	icon_state = "brain2"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")
	prosthetic_name = "cyberbrain"
	prosthetic_icon = "brain-prosthetic"
	organ_tag = "brain"
	organ_type = /datum/organ/internal/brain
	//nonplant_seed_type = /obj/item/seeds/synthbrainseed

	var/mob/living/carbon/brain/brainmob = null

/obj/item/organ/brain/New()
	..()
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud

/obj/item/organ/brain/proc/transfer_identity(var/mob/living/carbon/H)
	name = "[H]'s brain"
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	brainmob << "\blue You feel slightly disoriented. That's normal when you're just a brain."
	callHook("debrain", list(brainmob))

/obj/item/organ/brain/examine() // -- TLE
	set src in oview(12)
	if (!( usr ))
		return
	usr << "This is \icon[src] \an [name]."

	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		usr << "You can feel the small spark of life still left in this one."
	else
		usr << "This one seems particularly lifeless. Perhaps it will regain some of its luster later.."

/obj/item/organ/brain/removed(var/mob/living/target,var/mob/living/user)

	..()

	var/mob/living/simple_animal/borer/borer = target.has_brain_worms()

	if(borer)
		borer.detach() //Should remove borer if the brain is removed - RR

	var/mob/living/carbon/human/H = target
	var/obj/item/organ/brain/B = src
	if(istype(B) && istype(H))
		B.transfer_identity(target)

/obj/item/organ/brain/replaced(var/mob/living/target)

	if(target.key)
		target.ghostize()

	if(brainmob)
		if(brainmob.mind)
			brainmob.mind.transfer_to(target)
		else
			target.key = brainmob.key