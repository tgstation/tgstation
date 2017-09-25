/datum/clockwork_scripture/create_object/sigil_of_submission
	tier = SCRIPTURE_SCRIPT
	usage_tip = "This the primary way to make conversion traps, though it will not penetrate mindshield implants."

/obj/effect/clockwork/sigil/submission
	alpha = 75 // This makes it hard to see and more useful as an actual trap
	light_range = 1 //weak light
	light_power = 1

/obj/effect/temp_visual/ratvar/sigil/accession
	color = "#AF0AAF"
	layer = ABOVE_MOB_LAYER
	duration = 70
	icon_state = "sigilactiveoverlay"
	alpha = 0

/obj/effect/clockwork/sigil/submission/proc/post_channel(mob/living/L)
	return

/////////////////////////////
///////ACCESSION SIGILS//////
/////////////////////////////

//Sigil of Accession: After a short time, converts any non-servant standing on it though implants. Knocks down and silences them for five seconds afterwards.
/obj/effect/clockwork/sigil/submission/accession
	name = "terrifying sigil"
	desc = "A luminous brassy sigil. Something about it makes you want to flee."
	clockwork_desc = "A sigil that will enslave any person who crosses it, provided they remain on it for seven seconds. \n\
	It can convert a mindshielded target once before disppearing, but can convert any number of non-implanted targets."
	icon_state = "sigiltransgression"
	alpha = 200
	color = "#A97F1B"
	light_range = 3 //bright light
	light_power = 1
	light_color = "#A97F1B"
	delete_on_finish = FALSE
	sigil_name = "Sigil of Accession"
	glow_type = /obj/effect/temp_visual/ratvar/sigil/accession
	resist_string = "glows bright orange"

/obj/effect/clockwork/sigil/submission/accession/post_channel(mob/living/L)
	if(L.isloyal())
		L.log_message("<font color=#BE8700>Had their mindshield implant broken by a [sigil_name].</font>", INDIVIDUAL_ATTACK_LOG)
		delete_on_finish = TRUE
		L.visible_message("<span class='warning'>[L] visibly trembles!</span>", \
		"<span class='sevtug'>[text2ratvar("You will be mine and his. This puny trinket will not stop me.")]</span>")
		for(var/M in L.implants)
			var/obj/item/implant/mindshield/MS = M
			qdel(MS)


//Sigil of Accession: Creates a sigil of accession, which is like a sigil of submission, but can convert any number of non-implanted targets and up to one implanted target.
/datum/clockwork_scripture/create_object/sigil_of_accession
	descname = "Trap, Permanent Conversion"
	name = "Sigil of Accession"
	desc = "Places a luminous sigil much like a Sigil of Submission, but it will remain even after successfully converting a non-implanted target. \
	It will penetrate mindshield implants once before disappearing."
	invocations = list("Divinity, enslave...", "...all who trespass here!")
	channel_time = 70
	consumed_components = list(BELLIGERENT_EYE = 4, GEIS_CAPACITOR = 2, HIEROPHANT_ANSIBLE = 2)
	whispered = TRUE
	object_path = /obj/effect/clockwork/sigil/submission/accession
	prevent_path = /obj/effect/clockwork/sigil/submission
	creator_message = "<span class='brass'>A luminous sigil appears below you. All non-servants to cross it will be enslaved after a brief time if they do not move.</span>"
	usage_tip = "It will remain after converting a target, unless that target has a mindshield implant, which it will break to convert them, but consume itself in the process."
	tier = SCRIPTURE_APPLICATION
	one_per_tile = TRUE
	primary_component = BELLIGERENT_EYE
	sort_priority = 1
	quickbind = TRUE
	quickbind_desc = "Creates a Sigil of Accession, which can convert a mindshielded non-Servant that remains on it."
