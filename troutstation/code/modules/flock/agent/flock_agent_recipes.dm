/datum/flock_recipe
	var/obj/item/item
	VAR_PROTECTED/cost = 0
	var/time = 0
	var/desc = "HOW THE FUCK DID YOU GET THIS"

/proc/get_flock_recipe_cost(datum/flock_recipe/recipe)
	return recipe::cost + get_flock_item_resources(recipe::item)

/datum/flock_recipe/hat
	item = /obj/item/clothing/head/hats/flock_chameleon
	cost = 50
	time = 6 SECONDS
	desc = "Adaptive hat that can be taken into radiodive due to being entirely substrate based. For the discerning agent."

/datum/flock_recipe/jack
	item = /obj/item/flock_jack
	cost = 100
	time = 9 SECONDS
	desc = "Multifunctional albeit single-use tool for hacking into alien security. Slow and noisy."

/datum/flock_recipe/plushie
	item = /obj/item/toy/plush/flock_agent
	cost = 50
	time = 5 SECONDS
	desc = "Endearing effigy. Maybe it will make the crew nicer to you. Or redirect their ire."

/mob/living/basic/flock/agent/proc/create_recipe(datum/flock_recipe/recipe)
	if(internal_storage)
		to_chat(src, span_boldwarning("You can't make anything while you've got something in your storage!"))
		return FALSE
	var/cost = get_flock_recipe_cost(recipe)
	var/new_resources = resources - cost
	if(new_resources < 0)
		to_chat(src, span_boldwarning("You can't afford to make that!"))
		return FALSE
	resources -= cost
	SEND_SIGNAL(src, COMSIG_FLOCK_RESOURCES_CHANGED, resources)
	eat_mode_off() // don't want to start eating the thing we're making
	var/obj/item/flock_creation/creation = new(src)
	equip_to_slot_or_del(creation, ITEM_SLOT_DEX_STORAGE)
	addtimer(CALLBACK(src, PROC_REF(finish_recipe), recipe), recipe.time, TIMER_DELETE_ME)
	is_creating = TRUE

/mob/living/basic/flock/agent/proc/finish_recipe(datum/flock_recipe/recipe)
	if(!internal_storage || !istype(internal_storage, /obj/item/flock_creation)) // guess we changed our minds
		is_creating = FALSE
		// refund the resources
		var/cost = get_flock_recipe_cost(recipe)
		resources += cost
		return
	qdel(internal_storage)
	var/obj/item/created = new recipe.item(src)
	created.color = list(1,0,0,0,1,0,0,0,1,0,1,0.5)
	animate(created, color = null, time = 0.5 SECONDS)
	equip_to_slot_or_del(created, ITEM_SLOT_DEX_STORAGE)
	playsound(get_turf(src), 'troutstation/sound/effects/flock/flock_create.ogg', 40, TRUE, -5)
	src.visible_message(span_notice("[src] shakes a bit and makes a weird sound, like lots of tiny things smacking together into a larger thing."),
					span_good("You finish forming [internal_storage]!"),
					blind_message = span_hear("You hear the muffled sound of lots of tiny things smacking together into a larger thing."))
	is_creating = FALSE

/// Dummy item/effect to indicate we're making something in storage.
/obj/item/flock_creation
	name = "forming creation"
	desc = "I wouldn't touch this thing if you want it to finish."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT
