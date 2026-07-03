/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "Мысли о насилии вызывают у вас тошноту. Настолько, что вы не можете причинить никому вреда."
	icon = FA_ICON_PEACE
	value = -8
	mob_trait = TRAIT_PACIFISM
	gain_text = span_danger("Вы чувствуете, как любая мысль о насилии отвращает вас!")
	lose_text = span_notice("Кажется, вы уже и не такой беззащитный и можете дать отпор, как раньше.")
	medical_record_text = "Пациент необычайно пацифичен и не может заставить себя причинить физический вред кому-либо."
	hardcore_value = 6
	mail_goodies = list(/obj/effect/spawner/random/decoration/flower, /obj/effect/spawner/random/contraband/cannabis) // flower power
