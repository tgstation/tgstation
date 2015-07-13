/obj/item/weapon/storage/book
	name = "hollowed book"
	desc = "I guess someone didn't like it."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	burn_state = 0 //Burnable
	var/title = "book"
/obj/item/weapon/storage/book/attack_self(mob/user)
		user << "<span class='notice'>The pages of [title] have been cut out!</span>"

/obj/item/weapon/storage/book/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon = 'icons/obj/storage.dmi'
	icon_state ="bible"
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/weapon/storage/book/bible/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is offering \himself to [src.deity_name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS)

/obj/item/weapon/storage/book/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

/obj/item/weapon/storage/book/bible/booze/New()
	..()
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	new /obj/item/stack/spacecash(src)
	new /obj/item/stack/spacecash(src)
	new /obj/item/stack/spacecash(src)

//Pretty bible names
var/global/list/biblenames =		list("Bible", "Quran", "Scrapbook", "Burning Bible", "Clown Bible", "Banana Bible", "Creeper Bible", "White Bible", "Holy Light", "The God Delusion", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "Melted Bible", "Necronomicon")

//Bible iconstates
var/global/list/biblestates =		list("bible", "koran", "scrapbook", "burning", "honk1", "honk2", "creeper", "white", "holylight", "atheist", "tome", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon")

//Bible itemstates
var/global/list/bibleitemstates =	list("bible", "koran", "scrapbook", "bible", "bible", "bible", "syringe_kit", "syringe_kit", "syringe_kit", "syringe_kit", "syringe_kit", "kingyellow", "ithaqua", "scientology", "melted", "necronomicon")



/obj/item/weapon/storage/book/bible/attack_self(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(ticker && !ticker.Bible_icon_state && H.job == "Chaplain")
		//Open bible selection
		var/dat = "<html><head><title>Pick Bible Style</title></head><body><center><h2>Pick a bible style</h2></center><table>"

		var/i
		for(i = 1, i < biblestates.len, i++)
			var/icon/bibleicon = icon('icons/obj/storage.dmi', biblestates[i])

			var/nicename = biblenames[i]
			H << browse_rsc(bibleicon, nicename)
			dat += {"<tr><td><img src="[nicename]"></td><td><a href="?src=\ref[src];seticon=[i]">[nicename]</a></td></tr>"}

		dat += "</table></body></html>"

		H << browse(dat, "window=editicon;can_close=0;can_minimize=0;size=250x650")

/obj/item/weapon/storage/book/bible/proc/setupbiblespecifics(var/obj/item/weapon/storage/book/bible/B, var/mob/living/carbon/human/H)
	switch(B.icon_state)
		if("honk1","honk2")
			new /obj/item/weapon/bikehorn(B)
			H.dna.add_mutation(CLOWNMUT)
			H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), slot_wear_mask)

		if("bible")
			for(var/area/chapel/main/A in world)
				for(var/turf/T in A.contents)
					if(T.icon_state == "carpetsymbol")
						T.dir = 2
		if("koran")
			for(var/area/chapel/main/A in world)
				for(var/turf/T in A.contents)
					if(T.icon_state == "carpetsymbol")
						T.dir = 4
		if("scientology")
			for(var/area/chapel/main/A in world)
				for(var/turf/T in A.contents)
					if(T.icon_state == "carpetsymbol")
						T.dir = 8
		if("athiest")
			for(var/area/chapel/main/A in world)
				for(var/turf/T in A.contents)
					if(T.icon_state == "carpetsymbol")
						T.dir = 10

/obj/item/weapon/storage/book/bible/Topic(href, href_list)
	if(href_list["seticon"])
		var/iconi = text2num(href_list["seticon"])

		var/biblename = biblenames[iconi]
		var/obj/item/weapon/storage/book/bible/B = locate(href_list["src"])

		B.icon_state = biblestates[iconi]
		B.item_state = bibleitemstates[iconi]

		//Set biblespecific chapels
		setupbiblespecifics(B, usr)

		if(ticker)
			ticker.Bible_icon_state = B.icon_state
			ticker.Bible_item_state = B.item_state
		feedback_set_details("religion_book","[biblename]")

		usr << browse(null, "window=editicon") // Close window

/obj/item/weapon/storage/book/bible/proc/bless(mob/living/carbon/M as mob)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 10
		for(var/obj/item/organ/limb/affecting in H.organs)
			if(affecting.status == ORGAN_ORGANIC) //No Bible can heal a robotic arm!
				if(affecting.heal_damage(heal_amt, heal_amt, 0))
					H.update_damage_overlays(0)
	return

/obj/item/weapon/storage/book/bible/attack(mob/living/M as mob, mob/living/carbon/human/user as mob)

	var/chaplain = 0
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		chaplain = 1



	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return
	if(!chaplain)
		user << "<span class='danger'>The book sizzles in your hands.</span>"
		user.take_organ_damage(0,10)
		return

	if (user.disabilities & CLUMSY && prob(50))
		user << "<span class='danger'>The [src] slips out of your hand and hits your head.</span>"
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

//	if(..() == BLOCKED)
//		return

	if (M.stat !=2)
		if(M.mind && (M.mind.assigned_role == "Chaplain"))
			user << "<span class='warning'>You can't heal yourself!</span>"
			return
		/*if((M.mind in ticker.mode.cult) && (prob(20)))
			M << "\red The power of [src.deity_name] clears your mind of heresy!"
			user << "\red You see how [M]'s eyes become clear, the cult no longer holds control over him!"
			ticker.mode.remove_cultist(M.mind)*/
		if ((istype(M, /mob/living/carbon/human) && prob(60)))
			bless(M)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/message_halt = 0
				for(var/obj/item/organ/limb/affecting in H.organs)
					if(affecting.status == ORGAN_ORGANIC)
						if(message_halt == 0)
							M.visible_message("<span class='notice'>[user] heals [M] with the power of [src.deity_name]!</span>")
							M << "<span class='boldnotice'>May the power of [src.deity_name] compel you to be healed!</span>"
							playsound(src.loc, "punch", 25, 1, -1)
							message_halt = 1
					else
						user << "<span class='warning'>[src.deity_name] refuses to heal this metallic taint!</span>"
						return




		else
			if(ishuman(M) && !istype(M:head, /obj/item/clothing/head/helmet))
				M.adjustBrainLoss(10)
				M << "<span class='danger'>You feel dumber.</span>"
			M.visible_message("<span class='danger'>[user] beats [M] over the head with [src]!</span>", \
					"<span class='userdanger'>[user] beats [M] over the head with [src]!</span>")
			playsound(src.loc, "punch", 25, 1, -1)
			add_logs(user, M, "attacked", src)

	else if(M.stat == 2)
		M.visible_message("<span class='danger'>[user] smacks [M]'s lifeless corpse with [src].</span>")
		playsound(src.loc, "punch", 25, 1, -1)
	return

/obj/item/weapon/storage/book/bible/afterattack(atom/A, mob/user as mob, proximity)
	if(!proximity)
		return
	if (istype(A, /turf/simulated/floor))
		user << "<span class='notice'>You hit the floor with the bible.</span>"
		if(user.mind && (user.mind.assigned_role == "Chaplain"))
			call(/obj/effect/rune/proc/revealrunes)(src)
	if(user.mind && (user.mind.assigned_role == "Chaplain"))
		if(A.reagents && A.reagents.has_reagent("water")) //blesses all the water in the holder
			user << "<span class='notice'>You bless [A].</span>"
			var/water2holy = A.reagents.get_reagent_amount("water")
			A.reagents.del_reagent("water")
			A.reagents.add_reagent("holywater",water2holy)
		if(A.reagents && A.reagents.has_reagent("unholywater")) //yeah yeah, copy pasted code - sue me
			user << "<span class='notice'>You purify [A].</span>"
			var/unholy2clean = A.reagents.get_reagent_amount("unholywater")
			A.reagents.del_reagent("unholywater")
			A.reagents.add_reagent("holywater",unholy2clean)

/obj/item/weapon/storage/book/bible/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	playsound(src.loc, "rustle", 50, 1, -5)
	..()
