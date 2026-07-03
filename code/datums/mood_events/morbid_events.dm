/* Morbid Mood Events -
Any mood events related to TRAIT_MORBID.
Ususally this is an inverse of a typically good, alturistic action (such as saving someones life), punishing it with a negative mood event,
and rewards typically antisocial/unsavory actions (such as graverobbing) with a positive mood event.
Intended to push a creepy, mad scientist/doctor vibe, or someone who is downright monstrous in nature.
*/

// Positive Events - We did something unsavory in the name of mad science

/datum/mood_event/morbid_dismemberment
	description = "Ничто так не радует, как идеальное расчленение!"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/morbid_dissection_success
	description = "Я горжусь своей работой. Никто не сравнится со мной с препарированием тела."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/morbid_abominable_surgery_success
	description = "Даже сам Пикассо с трудом мог бы сравниться со мной своей кисточкой с тем, как я управляюсь с ножом."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/morbid_revival_success
	description = "ОНО ЖИВОЕ! АХ ХА ХА ХА ХА!!"
	mood_change = 6
	timeout = 8 MINUTES

/datum/mood_event/morbid_graverobbing
	description = "Мертвецам эти вещи не пригодятся. Я же, напротив, очень даже жив и очень даже нуждаюсь в них."
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/morbid_hauntium
	description = "Я чувствую более тесную связь с духами, мне нравится это!"
	mood_change = 3
	timeout = 6 MINUTES

/datum/mood_event/morbid_aquarium_good
	description = "Эхх, все рыбки спят..."
	mood_change = 3
	timeout = 90 SECONDS

// Negative Events - We helped someone stay alive.

/datum/mood_event/morbid_tend_wounds
	description = "Почему я должен тратить свой талант на эту пустяковую ерунду? Лечить живых - пустая трата сил."
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/morbid_saved_life
	description = "Я смог бы сделать гораздо большее с этим трупом, чем возвращать его к своей бесполезной жизни. Ужасно."
	mood_change = -6
	timeout = 2 MINUTES

/datum/mood_event/morbid_aquarium_bad
	description = "Наблюдать за живыми рыбками - мерзко."
	mood_change = -3
	timeout = 90 SECONDS
