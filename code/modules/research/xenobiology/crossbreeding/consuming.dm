/*
Consuming extracts:
	Can eat food items.
	After consuming enough, produces special cookies.
*/
/obj/item/slimecross/consuming
	name = "consuming extract"
	desc = "It hungers... for <i>more</i>." //My slimecross has finally decided to eat... my buffet!
	icon_state = "consuming"
	effect = "consuming"
	var/nutriment_eaten = 0
	var/nutriment_required = 10
	var/cooldown = 600 //1 minute.
	var/last_produced = 0
	var/cookies = 5 //Number of cookies to spawn
	var/cookietype = /obj/item/slime_cookie

/obj/item/slimecross/consuming/attackby(obj/item/O, mob/user)
	if(IS_EDIBLE(O))
		if(last_produced + cooldown > world.time)
			to_chat(user, span_warning("[src] is still digesting after its last meal!"))
			return
		var/datum/reagent/N = O.reagents.has_reagent(/datum/reagent/consumable/nutriment)
		if(N)
			nutriment_eaten += N.volume
			to_chat(user, span_notice("[src] opens up and swallows [O] whole!"))
			qdel(O)
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
		else
			to_chat(user, span_warning("[src] burbles unhappily at the offering."))
		if(nutriment_eaten >= nutriment_required)
			nutriment_eaten = 0
			user.visible_message(span_notice("[src] swells up and produces a small pile of cookies!"))
			playsound(src, 'sound/effects/splat.ogg', 40, TRUE)
			last_produced = world.time
			for(var/i in 1 to cookies)
				var/obj/item/S = spawncookie()
				S.pixel_x = base_pixel_x + rand(-5, 5)
				S.pixel_y = base_pixel_y + rand(-5, 5)
		return
	..()

/obj/item/slimecross/consuming/proc/spawncookie()
	return new cookietype(get_turf(src))

/obj/item/slime_cookie //While this technically acts like food, it's so removed from it that I made it its' own type.
	name = "error cookie"
	desc = "A weird slime cookie. You shouldn't see this."
	icon = 'icons/obj/food/slimecookies.dmi'
	var/taste = "error"
	var/nutrition = 5
	icon_state = "base"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6

/obj/item/slime_cookie/proc/do_effect(mob/living/M, mob/user)
	return

/obj/item/slime_cookie/attack(mob/living/M, mob/user)
	var/fed = FALSE
	if(M == user)
		M.visible_message(span_notice("[user] eats [src]!"), span_notice("You eat [src]."))
		fed = TRUE
	else
		M.visible_message(span_danger("[user] tries to force [M] to eat [src]!"), span_userdanger("[user] tries to force you to eat [src]!"))
		if(do_after(user, 2 SECONDS, target = M))
			fed = TRUE
			M.visible_message(span_danger("[user] forces [M] to eat [src]!"), span_warning("[user] forces you to eat [src]."))
	if(fed)
		var/mob/living/carbon/human/H = M

		if(!istype(H) || !HAS_TRAIT(H, TRAIT_AGEUSIA))
			to_chat(M, span_notice("Tastes like [taste]."))
		playsound(get_turf(M), 'sound/items/eatfood.ogg', 20, TRUE)
		if(nutrition)
			M.reagents.add_reagent(/datum/reagent/consumable/nutriment,nutrition)
		do_effect(M, user)
		qdel(src)
		return
	..()

/obj/item/slimecross/consuming/grey
	colour = SLIME_TYPE_GREY
	effect_desc = "Creates a slime cookie."
	cookietype = /obj/item/slime_cookie/grey

/obj/item/slime_cookie/grey
	name = "slime cookie"
	desc = "A grey-ish transparent cookie. Nutritious, probably."
	icon_state = "grey"
	taste = "goo"
	nutrition = 15

/obj/item/slimecross/consuming/orange
	colour = SLIME_TYPE_ORANGE
	effect_desc = "Creates a slime cookie that heats the target up and grants cold immunity for a short time."
	cookietype = /obj/item/slime_cookie/orange

/obj/item/slime_cookie/orange
	name = "fiery cookie"
	desc = "An orange cookie with a fiery pattern. Feels warm."
	icon_state = "orange"
	taste = "cinnamon and burning"

/obj/item/slime_cookie/orange/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/firecookie)

/obj/item/slimecross/consuming/purple
	colour = SLIME_TYPE_PURPLE
	effect_desc = "Creates a slime cookie that heals the target from every type of damage."
	cookietype = /obj/item/slime_cookie/purple

/obj/item/slime_cookie/purple
	name = "health cookie"
	desc = "A purple cookie with a cross pattern. Soothing."
	icon_state = "purple"
	taste = "fruit jam and cough medicine"

/obj/item/slime_cookie/purple/do_effect(mob/living/M, mob/user)
	var/need_mob_update = FALSE
	need_mob_update += M.adjustBruteLoss(-5, updating_health = FALSE)
	need_mob_update += M.adjustFireLoss(-5, updating_health = FALSE)
	need_mob_update += M.adjustToxLoss(-5, updating_health = FALSE, forced = TRUE) //To heal slimepeople.
	need_mob_update += M.adjustOxyLoss(-5, updating_health = FALSE)
	need_mob_update += M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -5)
	if(need_mob_update)
		M.updatehealth()

/obj/item/slimecross/consuming/blue
	colour = SLIME_TYPE_BLUE
	effect_desc = "Creates a slime cookie that wets the floor around you and makes you immune to water based slipping for a short time."
	cookietype = /obj/item/slime_cookie/blue

/obj/item/slime_cookie/blue
	name = "water cookie"
	desc = "A transparent blue cookie. Constantly dripping wet."
	icon_state = "blue"
	taste = "water"

/obj/item/slime_cookie/blue/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/watercookie)

/obj/item/slimecross/consuming/metal
	colour = SLIME_TYPE_METAL
	effect_desc = "Creates a slime cookie that increases the target's resistance to brute damage."
	cookietype = /obj/item/slime_cookie/metal

/obj/item/slime_cookie/metal
	name = "metallic cookie"
	desc = "A shiny grey cookie. Hard to the touch."
	icon_state = "metal"
	taste = /datum/reagent/copper

/obj/item/slime_cookie/metal/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/metalcookie)

/obj/item/slimecross/consuming/yellow
	colour = SLIME_TYPE_YELLOW
	effect_desc = "Creates a slime cookie that makes the target immune to electricity for a short time."
	cookietype = /obj/item/slime_cookie/yellow

/obj/item/slime_cookie/yellow
	name = "sparking cookie"
	desc = "A yellow cookie with a lightning pattern. Has a rubbery texture."
	icon_state = "yellow"
	taste = "lemon cake and rubber gloves"

/obj/item/slime_cookie/yellow/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/sparkcookie)

/obj/item/slimecross/consuming/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	effect_desc = "Creates a slime cookie that reverses how the target's body treats toxins."
	cookietype = /obj/item/slime_cookie/darkpurple

/obj/item/slime_cookie/darkpurple
	name = "toxic cookie"
	desc = "A dark purple cookie, stinking of plasma."
	icon_state = "darkpurple"
	taste = "slime jelly and toxins"

/obj/item/slime_cookie/darkpurple/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/toxincookie)

/obj/item/slimecross/consuming/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	effect_desc = "Creates a slime cookie that chills the target and extinguishes them."
	cookietype = /obj/item/slime_cookie/darkblue

/obj/item/slime_cookie/darkblue
	name = "frosty cookie"
	desc = "A dark blue cookie with a snowflake pattern. Feels cold."
	icon_state = "darkblue"
	taste = "mint and bitter cold"

/obj/item/slime_cookie/darkblue/do_effect(mob/living/M, mob/user)
	M.adjust_bodytemperature(-110)
	M.extinguish_mob()

/obj/item/slimecross/consuming/silver
	colour = SLIME_TYPE_SILVER
	effect_desc = "Creates a slime cookie that never gets the target fat."
	cookietype = /obj/item/slime_cookie/silver

/obj/item/slime_cookie/silver
	name = "waybread cookie"
	desc = "A warm, crispy cookie, sparkling silver in the light. Smells wonderful."
	icon_state = "silver"
	taste = "masterful elven baking"
	nutrition = 0 //We don't want normal nutriment

/obj/item/slime_cookie/silver/do_effect(mob/living/M, mob/user)
	M.reagents.add_reagent(/datum/reagent/consumable/nutriment/stabilized,10)

/obj/item/slimecross/consuming/bluespace
	colour = SLIME_TYPE_BLUESPACE
	effect_desc = "Creates a slime cookie that teleports the target to a random place in the area."
	cookietype = /obj/item/slime_cookie/bluespace

/obj/item/slime_cookie/bluespace
	name = "space cookie"
	desc = "A white cookie with green icing. Surprisingly hard to hold."
	icon_state = "bluespace"
	taste = "sugar and starlight"

/obj/item/slime_cookie/bluespace/do_effect(mob/living/eater, mob/user)
	var/area/eater_area = get_area(eater)
	if (eater_area.area_flags & NOTELEPORT)
		fail_effect(eater)
		return

	var/list/area_turfs = get_area_turfs(get_area(get_turf(eater)))
	var/turf/target

	while (length(area_turfs))
		var/turf/check_turf = pick_n_take(area_turfs)
		if (is_centcom_level(check_turf.z))
			continue // Probably already filtered out by NOTELEPORT but let's just be careful
		if (check_turf.is_blocked_turf())
			continue
		target = check_turf
		break

	if (isnull(target))
		fail_effect(eater)
		return
	if (!do_teleport(eater, target, 0, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE))
		fail_effect(eater)
		return
	new /obj/effect/particle_effect/sparks(target)
	playsound(target, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/slime_cookie/bluespace/proc/fail_effect(mob/living/eater)
	eater.visible_message(
		message = span_warning("[eater] briefly vanishes... then slams forcefully into the ground"),
		self_message = span_warning("You briefly vanish... and are returned forcefully to the ground.")
	)
	eater.Knockdown(0.1 SECONDS)
	new /obj/effect/particle_effect/sparks(get_turf(eater))

/obj/item/slimecross/consuming/sepia
	colour = SLIME_TYPE_SEPIA
	effect_desc = "Creates a slime cookie that makes the target do things slightly faster."
	cookietype = /obj/item/slime_cookie/sepia

/obj/item/slime_cookie/sepia
	name = "time cookie"
	desc = "A light brown cookie with a clock pattern. Takes some time to chew."
	icon_state = "sepia"
	taste = "brown sugar and a metronome"

/obj/item/slime_cookie/sepia/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/timecookie)

/obj/item/slimecross/consuming/cerulean
	colour = SLIME_TYPE_CERULEAN
	effect_desc = "Creates a slime cookie that has a chance to make another once you eat it."
	cookietype = /obj/item/slime_cookie/cerulean
	cookies = 3 //You're gonna get more.

/obj/item/slime_cookie/cerulean
	name = "duplicookie"
	desc = "A cerulean cookie with strange proportions. It feels like it could break apart easily."
	icon_state = "cerulean"
	taste = "a sugar cookie"

/obj/item/slime_cookie/cerulean/do_effect(mob/living/M, mob/user)
	if(prob(50))
		to_chat(M, span_notice("A piece of [src] breaks off while you chew, and falls to the ground."))
		var/obj/item/slime_cookie/cerulean/C = new(get_turf(M))
		C.taste = taste + " and a sugar cookie"

/obj/item/slimecross/consuming/pyrite
	colour = SLIME_TYPE_PYRITE
	effect_desc = "Creates a slime cookie that randomly colors the target."
	cookietype = /obj/item/slime_cookie/pyrite

/obj/item/slime_cookie/pyrite
	name = "color cookie"
	desc = "A yellow cookie with rainbow-colored icing. Reflects the light strangely."
	icon_state = "pyrite"
	taste = "vanilla and " //Randomly selected color dye.
	var/colour = COLOR_WHITE

/obj/item/slime_cookie/pyrite/Initialize(mapload)
	. = ..()
	var/tastemessage = "paint remover"
	switch(rand(1,7))
		if(1)
			tastemessage = "red dye"
			colour = COLOR_RED
		if(2)
			tastemessage = "orange dye"
			colour = "#FFA500"
		if(3)
			tastemessage = "yellow dye"
			colour = COLOR_YELLOW
		if(4)
			tastemessage = "green dye"
			colour = COLOR_VIBRANT_LIME
		if(5)
			tastemessage = "blue dye"
			colour = COLOR_BLUE
		if(6)
			tastemessage = "indigo dye"
			colour = "#4B0082"
		if(7)
			tastemessage = "violet dye"
			colour = COLOR_MAGENTA
	taste += tastemessage

/obj/item/slime_cookie/pyrite/do_effect(mob/living/M, mob/user)
	M.add_atom_colour(colour,WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/consuming/red
	colour = SLIME_TYPE_RED
	effect_desc = "Creates a slime cookie that creates a spatter of blood on the floor, while also restoring some of the target's blood."
	cookietype = /obj/item/slime_cookie/red

/obj/item/slime_cookie/red
	name = "blood cookie"
	desc = "A red cookie, oozing a thick red fluid. Vampires might enjoy it."
	icon_state = "red"
	taste = "red velvet and iron"

/obj/item/slime_cookie/red/do_effect(mob/living/M, mob/user)
	new /obj/effect/decal/cleanable/blood(get_turf(M))
	playsound(get_turf(M), 'sound/effects/splat.ogg', 10, TRUE)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.blood_volume += 25 //Half a vampire drain.

/obj/item/slimecross/consuming/green
	colour = SLIME_TYPE_GREEN
	effect_desc = "Creates a slime cookie that is absolutely disgusting, makes the target vomit, however all reagent in their body are also removed."
	cookietype = /obj/item/slime_cookie/green

/obj/item/slime_cookie/green
	name = "gross cookie"
	desc = "A disgusting green cookie, seeping with pus. You kind of feel ill just looking at it."
	icon_state = "green"
	taste = "the contents of your stomach"

/obj/item/slime_cookie/green/do_effect(mob/living/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = 25)
	M.reagents.remove_all()

/obj/item/slimecross/consuming/pink
	colour = SLIME_TYPE_PINK
	effect_desc = "Creates a slime cookie that makes the target want to spread the love."
	cookietype = /obj/item/slime_cookie/pink

/obj/item/slime_cookie/pink
	name = "love cookie"
	desc = "A pink cookie with an icing heart. D'aww."
	icon_state = "pink"
	taste = "love and hugs"

/obj/item/slime_cookie/pink/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/lovecookie)

/obj/item/slimecross/consuming/gold
	colour = SLIME_TYPE_GOLD
	effect_desc = "Creates a slime cookie that has a gold coin inside."
	cookietype = /obj/item/slime_cookie/gold

/obj/item/slime_cookie/gold
	name = "gilded cookie"
	desc = "A buttery golden cookie, closer to a bread than anything. May good fortune find you."
	icon_state = "gold"
	taste = "sweet cornbread and wealth"

/obj/item/slime_cookie/gold/do_effect(mob/living/M, mob/user)
	var/obj/item/held = M.get_active_held_item() //This should be itself, but just in case...
	M.dropItemToGround(held)
	var/newcoin = /obj/item/coin/gold
	var/obj/item/coin/C = new newcoin(get_turf(M))
	playsound(get_turf(C), 'sound/items/coinflip.ogg', 50, TRUE)
	M.put_in_hand(C)

/obj/item/slimecross/consuming/oil
	colour = SLIME_TYPE_OIL
	effect_desc = "Creates a slime cookie that slows anyone next to the user."
	cookietype = /obj/item/slime_cookie/oil

/obj/item/slime_cookie/oil
	name = "tar cookie"
	desc = "An oily black cookie, which sticks to your hands. Smells like chocolate."
	icon_state = "oil"
	taste = "rich molten chocolate and tar"

/obj/item/slime_cookie/oil/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/tarcookie)

/obj/item/slimecross/consuming/black
	colour = SLIME_TYPE_BLACK
	effect_desc = "Creates a slime cookie that makes the target look like a spooky skeleton for a little bit."
	cookietype = /obj/item/slime_cookie/black

/obj/item/slime_cookie/black
	name = "spooky cookie"
	desc = "A pitch black cookie with an icing ghost on the front. Spooky!"
	icon_state = "black"
	taste = "ghosts and stuff"

/obj/item/slime_cookie/black/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/spookcookie)

/obj/item/slimecross/consuming/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	effect_desc = "Creates a slime cookie that makes the target, and anyone next to the target, pacifistic for a small amount of time."
	cookietype = /obj/item/slime_cookie/lightpink

/obj/item/slime_cookie/lightpink
	name = "peace cookie"
	desc = "A light pink cookie with a peace symbol in the icing. Lovely!"
	icon_state = "lightpink"
	taste = "strawberry icing and P.L.U.R" //Literal candy raver.

/obj/item/slime_cookie/lightpink/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/peacecookie)

/obj/item/slimecross/consuming/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	effect_desc = "Creates a slime cookie that increases the target's resistance to burn damage."
	cookietype = /obj/item/slime_cookie/adamantine

/obj/item/slime_cookie/adamantine
	name = "crystal cookie"
	desc = "A translucent rock candy in the shape of a cookie. Surprisingly chewy."
	icon_state = "adamantine"
	taste = "crystalline sugar and metal"

/obj/item/slime_cookie/adamantine/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/adamantinecookie)

/obj/item/slimecross/consuming/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_desc = "Creates a slime cookie that has the effect of a random cookie."

/obj/item/slimecross/consuming/rainbow/spawncookie()
	var/cookie_type = pick(subtypesof(/obj/item/slime_cookie))
	var/obj/item/slime_cookie/S = new cookie_type(get_turf(src))
	S.name = "rainbow cookie"
	S.desc = "A beautiful rainbow cookie, constantly shifting colors in the light."
	S.icon_state = "rainbow"
	return S
