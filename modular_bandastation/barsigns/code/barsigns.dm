/obj/machinery/barsign/set_sign(datum/barsign/sign)
	if(!istype(sign))
		return
	if(initial(sign.ss220_icon))
		icon = initial(sign.ss220_icon)
	else
		icon = initial(icon)
	. = ..()

/datum/barsign
	var/ss220_icon

/datum/barsign/evahumanspace
	name = "SS220 EVA Human in Space"
	icon_state = "evahumanspace"
	desc = "Безопасность - это привелегия."
	ss220_icon = 'modular_bandastation/barsigns/icons/barsigns.dmi'

/datum/barsign/warpsurf
	name = "SS220 Warp Surf"
	icon_state = "warpsurf"
	desc = "Welcome to the club, buddy!"
	ss220_icon = 'modular_bandastation/barsigns/icons/barsigns.dmi'

/datum/barsign/papacafe
	name = "SS220 Space Daddy's Cafe"
	icon_state = "papacafe"
	desc = "Уважай своего Космического Папу!"
	ss220_icon = 'modular_bandastation/barsigns/icons/barsigns.dmi'

/datum/barsign/wycctide
	name = "SS220 Wycctide"
	icon_state = "wycctide"
	desc = "О нет, он близится!"
	ss220_icon = 'modular_bandastation/barsigns/icons/barsigns.dmi'

/datum/barsign/shitcur
	name = "SS220 Shitcur"
	icon_state = "shitcur"
	desc = "Невиновность ничего не доказывает."
	ss220_icon = 'modular_bandastation/barsigns/icons/barsigns.dmi'

/datum/barsign/pourndot
	name = "SS220 Pour and that's it"
	icon_state = "pourndot"
	desc = "Нальют и Точка. Тяжёлые времена приближаются."
	ss220_icon = 'modular_bandastation/barsigns/icons/barsigns.dmi'

/datum/barsign/moonipub
	name = "SS220 Mooniverse pub"
	icon_state = "mooni"
	desc = "Совершенно новый паб."
	ss220_icon = 'modular_bandastation/barsigns/icons/barsigns.dmi'
