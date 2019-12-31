/datum/game_mode/nuclear/mime_ops
	name = "mime ops"
	config_tag = "mimeops"

	announce_span = "danger"
	announce_text = "Mime empire forces are approaching the station in an attempt to silence it!\n\
	<span class='danger'>Operatives</span>: Secure the nuclear authentication disk and use your tranquillite fission explosive to silence the station.\n\
	<span class='notice'>Crew</span>: Defend the nuclear authentication disk and ensure that it leaves with you on the emergency shuttle."

	operative_antag_datum_type = /datum/antagonist/nukeop/mimeop
	leader_antag_datum_type = /datum/antagonist/nukeop/leader/mimeop

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/nuclear/mime_ops/pre_setup()
	. = ..()
	if(.)
		for(var/obj/machinery/nuclearbomb/syndicate/S in GLOB.nuke_list)
			var/turf/T = get_turf(S)
			if(T)
				qdel(S)
				new /obj/machinery/nuclearbomb/syndicate/tranquillite(T)
		for(var/V in pre_nukeops)
			var/datum/mind/the_op = V
			the_op.assigned_role = "Mime Operative"
			the_op.special_role = "Mime Operative"

/datum/outfit/syndicate/mimeop
	name = "Mime Operative - Basic"
	uniform = /obj/item/clothing/under/chameleon/mime
	suit = /obj/item/clothing/suit/chameleon/mime
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	mask = /obj/item/clothing/mask/chameleon/mime
	gloves = /obj/item/clothing/gloves/chameleon/mime
	head = /obj/item/clothing/head/chameleon/mime
	back = /obj/item/storage/backpack/chameleon/mime
	ears = /obj/item/radio/headset/chameleon
	l_pocket = /obj/item/pinpointer/nuke/syndicate
	r_pocket = /obj/item/pda/chameleon/mime
	id = /obj/item/card/id/syndicate
	backpack_contents = list(/obj/item/storage/box/survival/syndie=1, /obj/item/kitchen/knife/combat/survival, /obj/item/book/mimery/comprehensive, /obj/item/reagent_containers/food/drinks/bottle/bottleofnothing)

	uplink_type = /obj/item/uplink/mimeop

/datum/outfit/syndicate/mimeop/no_crystals
	tc = 0

/datum/outfit/syndicate/mimeop/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
	H.mind.miming = 1

/datum/outfit/syndicate/mimeop/leader
	name = "Mime Operative Leader - Basic"
	id = /obj/item/card/id/syndicate/nuke_leader
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	r_hand = /obj/item/nuclear_challenge/mimeops
	command_radio = TRUE

/obj/item/storage/box/syndie_kit/mimery/nuke/PopulateContents()
	new /obj/item/book/mimery/comprehensive(src)
	new /obj/item/book/granter/spell/mimery_blockade(src)
	new /obj/item/book/granter/spell/mimery_guns(src)

/obj/item/book/mimery/comprehensive
	name = "Comprehensive Guide to Dank Mimery"
	desc = "A comprehensive guide on basic pantomime."
	icon_state ="bookmime"

/obj/item/book/mimery/comprehensive/attack_self(mob/user,)
	user.set_machine(src)
	var/dat = "<B>Guide to Dank Mimery</B><BR>"
	dat += "Teaches you three classic pantomime routines, allowing a practiced mime to conjure invisible objects into corporeal existence.<BR>"
	dat += "This limited-edition book will allow you to learn all three basic routines, as well as a variety of powerful advanced techniques, if you so desire...<BR>"
	dat += "<HR>"
	dat += "<A href='byond://?src=[REF(src)];invisible_wall=1'>Invisible Wall</A><BR>"
	dat += "<A href='byond://?src=[REF(src)];invisible_chair=1'>Invisible Chair</A><BR>"
	dat += "<A href='byond://?src=[REF(src)];invisible_box=1'>Invisible Box</A><BR>"
	user << browse(dat, "window=book")

/obj/item/book/mimery/comprehensive/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained() || src.loc != usr)
		return
	if (!ishuman(usr))
		return
	var/mob/living/carbon/human/H = usr
	if(H.is_holding(src) && H.mind)
		H.set_machine(src)
		if (href_list["invisible_wall"])
			if(!locate(/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall) in H.mind.spell_list)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
				to_chat(usr, "<span class='notice'>You peruse the chapter on invisible walls.</span>")
			else
				to_chat(usr, "<span class='warning'>You've already read this chapter!</span>")
		if (href_list["invisible_chair"])
			if(!locate(/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair) in H.mind.spell_list)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair(null))
				to_chat(usr, "<span class='notice'>You carefully read the notes on chair conjuration.</span>")
			else
				to_chat(usr, "<span class='warning'>You've already read this chapter!</span>")
		if (href_list["invisible_box"])
			if(!locate(/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_box) in H.mind.spell_list)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_box(null))
				to_chat(usr, "<span class='notice'>You memorize the gestures for creating invisible boxes.</span>")
			else
				to_chat(usr, "<span class='warning'>You've already read this chapter!</span>")
		if (href_list["finger_gun"])
			if(!locate(/obj/effect/proc_holder/spell/aimed/finger_guns) in H.mind.spell_list)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/aimed/finger_guns(null))
				to_chat(usr, "<span class='notice'>You follow the diagram for flipping the safety on your finger gun.</span>")
			else
				to_chat(usr, "<span class='warning'>You've already read this chapter!</span>")



/obj/item/clothing/under/chameleon/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"

/obj/item/clothing/suit/chameleon/mime
	name = "suspenders"
	desc = "They suspend the illusion of the mime's play."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor"
	togglename = "straps"

/obj/item/clothing/head/chameleon/mime //Doesn't copy the speech changes because mime ops shouldn't be speaking anyway.
	name = "french beret"
	desc = "A quality beret, infused with the aroma of chain-smoking, wine-swilling Parisians. You feel less inclined to engage military conflict, for some reason."
	icon_state = "beret"
	dynamic_hair_suffix = ""

/obj/item/clothing/mask/chameleon/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"

/obj/item/clothing/gloves/chameleon/mime
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	item_state = "wgloves"

/obj/item/storage/backpack/chameleon/mime
	name = "Parcel Parceaux"
	desc = "A silent backpack made for those silent workers. Silence Co."
	icon_state = "mimepack"
	item_state = "mimepack"

/obj/item/pda/chameleon/mime
	name = "mime PDA"
	default_cartridge = /obj/item/cartridge/virus/mime
	inserted_item = /obj/item/toy/crayon/mime
	icon_state = "pda-mime"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The hardware has been modified for compliance with the vows of silence."
	allow_emojis = TRUE
	silent = TRUE
	ttone = "silence"

/obj/item/pda/chameleon/mime/msg_input(mob/living/U = usr)
	if(emped || toff)
		return
	var/emojis = emoji_sanitize(stripped_input(U, "Please enter emojis", name))
	if(!emojis)
		return
	if(!U.canUseTopic(src, BE_CLOSE))
		return
	return emojis