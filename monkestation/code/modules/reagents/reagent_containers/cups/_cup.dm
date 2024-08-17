/obj/item/reagent_containers/cup/Initialize(mapload, vol)
	. = ..()
	AddElement(/datum/element/trash_if_empty/reagent_container/if_prefilled)

/obj/item/reagent_containers/cup
	var/static/list/pouring_sounds_categorized = list(
		"0_10" = list(
			'monkestation/sound/chemistry/transfer/beakerpour_0-10-1.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_0-10-2.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_0-10-3.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_0-10-4.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_0-10-5.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_0-10-6.ogg',
		),
		"10_25" = list(
			'monkestation/sound/chemistry/transfer/beakerpour_10-25-1.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_10-25-2.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_10-25-3.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_10-25-5.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_10-25-6.ogg',
		),
		"25_50" = list(
			'monkestation/sound/chemistry/transfer/beakerpour_25-50-1.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_25-50-2.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_25-50-3.ogg',
		),
		"50_inf" = list(
			'monkestation/sound/chemistry/transfer/beakerpour_50-inf-1.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_50-inf-2.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_50-inf-3.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_50-inf-4.ogg',
			'monkestation/sound/chemistry/transfer/beakerpour_50-inf-5.ogg',
		),
	)
	var/static/list/rare_pouring_sound = list(
		"0_10" = 'monkestation/sound/chemistry/transfer/beakerpour_0-10-sparkle.ogg',
		"10_25" = 'monkestation/sound/chemistry/transfer/beakerpour_10-25-sparkle.ogg',
		"25_50" = 'monkestation/sound/chemistry/transfer/beakerpour_25-50-sparkle.ogg',
		"50_inf" = 'monkestation/sound/chemistry/transfer/beakerpour_50-inf-sparkle.ogg',
	)


/obj/item/reagent_containers/cup/proc/after_pour(trans, atom/transed_to, mob/user)
	var/sound = get_pouring_sound(trans)
	playsound(get_turf(src), sound, 60, TRUE, use_reverb = TRUE)

/obj/item/reagent_containers/cup/proc/get_pouring_sound(trans)
	var/pour_amount = "0_10"
	if(trans >= 50)
		pour_amount = "50_inf"
	else if(trans >= 25)
		pour_amount = "25_50"
	else if(trans >= 10)
		pour_amount = "10_25"

	return prob(1) ? rare_pouring_sound[pour_amount] : pick(pouring_sounds_categorized[pour_amount])
