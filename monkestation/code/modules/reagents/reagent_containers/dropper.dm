/obj/item/reagent_containers/dropper
	var/static/dropper_sounds = list(
		'monkestation/sound/chemistry/transfer/dropper1.ogg',
		'monkestation/sound/chemistry/transfer/dropper2.ogg',
	)

/obj/item/reagent_containers/dropper/proc/after_pour(trans, atom/transed_to, mob/user)
	playsound(get_turf(src), pick(dropper_sounds), 60, TRUE, use_reverb = TRUE)
