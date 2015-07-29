/obj/effect/proc_holder/changeling/transform
	name = "Transform"
	desc = "We take on the appearance and voice of one we have absorbed."
	chemical_cost = 5
	dna_cost = 0
	req_dna = 1
	req_human = 1
	max_genetic_damage = 3

//changeling clothing items
/obj/item/clothing/head/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/gloves/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/head/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/mask/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/shoes/changeling
	name = "flesh"
	flags = NODROP

/obj/item/clothing/suit/changeling
	name = "flesh"
	flags = NODROP
	allowed = list(/obj/item/changeling)

/obj/item/clothing/under/changeling
	name = "flesh"
	flags = NODROP

/obj/item/changeling
	name = "flesh"
	flags = NODROP
	slot_flags = SLOT_BELT | SLOT_BACK

//Change our DNA to that of somebody we've absorbed.
/obj/effect/proc_holder/changeling/transform/sting_action(mob/living/carbon/human/user)
	var/datum/changeling/changeling = user.mind.changeling
	var/datum/changelingprofile/chosen_prof = changeling.select_dna("Select the target DNA: ", "Target DNA")

	if(!chosen_prof)
		return

	user.dna = chosen_prof.dna
	user.real_name = chosen_prof.name
	hardset_dna(user, null, null, null, null, chosen_dna.species.type, chosen_dna.features)
	var/list/slots = list("head", "wear_mask", "back", "wear_suit", "w_uniform", "shoes", "belt", "gloves", "glasses", "ears", "wear_id", "s_store")

	//im so sorry
	if(!user.head)
		var/obj/item/clothing/head/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["head"]
		C.name = chosen_prof.name_list["head"]
		C.flags_cover = chosen_prof.flags_cover_list["head"]
		user.equip_to_slot_or_del(C, slot_head)

	if(!user.wear_mask)
		var/obj/item/clothing/mask/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["wear_mask"]
		C.name = chosen_prof.name_list["wear_mask"]
		C.flags_cover = chosen_prof.flags_cover_list["wear_mask"]
		user.equip_to_slot_or_del(C, slot_wear_mask)

	if(!user.back)
		var/obj/item/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["back"]
		C.name = chosen_prof.name_list["back"]
		user.equip_to_slot_or_del(C, slot_back)

	if(!user.wear_suit)
		var/obj/item/clothing/suit/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["wear_suit"]
		C.name = chosen_prof.name_list["wear_suit"]
		C.flags_cover = chosen_prof.flags_cover_list["wear_suit"]
		user.equip_to_slot_or_del(C, slot_wear_suit)

	if(!user.w_uniform)
		var/obj/item/clothing/under/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["w_uniform"]
		C.name = chosen_prof.name_list["w_uniform"]
		C.flags_cover = chosen_prof.flags_cover_list["w_uniform"]
		user.equip_to_slot_or_del(C, slot_w_uniform)

	if(!user.shoes)
		var/obj/item/clothing/shoes/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["shoes"]
		C.name = chosen_prof.name_list["shoes"]
		C.flags_cover = chosen_prof.flags_cover_list["shoes"]
		user.equip_to_slot_or_del(C, slot_shoes)

	if(!user.belt)
		var/obj/item/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["belt"]
		C.name = chosen_prof.name_list["belt"]
		user.equip_to_slot_or_del(C, slot_belt)

	if(!user.gloves)
		var/obj/item/clothing/gloves/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["gloves"]
		C.name = chosen_prof.name_list["gloves"]
		C.flags_cover = chosen_prof.flags_cover_list["gloves"]
		user.equip_to_slot_or_del(C, slot_gloves)

	if(!user.glasses)
		var/obj/item/clothing/glasses/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["glasses"]
		C.name = chosen_prof.name_list["glasses"]
		C.flags_cover = chosen_prof.flags_cover_list["glasses"]
		user.equip_to_slot_or_del(C, slot_glasses)

	if(!user.ears)
		var/obj/item/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["ears"]
		C.name = chosen_prof.name_list["ears"]
		C.flags_cover = chosen_prof.flags_cover_list["ears"]
		user.equip_to_slot_or_del(C, slot_ears)

	if(!user.wear_id)
		var/obj/item/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["wear_id"]
		C.name = chosen_prof.name_list["wear_id"]
		C.flags_cover = chosen_prof.flags_cover_list["wear_id"]
		user.equip_to_slot_or_del(C, slot_wear_id)

	if(!user.s_store)
		var/obj/item/changeling/C = new(user)
		C.appearance = chosen_prof.appearance_list["s_store"]
		C.name = chosen_prof.name_list["s_store"]
		C.flags_cover = chosen_prof.flags_cover_list["s_store"]
		user.equip_to_slot_or_del(C, slot_s_store)


	updateappearance(user)
	domutcheck(user)

	feedback_add_details("changeling_powers","TR")
	return 1

/datum/changeling/proc/select_dna(var/prompt, var/title)
	var/list/names = list()
	for(var/datum/changelingprofile/prof in stored_profiles)
		names += "[prof.name]"

	var/chosen_name = input(prompt, title, null) as null|anything in names
	if(!chosen_name)
		return
	var/datum/changelingprofile/prof = get_dna(chosen_name)
	return prof
