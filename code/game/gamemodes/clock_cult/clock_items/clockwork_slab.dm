/obj/item/clockwork/slab //Clockwork slab: The most important tool in Ratvar's arsenal. Allows scripture recital, tutorials, and generates components.
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	clockwork_desc = "A link between the Celestial Derelict and the mortal plane. Contains limitless knowledge, fabricates components, and outputs a stream of information that only a trained eye can detect.\n\
	Use the <span class='brass'>Hierophant Network</span> action button to communicate with other servants.\n\
	Clockwork slabs will only make components if held or if inside an item held by a human, and when making a component will prevent all other slabs held from making components.\n\
	Hitting a slab, a Servant with a slab, or a cache will <b>transfer</b> this slab's components into the target, the target's slab, or the global cache, respectively."
	icon_state = "dread_ipad"
	slot_flags = SLOT_BELT
	w_class = 2
	var/list/stored_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0)
	var/busy //If the slab is currently being used by something
	var/production_time = 0
	var/no_cost = FALSE //If the slab is admin-only and needs no components and has no scripture locks
	var/speed_multiplier = 1 //multiples how fast this slab recites scripture
	var/nonhuman_usable = FALSE //if the slab can be used by nonhumans, defaults to off
	var/produces_components = TRUE //if it produces components at all
	var/list/shown_scripture = list(SCRIPTURE_DRIVER = TRUE, SCRIPTURE_SCRIPT = FALSE, SCRIPTURE_APPLICATION = FALSE, SCRIPTURE_REVENANT = FALSE, SCRIPTURE_JUDGEMENT = FALSE)
	var/compact_scripture = TRUE
	var/obj/effect/proc_holder/slab/slab_ability //the slab's current bound ability, for certain scripture
	var/list/quickbound = list(/datum/clockwork_scripture/ranged_ability/geis_prep) //quickbound scripture, accessed by index
	actions_types = list(/datum/action/item_action/clock/hierophant)

/obj/item/clockwork/slab/starter
	stored_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 1)

/obj/item/clockwork/slab/internal //an internal motor for mobs running scripture
	name = "scripture motor"
	quickbound = list()
	no_cost = TRUE
	produces_components = FALSE

/obj/item/clockwork/slab/scarab
	nonhuman_usable = TRUE

/obj/item/clockwork/slab/debug
	speed_multiplier = 0
	no_cost = TRUE
	nonhuman_usable = TRUE

/obj/item/clockwork/slab/debug/attack_hand(mob/living/user)
	..()
	if(!is_servant_of_ratvar(user))
		add_servant_of_ratvar(user)

/obj/item/clockwork/slab/cyborg
	clockwork_desc = "A divine link to the Celestial Derelict, allowing for limited recital of scripture.\n\
	Hitting a slab, a Servant with a slab, or a cache will <b>transfer</b> this slab's components into the target, the target's slab, or the global cache, respectively."
	nonhuman_usable = TRUE
	quickbound = list(/datum/clockwork_scripture/ranged_ability/judicial_marker, /datum/clockwork_scripture/ranged_ability/sentinels_compromise, \
	/datum/clockwork_scripture/create_object/sigil_of_transgression, /datum/clockwork_scripture/create_object/vitality_matrix)
	actions_types = list()

/obj/item/clockwork/slab/cyborg/engineer
	quickbound = list(/datum/clockwork_scripture/create_object/tinkerers_cache, /datum/clockwork_scripture/create_object/ocular_warden, /datum/clockwork_scripture/create_object/tinkerers_daemon)

/obj/item/clockwork/slab/cyborg/medical
	quickbound = list(/datum/clockwork_scripture/ranged_ability/linked_vanguard, /datum/clockwork_scripture/ranged_ability/sentinels_compromise, /datum/clockwork_scripture/fellowship_armory, \
	/datum/clockwork_scripture/create_object/mending_motor)

/obj/item/clockwork/slab/cyborg/security
	quickbound = list(/datum/clockwork_scripture/channeled/belligerent, /datum/clockwork_scripture/ranged_ability/judicial_marker, /datum/clockwork_scripture/create_object/ocular_warden)

/obj/item/clockwork/slab/cyborg/peacekeeper
	quickbound = list(/datum/clockwork_scripture/channeled/belligerent, /datum/clockwork_scripture/ranged_ability/judicial_marker, /datum/clockwork_scripture/channeled/taunting_tirade, \
	/datum/clockwork_scripture/create_object/mania_motor)

/obj/item/clockwork/slab/cyborg/janitor
	quickbound = list(/datum/clockwork_scripture/channeled/belligerent, /datum/clockwork_scripture/channeled/volt_void, /datum/clockwork_scripture/create_object/sigil_of_transmission, \
	/datum/clockwork_scripture/create_object/interdiction_lens)

/obj/item/clockwork/slab/cyborg/service
	quickbound = list(/datum/clockwork_scripture/replicant, /datum/clockwork_scripture/fellowship_armory, /datum/clockwork_scripture/spatial_gateway, \
	/datum/clockwork_scripture/create_object/clockwork_obelisk)

/obj/item/clockwork/slab/cyborg/miner
	quickbound = list(/datum/clockwork_scripture/ranged_ability/judicial_marker, /datum/clockwork_scripture/ranged_ability/linked_vanguard, /datum/clockwork_scripture/spatial_gateway)

/obj/item/clockwork/slab/cyborg/access_display(mob/living/user)
	user << "<span class='warning'>Use the action buttons to recite your limited set of scripture!</span>"

/obj/item/clockwork/slab/New()
	..()
	update_quickbind()
	START_PROCESSING(SSobj, src)
	production_time = world.time + SLAB_PRODUCTION_TIME

/obj/item/clockwork/slab/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(slab_ability && slab_ability.ranged_ability_user)
		slab_ability.remove_ranged_ability()
	return ..()

/obj/item/clockwork/slab/dropped(mob/user)
	. = ..()
	addtimer(src, "check_on_mob", 1, FALSE, user) //dropped is called before the item is out of the slot, so we need to check slightly later

/obj/item/clockwork/slab/proc/check_on_mob(mob/user)
	if(user && !(src in user.held_items) && slab_ability && slab_ability.ranged_ability_user) //if we happen to check and we AREN'T in user's hands, remove whatever ability we have
		slab_ability.remove_ranged_ability()

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
	if(servants > SCRIPT_SERVANT_REQ)
		servants -= SCRIPT_SERVANT_REQ
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
		if(LAZYLEN(quickbound))
			for(var/i in 1 to quickbound.len)
				if(!quickbound[i])
					continue
				var/datum/clockwork_scripture/quickbind_slot = quickbound[i]
				user << "<b>Quickbind</b> button: <span class='[get_component_span(initial(quickbind_slot.primary_component))]'>[initial(quickbind_slot.name)]</span>."
		if(clockwork_caches)
			user << "<b>Stored components (with global cache):</b>"
			for(var/i in stored_components)
				user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[stored_components[i]]</b> \
				(<b>[stored_components[i] + clockwork_component_cache[i]]</b>)</span>"
		else
			user << "<b>Stored components:</b>"
			for(var/i in stored_components)
				user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[stored_components[i]]</b></span>"

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

//Slab actions; Hierophant, Quickbind
/obj/item/clockwork/slab/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/clock/hierophant))
		show_hierophant(user)
	else if(istype(action, /datum/action/item_action/clock/quickbind))
		var/datum/action/item_action/clock/quickbind/Q = action
		recite_scripture(quickbound[Q.scripture_index], user, FALSE)

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
	var/action = alert(user, "Among the swathes of information, you see...", "[src]", "Recital", "Recollection", "Cancel")
	if(!action || !user.canUseTopic(src))
		return 0
	switch(action)
		if("Recital")
			interact(user)
		if("Recollection")
			recollection(user)
		if("Cancel")
			return
	return 1

/obj/item/clockwork/slab/proc/recite_scripture(datum/clockwork_scripture/scripture, mob/living/user)
	if(!scripture || !user || !user.canUseTopic(src) || (!nonhuman_usable && !ishuman(user)))
		return FALSE
	if(user.get_active_held_item() != src)
		user << "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>"
		return FALSE
	var/initial_tier = initial(scripture.tier)
	if(initial_tier != SCRIPTURE_PERIPHERAL)
		var/list/tiers_of_scripture = scripture_unlock_check()
		if(!ratvar_awakens && !no_cost && !tiers_of_scripture[initial_tier])
			user << "<span class='warning'>That scripture is not unlocked, and cannot be recited!</span>"
			return FALSE
	var/datum/clockwork_scripture/scripture_to_recite = new scripture
	scripture_to_recite.slab = src
	scripture_to_recite.invoker = user
	scripture_to_recite.run_scripture()
	return TRUE

/obj/item/clockwork/slab/interact(mob/living/user)
	var/text = "<center>A complete list of scripture can be found and <font color=#BE8700><b>Quickbound</b></font> below.<br><br>\
	\
	<font size=1>Key:"
	for(var/i in clockwork_component_cache)
		text += " <b><font color=[get_component_color_brightalloy(i)]>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]</font></b>"
	text += "</font><br><br><center><A href='?src=\ref[src];compactscripture=1'>[compact_scripture ? "Dec":"C"]ompress Scripture Information</A></center>"
	var/text_to_add = ""
	var/drivers = "<br><b><A href='?src=\ref[src];Driver=1'>[SCRIPTURE_DRIVER]</A></b><br><font size=1><i>These scriptures are always unlocked.</i>"
	var/scripts = "<br><br><b><A href='?src=\ref[src];Script=1'>[SCRIPTURE_SCRIPT]</A></b><br><font size=1><i>These scriptures require at least <b>[SCRIPT_SERVANT_REQ]</b> Servants and \
	<b>[SCRIPT_CACHE_REQ]</b> Tinkerer's Cache.</i>"
	var/applications = "<br><br><b><A href='?src=\ref[src];Application=1'>[SCRIPTURE_APPLICATION]</A></b><br><font size=1><i>These scriptures require at least <b>[APPLICATION_SERVANT_REQ]</b> Servants, \
	<b>[APPLICATION_CACHE_REQ]</b> Tinkerer's Caches, and <b>[APPLICATION_CV_REQ]CV</b>.</i>"
	var/revenant = "<br><br><b><A href='?src=\ref[src];Revenant=1'>[SCRIPTURE_REVENANT]</A></b><br><font size=1><i>These scriptures require at least <b>[REVENANT_SERVANT_REQ]</b> Servants, \
	<b>[REVENANT_CACHE_REQ]</b> Tinkerer's Caches, and <b>[REVENANT_CV_REQ]CV</b>.</i>"
	var/judgement = "<br><br><b><A href='?src=\ref[src];Judgement=1'>[SCRIPTURE_JUDGEMENT]</A></b><br><font size=1><i>This scripture requires at least <b>[JUDGEMENT_SERVANT_REQ]</b> Servants, \
	<b>[JUDGEMENT_CACHE_REQ]</b> Tinkerer's Caches, and <b>[JUDGEMENT_CV_REQ]CV</b>.<br>In addition, there may not be any active non-Servant AIs.</i><br>"
	for(var/V in sortList(subtypesof(/datum/clockwork_scripture), /proc/cmp_clockscripture_priority))
		var/datum/clockwork_scripture/S = V
		var/initial_tier = initial(S.tier)
		if(initial_tier != SCRIPTURE_PERIPHERAL && shown_scripture[initial_tier])
			var/datum/clockwork_scripture/S2 = new V
			var/list/req_comps = S2.required_components
			var/list/cons_comps = S2.consumed_components
			qdel(S2)
			var/scripture_text = "<br><b><font color=[get_component_color_brightalloy(initial(S.primary_component))]>[initial(S.name)] ([initial(S.descname)])</font>:</b>"
			if(!compact_scripture)
				scripture_text += "<br>[initial(S.desc)]<br><b>Invocation Time:</b> <b>[initial(S.channel_time) / 10]</b> second\s\
				[initial(S.invokers_required) > 1 ? "<br><b>Invokers Required:</b> <b>[initial(S.invokers_required)]</b>":""]\
				<br><b>Component Requirement:</b>"
			for(var/i in req_comps)
				if(req_comps[i]) //if we're compact, this shows up to the right of the name
					scripture_text += " <font color=[get_component_color_brightalloy(i)]><b>[req_comps[i]]</b> [get_component_acronym(i)]</font>"
			if(!compact_scripture)
				for(var/a in cons_comps)
					if(cons_comps[a])
						scripture_text += "<br><b>Component Cost:</b>"
						for(var/i in cons_comps)
							if(cons_comps[i])
								scripture_text += " <font color=[get_component_color_brightalloy(i)]><b>[cons_comps[i]]</b> [get_component_acronym(i)]</font>"
						break //we want this to only show up if the scripture has a cost of some sort
				scripture_text += "<br><b>Tip:</b> [initial(S.usage_tip)]"
			if(initial(S.quickbind))
				var/bound_index = quickbound.Find(S)
				scripture_text += "<br><font color=#BE8700 size=1>"
				if(bound_index)
					scripture_text += "<A href='?src=\ref[src];task=unbind;quickbind=[S]'>Unbind from <b>[bound_index]</b></A></font>"
				else
					for(var/i in 1 to 5)
						scripture_text += "<A href='?src=\ref[src];task=[i];quickbind=[S]'>Quickbind to <b>[i]</b></A>"
						if(i != 5)
							scripture_text += "| "
						else
							scripture_text += "</font>"
			scripture_text += "<br><b><A href='?src=\ref[src];Recite=[S]'>Recite</A></b>"
			switch(initial_tier)
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
	text_to_add += "[drivers]</font>[scripts]</font>[applications]</font>[revenant]</font>[judgement]</font>"
	text += text_to_add
	text += "<br><br><br><br><font color=#BE8700 size=3><b><center>Purge all untruths and honor Ratvar.</center></b></font>"
	var/datum/browser/popup = new(user, "recital", "", 600, 500)
	popup.set_content(text)
	popup.open()
	return 1

//Guide to Serving Ratvar
/obj/item/clockwork/slab/proc/recollection(mob/living/user)
	var/text = "If you're seeing this, file a bug report."
	if(ratvar_awakens)
		text = "<font color=#BE8700 size=3><b>"
		for(var/i in 1 to 100)
			text += "HONOR RATVAR "
		text += "</b></font>"
	else
		var/servants = 0
		var/production_time = SLAB_PRODUCTION_TIME
		for(var/mob/living/M in living_mob_list)
			if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
				servants++
		if(servants > 5)
			servants -= 5
			production_time += min(SLAB_SERVANT_SLOWDOWN * servants, SLAB_SLOWDOWN_MAXIMUM)
		var/production_text_addon = ""
		if(production_time != SLAB_PRODUCTION_TIME+SLAB_SLOWDOWN_MAXIMUM)
			production_text_addon = ", which increases for each human or silicon servant above <b>[SCRIPT_SERVANT_REQ]</b>"
		production_time = production_time/600
		var/production_text = "<b>[round(production_time)] minute\s"
		if(production_time != round(production_time))
			production_time -= round(production_time)
			production_time *= 60
			production_text += " and [round(production_time, 1)] second\s"
		production_text += "</b>"
		production_text += production_text_addon

		text = "<font color=#BE8700 size=3><b><center>Chetr nyy hagehguf-naq-ubabe Ratvar.</center></b></font><br>\
		\
		First and foremost, you serve Ratvar, the Clockwork Justicar, in any ways he sees fit. This is with no regard to your personal well-being, and you would do well to think of the larger \
		scale of things than your life. Ratvar wishes retribution upon those that trapped him in Reebe - the Nar-Sian cultists - and you are to help him obtain it.<br><br>\
		\
		Ratvar, being trapped in Reebe, the Celestial Derelict, cannot directly affect the mortal plane. However, links, such as this Clockwork Slab, can be created to draw \
		<b><font color=#BE8700>Components</font></b>, fragments of the Justicar, from Reebe, and those Components can be used to draw power and material from Reebe through arcane chants \
		known as <b><font color=#BE8700>Scripture</font></b>.<br><br>\
		\
		One component of a random type is made in this slab every [production_text].<br>\
		<font color=#BE8700>Components</font> are stored either within slabs, where they can only be accessed by that slab, or in the Global Cache accessed by Tinkerer's Caches, which all slabs \
		can draw from to recite scripture.<br>\
		There are five types of component, and in general, <font color=#6E001A>Belligerent Eyes</font> are aggressive and judgemental, <font color=#1E8CE1>Vanguard Cogwheels</font> are defensive and \
		repairing, <font color=#AF0AAF>Geis Capacitors</font> are for conversion and control, <font color=#5A6068>Replicant Alloy</font> is for construction and fuel, and \
		<font color=#DAAA18>Hierophant Ansibles</font> are for transmission and power, though in combination their effects become more nuanced.<br><br>\
		\
		There are also five tiers of <font color=#BE8700>Scripture</font>; <font color=#BE8700>[SCRIPTURE_DRIVER]</font>, <font color=#BE8700>[SCRIPTURE_SCRIPT]</font>, <font color=#BE8700>[SCRIPTURE_APPLICATION]</font>, <font color=#BE8700>[SCRIPTURE_REVENANT]</font>, and <font color=#BE8700>[SCRIPTURE_JUDGEMENT]</font>.<br>\
		Each tier has additional requirements, including Servants, Tinkerer's Caches, and <b>Construction Value</b>(<b>CV</b>). Construction Value is gained by creating structures or converting the \
		station, and everything too large to hold will grant some amount of it.<br><br>\
		\
		This would be a massive amount of information to try and keep track of, but all Servants have the <b><font color=#BE8700>Global Records</font></b> alert, which appears in the top right.<br>\
		Mousing over that alert will display Servants, Caches, CV, and other information, such as the tiers of scripture that are unlocked.<br><br>\
		\
		On that note, <font color=#BE8700>Scripture</font> is recited through <b><font color=#BE8700>Recital</font></b>, the first and most important function of the slab, \
		which also allows <b>Quickbinding</b> scripture.<br>\
		All scripture requires some amount of <font color=#BE8700>Components</font> to recite, and only the weakest scripture does not consume any components when recited.<br>\
		However, weak is relative when it comes to scripture; even the 'weakest' could be enough to dominate a station in the hands of cunning Servants, and higher tiers of scripture are even \
		stronger in the right hands.<br><br>\
		\
		Some effects of scripture include granting the invoker a temporary complete immunity to stuns, summoning a turret that can attack anything that sets eyes on it, binding a powerful guardian \
		to the invoker, or even, at one of the highest tiers, granting all nearby Servants temporary invulnerability.<br>\
		However, the most important scripture is <font color=#AF0AAF>Geis</font>, which allows you to convert heathens with relative ease.<br><br>\
		\
		The second function of the clockwork slab is <b><font color=#BE8700>Recollection</font></b>, which will display this guide.<br><br>\
		\
		The third to fifth functions are three buttons in the top left while holding the slab.<br>From left to right, they are:<br>\
		<b><font color=#DAAA18>Hierophant Network</font></b>, which allows communication to other Servants.<br>"
		if(LAZYLEN(quickbound))
			for(var/i in 1 to quickbound.len)
				if(!quickbound[i])
					continue
				var/datum/clockwork_scripture/quickbind_slot = quickbound[i]
				text += "A <b>Quickbind</b> slot, currently set to <b><font color=[get_component_color_brightalloy(initial(quickbind_slot.primary_component))]>[initial(quickbind_slot.name)]</font></b>.<br>"
		text += "<br>\
		Examine the slab to check the number of components it has available.<br><br>\
		\
		<font color=#BE8700 size=3><b><center>Purge all untruths and honor Ratvar.</center></b></font>"
	var/datum/browser/popup = new(user, "slab", "", 600, 500)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/clockwork/slab/Topic(href, href_list)
	. = ..()
	if(.)
		return .

	if(!usr || !src || !(src in usr) || usr.incapacitated())
		return 0

	if(href_list["Recite"])
		href_list["Recite"] = text2path(href_list["Recite"])
		addtimer(src, "recite_scripture", 0, FALSE, href_list["Recite"], usr, FALSE)
		return

	if(href_list["task"])
		if(href_list["task"] == "unbind")
			var/remove_path = text2path(href_list["quickbind"]) //we need a path and not a string
			var/found_index = quickbound.Find(remove_path)
			if(found_index)
				if(LAZYLEN(quickbound) == found_index) //if it's the last scripture, remove it instead of leaving a null
					quickbound -= remove_path
				else
					quickbound[found_index] = null //otherwise, leave it as a null so the scripture maintains position
				update_quickbind()
		else
			var/number = text2num(href_list["task"])
			if(isnum(number) && number > 0 && number < 6)
				quickbind_to_slot(text2path(href_list["quickbind"]), number) //same here

	if(href_list["compactscripture"])
		compact_scripture = !compact_scripture

	for(var/i in shown_scripture)
		if(href_list[i])
			shown_scripture[i] = !shown_scripture[i]

	interact(usr)

/obj/item/clockwork/slab/proc/quickbind_to_slot(datum/clockwork_scripture/scripture, index) //takes a typepath(typecast for initial()) and binds it to a slot
	if(!ispath(scripture) || !scripture || (scripture in quickbound))
		return
	while(LAZYLEN(quickbound) < index)
		quickbound += null
	quickbound[index] = scripture
	update_quickbind()

/obj/item/clockwork/slab/proc/update_quickbind()
	for(var/datum/action/item_action/clock/quickbind/Q in actions)
		qdel(Q)
	if(LAZYLEN(quickbound))
		for(var/i in 1 to quickbound.len)
			if(!quickbound[i])
				continue
			var/datum/action/item_action/clock/quickbind/Q = new /datum/action/item_action/clock/quickbind(src)
			Q.scripture_index = i
			var/datum/clockwork_scripture/quickbind_slot = quickbound[i]
			Q.name = "[initial(quickbind_slot.name)] ([Q.scripture_index])"
			Q.desc = initial(quickbind_slot.quickbind_desc)
			Q.button_icon_state = initial(quickbind_slot.name)
			Q.UpdateButtonIcon()
			if(isliving(loc))
				Q.Grant(loc)
