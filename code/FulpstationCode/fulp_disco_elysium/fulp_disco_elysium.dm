/obj/item/clothing/suit/det_suit/disco
	name = "disco-ass blazer"
	desc = "Looks like someone skinned this blazer off some long extinct disco-animal. It has an enigmatic white rectangle on the back and the right sleeve."
	worn_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "jamrock_blazer"
	inhand_icon_state = "jamrock_blazer_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'

/obj/item/clothing/suit/det_suit/disco/aerostatic
	name = "aerostatic bomber jacket"
	desc = "An unquestionably gaudy and peculiar yet also curiously flattering bomber jacket. It emanates a strange air of authority."
	icon_state = "aerostatic_bomber_jacket"
	inhand_icon_state = "aerostatic_bomber_jacket_held"

/obj/item/clothing/under/rank/security/detective/disco
	name = "jamrock suit"
	desc = "An 'interesting' looking ensemble consisting of golden-brown flare cut trousers and an obviously hard worn white satin shirt."
	worn_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "jamrock_suit"
	inhand_icon_state = "jamrock_suit_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/security/detective/disco/aerostatic
	name = "aerostatic suit"
	desc = "A crisp and well-pressed suit; professional, comfortable and curiously authoritative."
	icon_state = "aerostatic_suit"
	inhand_icon_state = "aerostatic_suit_held"
	alt_covers_chest = TRUE

/obj/item/clothing/shoes/sneakers/disco
	name = "green lizardskin shoes"
	desc = "Though depleted of lustre with the passage of time, these well-worn green lizard leather shoes fit almost perfectly."
	worn_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "lizardskin_shoes"
	inhand_icon_state = "lizardskin_shoes_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'

/obj/item/clothing/shoes/jackboots/aerostatic
	name = "aerostatic boots"
	desc = "Sharp and comfortable looking boots crafted from tough brown leather."
	worn_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "aerostatic_boots"
	inhand_icon_state = "aerostatic_boots_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'

/obj/item/clothing/gloves/color/black/aerostatic_gloves
	name = "aerostatic gloves"
	desc = "Vivid red gloves that exude a mysterious style."
	worn_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "aerostatic_gloves"
	inhand_icon_state = "aerostatic_gloves_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'
	can_be_cut = FALSE

/obj/item/clothing/neck/tie/detective/disco_necktie
	name = "horrific necktie"
	desc = "The necktie is adorned with a garish pattern. It's disturbingly vivid. Somehow you feel as if it would be wrong to ever take it off. It's your friend now. You will betray it if you change it for some boring scarf."
	worn_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "eldritch_tie"
	inhand_icon_state = "eldritch_tie_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'
	var/possessed

/obj/item/clothing/neck/tie/detective/disco_necktie/relaymove(mob/user)
	return

/obj/item/clothing/neck/tie/detective/disco_necktie/attack_self(mob/living/user)
	if(possessed)
		return

	to_chat(user, "<span class='notice'>You plumb the depths of your Inland Empire. Whispers seem to emanate from [src], as though it had somehow come to life; could it be?</span>")

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
	worn_icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium_worn.dmi'
	icon = 'icons/Fulpicons/Surreal_stuff/disco_elysium.dmi'
	icon_state = "binoclard_lenses"
	inhand_icon_state = "binoclard_lenses_held"
	lefthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_left.dmi'
	righthand_file = 'icons/Fulpicons/Surreal_stuff/disco_elysium_inhand_right.dmi'