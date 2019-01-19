/datum/mutation/human/cryokinesis
	name = "Cryokinesis"
	desc = "Allows the user to concentrate moisture and sub-zero forces into a snowball."
	quality = POSITIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>Your hand feels cold.</span>"
	instability = 10
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/snowball

/obj/effect/proc_holder/spell/targeted/conjure_item/snowball
	name = "Create Snowball"
	desc = "Concentrates cryokinetic forces to create a snowball, or recall a previous snowball."
	item_type = /obj/item/toy/snowball
	charge_max = 100

/datum/mutation/human/gelidakinesis
	name = "Psychokinetic Gelidakinesis"
	desc = "Draws negative energy from the sub-zero void to freeze surrounding temperatures at will."
	quality = POSITIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>Your hand feels cold.</span>"
	instability = 10
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/snowball