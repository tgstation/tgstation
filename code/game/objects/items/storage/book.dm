/obj/item/storage/book
	name = "hollowed book"
	desc = "I guess someone didn't like it."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	var/title = "book"

/obj/item/storage/book/ComponentInitialize()
	. = ..()
	GET_COMPONENT(STR, /datum/component/storage)
	STR.max_items = 1

/obj/item/storage/book/attack_self(mob/user)
	to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")

GLOBAL_LIST_INIT(biblenames, list("Bible", "Quran", "Scrapbook", "Burning Bible", "Clown Bible", "Banana Bible", "Creeper Bible", "White Bible", "Holy Light",  "The God Delusion", "Tome",        "The King in Yellow", "Ithaqua", "Scientology", "Melted Bible", "Necronomicon"))
GLOBAL_LIST_INIT(biblestates, list("bible", "koran", "scrapbook", "burning",       "honk1",       "honk2",        "creeper",       "white",       "holylight",   "atheist",          "tome",        "kingyellow",         "ithaqua", "scientology", "melted",       "necronomicon"))
GLOBAL_LIST_INIT(bibleitemstates, list("bible", "koran", "scrapbook", "bible",         "bible",       "bible",        "syringe_kit",   "syringe_kit", "syringe_kit", "syringe_kit",      "syringe_kit", "kingyellow",         "ithaqua", "scientology", "melted",       "necronomicon"))

/mob/proc/bible_check() //The bible, if held, might protect against certain things
	var/obj/item/storage/book/bible/B = locate() in src
	if(is_holding(B))
		return B
	return 0

/obj/item/storage/book/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon = 'icons/obj/storage.dmi'
	icon_state = "bible"
	item_state = "bible"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	var/mob/affecting = null
	var/deity_name = "Christ"
	force_string = "holy"

/obj/item/storage/book/bible/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, FALSE, TRUE)

/obj/item/storage/book/bible/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is offering [user.p_them()]self to [deity_name]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/storage/book/bible/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return
	// If H is the Chaplain, we can set the icon_state of the bible (but only once!)
	if(!SSreligion.bible_icon_state && H.job == "Chaplain")
		var/dat = "<html><head><title>Pick Bible Style</title></head><body><center><h2>Pick a bible style</h2></center><table>"
		for(var/i in 1 to GLOB.biblestates.len)
			var/icon/bibleicon = icon('icons/obj/storage.dmi', GLOB.biblestates[i])
			var/nicename = GLOB.biblenames[i]
			H << browse_rsc(bibleicon, nicename)
			dat += {"<tr><td><img src="[nicename]"></td><td><a href="?src=[REF(src)];seticon=[i]">[nicename]</a></td></tr>"}
		dat += "</table></body></html>"
		H << browse(dat, "window=editicon;can_close=0;can_minimize=0;size=250x650")

/obj/item/storage/book/bible/Topic(href, href_list)
	if(!usr.canUseTopic(src))
		return
	if(href_list["seticon"] && SSreligion && !SSreligion.bible_icon_state)
		var/iconi = text2num(href_list["seticon"])
		var/biblename = GLOB.biblenames[iconi]
		var/obj/item/storage/book/bible/B = locate(href_list["src"])
		B.icon_state = GLOB.biblestates[iconi]
		B.item_state = GLOB.bibleitemstates[iconi]

		if(B.icon_state == "honk1" || B.icon_state == "honk2")
			var/mob/living/carbon/human/H = usr
			H.dna.add_mutation(CLOWNMUT)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_WEAR_MASK)

		SSreligion.bible_icon_state = B.icon_state
		SSreligion.bible_item_state = B.item_state

		SSblackbox.record_feedback("text", "religion_book", 1, "[biblename]")
		usr << browse(null, "window=editicon")

/obj/item/storage/book/bible/proc/bless(mob/living/carbon/human/H, mob/living/user)
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
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return 1

/obj/item/storage/book/bible/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)

	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if (user.has_trait(TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='danger'>[src] slips out of your hand and hits your head.</span>")
		user.take_bodypart_damage(10)
		user.Unconscious(400)
		return

	var/chaplain = 0
	if(user.mind && (user.mind.isholy))
		chaplain = 1

	if(!chaplain)
		to_chat(user, "<span class='danger'>The book sizzles in your hands.</span>")
		user.take_bodypart_damage(0,10)
		return

	if (!heal_mode)
		return ..()

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
				C.adjustBrainLoss(5, 60)
				to_chat(C, "<span class='danger'>You feel dumber.</span>")

		if(smack)
			M.visible_message("<span class='danger'>[user] beats [M] over the head with [src]!</span>", \
					"<span class='userdanger'>[user] beats [M] over the head with [src]!</span>")
			playsound(src.loc, "punch", 25, 1, -1)
			log_combat(user, M, "attacked", src)

	else
		M.visible_message("<span class='danger'>[user] smacks [M]'s lifeless corpse with [src].</span>")
		playsound(src.loc, "punch", 25, 1, -1)

/obj/item/storage/book/bible/afterattack(atom/A, mob/user, proximity)
	. = ..()
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
	if(istype(A, /obj/item/twohanded/required/cult_bastard) && !iscultist(user))
		var/obj/item/twohanded/required/cult_bastard/sword = A
		to_chat(user, "<span class='notice'>You begin to exorcise [sword].</span>")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,1)
		if(do_after(user, 40, target = sword))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,1)
			for(var/obj/item/soulstone/SS in sword.contents)
				SS.usability = TRUE
				for(var/mob/living/simple_animal/shade/EX in SS)
					SSticker.mode.remove_cultist(EX.mind, 1, 0)
					EX.icon_state = "ghost1"
					EX.name = "Purified [EX.name]"
				SS.release_shades(user)
				qdel(SS)
			new /obj/item/nullrod/claymore(get_turf(sword))
			user.visible_message("<span class='notice'>[user] has purified the [sword]!!</span>")
			qdel(sword)

	else if(istype(A, /obj/item/soulstone) && !iscultist(user))
		var/obj/item/soulstone/SS = A
		to_chat(user, "<span class='notice'>You begin to exorcise [SS].</span>")
		playsound(src,'sound/hallucinations/veryfar_noise.ogg',40,1)
		if(do_after(user, 40, user = SS))
			playsound(src,'sound/effects/pray_chaplain.ogg',60,1)
			SS.usability = TRUE
			for(var/mob/living/simple_animal/shade/EX in SS)
				SSticker.mode.remove_cultist(EX.mind, 1, 0)
				EX.icon_state = "ghost1"
				EX.name = "Purified [EX.name]"
				SS.release_shades(user)
			user.visible_message("<span class='notice'>[user] has purified the [SS]!!</span>")
			qdel(SS)

/obj/item/storage/book/bible/booze
	desc = "To be applied to the head repeatedly."

/obj/item/storage/book/bible/booze/PopulateContents()
	new /obj/item/reagent_containers/food/drinks/bottle/whiskey(src)

/obj/item/storage/book/bible/syndicate
	icon_state ="ebook"
	deity_name = "The Syndicate"
	throw_speed = 2
	throwforce = 18
	throw_range = 7
	force = 18
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	name = "Syndicate Tome"
	attack_verb = list("attacked", "burned", "blessed", "damned", "scorched")
	var/uses = 1

/obj/item/storage/book/bible/syndicate/attack_self(mob/living/carbon/human/H)
	if (uses)
		H.mind.isholy = TRUE
		uses -= 1
		to_chat(H, "<span class='userdanger'>You try to open the book AND IT BITES YOU!</span>")
		playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
		H.apply_damage(5, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		to_chat(H, "<span class='notice'>Your name appears on the inside cover, in blood.</span>")
		var/ownername = H.real_name
		desc += "<span class='warning'>The name [ownername] is written in blood inside the cover.</span>"

/obj/item/storage/book/bible/syndicate/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)
	if (user.a_intent == INTENT_HELP)
		return ..()
	else
		return ..(M,user,heal_mode = FALSE)

/obj/item/storage/book/bible/syndicate/add_blood_DNA(list/blood_dna)
	return FALSE
