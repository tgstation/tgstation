/// CARGO BORGS ///
#define CYBORG_FONT "Consolas"
#define MAX_PAPER_INTEGRATED_CLIPBOARD 10

/obj/item/pen/cyborg
	name = "integrated pen"
	font = CYBORG_FONT
	desc = "You can almost hear the sound of gears grinding against one another as you write with this pen. Almost."


/obj/item/clipboard/cyborg
	name = "\improper integrated clipboard"
	desc = "A clipboard which seems to come adapted with a paper synthetizer, carefully hidden in its paper clip."
	integrated_pen = TRUE
	/// When was the last time the printer was used?
	COOLDOWN_DECLARE(printer_cooldown)
	/// How long is the integrated printer's cooldown?
	var/printer_cooldown_time = 10 SECONDS
	/// How much charge is required to print a piece of paper?
	var/paper_charge_cost = 50


/obj/item/clipboard/cyborg/Initialize(mapload)
	. = ..()
	pen = new /obj/item/pen/cyborg


/obj/item/clipboard/cyborg/examine()
	. = ..()
	. += "Alt-click to synthetize a piece of paper."
	if(!COOLDOWN_FINISHED(src, printer_cooldown))
		. += "Its integrated paper synthetizer seems to still be on cooldown."


/obj/item/clipboard/cyborg/AltClick(mob/user)
	if(!iscyborg(user))
		to_chat(user, span_warning("You do not seem to understand how to use [src]."))
		return
	var/mob/living/silicon/robot/cyborg_user = user
	// Not enough charge? Tough luck.
	if(cyborg_user?.cell.charge < paper_charge_cost)
		to_chat(user, span_warning("Your internal cell doesn't have enough charge left to use [src]'s integrated printer."))
		return
	// Check for cooldown to avoid paper spamming
	if(COOLDOWN_FINISHED(src, printer_cooldown))
		// If there's not too much paper already, let's go
		if(!toppaper_ref || length(contents) < MAX_PAPER_INTEGRATED_CLIPBOARD)
			cyborg_user.cell.use(paper_charge_cost)
			COOLDOWN_START(src, printer_cooldown, printer_cooldown_time)
			var/obj/item/paper/new_paper = new /obj/item/paper
			new_paper.forceMove(src)
			if(toppaper_ref)
				var/obj/item/paper/toppaper = toppaper_ref?.resolve()
				UnregisterSignal(toppaper, COMSIG_ATOM_UPDATED_ICON)
			RegisterSignal(new_paper, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_top_paper_change))
			toppaper_ref = WEAKREF(new_paper)
			update_appearance()
			to_chat(user, span_notice("[src]'s integrated printer whirs to life, spitting out a fresh piece of paper and clipping it into place."))
		else
			to_chat(user, span_warning("[src]'s integrated printer refuses to print more paper, as [src] already contains enough paper."))
	else
		to_chat(user, span_warning("[src]'s integrated printer refuses to print more paper, its bluespace paper synthetizer not having finished recovering from its last synthesis."))


/obj/item/hand_labeler/cyborg
	name = "integrated hand labeler"
	labels_left = 9000 // I don't want to bother forcing them to recharge, honestly, that's a lot of code for a very niche functionality


/// The clamps
/obj/item/borg/hydraulic_clamp
	name = "integrated hydraulic clamp"
	desc = "A neat way to lift and move around few small packages for quick and painless deliveries!"
	icon = 'icons/mecha/mecha_equipment.dmi' // Just some temporary sprites because I don't have any unique one yet
	icon_state = "mecha_clamp"
	/// How much power does it draw per operation?
	var/charge_cost = 20
	/// How many items can it hold at once in its internal storage?
	var/storage_capacity = 5
	/// Does it require the items it takes in to be wrapped in paper wrap? Can have unforeseen consequences, change to FALSE at your own risks.
	var/whitelisted_contents = TRUE
	/// What kind of wrapped item can it hold, if `whitelisted_contents` is set to true?
	var/list/whitelisted_item_types = list(/obj/item/delivery/small, /obj/item/bounty_cube)
	/// A short description used when the check to pick up something has failed.
	var/whitelisted_item_description = "small wrapped packages"
	/// Weight limit on the items it can hold. Leave as NONE if there isn't.
	var/item_weight_limit = WEIGHT_CLASS_SMALL
	/// Can it hold mobs? (Dangerous, it is recommended to leave this to FALSE)
	var/can_hold_mobs = FALSE
	/// Audio for using the hydraulic clamp.
	var/clamp_sound = 'sound/mecha/hydraulic.ogg'
	/// Volume of the clamp's loading and unloading noise.
	var/clamp_sound_volume = 25
	/// Cooldown for the clamp.
	COOLDOWN_DECLARE(clamp_cooldown)
	/// How long is the clamp on cooldown for after every usage?
	var/cooldown_duration = 0.5 SECONDS
	/// How long does it take to load in an item?
	var/loading_time = 2 SECONDS
	/// How long does it take to unload an item?
	var/unloading_time = 1 SECONDS
	/// Is it currently in use?
	var/in_use = FALSE
	/// Index of the item we want to take out of the clamp, 0 if nothing selected.
	var/selected_item_index = 0
	/// Weakref to the cyborg we're currently connected to.
	var/datum/weakref/cyborg_holding_me


/obj/item/borg/hydraulic_clamp/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/robot_model))
		return

	var/obj/item/robot_model/holder_model = loc
	cyborg_holding_me = WEAKREF(holder_model.robot)

	RegisterSignal(holder_model.robot, COMSIG_LIVING_DEATH, PROC_REF(empty_contents))


/obj/item/borg/hydraulic_clamp/Destroy()
	var/mob/living/silicon/robot/robot_holder = cyborg_holding_me?.resolve()
	if(robot_holder)
		UnregisterSignal(robot_holder, COMSIG_LIVING_DEATH)
	return ..()


/obj/item/borg/hydraulic_clamp/examine(mob/user)
	. = ..()
	. += span_notice("It's cargo hold has a capacity of [storage_capacity] and is currently holding <b>[contents.len ? contents.len : 0]</b> items in it!")
	if(storage_capacity > 1)
		. += span_notice("Use in hand to select an item you want to prioritize taking out of the storage.")


/// A simple proc to empty the contents of the hydraulic clamp, forcing them on the turf it's on. Also forces `selected_item_index` to 0, to avoid any possible issues resulting from it.
/obj/item/borg/hydraulic_clamp/proc/empty_contents()
	SIGNAL_HANDLER

	selected_item_index = 0
	var/spilled_amount = 0
	var/turf/turf_of_clamp = get_turf(src)
	for(var/atom/movable/item in contents)
		item.forceMove(turf_of_clamp)
		spilled_amount++

	if(spilled_amount)
		var/holder = cyborg_holding_me?.resolve()
		if(holder)
			visible_message(span_warning("[cyborg_holding_me?.resolve()] spills the content of [src]'s cargo hold all over the floor!"))


/obj/item/borg/hydraulic_clamp/attack_self(mob/user, modifiers)
	if(storage_capacity <= 1) // No need for selection if there's one or less item at maximum in the clamp.
		return

	selected_item_index = 0

	if(contents.len <= 1)
		to_chat(user, span_warning("There's currently [contents.len ? "only one item" : "nothing"] to take out of [src]'s cargo hold, no need to pick!"))
		return

	. = ..()

	var/list/choices = list()
	var/index = 1
	for(var/item in contents)
		choices[item] = index
		index++

	var/selection = tgui_input_list(user, "Which item would you like to prioritize?", "Choose an item to prioritize", choices)
	if(!selection)
		return

	var/new_index = choices[selection]
	if(!new_index)
		return

	selected_item_index = new_index
	to_chat(user, span_notice("[src] will now prioritize unloading [selection]."))


/obj/item/borg/hydraulic_clamp/emp_act(severity)
	. = ..()
	empty_contents()


/obj/item/borg/hydraulic_clamp/pre_attack(atom/attacked_atom, mob/living/silicon/robot/user, params)
	if(!istype(user) || !user.Adjacent(attacked_atom) || !COOLDOWN_FINISHED(src, clamp_cooldown) || in_use)
		return

	// Not enough charge? Tough luck.
	if(user?.cell.charge < charge_cost)
		to_chat(user, span_warning("Your internal cell doesn't have enough charge left to use [src]."))
		return

	user.cell.use(charge_cost)
	in_use = TRUE
	COOLDOWN_START(src, clamp_cooldown, cooldown_duration)

	// We're trying to unload something from the clamp, only possible on the floor, tables and conveyors.
	if(isturf(attacked_atom) || istype(attacked_atom, /obj/structure/table) || istype(attacked_atom, /obj/machinery/conveyor))
		if(!contents.len)
			in_use = FALSE
			return

		var/extraction_index = selected_item_index ? selected_item_index : contents.len
		var/atom/movable/extracted_item = contents[extraction_index]
		selected_item_index = 0

		if(unloading_time > 0.5 SECONDS) // We don't want too much chat spam if the clamp works fast.
			to_chat(user, span_notice("You start unloading something from [src]..."))
		playsound(src, clamp_sound, clamp_sound_volume, FALSE, -5)
		COOLDOWN_START(src, clamp_cooldown, cooldown_duration)

		if(!do_after(user, unloading_time, attacked_atom))
			in_use = FALSE
			return

		var/turf/extraction_turf = get_turf(attacked_atom)
		extracted_item.forceMove(extraction_turf)
		visible_message(span_notice("[src.loc] unloads [extracted_item] from [src]."))
		log_silicon("[user] unloaded [extracted_item] onto [extraction_turf] ([AREACOORD(extraction_turf)]).")
		in_use = FALSE
		return

	// We're trying to load something in the clamp
	else
		if(whitelisted_contents && !is_type_in_list(attacked_atom, whitelisted_item_types))
			to_chat(user, span_warning("[src] can only pick up [whitelisted_item_description]!"))
			in_use = FALSE
			return

		if(contents.len >= storage_capacity)
			to_chat(user, span_warning("[src] is already at full capacity!"))
			in_use = FALSE
			return

		if(item_weight_limit)
			var/obj/item/to_lift = attacked_atom
			if(!to_lift || to_lift.w_class > item_weight_limit)
				to_chat(user, span_warning("[to_lift] is too big for [src]!"))
				in_use = FALSE
				return

		var/atom/movable/lifting_up = attacked_atom

		if(lifting_up.anchored)
			to_chat(user, span_warning("[lifting_up] is firmly secured, it's not currently possible to move it into [src]!"))
			in_use = FALSE
			return

		var/contains_mobs = FALSE

		if(istype(lifting_up, /obj/item/delivery/big))
			var/obj/item/delivery/big/parcel = lifting_up
			if(parcel.contains_mobs)
				if(!can_hold_mobs)
					to_chat(user, span_warning("[src]'s warning light blinks red: There's something with the potential to be alive inside of [parcel]!"))
					in_use = FALSE
					return
				contains_mobs = TRUE
			parcel.set_anchored(TRUE)

		lifting_up.add_fingerprint(user)

		if(loading_time > 0.5 SECONDS) // We don't want too much chat spam if the clamp works fast.
			to_chat(user, span_notice("You start loading [lifting_up] into [src]'s cargo hold..."))
		playsound(src, clamp_sound, clamp_sound_volume, FALSE, -5)

		if(!do_after(user, loading_time, lifting_up)) // It takes two seconds to put stuff into the clamp's cargo hold
			lifting_up.set_anchored(initial(lifting_up.anchored))
			in_use = FALSE
			return

		lifting_up.set_anchored(FALSE)
		lifting_up.forceMove(src)
		var/turf/lifting_up_from = get_turf(lifting_up.loc)
		log_silicon("[user] loaded [lifting_up] (Contains mobs: [contains_mobs]) into [src] at ([AREACOORD(lifting_up_from)]).")
		visible_message(span_notice("[src.loc] loads [lifting_up] into [src]'s cargo hold."))
		in_use = FALSE


/obj/item/borg/hydraulic_clamp/better
	name = "improved integrated hydraulic clamp"
	desc = "A neat way to lift and move around wrapped crates for quick and painless deliveries!"
	storage_capacity = 2
	whitelisted_item_types = list(/obj/item/delivery, /obj/item/bounty_cube) // If they want to carry a small package or a bounty cube instead, so be it, honestly.
	whitelisted_item_description = "wrapped packages"
	item_weight_limit = NONE
	clamp_sound_volume = 50

/obj/item/borg/hydraulic_clamp/better/examine(mob/user)
	. = ..()
	var/crate_count = contents.len
	. += "There is currently <b>[crate_count > 0 ? crate_count : "no"]</b> crate[crate_count > 1 ? "s" : ""] stored in the clamp's internal storage."

/obj/item/borg/hydraulic_clamp/mail
	name = "integrated rapid mail delivery device"
	desc = "Allows you to carry around a lot of mail, to distribute it around the station like the good little mailbot you are!"
	icon = 'icons/obj/library.dmi'
	icon_state = "bookbag"
	storage_capacity = 100
	loading_time = 0.25 SECONDS
	unloading_time = 0.25 SECONDS
	cooldown_duration = 0.25 SECONDS
	whitelisted_item_types = list(/obj/item/mail)
	whitelisted_item_description = "enveloppes"
	item_weight_limit = WEIGHT_CLASS_NORMAL
	clamp_sound_volume = 25
	clamp_sound = 'sound/items/pshoom.ogg'



/datum/design/borg_upgrade_clamp
	name = "Improved Integrated Hydraulic Clamp Module"
	id = "borg_upgrade_clamp"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/better_clamp
	materials = list(/datum/material/titanium = 2000 * 2, /datum/material/gold = 1000, /datum/material/bluespace = 1000)
	construction_time = 12 SECONDS
	category = list(RND_CATEGORY_MECHFAB_CYBORG_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_CARGO)


/obj/item/borg/upgrade/better_clamp
	name = "improved integrated hydraulic clamp"
	desc = "An improved hydraulic clamp that trades its storage quantity to allow for bigger packages to be picked up instead!"
	icon_state = "cyborg_upgrade3"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/cargo)
	model_flags = BORG_MODEL_CARGO


/obj/item/borg/upgrade/better_clamp/action(mob/living/silicon/robot/cyborg, user = usr)
	. = ..()
	if(!.)
		return
	var/obj/item/borg/hydraulic_clamp/better/big_clamp = locate() in cyborg.model.modules
	if(big_clamp)
		to_chat(user, span_warning("This cyborg is already equipped with an improved integrated hydraulic clamp!"))
		return FALSE

	big_clamp = new(cyborg.model)
	cyborg.model.basic_modules += big_clamp
	cyborg.model.add_module(big_clamp, FALSE, TRUE)


/obj/item/borg/upgrade/better_clamp/deactivate(mob/living/silicon/robot/cyborg, user = usr)
	. = ..()
	if(!.)
		return
	var/obj/item/borg/hydraulic_clamp/better/big_clamp = locate() in cyborg.model.modules
	if(big_clamp)
		cyborg.model.remove_module(big_clamp, TRUE)



/// The fabled paper plane crossbow and its hardlight paper planes.
/obj/item/paperplane/syndicate/hardlight
	name = "hardlight paper plane"
	desc = "Hard enough to hurt, fickle enough to be impossible to pick up."
	impact_eye_damage_lower = 10
	impact_eye_damage_higher = 10
	delete_on_impact = TRUE
	/// Which color is the paper plane?
	var/list/paper_colors = list(COLOR_CYAN, COLOR_BLUE_LIGHT, COLOR_BLUE)
	alpha = 150 // It's hardlight, it's gotta be see-through.


/obj/item/paperplane/syndicate/hardlight/Initialize(mapload)
	. = ..()
	color = color_hex2color_matrix(pick(paper_colors))
	alpha = initial(alpha) // It's hardlight, it's gotta be see-through.


/obj/item/borg/paperplane_crossbow
	name = "paper plane crossbow"
	desc = "Be careful, don't aim for the eyes- Who am I kidding, <i>definitely</i> aim for the eyes!"
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "crossbow"
	/// How many planes does the crossbow currently have in its internal magazine?
	var/planes = 4
	/// Maximum of planes the crossbow can hold.
	var/max_planes = 4
	/// Time it takes to regenerate one plane
	var/charge_delay = 1 SECONDS
	/// Is the crossbow currently charging a new paper plane?
	var/charging = FALSE
	/// How long is the cooldown between shots?
	var/shooting_delay = 0.5 SECONDS
	/// Are we ready to fire again?
	COOLDOWN_DECLARE(shooting_cooldown)


/obj/item/borg/paperplane_crossbow/examine(mob/user)
	. = ..()
	. += span_notice("There is <b>[planes]</b> left inside of its internal magazine, out of [max_planes].")
	var/charging_speed = 10 / charge_delay
	. += span_notice("It recharges at a rate of <b>[charging_speed]</b> plane[charging_speed >= 2 ? "s" : ""] per second.")


/obj/item/borg/paperplane_crossbow/equipped()
	. = ..()
	check_amount()


/obj/item/borg/paperplane_crossbow/dropped()
	. = ..()
	check_amount()


/// A simple proc to check if we're at the max amount of planes, if not, we keep on charging. Called by [/obj/item/borg/paperplane_crossbow/proc/charge_paper_planes()].
/obj/item/borg/paperplane_crossbow/proc/check_amount()
	if(!charging && planes < max_planes)
		addtimer(CALLBACK(src, PROC_REF(charge_paper_planes)), charge_delay)
		charging = TRUE


/// A simple proc to charge paper planes, that then calls [/obj/item/borg/paperplane_crossbow/proc/check_amount()] to see if it should charge another one, over and over.
/obj/item/borg/paperplane_crossbow/proc/charge_paper_planes()
	planes++
	charging = FALSE
	check_amount()


/// A proc for shooting a projectile at the target, it's just that simple, really.
/obj/item/borg/paperplane_crossbow/proc/shoot(atom/target, mob/living/user, params)
	if(!COOLDOWN_FINISHED(src, shooting_cooldown))
		return
	if(planes <= 0)
		to_chat(user, span_warning("Not enough paper planes left!"))
		return FALSE
	planes--

	var/obj/item/paperplane/syndicate/hardlight/plane_to_fire = new /obj/item/paperplane/syndicate/hardlight(get_turf(src.loc))

	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	plane_to_fire.throw_at(target, plane_to_fire.throw_range, plane_to_fire.throw_speed, user)
	COOLDOWN_START(src, shooting_cooldown, shooting_delay)
	user.visible_message(span_warning("[user] shoots a paper plane at [target]!"))
	check_amount()


/obj/item/borg/paperplane_crossbow/afterattack(atom/target, mob/living/user, proximity, click_params)
	. = ..()
	check_amount()
	if(iscyborg(user))
		var/mob/living/silicon/robot/robot_user = user
		if(!robot_user.cell.use(10))
			to_chat(user, span_warning("Not enough power."))
			return FALSE
		shoot(target, user, click_params)


/// Holders for the package wrap and the wrapping paper synthetizers.

/datum/robot_energy_storage/package_wrap
	name ="package wrapper synthetizer"
	max_energy = 25
	recharge_rate = 2


/datum/robot_energy_storage/wrapping_paper
	name ="wrapping paper synthetizer"
	max_energy = 25
	recharge_rate = 2


/obj/item/stack/package_wrap/cyborg
	name = "integrated package wrapper"
	is_cyborg = TRUE
	source = /datum/robot_energy_storage/package_wrap


/obj/item/stack/wrapping_paper/xmas/cyborg
	name = "integrated wrapping paper"
	is_cyborg = TRUE
	source = /datum/robot_energy_storage/wrapping_paper


/obj/item/stack/wrapping_paper/xmas/cyborg/use(used, transfer, check = FALSE) // Check is set to FALSE here, so the stack istn't deleted.
	. = ..()


/// Some override that didn't belong anywhere else.

/obj/item/delivery/big
	/// Does this wrapped package contain at least one mob?
	var/contains_mobs = FALSE

// I did this out of sanity, I didn't want to make the clamp code more complex than necessary, and honestly I'm considering taking this upstream, it just feels awkward to PR just that.
/obj/item/bounty_cube
	w_class = WEIGHT_CLASS_SMALL
