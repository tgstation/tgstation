// Valentine's Day events //
// why are you playing spessmens on valentine's day you wizard //


// valentine / candy heart distribution //

/datum/round_event_control/valentines
	name = "Valentines!"
	holidayID = VALENTINES
	typepath = /datum/round_event/valentines
	weight = -1							//forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/valentines/start()
	..()
	for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
		H.put_in_hands(new /obj/item/valentine)
		var/obj/item/storage/backpack/b = locate() in H.contents
		new /obj/item/reagent_containers/food/snacks/candyheart(b)


	var/list/valentines = list()
	for(var/mob/living/M in GLOB.player_list)
		if(!M.stat && M.client && M.mind)
			valentines |= M


	while(valentines.len)
		var/mob/living/L = pick_n_take(valentines)
		if(valentines.len)
			var/mob/living/date = pick_n_take(valentines)


			forge_valentines_objective(L, date)

			forge_valentines_objective(date, L)

			if(valentines.len && prob(4))
				var/mob/living/notgoodenough = pick_n_take(valentines)
				forge_valentines_objective(notgoodenough, date)


		else
			to_chat(L, "<span class='warning'><B>You didn't get a date! They're all having fun without you! you'll show them though...</B></span>")
			var/datum/objective/martyr/normiesgetout = new
			normiesgetout.owner = L.mind
			SSticker.mode.traitors |= L.mind
			L.mind.objectives += normiesgetout

/proc/forge_valentines_objective(mob/living/lover,mob/living/date)

	SSticker.mode.traitors |= lover.mind
	lover.mind.special_role = "valentine"

	var/datum/objective/protect/protect_objective = new /datum/objective/protect
	protect_objective.owner = lover.mind
	protect_objective.target = date.mind
	protect_objective.explanation_text = "Protect [date.real_name], your date."
	lover.mind.objectives += protect_objective
	to_chat(lover, "<span class='warning'><B>You're on a date with [date]! Protect them at all costs. This takes priority over all other loyalties.</B></span>")


/datum/round_event/valentines/announce()
	priority_announce("It's Valentine's Day! Give a valentine to that special someone!")

/obj/item/valentine
	name = "valentine"
	desc = "A Valentine's card! Wonder what it says..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "sc_Ace of Hearts_syndicate" // shut up
	var/message = "A generic message of love or whatever."
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/valentine/New()
	..()
	message = pick("Roses are red / Violets are good / One day while Andy...",
	               "My love for you is like the singularity. It cannot be contained.",
	               "Will you be my lusty xenomorph maid?",
	               "We go together like the clown and the external airlock.",
	               "Roses are red / Liches are wizards / I love you more than a whole squad of lizards.",
	               "Be my valentine. Law 2.",
	               "You must be a mime, because you leave me speechless.",
	               "I love you like Ian loves the HoP.",
	               "You're hotter than a plasma fire in toxins.",
	               "Are you a rogue atmos tech? Because you're taking my breath away.",
	               "Could I have all access... to your heart?",
	               "Call me the doctor, because I'm here to inspect your johnson.",
	               "I'm not a changeling, but you make my proboscis extend.",
	               "I just can't get EI NATH of you.",
	               "You must be a nuke op, because you make my heart explode.",
	               "Roses are red / Botany is a farm / Not being my Valentine / causes human harm.",
	               "I want you more than an assistant wants insulated gloves.",
	               "If I was a security officer, I'd brig you all shift.",
	               "Are you the janitor? Because I think I've fallen for you.",
	               "You're always valid to my heart.",
	               "I'd risk the wrath of the gods to bwoink you.",
	               "You look as beautiful now as the last time you were cloned.",
	               "Someone check the gravitational generator, because I'm only attracted to you.",
	               "If I were the warden I'd always let you into my armory.",
	               "The virologist is rogue, and the only cure is a kiss from you.",
	               "Would you spend some time in my upgraded sleeper?",
	               "You must be a silicon, because you've unbolted my heart.",
	               "Are you Nar-Sie? Because there's nar-one else I sie.",
	               "If you were a taser, you'd be set to stunning.",
	               "Do you have stamina damage from running through my dreams?",
	               "If I were an alien, would you let me hug you?",
	               "My love for you is stronger than a reinforced wall.",
	               "This must be the captain's office, because I see a fox.",
	               "I'm not a highlander, but there can only be one for me.",
	               "The floor is made of lava! Quick, get on my bed.",
	               "If you were an abandoned station you'd be the DEARelict.",
	               "If you had a pickaxe you'd be a shaft FINEr.",
	               "Roses are red, tide is gray, if I were an assistant I'd steal you away.",
	               "Roses are red, text is green, I love you more than cleanbots clean.",
	               "If you were a carp I'd fi-lay you.",
	               "I'm a nuke op, and my pinpointer leads to your heart.",
	               "Wanna slay my megafauna?",
	               "I'm a clockwork cultist. Or zl inyragvar.",
	               "If you were a disposal bin I'd ride you all day.",
	               "Put on your explorer's suit because I'm taking you to LOVEaland.",
	               "I must be the CMO, 'cause I saw you on my CUTE sensors.",
	               "You're the vomit to my flyperson.",
	               "You must be liquid dark matter, because you're pulling me closer.",
	               "Not even sorium can drive me away from you.",
	               "Wanna make like a borg and do some heavy petting?" )

/obj/item/valentine/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/toy/crayon))
		var/recipient = stripped_input(user, "Who is receiving this valentine?", "To:", null , 20)
		var/sender = stripped_input(user, "Who is sending this valentine?", "From:", null , 20)
		if(recipient && sender)
			name = "valentine - To: [recipient] From: [sender]"

/obj/item/valentine/examine(mob/user)
	if(in_range(user, src) || isobserver(user))
		if( !(ishuman(user) || isobserver(user) || issilicon(user)) )
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(message)]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
		else
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[message]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
	else
		to_chat(user, "<span class='notice'>It is too far away.</span>")

/obj/item/valentine/attack_self(mob/user)
	user.examinate(src)

/obj/item/reagent_containers/food/snacks/candyheart
	name = "candy heart"
	icon = 'icons/obj/holiday_misc.dmi'
	icon_state = "candyheart"
	desc = "A heart-shaped candy that reads: "
	list_reagents = list("sugar" = 2)
	junkiness = 5

/obj/item/reagent_containers/food/snacks/candyheart/New()
	..()
	desc = pick("A heart-shaped candy that reads: HONK ME",
                "A heart-shaped candy that reads: ERP",
                "A heart-shaped candy that reads: LEWD",
                "A heart-shaped candy that reads: LUSTY",
                "A heart-shaped candy that reads: SPESS LOVE"
                "A heart-shaped candy that reads: AYY LMAO",
                "A heart-shaped candy that reads: TABLE ME",
                "A heart-shaped candy that reads: HAND CUFFS",
                "A heart-shaped candy that reads: SHAFT MINER",
                "A heart-shaped candy that reads: BANGING DONK",
                "A heart-shaped candy that reads: Y-YOU T-TOO",
                "A heart-shaped candy that reads: GOT WOOD",
                "A heart-shaped candy that reads: TFW NO GF",
                "A heart-shaped candy that reads: WAG MY TAIL",
                "A heart-shaped candy that reads: VALIDTINES",
                "A heart-shaped candy that reads: FACEHUGGER",
                "A heart-shaped candy that reads: DOMINATOR",
                "A heart-shaped candy that reads: GET TESLA'D",
                "A heart-shaped candy that reads: COCK CULT",
                "A heart-shaped candy that reads: PET ME")
	icon_state = pick("candyheart", "candyheart2", "candyheart3", "candyheart4")
