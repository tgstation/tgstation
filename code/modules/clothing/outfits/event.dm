/datum/outfit/santa //ho ho ho!
	name = "Santa Claus"

	uniform = /obj/item/clothing/under/color/red
	suit = /obj/item/clothing/suit/space/santa
	back = /obj/item/storage/backpack/santabag
	backpack_contents = list(
		/obj/item/gift/anything = 5,
	)
	gloves = /obj/item/clothing/gloves/color/red
	head = /obj/item/clothing/head/helmet/space/santahat/beardless
	shoes = /obj/item/clothing/shoes/sneakers/red
	r_pocket = /obj/item/flashlight

	box = /obj/item/storage/box/survival/engineer

/datum/outfit/santa/post_equip(mob/living/carbon/human/user, visualsOnly = FALSE)
	if(visualsOnly)
		return
	user.fully_replace_character_name(user.real_name, "Santa Claus")
	user.mind.set_assigned_role(SSjob.get_job_type(/datum/job/santa))
	user.mind.special_role = ROLE_SANTA

	user.hairstyle = "Long Hair 3"
	user.facial_hairstyle = "Beard (Full)"
	user.hair_color = COLOR_WHITE
	user.facial_hair_color = COLOR_WHITE
	user.update_body_parts(update_limb_data = TRUE)
