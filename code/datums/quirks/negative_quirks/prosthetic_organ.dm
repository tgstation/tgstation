// // BANDASTATION REMOVAL START - Feat: Augmentations
// /datum/quirk/prosthetic_organ
// 	name = "Prosthetic Organ"
// 	desc = "В результате несчастного случая вы лишились одного из органов. Из-за этого у вас установлен дешевый протез!"
// 	icon = FA_ICON_LUNGS
// 	value = -3
// 	medical_record_text = "При физическом осмотре у пациента был обнаружен бюджетный протез органа. <b>Известно, что удаление этих органов опасно как для пациента, так и для врача.</b>"
// 	hardcore_value = 3
// 	mail_goodies = list(/obj/item/storage/organbox)
// 	/// The slot to replace, in string form
// 	var/slot_string = "organ"
// 	/// The original organ from before the prosthetic was applied
// 	var/obj/item/organ/old_organ

// /datum/quirk_constant_data/prosthetic_organ
// 	associated_typepath = /datum/quirk/prosthetic_organ
// 	customization_options = list(/datum/preference/choiced/prosthetic_organ)

// /datum/quirk/prosthetic_organ/add_unique(client/client_source)
// 	var/mob/living/carbon/human/human_holder = quirk_holder
// 	var/static/list/organ_slots = list(
// 		ORGAN_SLOT_HEART,
// 		ORGAN_SLOT_LUNGS,
// 		ORGAN_SLOT_LIVER,
// 		ORGAN_SLOT_STOMACH,
// 	)
// 	var/preferred_organ = GLOB.organ_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/prosthetic_organ)]
// 	if(isnull(preferred_organ))  //Client is gone or they chose a random prosthetic
// 		preferred_organ = GLOB.organ_choice[pick(GLOB.organ_choice)]

// 	var/list/possible_organ_slots = organ_slots.Copy()
// 	if(!CAN_HAVE_BLOOD(human_holder))
// 		possible_organ_slots -= ORGAN_SLOT_HEART
// 	if(HAS_TRAIT(human_holder, TRAIT_NOBREATH))
// 		possible_organ_slots -= ORGAN_SLOT_LUNGS
// 	if(HAS_TRAIT(human_holder, TRAIT_LIVERLESS_METABOLISM))
// 		possible_organ_slots -= ORGAN_SLOT_LIVER
// 	if(HAS_TRAIT(human_holder, TRAIT_NOHUNGER))
// 		possible_organ_slots -= ORGAN_SLOT_STOMACH
// 	if(!length(organ_slots)) //what the hell
// 		return

// 	var/organ_slot = pick(possible_organ_slots)
// 	if(preferred_organ in possible_organ_slots)
// 		organ_slot = preferred_organ
// 	var/obj/item/organ/prosthetic
// 	switch(organ_slot)
// 		if(ORGAN_SLOT_HEART)
// 			prosthetic = new /obj/item/organ/heart/cybernetic/surplus
// 			slot_string = "сердце"
// 		if(ORGAN_SLOT_LUNGS)
// 			prosthetic = new /obj/item/organ/lungs/cybernetic/surplus
// 			slot_string = "лёгкие"
// 		if(ORGAN_SLOT_LIVER)
// 			prosthetic = new /obj/item/organ/liver/cybernetic/surplus
// 			slot_string = "печень"
// 		if(ORGAN_SLOT_STOMACH)
// 			prosthetic = new /obj/item/organ/stomach/cybernetic/surplus
// 			slot_string = "желудок"
// 	medical_record_text = "При физическом осмотре было обнаружено, что орган пациента, [slot_string], заменен бюджетным протезом. Известно, что удаление этих органов опасно как для пациента, так и для врача."
// 	old_organ = human_holder.get_organ_slot(organ_slot)
// 	prosthetic.Insert(human_holder, special = TRUE)
// 	old_organ.moveToNullspace()
// 	STOP_PROCESSING(SSobj, old_organ)

// /datum/quirk/prosthetic_organ/post_add()
// 	to_chat(quirk_holder, span_bolddanger("Ваш орган, [slot_string], был замен дешевым протезом. Он слаб и крайне нестабилен. Кроме того, любое ЭМИ воздействие заставит его полностью прекратить работу."))

// /datum/quirk/prosthetic_organ/remove()
// 	if(old_organ)
// 		old_organ.Insert(quirk_holder, special = TRUE)
// 	old_organ = null
// // BANDASTATION REMOVAL END - Feat: Augmentations
