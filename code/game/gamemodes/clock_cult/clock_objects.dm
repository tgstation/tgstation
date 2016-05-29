/////////////////////
// CLOCKWORK ITEMS //
/////////////////////

/obj/item/clockwork
	name = "meme blaster"
	desc = "What the fuck is this? It looks kinda like a frog."
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	w_class = 2

/obj/item/clockwork/New()
	..()
	all_clockwork_objects += src

/obj/item/clockwork/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/item/clockwork/slab //Clockwork slab: The most important tool in Ratvar's arsenal. Allows scripture recital, tutorials, and generates components.
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	clockwork_desc = "A link between the Celestial Derelict and the mortal plane. Contains limitless knowledge, fabricates components, and outputs a stream of information that only a trained eye can detect."
	icon_state = "dread_ipad"
	w_class = 3
	var/list/stored_components = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 0, "hierophant_ansible" = 0)
	var/busy //If the slab is currently being used by something
	var/production_cycle = 0
	var/no_cost = FALSE //If the slab is admin-only and needs no components and has no scripture locks

/obj/item/clockwork/slab/starter
	stored_components = list("belligerent_eye" = 1, "vanguard_cogwheel" = 1, "guvax_capacitor" = 1, "replicant_alloy" = 1, "hierophant_ansible" = 1)

/obj/item/clockwork/slab/debug
	no_cost = TRUE

/obj/item/clockwork/slab/debug/attack_hand(mob/living/user)
	..()
	if(!is_servant_of_ratvar(user))
		add_servant_of_ratvar(user)

/obj/item/clockwork/slab/New()
	..()
	SSobj.processing += src

/obj/item/clockwork/slab/Destroy()
	SSobj.processing -= src
	..()

/obj/item/clockwork/slab/process()
	production_cycle++
	if(production_cycle < SLAB_PRODUCTION_THRESHOLD)
		return 0
	var/component_to_generate = pick("belligerent_eye", "vanguard_cogwheel", "guvax_capacitor", "replicant_alloy", "hierophant_ansible") //Possible todo: Generate based on the lowest amount?
	stored_components[component_to_generate]++
	var/mob/living/L
	if(isliving(loc))
		L = loc
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/W = loc
		if(isliving(W.loc)) //Only goes one level down - otherwise it just doesn't tell you
			L = W.loc
	if(L)
		L << "<span class='brass'>Your slab clunks as it produces a new component.</span>"
	production_cycle = 0
	return 1

/obj/item/clockwork/slab/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/component) && is_servant_of_ratvar(user))
		var/obj/item/clockwork/component/C = I
		if(!C.component_id)
			return 0
		user.visible_message("<span class='notice'>[user] inserts [C] into [src]'s compartments.</span>", "<span class='notice'>You insert [C] into [src].</span>")
		stored_components[C.component_id]++
		user.drop_item()
		qdel(C)
		return 1
	..()

/obj/item/clockwork/slab/attack_self(mob/living/user)
	if(iscultist(user))
		user << "<span class='heavy_brass'>\"You reek of blood. You've got a lot of nerve to even look at that slab.\"</span>"
		user.visible_message("<span class='warning'>A sizzling sound comes from [user]'s hands!</span>", "<span class='userdanger'>[src] suddenly grows extremely hot in your hands!</span>")
		playsound(get_turf(user), 'sound/weapons/sear.ogg', 50, 1)
		user.drop_item()
		user.emote("scream")
		user.apply_damage(5, BURN, "l_arm")
		user.apply_damage(5, BURN, "r_arm")
		return 0
	if(!is_servant_of_ratvar(user))
		user << "<span class='warning'>The information on [src]'s display shifts rapidly. After a moment, your head begins to pound, and you tear your eyes away.</span>"
		user.confused = max(0, user.confused + 3)
		return 0
	if(busy)
		user << "<span class='warning'>[src] refuses to work, displaying the message: \"[busy]!\"</span>"
		return 0
	access_display(user)

/obj/item/clockwork/slab/proc/access_display(mob/living/user)
	if(!is_servant_of_ratvar(user))
		return 0
	var/action = input(user, "Among the swathes of information, you see...", "[src]") as null|anything in list("Recital", "Records", "Recollection", "Repository", "Report")
	if(!action || !user.canUseTopic(src))
		return 0
	switch(action)
		if("Recital")
			recite_scripture(user)
		if("Records")
			show_stats(user)
		if("Recollection")
			show_guide(user)
		if("Repository")
			show_components(user)
			access_display(user)
		if("Report")
			show_hierophant(user)
			access_display(user)
	return 1

/obj/item/clockwork/slab/proc/recite_scripture(mob/living/user)
	var/servants = 0
	var/unconverted_ai_exists = FALSE
	for(var/mob/living/M in living_mob_list)
		if(is_servant_of_ratvar(M))
			servants++
	for(var/mob/living/silicon/ai/ai in living_mob_list)
		if(!is_servant_of_ratvar(ai) && ai.client)
			unconverted_ai_exists = TRUE
	var/list/tiers_of_scripture = list("Drivers")
	tiers_of_scripture += "Scripts[ratvar_awakens || (servants >= 5 && clockwork_caches >= 1) || no_cost ? "" : " \[LOCKED\]"]"
	tiers_of_scripture += "Applications[ratvar_awakens || (servants >= 8 && clockwork_caches >= 3 && clockwork_construction_value >= 50) || no_cost ? "" : " \[LOCKED\]"]"
	tiers_of_scripture += "Revenant[ratvar_awakens || (servants >= 10 && clockwork_construction_value >= 100) || no_cost ? "" : " \[LOCKED\]"]"
	tiers_of_scripture += "Judgement[ratvar_awakens || (servants >= 10 && clockwork_construction_value >= 100 && !unconverted_ai_exists) || no_cost ? "" : " \[LOCKED\]"]"
	var/scripture_tier = input(user, "Choose a category of scripture to recite.", "[src]") as null|anything in tiers_of_scripture
	if(!scripture_tier || !user.canUseTopic(src))
		return 0
	var/list/available_scriptures = list()
	var/datum/clockwork_scripture/scripture_to_recite
	var/tier_to_browse
	switch(scripture_tier)
		if("Drivers")
			tier_to_browse = SCRIPTURE_DRIVER
		if("Scripts")
			tier_to_browse = SCRIPTURE_SCRIPT
		if("Applications")
			tier_to_browse = SCRIPTURE_APPLICATION
		if("Revenant")
			tier_to_browse = SCRIPTURE_REVENANT
		if("Judgement")
			tier_to_browse = SCRIPTURE_JUDGEMENT
	if(!tier_to_browse)
		user << "<span class='warning'>That section of scripture is too powerful right now!</span>"
		return 0
	for(var/S in subtypesof(/datum/clockwork_scripture))
		var/datum/clockwork_scripture/C = S
		if(initial(C.tier) == tier_to_browse)
			available_scriptures += initial(C.name)
	if(!available_scriptures.len)
		return 0
	var/chosen_scripture = input(user, "Choose a piece of scripture to recite.", "[src]") as null|anything in available_scriptures
	if(!chosen_scripture || !user.canUseTopic(src))
		return 0
	for(var/S in subtypesof(/datum/clockwork_scripture))
		var/datum/clockwork_scripture/C = S
		if(initial(C.name) == chosen_scripture)
			scripture_to_recite = new C
	if(!scripture_to_recite)
		return 0
	scripture_to_recite.slab = src
	scripture_to_recite.invoker = user
	scripture_to_recite.run_scripture()
	return 1

/obj/item/clockwork/slab/proc/show_stats(mob/living/user) //A bit barebones, but there really isn't any more needed
	var/servants = 0
	for(var/mob/living/L in living_mob_list)
		if(is_servant_of_ratvar(L))
			servants++
	user << "<b>State of the Enlightened</b>"
	user << "<i>Total servants: </i>[servants]"
	user << "<i>Total construction value: </i>[clockwork_construction_value]"
	user << "<i>Total tinkerer's caches: </i>[clockwork_caches]"
	user << "<i>Total tinkerer's daemons: </i>[clockwork_daemons] ([servants / 5 < clockwork_daemons ? "<span class='boldannounce'>DISABLED: Too few servants (5 servants per daemon)!</span>" : "<font color='green'><b>Functioning Normally</b></font>"])"
	user << "<i>Nezbere: </i>[!clockwork_generals_invoked["nezbere"] ? "<font color='green'><b>Ready</b></font>" : "<span class='boldannounce'>Recovering</span>"]"
	user << "<i>Sevtug: </i>[!clockwork_generals_invoked["sevtug"] ? "<font color='green'><b>Ready</b></font>" : "<span class='boldannounce'>Recovering</span>"]"
	user << "<i>Nzcrentr: </i>[!clockwork_generals_invoked["nzcrentr"] ? "<font color='green'><b>Ready</b></font>" : "<span class='boldannounce'>Recovering</span>"]"
	user << "<i>Inath-Neq: </i>[!clockwork_generals_invoked["inath-neq"] ? "<font color='green'><b>Ready</b></font>" : "<span class='boldannounce'>Recovering</span>"]"

/obj/item/clockwork/slab/proc/show_guide(mob/living/user)
	var/text = "<font color=#BE8700 size=3><b><center>Chetr nyy hageh’guf naq ubabe Ratvar.</center></b></font><br><br>\
	\
	First and foremost, you serve Ratvar, the Clockwork Justiciar, in any ways he sees fit. This is with no regard to your personal well-being, and you would do well to think of the larger \
	scale of things than your life. Through foul and unholy magics was the Celestial Derelict formed, and fouler still those which trapped your master within it for all eternity. The Justiciar \
	wishes retribution upon those who performed this terrible act upon him - the Nar-Sian cultists - and you are to help him obtain it.<br><br>\
	\
	This is not a trivial task. Due to the nature of his prison, Ratvar is incapable of directly influencing the mortal plane. There is, however, a workaround - links between the perceptible \
	universe and Reebe (the Celestial Derelict) can be created and utilized. This is typically done via the creation of a slab akin to the one you are holding right now. The slabs tap into the \
	tidal flow of energy and information keeping Reebe sealed and presents it as meaningless images to preserve sanity. This slab can utilize the power in many different ways.<br><br>\
	\
	This is done through <b>Components</b> - pieces of the Justiciar's body that have since fallen off in the countless years since his imprisonment. Ratvar's unfortunate condition results \
	in the fragmentation of his body. These components still house great power on their own, and can slowly be drawn from Reebe by links capable of doing so. The most basic of these links lies \
	in the clockwork slab, which will slowly generate components over time - around one component of a random type is produced every minute, which is obviously inefficient. There are other ways \
	to create these components through scripture and certain structures.<br><br>\
	\
	In addition to their ability to pull components, slabs also possess other functionalities...<br><br>\
	\
	The first functionality of the slab is Recital. This allows you to consume components either from your slab or from the global cache (more on that in the scripture list) to perform \
	effects usually considered magical in nature. Effects vary considerably - you might drain the power of nearby APCs or break the will of those implanted by Nanotrasen. Nevertheless, scripture \
	is extremely important to a successful takeover.<br><br>\
	\
	The second functionality of the clockwork slab is Records. The slab is not a one-way link and can also feed information into the stream that it draws from. Records will allow many \
	important statistics to be displayed, such as the amount of people converted and total construction value. You should check it often.<br><br>\
	\
	The third functionality is Recollection, which will display this guide. Recollection will automatically be initiated if you have not used a slab before.<br><br>\
	\
	The fourth functionality is the Repository, which will display all components stored within the slab.<br><br>\
	\
	The fifth and final functionality is Report, which allows you to discreetly communicate with all other servants.<br><br>\
	\
	A complete list of scripture, its effects, and its requirements can be found below. <i>Note that anything above a driver always consumes the components listed unless otherwise \
	specified.</i><br><br>"
	var/text_to_add = ""
	var/drivers = "<font color=#BE8700 size=3><b>Drivers</b></font>"
	var/scripts = "<font color=#BE8700 size=3><b>Scripts</b></font><br><i>These scriptures require at least five servants and a tinkerer's cache.</i>"
	var/applications = "<font color=#BE8700 size=3><b>Applications</b></font><br><i>These scriptures require at least eight servants, three tinkerer's caches, and 50CV.</i>"
	var/revenant = "<font color=#BE8700 size=3><b>Revenant</b></font><br><i>These scriptures require at least ten servants and 100CV.</i>"
	var/judgement = "<font color=#BE8700 size=3><b>Judgement</b></font><br><i>These scriptures require at least ten servants and 100CV. In addition, there may not be an active non-servant AI.</i>"
	for(var/V in subtypesof(/datum/clockwork_scripture))
		var/datum/clockwork_scripture/S = V
		var/datum/clockwork_scripture/S2 = new V
		var/list/req_comps = S2.required_components
		qdel(S2)
		switch(initial(S.tier))
			if(SCRIPTURE_DRIVER)
				drivers += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Cost: </b>\
				[req_comps["belligerent_eye"] ? req_comps["belligerent_eye"] : "No"] belligerent eyes, \
				[req_comps["vanguard_cogwheel"] ? req_comps["vanguard_cogwheel"] : "no"] vanguard cogwheels, \
				[req_comps["guvax_capacitor"] ? req_comps["guvax_capacitor"] : "no"] guvax capacitors, \
				[req_comps["replicant_alloy"] ? req_comps["replicant_alloy"] : "no"] replicant alloys, and \
				[req_comps["hierophant_ansible"] ? req_comps["hierophant_ansible"] : "no"] hierophant ansibles.<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
			if(SCRIPTURE_SCRIPT)
				scripts += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Cost: </b>\
				[req_comps["belligerent_eye"] ? req_comps["belligerent_eye"] : "No"] belligerent eyes, \
				[req_comps["vanguard_cogwheel"] ? req_comps["vanguard_cogwheel"] : "no"] vanguard cogwheels, \
				[req_comps["guvax_capacitor"] ? req_comps["guvax_capacitor"] : "no"] guvax capacitors, \
				[req_comps["replicant_alloy"] ? req_comps["replicant_alloy"] : "no"] replicant alloys, and \
				[req_comps["hierophant_ansible"] ? req_comps["hierophant_ansible"] : "no"] hierophant ansibles.<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
			if(SCRIPTURE_APPLICATION)
				applications += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Cost: </b>\
				[req_comps["belligerent_eye"] ? req_comps["belligerent_eye"] : "No"] belligerent eyes, \
				[req_comps["vanguard_cogwheel"] ? req_comps["vanguard_cogwheel"] : "no"] vanguard cogwheels, \
				[req_comps["guvax_capacitor"] ? req_comps["guvax_capacitor"] : "no"] guvax capacitors, \
				[req_comps["replicant_alloy"] ? req_comps["replicant_alloy"] : "no"] replicant alloys, and \
				[req_comps["hierophant_ansible"] ? req_comps["hierophant_ansible"] : "no"] hierophant ansibles.<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
			if(SCRIPTURE_REVENANT)
				revenant += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Cost: </b>\
				[req_comps["belligerent_eye"] ? req_comps["belligerent_eye"] : "No"] belligerent eyes, \
				[req_comps["vanguard_cogwheel"] ? req_comps["vanguard_cogwheel"] : "no"] vanguard cogwheels, \
				[req_comps["guvax_capacitor"] ? req_comps["guvax_capacitor"] : "no"] guvax capacitors, \
				[req_comps["replicant_alloy"] ? req_comps["replicant_alloy"] : "no"] replicant alloys, and \
				[req_comps["hierophant_ansible"] ? req_comps["hierophant_ansible"] : "no"] hierophant ansibles.<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
			if(SCRIPTURE_JUDGEMENT)
				judgement += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Cost: </b>\
				[req_comps["belligerent_eye"] ? req_comps["belligerent_eye"] : "No"] belligerent eyes, \
				[req_comps["vanguard_cogwheel"] ? req_comps["vanguard_cogwheel"] : "no"] vanguard cogwheels, \
				[req_comps["guvax_capacitor"] ? req_comps["guvax_capacitor"] : "no"] guvax capacitors, \
				[req_comps["replicant_alloy"] ? req_comps["replicant_alloy"] : "no"] replicant alloys, and \
				[req_comps["hierophant_ansible"] ? req_comps["hierophant_ansible"] : "no"] hierophant ansibles.<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
	text_to_add += "[drivers]<br>[scripts]<br>[applications]<br>[revenant]<br>[judgement]<br>"
	text_to_add += "<font color=#BE8700 size=3><b><center>Purge all untruths and honor Ratvar.</center></b></font>"
	text += text_to_add
	if(ratvar_awakens)
		text = "<font color=#BE8700 size=3><b>"
		for(var/i in 1 to 100)
			text += "HONOR RATVAR "
		text += "</b></font>"
	var/datum/browser/popup = new(user, "slab", "", 400, 400)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/clockwork/slab/proc/show_components(mob/living/user)
	user << "<b>Stored components:</b>"
	user << "<i>Belligerent Eyes:</i> [stored_components["belligerent_eye"]]"
	user << "<i>Vanguard Cogwheels:</i> [stored_components["vanguard_cogwheel"]]"
	user << "<i>Guvax Capacitors:</i> [stored_components["guvax_capacitor"]]"
	user << "<i>Replicant Alloys:</i> [stored_components["replicant_alloy"]]"
	user << "<i>Hierophant Ansibles:</i> [stored_components["hierophant_ansible"]]"
	return 1

/obj/item/clockwork/slab/proc/show_hierophant(mob/living/user)
	var/message = stripped_input(user, "Enter a message to send to your fellow servants.", "Hierophant")
	if(!message || !user || !user.canUseTopic(src))
		return 0
	user.whisper("Freinagf, urne zl jbeqf. [message]")
	send_hierophant_message(user, message)
	return 1

/obj/item/clothing/glasses/wraith_spectacles //Wraith spectacles: Grants night and x-ray vision at the slow cost of the wearer's sight. Nar-Sian cultists are instantly blinded.
	name = "antique spectacles"
	desc = "Unnerving glasses with opaque yellow lenses."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "wraith_specs"
	item_state = "glasses"
	vision_flags = SEE_MOBS | SEE_TURFS | SEE_OBJS
	invis_view = 2
	darkness_view = 3

/obj/item/clothing/glasses/wraith_spectacles/equipped(mob/living/user, slot)
	..()
	if(slot != slot_glasses)
		return 0
	if(user.disabilities & BLIND)
		user << "<span class='heavy_brass'>\"You're blind, idiot. Stop embarassing yourself.\"</span>" //Ratvar with the sick burns yo
		return 0
	if(iscultist(user)) //Dummy
		user << "<span class='heavy_brass'>\"It looks like Nar-Sie's dogs really don't value their eyes.\"</span>"
		user << "<span class='userdanger'>Your eyes explode with horrific pain!</span>"
		user.emote("scream")
		user.become_blind()
		user.adjust_blurriness(30)
		user.adjust_blindness(30)
		return 1
	user << "<span class='heavy_brass'>As you put on the spectacles, all is revealed to you.[ratvar_awakens ? " Your eyes begin to itch - you cannot do this for long." : ""]</span>"
	return 1

/obj/item/clothing/glasses/wraith_spectacles/New()
	..()
	SSobj.processing += src

/obj/item/clothing/glasses/wraith_spectacles/Destroy()
	SSobj.processing -= src
	..()

/obj/item/clothing/glasses/wraith_spectacles/process()
	if(ratvar_awakens || !ishuman(loc)) //If Ratvar is alive, the spectacles don't hurt your eyes
		return 0
	var/mob/living/carbon/human/H = loc
	if(H.glasses != src)
		return 0
	H.adjust_eye_damage(1)
	if(H.eye_damage >= 10)
		H.adjust_blurriness(2)
	if(H.eye_damage >= 20)
		if(H.become_nearsighted())
			H << "<span class='warning'><b>Your vision doubles, then trebles. Darkness begins to close in. You can't keep this up!</b></span>"
			H.become_nearsighted()
	if(H.eye_damage >= 30)
		if(H.become_blind())
			H << "<span class='userdanger'>A piercing white light floods your vision. Suddenly, all goes dark!</span>"
	if(prob(15) && !H.disabilities & BLIND)
		H << "<span class='warning'>Your eyes continue to burn.</span>"

/obj/item/clothing/glasses/judicial_visor //Judicial visor: Grants the ability to smite an area and stun the unfaithful nearby every thirty seconds.
	name = "judicial visor"
	desc = "A strange purple-lensed visor. Looking at them inspires an odd sense of guilt."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "judicial_visor_0"
	item_state = "sunglasses"
	var/active = FALSE //If the visor is online
	var/recharging = FALSE //If the visor is currently recharging
	var/obj/item/weapon/ratvars_flame/flame //The linked flame object

/obj/item/clothing/glasses/judicial_visor/equipped(mob/living/user, slot)
	..()
	if(slot != slot_glasses)
		update_status(FALSE)
		if(flame)
			qdel(flame)
		return 0
	if(!is_servant_of_ratvar(user))
		return 0
	update_status(TRUE)

/obj/item/clothing/glasses/judicial_visor/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/ratvars_flame))
		user.visible_message("<span class='warning'>The flame in [user]'s hand winks out!</span>", "<span class='heavy_brass'>You dispel the power of [src].</span>")
		qdel(I)
		return 1

/obj/item/clothing/glasses/judicial_visor/AltClick(mob/living/user)
	if(is_servant_of_ratvar(user) && iscarbon(user) && active)
		if(recharging)
			user << "<span class='warning'>[src] is still gathering power!</span>"
			return 0
		var/mob/living/carbon/C = user
		if(C.l_hand && C.r_hand)
			C << "<span class='warning'>You require a free hand to utilize [src]'s power!</span>"
			return 0
		C.visible_message("<span class='warning'>[C]'s hand is enveloped in violet flames!<span>", "<span class='heavy_brass'>You harness [src]'s power. Direct it at a tile on harm intent to unleash it, or hit your visor with it dispel it.</span>")
		var/obj/item/weapon/ratvars_flame/R = new(get_turf(C))
		flame = R
		C.put_in_hands(R)
		R.visor = src
		return 1

/obj/item/clothing/glasses/judicial_visor/proc/update_status(change_to)
	if(recharging)
		icon_state = "judicial_visor_0"
		return 0
	if(active == change_to)
		return 0
	if(!isliving(loc))
		return 0
	var/mob/living/L = loc
	if(!is_servant_of_ratvar(L) || L.stat)
		return 0
	active = change_to
	icon_state = "judicial_visor_[active]"
	switch(active)
		if(TRUE)
			L << "<span class='notice'>As you put on [src], its lens begins to glow, information flashing before your eyes.</span>\n\
			<span class='heavy_brass'>Judicial visor active. Alt-click visor to gain the ability to smite the unworthy.</span>"
		if(FALSE)
			L << "<span class='notice'>As you take off [src], its lens darkens once more.</span>"
	return 1

/obj/item/clothing/head/helmet/clockwork //Clockwork armor: High melee protection but weak to lasers
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet"
	w_class = 3
	armor = list(melee = 65, bullet = 50, laser = -25, energy = 5, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	w_class = 4
	armor = list(melee = 80, bullet = 40, laser = -10, energy = 5, bomb = 0, bio = 0, rad = 0)
	allowed = list(/obj/item/clockwork)

/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"
	w_class = 3
	flags = NOSLIP

/obj/item/weapon/ratvars_flame //Used by the judicial visor
	name = "Ratvar's flame"
	desc = "A blazing violet ball of fire that, curiously, doesn't melt your hand off."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "ratvars_flame" //beware: minecraft-tier sprite
	item_state = "disintegrate"
	color = rgb(180, 50, 210)
	w_class = 5
	flags = NODROP | ABSTRACT
	force = 15 //Also serves as a potent melee weapon!
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	attack_verb = list("scorched")
	var/obj/item/clothing/glasses/judicial_visor/visor //The linked visor

/obj/item/weapon/ratvars_flame/afterattack(atom/target, mob/living/user, flag, params)
	if(!visor || (visor && visor.cooldown))
		qdel(src)
	if(user.a_intent != "harm")
		..()
		return 0
	visor.recharging = TRUE
	for(var/obj/item/clothing/glasses/judicial_visor/V in user.GetAllContents())
		if(V == visor)
			continue
		V.recharging = TRUE //To prevent exploiting multiple visors to bypass the cooldown
	user.say("Xarry, urn'guraf!")
	user.visible_message("<span class='warning'>The flame in [user]'s hand rushes to [target]!</span>", "<span class='heavy_brass'>You direct [visor]'s power to [target]. You must wait for some time before doing this again.</span>")
	new/obj/effect/clockwork/judicial_marker(get_turf(target))
	spawn(ratvar_awakens ? 30 : 300) //Cooldown is reduced by 10x if Ratvar is up
		if(!visor || !user)
			return 0
		visor.recharging = FALSE
		for(var/obj/item/clothing/glasses/judicial_visor/V in user.GetAllContents())
			if(V == visor)
				continue
			V.recharging = TRUE //To prevent exploiting multiple visors to bypass the cooldown
		if(visor.loc == user)
			user << "<span class='brass'>Your [visor.name] hums. It is ready.</span>"
	qdel(src)
	return 1

/obj/item/clockwork/clockwork_proselytizer //Clockwork proselytizer (yes, that's a real word): Converts applicable objects to Ratvarian variants.
	name = "clockwork proselytizer"
	desc = "An odd, L-shaped device that hums with energy."
	clockwork_desc = "A device that allows the replacing of mundane objects with Ratvarian variants. It requires liquified replicant alloy to function."
	icon_state = "clockwork_proselytizer"
	item_state = "resonator_u"
	w_class = 3
	force = 5
	var/stored_alloy = 0 //Requires this to function; each chunk of replicant alloy provides 10 charge
	var/max_alloy = 100
	var/uses_alloy = TRUE

/obj/item/clockwork/clockwork_proselytizer/preloaded
	stored_alloy = 25

/obj/item/clockwork/clockwork_proselytizer/examine(mob/living/user)
	..()
	if((is_servant_of_ratvar(user) || isobserver(user)) && uses_alloy)
		user << "It has [stored_alloy]/[max_alloy] units of liquified replicant alloy stored."

/obj/item/clockwork/clockwork_proselytizer/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user) && uses_alloy)
		if(stored_alloy >= max_alloy)
			user << "<span class='warning'>[src]'s replicant alloy compartments are full!</span>"
			return 0
		modify_stored_alloy(10)
		user << "<span class='brass'>You force [I] to liquify and pour it into [src]'s compartments. It now contains [stored_alloy]/[max_alloy] units of liquified alloy.</span>"
		user.drop_item()
		qdel(I)
		return 1
	..()

/obj/item/clockwork/clockwork_proselytizer/afterattack(atom/target, mob/living/user, flag, params)
	if(!target || !user)
		return 0
	if(user.a_intent == "harm" || !user.Adjacent(target))
		return ..()
	proselytize(target, user)

/obj/item/clockwork/clockwork_proselytizer/proc/modify_stored_alloy(amount)
	if(ratvar_awakens) //Summoning Ratvar doesn't make it free, but it might as well
		amount = 1
	stored_alloy = max(0, min(max_alloy, stored_alloy + amount))
	return 1

/obj/item/clockwork/clockwork_proselytizer/proc/proselytize(atom/target, mob/living/user)
	if(!target || !user)
		return 0
	var/operation_time = 0 //In deciseconds, how long the proselytization will take
	var/new_obj_type //The path of the new type of object to replace the old
	var/alloy_cost = 0
	var/valid_target = FALSE //If the proselytizer will actually function on the object
	switch(target.type)
		if(/turf/closed/wall, /turf/closed/wall/rust)
			operation_time = 50
			new_obj_type = /turf/closed/wall/clockwork
			alloy_cost = 10
			valid_target = TRUE //Need to change valid_target to 1 or TRUE in each check so that it doesn't return an invalid value
		if(/turf/open/floor/plating, /turf/open/floor/plasteel)
			operation_time = 30
			new_obj_type = /turf/open/floor/clockwork
			alloy_cost = 5
			valid_target = TRUE
	if(!uses_alloy)
		alloy_cost = 0
	if(!valid_target)
		user << "<span class='warning'>[target] cannot be proselytized!</span>"
		return 0
	if(!new_obj_type)
		user << "<span class='warning'>That object can't be changed into anything!</span>"
		return 0
	if(stored_alloy - alloy_cost < 0)
		user << "<span class='warning'>You need [alloy_cost] replicant alloy to proselytize [target]!</span>"
		return 0
	user.visible_message("<span class='warning'>[user]'s [src] begins tearing apart [target]!</span>", "<span class='brass'>You begin proselytizing [target]...</span>")
	playsound(target, 'sound/machines/click.ogg', 50, 1)
	if(!do_after(user, operation_time, target = target))
		return 0
	if(stored_alloy - alloy_cost < 0) //Check again to prevent bypassing via spamclick
		return 0
	user.visible_message("<span class='warning'>[user]'s [name] disgorges a chunk of metal and shapes it over what's left of [target]!</span>", \
	"<span class='brass'>You proselytize [target].</span>")
	playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
	if(isturf(target))
		var/turf/T = target
		T.ChangeTurf(new_obj_type)
	else
		new new_obj_type(get_turf(target))
		qdel(target)
	modify_stored_alloy(-alloy_cost)
	return 1

/obj/item/clockwork/ratvarian_spear //Ratvarian spear: A fragile spear from the Celestial Derelict. Deals extreme damage to silicons and enemy cultists, but doesn't last long.
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	clockwork_desc = "A fragile spear of Ratvarian making. It's more effective against enemy cultists and silicons, though it won't last long."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	force = 17 //Extra damage is dealt to silicons in afterattack()
	throwforce = 40
	attack_verb = list("stabbed", "poked", "slashed", "impaled")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = 4

/obj/item/clockwork/ratvarian_spear/New()
	..()
	spawn(1)
		if(ratvar_awakens) //If Ratvar is alive, the spear is extremely powerful
			force = 30
			throwforce = 50
		if(isliving(loc))
			var/mob/living/L = loc
			L << "<span class='warning'>Your spear begins to break down in this plane of existence. You can't use it for long!</span>"
		spawn(300) //5 minutes
			if(src)
				visible_message("<span class='warning'>[src] cracks in two and fades away!</span>")
				qdel(src)

/obj/item/clockwork/ratvarian_spear/afterattack(atom/target, mob/living/user, flag, params)
	if(!target || !user)
		return 0
	if(!ismob(target))
		return ..()
	var/mob/living/L = target
	if(issilicon(L))
		var/mob/living/silicon/S = L
		if(S.stat != DEAD)
			S.visible_message("<span class='warning'>[S] shudders violently at [src]'s touch!</span>", "<span class='userdanger'>ERROR: Temperature rising!</span>")
			S.adjustFireLoss(25)
	if(iscultist(L))
		var/mob/living/M = L
		M << "<span class='userdanger'>Your body flares with agony at [src]'s touch!</span>"
		M.adjustFireLoss(10)
	..()

/obj/item/clockwork/ratvarian_spear/throw_impact(atom/target)
	..()
	if(!ismob(target))
		return 0
	var/mob/living/L = target
	if(issilicon(L) || iscultist(L))
		L.Stun(3)
		L.Weaken(3)
	visible_message("<span class='warning'>[src] snaps in two and dematerializes!</span>")
	qdel(src)

/obj/item/device/mmi/posibrain/soul_vessel //Soul vessel: An ancient positronic brain with a lawset catered to serving Ratvar.
	name = "soul vessel"
	desc = "A heavy brass cube with a single protruding cogwheel."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	req_access = list()
	braintype = "Servant"
	begin_activation_message = "<span class='brass'>You activate the cogwheel. It hitches and stalls as it begins spinning.</span>"
	success_message = "<span class='brass'>The cogwheel's rotation smooths out as the soul vessel activates.</span>"
	fail_message = "<span class='warning'>The cogwheel creaks and grinds to a halt. Maybe you could try again?</span>"
	new_role = "Soul Vessel"
	welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a soul vessel - a clockwork mind created by Ratvar, the Clockwork Justiciar.\n\
	You answer to Ratvar and his servants. It is your discretion as to whether or not to answer to anyone else.\n\
	The purpose of your existence is to further the goals of the servants and Ratvar himself. Above all else, serve Ratvar.</b>"
	new_mob_message = "<span class='brass'>The soul vessel emits a jet of steam before its cogwheel smooths out.</span>"
	dead_message = "<span class='deadsay'>Its cogwheel, scratched and dented, lies motionless.</span>"
	fluff_names = list("Servant")
	clockwork = TRUE

/obj/item/device/mmi/posibrain/soul_vessel/New()
	..()
	all_clockwork_objects += src

/obj/item/device/mmi/posibrain/soul_vessel/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/device/mmi/posibrain/soul_vessel/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		user << "<span class='warning'>You fiddle around with [src], to no avail.</span>"
		return 0
	..()

/obj/item/clockwork/daemon_shell
	name = "daemon shell"
	desc = "A vaguely arachnoid brass shell with a single empty socket in its body."
	clockwork_desc = "An unpowered daemon. It needs to be attached to a cache."
	icon_state = "daemon_shell"
	w_class = 3

/obj/item/clockwork/tinkerers_daemon //Shouldn't ever appear on its own
	name = "tinkerer's daemon"
	desc = "An arachnoid shell with a single spinning cogwheel in its center."
	clockwork_desc = "A tinkerer's daemon, dutifully producing components."
	icon_state = "tinkerers_daemon"
	w_class = 3
	var/specific_component //The type of component that the daemon is set to produce in particular, if any
	var/obj/structure/clockwork/cache/cache //The cache the daemon is feeding
	var/production_progress = 0 //Progress towards production of the next component in seconds
	var/production_interval = 30 //How many seconds it takes to produce a new component

/obj/item/clockwork/tinkerers_daemon/New()
	..()
	SSobj.processing += src
	clockwork_daemons++

/obj/item/clockwork/tinkerers_daemon/Destroy()
	SSobj.processing -= src
	clockwork_daemons--
	..()

/obj/item/clockwork/tinkerers_daemon/process()
	if(!cache)
		visible_message("<span class='warning'>[src] shuts down!</span>")
		new/obj/item/clockwork/daemon_shell(get_turf(src))
		qdel(src)
		return 0
	var/servants = 0
	for(var/mob/living/L in living_mob_list)
		if(is_servant_of_ratvar(L))
			servants++
	if(servants / 5 < clockwork_daemons)
		return 0
	production_progress = min(production_progress + 1, production_interval)
	if(production_progress >= production_interval)
		production_progress = 0 //Start it over
		if(specific_component)
			clockwork_component_cache[specific_component]++
		else
			clockwork_component_cache[pick("belligerent_eye", "vanguard_cogwheel", "guvax_capacitor", "replicant_alloy", "hierophant_ansible")]++
		cache.visible_message("<span class='warning'>Something clunks around inside of [cache].</span>")

/obj/item/clockwork/tinkerers_daemon/attack_hand(mob/user)
	return 0

//////////////////////////
// CLOCKWORK COMPONENTS //
//////////////////////////

/obj/item/clockwork/component //Components: Used in scripture among other things.
	name = "meme component"
	desc = "A piece of a famous meme."
	clockwork_desc = null
	var/component_id //What the component is identified as
	var/cultist_message = "You are not worthy of this meme." //Showed to Nar-Sian cultists if they pick up the component in addition to chaplains
	var/list/servant_of_ratvar_messages = list("ayy", "lmao") //Fluff, shown to servants of Ratvar on a low chance

/obj/item/clockwork/component/pickup(mob/living/user)
	..()
	if(iscultist(user) || (user.mind && user.mind.assigned_role == "Chaplain"))
		user << "<span class='heavy_brass'>[cultist_message]</span>"
	if(is_servant_of_ratvar(user) && prob(15))
		user << "<span class='heavy_brass'>[pick(servant_of_ratvar_messages)]</span>"

/obj/item/clockwork/component/belligerent_eye
	name = "belligerent eye"
	desc = "A brass construct with a rotating red center. It's as though it's looking for something to hurt."
	icon_state = "belligerent_eye"
	component_id = "belligerent_eye"
	cultist_message = "The eye gives you an intensely hateful glare."
	servant_of_ratvar_messages = list("\"...\"", "For a moment, your mind is flooded with extremely violent thoughts.")

/obj/item/clockwork/component/vanguard_cogwheel
	name = "vanguard cogwheel"
	desc = "A sturdy brass cog with a faintly glowing blue gem in its center."
	icon_state = "vanguard_cogwheel"
	component_id = "vanguard_cogwheel"
	cultist_message = "\"Pray to your god that we never meet.\""
	servant_of_ratvar_messages = list("\"Be safe, child.\"", "You feel unexplainably comforted.", "\"Never forget: pain is temporary. The Justiciar's glory is eternal.\"")

/obj/item/clockwork/component/guvax_capacitor
	name = "guvax capacitor"
	desc = "A curiously cold brass doodad. It seems as though it really doesn't appreciate being held."
	icon_state = "guvax_capacitor"
	component_id = "guvax_capacitor"
	cultist_message = "\"Try not to lose your mind - I'll need it. Heh heh...\""
	servant_of_ratvar_messages = list("\"Disgusting.\"", "\"Well, aren't you an inquisitive fellow?\"", "A foul presence pervades your mind, then vanishes.", "\"The fact that Ratvar has to depend on simpletons like you is appalling.\"")

/obj/item/clockwork/component/replicant_alloy
	name = "replicant alloy"
	desc = "A seemingly strong but very malleable chunk of metal. It seems as though it wants to be molded into something greater."
	icon_state = "replicant_alloy"
	component_id = "replicant_alloy"
	cultist_message = "The alloy takes on the appearance of a screaming face for a moment."
	servant_of_ratvar_messages = list("\"There's always something to be done. Get to it.\"", "\"Idle hands are worse than broken ones. Get to work.\"", "A detailed image of Ratvar appears in the alloy for a moment.")

/obj/item/clockwork/component/replicant_alloy/smashed_anima_fragment
	name = "smashed anima fragment"
	desc = "Shattered chunks of metal. Damaged beyond repair and completely unusable."
	clockwork_desc = "The sad remains of an anima fragment. Might still be serviceable as a substitute for replicant alloy."
	icon_state = "smashed_anime_fragment"
	cultist_message = "The shards vibrate in your hands for a moment."
	servant_of_ratvar_messages = list("\"...still fight...\"", "\"...where am I...?\"", "\"...put me... slab...\"")
	w_class = 3

/obj/item/clockwork/component/replicant_alloy/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	clockwork_desc = "The armor from a former clockwork marauder. Might still be serviceable as a substitute for replicant alloy."
	icon_state = "fallen_armor"
	cultist_message = "Red flame sputters from the mask's eye before winking out."
	servant_of_ratvar_messages = list("A piece of armor hovers away from the others for a moment.", "Red flame appears in the cuirass before sputtering out.")
	w_class = 3

/obj/item/clockwork/component/replicant_alloy/blind_eye
	name = "blind eye"
	desc = "A heavy brass eye, its red iris fallen dark."
	clockwork_desc = "A smashed ocular warden covered in dents. Might still be serviceable as a substitute for replicant alloy."
	icon_state = "blind_eye"
	cultist_message = "The eye flickers at you with intense hate before falling dark."
	servant_of_ratvar_messages = list("The eye flickers before falling dark.", "You feel watched.")
	w_class = 3

/obj/item/clockwork/component/hierophant_ansible
	name = "hierophant ansible"
	desc = "Some sort of transmitter? It seems as though it's trying to say something."
	icon_state = "hierophant_ansible"
	component_id = "hierophant_ansible"
	cultist_message = "\"Gur obff nlf vg'f abg ntnvafg gur ehyrf gb xvyy lbh.\""
	servant_of_ratvar_messages = list("\"Rkvyr vf fhpu n'ober. Gurer'f abguvat v'pna uhag va urer.\"", "\"Jung'f xrrcvat lbh? V'jnag gb tb xvyy fbzrguvat.\"", "\"HEHEHEHEHEHEH!\"")

//////////////////////////
// CLOCKWORK STRUCTURES //
//////////////////////////

/obj/structure/clockwork
	name = "meme structure"
	desc = "Some frog or something, the fuck?"
	var/clockwork_desc = "This fabled artifact from beyond the stars contains concentrated meme essence." //See above
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	anchored = 1
	density = 1
	opacity = 0
	var/max_health = 100 //All clockwork structures have health that can be removed via attacks
	var/health = 100
	var/takes_damage = TRUE //If the structure can be damaged
	var/break_message = "<span class='warning'>The frog isn't a meme after all!</span>" //The message shown when a structure breaks
	var/break_sound = 'sound/magic/clockwork/anima_fragment_death.ogg' //The sound played when a structure breaks
	var/list/debris = list(/obj/item/clockwork/component/replicant_alloy) //Parts left behind when a structure breaks
	var/construction_value = 0 //How much value the structure contributes to the overall "power" of the structures on the station

/obj/structure/clockwork/New()
	..()
	clockwork_construction_value += construction_value
	all_clockwork_objects += src

/obj/structure/clockwork/Destroy()
	clockwork_construction_value -= construction_value
	all_clockwork_objects -= src
	..()

/obj/structure/clockwork/proc/destroyed()
	if(!takes_damage)
		return 0
	for(var/obj/item/I in debris)
		new I (get_turf(src))
	visible_message(break_message)
	playsound(src, break_sound, 50, 1)
	qdel(src)
	return 1

/obj/structure/clockwork/ex_act(severity)
	if(takes_damage)
		switch(severity)
			if(1)
				health -= max_health * 0.7 //70% max health lost
			if(2)
				health -= max_health * 0.4 //40% max health lost
			if(3)
				if(prob(50))
					health -= max_health * 0.1 //10% max health lost
		if(health <= max_health * 0.1) //If there's less than 10% max health left, destroy it
			destroyed()
			qdel(src)

/obj/structure/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/structure/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == "harm" && user.canUseTopic(I) && I.force)
		user.visible_message("<span class='warning'>[user] strikes [src] with [I]!</span>", "<span class='danger'>You strike [src] with [I]!</span>")
		playsound(src, I.hitsound, 50, 1)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		health = max(0, health - I.force)
		if(!health)
			destroyed()
			return 0
	else
		..()

/obj/structure/clockwork/cache //Tinkerer's cache: Stores components for later use.
	name = "tinkerer's cache"
	desc = "A large brass spire with a flaming hole in its center."
	clockwork_desc = "A brass container capable of storing a large amount of components. Shares components with all other caches."
	icon_state = "tinkerers_cache"
	construction_value = 10
	break_message = "<span class='warning'>The cache's fire winks out before it falls in on itself!</span>"

/obj/structure/clockwork/cache/New()
	..()
	clockwork_caches++

/obj/structure/clockwork/cache/Destroy()
	clockwork_caches--
	return ..()

/obj/structure/clockwork/cache/attackby(obj/item/I, mob/living/user, params)
	if(!is_servant_of_ratvar(user))
		..()
		return 0
	if(istype(I, /obj/item/clockwork/component))
		var/obj/item/clockwork/component/C = I
		clockwork_component_cache[C.component_id]++
		user << "<span class='notice'>You add [C] to [src].</span>"
		user.drop_item()
		qdel(C)
		return 1
	if(istype(I, /obj/item/clockwork/slab))
		var/obj/item/clockwork/slab/S = I
		clockwork_component_cache["belligerent_eye"] += S.stored_components["belligerent_eye"]
		clockwork_component_cache["vanguard_cogwheel"] += S.stored_components["vanguard_cogwheel"]
		clockwork_component_cache["guvax_capacitor"] += S.stored_components["guvax_capacitor"]
		clockwork_component_cache["replicant_alloy"] += S.stored_components["replicant_alloy"]
		clockwork_component_cache["hierophant_ansible"] += S.stored_components["hierophant_ansible"]
		S.stored_components["belligerent_eye"] = 0
		S.stored_components["vanguard_cogwheel"] = 0
		S.stored_components["guvax_capacitor"] = 0
		S.stored_components["replicant_alloy"] = 0
		S.stored_components["hierophant_ansible"] = 0
		user.visible_message("<span class='notice'>[user] empties [S] into [src].</span>", "<span class='notice'>You offload your slab's components into [src].</span>")
		return 1
	if(istype(I, /obj/item/clockwork/daemon_shell))
		var/component_type
		switch(alert(user, "Will this daemon produce a specific type of component or produce randomly?.", , "Specific Type", "Random Component"))
			if("Specific Type")
				switch(input(user, "Choose a component type.", name) as null|anything in list("Belligerent Eyes", "Vanguard Cogwheels", "Guvax Capacitors", "Replicant Alloys", "Hierophant Ansibles"))
					if("Belligerent Eyes")
						component_type = "belligerent_eye"
					if("Vanguard Cogwheels")
						component_type = "vanguard_cogwheel"
					if("Guvax Capacitors")
						component_type = "guvax_capacitor"
					if("Replicant Alloys")
						component_type = "replicant_alloy"
					if("Hierophant Ansibles")
						component_type = "hierophant_ansibles"
		if(!user || !user.canUseTopic(src) || !user.canUseTopic(I))
			return 0
		var/obj/item/clockwork/tinkerers_daemon/D = new(src)
		D.cache = src
		D.specific_component = component_type
		user.visible_message("<span class='notice'>[user] spins the cogwheel on [I] and puts it into [src].</span>", \
		"<span class='notice'>You activate the daemon and put it into [src]. It will now produce a component every thirty seconds.</span>")
		user.drop_item()
		qdel(I)
		return 1
	..()

/obj/structure/clockwork/cache/attack_hand(mob/user)
	if(!is_servant_of_ratvar(user))
		return 0
	var/list/possible_components = list()
	if(clockwork_component_cache["belligerent_eye"])
		possible_components += "Belligerent Eye"
	if(clockwork_component_cache["vanguard_cogwheel"])
		possible_components += "Vanguard Cogwheel"
	if(clockwork_component_cache["guvax_capacitor"])
		possible_components += "Guvax Capacitor"
	if(clockwork_component_cache["replicant_alloy"])
		possible_components += "Replicant Alloy"
	if(clockwork_component_cache["hierophant_ansible"])
		possible_components += "Hierophant Ansible"
	if(!possible_components.len)
		user << "<span class='warning'>[src] is empty!</span>"
		return 0
	var/component_to_withdraw = input(user, "Choose a component to withdraw.", name) as null|anything in possible_components
	if(!user || !user.canUseTopic(src) || !component_to_withdraw)
		return 0
	var/obj/item/clockwork/component/the_component
	switch(component_to_withdraw)
		if("Belligerent Eye")
			the_component = new/obj/item/clockwork/component/belligerent_eye(get_turf(src))
			clockwork_component_cache["belligerent_eye"]--
		if("Vanguard Cogwheel")
			the_component = new/obj/item/clockwork/component/vanguard_cogwheel(get_turf(src))
			clockwork_component_cache["vanguard_cogwheel"]--
		if("Guvax Capacitor")
			the_component = new/obj/item/clockwork/component/guvax_capacitor(get_turf(src))
			clockwork_component_cache["guvax_capacitor"]--
		if("Replicant Alloy")
			the_component = new/obj/item/clockwork/component/replicant_alloy(get_turf(src))
			clockwork_component_cache["replicant_alloy"]--
		if("Hierophant Ansible")
			the_component = new/obj/item/clockwork/component/hierophant_ansible(get_turf(src))
			clockwork_component_cache["hierophant_ansible"]--
	if(the_component)
		user.visible_message("<span class='notice'>[user] withdraws [the_component] from [src].</span>", "<span class='notice'>You withdraw [the_component] from [src].</span>")
		user.put_in_hands(the_component)
	return 1

/obj/structure/clockwork/cache/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<b>Stored components:</b>"
		user << "<i>Belligerent Eyes:</i> [clockwork_component_cache["belligerent_eye"]]"
		user << "<i>Vanguard Cogwheels:</i> [clockwork_component_cache["vanguard_cogwheel"]]"
		user << "<i>Guvax Capacitors:</i> [clockwork_component_cache["guvax_capacitor"]]"
		user << "<i>Replicant Alloys:</i> [clockwork_component_cache["replicant_alloy"]]"
		user << "<i>Hierophant Ansibles:</i> [clockwork_component_cache["hierophant_ansible"]]"

/obj/structure/clockwork/ocular_warden //Ocular warden: Low-damage, low-range turret. Deals constant damage to whoever it makes eye contact with.
	name = "ocular warden"
	desc = "A large brass eye with tendrils trailing below it and a wide red iris."
	clockwork_desc = "A stalwart turret that will deal sustained damage to any non-faithful it sees."
	icon_state = "ocular_warden"
	health = 25
	max_health = 25
	construction_value = 15
	break_message = "<span class='warning'>The warden's eye gives a glare of utter hate before falling dark!</span>"
	debris = list(/obj/item/clockwork/component/replicant_alloy/blind_eye)
	var/damage_per_tick = 3
	var/sight_range = 3
	var/mob/living/target

/obj/structure/clockwork/ocular_warden/New()
	..()
	SSfastprocess.processing += src

/obj/structure/clockwork/ocular_warden/Destroy()
	SSfastprocess.processing -= src
	return ..()

/obj/structure/clockwork/ocular_warden/examine(mob/user)
	..()
	user << "[target ? "It's fixated on [target]" : "Its gaze is wandering aimlessly"]."

/obj/structure/clockwork/ocular_warden/process()
	if(ratvar_awakens && (damage_per_tick == initial(damage_per_tick) || sight_range == initial(sight_range))) //Massive buff if Ratvar has returned
		damage_per_tick = 10
		sight_range = 5
	if(target)
		if(target.stat || get_dist(get_turf(src), get_turf(target)) > sight_range)
			lose_target()
		else
			target.adjustFireLoss(!iscultist(target) ? damage_per_tick : damage_per_tick * 2) //Nar-Sian cultists take additional damage
			if(ratvar_awakens)
				target.adjust_fire_stacks(damage_per_tick)
				target.IgniteMob()
			dir = get_dir(get_turf(src), get_turf(target))
	else
		if(!acquire_nearby_target() && prob(0.5)) //Extremely low chance because of how fast the subsystem it uses processes
			var/list/idle_messages = list("[src] sulkily glares around.", "[src] lazily drifts from side to side.", "[src] looks around for something to burn.", "[src] slowly turns in circles.")
			if(prob(50))
				visible_message("<span class='notice'>[pick(idle_messages)]</span>")
			else
				dir = pick(NORTH, EAST, SOUTH, WEST) //Random rotation

/obj/structure/clockwork/ocular_warden/proc/acquire_nearby_target()
	var/list/possible_targets = list()
	for(var/mob/living/L in viewers(sight_range, src)) //Doesn't attack the blind
		if(!is_servant_of_ratvar(L) && !L.stat && L.mind)
			possible_targets += L
	if(!possible_targets.len)
		return 0
	target = pick(possible_targets)
	visible_message("<span class='warning'>[src] swivels to face [target]!</span>")
	target << "<span class='heavy_brass'>\"I SEE YOU!\"</span>\n<span class='userdanger'>[src]'s gaze [ratvar_awakens ? "melts you alive" : "burns you"]!</span>"
	return 1

/obj/structure/clockwork/ocular_warden/proc/lose_target()
	if(!target)
		return 0
	target = null
	visible_message("<span class='warning'>[src] settles and seems almost disappointed.</span>")
	return 1

/obj/structure/clockwork/anima_fragment //Anima fragment: Useless on its own, but can accept an active soul vessel to create a powerful construct.
	name = "anima fragment"
	desc = "A massive brass shell with a small cube-shaped receptable in its center. It gives off an aura of contained power."
	clockwork_desc = "A dormant receptable that, when powered with a soul vessel, will become a powerful construct."
	icon_state = "anime_fragment"
	construction_value = 0
	anchored = 0
	density = 0
	takes_damage = FALSE

/obj/structure/clockwork/anima_fragment/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/device/mmi/posibrain/soul_vessel))
		if(!is_servant_of_ratvar(user))
			..()
			return 0
		var/obj/item/device/mmi/posibrain/soul_vessel/S = I
		if(!S.brainmob)
			user << "<span class='warning'>[S] hasn't trapped a spirit! Turn it on first.</span>"
			return 0
		if(S.brainmob && (!S.brainmob.client || !S.brainmob.mind))
			user << "<span class='warning'>[S]'s trapped spirit appears inactive!</span>"
			return 0
		user.visible_message("<span class='notice'>[user] clicks [S] into place on [src].</span>", "<span class='brass'>You insert [S] into [src]. It whirs and begins to rise.</span>")
		var/mob/living/simple_animal/hostile/anima_fragment/A = new(get_turf(src))
		S.brainmob.mind.transfer_to(A)
		add_servant_of_ratvar(A, TRUE)
		A << A.playstyle_string
		user.drop_item()
		qdel(S)
		qdel(src)
		return 1
	..()

/obj/structure/clockwork/interdiction_lens //Interdiction lens: A powerful artifact that can massively disrupt electronics. Five-minute cooldown between uses.
	name = "interdiction lens"
	desc = "An ominous, double-pronged brass obelisk. There's a strange gemstone clasped between the pincers."
	clockwork_desc = "A powerful obelisk that can devastate certain electronics. It needs to recharge between uses."
	icon_state = "interdiction_lens"
	construction_value = 25
	break_message = "<span class='warning'>The lens flares a blinding violet before shattering!</span>"
	break_sound = 'sound/effects/Glassbr3.ogg'
	var/recharging = FALSE //If the lens is still recharging its energy

/obj/structure/clockwork/interdiction_lens/examine(mob/user)
	..()
	user << "Its gemstone [recharging ? "has been breached by writhing tendrils of blackness that cover the obelisk" : "vibrates in place and thrums with power"],"

/obj/structure/clockwork/interdiction_lens/attack_hand(mob/living/user)
	if(user.canUseTopic(src))
		disrupt(user)

/obj/structure/clockwork/interdiction_lens/proc/disrupt(mob/living/user)
	if(!user || !is_servant_of_ratvar(user))
		return 0
	if(recharging)
		user << "<span class='warning'>As you place your hand on the gemstone, cold tendrils of black matter crawl up your arm. You quickly pull back.</span>"
		return 0
	user.visible_message("<span class='warning'>[user] places their hand on [src]' gemstone...</span>", "<span class='brass'>You place your hand on the gemstone...</span>")
	var/target = input(user, "Power flows through you. Choose where to direct it.", "Interdiction Lens") as null|anything in list("Disrupt Telecommunications", "Disable Cameras", "Disable Cyborgs")
	if(!user.canUseTopic(src) || !target)
		user.visible_message("<span class='warning'>[user] pulls their hand back.</span>", "<span class='brass'>On second thought, maybe not right now.</span>")
		return 0
	user.visible_message("<span class='warning'>Violet tendrils engulf [user]'s arm as the gemstone glows with furious energy!</span>", \
	"<span class='heavy_brass'>A mass of violet tendrils cover your arm as [src] unleashes a blast of power!</span>")
	user.notransform = TRUE
	icon_state = "[initial(icon_state)]_active"
	recharging = TRUE
	sleep(30)
	switch(target)
		if("Disrupt Telecommunications")
			for(var/obj/machinery/telecomms/hub/H in telecomms_list)
				for(var/mob/M in range(7, H))
					M << "<span class='warning'>You sense a strange force pass through you...</span>"
				H.visible_message("<span class='warning'>The lights on [H] flare a blinding yellow before falling dark!</span>")
				H.emp_act(1)
		if("Disable Cameras")
			for(var/obj/machinery/camera/C in cameranet.cameras)
				C.emp_act(1)
			for(var/mob/living/silicon/ai/A in living_mob_list)
				A << "<span class='userdanger'>Massive energy surge detected. All cameras offline.</span>"
				A << 'sound/machines/warning-buzzer.ogg'
		if("Disable Cyborgs")
			for(var/mob/living/silicon/robot/R in living_mob_list) //Doesn't include AIs, for obvious reasons
				if(is_servant_of_ratvar(R) || R.stat) //Doesn't affect already-offline cyborgs
					continue
				R.visible_message("<span class='warning'>[R] shuts down with no warning!</span>", \
				"<span class='userdanger'>Massive emergy surge detected. All systems offline. Initiating reboot sequence..</span>")
				playsound(R, 'sound/machines/warning-buzzer.ogg', 50, 1)
				R.Weaken(30)
	user.visible_message("<span class='warning'>The tendrils around [user]'s arm turn to an onyx black and wither away!</span>", \
	"<span class='heavy_brass'>The tendrils around your arm turn a horrible black and sting your skin before they shrivel away.</span>")
	user.notransform = FALSE
	if(!src)
		return 0
	flick("[initial(icon_state)]_discharged", src)
	icon_state = "[initial(icon_state)]_recharging"
	spawn(3000) //5 minutes
		if(!src)
			return 0
		visible_message("<span class='warning'>The writhing tendrils return to the gemstone, which begins to glow with power.</span>")
		flick("[initial(icon_state)]_recharged", src)
		icon_state = initial(icon_state)
		recharging = FALSE
	return 1

/obj/structure/clockwork/mending_motor //Mending motor: A prism that consumes replicant alloy to repair nearby mechanical servants at a quick rate.
	name = "mending motor"
	desc = "A dark onyx prism, held in midair by spiraling tendrils of stone."
	clockwork_desc = "A powerful prism that rapidly repairs nearby mechanical servants and clockwork structures."
	icon_state = "mending_motor"
	construction_value = 20
	break_message = "<span class='warning'>The prism collapses with a heavy thud!</span>"
	var/stored_alloy = 0
	var/max_alloy = 150
	var/uses_alloy = TRUE
	var/active = TRUE

/obj/structure/clockwork/mending_motor/prefilled
	stored_alloy = 30

/obj/structure/clockwork/mending_motor/New()
	..()
	SSobj.processing += src
	toggle() //Toggles off as soon as it's created, but starts online for reasons

/obj/structure/clockwork/mending_motor/Destroy()
	SSobj.processing -= src
	..()

/obj/structure/clockwork/mending_motor/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "It has [stored_alloy]/[max_alloy] units of replicant alloy."

/obj/structure/clockwork/mending_motor/process()
	if(!active)
		return 0
	if(!stored_alloy && uses_alloy)
		visible_message("<span class='warning'>[src] emits an airy chuckling sound and falls dark!</span>")
		toggle()
		return 0
	for(var/mob/living/simple_animal/hostile/anima_fragment/F in range(5, src))
		if(F.health == F.maxHealth || F.stat)
			continue
		F.adjustBruteLoss(-15)
		if(uses_alloy)
			stored_alloy = max(0, stored_alloy - 2)
	for(var/mob/living/simple_animal/hostile/clockwork_marauder/M in range(5, src))
		if(M.health == M.maxHealth || M.stat)
			continue
		M.adjustBruteLoss(-M.maxHealth) //Instant because marauders don't usually take health damage
		M.fatigue = max(0, M.fatigue - 15)
		if(uses_alloy)
			stored_alloy = max(0, stored_alloy - 2)
	for(var/mob/living/silicon/S in range(5, src))
		if(S.health == S.maxHealth || S.stat == DEAD || !is_servant_of_ratvar(S))
			continue
		S.adjustBruteLoss(-25)
		S.adjustFireLoss(-25)
		if(uses_alloy)
			stored_alloy = max(0, stored_alloy - 5) //Much higher cost because silicons are much more useful
	for(var/obj/structure/clockwork/C in range(5, src))
		if(C.health == C.max_health)
			continue
		C.health = min(C.health + 10, C.max_health)
		if(uses_alloy)
			stored_alloy = max(0, stored_alloy - 1)


/obj/structure/clockwork/mending_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src)) //Unnecessary?
		if(!stored_alloy)
			user << "<span class='warning'>[src] needs more replicant alloy to function!</span>"
			return 0
		toggle(user)

/obj/structure/clockwork/mending_motor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user))
		if(stored_alloy + 10 > max_alloy)
			user << "<span class='warning'>[src] is too full to accept any more alloy!</span>"
			return 0
		user.whisper("Genafzhgr vagb jngre.")
		user.visible_message("<span class='notice'>[user] liquifies [I] and pours it onto [src].</span>", \
		"<span class='notice'>You liquify [src] and pour it onto [src], which transfers the alloy into its reserves.</span>")
		stored_alloy = min(max(0, stored_alloy + 10), max_alloy)
		user.drop_item()
		qdel(I)
		return 1
	..()

/obj/structure/clockwork/mending_motor/proc/toggle(mob/living/user)
	active = !active
	if(user && is_servant_of_ratvar(user))
		user.visible_message("<span class='notice'>[user] [active ? "en" : "dis"]ables [src].</span>", "<span class='brass'>You [active ? "en" : "dis"]able [src].</span>")
	if(active)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_inactive"

///////////////////////
// CLOCKWORK EFFECTS //
///////////////////////

/obj/effect/clockwork
	name = "meme machine"
	desc = "Still don't know what it is."
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "ratvars_flame"
	anchored = 1
	density = 0
	opacity = 0

/obj/effect/clockwork/New()
	..()
	all_clockwork_objects += src

/obj/effect/clockwork/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/effect/clockwork/examine(mob/user)
	if(is_servant_of_ratvar(user) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/effect/clockwork/judicial_marker //Judicial marker: Created by the judicial visor. After four seconds, stuns any non-servants nearby and damages Nar-Sian cultists.
	name = "judicial marker"
	desc = "You get the feeling that you shouldn't be standing here."
	clockwork_desc = "A sigil that will soon erupt and smite any unenlightened nearby."
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -30
	pixel_y = -30
	layer = ABOVE_OPEN_TURF_LAYER

/obj/effect/clockwork/judicial_marker/New()
	..()
	flick("judicial_marker", src)
	spawn(25) //Utilizes spawns due to how it works with Ratvar's flame
		flick("judicial_explosion", src)
		spawn(15)
			for(var/mob/living/L in range(1, src))
				if(is_servant_of_ratvar(L))
					continue
				if(!iscultist(L))
					L << "<span class='userdanger'>[!issilicon(L) ? "An unseen force slams you into the ground!" : "ERROR: Motor servos disabled by external source!"]</span>"
					L.Weaken(8)
				else
					L << "<span class='heavy_brass'>\"Keep an eye out, filth.\"</span>\n<span class='userdanger'>[!issilicon(L) ? "An unseen force piledrives you into the ground!" : "ERROR: Motor servos damaged by external source!"]</span>"
					L.Weaken(10)
					L.adjustBruteLoss(10)
			qdel(src)
			return 1

/obj/effect/clockwork/spatial_gateway //Spatial gateway: A one-way rift to another location.
	name = "spatial gateway"
	desc = "A gently thrumming tear in reality."
	clockwork_desc = "A gateway in reality. It can either send or receive, but not both."
	icon_state = "spatial_gateway"
	density = 1
	var/sender = TRUE //If this gateway is made for sending, not receiving
	var/lifetime = 25 //How many deciseconds this portal will last
	var/uses = 1 //How many objects or mobs can go through the portal
	var/obj/effect/clockwork/spatial_gateway/linked_gateway //The gateway linked to this one

/obj/effect/clockwork/spatial_gateway/New()
	..()
	spawn(1)
		if(!linked_gateway)
			qdel(src)
			return 0
		else
			if(linked_gateway.sender == sender)
				linked_gateway.sender = !sender
		spawn(lifetime)
			if(src)
				qdel(src)

/obj/effect/clockwork/spatial_gateway/Destroy()
	visible_message("<span class='warning'>[src] flickers and closes!</span>")
	animate(src, transform = matrix() - matrix(), time = 10)
	spawn(10)
		..()

/obj/effect/clockwork/spatial_gateway/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "This gateway can only [sender ? "send" : "receive"] objects."

/obj/effect/clockwork/spatial_gateway/attack_hand(mob/living/user)
	if(user.pulling && user.a_intent == "grab" && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.anchored || L.buckled_mobs.len)
			return 0
		user.visible_message("<span class='warning'>[user] shoves [L] into [src]!</span>", "<span class='danger'>You shove [L] into [src]!</span>")
		user.stop_pulling()
		pass_through_gateway(L)
		return 1
	if(!user.canUseTopic(src))
		return 0
	user.visible_message("<span class='warning'>[user] climbs through [src]!</span>", "<span class='danger'>You brace yourself and step through [src]...</span>")
	pass_through_gateway(user)
	return 1

/obj/effect/clockwork/spatial_gateway/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/nullrod))
		user.visible_message("<span class='warning'>[user] dispels [src] with [I]!</span>", "<span class='danger'>You close [src] with [I]!</span>")
		qdel(linked_gateway)
		qdel(src)
		return 1
	if(user.drop_item())
		pass_through_gateway(I)
	..()

/obj/effect/clockwork/spatial_gateway/Bumped(atom/A)
	..()
	if(isliving(A) || istype(A, /obj/item))
		pass_through_gateway(A)

/obj/effect/clockwork/spatial_gateway/proc/pass_through_gateway(atom/movable/A)
	if(!linked_gateway)
		qdel(src)
		return 0
	if(!sender)
		visible_message("<span class='warning'>[A] bounces off of [src]!</span>")
		return 0
	if(isliving(A))
		var/mob/living/user = A
		user << "<span class='warning'><b>You pass through [src] and appear elsewhere!</b></span>"
	linked_gateway.visible_message("<span class='warning'>A shape appears in [linked_gateway] before emerging!</span>")
	playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)
	playsound(linked_gateway, 'sound/effects/EMPulse.ogg', 50, 1)
	transform = matrix() * 1.5
	animate(src, transform = matrix() / 1.5, time = 10)
	linked_gateway.transform = matrix() * 1.5
	animate(linked_gateway, transform = matrix() / 1.5, time = 10)
	if(ismob(A))
		var/mob/M = A
		M.forceMove(get_turf(linked_gateway))
	else
		A.loc = get_turf(linked_gateway)
	uses = max(0, uses - 1)
	linked_gateway.uses = max(0, uses - 1)
	spawn(10)
		if(!uses)
			qdel(src)
			qdel(linked_gateway)
	return 1

/obj/effect/clockwork/general_marker
	name = "general marker"
	desc = "Some big guy."
	clockwork_desc = "One of Ratvar's generals."
	alpha = 200
	layer = MASSIVE_OBJ_LAYER

/obj/effect/clockwork/general_marker/New()
	..()
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 50, 0)
	animate(src, alpha = 0, time = 10)
	spawn(10)
		qdel(src)

/obj/effect/clockwork/general_marker/nezbere
	name = "Nezbere, the Brass Eidolon"
	desc = "A towering colossus clad in nigh-impenetrable brass armor. Its gaze is stern yet benevolent, even upon you."
	clockwork_desc = "One of Ratvar's four generals. Nezbere is responsible for the design, testing, and creation of everything in Ratvar's domain."
	icon = 'icons/effects/340x428.dmi'
	icon_state = "nezbere"
	pixel_x = -154
	pixel_y = -192

/obj/effect/clockwork/general_marker/sevtug
	name = "Sevtug, the Formless Pariah"
	desc = "A sinister cloud of purple energy. Looking at it gives you a headache."
	clockwork_desc = "One of Ratvar's four generals. Sevtug taught him how to manipulate minds and is one of his oldest allies."
	icon = 'icons/effects/211x247.dmi'
	icon_state = "sevtug"
	pixel_x = -113
	pixel_y = -131

/obj/effect/clockwork/general_marker/nzcrentr
	name = "Nzcrentr, the Forgotten Arbiter"
	desc = "A terrifying war machine crackling with limitless energy."
	clockwork_desc = "One of Ratvar's four generals. Nzcrentr is the result of Neovgre - Nezbere's finest war machine, commandeerable only be a mortal - fusing with its pilot and driving her \
	insane. Nzcrentr seeks out any and all sentient life to slaughter it for sport."
	icon = 'icons/effects/254x361.dmi'
	icon_state = "nzcrentr"
	pixel_x = -110
	pixel_y = -163

/obj/effect/clockwork/general_marker/inathneq
	name = "Inath-Neq, the Resonant Cogwheel"
	desc = "A humanoid form blazing with blue fire. It radiates an aura of kindness and caring."
	clockwork_desc = "One of Ratvar's four generals. Before her current form, Inath-Neq was a powerful warrior priestess commanding the Resonant Cogs, a sect of Ratvarian warriors renowned for \
	their prowess. After a lost battle with Nar-Sian cultists, Inath-Neq was struck down and stated in her dying breath, \
	\"The Resonant Cogs shall not fall silent this day, but will come together to form a wheel that shall never stop turning.\" Ratvar, touched by this, granted Inath-Neq an eternal body and \
	merged her soul with those of the Cogs slain with her on the battlefield."
	icon = 'icons/effects/187x381.dmi'
	icon_state = "inath-neq"
	pixel_x = -91
	pixel_y = -199

/obj/effect/clockwork/sigil //Sigils: Rune-like markings on the ground with various effects.
	name = "sigil"
	desc = "A strange set of markings drawn on the ground."
	clockwork_desc = "A sigil of some purpose."
	icon_state = "sigil"
	alpha = 25
	var/affects_servants = FALSE

/obj/effect/clockwork/sigil/attack_hand(mob/user)
	if(iscarbon(user) && !user.stat && user.a_intent == "harm")
		user.visible_message("<span class='warning'>[user] stamps out [src]!</span>", "<span class='danger'>You stomp on [src], scattering it into thousands of particles.</span>")
		qdel(src)
		return 1
	..()

/obj/effect/clockwork/sigil/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(!L.stat)
			if(!is_servant_of_ratvar(L) || (is_servant_of_ratvar(L) && affects_servants))
				sigil_effects(L)
			return 1
	..()

/obj/effect/clockwork/sigil/proc/sigil_effects(mob/living/L)

/obj/effect/clockwork/sigil/transgression //Sigil of Transgression: Stuns and flashes the first non-servant to walk on it. Nar-Sian cultists are damaged and knocked down.
	name = "dull sigil"
	desc = "A dull, barely-visible golden sigil. It's as though light was carved into the ground."
	icon = 'icons/effects/clockwork_effects.dmi'
	clockwork_desc = "A sigil that will stun the first non-servant to cross it. Nar-Sie's dogs will be knocked down."
	color = rgb(255, 255, 0)

/obj/effect/clockwork/sigil/transgression/sigil_effects(mob/living/L)
	visible_message("<span class='warning'>[src] appears in a burst of light!</span>")
	for(var/mob/living/M in viewers(5, src))
		if(!is_servant_of_ratvar(M))
			M.flash_eyes()
	if(!iscultist(L))
		L << "<span class='userdanger'>An unseen force holds you in place!</span>"
	else
		L << "<span class='heavy_brass'>\"Watch your step, wretch.\"</span>"
		L.adjustBruteLoss(10)
		L.Weaken(5)
	L.Stun(5)
	qdel(src)
	return 1

/obj/effect/clockwork/sigil/submission //Sigil of Submission: After a short time, converts any non-servant standing on it. Knocks down and silences them for five seconds afterwards.
	name = "ominous sigil"
	desc = "A brilliant golden sigil. Something about it really bothers you."
	clockwork_desc = "A sigil that will enslave the first person to cross it, provided they do not move and they stand still for a brief time."
	color = rgb(255, 255, 0)
	alpha = 75

/obj/effect/clockwork/sigil/submission/sigil_effects(mob/living/L)
	visible_message("<span class='warning'>[src] begins to glow a piercing magenta!</span>")
	animate(src, color = rgb(255, 0, 150), time = 30)
	sleep(30)
	if(get_turf(L) != get_turf(src))
		animate(src, color = initial(color), time = 30)
		return 0
	L << "<span class='heavy_brass'>\"You belong to me now.\"</span>"
	add_servant_of_ratvar(L)
	L.Weaken(5) //Completely defenseless for a few seconds - mainly to give them time to read over the information they've just been presented with
	L.Stun(5)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.silent += 5
	for(var/mob/living/M in living_mob_list - L)
		if(is_servant_of_ratvar(M) || isobserver(M))
			M << "<span class='heavy_brass'>Sigil of Submission in [get_area(src)] [is_servant_of_ratvar(L) ? "" : "un"]successfully converted [L.real_name]!</span>"
	qdel(src)
	return 1

/obj/effect/clockwork/sigil/transmission
	name = "suspicious sigil"
	desc = "A barely-visible sigil. Things seem a bit quieter around it."
	clockwork_desc = "A sigil that will listen for and transmit anything it hears."
	color = rgb(75, 75, 75)
	alpha = 50
	flags = HEAR
	languages = ALL

/obj/effect/clockwork/sigil/transmission/sigil_effects(mob/living/L)
	for(var/mob/M in mob_list)
		if(is_servant_of_ratvar(M) || isobserver(M))
			M << "<span class='heavy_brass'>Sigil of Transmission in [get_area(src)] crossed by [L.name].</span>"
	return 0

/obj/effect/clockwork/sigil/transmission/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(!message || !speaker)
		return 0
	var/parsed_message = "<span class='heavy_brass'>(Sigil of Tranmission in [get_area(src)]): </span><span class='brass'>[message]</span>"
	for(var/mob/M in mob_list)
		if(is_servant_of_ratvar(M) || isobserver(M))
			M << parsed_message
