/obj/item/clockwork/slab //Clockwork slab: The most important tool in Ratvar's arsenal. Allows scripture recital, tutorials, and generates components.
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	clockwork_desc = "A link between the Celestial Derelict and the mortal plane. Contains limitless knowledge, fabricates components, and outputs a stream of information that only a trained eye can detect."
	icon_state = "dread_ipad"
	slot_flags = SLOT_BELT
	w_class = 2
	var/list/stored_components = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 0, "hierophant_ansible" = 0)
	var/busy //If the slab is currently being used by something
	var/production_time = 0
	var/no_cost = FALSE //If the slab is admin-only and needs no components and has no scripture locks
	var/nonhuman_usable = FALSE //if the slab can be used by nonhumans, defaults to off
	var/produces_components = TRUE //if it produces components at all
	actions_types = list(/datum/action/item_action/clock/hierophant, /datum/action/item_action/clock/guvax, /datum/action/item_action/clock/vanguard)

/obj/item/clockwork/slab/starter
	stored_components = list("belligerent_eye" = 1, "vanguard_cogwheel" = 1, "guvax_capacitor" = 1, "replicant_alloy" = 1, "hierophant_ansible" = 1)

/obj/item/clockwork/slab/internal //an internal motor for mobs running scripture
	name = "scripture motor"
	no_cost = TRUE
	produces_components = FALSE

/obj/item/clockwork/slab/scarab
	nonhuman_usable = TRUE

/obj/item/clockwork/slab/debug
	no_cost = TRUE
	nonhuman_usable = TRUE

/obj/item/clockwork/slab/debug/attack_hand(mob/living/user)
	..()
	if(!is_servant_of_ratvar(user))
		add_servant_of_ratvar(user)

/obj/item/clockwork/slab/New()
	..()
	START_PROCESSING(SSobj, src)
	production_time = world.time + SLAB_PRODUCTION_TIME

/obj/item/clockwork/slab/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

//Component Generation
/obj/item/clockwork/slab/process()
	if(!produces_components)
		STOP_PROCESSING(SSobj, src)
		return
	if(production_time > world.time)
		return
	var/servants = 0
	var/production_slowdown = 0
	for(var/mob/living/M in living_mob_list)
		if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
			servants++
	if(servants > 5)
		servants -= 5
		production_slowdown = min(SLAB_SERVANT_SLOWDOWN * servants, SLAB_SLOWDOWN_MAXIMUM) //SLAB_SERVANT_SLOWDOWN additional seconds for each servant above 5, up to SLAB_SLOWDOWN_MAXIMUM
	production_time = world.time + SLAB_PRODUCTION_TIME + production_slowdown
	var/mob/living/L
	if(isliving(loc))
		L = loc
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/W = loc
		if(isliving(W.loc)) //Only goes one level down - otherwise it won't produce components
			L = W.loc
	if(L)
		var/component_to_generate = get_weighted_component_id(src) //more likely to generate components that we have less of
		stored_components[component_to_generate]++
		for(var/obj/item/clockwork/slab/S in L.GetAllContents()) //prevent slab abuse today
			if(L == src)
				continue
			S.production_time = world.time + SLAB_PRODUCTION_TIME
		L << "<span class='warning'>Your slab clunks as it produces a new component.</span>"

/obj/item/clockwork/slab/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "Use the <span class='brass'>Hierophant Network</span> action button to communicate with other servants."
		user << "Clockwork slabs will only generate components if held by a human or if inside a storage item held by a human, and when generating a component will prevent all other slabs held from generating components.<br>"
		user << "Attacking a slab, a fellow Servant with a slab, or a cache with this slab will transfer this slab's components into that slab's components, their slab's components, or the global cache, respectively."
		if(clockwork_caches)
			user << "<b>Stored components (with global cache):</b>"
			for(var/i in stored_components)
				user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != "replicant_alloy" ? "s":""]:</i> <b>[stored_components[i]]</b> \
				(<b>[stored_components[i] + clockwork_component_cache[i]]</b>)</span>"
		else
			user << "<b>Stored components:</b>"
			for(var/i in stored_components)
				user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != "replicant_alloy" ? "s":""]:</i> <b>[stored_components[i]]</b></span>"

//Component Transferal
/obj/item/clockwork/slab/attack(mob/living/target, mob/living/carbon/human/user)
	if(is_servant_of_ratvar(user) && is_servant_of_ratvar(target))
		var/obj/item/clockwork/slab/targetslab
		var/highest_component_amount = 0
		for(var/obj/item/clockwork/slab/S in target.GetAllContents())
			if(!istype(S, /obj/item/clockwork/slab/internal))
				var/totalcomponents = 0
				for(var/i in S.stored_components)
					totalcomponents += S.stored_components[i]
				if(!targetslab || totalcomponents > highest_component_amount)
					highest_component_amount = totalcomponents
					targetslab = S
		if(targetslab)
			if(targetslab == src)
				user << "<span class='heavy_brass'>\"You can't transfer components into your own slab, idiot.\"</span>"
			else
				for(var/i in stored_components)
					targetslab.stored_components[i] += stored_components[i]
					stored_components[i] = 0
				user.visible_message("<span class='notice'>[user] empties [src] into [target]'s [targetslab.name].</span>", \
				"<span class='notice'>You transfer your slab's components into [target]'s [targetslab.name].</span>")
		else
			user << "<span class='warning'>[target] has no slabs to transfer components to.</span>"
	else
		return ..()

/obj/item/clockwork/slab/attackby(obj/item/I, mob/user, params)
	var/ratvarian = is_servant_of_ratvar(user)
	if(istype(I, /obj/item/clockwork/component) && ratvarian)
		var/obj/item/clockwork/component/C = I
		if(!C.component_id)
			return 0
		user.visible_message("<span class='notice'>[user] inserts [C] into [src].</span>", "<span class='notice'>You insert [C] into [src], where it is added to the global cache.</span>")
		clockwork_component_cache[C.component_id]++
		user.drop_item()
		qdel(C)
		return 1
	else if(istype(I, /obj/item/clockwork/slab) && ratvarian)
		var/obj/item/clockwork/slab/S = I
		for(var/i in stored_components)
			stored_components[i] += S.stored_components[i]
			S.stored_components[i] = 0
		user.visible_message("<span class='notice'>[user] empties [src] into [S].</span>", "<span class='notice'>You transfer your slab's components into [S].</span>")
	else
		return ..()

//Slab actions; Hierophant, Guvax, Vanguard
/obj/item/clockwork/slab/ui_action_click(mob/user, actiontype)
	switch(actiontype)
		if(/datum/action/item_action/clock/hierophant)
			show_hierophant(user)
		if(/datum/action/item_action/clock/guvax)
			if(!nonhuman_usable && !ishuman(user))
				return
			if(src == user.get_active_held_item())
				var/datum/clockwork_scripture/guvax/convert = new
				convert.slab = src
				convert.invoker = user
				convert.run_scripture()
			else
				user << "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>"
		if(/datum/action/item_action/clock/vanguard)
			if(!nonhuman_usable && !ishuman(user))
				return
			if(src == user.get_active_held_item())
				var/datum/clockwork_scripture/vanguard/antistun = new
				antistun.slab = src
				antistun.invoker = user
				antistun.run_scripture()
			else
				user << "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>"

/obj/item/clockwork/slab/proc/show_hierophant(mob/living/user)
	var/message = stripped_input(user, "Enter a message to send to your fellow servants.", "Hierophant")
	if(!message || !user || !user.canUseTopic(src))
		return 0
	clockwork_say(user, text2ratvar("Servants, hear my words. [html_decode(message)]"), TRUE)
	titled_hierophant_message(user, message)
	return 1

//Scripture Recital
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
		user.confused += 5
		user.dizziness += 5
		return 0
	if(busy)
		user << "<span class='warning'>[src] refuses to work, displaying the message: \"[busy]!\"</span>"
		return 0
	if(!nonhuman_usable && !ishuman(user))
		user << "<span class='nezbere'>[src] hums fitfully in your hands, but doesn't seem to do anything...</span>"
		return 0
	access_display(user)

/obj/item/clockwork/slab/proc/access_display(mob/living/user)
	if(!is_servant_of_ratvar(user))
		return 0
	var/action = alert(user, "[text2ratvar(pick("We endure!", "Hello, servant!", "Good tidings!"))] How can I help today?", "[src]", "Scripture", "Tutorial/Scrpt. List", "Cancel")
	if(!action || !user.canUseTopic(src))
		return 0
	switch(action)
		if("Scripture")
			if(user.get_active_held_item() != src)
				user << "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>"
				return
			recite_scripture(user)
		if("Tutorial/Scrpt. List")
			show_guide(user)
		if("Cancel")
			return
	return 1

/obj/item/clockwork/slab/proc/recite_scripture(mob/living/user)
	var/list/tiers_of_scripture = scripture_unlock_check()
	for(var/i in tiers_of_scripture)
		if(!tiers_of_scripture[i] && !ratvar_awakens && !no_cost)
			tiers_of_scripture["[i] \[LOCKED\]"] = TRUE
			tiers_of_scripture -= i
	var/scripture_tier = input(user, "Choose a category of scripture to recite.", "[src]") as null|anything in tiers_of_scripture
	if(!scripture_tier || !user.canUseTopic(src))
		return 0
	var/list/available_scriptures = list()
	var/datum/clockwork_scripture/scripture_to_recite
	switch(scripture_tier)
		if(SCRIPTURE_DRIVER,SCRIPTURE_SCRIPT,SCRIPTURE_APPLICATION,SCRIPTURE_REVENANT,SCRIPTURE_JUDGEMENT); //; for the empty if
		else
			user << "<span class='warning'>That section of scripture is still locked!</span>"
			return 0
	for(var/S in sortList(subtypesof(/datum/clockwork_scripture), /proc/cmp_clockscripture_priority))
		var/datum/clockwork_scripture/C = S
		if(initial(C.tier) == scripture_tier)
			available_scriptures["[initial(C.name)] ([initial(C.descname)])"] = C
	if(!available_scriptures.len)
		return 0
	var/chosen_scripture_key = input(user, "Choose a piece of scripture to recite.", "[src]") as null|anything in available_scriptures
	var/datum/clockwork_scripture/chosen_scripture = available_scriptures[chosen_scripture_key]
	if(!chosen_scripture || !user.canUseTopic(src) || user.get_active_held_item() != src)
		return 0
	tiers_of_scripture = scripture_unlock_check()
	if(!ratvar_awakens && !no_cost && !tiers_of_scripture[initial(chosen_scripture.tier)])
		user << "<span class='warning'>That scripture is no longer unlocked, and cannot be recited!</span>"
		return 0
	scripture_to_recite = new chosen_scripture
	scripture_to_recite.slab = src
	scripture_to_recite.invoker = user
	scripture_to_recite.run_scripture()
	return 1

//Guide to Serving Ratvar
/obj/item/clockwork/slab/proc/show_guide(mob/living/user)
	var/text = "If you're seeing this, file a bug report."
	if(ratvar_awakens)
		text = "<font color=#BE8700 size=3><b>"
		for(var/i in 1 to 100)
			text += "HONOR RATVAR "
		text += "</b></font>"
	else
		text = "<font color=#BE8700 size=3><b><center>Chetr nyy hagehguf-naq-ubabe Ratvar.</center></b></font><br><br>\
		(This is a long read. If you're confident that you can learn the basics yourself, feel free to skip to the scripture list at the bottom.)<br><br>\
		\
		Welcome, good slave, to the archives of Ratvar! If you're able to read this without losing your mind, then congratulations; you've either been converted or chosen by Ratvar to serve his \
		cause. Ratvar - you and I's master - wishes is, so it will be done. The Clockwork Justiciar wants Nar-Sie to rot for a thousand years like he did, so we're going to be furthering that \
		goal together. I'm to help you in any way I can. You can call me Ze-Fyno, but that's not important.<br><br>\
		\
		I can already hear you thinking out loud with that meaty processor in your head. \"But, disembodied slab conscience,\" you think to yourself, \"how am I supposed to summon Ratvar with \
		these fleshy human hands that are inferior to your glorious brass gears?\" Fear not, my student! Judging by the fact that you're currently reading what I have to say, you've already \
		discovered your most important tool: the <b>clockwork slab</b>. That's me! Through me, you can access <b>scripture</b>, which we'll cover later. If you examine me, I can tell you some \
		useful stuff, but there's an easier way, too.<br><br>\
		\
		Take a look at your interface. We'll start with the top right. Here is where I'll tell you anything important that you need to know. If you focus on the image of the tower-looking thingy, \
		I can tell you how many components you have, how many servants there are total, and which generals we can invoke. That probably all sounds like gibberish to you, but don't worry about it \
		for now. I'll also let you know if there's anything severe, like no tinkerer's caches.<br><br>\
		\
		If you look at the top left, you can see a few quick functionalities I offer. This is what they do, from left to right...<br>\
		<b><font color=#DAAA18>Hierophant Network</font></b> lets you talk from any distance to every other servant. You still have to talk into the slab, so be careful you aren't observed!<br>\
		<b><font color=#AF0AAF>Guvax</font></b> lets you recite the Guvax scripture, which is our best way to convert people.<br>\
		<b><font color=#1E8CE1>Vanguard</font></b> lets you recite the Vanguard scripture, which makes you immune to stuns for a while but has some drawbacks.<br><br>\
		\
		Well, I think I've kept you in the dark for long enough. Let's talk about <b>scripture</b>. You know how Nar-Sie has runes? We don't use those; instead we use scripture, which serves the \
		same function of letting you do stuff you otherwise couldn't. Unlike runes, all the scripture you need is contained right here in me, so you don't have to draw runes where they can be \
		found. Great, right? Anyways, they ain't cheap. To use scripture, you need <b>components</b>. These are bits of Ratvar's body that have rusted away and fallen off during his banishment. \
		Kinda gross, right? Well, each component is about as powerful as a collapsing star, so don't underestimate them! There are five types: belligerent eyes, vanguard cogwheels, guvax \
		capacitors, replicant alloy, and hierophant ansibles. Scripture needs different types of components to function, and usually consumes at least a few of those. In general, eyes are \
		offensive, cogs are defensive, capacitors are for intelligence or mind control, alloys are for making stuff, and ansibles are for transmitting stuff. Simple enough, but important!<br><br>\
		\
		Oh, another thing to note: scripture is divided into five <b>tiers</b>. Y'see, as Ratvar's presence grows on this deathtrap you call a station, all of his servants grow more resistant to \
		the power of the scriptures. Although technically I could let you make the Ark right now, your head would probably explode from the mental strain, and I think you like having one. For \
		your sake, we keep them tiered up, with scripture becoming steadily more powerful depending on tier. You only have the Driver tier unlocked by default, and it has stuff that's basic but \
		important. As we grow more powerful, you unlock further tiers. I'll detail the requirements down below.<br><br>\
		\
		Anyway, that's about all you need to kn- actually, wait. Something you should know. Unlike Nar-Sie's cult, which focuses on sabotage and doesn't really stay anywhere for long, we're much \
		more static. That means that, instead of staying on the move, we make fortified strongholds and set up our operations there. Nezbere, Ratvar's engineer, has designed a lot of structures, \
		so we need somewhere to put them. The most important of these is the <b>tinkerer's cache</b>, which lets you store components for later use. You can offload my (the slab) components into \
		one by hitting it with me. Caches are so good because <i>everyone</i> can draw from the components inside, all caches are linked, and the components can be used to power scripture! It's \
		a wonderful thing, teamwork. Anyway, the cache and other structures have something called <b>CV</b> - that stands for Construction Value. When you see CV mentioned in a tier unlock, we \
		need that much <i>combined</i> CV to unlock it.<br><br>\
		\
		Ol gur Nex, listen to me ramble. You probably just want to know the scripture, so let me tell you. I can't teach you any more, but feel free to ask your fellow servants for help. Anyway, \
		here's your scripture...<br>\
		Key:<br><font color=#6E001A>BE</font> = Belligerent Eyes<br>\
		<font color=#1E8CE1>VC</font> = Vanguard Cogwheels<br>\
		<font color=#AF0AAF>GC</font> = Guvax Capacitors<br>\
		<font color=#5A6068>RA</font> = Replicant Alloy<br>\
		<font color=#DAAA18>HA</font> = Hierophant Ansibles<br>"
		var/text_to_add = ""
		var/drivers = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_DRIVER]</b></font><br><i>These scriptures are always unlocked.</i><br>"
		var/scripts = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_SCRIPT]</b></font><br><i>These scriptures require at least five servants and a tinkerer's cache.</i><br>"
		var/applications = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_APPLICATION]</b></font><br><i>These scriptures require at least eight servants, three tinkerer's caches, and 100CV.</i><br>"
		var/revenant = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_REVENANT]</b></font><br><i>These scriptures require at least ten servants and 200CV.</i><br>"
		var/judgement = "<br><font color=#BE8700 size=3><b>[SCRIPTURE_JUDGEMENT]</b></font><br><i>These scriptures require at least twelve servants and 300CV. In addition, there may not be any active non-servant AIs.</i><br>"
		for(var/V in sortList(subtypesof(/datum/clockwork_scripture), /proc/cmp_clockscripture_priority))
			var/datum/clockwork_scripture/S = V
			if(initial(S.tier) != SCRIPTURE_PERIPHERAL)
				var/datum/clockwork_scripture/S2 = new V
				var/list/req_comps = S2.required_components
				var/list/cons_comps = S2.consumed_components
				qdel(S2)
				var/scripture_text = "<br><b><font color=#BE8700>[initial(S.name)]</font>:</b><br>[initial(S.desc)]<br><b>Invocation Time:</b> <b>[initial(S.channel_time) / 10]</b> seconds<br>\
				<b>Component Requirement: </b>\
				[req_comps["belligerent_eye"] ?  "<font color=#6E001A><b>[req_comps["belligerent_eye"]]</b> BE</font>" : ""] \
				[req_comps["vanguard_cogwheel"] ? "<font color=#1E8CE1><b>[req_comps["vanguard_cogwheel"]]</b> VC</font>" : ""] \
				[req_comps["guvax_capacitor"] ? "<font color=#AF0AAF><b>[req_comps["guvax_capacitor"]]</b> GC</font>" : ""] \
				[req_comps["replicant_alloy"] ? "<font color=#5A6068><b>[req_comps["replicant_alloy"]]</b> RA</font>" : ""] \
				[req_comps["hierophant_ansible"] ? "<font color=#DAAA18><b>[req_comps["hierophant_ansible"]]</b> HA</font>" : ""]<br>"
				for(var/i in cons_comps)
					if(cons_comps[i])
						scripture_text += "<b>Component Cost: </b>\
						[cons_comps["belligerent_eye"] ?  "<font color=#6E001A><b>[cons_comps["belligerent_eye"]]</b> BE</font>" : ""] \
						[cons_comps["vanguard_cogwheel"] ? "<font color=#1E8CE1><b>[cons_comps["vanguard_cogwheel"]]</b> VC</font>" : ""] \
						[cons_comps["guvax_capacitor"] ? "<font color=#AF0AAF><b>[cons_comps["guvax_capacitor"]]</b> GC</font>" : ""] \
						[cons_comps["replicant_alloy"] ? "<font color=#5A6068><b>[cons_comps["replicant_alloy"]]</b> RA</font>" : ""] \
						[cons_comps["hierophant_ansible"] ? "<font color=#DAAA18><b>[cons_comps["hierophant_ansible"]]</b> HA</font>" : ""]<br>"
						break //we want this to only show up if the scripture has a cost of some sort
				scripture_text += "<b>Tip:</b> [initial(S.usage_tip)]<br>"
				switch(initial(S.tier))
					if(SCRIPTURE_DRIVER)
						drivers += scripture_text
					if(SCRIPTURE_SCRIPT)
						scripts += scripture_text
					if(SCRIPTURE_APPLICATION)
						applications += scripture_text
					if(SCRIPTURE_REVENANT)
						revenant += scripture_text
					if(SCRIPTURE_JUDGEMENT)
						judgement += scripture_text
		text_to_add += "[drivers]<br>[scripts]<br>[applications]<br>[revenant]<br>[judgement]<br>"
		text_to_add += "<font color=#BE8700 size=3><b><center>Purge all untruths and honor Ratvar.</center></b></font>"
		text += text_to_add
	var/datum/browser/popup = new(user, "slab", "", 600, 500)
	popup.set_content(text)
	popup.open()
	return 1
