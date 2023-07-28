/// SKYRAPTOR AESTHETICS MODULE: SHIPTEST CHEMISTRY
/// Reworks sprites to Shiptest style, and adds caps to beakers and bottles.

/// CAP CODE GOES HERE
/obj/item/reagent_containers
	/// To enable caps, set can_have_cap to TRUE and define a cap_icon_state. Do not change at runtime.
	var/can_have_cap = FALSE
	VAR_PROTECTED/cap_icon_state = null
	/// Whether the container has a cap on. Do not set directly at runtime; use set_cap_status().
	VAR_PROTECTED/cap_on = FALSE
	VAR_PRIVATE/mutable_appearance/cap_overlay = null

/// Adds code to initialization for the caps
/obj/item/reagent_containers/Initialize(mapload, vol)
	. = ..()
	if(can_have_cap && cap_icon_state)
		cap_overlay = mutable_appearance(icon, cap_icon_state)
	if(can_have_cap)
		if(!cap_icon_state)
			WARNING("Container that allows caps is lacking a cap_icon_state!")
		set_cap_status(cap_on)
	else
		cap_on = FALSE

/// Adds the container's cap if TRUE is passed in, and removes it if FALSE is passed in. Container must be able to accept a cap.
/obj/item/reagent_containers/proc/set_cap_status(value_to_set)
	if(!can_have_cap)
		CRASH("Cannot change cap status of reagent container that disallows caps!")
	if(value_to_set)
		cap_on = TRUE
		spillable = FALSE
	else
		cap_on = FALSE
		spillable = TRUE
	update_icon()

/// Adds examine notes for the cap
/obj/item/reagent_containers/examine(mob/user)
	. = ..()
	if(!can_have_cap)
		return
	else
		if(cap_on)
			. += "<span class='notice'>The cap is firmly on to prevent spilling. Alt-click to remove the cap.</span>"
		else
			. += "<span class='notice'>The cap has been taken off. Alt-click to put a cap on.</span>"

/// Stops injectability, drawability, refilling, draining, and so on
/obj/item/reagent_containers/is_injectable(mob/user, allowmobs = TRUE)
	if(can_have_cap && cap_on)
		return FALSE
	return ..()
/obj/item/reagent_containers/is_drawable(mob/user, allowmobs = TRUE)
	if(can_have_cap && cap_on)
		return FALSE
	return ..()
/obj/item/reagent_containers/is_refillable()
	if(can_have_cap && cap_on)
		return FALSE
	return ..()
/obj/item/reagent_containers/is_drainable()
	if(can_have_cap && cap_on)
		return FALSE
	return ..()

/// Adds alt-clicking to take the cap on or off
/obj/item/reagent_containers/AltClick(mob/user)
	. = ..()
	if(can_have_cap)
		if(cap_on)
			set_cap_status(FALSE)
			to_chat(user, "<span class='notice'>You remove the cap from [src].</span>")
		else
			set_cap_status(TRUE)
			to_chat(user, "<span class='notice'>You put the cap on [src].</span>")
		//playsound(src, 'sound/items/glass_cap.ogg', 50, 1)

/// Adds cap overlay
/obj/item/reagent_containers/update_overlays()
	. = ..()
	if(cap_on)
		. += cap_overlay



/// ACTUAL AESTHETIC CHANGES BEGIN HERE
/obj/item/reagent_containers/cup/beaker
	icon = 'modular_skyraptor/modules/aesthetics/shiptest_chemcontainers/shipchems.dmi'
	fill_icon = 'modular_skyraptor/modules/aesthetics/shiptest_chemcontainers/reagentfillings.dmi'
	fill_icon_thresholds = list(1, 40, 60, 80, 100)
	//fill_icon_state = "beaker"

	cap_on = TRUE
	can_have_cap = TRUE
	cap_icon_state = "beaker_cap"

/obj/item/reagent_containers/cup/beaker/jar
	fill_icon = 'icons/obj/medical/reagent_fillings.dmi'
	cap_on = FALSE
	can_have_cap = FALSE
	cap_icon_state = null

/obj/item/reagent_containers/cup/beaker/large
	fill_icon_thresholds = list(1, 40, 60, 80, 100)
	cap_icon_state = "beakerlarge_cap"

/obj/item/reagent_containers/cup/beaker/plastic
	fill_icon_thresholds = list(1, 40, 60, 80, 100)
	fill_icon_state = "beakerlarge"
	cap_icon_state = "beakerlarge_cap"

/obj/item/reagent_containers/cup/beaker/meta
	fill_icon_thresholds = list(1, 25, 50, 75, 100)
	cap_icon_state = "beakergold_cap"

/obj/item/reagent_containers/cup/beaker/noreact
	cap_icon_state = "beakernoreact_cap"

/obj/item/reagent_containers/cup/beaker/bluespace
	cap_icon_state = "beakerbluespace_cap"

/obj/item/reagent_containers/cup/bottle
	icon = 'modular_skyraptor/modules/aesthetics/shiptest_chemcontainers/shipchems.dmi'
	fill_icon = 'modular_skyraptor/modules/aesthetics/shiptest_chemcontainers/reagentfillings.dmi'
	fill_icon_thresholds = list(0, 10, 30, 50, 70)

	cap_on = TRUE
	can_have_cap = TRUE
	cap_icon_state = "bottle_cap"

/obj/item/reagent_containers/cup/bottle/morphine
	icon = 'modular_skyraptor/modules/aesthetics/shiptest_chemcontainers/shipchems.dmi'

/obj/item/reagent_containers/cup/bottle/syrup_bottle
	fill_icon = 'icons/obj/medical/reagent_fillings.dmi'
	fill_icon_thresholds = list(0, 20, 40, 60, 80, 100)
	cap_on = FALSE
	can_have_cap = FALSE
	cap_icon_state = null
