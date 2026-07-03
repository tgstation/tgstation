/obj/item/clothing/shoes/greaves_of_the_prophet
	name = "\improper Joint-snap sabatons"
	desc = "Сабатоны, сделанные из грубого, изношенного железа. По ощущениям они более устойчивы, чем земля, по которой они ступают. Их покрывает тонкий слой ржавчины - и всё же при виде их вас охватывает неожиданное чувство покоя."
	icon_state = "hereticgreaves"
	resistance_flags = ACID_PROOF | FIRE_PROOF | LAVA_PROOF

/obj/item/clothing/shoes/greaves_of_the_prophet/Initialize(mapload)
	. = ..()
	attach_clothing_traits(list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NO_SLIP_ALL))
