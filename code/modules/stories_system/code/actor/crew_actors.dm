/// Crew actors are actors chosen from the crew, ie. existing, on-station players.
/datum/story_actor/crew

/datum/story_actor/crew/handle_spawning(mob/living/carbon/human/picked_spawner, datum/story_type/current_story)
	. = ..()
	if(!.)
		return FALSE
	if(length(actor_outfits))
		picked_spawner.equipOutfit(pick(actor_outfits))
	current_story.mind_actor_list[picked_spawner.mind] = src
	if(inform_player) // If they aren't aware they're in a story, we don't want to spoil it by showing them the info!
		info_button = new(src)
		info_button.Grant(picked_spawner)


/datum/story_actor/crew/mob_debt
	name = "Mob Debtor"
	actor_info = "You were in a bit of a rough spot, so you got a loan from a guy you knew's friend, more than you could ever pay back. Not like they'll be looking for you all the way out here, heheh."

/datum/story_actor/crew/mob_debt/handle_spawning(mob/living/carbon/human/picked_spawner, datum/story_type/current_story)
	. = ..()
	if(istype(current_story, /datum/story_type/somewhat_impactful/mob_money))
		var/datum/story_type/somewhat_impactful/mob_money/mob_plot = current_story
		mob_plot.poor_sod = picked_spawner

/datum/story_actor/crew/ominous
	name = "Ominous"
	actor_info = "You never meant for it to end like that.\n\n\
	You did everything you could, but it still wasn't enough. Even today, the memories of that moment stalk you like a killer. \
	Yet words fail you whenever you try to talk about it, it was just that horrifying. You'll never be the same… and you're certain to make everyone aware of the fact."
	actor_goal = "Survive the shift. Provide helpful advice. Constantly make references to 'the event'."

/datum/story_actor/crew/apprentice
	name = "Apprentice"
	actor_info = "Long have you trained, and at last the day is upon you!\n\n\
	You've scoured the SpaceNet for every crumb of information, thrown yourself at the foot of every Zoldorf machine, and attended one too many Astrology classes. \
	But now, the power rests within you. The pathways of destiny have been made clear, and at last, you understand how to bend fate to your whims… \
	so long as there are some credits to be had."
	actor_goal = "Perform Tarot readings. “Accurately” predict the future. Survive the shift (with pockets full of credits)."

/datum/story_actor/crew/apprentice/handle_spawning(mob/living/carbon/human/picked_spawner, datum/story_type/current_story)
	. = ..()
	picked_spawner.put_in_hands(new /obj/item/toy/cards/deck/tarot, ignore_animation = TRUE)

/datum/story_actor/crew/smuggler
	name = "Smuggler"
	actor_info = "With the space economy in the shitter, you're always looking for new opportunities to prolong your existence just a little longer. \
	Looks like the gods of the free market have answered your prayers. A message from an anonymous client, who is interested in 'luxury' goods only found in your place of work. \
	If you can sneak them off the station, you'll be in for a massive payday…\n\n\
	There's just one caveat. The client wants you to steal them."
	actor_goal = "Acquire the following items through a spree of minor theft, the likes of which has never been pulled off: %ITEM1%, %ITEM2%, %ITEM3%, %ITEM4%, %ITEM5%. \
	Don't get caught."
	/// List of potential steal objectives. Note from the author:
	/// The items the Smuggler has to steal are extremely generic and not at all illegal. The Smuggler should have no problem obtaining them.
	/// The ‘fun’ comes from having to steal them, as opposed to making or buying them.
	var/list/potential_steal_objectives = list(
		/obj/item/pen,
		/obj/item/clothing/head/utility/chefhat,
		/obj/item/clothing/shoes,
		/obj/item/storage/toolbox,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/medical/suture,
		/obj/item/stack/medical/mesh,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/clothing/head/utility/hardhat,
		/obj/item/flashlight,
		/obj/item/stamp,
		/obj/item/storage/bag/trash,
		/obj/item/clothing/head/beret/sec,
		/obj/item/clothing/glasses,
		/obj/item/banner,
		/obj/item/holosign_creator,
		/obj/item/bikehorn
	)

/datum/story_actor/crew/smuggler/handle_spawning(mob/living/carbon/human/picked_spawner, datum/story_type/current_story)
	for(var/i in 1 to 5)
		var/obj/item/item_picked = pick_n_take(potential_steal_objectives)
		actor_goal = replacetext(actor_goal, "%ITEM[i]%", initial(item_picked.name))
	. = ..()

/datum/story_actor/crew/coffee_critic
	name = "Coffee Critic"
	actor_info = "Ever since those aromas brushed your senses and tantalized your tongue, you haven't been able to stop thinking about it. \
	The smoky sweetness, the flowery bitterness, and the scalding third-degree burns it left in its wake. You must have it once more. \
	Yet no one else has been able to brew it. Perhaps this place will be different…"
	actor_goal = "Find someone who can make the perfect brew of coffee. Relentlessly insult the drink if it isn't up to snuff. \
	Maintain the guise of a galaxy-renowned coffee critic."

/datum/story_actor/crew/salesperson
	name = "Salesperson"
	actor_info = "Others have tried to steer you from this path, but you know the truth. Toxic medical corporations have filled their “cures” with dangerous poisons. \
	How many people have walked into a clinic for a checkup, only to leave with a Swedish accent? Thankfully, you're here with miracles in bottles, \
	ready to put an end to any sickness… for a nominal fee."
	actor_goal = "Sell your entire stock of alternative medicine! Don't get shut down!"
	/// List of snake oils to give the salesperson.
	var/list/snake_oil = list(
		/obj/item/reagent_containers/cup/glass/bottle/snake_oil/revitalize,
		/obj/item/reagent_containers/cup/glass/bottle/snake_oil/rebirth,
		/obj/item/reagent_containers/cup/glass/bottle/snake_oil/renewal,
		/obj/item/reagent_containers/cup/glass/bottle/snake_oil/resurrection,
		/obj/item/reagent_containers/cup/glass/bottle/snake_oil/resurgence,
	)

/datum/story_actor/crew/salesperson/handle_spawning(mob/living/carbon/human/picked_spawner, datum/story_type/current_story)
	. = ..()
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)
	for(var/bottle_type in snake_oil)
		var/obj/item/snake_oil_spawned = new snake_oil(get_turf(picked_spawner))
		picked_spawner.equip_in_one_of_slots(snake_oil_spawned, slots)

/datum/story_actor/crew/visionist
	name = "Visionist"
	actor_info = "The cold flash of an energy gun. The rush of flames and heat. That one time you broke wind on a bible. You've been here before. \
	Are you trapped in a simulation? An endless loop of life and death? Or have you been spending too much time near Misama clouds? Even so, you can't shake this sense of dread \
	and doom. The station is cursed. Something bad is going to happen… and you're not sure you can stop it."
	actor_goal = "Survive the shift. Try and stop bad things from happening."

/datum/story_actor/crew/multiverse_researcher
	name = "Multiverse Researcher"
	actor_info = "Vindication! At long last!\n\n\
	They called you crazy. Insane. Declared your ideas unfit for 'safe and sane scientific practice'. But soon you'll be the one laughing. After months of sleepless nights, \
	you've finally completed your 'Multiversal Positioning Tracker'. And what luck, it has activated! There's a visitor from another world, somewhere aboard the station…\n\n\
	The multiversal theory is about to be proven."
	actor_goal = "Find the visitor from another world. Study them. Get their autograph."

/datum/story_actor/crew/multiverse_researcher/handle_spawning(mob/living/carbon/human/picked_spawner, datum/story_type/current_story)
	. = ..()
	picked_spawner.put_in_hands(new /obj/item/locator, ignore_animation = TRUE)
