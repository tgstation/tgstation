/obj/inject_the_memes_daddy
	name = "inject me"
	desc = "all night long"
	var/test_int = 69
	var/test_float = 0.5
	var/test_string = "god made tomorrow for the crooks we can't catch today"
	var/list/test_list = list(1,2,4,8,16,32)
	var/list/test_assoc = list("aaaugh" = 1, "i neeeeeed" = 2, "a medic baaaaagh" = 3)
	var/datum/test_datum_memes/test_datum_ref

/obj/inject_the_memes_daddy/New()
	..()
	test_datum_ref = new /datum/test_datum_memes()
	test_datum_ref.stacys_mom_has_got_it_going_on = src


/datum/test_datum_memes
	var/name = "porno for pyros"
	var/description = "it was me DIO"
	var/obj/inject_the_memes_daddy/stacys_mom_has_got_it_going_on
