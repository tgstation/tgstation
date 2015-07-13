#define STUN_SET_AMOUNT	2

/obj/item/cybernetic_implant
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/implant_color = "#FFFFFF"

/obj/item/cybernetic_implant/New(var/mob/M = null)
	owner = M
	return ..()

/obj/item/cybernetic_implant/proc/function()
	return


//[[[[EYES]]]]

/obj/item/cybernetic_implant/eyes
	name = "cybernetic eyes"
	desc = "artificial photoreceptors with specialized functionality"
	icon_state = "eye_implant"
	var/eye_color = "fff"
	var/flash_protect = 0

/obj/item/cybernetic_implant/eyes/New()
	var/icon/overlay = new /icon('icons/obj/surgery.dmi',"eye_implant_overlay")
	overlay.ColorTone(implant_color)
	overlays |= overlay
	..()

/obj/item/cybernetic_implant/eyes/proc/update_eye_color(fluff_message)
	if(istype(owner,/mob/living/carbon/human))
		var/mob/living/carbon/human/HMN = owner
		HMN.eye_color = eye_color
		HMN.regenerate_icons()
	if(fluff_message)
		owner << "<span class='notice'>[fluff_message]</span>"

/obj/item/cybernetic_implant/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eyes will display a medical HUD over everything you see. Wiggle eyes to control."
	eye_color = "0ff"
	implant_color = "#00FFFF"
	origin_tech = "materials=4;programming=3;biotech=4"

/obj/item/cybernetic_implant/eyes/hud/medical/function()
	if(!owner)
		return

	var/datum/atom_hud/H = huds[DATA_HUD_MEDICAL_ADVANCED]
	H.add_hud_to(owner)
	owner.permanent_huds |= H
	update_eye_color("You suddenly see health bars floating above people's heads...")

/obj/item/cybernetic_implant/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eyes will display a security HUD over everything you see. Wiggle eyes to control."
	eye_color = "d00"
	implant_color = "#CC0000"
	origin_tech = "materials=4;programming=4;biotech=3;combat=1"

/obj/item/cybernetic_implant/eyes/hud/security/function()
	if(!owner)
		return

	var/datum/atom_hud/H = huds[DATA_HUD_SECURITY_ADVANCED]
	H.add_hud_to(owner)
	owner.permanent_huds |= H
	update_eye_color("Job indicator icons pop up in your vision. That is not a certified surgeon...")

/obj/item/cybernetic_implant/eyes/xray
	name = "X-ray implant"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color = "000"
	implant_color = "#000000"
	origin_tech = "materials=6;programming=4;biotech=6;magnets=5"

/obj/item/cybernetic_implant/eyes/xray/function()
	if(!owner)
		return

	owner.sight |= SEE_MOBS
	owner.sight |= SEE_OBJS
	owner.sight |= SEE_TURFS
	owner.permanent_sight_flags |= SEE_MOBS
	owner.permanent_sight_flags |= SEE_OBJS
	owner.permanent_sight_flags |= SEE_TURFS
	update_eye_color("Your vision is augmented!")

/obj/item/cybernetic_implant/eyes/thermals
	name = "Thermals implant"
	desc = "These cybernetic eyes will give you Thermal vision. Vertical slit pupil included."
	eye_color = "FC0"
	implant_color = "#FFCC00"
	flash_protect = -1
	origin_tech = "materials=6;programming=4;biotech=5;magnets=5;syndicate=4"

/obj/item/cybernetic_implant/eyes/thermals/function()
	if(!owner)
		return

	owner.sight |= SEE_MOBS
	owner.permanent_sight_flags |= SEE_MOBS
	update_eye_color("You see prey everywhere you look...")

/obj/item/cybernetic_implant/eyes/emp_act(severity)
	if(!owner)
		return
	if(severity > 1)
		if(prob(5))
			return
	var/save_sight = owner.sight
	owner.sight &= 0
	owner.disabilities |= BLIND
	owner << "<span class='warning'>Static obfuscates your vision!</span>"
	spawn(50)
	owner.sight |= save_sight
	owner.disabilities ^= BLIND


//[[[[BRAIN]]]]

/obj/item/cybernetic_implant/brain
	name = "cybernetic brain implant"
	desc = "injectors of extra sub-routines for the brain"
	icon_state = "brain_implant"

/obj/item/cybernetic_implant/brain/New()
	var/icon/overlay = new /icon('icons/obj/surgery.dmi',"brain_implant_overlay")
	overlay.ColorTone(implant_color)
	overlays |= overlay
	..()

/obj/item/cybernetic_implant/brain/emp_act(severity)
	if(!owner)
		return
	var/stun_amount = 5 + (severity-1 ? 0 : 5)
	owner.Stun(stun_amount)
	owner << "<span class='warning'>Your body seizes up!</span>"
	return stun_amount

/obj/item/cybernetic_implant/brain/anti_drop
	name = "Anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = 0
	var/l_hand_ignore = 0
	var/r_hand_ignore = 0
	var/obj/item/l_hand_obj = null
	var/obj/item/r_hand_obj = null
	implant_color = "#DE7E00"
	origin_tech = "materials=5;programming=4;biotech=4"

/obj/item/cybernetic_implant/brain/anti_drop/function()
	action_button_name = "Toggle Anti-Drop"

/obj/item/cybernetic_implant/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		l_hand_obj = owner.l_hand
		r_hand_obj = owner.r_hand
		if(l_hand_obj)
			if(owner.l_hand.flags & NODROP)
				l_hand_ignore = 1
			else
				owner.l_hand.flags |= NODROP
				l_hand_ignore = 0

		if(r_hand_obj)
			if(owner.r_hand.flags & NODROP)
				r_hand_ignore = 1
			else
				owner.r_hand.flags |= NODROP
				r_hand_ignore = 0

		if(!l_hand_obj && !r_hand_obj)
			owner << "<span class='notice'>You are not holding any items, your hands relax...</span>"
			active = 0
		else
			var/msg = 0
			msg += !l_hand_ignore && l_hand_obj ? 1 : 0
			msg += !r_hand_ignore && r_hand_obj ? 2 : 0
			switch(msg)
				if(1)
					owner << "<span class='notice'>Your left hand's grip tightens.</span>"
				if(2)
					owner << "<span class='notice'>Your right hand's grip tightens.</span>"
				if(3)
					owner << "<span class='notice'>Both of your hand's grips tighten.</span>"
	else
		release_items()
		owner << "<span class='notice'>Your hands relax...</span>"
		l_hand_obj = null
		r_hand_obj = null

/obj/item/cybernetic_implant/brain/anti_drop/emp_act(severity)
	if(!owner)
		return
	var/range = severity ? 10 : 5
	var/atom/A
	var/obj/item/L_item = owner.l_hand
	var/obj/item/R_item = owner.r_hand

	release_items()
	..()
	if(L_item)
		A = pick(oview(range))
		L_item.throw_at(A, range, 2)
		owner << "<span class='notice'>Your left arm spasms and throws the [L_item.name]!</span>"
	if(R_item)
		A = pick(oview(range))
		R_item.throw_at(A, range, 2)
		owner << "<span class='notice'>Your right arm spasms and throws the [R_item.name]!</span>"

/obj/item/cybernetic_implant/brain/anti_drop/proc/release_items()
	if(!l_hand_ignore && l_hand_obj in owner.contents)
		l_hand_obj.flags ^= NODROP
	if(!r_hand_ignore && r_hand_obj in owner.contents)
		r_hand_obj.flags ^= NODROP

/obj/item/cybernetic_implant/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	implant_color = "#FFFF00"
	origin_tech = "materials=6;programming=4;biotech=5"

/obj/item/cybernetic_implant/brain/anti_stun/function()
	SSobj.processing |= src

/obj/item/cybernetic_implant/brain/anti_stun/process()
	if(!owner)
		SSobj.processing.Remove(src)
		qdel(src)
		return
	if(owner.stat == DEAD)
		return

	if(owner.stunned > STUN_SET_AMOUNT)
		owner.stunned = STUN_SET_AMOUNT
	if(owner.weakened > STUN_SET_AMOUNT)
		owner.weakened = STUN_SET_AMOUNT

/obj/item/cybernetic_implant/brain/anti_stun/emp_act(severity)
	if(!owner)
		return
	SSobj.processing.Remove(src)
	spawn(..() * 10)
		SSobj.processing |= src


//[[[[CHEST]]]]

/obj/item/cybernetic_implant/chest
	name = "cybernetic torso implant"
	desc = "implants for the organs in your torso"
	icon_state = "chest_implant"

/obj/item/cybernetic_implant/chest/New()
	var/icon/overlay = new /icon('icons/obj/surgery.dmi',"chest_implant_overlay")
	overlay.ColorTone(implant_color)
	overlays |= overlay
	..()

/obj/item/cybernetic_implant/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/nutriment_amount = 30
	var/poison_amount = 5
	origin_tech = "materials=5;programming=3;biotech=4"

/obj/item/cybernetic_implant/chest/nutriment/function()
	SSobj.processing |= src

/obj/item/cybernetic_implant/chest/nutriment/process()
	if(synthesizing)
		return
	if(!owner)
		SSobj.processing.Remove(src)
		qdel(src)
		return
	if(owner.stat == DEAD)
		return

	if(owner.nutrition <= hunger_threshold)
		synthesizing = 1
		spawn(50)
			owner << "<span class='notice'>You feel less hungry...</span>"
			owner.nutrition += nutriment_amount
			synthesizing = 0

/obj/item/cybernetic_implant/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	nutriment_amount = 50
	poison_amount = 10
	origin_tech = "materials=5;programming=3;biotech=5"

/obj/item/cybernetic_implant/chest/nutriment/emp_act(severity)
	if(!owner)
		return
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	owner << "<span class='warning'>You feel like your insides are burning.</span>"


/obj/item/cybernetic_implant/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	origin_tech = "materials=6;programming=3;biotech=6;syndicate=4"
	var/revive_cost = 0
	var/reviving = 0
	var/cooldown = 0

/obj/item/cybernetic_implant/chest/reviver/function()
	SSobj.processing |= src

/obj/item/cybernetic_implant/chest/reviver/process()
	if(!owner)
		SSobj.processing.Remove(src)
		qdel(src)
		return

	if(reviving)
		if(owner.stat == UNCONSCIOUS)
			spawn(30)
				if(prob(90) && owner.getOxyLoss())
					owner.adjustOxyLoss(-3)
					revive_cost += 5
				if(prob(75) && owner.getBruteLoss())
					owner.adjustBruteLoss(-1)
					revive_cost += 20
				if(prob(75) && owner.getFireLoss())
					owner.adjustFireLoss(-1)
					revive_cost += 20
				if(prob(40) && owner.getToxLoss())
					owner.adjustToxLoss(-1)
					revive_cost += 50
		else
			cooldown = revive_cost + world.time
			reviving = 0
		return

	if(cooldown > world.time)
		return
	if(owner.stat != UNCONSCIOUS)
		return
	if(owner.suiciding)
		SSobj.processing.Remove(src)
		return

	revive_cost = 0
	reviving = 1

/obj/item/cybernetic_implant/chest/reviver/emp_act(severity)
	if(reviving)
		revive_cost += 200
	else
		cooldown += 200

	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.heart_attack = 1
			spawn(600 / severity)
				H.heart_attack = 0
				if(H.stat == CONSCIOUS)
					H << "<span class='notice'>You feel your heart beating again!</span>"


//BOX O' IMPLANTS

/obj/item/weapon/storage/box/cyber_implants
	name = "boxed cybernetic implants"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"
	var/list/boxed = list(/obj/item/cybernetic_implant/eyes/xray,/obj/item/cybernetic_implant/eyes/thermals,
						/obj/item/cybernetic_implant/brain/anti_drop, /obj/item/cybernetic_implant/brain/anti_stun,
						/obj/item/cybernetic_implant/chest/nutriment/plus, /obj/item/cybernetic_implant/chest/reviver)
	var/amount = 5

/obj/item/weapon/storage/box/cyber_implants/New()
	..()
	var/i
	var/implant
	for(i = 0, i < amount, i++)
		implant = pick(boxed)
		new implant(src)