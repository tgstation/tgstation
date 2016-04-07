/datum/disease/velocity
	name = "Velocity 9 poisoning"
	max_stages = 3
	spread_text = "Special"
	cure_text = "Frost Oil"
	cures = list("frostoil")
	agent = "Speed force"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 100
	desc = ""
	disease_flags = CAN_CARRY|CURABLE
	spread_flags = NON_CONTAGIOUS
	required_organs = list(/obj/item/organ/internal/lungs)
	severity = HARMFUL

/datum/disease/velocity/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(10))
				affected_mob.visible_message("<span class='warning'>[affected_mob]'s rapidly vibrates and moves in slow motion</span>")
			if (affected_mob.reagents.get_reagent_amount("velocity9") < 20)
				affected_mob.reagents.add_reagent("velocity9", 20)
		if(3)
			if (affected_mob.reagents.get_reagent_amount("velocity9") < 20)
				affected_mob.reagents.add_reagent("velocity9", 20)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/H = affected_mob
				H.unEquip(H.wear_suit)
			affected_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/reactive/speed(affected_mob), slot_wear_suit)
			grant_vibratinghand()
			grant_iciclehand()
			affected_mob.next_move_adjust = -3

/datum/disease/velocity/proc/grant_vibratinghand()
	if(affected_mob.dna.species.id != "human")//can't vibrate scales fast enough
		return
	var/list/spelllist = affected_mob.mob_spell_list.Copy()
	if(affected_mob.mind)
		spelllist |= affected_mob.mind.spell_list
	for(var/S in spelllist)
		if(istype(S, /obj/effect/proc_holder/spell/targeted/touch/vibrate))
			return
	affected_mob.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/vibrate)

/datum/disease/velocity/proc/grant_iciclehand()
	if(affected_mob.dna.species.id != "human")//can't vibrate calws fast enough
		return
	var/list/spelllist = affected_mob.mob_spell_list.Copy()
	if(affected_mob.mind)
		spelllist |= affected_mob.mind.spell_list
	for(var/S in spelllist)
		if(istype(S, /obj/effect/proc_holder/spell/targeted/icicle))
			return
	affected_mob.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/icicle)

/obj/effect/proc_holder/spell/targeted/touch/vibrate
	name = "Vibrating hand"
	desc = "Vibrate your hand into a highly effective disabling weapon."
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
		var/obj/item/weapon/icicle/velocity = new
		C.put_in_hands(velocity)