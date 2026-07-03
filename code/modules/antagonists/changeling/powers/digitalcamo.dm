/datum/action/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "Развивая способность искажать свою форму и пропорции, мы побеждаем обычные алгоритмы, используемые для обнаружения форм жизни на камерах."
	helptext = "При использовании этого навыка нас нельзя отследить с помощью камеры или увидеть с помощью ИИ. Однако люди, смотрящие на нас, будут находить нас... странными."
	button_icon_state = "digital_camo"
	category = "stealth"
	dna_cost = 1
	active = FALSE

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/datum/action/changeling/digitalcamo/sting_action(mob/user)
	..()
	if(active)
		to_chat(user, span_notice("Мы возвращаемся в нормальное состояние."))
		user.RemoveElement(/datum/element/digitalcamo)
	else
		to_chat(user, span_notice("Мы искажаем свою форму, чтобы скрыться от ИИ."))
		user.AddElement(/datum/element/digitalcamo)
	active = !active
	return TRUE

/datum/action/changeling/digitalcamo/Remove(mob/user)
	user.RemoveElement(/datum/element/digitalcamo)
	..()
