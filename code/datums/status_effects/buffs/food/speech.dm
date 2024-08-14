///Temporary modifies the speech using the /datum/component/speechmod
/datum/status_effect/food/speech

/datum/status_effect/food/speech/italian
	alert_type = /atom/movable/screen/alert/status_effect/italian_speech

/datum/status_effect/food/speech/italian/on_apply()
	AddComponent( \
		/datum/component/speechmod, \
		replacements = strings("italian_replacement.json", "italian"), \
		end_string = list(
			" Ravioli, ravioli, give me the formuoli!",
			" Mamma-mia!",
			" Mamma-mia! That's a spicy meat-ball!",
			" La la la la la funiculi funicula!"
			), \
		end_string_chance = 3 \
		)
	return ..()

/atom/movable/screen/alert/status_effect/italian_speech
	name = "Linguini Embrace"
	desc = "You feel a sudden urge to gesticulate wildly."
	icon_state = "food_italian"

/datum/status_effect/food/speech/french
	alert_type = /atom/movable/screen/alert/status_effect/french_speech

/datum/status_effect/food/speech/french/on_apply()
	AddComponent( \
		/datum/component/speechmod, \
		replacements = strings("french_replacement.json", "french"), \
		end_string = list(
			" Honh honh honh!",
			" Honh!",
			" Zut Alors!"
			), \
		end_string_chance = 3, \
		)
	return ..()

/atom/movable/screen/alert/status_effect/french_speech
	name = "Café Chic"
	desc = "Suddenly, everything seems worthy of a passionate debate."
	icon_state = "food_french"
