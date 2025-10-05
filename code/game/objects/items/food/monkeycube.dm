/obj/item/food/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bite_consumption = 12
	food_reagents = list(/datum/reagent/monkey_powder = 30)
	tastes = list("the jungle" = 1, "bananas" = 1)
	foodtypes = MEAT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	/// Mob typepath to spawn when expanding
	var/spawned_mob = /mob/living/carbon/human/species/monkey
	/// Whether we've been wetted and are expanding
	var/expanding = FALSE

/obj/item/food/monkeycube/attempt_pickup(mob/user)
	if(expanding)
		return FALSE
	return ..()

/obj/item/food/monkeycube/proc/Expand()
	if(expanding)
		return

	expanding = TRUE

	if(ismob(loc))
		var/mob/holder = loc
		holder.dropItemToGround(src)

	var/mob/spammer = get_mob_by_key(fingerprintslast)
	var/mob/living/bananas = new spawned_mob(drop_location(), TRUE, spammer) // funny that we pass monkey init args to non-monkey mobs, that's totally a future issue
	if (!QDELETED(bananas))
		if(faction)
			bananas.faction = faction

		visible_message(span_notice("[src] expands!"))
		bananas.log_message("spawned via [src], Last attached mob: [key_name(spammer)].", LOG_ATTACK)

		var/alpha_to = bananas.alpha
		var/matrix/scale_to = matrix(bananas.transform)
		bananas.alpha = 0
		bananas.transform = bananas.transform.Scale(0.1)
		animate(bananas, 0.5 SECONDS, alpha = alpha_to, transform = scale_to, easing = QUAD_EASING|EASE_OUT)

	else if (!spammer) // Visible message in case there are no fingerprints
		visible_message(span_notice("[src] fails to expand!"))
		return

	animate(src, 0.4 SECONDS, alpha = 0, transform = transform.Scale(0), easing = QUAD_EASING|EASE_IN)
	QDEL_IN(src, 0.5 SECONDS)

/obj/item/food/monkeycube/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is putting [src] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/eating_success = do_after(user, 1 SECONDS, src)
	if(QDELETED(user)) //qdeletion: the nuclear option of self-harm
		return SHAME
	if(!eating_success || QDELETED(src)) //checks if src is gone or if they failed to wait for a second
		user.visible_message(span_suicide("[user] chickens out!"))
		return SHAME
	if(HAS_TRAIT(user, TRAIT_NOHUNGER)) //plasmamen don't have saliva/stomach acid
		user.visible_message(span_suicide("[user] realizes [user.p_their()] body won't activate [src]!")
		,span_warning("Your body won't activate [src]..."))
		return SHAME
	playsound(user, 'sound/items/eatfood.ogg', rand(10, 50), TRUE)
	user.temporarilyRemoveItemFromInventory(src) //removes from hands, keeps in M
	addtimer(CALLBACK(src, PROC_REF(finish_suicide), user), 15) //you've eaten it, you can run now
	return MANUAL_SUICIDE

/obj/item/food/monkeycube/proc/finish_suicide(mob/living/user) ///internal proc called by a monkeycube's suicide_act using a timer and callback. takes as argument the mob/living who activated the suicide
	if(QDELETED(user) || QDELETED(src))
		return
	if(src.loc != user) //how the hell did you manage this
		to_chat(user, span_warning("Something happened to [src]..."))
		return
	Expand()
	user.visible_message(span_danger("[user]'s torso bursts open as a primate emerges!"))
	user.gib(DROP_BRAIN|DROP_BODYPARTS|DROP_ITEMS) // just remove the organs

/obj/item/food/monkeycube/syndicate
	faction = list(FACTION_NEUTRAL, ROLE_SYNDICATE)

/obj/item/food/monkeycube/gorilla
	name = "gorilla cube"
	desc = "A Waffle Corp. brand gorilla cube. Now with extra molecules!"
	bite_consumption = 20
	food_reagents = list(
		/datum/reagent/monkey_powder = 30,
		/datum/reagent/medicine/strange_reagent = 5,
	)
	tastes = list("the jungle" = 1, "bananas" = 1, "jimmies" = 1)
	spawned_mob = /mob/living/basic/gorilla

/obj/item/food/monkeycube/chicken
	name = "chicken cube"
	desc = "A new Nanotrasen classic, the chicken cube. Tastes like everything!"
	bite_consumption = 20
	food_reagents = list(
		/datum/reagent/consumable/eggyolk = 30,
		/datum/reagent/medicine/strange_reagent = 1,
	)
	tastes = list("chicken" = 1, "the country" = 1, "chicken bouillon" = 1)
	spawned_mob = /mob/living/basic/chicken

/obj/item/food/monkeycube/bee
	name = "bee cube"
	desc = "We were sure it was a good idea. Just add water."
	bite_consumption = 20
	food_reagents = list(
		/datum/reagent/consumable/honey = 10,
		/datum/reagent/toxin = 5,
		/datum/reagent/medicine/strange_reagent = 1,
	)
	tastes = list("buzzing" = 1, "honey" = 1, "regret" = 1)
	spawned_mob = /mob/living/basic/bee

/obj/item/food/monkeycube/dangerous_horse
	name = "a pony cube"
	desc = "This is a cube that, when water is added, creates a syndicate pony powerful enough to break the enemy's face!"
	bite_consumption = 10
	food_reagents = list(
		/datum/reagent/toxin = 15,
		/datum/reagent/medicine/strange_reagent = 1,
	)
	tastes = list("the loss of 5 TC" = 1, "eaten friend" = 1)
	spawned_mob = /mob/living/basic/pony/dangerous

/obj/item/food/monkeycube/random
	name = "monster cube"
	desc = "A cube that, when water is added, creates a random creature. Who knows what's inside?"
	food_reagents = list(
		/datum/reagent/toxin = 15,
		/datum/reagent/medicine/strange_reagent = 1,
	)

/obj/item/food/monkeycube/random/Initialize(mapload)
	. = ..()
	spawned_mob = pick_weight(list(
		/mob/living/basic/bear = 4,
		/mob/living/basic/bear/snow = 1,
		/mob/living/basic/blankbody = 2,
		/mob/living/basic/blob_minion/blobbernaut = 2,
		/mob/living/basic/blob_minion/spore = 2,
		/mob/living/basic/carp = 4,
		/mob/living/basic/carp/mega = 1,
		/mob/living/basic/creature = 2,
		/mob/living/basic/eyeball = 1,
		/mob/living/basic/gorilla = 5,
		/mob/living/basic/migo = 2,
		/mob/living/basic/mining/basilisk = 5,
		/mob/living/basic/mining/lobstrosity = 1,
		/mob/living/basic/mining/lobstrosity/lava = 4,
		/mob/living/basic/mining/wolf = 4,
		/mob/living/basic/pet/cat/feral = 1,
		/mob/living/basic/spider/giant = 5,
		/mob/living/basic/spider/giant/hunter = 1,
		/mob/living/basic/spider/giant/tank = 1,
		/mob/living/basic/spider/giant/tarantula = 1,
		/mob/living/basic/spider/giant/viper = 1,
	))
