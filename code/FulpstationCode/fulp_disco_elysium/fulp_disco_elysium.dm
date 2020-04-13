/obj/machinery/vending/dic
	name = "\improper DicTech"
	desc = "A fashion and essentials vendor for the discerning detective."
	product_ads = "Just one more question: Are you ready to look swag?; Upgrade your LA Noir threads today!;Evidence bags? Cigs? Matches? We got it all!;Get your fix of cheap cigs and burnt coffee!;Stogies here to complete that classic noir look!;Stylish apparel here! Crack your case in style!;Fedoras for her tipping pleasure.;Why not have a donut?"
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "det"
	icon_deny = "det-deny"
	req_access = list(ACCESS_SEC_DOORS, ACCESS_FORENSICS_LOCKERS)
	products = list(/obj/item/clothing/suit/det_suit/disco = 4,
					/obj/item/clothing/suit/det_suit/disco/aerostatic = 4,
					/obj/item/clothing/under/rank/security/detective/disco = 4,
					/obj/item/clothing/under/rank/security/detective/disco/aerostatic = 4,
					/obj/item/clothing/neck/tie/detective/disco_necktie = 4,
					/obj/item/clothing/gloves/color/black/aerostatic_gloves = 4,
					/obj/item/clothing/shoes/sneakers/disco = 4,
					/obj/item/clothing/shoes/jackboots/aerostatic = 4,
					/obj/item/clothing/glasses/sunglasses/disco = 4,
					/obj/item/clothing/under/rank/security/detective = 4,
					/obj/item/clothing/under/rank/security/detective/skirt = 4,
					/obj/item/clothing/suit/det_suit = 4,
					/obj/item/clothing/head/fedora/det_hat = 4,
					/obj/item/clothing/gloves/color/black = 4,
					/obj/item/clothing/under/rank/security/detective/grey = 4,
					/obj/item/clothing/under/rank/security/detective/grey/skirt = 4,
					/obj/item/clothing/accessory/waistcoat = 4,
					/obj/item/clothing/suit/det_suit/grey = 4,
					/obj/item/clothing/suit/det_suit/noir = 4,
					/obj/item/clothing/head/fedora = 4,
					/obj/item/clothing/shoes/laceup = 4,
					/obj/item/assembly/flash/handheld = 4,
					/obj/item/flashlight/seclite = 4,
					/obj/item/storage/box/evidence = 12,
					/obj/item/storage/box/matches = 12,
					/obj/item/storage/fancy/cigarettes/cigars = 12,
					/obj/item/reagent_containers/food/drinks/coffee = 12,
					/obj/item/reagent_containers/food/snacks/donut = 12)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,
					  /obj/item/storage/fancy/donut_box = 2)
	premium = list(/obj/item/storage/belt/security/webbing = 5,
					/obj/item/coin/antagtoken = 1,
					/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 4,
					/obj/item/storage/box/gum/nicotine = 2,
					/obj/item/lighter = 4,
					/obj/item/clothing/mask/cigarette/pipe = 4,
					/obj/item/storage/fancy/cigarettes/cigars/havana = 12,
					/obj/item/storage/fancy/cigarettes/cigars/cohiba = 12)

	refill_canister = /obj/item/vending_refill/detective
	default_price = 650
	extra_price = 700
	payment_department = ACCOUNT_SEC

/obj/machinery/vending/dic/pre_throw(obj/item/I)
	if(istype(I, /obj/item/grenade))
		var/obj/item/grenade/G = I
		G.preprime()
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		F.on = TRUE
		F.update_brightness()

/obj/item/vending_refill/detective
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "refill_det"


/obj/item/clothing/suit/det_suit/disco
	name = "disco-ass blazer"
	desc = "Looks like someone skinned this blazer off some long extinct disco-animal. It has an enigmatic white rectangle on the back and the right sleeve."
	mob_overlay_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "jamrock_blazer"
	item_state = "jamrock_blazer_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'

/obj/item/clothing/suit/det_suit/disco/aerostatic
	name = "aerostatic bomber jacket"
	desc = "An unquestionably gaudy and peculiar yet also curiously flattering bomber jacket. It emanates a strange air of authority."
	icon_state = "aerostatic_bomber_jacket"
	item_state = "aerostatic_bomber_jacket_held"

/obj/item/clothing/under/rank/security/detective/disco
	name = "jamrock suit"
	desc = "An 'interesting' looking ensemble consisting of golden-brown flare cut trousers and an obviously hard worn white satin shirt."
	mob_overlay_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "jamrock_suit"
	item_state = "jamrock_suit_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/detective/disco/aerostatic
	name = "aerostatic suit"
	desc = "A crisp and well-pressed suit; professional, comfortable and curiously authoritative."
	icon_state = "aerostatic_suit"
	item_state = "aerostatic_suit_held"
	alt_covers_chest = TRUE

/obj/item/clothing/shoes/sneakers/disco
	name = "green lizardskin shoes"
	desc = "Though depleted of lustre with the passage of time, these well-worn green lizard leather shoes fit almost perfectly."
	mob_overlay_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "lizardskin_shoes"
	item_state = "lizardskin_shoes_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'

/obj/item/clothing/shoes/jackboots/aerostatic
	name = "aerostatic boots"
	desc = "Sharp and comfortable looking boots crafted from tough brown leather."
	mob_overlay_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "aerostatic_boots"
	item_state = "aerostatic_boots_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'

/obj/item/clothing/gloves/color/black/aerostatic_gloves
	desc = "Vivid red gloves that exude a mysterious style."
	name = "aerostatic_gloves"
	mob_overlay_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "aerostatic_gloves"
	item_state = "aerostatic_gloves_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'
	can_be_cut = FALSE

/obj/item/clothing/neck/tie/detective/disco_necktie
	name = "horrific necktie"
	desc = "The necktie is adorned with a garish pattern. It's disturbingly vivid. Somehow you feel as if it would be wrong to ever take it off. It's your friend now. You will betray it if you change it for some boring scarf."
	mob_overlay_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "eldritch_tie"
	item_state = "eldritch_tie_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'
	var/possessed

/obj/item/clothing/neck/tie/detective/disco_necktie/relaymove(mob/user)
	return

/obj/item/clothing/neck/tie/detective/disco_necktie/attack_self(mob/living/user)
	if(possessed)
		return

	to_chat(user, "<span class='notice'>You plumb the depths of your Inland Empire. Whispers seem to emaninate from [src], as though it had somehow come to life; could it be?</span>")

	possessed = TRUE

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the spirit of [user.real_name]'s [src]?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/shade/S = new(src)
		S.ckey = C.ckey
		S.fully_replace_character_name(null, "The spirit of [name]")
		S.status_flags |= GODMODE
		S.copy_languages(user, LANGUAGE_MASTER)	//Make sure the tie  can understand and communicate with the user.
		S.update_atom_languages()
		grant_all_languages(FALSE, FALSE, TRUE)	//Grants omnitongue
		var/input = sanitize_name(stripped_input(S,"What are you named?", ,"", MAX_NAME_LEN))

		if(src && input)
			name = input
			S.fully_replace_character_name(null, "The spirit of [input]")
	else
		to_chat(user, "<span class='warning'>The whispers coming from [src] fade and are silent again... Was it all your imagination? Maybe you can try again later.</span>")
		possessed = FALSE

/obj/item/clothing/neck/tie/detective/disco_necktie/Destroy()
	deconceptualize()
	return ..()

/obj/item/clothing/neck/tie/detective/disco_necktie/proc/deconceptualize()
	for(var/mob/living/simple_animal/shade/S in contents)
		to_chat(S, "<span class='userdanger'>You were deconceptualized!</span>")
		qdel(S)

/obj/item/clothing/neck/tie/detective/disco_necktie/verb/deconceptualize_tie()
	set name = "Deconceptualize Tie"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	if (!possessed)
		to_chat(M, "<span class='warning'>There is no tie persona to deconceptualize!</span>")
		return

	var/list/deconceptualize_options = list(
	"No.", \
	"Yes.")

	var/choice = input(M,"Deconceptualizing the tie will remove its personality. Are you sure?","Deconceptualize Tie") as null|anything in deconceptualize_options

	switch(choice)
		if("Yes.")
			to_chat(M, "<span class='warning'>Asserting your volition in a triumphant act of will, you dispel the phantom persona imposed upon your preternaturally ugly tie.</span>")
			deconceptualize() //This kills the tie ghost.
		if("No.")
			to_chat(M, "<span class='warning'>Thinking better of it, you choose not to banish your phantom friend to the conceptual oblivion from which it was dredged.</span>")

/obj/item/clothing/glasses/sunglasses/disco
	name = "binoclard lenses"
	desc = "Stylish round lenses subtly shaded for your protection and criminal discomfort."
	mob_overlay_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "binoclard_lenses"
	item_state = "binoclard_lenses_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'