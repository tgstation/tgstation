/obj/item/toy/plush
	name = "plush"
	desc = "This is the special coder plush, do not steal."
	icon = 'icons/obj/toys/plushes.dmi'
	icon_state = "debug"
	worn_icon_state = "plushie"
	attack_verb_continuous = list("thumps", "whomps", "bumps")
	attack_verb_simple = list("thump", "whomp", "bump")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	floor_placeable = TRUE
	var/list/squeak_override //Weighted list; If you want your plush to have different squeak sounds use this
	var/stuffed = TRUE //If the plushie has stuffing in it
	var/obj/item/grenade/grenade //You can remove the stuffing from a plushie and add a grenade to it for *nefarious uses*
	//--love ~<3--
	gender = NEUTER
	var/obj/item/toy/plush/lover
	var/obj/item/toy/plush/partner
	var/obj/item/toy/plush/plush_child
	var/obj/item/toy/plush/paternal_parent //who initiated creation
	var/obj/item/toy/plush/maternal_parent //who owns, see love()
	var/static/list/breeding_blacklist = typecacheof(/obj/item/toy/plush/carpplushie/dehy_carp) // you cannot have sexual relations with this plush
	var/list/scorned = list() //who the plush hates
	var/list/scorned_by = list() //who hates the plush, to remove external references on Destroy()
	var/heartbroken = FALSE
	var/vowbroken = FALSE
	var/young = FALSE
///Prevents players from cutting stuffing out of a plushie if true
	var/divine = FALSE
	var/mood_message
	var/list/love_message
	var/list/partner_message
	var/list/heartbroken_message
	var/list/vowbroken_message
	var/list/parent_message
	var/normal_desc
	//--end of love :'(--

/*
** If you add a new plushie please add it to the lists at both:
** /obj/effect/spawner/random/entertainment/plushie
** /obj/effect/spawner/random/entertainment/plushie_delux
*/

/obj/item/toy/plush/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, squeak_override)
	AddElement(/datum/element/bed_tuckable, mapload, 6, -5, 90)
	AddElement(/datum/element/toy_talk)

	//have we decided if Pinocchio goes in the blue or pink aisle yet?
	if(gender == NEUTER)
		if(prob(50))
			gender = FEMALE
		else
			gender = MALE

	love_message = list("\n[src] is so happy, \he could rip a seam!")
	partner_message = list("\n[src] has a ring on \his finger! It says bound to my dear [partner].")
	heartbroken_message = list("\n[src] looks so sad.")
	vowbroken_message = list("\n[src] lost \his ring...")
	parent_message = list("\n[src] can't remember what sleep is.")

	normal_desc = desc

/obj/item/toy/plush/Destroy()
	QDEL_NULL(grenade)

	//inform next of kin and... acquaintances
	if(partner)
		partner.bad_news(src)
		partner = null
		lover = null
	else if(lover)
		lover.bad_news(src)
		lover = null

	if(paternal_parent)
		paternal_parent.bad_news(src)
		paternal_parent = null

	if(maternal_parent)
		maternal_parent.bad_news(src)
		maternal_parent = null

	if(plush_child)
		plush_child.bad_news(src)
		plush_child = null

	var/i
	var/obj/item/toy/plush/P
	for(i=1, i <= scorned.len, i++)
		P = scorned[i]
		P.bad_news(src)
	scorned = null

	for(i=1, i <= scorned_by.len, i++)
		P = scorned_by[i]
		P.bad_news(src)
	scorned_by = null

	//null remaining lists
	squeak_override = null

	love_message = null
	partner_message = null
	heartbroken_message = null
	vowbroken_message = null
	parent_message = null

	return ..()

/obj/item/toy/plush/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == grenade)
		grenade = null

/obj/item/toy/plush/attack_self(mob/user)
	. = ..()
	if(stuffed || grenade)
		to_chat(user, span_notice("You pet [src]. D'awww."))
		if(grenade && !grenade.active)
			user.log_message("activated a hidden grenade in [src].", LOG_VICTIM)
			grenade.arm_grenade(user, msg = FALSE, volume = 10)
	else
		to_chat(user, span_notice("You try to pet [src], but it has no stuffing. Aww..."))

/obj/item/toy/plush/attackby(obj/item/I, mob/living/user, list/modifiers, list/attack_modifiers)
	if(I.get_sharpness())
		if(!grenade)
			if(!stuffed)
				to_chat(user, span_warning("You already murdered it!"))
				return
			if(!divine)
				user.visible_message(span_notice("[user] tears out the stuffing from [src]!"), span_notice("You rip a bunch of the stuffing from [src]. Murderer."))
				I.play_tool_sound(src)
				stuffed = FALSE
			else
				to_chat(user, span_notice("What a fool you are. [src] is a god, how can you kill a god? What a grand and intoxicating innocence."))
				user.adjust_drunk_effect(20, up_to = 50)

				var/turf/current_location = get_turf(user)
				var/area/current_area = current_location.loc //copied from hand tele code
				if(current_location && current_area && (current_area.area_flags & NOTELEPORT))
					to_chat(user, span_notice("There is no escape. No recall or intervention can work in this place."))
				else
					to_chat(user, span_notice("There is no escape. Although recall or intervention can work in this place, attempting to flee from [src]'s immense power would be futile."))
				user.visible_message(span_notice("[user] lays down their weapons and begs for [src]'s mercy!"), span_notice("You lay down your weapons and beg for [src]'s mercy."))
				user.drop_all_held_items()
		else
			to_chat(user, span_notice("You remove the grenade from [src]."))
			user.put_in_hands(grenade)
		return
	if(isgrenade(I))
		if(stuffed)
			to_chat(user, span_warning("You need to remove some stuffing first!"))
			return
		if(grenade)
			to_chat(user, span_warning("[src] already has a grenade!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		user.visible_message(span_warning("[user] slides [grenade] into [src]."), \
		span_danger("You slide [I] into [src]."))
		grenade = I
		user.log_message("added a grenade ([I.name]) to [src]", LOG_GAME)
		return
	if(istype(I, /obj/item/toy/plush))
		love(I, user)
		return
	return ..()

/obj/item/toy/plush/proc/love(obj/item/toy/plush/Kisser, mob/living/user) //~<3
	var/chance = 100 //to steal a kiss, surely there's a 100% chance no-one would reject a plush such as I?
	var/concern = 20 //perhaps something might cloud true love with doubt
	var/loyalty = 30 //why should another get between us?
	var/duty = 50 //conquering another's is what I live for

	//we are not catholic
	if(young == TRUE || Kisser.young == TRUE)
		user.show_message(span_notice("[src] plays tag with [Kisser]."), MSG_VISUAL,
			span_notice("They're happy."), NONE)
		Kisser.cheer_up()
		cheer_up()

	//never again
	else if(Kisser in scorned)
		//message, visible, alternate message, neither visible nor audible
		user.show_message(span_notice("[src] rejects the advances of [Kisser]!"), MSG_VISUAL,
			span_notice("That didn't feel like it worked."), NONE)
	else if(src in Kisser.scorned)
		user.show_message(span_notice("[Kisser] realises who [src] is and turns away."), MSG_VISUAL,
			span_notice("That didn't feel like it worked."), NONE)

	//first comes love
	else if(Kisser.lover != src && Kisser.partner != src) //cannot be lovers or married
		if(Kisser.lover) //if the initiator has a lover
			Kisser.lover.heartbreak(Kisser) //the old lover can get over the kiss-and-run whilst the kisser has some fun
			chance -= concern //one heart already broken, what does another mean?
		if(lover) //if the recipient has a lover
			chance -= loyalty //mustn't... but those lips
		if(partner) //if the recipient has a partner
			chance -= duty //do we mate for life?

		if(prob(chance)) //did we bag a date?
			user.visible_message(span_notice("[user] makes [Kisser] kiss [src]!"),
									span_notice("You make [Kisser] kiss [src]!"))
			if(lover) //who cares for the past, we live in the present
				lover.heartbreak(src)
			new_lover(Kisser)
			Kisser.new_lover(src)
		else
			user.show_message(span_notice("[src] rejects the advances of [Kisser], maybe next time?"), MSG_VISUAL,
								span_notice("That didn't feel like it worked, this time."), NONE)

	//then comes marriage
	else if(Kisser.lover == src && Kisser.partner != src) //need to be lovers (assumes loving is a two way street) but not married (also assumes similar)
		user.visible_message(span_notice("[user] pronounces [Kisser] and [src] married! D'aw."),
									span_notice("You pronounce [Kisser] and [src] married!"))
		new_partner(Kisser)
		Kisser.new_partner(src)

	//then comes a baby in a baby's carriage, or an adoption in an adoption's orphanage
	else if(Kisser.partner == src && !plush_child) //the one advancing does not take ownership of the child and we have a one child policy in the toyshop
		user.visible_message(span_notice("[user] is going to break [Kisser] and [src] by bashing them like that."),
									span_notice("[Kisser] passionately embraces [src] in your hands. Look away you perv!"))
		user.client.give_award(/datum/award/achievement/misc/rule8, user)
		if(plop(Kisser))
			user.visible_message(span_notice("Something drops at the feet of [user]."),
							span_notice("The miracle of oh god did that just come out of [src]?!"))

	//then comes protection, or abstinence if we are catholic
	else if(Kisser.partner == src && plush_child)
		user.visible_message(span_notice("[user] makes [Kisser] nuzzle [src]!"),
									span_notice("You make [Kisser] nuzzle [src]!"))

	//then oh fuck something unexpected happened
	else
		user.show_message(span_warning("[Kisser] and [src] don't know what to do with one another."), NONE)

/obj/item/toy/plush/proc/heartbreak(obj/item/toy/plush/Brutus)
	if(lover != Brutus)
		CRASH("plushie heartbroken by a plushie that is not their lover")

	scorned.Add(Brutus)
	Brutus.scorned_by(src)

	lover = null
	Brutus.lover = null //feeling's mutual

	heartbroken = TRUE
	mood_message = pick(heartbroken_message)

	if(partner == Brutus) //oh dear...
		partner = null
		Brutus.partner = null //it'd be weird otherwise
		vowbroken = TRUE
		mood_message = pick(vowbroken_message)

	update_desc()

/obj/item/toy/plush/proc/scorned_by(obj/item/toy/plush/Outmoded)
	scorned_by.Add(Outmoded)

/obj/item/toy/plush/proc/new_lover(obj/item/toy/plush/Juliet)
	if(lover == Juliet)
		return //nice try
	lover = Juliet

	cheer_up()
	lover.cheer_up()

	mood_message = pick(love_message)
	update_desc()

	if(partner) //who?
		partner = null //more like who cares

/obj/item/toy/plush/proc/new_partner(obj/item/toy/plush/Apple_of_my_eye)
	if(partner == Apple_of_my_eye)
		return //double marriage is just insecurity
	if(lover != Apple_of_my_eye)
		return //union not born out of love will falter

	partner = Apple_of_my_eye

	heal_memories()
	partner.heal_memories()

	mood_message = pick(partner_message)
	update_desc()

/obj/item/toy/plush/proc/plop(obj/item/toy/plush/Daddy)
	if(partner != Daddy)
		return FALSE //we do not have bastards in our toyshop

	if(is_type_in_typecache(Daddy, breeding_blacklist))
		return FALSE // some love is forbidden

	if(prob(50)) //it has my eyes
		plush_child = new type(get_turf(loc))
	else //it has your eyes
		plush_child = new Daddy.type(get_turf(loc))

	plush_child.make_young(src, Daddy)

/obj/item/toy/plush/proc/make_young(obj/item/toy/plush/Mama, obj/item/toy/plush/Dada)
	if(Mama == Dada)
		return //cloning is reserved for plants and spacemen

	maternal_parent = Mama
	paternal_parent = Dada
	young = TRUE
	name = "[Mama] Jr" //Icelandic naming convention pending
	normal_desc = "[src] is a little baby of [maternal_parent] and [paternal_parent]!" //original desc won't be used so the child can have moods
	transform *= 0.75
	update_desc()

	Mama.mood_message = pick(Mama.parent_message)
	Mama.update_desc()
	Dada.mood_message = pick(Dada.parent_message)
	Dada.update_desc()

/obj/item/toy/plush/proc/bad_news(obj/item/toy/plush/Deceased) //cotton to cotton, sawdust to sawdust
	var/is_that_letter_for_me = FALSE
	if(partner == Deceased) //covers marriage
		is_that_letter_for_me = TRUE
		partner = null
		lover = null
	else if(lover == Deceased) //covers lovers
		is_that_letter_for_me = TRUE
		lover = null

	//covers children
	if(maternal_parent == Deceased)
		is_that_letter_for_me = TRUE
		maternal_parent = null

	if(paternal_parent == Deceased)
		is_that_letter_for_me = TRUE
		paternal_parent = null

	//covers parents
	if(plush_child == Deceased)
		is_that_letter_for_me = TRUE
		plush_child = null

	//covers bad memories
	if(Deceased in scorned)
		scorned.Remove(Deceased)
		cheer_up() //what cold button eyes you have

	if(Deceased in scorned_by)
		scorned_by.Remove(Deceased)

	//all references to the departed should be cleaned up by now

	if(is_that_letter_for_me)
		heartbroken = TRUE
		mood_message = pick(heartbroken_message)
		update_desc()

/obj/item/toy/plush/proc/cheer_up() //it'll be all right
	if(!heartbroken)
		return //you cannot make smile what is already
	if(vowbroken)
		return //it's a pretty big deal

	heartbroken = !heartbroken

	if(mood_message in heartbroken_message)
		mood_message = null
	update_desc()

/obj/item/toy/plush/proc/heal_memories() //time fixes all wounds
	if(!vowbroken)
		vowbroken = !vowbroken
		if(mood_message in vowbroken_message)
			mood_message = null
	cheer_up()

/obj/item/toy/plush/update_desc()
	desc = normal_desc
	. = ..()
	if(mood_message)
		desc += mood_message

/obj/item/toy/plush/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/toy/plush/carpplushie"
	post_init_icon_state = "map_plushie_carp"
	greyscale_config = /datum/greyscale_config/plush_carp
	greyscale_colors = "#cc99ff#000000"
	inhand_icon_state = "carp_plushie"
	attack_verb_continuous = list("bites", "eats", "fin slaps")
	attack_verb_simple = list("bite", "eat", "fin slap")
	squeak_override = list('sound/items/weapons/bite.ogg'=1)

/obj/item/toy/plush/bubbleplush
	name = "\improper Bubblegum plushie"
	desc = "The friendly red demon that gives good miners gifts."
	icon_state = "bubbleplush"
	attack_verb_continuous = list("rents")
	attack_verb_simple = list("rent")
	squeak_override = list('sound/effects/magic/demon_attack1.ogg'=1)

/obj/item/toy/plush/ratplush
	name = "\improper Ratvar plushie"
	desc = "An adorable plushie of the clockwork justiciar himself with new and improved spring arm action."
	icon_state = "plushvar"
	divine = TRUE
	var/obj/item/toy/plush/narplush/clash_target
	gender = MALE //he's a boy, right?

/obj/item/toy/plush/ratplush/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(clash_target)
		return
	var/obj/item/toy/plush/narplush/P = locate() in range(1, src)
	if(P && istype(P.loc, /turf/open) && !P.clashing)
		clash_of_the_plushies(P)

/obj/item/toy/plush/ratplush/proc/clash_of_the_plushies(obj/item/toy/plush/narplush/P)
	clash_target = P
	P.clashing = TRUE
	say("YOU.")
	P.say("Ratvar?!")
	var/obj/item/toy/plush/a_winnar_is
	var/victory_chance = 10
	for(var/i in 1 to 10) //We only fight ten times max
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(!Adjacent(P))
			visible_message(span_warning("The two plushies angrily flail at each other before giving up."))
			clash_target = null
			P.clashing = FALSE
			return
		playsound(src, 'sound/effects/magic/clockwork/ratvar_attack.ogg', 50, TRUE, frequency = 2)
		sleep(0.24 SECONDS)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(prob(victory_chance))
			a_winnar_is = src
			break
		P.SpinAnimation(5, 0)
		sleep(0.5 SECONDS)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		playsound(P, 'sound/effects/magic/clockwork/narsie_attack.ogg', 50, TRUE, frequency = 2)
		sleep(0.33 SECONDS)
		if(QDELETED(src))
			P.clashing = FALSE
			return
		if(QDELETED(P))
			clash_target = null
			return
		if(prob(victory_chance))
			a_winnar_is = P
			break
		SpinAnimation(5, 0)
		victory_chance += 10
		sleep(0.5 SECONDS)
	if(!a_winnar_is)
		a_winnar_is = pick(src, P)
	if(a_winnar_is == src)
		say(pick("DIE.", "ROT."))
		P.say(pick("Nooooo...", "Not die. To y-", "Die. Ratv-", "Sas tyen re-"))
		playsound(src, 'sound/effects/magic/clockwork/anima_fragment_attack.ogg', 50, TRUE, frequency = 2)
		playsound(P, 'sound/effects/magic/demon_dies.ogg', 50, TRUE, frequency = 2)
		explosion(P, light_impact_range = 1)
		qdel(P)
		clash_target = null
	else
		say("NO! I will not be banished again...")
		P.say(pick("Ha.", "Ra'sha fonn dest.", "You fool. To come here."))
		playsound(src, 'sound/effects/magic/clockwork/anima_fragment_death.ogg', 62, TRUE, frequency = 2)
		playsound(P, 'sound/effects/magic/demon_attack1.ogg', 50, TRUE, frequency = 2)
		explosion(src, light_impact_range = 1)
		qdel(src)
		P.clashing = FALSE

/obj/item/toy/plush/narplush
	name = "\improper Nar'Sie plushie"
	desc = "A small stuffed doll of the elder goddess Nar'Sie. Who thought this was a good children's toy?"
	icon_state = "narplush"
	divine = TRUE
	var/clashing
	gender = FEMALE //it's canon if the toy is

/obj/item/toy/plush/narplush/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/obj/item/toy/plush/ratplush/P = locate() in range(1, src)
	if(P && istype(P.loc, /turf/open) && !P.clash_target && !clashing)
		P.clash_of_the_plushies(src)

/obj/item/toy/plush/lizard_plushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon_state = "map_plushie_lizard"
	greyscale_config = /datum/greyscale_config/plush_lizard
	attack_verb_continuous = list("claws", "hisses", "tail slaps")
	attack_verb_simple = list("claw", "hiss", "tail slap")
	squeak_override = list('sound/items/weapons/slash.ogg' = 1)

/obj/item/toy/plush/lizard_plushie/Initialize(mapload)
	. = ..()
	if(!greyscale_colors)
		// Generate a random valid lizard color for our plushie friend
		var/generated_lizard_color = "#" + random_color()
		var/list/lizard_hsv = rgb2hsv(generated_lizard_color)

		// If our color is too dark, use the classic green lizard plush color
		if(lizard_hsv[3] < 50)
			generated_lizard_color = "#66ff33"

		// Set our greyscale colors to the lizard color we made + black eyes
		set_greyscale(colors = list(generated_lizard_color, COLOR_BLACK))

// Preset lizard plushie that uses the original lizard plush green. (Or close to it)
/obj/item/toy/plush/lizard_plushie/green
	desc = "An adorable stuffed toy that resembles a green lizardperson. This one fills you with nostalgia and soul."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/toy/plush/lizard_plushie/green"
	post_init_icon_state = "map_plushie_lizard"
	greyscale_colors = "#66ff33#000000"

/obj/item/toy/plush/lizard_plushie/greyscale
	desc = "An adorable stuffed toy that resembles a lizardperson. This one has been custom made."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/toy/plush/lizard_plushie/greyscale"
	post_init_icon_state = "map_plushie_lizard"
	greyscale_colors = "#d3d3d3#000000"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/toy/plush/lizard_plushie/space
	name = "space lizard plushie"
	desc = "An adorable stuffed toy that resembles a very determined spacefaring lizardperson. To infinity and beyond, little guy."
	icon_state = "map_plushie_spacelizard"
	greyscale_config = /datum/greyscale_config/plush_spacelizard
	// space lizards can't hit people with their tail, it's stuck in their suit
	attack_verb_continuous = list("claws", "hisses", "bops")
	attack_verb_simple = list("claw", "hiss", "bop")

/obj/item/toy/plush/lizard_plushie/space/green
	desc = "An adorable stuffed toy that resembles a very determined spacefaring green lizardperson. To infinity and beyond, little guy. This one fills you with nostalgia and soul."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/toy/plush/lizard_plushie/space/green"
	post_init_icon_state = "map_plushie_spacelizard"
	greyscale_colors = "#66ff33#000000"

/obj/item/toy/plush/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/toy/plush/snakeplushie"
	post_init_icon_state = "map_plushie_snake"
	greyscale_config = /datum/greyscale_config/plush_snake
	greyscale_colors = "#99ff99#000000"
	inhand_icon_state = null
	attack_verb_continuous = list("bites", "hisses", "tail slaps")
	attack_verb_simple = list("bite", "hiss", "tail slap")
	squeak_override = list('sound/items/weapons/bite.ogg' = 1)

/obj/item/toy/plush/nukeplushie
	name = "operative plushie"
	desc = "A stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"
	inhand_icon_state = null
	attack_verb_continuous = list("shoots", "nukes", "detonates")
	attack_verb_simple = list("shoot", "nuke", "detonate")
	squeak_override = list('sound/effects/hit_punch.ogg' = 1)

/obj/item/toy/plush/plasmamanplushie
	name = "plasmaman plushie"
	desc = "A stuffed toy that resembles your purple coworkers. Mmm, yeah, in true plasmaman fashion, it's not cute at all despite the designer's best efforts."
	icon_state = "plushie_pman"
	inhand_icon_state = null
	attack_verb_continuous = list("burns", "space beasts", "fwooshes")
	attack_verb_simple = list("burn", "space beast", "fwoosh")
	squeak_override = list('sound/effects/extinguish.ogg' = 1)

/obj/item/toy/plush/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/toy/plush/slimeplushie"
	post_init_icon_state = "map_plushie_slime"
	greyscale_config = /datum/greyscale_config/plush_slime
	greyscale_colors = "#aaaaff#000000"
	inhand_icon_state = null
	attack_verb_continuous = list("blorbles", "slimes", "absorbs")
	attack_verb_simple = list("blorble", "slime", "absorb")
	squeak_override = list('sound/effects/blob/blobattack.ogg' = 1)
	gender = FEMALE //given all the jokes and drawings, I'm not sure the xenobiologists would make a slimeboy

// This is supposed to be only in the bus ruin, don't spawn it elsewhere
/obj/item/toy/plush/awakenedplushie
	name = "awakened plushie"
	desc = "An ancient plushie that has grown enlightened to the true nature of reality."
	icon_state = "plushie_awake"
	inhand_icon_state = null

/obj/item/toy/plush/awakenedplushie/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/edit_complainer)

/obj/item/toy/plush/whiny_plushie
	name = "whiny plushie"
	desc = "An ancient plushie that demands constant companionship, after being forgotten for too long."
	icon_state = "plushie_whiny"
	inhand_icon_state = null
	/// static list of cry messages it picks from to speak when it is insecure from no movement
	var/static/list/cry_still_messages
	/// static list of cry messages it picks from to speak when it is insecure from no holder
	var/static/list/cry_alone_messages
	/// cooldown for it sending messages, it will every 10 seconds
	COOLDOWN_DECLARE(cry_cooldown)

/obj/item/toy/plush/whiny_plushie/Initialize(mapload)
	. = ..()
	if(!cry_still_messages)
		cry_still_messages = list(
			"WHY DID WE STOP MOVING?! ARE YOU GOING TO LEAVE ME?!!",
			"WE COULD GET ATTACKED WE'RE SITTING DUCKS MOVE MOOOOOOOVE!!",
			"YOU'RE PLANNING ON DROPPING ME AREN'T YOU I KNOW YOU AAAAAAAREE!!",
			"THE SYNDICATE ARE TRIANGULATING OUR LOCAAAAAAAATIONNN!!",
			"THIS PLACE IS SCARY I WANNA LEEEEEAAAAAVVVEEEEEE!!",
			"CHELP, CHELP CCCCHHHHEEEEEEEEEEEEEEELLLLLLLPPPPPP!!",
		)
		cry_alone_messages = list(
			"NOOOOOOOOOOOOOOOOOO DON'T LEAVE MEEEEE!!",
			"WUH WHERE DID EVERYONE GOOOOOOHHHHHHH WAHHH!!",
			"SOMEONE, ANYONEEEEEEEEE PICK ME UPP!!",
			"I DIDN'T DESERVE ITTTTTTTTTT!!",
			"I WILL DIE TO JUST ONE ATTTTTTAAAAACKKKKKK!!",
			"I WILLLLLL NOT DROP GOOOD IITITTEEEEEMMMS!!",
		)
	AddComponent(/datum/component/keep_me_secure, CALLBACK(src, PROC_REF(secured_process)) , CALLBACK(src, PROC_REF(unsecured_process)), 0)

/obj/item/toy/plush/whiny_plushie/proc/secured_process(last_move)
	icon_state = initial(icon_state)

/obj/item/toy/plush/whiny_plushie/proc/unsecured_process(last_move)
	if(!COOLDOWN_FINISHED(src, cry_cooldown))
		return
	COOLDOWN_START(src, cry_cooldown, 10 SECONDS)
	icon_state = "plushie_whiny_crying"
	if(isturf(loc))
		say(pick(cry_alone_messages))
	else
		say(pick(cry_still_messages))
	playsound(src, 'sound/items/intents/Help.ogg', 50, FALSE)

/obj/item/toy/plush/beeplushie
	name = "bee plushie"
	desc = "A cute toy that resembles an even cuter bee."
	icon_state = "plushie_h"
	inhand_icon_state = null
	attack_verb_continuous = list("stings")
	attack_verb_simple = list("sting")
	gender = FEMALE
	squeak_override = list('sound/mobs/humanoids/moth/scream_moth.ogg'=1)

/obj/item/toy/plush/moth
	name = "moth plushie"
	desc = "A plushie depicting an adorable mothperson. It's a huggable bug!"
	icon_state = "moffplush"
	inhand_icon_state = null
	attack_verb_continuous = list("flutters", "flaps")
	attack_verb_simple = list("flutter", "flap")
	squeak_override = list('sound/mobs/humanoids/moth/scream_moth.ogg'=1)
///Used to track how many people killed themselves with item/toy/plush/moth
	var/suicide_count = 0

/obj/item/toy/plush/moth/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] stares deeply into the eyes of [src] and it begins consuming [user.p_them()]!  It looks like [user.p_theyre()] trying to commit suicide!"))
	suicide_count++
	if(suicide_count < 3)
		desc = "A plushie depicting an unsettling mothperson. After killing [suicide_count] [suicide_count == 1 ? "person" : "people"] it's not looking so huggable now..."
	else
		desc = "A plushie depicting a creepy mothperson. It's killed [suicide_count] people! I don't think I want to hug it any more!"
		divine = TRUE
		resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	playsound(src, 'sound/effects/hallucinations/wail.ogg', 50, TRUE, -1)
	var/list/available_spots = get_adjacent_open_turfs(loc)
	if(available_spots.len) //If the user is in a confined space the plushie will drop normally as the user dies, but in the open the plush is placed one tile away from the user to prevent squeak spam
		var/turf/open/random_open_spot = pick(available_spots)
		forceMove(random_open_spot)
	user.dust(just_ash = FALSE, drop_items = TRUE)
	return MANUAL_SUICIDE

/obj/item/toy/plush/pkplush
	name = "peacekeeper plushie"
	desc = "A plushie depicting a peacekeeper cyborg. Only you can prevent human harm!"
	icon_state = "pkplush"
	attack_verb_continuous = list("hugs", "squeezes")
	attack_verb_simple = list("hug", "squeeze")
	squeak_override = list('sound/items/weapons/thudswoosh.ogg'=1)

/obj/item/toy/plush/rouny
	name = "runner plushie"
	desc = "A plushie depicting a xenomorph runner, made to commemorate the centenary of the Battle of LV-426. Much cuddlier than the real thing."
	icon_state = "rouny"
	item_flags = XENOMORPH_HOLDABLE
	inhand_icon_state = null
	attack_verb_continuous = list("slashes", "bites", "charges")
	attack_verb_simple = list("slash", "bite", "charge")
	squeak_override = list('sound/items/intents/Help.ogg' = 1)

/obj/item/toy/plush/abductor
	name = "abductor plushie"
	desc = "A plushie depicting an alien abductor. The tag on it is in an indecipherable language."
	icon_state = "abductor"
	inhand_icon_state = null
	attack_verb_continuous = list("abducts", "probes")
	attack_verb_continuous = list("abduct", "probe")
	squeak_override = list('sound/ambience/weather/ashstorm/inside/weak_end.ogg' = 1) //very faint sound since abductors are silent as far as "speaking" is concerned.

/obj/item/toy/plush/abductor/agent
	name = "abductor agent plushie"
	desc = "A plushie depicting an alien abductor agent. The stun baton is attached to the hand of the plushie, and appears to be inert. I wouldn't stay alone with it."
	icon_state = "abductor_agent"
	inhand_icon_state = null
	attack_verb_continuous = list("abducts", "probes", "stuns")
	attack_verb_continuous = list("abduct", "probe", "stun")
	squeak_override = list(
		'sound/items/weapons/egloves.ogg' = 2,
		'sound/items/weapons/cablecuff.ogg' = 1,
	)

/obj/item/toy/plush/shark
	name = "shark plushie"
	desc = "A plushie depicting a somewhat cartoonish shark. The tag calls it a 'hákarl', noting that it was made by an obscure furniture manufacturer in old Scandinavia."
	lefthand_file = 'icons/mob/inhands/items/plushes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/plushes_righthand.dmi'
	icon_state = "blahaj"
	inhand_icon_state = "blahaj"
	attack_verb_continuous = list("gnaws", "gnashes", "chews")
	attack_verb_simple = list("gnaw", "gnash", "chew")

/obj/item/toy/plush/donkpocket
	name = "donk pocket plushie"
	desc = "The stuffed companion of choice for the seasoned traitor."
	icon_state = "donkpocket"
	attack_verb_continuous = list("donks")
	attack_verb_simple = list("donk")

/obj/item/toy/plush/human
	name = "human plushie"
	desc = "This is a felt plush of a human. All craftsmanship is of the lowest quality. The human is crying. The human is screaming."
	icon_state = "plushie_human"
	inhand_icon_state = null //i would rather not have a blue coder plushie inhand
	attack_verb_continuous = list("screams at", "strikes", "bashes")
	attack_verb_simple = list("scream at", "strike", "bash")
	squeak_override = list(
		'sound/mobs/humanoids/human/scream/malescream_2.ogg' = 10, //10% chance to scream, rare but not abysmal
		'sound/items/weapons/smash.ogg' = 90,
		)

/obj/item/toy/plush/horse
	name = "horse plushie"
	desc = "A squishy soft horse plushie. This one is bay with white socks."
	icon_state = "horse"
	attack_verb_continuous = list("whinnies", "gallops", "prances", "horses")  // Yes I'm using horse as a verb
	attack_verb_simple = list("whinny", "gallop", "prance", "horse")

/obj/item/toy/plush/unicorn
	name = "unicorn plushie"
	desc = "A squishy soft unicorn plushie. It has a magical aura."
	icon_state = "unicorn"
	attack_verb_continuous = list("whinnies", "gallops", "prances", "magicks")
	attack_verb_simple = list("whinny", "gallop", "prance", "magick")

/obj/item/toy/plush/monkey
	name = "monkey plushie"
	desc = "The tag reads: 'Oop eek! I'm a chimpanzee!', with 'Now in JUMBO SIZE!' on the flipside."
	w_class = WEIGHT_CLASS_BULKY
	throw_range = 2
	throw_speed = 1
	icon_state = "monkey"
	inhand_icon_state = null
	attack_verb_continuous = list("Oops", "Eeks")
	attack_verb_simple = list("Oop", "Eek")
	squeak_override = list(SFX_SCREECH=1)
	/// if the monkey ate a mimana and has changed nationality
	var/french = FALSE

/obj/item/toy/plush/monkey/item_interaction(mob/living/feeder, obj/item/food/grown/banana/nana, list/modifiers)
	if(!istype(nana))
		return ..()
	nana.forceMove(src) // go into the cotton stomach
	to_chat(feeder, span_notice("You hand over the [nana] to [src] and watch as it eats..."))
	playsound(src, 'sound/items/eatfood.ogg', 75, TRUE)
	addtimer(CALLBACK(src, PROC_REF(eat), feeder, nana), 3 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/item/toy/plush/monkey/proc/eat(mob/living/feeder, obj/item/food/grown/banana/nana)
	if(istype(nana, /obj/item/food/grown/banana/bluespace))
		do_teleport(src, get_turf(src), 15, channel = TELEPORT_CHANNEL_BLUESPACE)
	else if(istype(nana, /obj/item/food/grown/banana/mime) && !french)
		name = "peluche de singe"
		desc = "L'étiquette indique: 'Oop eek! Je suis un chimpanzé!', avec 'Maintenant en TAILLE JUMBO!' sur l'autre face."
		french = TRUE
	// throw the peel at a random mob, or a random turf if there are none
	var/obj/item/grown/bananapeel/peel = new nana.trash_type(get_turf(src))
	var/list/oviewers = oviewers(peel.throw_range, src)
	var/throw_src = src
	// if a player holds the plushie, the throw source will be the player
	if(isliving(loc))
		oviewers = oviewers(loc)
		throw_src = loc
	if(oviewers.len > 0 && (locate(feeder) in oviewers))
		oviewers -= feeder // remove feeder from targetables
	peel.throw_at(oviewers.len == 0 ? get_ranged_target_turf(throw_src, pick(GLOB.alldirs), peel.throw_range) : pick(oviewers), peel.throw_range, peel.throw_speed, quickstart = FALSE)
	playsound(src, 'sound/mobs/non-humanoids/gorilla/gorilla.ogg', 100, FALSE)
	spasm_animation(5 SECONDS)
	qdel(nana)
