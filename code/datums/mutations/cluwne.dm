/datum/mutation/human/cluwne
	name = "Cluwne"
	desc = "Turns a person into a Cluwne, a poor soul cursed to a short and miserable life by the honkmother."
	quality = NEGATIVE
	locked = TRUE

/datum/mutation/human/cluwne/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.dna.add_mutation(/datum/mutation/human/epilepsy)
	owner.setOrganLoss(ORGAN_SLOT_BRAIN, 199)

	playsound(owner.loc, 'sound/misc/honk_echo_distant.ogg', 50, 1)
	owner.equip_to_slot_or_del(new /obj/item/storage/backpack/clown(owner), ITEM_SLOT_BACK) // this is purely for cosmetic purposes incase they aren't wearing anything in that slot
	if(!istype(owner.wear_mask, /obj/item/clothing/mask/gas/cluwne))
		if(!owner.dropItemToGround(owner.wear_mask, force = TRUE))
			qdel(owner.wear_mask)
		owner.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/cluwne(owner), ITEM_SLOT_MASK)

	var/mob/living/carbon/human/victim = owner
	if(!istype(victim.w_uniform, /obj/item/clothing/under/rank/civilian/cluwne))
		if(!victim.dropItemToGround(victim.w_uniform))
			qdel(victim.w_uniform)
		victim.equip_to_slot_or_del(new /obj/item/clothing/under/rank/civilian/cluwne(victim), ITEM_SLOT_ICLOTHING)
	if(!istype(victim.shoes, /obj/item/clothing/shoes/cluwne))
		if(!victim.dropItemToGround(victim.shoes))
			qdel(victim.shoes)
		victim.equip_to_slot_or_del(new /obj/item/clothing/shoes/cluwne(victim), ITEM_SLOT_FEET)
	owner.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/white(owner), ITEM_SLOT_GLOVES) // ditto

/datum/mutation/human/cluwne/on_life()
	if(!prob(15) || !owner.IsUnconscious())
		return
	owner.setOrganLoss(ORGAN_SLOT_BRAIN, 199)
	switch(rand(1, 6))
		if(1)
			owner.say("HONK")
		if(2 to 5)
			owner.emote("scream")
		if(6)
			owner.Stun(1)
			owner.Knockdown(20)
			owner.do_jitter_animation(300)

/datum/mutation/human/cluwne/on_losing(mob/living/carbon/owner)
	owner.adjust_fire_stacks(1)
	owner.ignite_mob()
	owner.cluwne_transform_dna()

/**
 * Adds the cluwne mutation to a mob.
 *
 * Used when equipping cursed cluwne items.
 */
/mob/living/carbon/proc/cluwne_transform_dna()
	dna.add_mutation(/datum/mutation/human/cluwne)
	emote("scream")
	regenerate_icons()
	visible_message(span_danger("[src]'s body glows green, the glow dissipating only to leave behind a cluwne formerly known as [src]!"), \
					span_danger("Your brain feels like it's being torn apart, there is only the honkmother now."))
	flash_act()
