#define STUN_SET_AMOUNT	2

/obj/item/organ/internal/cyberimp
	name = "cybernetic implant"
	desc = "a state-of-the-art implant that improves a baseline's functionality"
	status = ORGAN_ROBOTIC
	var/implant_color = "#FFFFFF"
	var/implant_overlay

/obj/item/organ/internal/cyberimp/New(var/mob/M = null)
	if(iscarbon(M))
		src.Insert(M)
	if(implant_overlay)
		var/image/overlay = new /image(icon, implant_overlay)
		overlay.color = implant_color
		overlays |= overlay
	return ..()



//[[[[BRAIN]]]]

/obj/item/organ/internal/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "injectors of extra sub-routines for the brain"
	icon_state = "brain_implant"
	implant_overlay = "brain_implant_overlay"
	zone = "head"
	w_class = 1

/obj/item/organ/internal/cyberimp/brain/emp_act(severity)
	if(!owner)
		return
	var/stun_amount = 5 + (severity-1 ? 0 : 5)
	owner.Stun(stun_amount)
	owner << "<span class='warning'>Your body seizes up!</span>"
	return stun_amount


/obj/item/organ/internal/cyberimp/brain/anti_drop
	name = "anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	var/active = 0
	var/l_hand_ignore = 0
	var/r_hand_ignore = 0
	var/obj/item/l_hand_obj = null
	var/obj/item/r_hand_obj = null
	implant_color = "#DE7E00"
	slot = "brain_antidrop"
	origin_tech = "materials=5;programming=4;biotech=4"
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/internal/cyberimp/brain/anti_drop/ui_action_click()
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

/obj/item/organ/internal/cyberimp/brain/anti_drop/emp_act(severity)
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
		owner << "<span class='warning'>Your left arm spasms and throws the [L_item.name]!</span>"
	if(R_item)
		A = pick(oview(range))
		R_item.throw_at(A, range, 2)
		owner << "<span class='warning'>Your right arm spasms and throws the [R_item.name]!</span>"

/obj/item/organ/internal/cyberimp/brain/anti_drop/proc/release_items()
	if(!l_hand_ignore && l_hand_obj in owner.contents)
		l_hand_obj.flags ^= NODROP
	if(!r_hand_ignore && r_hand_obj in owner.contents)
		r_hand_obj.flags ^= NODROP

/obj/item/organ/internal/cyberimp/brain/anti_drop/Remove(var/mob/living/carbon/M, special = 0)
	if(active)
		ui_action_click()
	..()


/obj/item/organ/internal/cyberimp/brain/anti_stun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	implant_color = "#FFFF00"
	slot = "brain_antistun"
	origin_tech = "materials=6;programming=4;biotech=5"

/obj/item/organ/internal/cyberimp/brain/anti_stun/on_life()
	..()
	if(crit_fail)
		return

	if(owner.stunned > STUN_SET_AMOUNT)
		owner.stunned = STUN_SET_AMOUNT
	if(owner.weakened > STUN_SET_AMOUNT)
		owner.weakened = STUN_SET_AMOUNT

/obj/item/organ/internal/cyberimp/brain/anti_stun/emp_act(severity)
	if(crit_fail)
		return
	crit_fail = 1
	spawn(90 / severity)
		crit_fail = 0


//[[[[MOUTH]]]]
/obj/item/organ/internal/cyberimp/mouth
	zone = "mouth"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = "breathing_tube"
	w_class = 1
	origin_tech = "materials=2;biotech=3"

/obj/item/organ/internal/cyberimp/mouth/breathing_tube/emp_act(severity)
	if(prob(60/severity))
		owner << "<span class='warning'>Your breathing tube suddenly closes!</span>"
		owner.losebreath += 2



//BOX O' IMPLANTS

/obj/item/weapon/storage/box/cyber_implants
	name = "boxed cybernetic implant"
	desc = "A sleek, sturdy box."
	icon_state = "cyber_implants"

/obj/item/weapon/storage/box/cyber_implants/New(loc, implant)
	..()
	new /obj/item/device/autoimplanter(src)
	if(ispath(implant))
		new implant(src)

/obj/item/weapon/storage/box/cyber_implants/bundle
	name = "boxed cybernetic implants"
	var/list/boxed = list(/obj/item/organ/internal/cyberimp/eyes/xray,/obj/item/organ/internal/cyberimp/eyes/thermals,
						/obj/item/organ/internal/cyberimp/brain/anti_stun, /obj/item/organ/internal/cyberimp/chest/reviver)
	var/amount = 5

/obj/item/weapon/storage/box/cyber_implants/bundle/New()
	..()
	var/implant
	while(contents.len <= amount + 1) // +1 for the autoimplanter.
		implant = pick(boxed)
		new implant(src)