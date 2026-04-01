/*!
 * Tier 4 knowledge: Combat related knowledge
 */

/datum/heretic_knowledge/spell/space_phase
	name = "Space Phase"
	desc = "Grants you Space Phase, a spell that allows you to move freely through space. \
		You can only phase in and out when you are on a space or misc turf."
	gain_text = "You feel like your body can move through space as if you where dust."

	action_to_add = /datum/action/cooldown/spell/jaunt/space_crawl
	cost = 2
	research_tree_icon_frame = 6
	drafting_tier = 4

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Allows you to transmute 3 rods, lungs, and any belt into an Unfathomable Curio - \
			a belt that can hold blades and items for rituals. Whilst worn it will veil you, \
			blocking one blow of incoming damage, at the cost of the veil. The veil will recharge itself out of combat."
	gain_text = "The mansus holds many a curio, some are not meant for the mortal eye."

	required_atoms = list(
		/obj/item/organ/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"
	drafting_tier = 4

/datum/heretic_knowledge/rust_sower
	name = "Rust Sower Grenade"
	desc = "Allows you to combine a chemical grenade casing and some moldy food to conjure a cursed grenade filled with Eldritch Rust, upon detonating it releases a huge cloud that blinds organics, rusts affected turfs and obliterates Silicons and Mechs."
	gain_text = "The choked vines of the Rusted Hills are burdened with such overripe fruits. It undoes the markers of progress, leaving a clean slate to work into new shapes."
	required_atoms = list(
		list(
			/obj/item/food/breadslice/moldy,
			/obj/item/food/badrecipe/moldy,
			/obj/item/food/deadmouse/moldy,
			/obj/item/food/pizzaslice/moldy,
			/obj/item/food/boiledegg/rotten,
			/obj/item/food/egg/rotten
		) = 1,
		/obj/item/grenade/chem_grenade = 1
	)
	result_atoms = list(/obj/item/grenade/chem_grenade/rust_sower)
	cost = 2
	research_tree_icon_path = 'icons/obj/weapons/grenade.dmi'
	research_tree_icon_state = "rustgrenade"
	drafting_tier = 4

/datum/heretic_knowledge/spell/crimson_cleave
	name = "Crimson Cleave"
	desc = "Grants you Crimson Cleave, a targeted spell which siphons health in a small AOE. Cleanses all wounds upon casting"
	gain_text = "At first I didn't understand these instruments of war, but the Priest \
				told me to use them regardless. Soon, he said, I would know them well."
	action_to_add = /datum/action/cooldown/spell/pointed/crimson_cleave
	cost = 2
	drafting_tier = 4

/datum/heretic_knowledge/rifle
	name = "Lionhunter's Rifle"
	desc = "Allows you to transmute a piece of wood, with hide \
		from any animal, and a camera to create the Lionhunter's rifle. \
		The Lionhunter's Rifle is a long ranged ballistic weapon with three shots. \
		These shots function as normal, albeit weak high-caliber munitions when fired from \
		close range or at inanimate objects. You can aim the rifle at distant foes, \
		causing the shot to mark your victim with your grasp and teleport you directly to them."
	gain_text = "I met an old man in an antique shop who wielded a very unusual weapon. \
		I could not purchase it at the time, but they showed me how they made it ages ago."
	required_atoms = list(
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/animalhide = 1,
		/obj/item/camera = 1,
	)
	result_atoms = list(/obj/item/gun/ballistic/rifle/lionhunter)
	cost = 2
	research_tree_icon_path = 'icons/obj/weapons/guns/ballistic.dmi'
	research_tree_icon_state = "goldrevolver"
	drafting_tier = 2

/datum/heretic_knowledge/rifle_ammo
	name = "Lionhunter Rifle Ammunition"
	desc = "Allows you to transmute 3 ballistic ammo casings (used or unused) of any caliber, \
		including shotgun shells to create an extra clip of ammunition for the Lionhunter Rifle."
	gain_text = "The weapon came with three rough iron balls, intended to be used as ammunition. \
		They were very effective, for simple iron, but used up quickly. I soon ran out. \
		No replacement munitions worked in their stead. It was peculiar in what it wanted."
	required_atoms = list(
		/obj/item/ammo_casing = 3,
	)
	result_atoms = list(/obj/item/ammo_box/speedloader/strilka310/lionhunter)
	cost = 0
	research_tree_icon_path = 'icons/obj/weapons/guns/ammo.dmi'
	research_tree_icon_state = "310_strip"

	/// A list of calibers that the ritual will deny. Only ballistic calibers are allowed.
	var/static/list/caliber_blacklist = list(
		CALIBER_LASER,
		CALIBER_ENERGY,
		CALIBER_FOAM,
		CALIBER_ARROW,
		CALIBER_HARPOON,
		CALIBER_HOOK,
	)

/datum/heretic_knowledge/rifle_ammo/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/obj/item/ammo_casing/casing in atoms)
		if(!(casing.caliber in caliber_blacklist))
			continue

		// Remove any casings in the caliber_blacklist list from atoms
		atoms -= casing

	// We removed any invalid casings from the atoms list,
	// return to allow the ritual to fill out selected atoms with the new list
	return TRUE

/datum/heretic_knowledge/here_in_my_garage
	name = "Knowledge to surpass materialistic things"
	desc = "Sacrifice your codex cicatrix, and a clean 5,000 credits worth of money, in order to summon something far less valuable than knowledge."
	gain_text = "Here in my garage, just bought this uhh, new Lamborghini here. It's fun to drive up here in the Hollywood Hills. But do you know what I like a lot more than materialistic things? Knowledge!...In fact, I am a lot more proud of these seven new bookshelves that I had to get installed, the whole 2000 new books that I've got. It's like...the billionaire Warren Buffet says: \"The more you learn, the more you earn.\". Now, maybe you've seen my Ted Ex talk where I talk about how I read a book a day- you know I read a book a day not to show off, once again, it's about the knowledge. The real reason I keep this Lamborghini here is that it's a reminder. A reminder that dreams are still possible. Because it wasn't that long ago that I was in a little town, across the country, sleepin'...on a couch, in a mobile home, with only $47 in my bank account. I didn't have a college degree. I had no opportunities. But you know what? Something happened that changed my life. I bumped into a mentor. And another mentor. And a few more mentors later I found FIVE mentors. And they showed me what THEY did- to become multi-millionaires. Again, it's not just about the money, it's about the good life: health, wealth, love and happiness. So I recorded a little video, it's actually on my website you can click here, on this video and it will take you to my website where I share THREE things that they taught me. THREE things that you can implement today, no matter where you are. Now, this isn't a \"get rich quick\" scheme. You know, like they say. If it sounds too good to be true, they are too good to be true. I'm not promising you that TOMORROW you will be able to go out and buy a Lamborghini- but what I am telling you is that it can happen faster than you think if you know the proven steps! So, I recorded a little 2 minute video on my website, uhh, like I said it's not the most professional, I just shot it here with my iPhone, but it's real. Nobody can argue that this is mine. True story. And I'mma give you...the three most important things you can do today. So click the link, go there. It's completely free to watch. It's just a couple minutes. Invest it in yourself. Always be curious. Don't be a cynic. Okay? People see videos like this and they say \"uhh that\'s not for me, that\'s for somebody else\". DON\'T LISTEN! Don\'t listen! Be an optimist! Like Conrad Hilton, the man who started Hilton Hotel, he said...that when he was 15 year old, he read a book by Helen Keller. And that book changed his life. Books can change your life and in that book, Helen Keller said: \"Optimism\". So, if you're a pessimist, if you're a cynic, you don't have to click here."

	required_atoms = list(
		/obj/item/codex_cicatrix = 1,
	)
	result_atoms = list(/obj/vehicle/sealed/car/speedwagon)
	cost = 2
	research_tree_icon_path = 'icons/obj/weapons/sword.dmi'
	research_tree_icon_state = "v8_engine"
	drafting_tier = 4

/datum/heretic_knowledge/here_in_my_garage/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()

	var/total = 0
	for(var/obj/item/valuables as anything in atoms)
		if(!isitem(valuables))
			continue
		var/subtotal = valuables.get_item_credit_value()
		if(subtotal > 0)
			selected_atoms += valuables
			total += subtotal

	if(total < 5000)
		loc.balloon_alert(user, "come back when you're a little, mmmmmmmmmm, richer!")
		return FALSE

	message_admins("Bro I'm so sorry")
	return TRUE
