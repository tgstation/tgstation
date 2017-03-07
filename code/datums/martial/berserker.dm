/datum/martial_art/berserker
	name = "Berserker"
	var/datum/action/berserker/backbreak/backbreak = new()
	var/datum/action/berserker/cuffbreak/cuffbreak = new()
	var/datum/action/berserker/stimulants/stimulants = new()
	var/datum/action/berserker/stimulants/medical/medical = new()
	var/datum/action/berserker/stimulants/big/big = new()
	var/chemCD = FALSE

/datum/action/berserker/backbreak
	name = "Backbreak - Only usable while aggressively grabbing someone. You lift them up and break their back over your knee."
	button_icon_state = "backbreak"
	var/inProgress = FALSE

/datum/action/berserker/backbreak/Trigger()
	var/mob/living/carbon/human/H = owner
	if(inProgress)
		return
	inProgress = TRUE
	if(H.pulling && iscarbon(H.pulling))
		var/mob/living/carbon/victim = H.pulling
		if(H.grab_state >= GRAB_AGGRESSIVE)
			H.visible_message("<span class='danger'>[H] starts lifting up [victim]!</span>", "<b><i>You begin lifting [victim] over your knee.</i></b>")
			if(do_after(H, 35, target = victim))
				H.visible_message("<span class='danger'>[H] slams [victim]'s back over [H.p_their()] knee!</span>", "<b><i>You slam [victim] over your knee!</i></b>")
				victim << "<span class='userdanger'>[H] slams your back over [H.p_their()] knee!</span>"
				playsound(victim, 'sound/effects/blobattack.ogg', 40, 1)
				victim.forceMove(get_turf(H))
				victim.Weaken(3)
				victim.adjustStaminaLoss(50)
				victim.apply_damage(35)
		else
			H << "<span class='warning'>You need a stronger grab to do that.</span>"
	else
		H << "<span class='warning'>You have to grab somebody to do that.</span>"
	inProgress = FALSE

/datum/action/berserker/cuffbreak
	name = "Cuffbreak - You destroy any handcuffs that are currently on you with brute strength."
	button_icon_state = "freedom"

/datum/action/berserker/cuffbreak/Trigger()
	var/mob/living/carbon/human/H = owner
	if(H.handcuffed)
		var/obj/cuffs = H.get_item_by_slot(slot_handcuffed)
		if(!istype(cuffs))
			return 0
		H.visible_message("<span class='warning'>[H] breaks apart [H.p_their()] [cuffs] with raw strength!</span>", "<span class='warning'>You force your hands apart, destroying \the [cuffs].</span>")
		playsound(H, 'sound/machines/click.ogg', 40, 1)
		qdel(cuffs)
	else
		H << "<span class='warning'>You have to be in handcuffs to do that.</span>"
		return

/datum/action/berserker/stimulants
	name = "Stimulants - Draw synthesized combat drugs from your mask. Shares a cooldown with other abilities that make chemicals. Has about two minutes of cooldown."
	button_icon_state = "stimulants"
	var/list/chems = list(
		"leporazine",
		"stimulants",
		"nicotine")
	var/amount = 10
	var/cooldownTime = 1050//about 1.75 minutes
	var/message = "<b><i>You feel a rush as combat drugs flow into you.</i></b>"

/datum/action/berserker/stimulants/Trigger()
	var/mob/living/carbon/human/H = owner
	if(istype(H.martial_art, /datum/martial_art/berserker))
		var/datum/martial_art/berserker/parentArt = H.martial_art
		if(!parentArt.chemCD)
			for(var/types in chems)
				H.reagents.add_reagent(types, amount)
			parentArt.chemCD = TRUE
			addtimer(CALLBACK(parentArt, /datum/martial_art/berserker/proc/resetChemCD), cooldownTime)
			H << message
		else
			H << "<span class='warning'>The chemical synthesizer isn't recharged yet.</span>"
			return
	else
		H << "<span class='notice'>You shouldn't be able to use this ability with the proper mask. Adminhelp this and report it as a bug.</span>"

/datum/action/berserker/stimulants/medical
	name = "Medicines - Draw synthesized medicines from your mask. Shares a cooldown with other abilities that make chemicals. Has a minute and a half of cooldown."
	button_icon_state = "medicines"
	chems = list(
		"bicaridine",
		"dexalin",
		"kelotane",
		"tricordrazine")//cant have antitoxin or else it brews into tricord!
	amount = 7.5
	cooldownTime = 900
	message = "<b><i>You feel calmed as medicines flow into you.</i></b>"

/datum/action/berserker/stimulants/big
	name = "Growth Hormone - Draw synthesized hormone from your mask. Shares a cooldown with other abilities that make chemicals. Has a short cooldown."
	button_icon_state = "bigguy"
	chems = list("growthserum")
	amount = 10
	cooldownTime = 150
	message = "<b><i>You're a big guy.</i></b>"

/datum/martial_art/berserker/proc/resetChemCD()
	chemCD = FALSE


/datum/martial_art/berserker/teach(var/mob/living/carbon/human/H,var/make_temporary=0)
	..()
	H << "<span class = 'userdanger'>Your muscles twitch as the mask plunges into your head.</span>"
	H << "<span class = 'danger'>Place your cursor over an ability at the top of the screen to see what it does.</span>"
	backbreak.Grant(H)
	cuffbreak.Grant(H)
	stimulants.Grant(H)
	medical.Grant(H)
	big.Grant(H)

/datum/martial_art/berserker/remove(var/mob/living/carbon/human/H)
	H << "<span class = 'userdanger'>Your muscles stop twitching.</span>"
	H << "<span class = 'danger'>You feel extreme pain as you lose your abilities.</span>"
	H.Weaken(3)//if i pull that off, will you die?
	H.reagents.add_reagent("anacea", 0.5)//purge the healing chems
	backbreak.Remove(H)
	cuffbreak.Remove(H)
	stimulants.Remove(H)
	medical.Remove(H)
	big.Remove(H)


/obj/item/clothing/mask/gas/berserker_mask
	name = "Berserker mask"
	desc = "A mask produced by the syndicate. Has the ID 'ZS-NVB' carefully engraved into it."
	icon_state = "bigmask"
	var/datum/martial_art/berserker/style = new

/obj/item/clothing/mask/gas/berserker_mask/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_wear_mask)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)

/obj/item/clothing/mask/gas/berserker_mask/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_wear_mask) == src)
		style.remove(H)
