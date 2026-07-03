/mob/living/proc/judo_help()
	set name = "Вспомнить основы"
	set desc = "Вы взываете к техникам корпоратского дзюдо."
	set category = "Judo"

	var/list/message = list()
	message += span_bolditalic("Вы взываете к техникам корпоратского дзюдо.")
	message += "[span_notice("Бросок")]: Grab Shove. Возьмите врага в захват и бросьте на пол. Наносит урон стамине."
	message += "[span_notice("Большое колесо")]: Grab Shove Punch. Перекиньте противника, захваченного 'рычагом', через себя или прижмите его к полу."
	message += "[span_notice("Тычок в глаза")]: Shove Punch. Ударьте противника в глаза, мгновенно ослепляя его."
	message += "[span_notice("Рычаг")]: Shove Shove Grab. Возьмите лежащего противника в захват."
	message += "[span_notice("Золотой взрыв")]: Help Shove Help Grab Shove Shove Grab Help Shove Shove Grab Help. Используя боевые искусства, вы можете оглушить противника жизненной энергией. Или перегрузив наниты пояса."
	message += "[span_notice("Сбить с толку")]: Нанесите противнику удар по уху, ненадолго сбив его с толку."

	to_chat(usr, message.Join("\n"))
