/obj/item/clothing/mask/stone
	name = "stone mask"
	desc = "An old, cracked stone mask. Its mouth seems to sport a pair of fangs."
	icon_state = "stone"
	item_state = "stone"
	flags = FPRINT
	body_parts_covered = FACE
	w_class = 2
	siemens_coefficient = 0 //it's made of stone, after all
	unacidable = 1
	var/spikes_out = 0 //whether the spikes are extended
	var/infinite = 0 //by default the mask is destroyed after one use
	var/blood_to_give = 300 //seeing as the new vampire won't have had a whole round to prepare, they get some blood free

/obj/item/clothing/mask/stone/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	if(spikes_out)
		to_chat(M, "<span class='warning'>You can't get the mask over your face with its stone spikes in the way!</span>")
		return CANNOT_EQUIP
	else
		if(!istype(M, /mob/living/carbon/human))
			to_chat(M, "<span class='warning'>You can't seem to get the mask to fit correctly over your face.</span>")
			return CANNOT_EQUIP
		else
			return ..()

/obj/item/clothing/mask/stone/equipped(mob/M as mob, wear_mask)
	if(!istype(M, /mob/living/carbon/human)) //just in case a non-human somehow manages to equip it
		forceMove(M.loc)

/obj/item/clothing/mask/stone/proc/spikes()
	icon_state = "stone_spikes"
	spikes_out = 1
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		H.visible_message("<span class='warning'>Stone spikes shoot out from the sides of \the [src]!</span>")
		if(H.wear_mask == src) //the mob is wearing this mask
			if(H.mind)
				var/datum/mind/M = H.mind
				if(!isvampire(H)) //They are not already a vampire
					to_chat(H, "<span class='danger'>The mask's stone spikes pierce your skull and enter your brain!</span>")
					M.make_new_vampire()
					log_admin("[H] has become a vampire using a stone mask.")
					H.mind.vampire.bloodtotal = blood_to_give
					H.mind.vampire.bloodusable = blood_to_give
					to_chat(H, "<span class='notice'>You have accumulated [H.mind.vampire.bloodtotal] [H.mind.vampire.bloodtotal > 1 ? "units" : "unit"] of blood and have [H.mind.vampire.bloodusable] left to use.</span>")
					H.check_vampire_upgrade(H.mind)
					if(!infinite)
						crumble()
						return
				else
					to_chat(H, "<span class='notice'>The stone spikes pierce your skull, but nothing happens. Perhaps vampires cannot benefit further from use of the mask.</span>")
	else
		visible_message("<span class='warning'>Stone spikes shoot out from the sides of \the [src]!</span>")
	sleep(10)
	spikes_out = 0
	if(istype(loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = loc
		H.visible_message("<span class='notice'>\The [src]'s stone spikes retract back into itself.</span>")
	else
		visible_message("<span class='notice'>\The [src]'s stone spikes retract back into itself.</span>")
	icon_state = initial(icon_state)

/obj/item/clothing/mask/stone/proc/crumble()
	if(istype(loc, /mob/living))
		loc.visible_message("<span class='info'>\The [src] crumbles into dust...</span>")
	else
		visible_message("<span class='info'>\The [src] crumbles into dust...</span>")
	qdel(src)

/obj/item/clothing/mask/stone/infinite //this mask can be used any number of times
	infinite = 1
