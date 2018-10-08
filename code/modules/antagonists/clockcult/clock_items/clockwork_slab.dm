/obj/item/clockwork/slab //Clockwork slab: The most important tool in Ratvar's arsenal. Allows scripture recital, tutorials, and generates components.
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	clockwork_desc = "A link between you and the Celestial Derelict. It contains information, recites scripture, and is your most vital tool as a Servant.<br>\
	It can be used to link traps and triggers by attacking them with the slab. Keep in mind that traps linked with one another will activate in tandem!"

	icon_state = "dread_ipad"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	var/inhand_overlay //If applicable, this overlay will be applied to the slab's inhand

	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL

	var/busy //If the slab is currently being used by something
	var/no_cost = FALSE //If the slab is admin-only and needs no components and has no scripture locks
	var/speed_multiplier = 1 //multiples how fast this slab recites scripture
	var/selected_scripture = SCRIPTURE_DRIVER
	var/obj/effect/proc_holder/slab/slab_ability //the slab's current bound ability, for certain scripture

	var/recollecting = FALSE //if we're looking at fancy recollection
	var/recollection_category = "Default"

	var/list/quickbound = list(/datum/clockwork_scripture/abscond, \
	/datum/clockwork_scripture/ranged_ability/kindle, /datum/clockwork_scripture/ranged_ability/hateful_manacles) //quickbound scripture, accessed by index
	var/maximum_quickbound = 5 //how many quickbound scriptures we can have

	var/obj/structure/destructible/clockwork/trap/linking //If we're linking traps together, which ones we're doing

/obj/item/clockwork/slab/internal //an internal motor for mobs running scripture
	name = "scripture motor"
	quickbound = list()
	no_cost = TRUE

/obj/item/clockwork/slab/debug
	speed_multiplier = 0
	no_cost = TRUE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clockwork/slab/debug/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user))
		add_servant_of_ratvar(user)
	return ..()

/obj/item/clockwork/slab/cyborg //three scriptures, plus a spear and fabricator
	clockwork_desc = "A divine link to the Celestial Derelict, allowing for limited recital of scripture."
	quickbound = list(/datum/clockwork_scripture/abscond, /datum/clockwork_scripture/ranged_ability/judicial_marker, /datum/clockwork_scripture/ranged_ability/linked_vanguard)
	maximum_quickbound = 6 //we usually have one or two unique scriptures, so if ratvar is up let us bind one more
	actions_types = list()

/obj/item/clockwork/slab/cyborg/engineer //two scriptures, plus a fabricator
	quickbound = list(/datum/clockwork_scripture/abscond, /datum/clockwork_scripture/create_object/replicant, /datum/clockwork_scripture/create_object/sigil_of_transmission)

/obj/item/clockwork/slab/cyborg/medical //five scriptures, plus a spear
	quickbound = list(/datum/clockwork_scripture/abscond, /datum/clockwork_scripture/ranged_ability/linked_vanguard, /datum/clockwork_scripture/ranged_ability/sentinels_compromise, \
	/datum/clockwork_scripture/create_object/vitality_matrix)

/obj/item/clockwork/slab/cyborg/security //twoscriptures, plus a spear
	quickbound = list(/datum/clockwork_scripture/abscond, /datum/clockwork_scripture/ranged_ability/hateful_manacles, /datum/clockwork_scripture/ranged_ability/judicial_marker)

/obj/item/clockwork/slab/cyborg/peacekeeper //two scriptures, plus a spear
	quickbound = list(/datum/clockwork_scripture/abscond, /datum/clockwork_scripture/ranged_ability/hateful_manacles, /datum/clockwork_scripture/ranged_ability/judicial_marker)

/obj/item/clockwork/slab/cyborg/janitor //five scriptures, plus a fabricator
	quickbound = list(/datum/clockwork_scripture/abscond, /datum/clockwork_scripture/create_object/replicant, /datum/clockwork_scripture/create_object/sigil_of_transgression, \
	/datum/clockwork_scripture/create_object/ocular_warden, /datum/clockwork_scripture/create_object/mania_motor)

/obj/item/clockwork/slab/cyborg/service //five scriptures, plus xray vision
	quickbound = list(/datum/clockwork_scripture/abscond, /datum/clockwork_scripture/create_object/replicant, \
	/datum/clockwork_scripture/spatial_gateway, /datum/clockwork_scripture/create_object/clockwork_obelisk)

/obj/item/clockwork/slab/cyborg/miner //two scriptures, plus a spear and xray vision
	quickbound = list(/datum/clockwork_scripture/abscond, /datum/clockwork_scripture/ranged_ability/linked_vanguard, /datum/clockwork_scripture/spatial_gateway)

/obj/item/clockwork/slab/cyborg/access_display(mob/living/user)
	if(!GLOB.ratvar_awakens)
		to_chat(user, "<span class='warning'>Use the action buttons to recite your limited set of scripture!</span>")
	else
		..()

/obj/item/clockwork/slab/cyborg/ratvar_act()
	..()
	if(!GLOB.ratvar_awakens)
		SStgui.close_uis(src)

/obj/item/clockwork/slab/Initialize()
	. = ..()
	update_slab_info(src)
	START_PROCESSING(SSobj, src)
	if(GLOB.ratvar_approaches)
		name = "supercharged [name]"
		speed_multiplier = max(0.1, speed_multiplier - 0.25)

/obj/item/clockwork/slab/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(slab_ability && slab_ability.ranged_ability_user)
		slab_ability.remove_ranged_ability()
	slab_ability = null
	return ..()

/obj/item/clockwork/slab/dropped(mob/user)
	. = ..()
	addtimer(CALLBACK(src, .proc/check_on_mob, user), 1) //dropped is called before the item is out of the slot, so we need to check slightly later

/obj/item/clockwork/slab/worn_overlays(isinhands = FALSE, icon_file)
	. = list()
	if(isinhands && item_state && inhand_overlay)
		var/mutable_appearance/M = mutable_appearance(icon_file, "slab_[inhand_overlay]")
		. += M

/obj/item/clockwork/slab/proc/check_on_mob(mob/user)
	if(user && !(src in user.held_items) && slab_ability && slab_ability.ranged_ability_user) //if we happen to check and we AREN'T in user's hands, remove whatever ability we have
		slab_ability.remove_ranged_ability()

//Power generation
/obj/item/clockwork/slab/process()
	if(GLOB.ratvar_approaches && speed_multiplier == initial(speed_multiplier))
		name = "supercharged [name]"
		speed_multiplier = max(0.1, speed_multiplier - 0.25)
	adjust_clockwork_power(0.1) //Slabs serve as very weak power generators on their own (no, not enough to justify spamming them)

/obj/item/clockwork/slab/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(LAZYLEN(quickbound))
			for(var/i in 1 to quickbound.len)
				if(!quickbound[i])
					continue
				var/datum/clockwork_scripture/quickbind_slot = quickbound[i]
				to_chat(user, "<b>Quickbind</b> button: <span class='[get_component_span(initial(quickbind_slot.primary_component))]'>[initial(quickbind_slot.name)]</span>.")
		to_chat(user, "<b>Available power:</b> <span class='bold brass'>[DisplayPower(get_clockwork_power())].</span>")

//Slab actions; Hierophant, Quickbind
/obj/item/clockwork/slab/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/clock/quickbind))
		var/datum/action/item_action/clock/quickbind/Q = action
		recite_scripture(quickbound[Q.scripture_index], user, FALSE)

//Scripture Recital
/obj/item/clockwork/slab/attack_self(mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='heavy_brass'>\"You reek of blood. You've got a lot of nerve to even look at that slab.\"</span>")
		user.visible_message("<span class='warning'>A sizzling sound comes from [user]'s hands!</span>", "<span class='userdanger'>[src] suddenly grows extremely hot in your hands!</span>")
		playsound(get_turf(user), 'sound/weapons/sear.ogg', 50, 1)
		user.dropItemToGround(src)
		user.emote("scream")
		user.apply_damage(5, BURN, BODY_ZONE_L_ARM)
		user.apply_damage(5, BURN, BODY_ZONE_R_ARM)
		return 0
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='warning'>The information on [src]'s display shifts rapidly. After a moment, your head begins to pound, and you tear your eyes away.</span>")
		user.confused += 5
		user.dizziness += 5
		return 0
	if(busy)
		to_chat(user, "<span class='warning'>[src] refuses to work, displaying the message: \"[busy]!\"</span>")
		return 0
	if(!no_cost && !can_recite_scripture(user))
		to_chat(user, "<span class='nezbere'>[src] hums fitfully in your hands, but doesn't seem to do anything...</span>")
		return 0
	access_display(user)

/obj/item/clockwork/slab/AltClick(mob/living/user)
	if(is_servant_of_ratvar(user) && linking && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		linking = null
		to_chat(user, "<span class='notice'>Object link canceled.</span>")

/obj/item/clockwork/slab/proc/access_display(mob/living/user)
	if(!is_servant_of_ratvar(user))
		return FALSE
	ui_interact(user)
	return TRUE

/obj/item/clockwork/slab/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "clockwork_slab", name, 800, 420, master_ui, state)
		ui.set_autoupdate(FALSE) //we'll update this occasionally, but not as often as possible
		ui.set_style("clockwork")
		ui.open()

/obj/item/clockwork/slab/proc/recite_scripture(datum/clockwork_scripture/scripture, mob/living/user)
	if(!scripture || !user || !user.canUseTopic(src) || (!no_cost && !can_recite_scripture(user)))
		return FALSE
	if(user.get_active_held_item() != src)
		to_chat(user, "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>")
		return FALSE
	var/initial_tier = initial(scripture.tier)
	if(initial_tier != SCRIPTURE_PERIPHERAL)
		if(!GLOB.ratvar_awakens && !no_cost && !GLOB.scripture_states[initial_tier])
			to_chat(user, "<span class='warning'>That scripture is not unlocked, and cannot be recited!</span>")
			return FALSE
	var/datum/clockwork_scripture/scripture_to_recite = new scripture
	scripture_to_recite.slab = src
	scripture_to_recite.invoker = user
	scripture_to_recite.run_scripture()
	return TRUE


//Guide to Serving Ratvar
/obj/item/clockwork/slab/proc/recollection()
	var/list/textlist = list("If you're seeing this, file a bug report.")
	if(GLOB.ratvar_awakens)
		textlist = list("<font color=#BE8700 size=3><b>")
		for(var/i in 1 to 100)
			textlist += "HONOR RATVAR "
		textlist += "</b></font>"
	else
		textlist = list("<font color=#BE8700 size=3><b><center>[text2ratvar("Purge all untruths and honor Engine.")]</center></b></font><br>\
		\
		<b><i>NOTICE:</b> This information is out of date. Read the Ark & You primer in your backpack or read the wiki page for current info.</i><br>\
		<hr><br>\
		These pages serve as the archives of Ratvar, the Clockwork Justiciar. This section of your slab has information on being as a Servant, advice for what to do next, and \
		pointers for serving the master well. You should recommended that you check this area for help if you get stuck or need guidance on what to do next.<br><br>\
		\
		<i>Disclaimer: Many objects, terms, and phrases, such as Servant, Cache, and Slab, are capitalized like proper nouns. This is a quirk of the Ratvarian language; \
		do not let it confuse you! You are free to use the names in pronoun form when speaking in normal languages.<br>")
	return textlist.Join()

//Gets text for a certain section. "Default" is used for when you first open Recollection.
//Current sections (make sure to update this if you add one:
//- Basics
//- Terminology
//- Components
//- Scripture
//- Power
//- Conversion
/obj/item/clockwork/slab/proc/get_recollection_text(section)
	var/list/dat = list()
	switch(section)
		if("Default")
			dat += "You can browse the above sections as you please. They're designed to be read in order, but feel free to pick and choose between them."
		if("Getting Started")
			dat += "<font color=#BE8700 size=3>Getting Started</font><br><br>"
			dat += "Welcome, Servant! This section houses the utmost basics of being a Servant of Ratvar, and is much more informal than the other sections. Being a Servant of \
			Ratvar is a very complex role, with many systems, objects, and resources to use effectively and creatively.<br><br>"
			dat += "This section of your clockwork slab covers everything that Servants have to be aware of, but is a long read because of how in-depth the systems are. Knowing \
			how to use the tools at your disposal makes all the difference between a clueless Servant and a great one.<br><br>"
			dat += "If this is your first time being a Servant, relax. It's very much possible that you'll fail, but it's impossible to learn without making mistakes. For the time \
			being, use the Hierophant Network button in the top left-hand corner of your screen to try and get in touch with your fellow Servants; ignore the others for now. This button \
			will let you send messages across space and time to all other Servants. This makes it great for coordinating, and you should use it often! <i>Note:</i> Using \
			this will cause you to whisper your message aloud, so doing so in a public place is very suspicious and you should try to restrict it to private use.<br><br>"
			dat += "If you aren't willing or don't have the time to read through every section, you can still help your teammates! Ask if they've set up a base. If they have, head there \
			and ask however you can help; chances are there's always something. If not, it's your job as a Servant to get one up and running! Try to find a secluded, low-traffic area, \
			like the auxiliary base or somewhere deep in maintenance. You'll want to go into the Drivers section of the slab and look for <i>Tinkerer's Cache.</i> Find a nice spot and \
			create one. This serves as a storage for <i>components,</i> the cult's primary resource. (Your slab's probably produced a few by now.) By attacking that cache with this \
			slab, you'll offload all your components into it, and all Servants will be able to use those components from any distance - all Tinkerer's Caches are linked!<br><br>"
			dat += "Once you have a base up and running, contact your fellows and let them know. You should come back here often to drop off the slab's components, and your fellows \
			should do the same, either in this cache or in ones of their own.<br><br>"
			dat += "If you think you're confident in taking further steps to help the cult, feel free to move onto the other sections. If not, let your allies know that you're new and \
			would appreciate the help they might offer you. Most experienced Servants would be happy to help; if everyone is inexperienced, then you'll have to step out of your comfort \
			zone and read onto the other sections. It's very likely that you might fail, but don't worry too much about it; you can't learn effectively without making mistakes.<br><br>"
			dat += "For now, welcome! If you're looking to learn, you should start with the <b>Basics</b> section, then move onto <b>Components</b> and <b>Scripture</b>. At the very \
			least, you should read the <b><i>Conversion</i></b> section, as it outlines the most important aspects of being a Servant. Good luck!<br><br>"
			dat += "<font color=#BE8700 size=3>-=-=-=-=-=-</font>"
		if("Basics")
			dat += "<font color=#BE8700 size=3>Servant Basics</font><br><br>"
			dat += "The first thing any Servant should know is their slab, inside and out. The clockwork slab is by far your most important tool. It allows you to speak with your \
			fellow Servants, create components that fuel many of your abilities, use those abilities, and should be kept safe and hidden on your person at all times. If you have not \
			done so already, it's a good idea to check for any fellow Servants using the Hierophant Network button in the top-left corner of your screen; due to the cult's nature, \
			teamwork is an instrumental component of your success.<br><br>" //get it? component? ha!
			dat += "As a Servant of Ratvar, the tools you are given focus around building and maintaining bases and outposts. A great deal of your power comes from stationary \
			structures, and without constructing a base somewhere, it's essentially impossible to succeed. Finding a good spot to build a base can be difficult, and it's recommended \
			that you choose an area in low-traffic part of the station (such as the auxiliary base). Make sure to disconnect any cameras in the area beforehand.<br><br>"
			dat += "Because of how complex being a Servant is, it isn't possible to fit much information into this section. It's highly recommended that you read the <b>Components</b> \
			and <b>Scripture</b> sections next. Not knowing how these two systems work will cripple both you and your fellows, and lead to a frustrating experience for everyone.<br><br>"
			dat += "<font color=#BE8700 size=3>-=-=-=-=-=-</font>"
		if("Terminology")
			dat += "<font color=#BE8700 size=3>Common Servant Terminology</font><br>"
			dat += "<i>This isn't intended to be read all at once; you are advised to treat it moreso as a glossary.</i><br><br>"
			dat += "<font color=#BE8700 size=3>General</font><br>"
			dat += "<font color=#BE8700><b>Servant:</b></font> A person or robot who serves Ratvar. You are one of these.<br>"
			dat += "<font color=#BE8700><b>Cache:</b></font> A <i>Tinkerer's Cache</i>, which is a structure that stores and creates components.<br>"
			dat += "<font color=#BE8700><b>CV:</b></font> Construction Value. All clockwork structures, floors, and walls increase this number.<br>"
			dat += "<font color=#BE8700><b>Vitality:</b></font> Used for healing effects, produced by Ratvarian spear attacks and Vitality Matrices.<br>"
			dat += "<font color=#BE8700><b>Geis:</b></font> An important scripture used to make normal crew and robots into Servants of Ratvar.<br>"
			dat += "<font color=#BE8700><b>Ark:</b></font> The cult's win condition, a huge structure that needs to be defended.<br><br>"
			dat += "<font color=#BE8700 size=3>Items</font><br>"
			dat += "<font color=#BE8700><b>Slab:</b></font> A clockwork slab, a Servant's most important tool. You're holding one! Keep it safe and hidden.<br>"
			dat += "<font color=#BE8700><b>Visor:</b></font> A judicial visor, which is a pair of glasses that can smite an area for a brief stun and delayed explosion.<br>"
			dat += "<font color=#BE8700><b>Wraith Specs:</b></font> Wraith spectacles, which provide true sight (X-ray, night vision) but damage the wearer's eyes.<br>"
			dat += "<font color=#BE8700><b>Spear:</b></font> A Ratvarian spear, which is a very powerful melee weapon that produces Vitality.<br>"
			dat += "<font color=#BE8700><b>Fabricator:</b></font> A replica fabricator, which converts objects into clockwork versions.<br><br>"
			dat += "<font color=#BE8700 size=3>Constructs</font><br>"
			dat += "<font color=#BE8700><b>Marauder:</b></font> A clockwork marauder, which is a powerful bodyguard that hides in its owner.<br><br>"
			dat += "<font color=#BE8700 size=3>Structures (* = requires power)</font><br>"
			dat += "<font color=#BE8700><b>Warden:</b></font> An ocular warden, which is a ranged turret that damages non-Servants that see it.<br>"
			dat += "<font color=#BE8700><b>Prism*:</b></font> A prolonging prism, which delays the shuttle for two minutes at a huge power cost.<br><br>"
			dat += "<font color=#BE8700><b>Motor*:</b></font> A mania motor, which serves as area-denial through negative effects and eventual conversion.<br>"
			dat += "<font color=#BE8700><b>Daemon*:</b></font> A tinkerer's daemon, which quickly creates components.<br>"
			dat += "<font color=#BE8700><b>Obelisk*:</b></font> A clockwork obelisk, which can broadcast large messages and allows limited teleportation.<br>"
			dat += "<font color=#BE8700 size=3>Sigils</font><br>"
			dat += "<i>Note: Sigils can be stacked on top of one another, making certain sigils very effective when paired!</i><br>"
			dat += "<font color=#BE8700><b>Transgression:</b></font> Stuns the first non-Servant to cross it for ten seconds and blinds others nearby. Disappears on use.<br>"
			dat += "<font color=#BE8700><b>Submission:</b></font> Converts the first non-Servant to stand on the sigil for seven seconds. Disappears on use.<br>"
			dat += "<font color=#BE8700><b>Matrix:</b></font> Drains health from non-Servants, producing Vitality. Can heal and revive Servants.<br>"
			dat += "<font color=#BE8700><b>Accession:</b></font> Identical to the Sigil of Submission, but doesn't disappear on use. It can also convert a single mindshielded target, but will disappear after doing this.<br>"
			dat += "<font color=#BE8700><b>Transmission:</b></font> Drains and stores power for clockwork structures. Feeding it brass sheets will create additional power.<br><br>"
			dat += "<font color=#BE8700 size=3>-=-=-=-=-=-</font>"
		if("Components")
			dat += "<font color=#BE8700 size=3>Components & Their Uses</font><br><br>"
			dat += "<b>Components</b> are your primary resource as a Servant. There are five types of component, with each one being used in different roles:<br><br>"
			dat += "Although this is a good rule of thumb, their effects become much more nuanced when used together. For instance, a turret might have both belligerent eyes and \
			vanguard cogwheels as construction requirements, because it defends its allies by harming its enemies.<br><br>"
			dat += "Components' primary use is fueling <b>scripture</b> (covered in its own section), and they can be created through various ways. This clockwork slab, for instance, \
			will make a random component of every type - or a specific one, if you choose a target component from the interface - every <b>remove me already</b>. This number will increase \
			as the amount of Servants in the covenant increase; additionally, slabs can only produce components when held by a Servant, and holding more than one slab will cause both \
			of them to halt progress until one of them is removed from their person.<br><br>"
			dat += "Your slab has an internal storage of components, but it isn't meant to be the main one. Instead, there's a <b>global storage</b> of components that can be \
			added to through various ways. Anything that needs components will first draw them from the global storage before attempting to draw them from the slab. Most methods of \
			component production add to the global storage. You can also offload components from your slab into the global storage by using it on a Tinkerer's Cache, a structure whose \
			primary purpose is to do just that (although it will also slowly produce components when placed near a brass wall.)<br><br>"
			dat += "<font color=#BE8700 size=3>-=-=-=-=-=-</font>"
		if("Scripture")
			dat += "<font color=#BE8700 size=3>The Ancient Scripture</font><br><br>"
			dat += "If you have experience with the Nar'Sian cult (or the \"blood cult\") then you will know of runes. They are the manifestations of the Geometer's power, and where most \
			of the cult's supernatural ability comes from. The Servant equivalent of runes is called <b>scripture</b>, and unlike runes, scripture is loaded into your clockwork slab.<br><br>"
			dat += "Each piece of scripture has widely-varying effects. Your most important scripture, <i>Geis</i>, is obvious and suspicious, but charges your slab with energy and allows \
			you to attack a non-Servant in melee range to restrain them and begin converting them into a Servant. This is just one example; each piece of scripture can be simple or \
			complex, be obvious or have hidden mechanics that can only be found through trial and error.<br><br>"
			dat += "Any given piece of scripture has a component cost listed in its \"Recite\" button. The acronyms for the components should be obvious if you've read about components \
			already; reciting this piece of scripture will consume the listed components, first from the global storage and then from your slab. Note that failing to recite a piece of \
			scripture will <i>not</i> consume the components required to recite it.<br><br>"
			dat += "It should also be noted that some scripture cannot be recited alone. Especially with more powerful scripture, you may need multiple Servants to recite a piece of \
			scripture; both of you will need to stand still until the recital completes. <i>Only human and silicon Servants are valid for scripture recital!</i> Constructs cannot help \
			in reciting scripture.<br><br>"
			dat += "Finally, scripture is separated into three \"tiers\" based on power: Drivers, Scripts, and Applications.[prob(1) ? " (The Revenant tier was removed a long time ago. \
			Get with the times.)" : ""] You can view the requirements to unlock each tier in its scripture list. Once a tier is unlocked, it's unlocked permanently; the cult only needs to fill the \
			requirement for unlocking a tier once!<br><br>"
			dat += "<font color=#BE8700 size=3>-=-=-=-=-=-</font>"
		if("Power")
			dat += "<font color=#BE8700 size=3>Power! Unlimited Power!</font><br><br>"
			dat += "In the early stages of the cult, the only resource that must be actively worried about is components. However, as new scripture is unlocked, a new resource \
			becomes necessary: <b>power</b>. Almost all clockwork structures require power to function in some way. There is nothing special about this power; it's mere electricity, \
			and can be harnessed in several ways.<br><br>"
			dat += "To begin with, if there is no other source of power nearby, structures will draw from the area's APC, assuming it has one. This is inefficient and ill-advised as \
			anything but a last resort. Instead, it is recommended that a <b>Sigil of Transmission</b> is created. This sigil serves as both battery  and power generator for nearby clockwork \
			structures, and those structures will happily draw power from the sigil before they resort to APCs.<br><br>"
			dat += "Generating power is less easy. The most reliable and efficient way is using brass sheets; attacking a sigil of transmission with brass sheets will convert them \
			to power, at a rate of <b>[DisplayPower(POWER_FLOOR)]</b> per sheet. (Brass sheets are created from replica fabricators, which are explained more in detail in the <b>Conversion</b> section.) \
			Activating a sigil of transmission will also cause it to drain power from the nearby area, which, while effective, serves as an obvious tell that there is something wrong.<br><br>"
			dat += "Without power, many structures will not function, making a base vulnerable to attack. For this reason, it is critical that you keep an eye on your power reserves and \
			ensure that they remain comfortably high.<br><br>"
			dat += "<font color=#BE8700 size=3>-=-=-=-=-=-</font>"
		if("Conversion")
			dat += "<font color=#BE8700 size=3>Growing the Ranks</font><br><br>"
			dat += "Because the Servants of Ratvar are a cult, the main method to gain more power is to \"enlighten\" normal crew into new Servants. When a crewmember is converted, \
			they become a full-fledged Servant, ready and willing to serve the cause of Ratvar. It should also be noted that <i>silicon crew, such as cyborgs and the AI, can be \
			converted just like normal crew</i> and will gain special abilities; this is covered later. This section will also cover converting the station's structure itself; walls, \
			floors, windows, tables, and other objects can all be converted into clockwork versions, and serve an important purpose.<br><br>"
			dat += "<font color=#BE8700><b>A Note on Geis:</b></font> There are several ways to convert humans and silicons. However, the most important tool to making them work is \
			<b>Geis</b>, a Driver-tier scripture. Using it whispers an invocation very quickly and charges your slab with power. In addition to <i>making the slab visible in your hand,</i> \
			you can now use it on a target within melee range to bind and mute them. It is by far your most reliable tool for capturing potential converts and targets, though it is incredibly \
			obvious. In addition, you are unable to take any actions other than moving while your target is bound. The binding will last for 25 seconds and mute for about 13 seconds, though \
			allies can use Geis to refresh these effects.<br><br>"
			dat += "<font color=#BE8700><b>Converting:</b></font> The two methods of conversion are the <b>sigil of submission</b>, whose purpose is to do so, and the <b>mania motor.</b> \
			The sigil of submission is a sigil that, when stood on by a non-Servant for eight seconds, will convert that non-Servant. This is the only practical way to convert targets. \
			Sigils of submission are cheap, early, and permanent! Make sure sigils of submission are placed only in bases or otherwise hidden spots, or with a sigil of transgression on them. \
			The mania motor, however, is generally unreliable and unlocked later, only converting those who stand near it for an extended period.<br><br>"
			dat += "<font color=#BE8700><b>Converting Humans:</b></font> For obvious reasons, humans are the most common conversion target. Because every crew member is different, and \
			may be armed with different equipment, you should take precautions to ensure that they aren't able to resist. If able, removing a headset is essential, as is restraining \
			them through handcuffs, cable ties, or other restraints. Some crew, like security, are also implanted with mindshield implants; these will prevent conversion and must be \
			surgically removed before they are an eligible convert. <i>Note:</i> The captain is <i>never</i> an eligible convert and should instead be killed or imprisoned. If security \
			begins administering mindshield implants, this will greatly inhibit conversion. Also note that mindshield implants can be broken by a sigil of accession automatically, but \
			the sigil will disappear.<br><br>"
			dat += "<font color=#BE8700><b>Converting Silicons:</b></font> Due to their robotic nature, silicons are generally more predictable than humans in terms of conversion. \
			However, they are also much, much harder to subdue, especially cyborgs. The easiest way to convert a cyborg is by using Geis to restrain them, then dragging them to a sigil \
			of submission. If you stack a sigil of transgression and a sigil of submission, a crossing cyborg will be stunned and helpless to escape before they are converted.<br><br>"
			dat += "Converting AIs is very often the hardest task of the cult, and has been the downfall of countless successful Servants. Their omnipresence across the station, \
			coupled with their secure location and ability to lock themselves securely, makes them a powerful target. However, once the AI itself is reached, it is usually completely \
			helpless to resist its own conversion. A very common tactic is to take advantage of a converted cyborg to rush the AI before it is able to react.<br><br>"
			dat += "Even once an AI is converted, care must be taken to ensure that it remains hidden. Not only does the AI's core become brassy and thus obvious to an outside \
			observer, but <i>the AI loses the ability to speak in anything but Ratvarian.</i> For this reason, it has to remain completely silent over common radio channels if stealth \
			is at all a priority. This is suspicious and will rapidly lead to the crew checking on it, which usually results in the cult's outing. It is, however, necessary to convert \
			all AIs present on the station before the Ark becomes invokable, so this must be done at some point.<br><br>"
			dat += "<font color=#BE8700><b>Converting the Station:</b></font> Converted objects all serve a purpose and are important to the cult's success. To convert objects, \
			a Servant needs to use a <b>replica fabricator,</b> a handheld tool that uses power to replace objects with clockwork versions. Different clockwork objects have different \
			effects and are often crucial. The most noteworthy are <b>clockwork walls,</b> which automatically \"link\" to any nearby Tinkerer's Caches, causing them to <b>slowly \
			generate components.</b> This is incredibly useful for obvious reasons, and creating a clockwork wall near every Tinkerer's Cache should be prioritized. Clockwork floors \
			will slowly heal any toxin damage suffered by Servants standing on them, and clockwork airlocks can only be opened by Servants.<br><br>"
			dat += "The replica fabricator itself is also worth noting. In addition to replacing objects, it can also create brass sheets at the cost of power by using the \
			fabricator in-hand. It can also be used to repair any damaged clockwork structures.<br><br>"
			dat += "Replacing objects is almost as, if not as important as, converting new Servants. A base is impossible to manage without clockwork walls at the very least, and \
			once the cult has been outed and the crew are actively searching, there is little reason not to use as many as possible.<br><br>"
			dat += "<font color=#BE8700 size=3>-=-=-=-=-=-</font>"
		else
			dat += "<font color=#BE8700 size=3>404: [section ? section : "Section"] Not Found!</font><br><br>\
			One of the cogscarabs must've misplaced this section, because the game wasn't able to find any info regarding it. Report this to the coders!"
	return "<br><br>[dat.Join()]<br><br>"

//Gets the quickbound scripture as a text block.
/obj/item/clockwork/slab/proc/get_recollection_quickbinds()
	var/list/dat = list()
	dat += "<font color=#BE8700 size=3>Quickbound Scripture</font><br>\
	<i>You can have up to five scriptures bound to action buttons for easy use.</i><br><br>"
	if(LAZYLEN(quickbound))
		for(var/i in 1 to maximum_quickbound)
			if(LAZYLEN(quickbound) < i || !quickbound[i])
				dat += "A <b>Quickbind</b> slot, currently set to <b><font color=#BE8700>Nothing</font></b>.<br>"
			else
				var/datum/clockwork_scripture/quickbind_slot = quickbound[i]
				dat += "A <b>Quickbind</b> slot, currently set to <b><font color=[get_component_color_bright(initial(quickbind_slot.primary_component))]>[initial(quickbind_slot.name)]</font></b>.<br>"
	return dat.Join()


/obj/item/clockwork/slab/ui_data(mob/user) //we display a lot of data via TGUI
	var/list/data = list()
	data["power"] = "<b><font color=#B18B25>[DisplayPower(get_clockwork_power())]</b> power is available for scripture and other consumers.</font>"

	switch(selected_scripture) //display info based on selected scripture tier
		if(SCRIPTURE_DRIVER)
			data["tier_info"] = "<font color=#B18B25><b>These scriptures are permanently unlocked.</b></font>"
		if(SCRIPTURE_SCRIPT)
			if(GLOB.scripture_states[SCRIPTURE_SCRIPT])
				data["tier_info"] = "<font color=#B18B25><b>These scriptures are permanently unlocked.</b></font>"
			else
				data["tier_info"] = "<font color=#B18B25><i>These scriptures will automatically unlock when the Ark is halfway ready or if [DisplayPower(SCRIPT_UNLOCK_THRESHOLD)] of power is reached.</i></font>"
		if(SCRIPTURE_APPLICATION)
			if(GLOB.scripture_states[SCRIPTURE_APPLICATION])
				data["tier_info"] = "<font color=#B18B25><b>These scriptures are permanently unlocked.</b></font>"
			else
				data["tier_info"] = "<font color=#B18B25><i>Unlock these optional scriptures by converting another servant or if [DisplayPower(APPLICATION_UNLOCK_THRESHOLD)] of power is reached..</i></font>"

	data["selected"] = selected_scripture
	data["scripturecolors"] = "<font color=#DAAA18>Scriptures in <b>yellow</b> are related to construction and building.</font><br>\
	<font color=#6E001A>Scriptures in <b>red</b> are related to attacking and offense.</font><br>\
	<font color=#1E8CE1>Scriptures in <b>blue</b> are related to healing and defense.</font><br>\
	<font color=#AF0AAF>Scriptures in <b>purple</b> are niche but still important!</font><br>\
	<font color=#DAAA18><i>Scriptures with italicized names are important to success.</i></font>"
	generate_all_scripture()

	data["scripture"] = list()
	for(var/s in GLOB.all_scripture)
		var/datum/clockwork_scripture/S = GLOB.all_scripture[s]
		if(S.tier == selected_scripture) //display only scriptures of the selected tier
			var/scripture_color = get_component_color_bright(S.primary_component)
			var/list/temp_info = list("name" = "<font color=[scripture_color]><b>[S.name]</b></font>",
			"descname" = "<font color=[scripture_color]>([S.descname])</font>",
			"tip" = "[S.desc]\n[S.usage_tip]",
			"required" = "([DisplayPower(S.power_cost)][S.special_power_text ? "+ [replacetext(S.special_power_text, "POWERCOST", "[DisplayPower(S.special_power_cost)]")]" : ""])",
			"type" = "[S.type]",
			"quickbind" = S.quickbind)
			if(S.important)
				temp_info["name"] = "<i>[temp_info["name"]]</i>"
			var/found = quickbound.Find(S.type)
			if(found)
				temp_info["bound"] = "<b>[found]</b>"
			if(S.invokers_required > 1)
				temp_info["invokers"] = "<font color=#B18B25>Invokers: <b>[S.invokers_required]</b></font>"
			data["scripture"] += list(temp_info)
	data["recollection"] = recollecting
	if(recollecting)
		data["recollection_categories"] = GLOB.ratvar_awakens ? list() : list(\
		list("name" = "Getting Started", "desc" = "First-time servant? Read this first."), \
		list("name" = "Basics", "desc" = "A primer on how to play as a servant."), \
		list("name" = "Terminology", "desc" = "Common acronyms, words, and terms."), \
		list("name" = "Components", "desc" = "Information on components, your primary resource."), \
		list("name" = "Scripture", "desc" = "Information on scripture, ancient tools used by the cult."), \
		list("name" = "Power", "desc" = "The power system that certain objects use to function."), \
		list("name" = "Conversion", "desc" = "Converting the crew, cyborgs, and very walls to your cause."), \
		)
		data["rec_text"] = recollection()
		data["rec_section"] = GLOB.ratvar_awakens ? "" : get_recollection_text(recollection_category)
		data["rec_binds"] = GLOB.ratvar_awakens ? "" : get_recollection_quickbinds()
	return data

/obj/item/clockwork/slab/ui_act(action, params)
	switch(action)
		if("toggle")
			recollecting = !recollecting
		if("recite")
			INVOKE_ASYNC(src, .proc/recite_scripture, text2path(params["category"]), usr, FALSE)
		if("select")
			selected_scripture = params["category"]
		if("bind")
			var/datum/clockwork_scripture/path = text2path(params["category"]) //we need a path and not a string
			var/found_index = quickbound.Find(path)
			if(found_index) //hey, we already HAVE this bound
				if(LAZYLEN(quickbound) == found_index) //if it's the last scripture, remove it instead of leaving a null
					quickbound -= path
				else
					quickbound[found_index] = null //otherwise, leave it as a null so the scripture maintains position
				update_quickbind()
			else
				var/target_index = input("Position of [initial(path.name)], 1 to [maximum_quickbound]?", "Input")  as num|null
				if(isnum(target_index) && target_index > 0 && target_index <= maximum_quickbound && !..())
					var/datum/clockwork_scripture/S
					if(LAZYLEN(quickbound) >= target_index)
						S = quickbound[target_index]
					if(S != path)
						quickbind_to_slot(path, target_index)
		if("rec_category")
			recollection_category = params["category"]
			ui_interact(usr)
	return 1

/obj/item/clockwork/slab/proc/quickbind_to_slot(datum/clockwork_scripture/scripture, index) //takes a typepath(typecast for initial()) and binds it to a slot
	if(!ispath(scripture) || !scripture || (scripture in quickbound))
		return
	while(LAZYLEN(quickbound) < index)
		quickbound += null
	var/datum/clockwork_scripture/quickbind_slot = GLOB.all_scripture[quickbound[index]]
	if(quickbind_slot && !quickbind_slot.quickbind)
		return //we can't unbind things we can't normally bind
	quickbound[index] = scripture
	update_quickbind()

/obj/item/clockwork/slab/proc/update_quickbind()
	for(var/datum/action/item_action/clock/quickbind/Q in actions)
		qdel(Q) //regenerate all our quickbound scriptures
	if(LAZYLEN(quickbound))
		for(var/i in 1 to quickbound.len)
			if(!quickbound[i])
				continue
			var/datum/action/item_action/clock/quickbind/Q = new /datum/action/item_action/clock/quickbind(src)
			Q.scripture_index = i
			var/datum/clockwork_scripture/quickbind_slot = GLOB.all_scripture[quickbound[i]]
			Q.name = "[quickbind_slot.name] ([Q.scripture_index])"
			Q.desc = quickbind_slot.quickbind_desc
			Q.button_icon_state = quickbind_slot.name
			Q.UpdateButtonIcon()
			if(isliving(loc))
				Q.Grant(loc)
