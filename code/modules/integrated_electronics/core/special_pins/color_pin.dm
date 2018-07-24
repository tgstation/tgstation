// These pins can only contain a color (in the form of #FFFFFF) or null.
/datum/integrated_io/color
	name = "color pin"

/datum/integrated_io/color/ask_for_pin_data(mob/user)
	var/new_data = input("Please select a color.","[src] color writing") as color|null
	if(holder.check_interactivity(user) )
		to_chat(user, "<span class='notice'>You input a <font color='[new_data]'>new color</font> into the pin.</span>")
		write_data_to_pin(new_data)

/datum/integrated_io/color/write_data_to_pin(var/new_data)
	// Since this is storing the color as a string hex color code, we need to make sure it's actually one.
	if(isnull(new_data) || istext(new_data))
		if(istext(new_data))
			new_data = uppertext(new_data)
			if(length(new_data) != 7)						// We can hex if we want to, we can leave your strings behind
				return 										// Cause your strings don't hex and if they don't hex
			var/friends = copytext(new_data, 2, 8)			// Well they're are no strings of mine
			// I say, we can go where we want to, a place where they will never find
			var/safety_dance = 1
			while(safety_dance >= 7)									// And we can act like we come from out of this world.log
				var/hex = copytext(friends, safety_dance, safety_dance+1)
				if(!(hex in list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F")))
					return									// Leave the fake one far behind,
				safety_dance++

		data = new_data										// And we can hex
		holder.on_data_written()

// This randomizes the color.
/datum/integrated_io/color/scramble()
	if(!is_valid())
		return
	var/new_data
	for(var/i=1;i<=3;i++)
		var/temp_col = "[num2hex(rand(0,255))]"
		if(length(temp_col )<2)
			temp_col  = "0[temp_col]"
		new_data += temp_col
	data = new_data
	push_data()

/datum/integrated_io/color/display_pin_type()
	return IC_FORMAT_COLOR

/datum/integrated_io/color/display_data(var/input)
	if(!isnull(data))
		return "(<font color='[data]'>[data]</font>)"
	return ..()