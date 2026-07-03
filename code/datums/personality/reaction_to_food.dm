/datum/personality/ascetic
	savefile_key = "ascetic"
	name = "Аскетичный"
	desc = "Я не очень люблю изысканные блюда - все это только топливо для организма."
	pos_gameplay_desc = "Грусть от употребления нелюбимой еды уменьшена"
	neg_gameplay_desc = "Радость от поедания любимой еды ограничена"
	groups = list(PERSONALITY_GROUP_FOOD)

/datum/personality/gourmand
	savefile_key = "gourmand"
	name = "Гурман"
	desc = "Еда для меня — это всё!"
	pos_gameplay_desc = "Радость от поедания любимой еды усиливается"
	neg_gameplay_desc = "Грусть от съеденной нелюбимой пищи увеличивается, а обычная еда приносит меньше удовольствия"
	groups = list(PERSONALITY_GROUP_FOOD)

/datum/personality/teetotal
	savefile_key = "teetotal"
	name = "Трезвенник"
	desc = "Алкоголь не для меня."
	neg_gameplay_desc = "Не любит употреблять алкоголь"
	groups = list(PERSONALITY_GROUP_ALCOHOL)

/datum/personality/bibulous
	savefile_key = "bibulous"
	name = "Любитель выпить"
	desc = "Я всегда готов выпить ещё!"
	pos_gameplay_desc = "Удовлетворение от выпивки длится дольше, даже после того, как вы больше не пьяны"
	groups = list(PERSONALITY_GROUP_ALCOHOL)
