/datum/mood_event/high
	mood_change = 6
	description = "Вооооу, чувааааак... Меня таааак качааааает..."

/datum/mood_event/stoned
	mood_change = 6
	description = "Я под такиииииим каааайфом..."

/datum/mood_event/maintenance_high
	mood_change = 6
	description = "Я на вершине мира, детка! Тайдим весь мир!"
	timeout = 2 MINUTES

/datum/mood_event/maintenance_high/add_effects(param)
	var/value = rand(-1, 6) // chance for it to suck
	mood_change = value
	if(value < 0)
		description = "Нет! Не надо! Только не мои перчатки! Аргххх!"
	else
		description = initial(description)

/datum/mood_event/hang_over
	mood_change = -4
	description = "Это похмелье хочет меня убить!"
	timeout = 1 MINUTES

/datum/mood_event/smoked
	description = "Я недавно курил."
	mood_change = 2
	timeout = 6 MINUTES

/datum/mood_event/wrong_brand
	description = "Я ненавижу эту марку сигарет."
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/overdose
	mood_change = -8
	timeout = 5 MINUTES

/datum/mood_event/overdose/add_effects(drug_name)
	description = "Кажется, я немного переборщил с [drug_name]!"

/datum/mood_event/withdrawal_light
	mood_change = -2

/datum/mood_event/withdrawal_light/add_effects(drug_name)
	description = "Вот бы еще немножечко [drug_name]..."

/datum/mood_event/withdrawal_medium
	mood_change = -5

/datum/mood_event/withdrawal_medium/add_effects(drug_name)
	description = "Мне очень нужно [drug_name]."

/datum/mood_event/withdrawal_severe
	mood_change = -8

/datum/mood_event/withdrawal_severe/add_effects(drug_name)
	description = "Боже, кто-нибудь дайте мне [drug_name]!"

/datum/mood_event/happiness_drug
	description = "Я ничего не чувствую..."
	mood_change = 50

/datum/mood_event/happiness_drug_good_od
	description = "ДА! ДА!! ДА!!!"
	mood_change = 100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_good"

/datum/mood_event/happiness_drug_bad_od
	description = "НЕТ! НЕТ!! НЕТ!!!"
	mood_change = -100
	timeout = 30 SECONDS
	special_screen_obj = "mood_happiness_bad"

/datum/mood_event/narcotic_medium
	description = "Я чувствую комфортное онемение."
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/narcotic_heavy
	description = "Я как будто окутан в хлопок!"
	mood_change = 9
	timeout = 3 MINUTES

/datum/mood_event/antinarcotic_medium
	description = "I wish I was numb again!"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/antinarcotic_heavy
	description = "NO!! Make the cotton come back!"
	mood_change = -9
	timeout = 3 MINUTES

/datum/mood_event/stimulant_medium
	description = "Я наполнен энергией! Такое ощущение, что я могу всё!"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/stimulant_heavy
	description = "ЕЕЕ-ХАААА! ХА ХА ХА ХА ХАА! Аххх."
	mood_change = 6
	timeout = 3 MINUTES

#define EIGENTRIP_MOOD_RANGE 10

/datum/mood_event/eigentrip
	description = "Я поменялся местами с самим собой из альтернативной реальности!"
	mood_change = 0
	timeout = 10 MINUTES

/datum/mood_event/eigentrip/add_effects(param)
	var/value = rand(-EIGENTRIP_MOOD_RANGE,EIGENTRIP_MOOD_RANGE)
	mood_change = value
	if(value < 0)
		description = "Я поменялся местами с самим собой из альтернативной реальности! Хочется домой!"
	else
		description = "Я поменялся местами с самим собой из альтернативной реальности! Ну, здесь в разы лучше, чем в прошлой жизни."

#undef EIGENTRIP_MOOD_RANGE

/datum/mood_event/nicotine_withdrawal_moderate
	description = "Давно я не закуривал. Немного на взводе... "
	mood_change = -5

/datum/mood_event/nicotine_withdrawal_severe
	description = "Голова трещит. Холодный пот. Тревожность. Нужно расслабиться и закурить!"
	mood_change = -8

/datum/mood_event/hauntium_spirits
	description = "Моя душа деградирует!"
	mood_change = -8
	timeout = 8 MINUTES

/datum/mood_event/sadness_inverse
	description = "МНЕ ОЧЕНЬ ГРУСТНО..."
	mood_change = -150
	special_screen_obj = "mood_happiness_bad"
