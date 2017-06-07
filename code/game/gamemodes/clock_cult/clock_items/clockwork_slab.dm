/obj/item/clockwork/slab //Clockwork slab: The most important tool in Ratvar's arsenal. Allows scripture recital, tutorials, and generates components.
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	clockwork_desc = "A link between the Celestial Derelict and the mortal plane. Contains limitless knowledge, fabricates components, and outputs a stream of information that only a trained eye can detect.\n\
	Use the <span class='brass'>Hierophant Network</span> action button to communicate with other servants.\n\
	Clockwork slabs will only make components if held or if inside an item held by a human, and when making a component will prevent all other slabs held from making components.\n\
	Hitting a slab, a Servant with a slab, or a cache will <b>transfer</b> this slab's components into the target, the target's slab, or the global cache, respectively."
	icon_state = "dread_ipad"
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	var/list/stored_components = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0)
	var/busy //If the slab is currently being used by something
	var/production_time = 0
	var/target_component_id //the target component ID to create, if any
	var/no_cost = FALSE //If the slab is admin-only and needs no components and has no scripture locks
	var/speed_multiplier = 1 //multiples how fast this slab recites scripture
	var/produces_components = TRUE //if it produces components at all
	var/selected_scripture = SCRIPTURE_DRIVER
	var/recollecting = FALSE //if we're looking at fancy recollection
	var/obj/effect/proc_holder/slab/slab_ability //the slab's current bound ability, for certain scripture
	var/list/quickbound = list(/datum/clockwork_scripture/ranged_ability/geis_prep, /datum/clockwork_scripture/create_object/replicant, \
	/datum/clockwork_scripture/create_object/tinkerers_cache) //quickbound scripture, accessed by index
	var/maximum_quickbound = 5 //how many quickbound scriptures we can have
	actions_types = list(/datum/action/item_action/clock/hierophant)

/obj/item/clockwork/slab/starter
	stored_components = list(BELLIGERENT_EYE = 1, VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 1, HIEROPHANT_ANSIBLE = 1)

/obj/item/clockwork/slab/internal //an internal motor for mobs running scripture
	name = "scripture motor"
	quickbound = list()
	no_cost = TRUE
	produces_components = FALSE

/obj/item/clockwork/slab/debug
	speed_multiplier = 0
	no_cost = TRUE

/obj/item/clockwork/slab/debug/attack_hand(mob/living/user)
	..()
	if(!is_servant_of_ratvar(user))
		add_servant_of_ratvar(user)

/obj/item/clockwork/slab/cyborg //three scriptures, plus a spear and proselytizer
	clockwork_desc = "A divine link to the Celestial Derelict, allowing for limited recital of scripture.\n\
	Hitting a slab, a Servant with a slab, or a cache will <b>transfer</b> this slab's components into the target, the target's slab, or the global cache, respectively."
	quickbound = list(/datum/clockwork_scripture/ranged_ability/judicial_marker, /datum/clockwork_scripture/ranged_ability/linked_vanguard, \
	/datum/clockwork_scripture/create_object/tinkerers_cache)
	maximum_quickbound = 6 //we usually have one or two unique scriptures, so if ratvar is up let us bind one more
	actions_types = list()

/obj/item/clockwork/slab/cyborg/engineer //five scriptures, plus a proselytizer
	quickbound = list(/datum/clockwork_scripture/create_object/replicant, /datum/clockwork_scripture/create_object/cogscarab, \
	/datum/clockwork_scripture/create_object/soul_vessel, /datum/clockwork_scripture/create_object/sigil_of_transmission, /datum/clockwork_scripture/create_object/interdiction_lens)

/obj/item/clockwork/slab/cyborg/medical //five scriptures, plus a spear
	quickbound = list(/datum/clockwork_scripture/ranged_ability/linked_vanguard, /datum/clockwork_scripture/ranged_ability/sentinels_compromise, \
	/datum/clockwork_scripture/create_object/vitality_matrix, /datum/clockwork_scripture/channeled/mending_mantra, /datum/clockwork_scripture/fellowship_armory)

/obj/item/clockwork/slab/cyborg/security //four scriptures, plus a spear
	quickbound = list(/datum/clockwork_scripture/channeled/belligerent, /datum/clockwork_scripture/ranged_ability/judicial_marker, /datum/clockwork_scripture/channeled/taunting_tirade, \
	/datum/clockwork_scripture/channeled/volt_void/cyborg)

/obj/item/clockwork/slab/cyborg/peacekeeper //four scriptures, plus a spear
	quickbound = list(/datum/clockwork_scripture/channeled/belligerent, /datum/clockwork_scripture/ranged_ability/judicial_marker, /datum/clockwork_scripture/channeled/taunting_tirade, \
	/datum/clockwork_scripture/channeled/volt_void/cyborg)

/obj/item/clockwork/slab/cyborg/janitor //five scriptures, plus a proselytizer
	quickbound = list(/datum/clockwork_scripture/create_object/replicant, /datum/clockwork_scripture/create_object/sigil_of_transgression, \
	/datum/clockwork_scripture/create_object/ocular_warden, /datum/clockwork_scripture/create_object/mania_motor, /datum/clockwork_scripture/create_object/tinkerers_daemon)

/obj/item/clockwork/slab/cyborg/service //five scriptures, plus xray vision
	quickbound = list(/datum/clockwork_scripture/create_object/replicant, /datum/clockwork_scripture/create_object/tinkerers_cache, \
	/datum/clockwork_scripture/spatial_gateway, /datum/clockwork_scripture/fellowship_armory, /datum/clockwork_scripture/create_object/clockwork_obelisk)

/obj/item/clockwork/slab/cyborg/miner //three scriptures, plus a spear and xray vision
	quickbound = list(/datum/clockwork_scripture/ranged_ability/linked_vanguard, /datum/clockwork_scripture/spatial_gateway, /datum/clockwork_scripture/channeled/volt_void/cyborg)

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
	production_time = world.time + SLAB_PRODUCTION_TIME

/obj/item/clockwork/slab/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(slab_ability && slab_ability.ranged_ability_user)
		slab_ability.remove_ranged_ability()
	slab_ability = null
	return ..()

/obj/item/clockwork/slab/dropped(mob/user)
	. = ..()
	addtimer(CALLBACK(src, .proc/check_on_mob, user), 1) //dropped is called before the item is out of the slot, so we need to check slightly later

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
	for(var/mob/living/M in GLOB.living_mob_list)
		if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
			servants++
	if(servants > SCRIPT_SERVANT_REQ)
		servants -= SCRIPT_SERVANT_REQ
		production_slowdown = min(SLAB_SERVANT_SLOWDOWN * servants, SLAB_SLOWDOWN_MAXIMUM) //SLAB_SERVANT_SLOWDOWN additional seconds for each servant above 5, up to SLAB_SLOWDOWN_MAXIMUM
	production_time = world.time + SLAB_PRODUCTION_TIME + production_slowdown
	var/mob/living/L
	L = get_atom_on_turf(src, /mob/living)
	if(istype(L) && can_recite_scripture(L))
		var/component_to_generate = target_component_id
		if(!component_to_generate)
			component_to_generate = get_weighted_component_id(src) //more likely to generate components that we have less of
		stored_components[component_to_generate]++
		update_slab_info(src)
		for(var/obj/item/clockwork/slab/S in L.GetAllContents()) //prevent slab abuse today
			if(S == src)
				continue
			S.production_time = production_time + 50 //set it to our next production plus five seconds, so that if you hold the same slabs, the same one will always generate
		to_chat(L, "<span class='warning'>Your slab cl[pick("ank", "ink", "unk", "ang")]s as it produces a </span><span class='[get_component_span(component_to_generate)]'>component</span><span class='warning'>.</span>")

/obj/item/clockwork/slab/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(LAZYLEN(quickbound))
			for(var/i in 1 to quickbound.len)
				if(!quickbound[i])
					continue
				var/datum/clockwork_scripture/quickbind_slot = quickbound[i]
				to_chat(user, "<b>Quickbind</b> button: <span class='[get_component_span(initial(quickbind_slot.primary_component))]'>[initial(quickbind_slot.name)]</span>.")
		if(GLOB.clockwork_caches) //show components on examine
			to_chat(user, "<b>Stored components (with global cache):</b>")
			for(var/i in stored_components)
				to_chat(user, "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[stored_components[i]]</b> \
				(<b>[stored_components[i] + GLOB.clockwork_component_cache[i]]</b>)</span>")
		else
			to_chat(user, "<b>Stored components:</b>")
			for(var/i in stored_components)
				to_chat(user, "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[stored_components[i]]</b></span>")

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
				to_chat(user, "<span class='heavy_brass'>\"You can't transfer components into your own slab, idiot.\"</span>")
			else
				for(var/i in stored_components)
					targetslab.stored_components[i] += stored_components[i]
					stored_components[i] = 0
				update_slab_info(targetslab)
				update_slab_info(src)
				user.visible_message("<span class='notice'>[user] empties [src] into [target]'s [targetslab.name].</span>", \
				"<span class='notice'>You transfer your slab's components into [target]'s [targetslab.name].</span>")
		else
			to_chat(user, "<span class='warning'>[target] has no slabs to transfer components to.</span>")
	else
		return ..()

/obj/item/clockwork/slab/attackby(obj/item/I, mob/user, params)
	var/ratvarian = is_servant_of_ratvar(user)
	if(istype(I, /obj/item/clockwork/component) && ratvarian)
		var/obj/item/clockwork/component/C = I
		if(!C.component_id)
			return 0
		user.visible_message("<span class='notice'>[user] inserts [C] into [src].</span>", "<span class='notice'>You insert [C] into [src]\
		[GLOB.clockwork_caches ? ", where it is added to the global cache":""].</span>")
		if(GLOB.clockwork_caches)
			GLOB.clockwork_component_cache[C.component_id]++
			update_slab_info()
		else
			stored_components[C.component_id]++
			update_slab_info(src)
		user.drop_item()
		qdel(C)
		return 1
	else if(istype(I, /obj/item/clockwork/slab) && ratvarian)
		var/obj/item/clockwork/slab/S = I
		var/needs_update = FALSE
		for(var/i in stored_components)
			stored_components[i] += S.stored_components[i]
			S.stored_components[i] = 0
			if(S.stored_components[i])
				needs_update = TRUE
		if(needs_update)
			update_slab_info(src)
			update_slab_info(S)
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
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='warning'>You cannot speak into the slab!</span>")
		return FALSE
	var/message = stripped_input(user, "Enter a message to send to your fellow servants.", "Hierophant")
	if(!message || !user || !user.canUseTopic(src) || !user.can_speak_vocal())
		return FALSE
	clockwork_say(user, text2ratvar("Servants, hear my words. [html_decode(message)]"), TRUE)
	titled_hierophant_message(user, message)
	return TRUE

//Scripture Recital
/obj/item/clockwork/slab/attack_self(mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='heavy_brass'>\"You reek of blood. You've got a lot of nerve to even look at that slab.\"</span>")
		user.visible_message("<span class='warning'>A sizzling sound comes from [user]'s hands!</span>", "<span class='userdanger'>[src] suddenly grows extremely hot in your hands!</span>")
		playsound(get_turf(user), 'sound/weapons/sear.ogg', 50, 1)
		user.drop_item()
		user.emote("scream")
		user.apply_damage(5, BURN, "l_arm")
		user.apply_damage(5, BURN, "r_arm")
		return 0
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='warning'>The information on [src]'s display shifts rapidly. After a moment, your head begins to pound, and you tear your eyes away.</span>")
		user.confused += 5
		user.dizziness += 5
		return 0
	if(busy)
		to_chat(user, "<span class='warning'>[src] refuses to work, displaying the message: \"[busy]!\"</span>")
		return 0
	if(!can_recite_scripture(user))
		to_chat(user, "<span class='nezbere'>[src] hums fitfully in your hands, but doesn't seem to do anything...</span>")
		return 0
	access_display(user)

/obj/item/clockwork/slab/proc/access_display(mob/living/user)
	if(!is_servant_of_ratvar(user))
		return FALSE
	ui_interact(user)
	return TRUE

/obj/item/clockwork/slab/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "clockwork_slab", name, 800, 420, master_ui, state)
		ui.set_autoupdate(FALSE) //we'll update this occasionally, but not as often as possible
		ui.set_style("clockwork")
		ui.open()

/obj/item/clockwork/slab/proc/recite_scripture(datum/clockwork_scripture/scripture, mob/living/user)
	if(!scripture || !user || !user.canUseTopic(src) || !can_recite_scripture(user))
		return FALSE
	if(user.get_active_held_item() != src)
		to_chat(user, "<span class='warning'>You need to hold the slab in your active hand to recite scripture!</span>")
		return FALSE
	var/initial_tier = initial(scripture.tier)
	if(initial_tier != SCRIPTURE_PERIPHERAL)
		if(!GLOB.ratvar_awakens && !no_cost && !SSticker.scripture_states[initial_tier])
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
		var/servants = 0
		var/production_time = SLAB_PRODUCTION_TIME
		for(var/mob/living/M in GLOB.living_mob_list)
			if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
				servants++
		if(servants > SCRIPT_SERVANT_REQ)
			servants -= SCRIPT_SERVANT_REQ
			production_time += min(SLAB_SERVANT_SLOWDOWN * servants, SLAB_SLOWDOWN_MAXIMUM)
		var/production_text_addon = ""
		if(production_time != SLAB_PRODUCTION_TIME+SLAB_SLOWDOWN_MAXIMUM)
			production_text_addon = ", which increases for each human or silicon servant above <b>[SCRIPT_SERVANT_REQ]</b>"
		production_time = production_time/600
		var/list/production_text
		if(round(production_time))
			production_text = list("<b>[round(production_time)] minute\s")
		if(production_time != round(production_time))
			production_time -= round(production_time)
			production_time *= 60
			if(!LAZYLEN(production_text))
				production_text = list("<b>[round(production_time, 1)] second\s")
			else
				production_text += " and [round(production_time, 1)] second\s"
		production_text += "</b>"
		production_text += production_text_addon
		production_text = production_text.Join()

		textlist = list("<font color=#BE8700 size=3><b><center>Chetr nyy hagehguf-naq-ubabe Ratvar.</center></b></font><br>\
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
		The remaining functions are several buttons in the top left while holding the slab.<br>From left to right, they are:<br>\
		<b><font color=#DAAA18>Hierophant Network</font></b>, which allows communication to other Servants.<br>")
		if(LAZYLEN(quickbound))
			for(var/i in 1 to maximum_quickbound)
				if(LAZYLEN(quickbound) < i || !quickbound[i])
					textlist += "A <b>Quickbind</b> slot, currently set to <b><font color=#BE8700>Nothing</font></b>.<br>"
				else
					var/datum/clockwork_scripture/quickbind_slot = quickbound[i]
					textlist += "A <b>Quickbind</b> slot, currently set to <b><font color=[get_component_color_bright(initial(quickbind_slot.primary_component))]>[initial(quickbind_slot.name)]</font></b>.<br>"
		textlist += "<br>\
		Examine the slab or swap to Recital to check the number of components it has available.<br><br>\
		\
		<font color=#BE8700 size=3><b><center>Purge all untruths and honor Ratvar.</center></b></font>"
	return textlist.Join()

/obj/item/clockwork/slab/ui_data(mob/user) //we display a lot of data via TGUI
	var/list/data = list()
	data["components"] = stored_components.Copy()
	var/list/temp_data = list("<font color=#B18B25>")
	for(var/i in data["components"]) //display the slab's components
		temp_data += "<font color=[get_component_color_bright(i)]>[get_component_acronym(i)] <b>[data["components"][i]]</b></font>"
		if(i != HIEROPHANT_ANSIBLE)
			temp_data += " "
		else
			temp_data += " ("
	if(GLOB.clockwork_caches) //if we have caches, display what's in the global cache
		for(var/i in GLOB.clockwork_component_cache)
			temp_data += "<font color=[get_component_color_bright(i)]>[get_component_acronym(i)] <b>[data["components"][i] + GLOB.clockwork_component_cache[i]]</b></font>"
			if(i != HIEROPHANT_ANSIBLE)
				temp_data += " "
	else
		temp_data += "<b>NONE</b>"
	temp_data += ")</font>"
	temp_data = temp_data.Join()
	data["components"] = temp_data

	switch(selected_scripture) //display info based on selected scripture tier
		if(SCRIPTURE_DRIVER)
			data["tier_info"] = "<font color=#B18B25><b>These scriptures are permenantly unlocked.</b></font>"
		if(SCRIPTURE_SCRIPT)
			if(SSticker.scripture_states[SCRIPTURE_SCRIPT])
				data["tier_info"] = "<font color=#B18B25><b>These scriptures are permenantly unlocked.</b></font>"
			else
				data["tier_info"] = "<font color=#B18B25><i>These scriptures require at least <b>[SCRIPT_SERVANT_REQ]</b> Servants and <b>[SCRIPT_CACHE_REQ]</b> Tinkerer's Cache.</i></font>"
		if(SCRIPTURE_APPLICATION)
			if(SSticker.scripture_states[SCRIPTURE_APPLICATION])
				data["tier_info"] = "<font color=#B18B25><b>These scriptures are permenantly unlocked.</b></font>"
			else
				data["tier_info"] = "<font color=#B18B25><i>These scriptures require at least <b>[APPLICATION_SERVANT_REQ]</b> Servants, <b>[APPLICATION_CACHE_REQ]</b> Tinkerer's Caches, and <b>[APPLICATION_CV_REQ]CV</b>.</i></font>"
		if(SCRIPTURE_REVENANT)
			if(SSticker.scripture_states[SCRIPTURE_REVENANT])
				data["tier_info"] = "<font color=#B18B25><b>These scriptures are permenantly unlocked.</b></font>"
			else
				data["tier_info"] = "<font color=#B18B25><i>These scriptures require at least <b>[REVENANT_SERVANT_REQ]</b> Servants, <b>[REVENANT_CACHE_REQ]</b> Tinkerer's Caches, and <b>[REVENANT_CV_REQ]CV</b>.</i></font>"
		if(SCRIPTURE_JUDGEMENT)
			if(SSticker.scripture_states[SCRIPTURE_JUDGEMENT])
				data["tier_info"] = "<font color=#B18B25><b>This scripture is permenantly unlocked.</b></font>"
			else
				data["tier_info"] = "<font color=#B18B25><i>This scripture requires at least <b>[JUDGEMENT_SERVANT_REQ]</b> Servants, <b>[JUDGEMENT_CACHE_REQ]</b> Tinkerer's Caches, and <b>[JUDGEMENT_CV_REQ]CV</b>.<br>In addition, there may not be any active non-Servant AIs.</i></font>"

	data["selected"] = selected_scripture

	data["target_comp"] = "<font color=#B18B25>NONE</font>"
	if(target_component_id) //if we have a component to make, display that, too
		data["target_comp"] = "<font color=[get_component_color_bright(target_component_id)]>[get_component_acronym(target_component_id)]</font>"

	generate_all_scripture()

	data["scripture"] = list()
	for(var/s in GLOB.all_scripture)
		var/datum/clockwork_scripture/S = GLOB.all_scripture[s]
		if(S.tier == selected_scripture) //display only scriptures of the selected tier
			var/scripture_color = get_component_color_bright(S.primary_component)
			var/list/temp_info = list("name" = "<font color=[scripture_color]><b>[S.name]</b></font>",
			"descname" = "<font color=[scripture_color]>([S.descname])</font>",
			"tip" = "[S.desc]\n[S.usage_tip]",
			"required" = list(BELLIGERENT_EYE = 0, VANGUARD_COGWHEEL = 0, GEIS_CAPACITOR = 0, REPLICANT_ALLOY = 0, HIEROPHANT_ANSIBLE = 0),
			"type" = "[S.type]",
			"quickbind" = S.quickbind)
			var/found = quickbound.Find(S.type)
			if(found)
				temp_info["bound"] = "<b>[found]</b>"
			if(S.invokers_required > 1)
				temp_info["invokers"] = "<font color=#B18B25>Invokers: <b>[S.invokers_required]</b></font>"
			var/costs_components = FALSE
			for(var/i in S.consumed_components)
				if(S.consumed_components[i])
					temp_info["required"][i] += S.consumed_components[i]
					costs_components = TRUE
			if(costs_components) //if we have a component cost, we'll need a : next to the recital button
				var/list/really_temp_data = list(": ")
				for(var/i in temp_info["required"])
					if(temp_info["required"][i])
						really_temp_data += "<font color=[get_component_color_bright(i)]>[get_component_acronym(i)] <b>[temp_info["required"][i]]</b></font> "
				really_temp_data = really_temp_data.Join()
				temp_info["required"] = really_temp_data
			else //and if we don't, we won't.
				temp_info["required"] = ""
			data["scripture"] += list(temp_info)
	data["recollection"] = recollecting
	if(recollecting)
		data["rec_text"] = recollection()
	return data

/obj/item/clockwork/slab/ui_act(action, params)
	switch(action)
		if("toggle")
			recollecting = !recollecting
		if("recite")
			INVOKE_ASYNC(src, .proc/recite_scripture, text2path(params["category"]), usr, FALSE)
		if("select")
			selected_scripture = params["category"]
		if("component")
			var/list/components = list("Random Components")
			for(var/i in GLOB.clockwork_component_cache)
				var/cache_components = 0
				if(GLOB.clockwork_caches)
					cache_components = GLOB.clockwork_component_cache[i]
				components["[get_component_name(i)] [(cache_components + stored_components[i])]"] = i
			var/input_component = input("Choose a component type.", "Target Component") as null|anything in components
			if(input_component && !..())
				target_component_id = components[input_component]
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
			var/list/temp_desc = list()
			for(var/c in quickbind_slot.consumed_components) //show how much the bound scripture costs
				if(quickbind_slot.consumed_components[c])
					temp_desc += "<font color=[get_component_color_bright(c)]>[get_component_acronym(c)] <b>[quickbind_slot.consumed_components[c]]</b></font> "
			if(LAZYLEN(temp_desc))
				temp_desc += "<br>"
			temp_desc += "[quickbind_slot.quickbind_desc]"
			Q.desc = temp_desc.Join()
			Q.button_icon_state = quickbind_slot.name
			Q.UpdateButtonIcon()
			if(isliving(loc))
				Q.Grant(loc)
