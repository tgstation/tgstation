/datum/quirk/freerunning
	name = "Freerunning"
	desc = "У вас отлично получаются быстрые движения! Вы можете быстрее взбираться на столы и не получать повреждений от коротких падений."
	icon = FA_ICON_RUNNING
	value = 8
	mob_trait = TRAIT_FREERUNNING
	gain_text = span_notice("Вы чувствуете себя уверенно на своих двоих!")
	lose_text = span_danger("Вы снова чувствуете себя неуклюжим.")
	medical_record_text = "Пациент получил высокие баллы по результатам кардиологических тестов."
	mail_goodies = list(/obj/item/melee/skateboard, /obj/item/clothing/shoes/wheelys/rollerskates)
