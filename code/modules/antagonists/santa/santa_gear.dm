/datum/outfit/santa //ho ho ho!
	name = "Santa Claus"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/red
	suit = /obj/item/clothing/suit/space/santa
	head = /obj/item/clothing/head/santa
	back = /obj/item/storage/backpack/santabag
	r_pocket = /obj/item/flashlight
	gloves = /obj/item/clothing/gloves/color/red

	box = /obj/item/storage/box/survival/engineer
	backpack_contents = list(/obj/item/a_gift/anything = 5)

/datum/outfit/santa/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	H.fully_replace_character_name(H.real_name, "Santa Claus")
	H.mind.assigned_role = "Santa"
	H.mind.special_role = "Santa"

	H.hairstyle = "Long Hair 3"
	H.facial_hairstyle = "Beard (Full)"
	H.hair_color = "FFF"
	H.facial_hair_color = "FFF"
	H.update_hair()

	//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags_cover = HEADCOVERSEYES

	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	inhand_icon_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents

/obj/item/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver presents to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	inhand_icon_state = "giftbag"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/backpack/santabag/Initialize()
	. = ..()
	regenerate_presents()

/obj/item/storage/backpack/santabag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60

/obj/item/storage/backpack/santabag/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] places [src] over [user.p_their()] head and pulls it tight! It looks like [user.p_they()] [user.p_are()]n't in the Christmas spirit...</span>")
	return (OXYLOSS)

/obj/item/storage/backpack/santabag/proc/regenerate_presents()
	addtimer(CALLBACK(src, .proc/regenerate_presents), 30 SECONDS)

	var/mob/M = get(loc, /mob)
	if(!istype(M))
		return
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_CANNOT_OPEN_PRESENTS))
		var/datum/component/storage/STR = GetComponent(/datum/component/storage)
		var/turf/floor = get_turf(src)
		var/obj/item/I = new /obj/item/a_gift/anything(floor)
		if(STR.can_be_inserted(I, stop_messages=TRUE))
			STR.handle_item_insertion(I, prevent_warning=TRUE)
		else
			qdel(I)
