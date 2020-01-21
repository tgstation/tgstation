/datum/job/mime
	title = "Mime"
	flag = MIME
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"

	outfit = /datum/outfit/job/mime

	access = list(ACCESS_THEATRE)
	minimal_access = list(ACCESS_THEATRE)
	paycheck = PAYCHECK_MINIMAL
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_MIME

/datum/job/mime/after_spawn(mob/living/carbon/human/H, mob/M)
	H.apply_pref_name("mime", M.client)

/datum/outfit/job/mime
	name = "Mime"
	jobtype = /datum/job/mime

	belt = /obj/item/pda/mime
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/civilian/mime
	mask = /obj/item/clothing/mask/gas/mime
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/frenchberet
	suit = /obj/item/clothing/suit/toggle/suspenders
	backpack_contents = list(/obj/item/book/mimery=1, /obj/item/reagent_containers/food/drinks/bottle/bottleofnothing=1)

	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime


/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = TRUE

/obj/item/book/mimery
	name = "Guide to Dank Mimery"
	desc = "A primer on basic pantomime."
	icon_state ="bookmime"

/obj/item/book/mimery/attack_self(mob/user,)
	user.set_machine(src)
	var/dat = "<B>Guide to Dank Mimery</B><BR>"
	dat += "Teaches one of three classic pantomime routines, allowing a practiced mime to conjure invisible objects into corporeal existence.<BR>"
	dat += "Once you have mastered your routine, this book will have no more to say to you.<BR>"
	dat += "<HR>"
	dat += "<A href='byond://?src=[REF(src)];invisible_wall=1'>Invisible Wall</A><BR>"
	dat += "<A href='byond://?src=[REF(src)];invisible_chair=1'>Invisible Chair</A><BR>"
	dat += "<A href='byond://?src=[REF(src)];invisible_box=1'>Invisible Box</A><BR>"
	user << browse(dat, "window=book")

/obj/item/book/mimery/Topic(href, href_list)
	..()
	if(!ishuman(usr) || loc != usr)
		return
	var/mob/living/carbon/human/human_user = usr
	if(!LIVING_CAN_USE_HANDS(human_user))
		return
	if(human_user.is_holding(src) && human_user.mind)
		human_user.set_machine(src)
		if (href_list["invisible_wall"])
			human_user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		if (href_list["invisible_chair"])
			human_user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_chair(null))
		if (href_list["invisible_box"])
			human_user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_box(null))
	to_chat(human_user, "<span class='notice'>The book disappears into thin air.</span>")
	qdel(src)
