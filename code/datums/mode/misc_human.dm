///*==========================================SANTA==========================================*
/datum/role/santa
	name = "santa"
	id = "santa"
	threat = 0 //wip

/datum/role/santa/equip()
	if(!ishuman(owner.current))
		return
	owner.current.equip_to_slot_or_del(new /obj/item/clothing/under/color/red, slot_w_uniform)
	owner.current.equip_to_slot_or_del(new /obj/item/clothing/suit/space/santa, slot_wear_suit)
	owner.current.equip_to_slot_or_del(new /obj/item/clothing/head/santa, slot_head)
	owner.current.equip_to_slot_or_del(new /obj/item/clothing/mask/breath, slot_wear_mask)
	owner.current.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/red, slot_gloves)
	owner.current.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/red, slot_shoes)
	owner.current.equip_to_slot_or_del(new /obj/item/weapon/tank/internals/emergency_oxygen/double, slot_belt)
	owner.current.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain, slot_ears)
	owner.current.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/santabag, slot_back)
	owner.current.equip_to_slot_or_del(new /obj/item/device/flashlight, slot_r_store) //most blob spawn locations are really dark.

	var/obj/item/weapon/card/id/gold/santacard = new(owner.current)
	santacard.update_label("Santa Claus", "Santa")
	var/datum/job/captain/J = new/datum/job/captain
	santacard.access = J.get_access()
	owner.current.equip_to_slot_or_del(santacard, slot_wear_id)

	var/obj/item/weapon/storage/backpack/bag = owner.current.back
	var/obj/item/weapon/a_gift/gift = new(owner.current)
	while(bag.can_be_inserted(gift, 1))
		bag.handle_item_insertion(gift, 1)
		gift = new(owner.current)
	..()

/datum/role/santa/enpower()
	owner.current.real_name = "Santa Claus"
	owner.current.name = "Santa Claus"
	owner.current.mind.name = "Santa Claus"
	owner.current.mind.assigned_role = "Santa"
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.hair_style = "Long Hair"
		H.facial_hair_style = "Full Beard"
		H.hair_color = "FFF"
		H.facial_hair_color = "FFF"
	owner.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/presents)
	var/obj/effect/proc_holder/spell/targeted/area_teleport/teleport/telespell = new(owner.current)
	telespell.clothes_req = 0 //santa robes aren't actually magical.
	owner.AddSpell(telespell) //does the station have chimneys? WHO KNOWS!
	..()

/datum/role/santa/greet()
	owner.current << "<span class='boldannounce'>You are Santa! Your objective is to bring joy to the people on this station. You can conjure more presents using a spell, and there are several presents in your bag.</span>"

///*====================================CHRONO LEGIONNAIRE===================================*
/datum/role/chrono
	name = "timeline eradication agent"
	id = "chrono"
	threat = 10 //wip

/datum/role/chrono/equip()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.equipOutfit(/datum/outfit/chrono_agent)
	..()

///*================================AVATAR OF THE WISHGRANTER================================*
/datum/role/avatar
	name = "avatar of the wish granter"
	id = "avatar"
	threat = 10 //wip

/datum/role/avatar/enpower()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		if(H.dna)
			H.dna.add_mutation(HULK)
			H.dna.add_mutation(XRAY)
			H.dna.add_mutation(COLDRES)
			H.dna.add_mutation(TK)
	..()

///*===========================MULTIVERSE SUMMONER (aka memeswords)==========================*
/datum/role/multiverse
	name = "multiverse summoner"
	id = "multiverse"
	threat = 10 //wip

/datum/role/multiverse/equip()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		qdel(H.get_item_by_slot(slot_wear_id))
		H.unEquip(H.get_item_by_slot(slot_r_hand))
		H.equip_to_slot_or_del(new /obj/item/weapon/multisword, slot_r_hand)
		var/obj/item/weapon/card/id/W = new(H)
		W.icon_state = "centcom"
		W.access = get_all_accesses()
		W.access += get_all_centcom_access()
		W.assignment = "Multiverse Summoner"
		W.registered_name = H.real_name
		W.update_label(H.real_name)
		H.equip_to_slot_or_del(W, slot_wear_id)
	..()

///*=========================================WINNER=========================================*
/datum/role/winner //Note: the greentext holder doesn't get this role until they leave on the escape shuttle
	name = "winner"
	id = "winner"
	threat = 0 //wip

/datum/role/winner/equip()
	var/obj/item/weapon/reagent_containers/food/drinks/golden_cup/G = new(owner.current.loc)
	G.name = pick("You're Winner!", "Congrabulae!", "Congraturaisins!", "THE BEST!", "Victor!", "Good Jorb!")
	owner.current.put_in_hands(G)
	..()