/obj/item/integrated_electronics/debugger
	name = "circuit debugger"
	desc = "This small tool allows one working with custom machinery to directly set data to a specific pin, useful for writing \
	settings to specific circuits, or for debugging purposes.  It can also pulse activation pins."
	icon = 'icons/obj/assemblies/electronic_tools.dmi'
	icon_state = "debugger"
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	var/data_to_write = null
	var/accepting_refs = FALSE
	var/copy_values = FALSE

/obj/item/integrated_electronics/debugger/attack_self(mob/user)
	var/type_to_use = input("Please choose a type to use.","[src] type setting") as null|anything in list("string","number","ref","copy","null")
	if(!user.IsAdvancedToolUser())
		return

	var/new_data = null
	switch(type_to_use)
		if("string")
			accepting_refs = FALSE
			copy_values = FALSE
			new_data = stripped_input(user, "Now type in a string.","[src] string writing", no_trim = TRUE)
			if(istext(new_data) && user.IsAdvancedToolUser())
				data_to_write = new_data
				to_chat(user, "<span class='notice'>You set \the [src]'s memory to \"[new_data]\".</span>")
		if("number")
			accepting_refs = FALSE
			copy_values = FALSE
			new_data = input(user, "Now type in a number.","[src] number writing") as null|num
			if(isnum(new_data) && user.IsAdvancedToolUser())
				data_to_write = new_data
				to_chat(user, "<span class='notice'>You set \the [src]'s memory to [new_data].</span>")
		if("ref")
			accepting_refs = TRUE
			copy_values = FALSE
			to_chat(user, "<span class='notice'>You turn \the [src]'s ref scanner on.  Slide it across \
			an object for a ref of that object to save it in memory.</span>")
		if("copy")
			accepting_refs = FALSE
			copy_values = TRUE
			to_chat(user, "<span class='notice'>You turn \the [src]'s value copier on.  Use it on a pin \
			to save its current value in memory.</span>")
		if("null")
			data_to_write = null
			copy_values = FALSE
			to_chat(user, "<span class='notice'>You set \the [src]'s memory to absolutely nothing.</span>")

/obj/item/integrated_electronics/debugger/afterattack(atom/target, mob/living/user, proximity)
	. = ..()
	if(accepting_refs && proximity)
		data_to_write = WEAKREF(target)
		visible_message("<span class='notice'>[user] slides \a [src]'s over \the [target].</span>")
		to_chat(user, "<span class='notice'>You set \the [src]'s memory to a reference to [target.name] \[Ref\].  The ref scanner is \
		now off.</span>")
		accepting_refs = FALSE

/obj/item/integrated_electronics/debugger/proc/write_data(var/datum/integrated_io/io, mob/user)
	//If the pin can take data:
	if(io.io_type == DATA_CHANNEL)
		//If the debugger is set to copy, copy the data in the pin onto it
		if(copy_values)
			data_to_write = io.data
			to_chat(user, "<span class='notice'>You let the debugger copy the data.</span>")
			copy_values = FALSE
			return

		//Else, write the data to the pin
		io.write_data_to_pin(data_to_write)
		var/data_to_show = data_to_write
		//This is only to convert a weakref into a name for better output
		if(isweakref(data_to_write))
			var/datum/weakref/w = data_to_write
			var/atom/A = w.resolve()
			data_to_show = A.name
		to_chat(user, "<span class='notice'>You write '[data_to_write ? data_to_show : "NULL"]' to the '[io]' pin of \the [io.holder].</span>")

	//If the pin can only be pulsed
	else if(io.io_type == PULSE_CHANNEL)
		io.holder.check_then_do_work(io.ord,ignore_power = TRUE)
		to_chat(user, "<span class='notice'>You pulse \the [io.holder]'s [io].</span>")

	io.holder.interact(user) // This is to update the UI.
