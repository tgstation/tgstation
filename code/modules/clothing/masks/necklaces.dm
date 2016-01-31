/obj/item/clothing/mask/necklace
	body_parts_covered = 0

/obj/item/clothing/mask/necklace/xeno_claw
	name = "xeno necklace"
	desc = "A necklace made out of some cable coils and a xenomorph's claws."
	icon_state = "xeno_necklace"

/obj/item/clothing/mask/necklace/teeth
	name = "teeth necklace"
	desc = "A necklace made out of a bunch of teeth."
	icon_state = "tooth-necklace"

	var/mob/animal_type
	var/teeth_amount = 10

/obj/item/clothing/mask/necklace/teeth/attackby(obj/item/W, mob/user)
	.=..()

	if(istype(W, /obj/item/stack/teeth))
		var/obj/item/stack/teeth/T = W
		if(T.animal_type != src.animal_type) //If the teeth came from a different animal, fuck off
			return

		src.teeth_amount += T.amount
		update_name()
		to_chat(user, "<span class='info'>You add [T.amount] [T] to \the [src].</span>")
		T.use(T.amount)

/obj/item/clothing/mask/necklace/teeth/proc/update_name()
	var/animal_name = "teeth"
	if(animal_type)
		if(ispath(animal_type, /mob/living/carbon/human))
			animal_name = "human teeth"
			if(animal_type == /mob/living/carbon/human/skellington)
				animal_name = "skellington teeth"
			if(animal_type == /mob/living/carbon/human/tajaran)
				animal_name = "tajaran teeth"
		else
			animal_name = "[initial(animal_type.name)] teeth"

	var/prefix = ""
	if(teeth_amount >= 20)
		prefix = "fine "
	if(teeth_amount >= 35)
		prefix = "well-made "
	if(teeth_amount >= 50)
		prefix = "masterwork "
	if(teeth_amount >= 100)
		prefix = "legendary "

	name = "[prefix][animal_name] necklace"
	desc = "A necklace made out of [teeth_amount] [animal_name]."
