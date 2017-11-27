/datum/mutation/human/cluwne

	name = "Cluwne"
	quality = NEGATIVE
	dna_block = NON_SCANNABLE
	text_gain_indication = "<span class='danger'>You feel like your brain is tearing itself apart.</span>"

/datum/mutation/human/cluwne/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.dna.add_mutation(CLOWNMUT)
	owner.dna.add_mutation(EPILEPSY)
	owner.setBrainLoss(200)

	var/mob/living/carbon/human/H = owner

	if(!istype(H.wear_mask, /obj/item/clothing/mask/hippie/cluwne))
		if(!H.doUnEquip(H.wear_mask))
			qdel(H.wear_mask)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/hippie/cluwne(H), slot_wear_mask)
	if(!istype(H.w_uniform, /obj/item/clothing/under/hippie/cluwne))
		if(!H.doUnEquip(H.w_uniform))
			qdel(H.w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/hippie/cluwne(H), slot_w_uniform)
	if(!istype(H.shoes, /obj/item/clothing/shoes/hippie/cluwne))
		if(!H.doUnEquip(H.shoes))
			qdel(H.shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/hippie/cluwne(H), slot_shoes)

	owner.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/white(owner), slot_gloves) // this is purely for cosmetic purposes incase they aren't wearing anything in that slot
	owner.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(owner), slot_back) // ditto

/datum/mutation/human/cluwne/on_life(mob/living/carbon/human/owner)
	if((prob(15) && owner.IsUnconscious()))
		owner.setBrainLoss(200) // there I changed it to setBrainLoss
		switch(rand(1, 6))
			if(1)
				owner.say("HONK")
			if(2 to 5)
				owner.emote("scream")
			if(6)
				owner.Stun(1)
				owner.Knockdown(20)
				owner.Jitter(500)

/datum/mutation/human/cluwne/on_losing(mob/living/carbon/human/owner)
	owner.adjust_fire_stacks(1)
	owner.IgniteMob()
	owner.dna.add_mutation(CLUWNEMUT)

/mob/living/carbon/human/proc/cluwneify()
	dna.add_mutation(CLUWNEMUT)
	emote("scream")
	regenerate_icons()
	visible_message("<span class='danger'>[src]'s body glows green, the glow dissipating only to leave behind a cluwne formerly known as [src]!</span>", \
					"<span class='danger'>Your brain feels like it's being torn apart, and after a short while, you notice that you've become a cluwne!</span>")
	flash_act()