/obj/item/weapon/storage/book
	name = "hollowed book"
	desc = "I guess someone didn't like it."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	storage_slots = 1
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	var/title = "book"

/obj/item/weapon/storage/book/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")

GLOBAL_LIST_INIT(biblenames, list("Bible", "Quran", "Scrapbook", "Burning Bible", "Clown Bible", "Banana Bible", "Creeper Bible", "White Bible", "Holy Light",  "The God Delusion", "Tome",        "The King in Yellow", "Ithaqua", "Scientology", "Melted Bible", "Necronomicon"))
GLOBAL_LIST_INIT(biblestates, list("bible", "koran", "scrapbook", "burning",       "honk1",       "honk2",        "creeper",       "white",       "holylight",   "atheist",          "tome",        "kingyellow",         "ithaqua", "scientology", "melted",       "necronomicon"))
GLOBAL_LIST_INIT(bibleitemstates, list("bible", "koran", "scrapbook", "bible",         "bible",       "bible",        "syringe_kit",   "syringe_kit", "syringe_kit", "syringe_kit",      "syringe_kit", "kingyellow",         "ithaqua", "scientology", "melted",       "necronomicon"))

/obj/item/weapon/storage/book/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon = 'icons/obj/storage.dmi'
	icon_state = "bible"
	item_state = "bible"
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/weapon/storage/book/bible/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is offering [user.p_them()]self to [deity_name]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/weapon/storage/book/bible/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return
	// If H is the Chaplain, we can set the icon_state of the bible (but only once!)
	if(!SSreligion.bible_icon_state && H.job == "Chaplain")
		var/dat = "<html><head><title>Pick Bible Style</title></head><body><center><h2>Pick a bible style</h2></center><table>"
		for(var/i in 1 to GLOB.biblestates.len)
			var/icon/bibleicon = icon('icons/obj/storage.dmi', GLOB.biblestates[i])
			var/nicename = GLOB.biblenames[i]
			H << browse_rsc(bibleicon, nicename)
			dat += {"<tr><td><img src="[nicename]"></td><td><a href="?src=\ref[src];seticon=[i]">[nicename]</a></td></tr>"}
		dat += "</table></body></html>"
		H << browse(dat, "window=editicon;can_close=0;can_minimize=0;size=250x650")

/obj/item/weapon/storage/book/bible/Topic(href, href_list)
	if(!usr.canUseTopic(src))
		return
	if(href_list["seticon"] && SSreligion && !SSreligion.bible_icon_state)
		var/iconi = text2num(href_list["seticon"])
		var/biblename = GLOB.biblenames[iconi]
		var/obj/item/weapon/storage/book/bible/B = locate(href_list["src"])
		B.icon_state = GLOB.biblestates[iconi]
		B.item_state = GLOB.bibleitemstates[iconi]

		if(B.icon_state == "honk1" || B.icon_state == "honk2")
			var/mob/living/carbon/human/H = usr
			H.dna.add_mutation(CLOWNMUT)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)

		SSreligion.bible_icon_state = B.icon_state
		SSreligion.bible_item_state = B.item_state

		SSblackbox.set_details("religion_book","[biblename]")
		usr << browse(null, "window=editicon")

/obj/item/weapon/storage/book/bible/proc/bless(mob/living/carbon/human/H, mob/living/user)
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, "<span class='warning'>[src.deity_name] refuses to heal this metallic taint!</span>")
			return 0

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt))
				H.update_damage_overlays()
		H.visible_message("<span class='notice'>[user] heals [H] with the power of [deity_name]!</span>")
		to_chat(H, "<span class='boldnotice'>May the power of [deity_name] compel you to be healed!</span>")
		playsound(src.loc, "punch", 25, 1, -1)
	return 1

/obj/item/weapon/storage/book/bible/attack(mob/living/M, mob/living/carbon/human/user)

	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if (user.disabilities & CLUMSY && prob(50))
		to_chat(user, "<span class='danger'>[src] slips out of your hand and hits your head.</span>")
		user.take_bodypart_damage(10)
		user.Paralyse(20)
		return

	var/chaplain = 0
	if(user.mind && (user.mind.isholy))
		chaplain = 1

	if(!chaplain)
		to_chat(user, "<span class='danger'>The book sizzles in your hands.</span>")
		user.take_bodypart_damage(0,10)
		return

	var/smack = 1

	if (M.stat != DEAD)
		if(chaplain && user == M)
			to_chat(user, "<span class='warning'>You can't heal yourself!</span>")
			return

		if(ishuman(M) && prob(60) && bless(M, user))
			smack = 0
		else if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!istype(C.head, /obj/item/clothing/head/helmet))
				C.adjustBrainLoss(10)
				to_chat(C, "<span class='danger'>You feel dumber.</span>")

		if(smack)
			M.visible_message("<span class='danger'>[user] beats [M] over the head with [src]!</span>", \
					"<span class='userdanger'>[user] beats [M] over the head with [src]!</span>")
			playsound(src.loc, "punch", 25, 1, -1)
			add_logs(user, M, "attacked", src)

	else
		M.visible_message("<span class='danger'>[user] smacks [M]'s lifeless corpse with [src].</span>")
		playsound(src.loc, "punch", 25, 1, -1)

/obj/item/weapon/storage/book/bible/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(isfloorturf(A))
		to_chat(user, "<span class='notice'>You hit the floor with the bible.</span>")
		if(user.mind && (user.mind.isholy))
			for(var/obj/effect/rune/R in orange(2,user))
				R.invisibility = 0
	if(user.mind && (user.mind.isholy))
		if(A.reagents && A.reagents.has_reagent("water")) // blesses all the water in the holder
			to_chat(user, "<span class='notice'>You bless [A].</span>")
			var/water2holy = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			A.reagents.add_reagent("holywater",water2holy)
		if(A.reagents && A.reagents.has_reagent("unholywater")) // yeah yeah, copy pasted code - sue me
			to_chat(user, "<span class='notice'>You purify [A].</span>")
			var/unholy2clean = A.reagents.get_reagent_amount("unholywater")
			A.reagents.del_reagent("unholywater")
			A.reagents.add_reagent("holywater",unholy2clean)

/obj/item/weapon/storage/book/bible/booze
	desc = "To be applied to the head repeatedly."

/obj/item/weapon/storage/book/bible/booze/PopulateContents()
	new /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(src)
