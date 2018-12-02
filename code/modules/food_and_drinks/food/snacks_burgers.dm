/obj/item/reagent_containers/food/snacks/burger
	filling_color = "#CD853F"
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "hburger"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "vitamin" = 1)
	tastes = list("bun" = 4)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/plain
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	bonus_reagents = list("vitamin" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/plain/Initialize()
	. = ..()
	if(prob(1))
		new/obj/effect/particle_effect/smoke(get_turf(src))
		playsound(src, 'sound/effects/smoke.ogg', 50, TRUE)
		visible_message("<span class='warning'>Oh, ye gods! [src] is ruined! But what if...?</span>")
		name = "steamed ham"
		desc = pick("Ahh, Head of Personnel, welcome. I hope you're prepared for an unforgettable luncheon!",
		"And you call these steamed hams despite the fact that they are obviously microwaved?",
		"Aurora Station 13? At this time of shift, in this time of year, in this sector of space, localized entirely within your freezer?",
		"You know, these hamburgers taste quite similar to the ones they have at the Maltese Falcon.")
		tastes = list("fast food hamburger" = 1)

/obj/item/reagent_containers/food/snacks/burger/human
	var/subjectname = ""
	var/subjectjob = null
	name = "human burger"
	desc = "A bloody burger."
	bonus_reagents = list("vitamin" = 4)
	foodtype = MEAT | GRAIN | GROSS

/obj/item/reagent_containers/food/snacks/burger/human/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/food/snacks/meat/M = locate(/obj/item/reagent_containers/food/snacks/meat/steak/plain/human) in contents
	if(M)
		subjectname = M.subjectname
		subjectjob = M.subjectjob
		if(subjectname)
			name = "[subjectname] burger"
		else if(subjectjob)
			name = "[subjectjob] burger"
		qdel(M)


/obj/item/reagent_containers/food/snacks/burger/corgi
	name = "corgi burger"
	desc = "You monster."
	bonus_reagents = list("vitamin" = 1)
	foodtype = GRAIN | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/burger/appendix
	name = "appendix burger"
	desc = "Tastes like appendicitis."
	bonus_reagents = list("nutriment" = 6, "vitamin" = 6)
	icon_state = "appendixburger"
	tastes = list("bun" = 4, "grass" = 2)
	foodtype = GRAIN | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/burger/fish
	name = "fillet -o- carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 3)
	tastes = list("bun" = 4, "fish" = 4)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/tofu
	name = "tofu burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 2)
	tastes = list("bun" = 4, "tofu" = 4)
	foodtype = GRAIN | VEGETABLES

/obj/item/reagent_containers/food/snacks/burger/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	bonus_reagents = list("nutriment" = 2, "nanomachines" = 2, "vitamin" = 5)
	list_reagents = list("nutriment" = 6, "nanomachines" = 5, "vitamin" = 1)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/burger/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	volume = 120
	bonus_reagents = list("nutriment" = 5, "nanomachines" = 70, "vitamin" = 10)
	list_reagents = list("nutriment" = 6, "nanomachines" = 70, "vitamin" = 5)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/burger/xeno
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 6)
	tastes = list("bun" = 4, "acid" = 4)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/bearger
	name = "bearger"
	desc = "Best served rawr."
	icon_state = "bearger"
	bonus_reagents = list("nutriment" = 3, "vitamin" = 6)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/clown
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 6, "banana" = 6)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/burger/mime
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 6, "nothing" = 6)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/burger/brain
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	bonus_reagents = list("nutriment" = 6, "mannitol" = 6, "vitamin" = 5)
	list_reagents = list("nutriment" = 6, "mannitol" = 5, "vitamin" = 1)
	tastes = list("bun" = 4, "brains" = 2)
	foodtype = GRAIN | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/burger/ghost
	name = "ghost burger"
	desc = "Too Spooky!"
	alpha = 125
	bonus_reagents = list("nutriment" = 5, "vitamin" = 12)
	tastes = list("bun" = 4, "ectoplasm" = 2)
	foodtype = GRAIN

/obj/item/reagent_containers/food/snacks/burger/red
	name = "red burger"
	desc = "Perfect for hiding the fact it's burnt to a crisp."
	icon_state = "cburger"
	color = "#DA0000FF"
	bonus_reagents = list("redcrayonpowder" = 10, "vitamin" = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/orange
	name = "orange burger"
	desc = "Contains 0% juice."
	icon_state = "cburger"
	color = "#FF9300FF"
	bonus_reagents = list("orangecrayonpowder" = 10, "vitamin" = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/yellow
	name = "yellow burger"
	desc = "Bright to the last bite."
	icon_state = "cburger"
	color = "#FFF200FF"
	bonus_reagents = list("yellowcrayonpowder" = 10, "vitamin" = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/green
	name = "green burger"
	desc = "It's not tainted meat, it's painted meat!"
	icon_state = "cburger"
	color = "#A8E61DFF"
	bonus_reagents = list("greencrayonpowder" = 10, "vitamin" = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/blue
	name = "blue burger"
	desc = "Is this blue rare?"
	icon_state = "cburger"
	color = "#00B7EFFF"
	bonus_reagents = list("bluecrayonpowder" = 10, "vitamin" = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/purple
	name = "purple burger"
	desc = "Regal and low class at the same time."
	icon_state = "cburger"
	color = "#DA00FFFF"
	bonus_reagents = list("purplecrayonpowder" = 10, "vitamin" = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/black
	name = "black burger"
	desc = "This is overcooked."
	icon_state = "cburger"
	color = "#1C1C1C"
	bonus_reagents = list("blackcrayonpowder" = 10, "vitamin" = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/white
	name = "white burger"
	desc = "Delicous Titanium!"
	icon_state = "cburger"
	color = "#FFFFFF"
	bonus_reagents = list("whitecrayonpowder" = 10, "vitamin" = 5)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/spell
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	bonus_reagents = list("nutriment" = 6, "vitamin" = 10)
	tastes = list("bun" = 4, "magic" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/bigbite
	name = "big bite burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	bonus_reagents = list("vitamin" = 6)
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	w_class = WEIGHT_CLASS_NORMAL
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/jelly
	name = "jelly burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	tastes = list("bun" = 4, "jelly" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/jelly/slime
	bonus_reagents = list("slimejelly" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 6, "slimejelly" = 5, "vitamin" = 1)
	foodtype = GRAIN | TOXIC

/obj/item/reagent_containers/food/snacks/burger/jelly/cherry
	bonus_reagents = list("cherryjelly" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 6, "cherryjelly" = 5, "vitamin" = 1)
	foodtype = GRAIN | FRUIT

/obj/item/reagent_containers/food/snacks/burger/superbite
	name = "super bite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	bonus_reagents = list("vitamin" = 10)
	list_reagents = list("nutriment" = 40, "vitamin" = 5)
	w_class = WEIGHT_CLASS_NORMAL
	bitesize = 7
	volume = 100
	tastes = list("bun" = 4, "type two diabetes" = 10)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/fivealarm
	name = "five alarm burger"
	desc = "HOT! HOT!"
	icon_state = "fivealarmburger"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 5)
	list_reagents = list("nutriment" = 6, "capsaicin" = 5, "condensedcapsaicin" = 5, "vitamin" = 1)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/rat
	name = "rat burger"
	desc = "Pretty much what you'd expect..."
	icon_state = "ratburger"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	foodtype = GRAIN | MEAT | GROSS

/obj/item/reagent_containers/food/snacks/burger/baseball
	name = "home run baseball burger"
	desc = "It's still warm. The steam coming off of it looks like baseball."
	icon_state = "baseball"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	foodtype = GRAIN | GROSS

/obj/item/reagent_containers/food/snacks/burger/baconburger
	name = "bacon burger"
	desc = "The perfect combination of all things American."
	icon_state = "baconburger"
	bonus_reagents = list("nutriment" = 8, "vitamin" = 1)
	tastes = list("bun" = 4, "bacon" = 2)
	foodtype = GRAIN | MEAT

/obj/item/reagent_containers/food/snacks/burger/empoweredburger
	name = "empowered burger"
	desc = "It's shockingly good, if you live off of electricity that is."
	icon_state = "empoweredburger"
	list_reagents = list("nutriment" = 8, "liquidelectricity" = 5)
	tastes = list("bun" = 2, "pure electricity" = 4)
	foodtype = GRAIN | TOXIC