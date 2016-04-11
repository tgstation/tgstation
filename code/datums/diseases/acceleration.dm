/datum/disease/acceleration
	name = "Accelerated attributes"
	max_stages = 3
	spread_text = "Special"
	cure_text = "Frost Oil"
	cures = list("frostoil")
	agent = "Radiation metabolism accidents"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 100
	desc = "Infected's attributes such as reagent metabolism, movement, and speed rapidly accelerate."
	disease_flags = CAN_CARRY|CURABLE
	spread_flags = NON_CONTAGIOUS
	required_organs = list(/obj/item/organ/internal/lungs)
	severity = HARMFUL

/datum/disease/acceleration/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(10))
				affected_mob.visible_message("<span class='warning'>[affected_mob] violently jitters and rapidly shakes.</span>")
				affected_mob.Jitter(33)
			if (affected_mob.reagents.get_reagent_amount("accelerativeenyzme") < 20)
				affected_mob.reagents.add_reagent("accelerativeenyzme", 20)
		if(3)
			if (affected_mob.reagents.get_reagent_amount("accelerativeenyzme") < 20)
				affected_mob.reagents.add_reagent("accelerativeenyzme", 20)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/H = affected_mob
				H.unEquip(H.wear_suit)
			affected_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/reactive/kinetic(affected_mob), slot_wear_suit)
			grant_vibratinghand()
			grant_iciclehand()
			affected_mob.next_move_adjust = -3

/datum/disease/acceleration/Destroy()
	affected_mob.unEquip(SLOT_OCLOTHING)
	affected_mob.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/touch/vibrate)
	affected_mob.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/icicle)
	affected_mob.reagents.remove_reagent("accelerativeenyzme", 20)
	affected_mob.next_move_adjust = 0

/datum/disease/acceleration/proc/grant_vibratinghand()
	if(affected_mob.dna.species.id != "human")//can't vibrate scales fast enough
		return
	var/list/spelllist = affected_mob.mob_spell_list.Copy()
	if(affected_mob.mind)
		spelllist |= affected_mob.mind.spell_list
	for(var/S in spelllist)
		if(istype(S, /obj/effect/proc_holder/spell/targeted/touch/vibrate))
			return
	affected_mob.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/vibrate)

/datum/disease/acceleration/proc/grant_iciclehand()
	if(affected_mob.dna.species.id != "human")//can't vibrate claws fast enough
		return
	var/list/spelllist = affected_mob.mob_spell_list.Copy()
	if(affected_mob.mind)
		spelllist |= affected_mob.mind.spell_list
	for(var/S in spelllist)
		if(istype(S, /obj/effect/proc_holder/spell/targeted/icicle))
			return
	affected_mob.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/icicle)

/obj/effect/proc_holder/spell/targeted/touch/vibrate
	name = "Vibrating chop"
	desc = "Vibrate your hand into an effective disabling chop."
	hand_path = "/obj/item/weapon/melee/touch_attack/vibratinghand"

	school = "speed"
	charge_max = 200
	clothes_req = 0

	action_icon_state = "vibrate"

/obj/effect/proc_holder/spell/targeted/icicle
	name = "Create Icicle"
	desc = "Phase your hand fast enough particles of water freeze into a throwable icicle."
	include_user = 1
	range = -1

	school = "speed"
	charge_max = 400
	clothes_req = 0
	action_icon_state = "icicle"



/obj/effect/proc_holder/spell/targeted/icicle/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/C in targets)
		C.drop_item()
		C.swap_hand()
		C.drop_item()
		var/obj/item/weapon/icicle/acceleration = new
		C.put_in_hands(acceleration)