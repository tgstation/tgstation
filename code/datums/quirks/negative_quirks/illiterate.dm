/datum/quirk/illiterate
	name = "Illiterate"
	desc = "Вы бросили школу и не умеете читать и писать. Это влияет на чтение, письмо, использование компьютеров и другой электроники."
	icon = FA_ICON_GRADUATION_CAP
	value = -8
	mob_trait = TRAIT_ILLITERATE
	medical_record_text = "Пациент безграмотен."
	hardcore_value = 8
	mail_goodies = list(/obj/item/pai_card) // can read things for you
