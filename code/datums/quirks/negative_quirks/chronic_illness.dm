/datum/quirk/item_quirk/chronic_illness
	name = "Eradicative Chronic Illness"
	desc = "У вас аномальное хроническое заболевание, которое требует постоянного приёма лекарств для контроля над ним, иначе оно вызывает коррекцию временной линии."
	icon = FA_ICON_DISEASE
	value = -12
	gain_text = span_danger("Вы чувствуете, будто растворяетесь...")
	lose_text = span_notice("Вы внезапно почувствовали себя более ощутимым.")
	medical_record_text = "Пациент страдает аномальным хроническим заболеванием, которое требует постоянного приема медикаментов для поддержания состояния под контролем."
	hardcore_value = 12
	mail_goodies = list(/obj/item/storage/pill_bottle/sansufentanyl)

/datum/quirk/item_quirk/chronic_illness/add(client/client_source)
	var/datum/disease/chronic_illness/hms = new()
	quirk_holder.ForceContractDisease(hms, make_copy = FALSE, del_on_fail = TRUE)

/datum/quirk/item_quirk/chronic_illness/add_unique(client/client_source)
	give_item_to_holder(/obj/item/storage/pill_bottle/sansufentanyl, list(LOCATION_BACKPACK), flavour_text = "Вам назначили лекарства, которые помогут справиться с вашим заболеванием. Принимайте их регулярно, чтобы избежать осложнений.", notify_player = TRUE)
	give_item_to_holder(/obj/item/healthanalyzer/simple/disease, list(LOCATION_BACKPACK))
