// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer

/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	anchored = 1
	density = 0
	use_power = 1
	idle_power_usage = 10
	var/mode = 1	// 0 = Blank
					// 1 = Shuttle timer
					// 2 = Arbitrary message(s)
					// 3 = alert picture
					// 4 = Supply shuttle timer

	var/picture_state	// icon_state of alert picture
	var/message1 = ""	// message line 1
	var/message2 = ""	// message line 2
	var/index1			// display index for scrolling messages or 0 if non-scrolling
	var/index2

	var/lastdisplayline1 = ""		// the cached last displays
	var/lastdisplayline2 = ""

	var/frequency = 1435		// radio frequency
	var/supply_display = 0		// true if a supply shuttle display
	var/repeat_update = 0		// true if we are going to update again this ptick

	var/friendc = 0      // track if Friend Computer mode

	// new display
	// register for radio system
	New()
		..()
		spawn(5)	// must wait for map loading to finish
			if(radio_controller)
				radio_controller.add_object(src, frequency)


	// timed process

	process()
		if(stat & NOPOWER)
			overlays = null
			return

		update()


	// set what is displayed

	proc/update()

		if(friendc && mode!=4) //Makes all status displays except supply shuttle timer display the eye -- Urist
			set_picture("ai_friend")
			return

		if(mode==0)
			overlays = null
			return

		if(mode==3)	// alert picture, no change
			return

		if(mode==1)	// shuttle timer
			if(emergency_shuttle.online)
				var/displayloc
				if(emergency_shuttle.location == 1)
					displayloc = "ETD "
				else
					displayloc = "ETA "

				var/displaytime = get_shuttle_timer()
				if(lentext(displaytime) > 5)
					displaytime = "**~**"

				update_display(displayloc, displaytime)
				return
			else
				overlays = null
				return

		if(mode==4)		// supply shuttle timer
			var/disp1
			var/disp2
			if(supply_shuttle_moving)
				disp1 = "SPPLY"
				disp2 = get_supply_shuttle_timer()
				if(lentext(disp1) > 5)
					disp1 = "**~**"

			else
				if(supply_shuttle_at_station)
					disp1 = "SPPLY"
					disp2 = "STATN"
				else
					disp1 = "SPPLY"
					disp2 = "AWAY"

			update_display(disp1, disp2)



		if(mode==2)
			var/line1
			var/line2

			if(!index1)
				line1 = message1
			else
				line1 = copytext(message1+message1, index1, index1+5)
				if(index1++ > (lentext(message1)))
					index1 = 1

			if(!index2)
				line2 = message2
			else
				line2 = copytext(message2+message2, index2, index2+5)
				if(index2++ > (lentext(message2)))
					index2 = 1

			update_display(line1, line2)

			// the following allows 2 updates per process, giving faster scrolling
			if((index1 || index2) && repeat_update)	// if either line is scrolling
													// and we haven't forced an update yet

				spawn(5)
					repeat_update = 0
					update()		// set to update again in 5 ticks
					repeat_update = 1

	proc/set_message(var/m1, var/m2)
		if(m1)
			index1 = (lentext(m1) > 5)
			message1 = uppertext(m1)
		else
			message1 = ""
			index1 = 0

		if(m2)
			index2 = (lentext(m2) > 5)
			message2 = uppertext(m2)
		else
			message2 = null
			index2 = 0
		repeat_update = 1

	proc/set_picture(var/state)
		picture_state = state
		overlays = null
		overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)

	proc/update_display(var/line1, var/line2)

		if(line1 == lastdisplayline1 && line2 == lastdisplayline2)
			return			// no change, no need to update

		lastdisplayline1 = line1
		lastdisplayline2 = line2

		if(line2 == null)		// single line display
			overlays = null
			overlays += texticon(line1, 23, -13)
		else					// dual line display

			overlays = null
			overlays += texticon(line1, 23, -9)
			overlays += texticon(line2, 23, -17)


	// return shuttle timer as text

	proc/get_shuttle_timer()
		var/timeleft = emergency_shuttle.timeleft()
		if(timeleft)
			return "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
			// note ~ translates into a blinking :
		return ""

	proc/get_supply_shuttle_timer()
		if(supply_shuttle_moving)
			var/timeleft = round((supply_shuttle_time - world.timeofday) / 10,1)
			return "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
			// note ~ translates into a blinking :
		return ""




	// return an icon of a time text string (tn)
	// valid characters are 0-9 and :
	// px, py are pixel offsets
	proc/texticon(var/tn, var/px = 0, var/py = 0)
		var/image/I = image('icons/obj/status_display.dmi', "blank")


		var/len = lentext(tn)

		for(var/d = 1 to len)


			var/char = copytext(tn, len-d+1, len-d+2)

			if(char == " ")
				continue

			var/image/ID = image('icons/obj/status_display.dmi', icon_state=char)

			ID.pixel_x = -(d-1)*5 + px
			ID.pixel_y = py

			I.overlays += ID

		return I






	receive_signal(datum/signal/signal)

		switch(signal.data["command"])
			if("blank")
				mode = 0

			if("shuttle")
				mode = 1

			if("message")
				mode = 2
				set_message(signal.data["msg1"], signal.data["msg2"])

			if("alert")
				mode = 3
				set_picture(signal.data["picture_state"])

			if("supply")
				if(supply_display)
					mode = 4



/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = 1
	density = 0

	var/mode = 0	// 0 = Blank
					// 1 = AI emoticon
					// 2 = Blue screen of death

	var/picture_state	// icon_state of ai picture

	var/emotion = "Neutral"


	process()
		if(stat & NOPOWER)
			overlays = null
			return

		update()

	proc/update()

		if(mode==0) //Blank
			overlays = null
			return

		if(mode==1)	// AI emoticon
			switch(emotion)
				if("Very Happy")
					set_picture("ai_veryhappy")
				if("Happy")
					set_picture("ai_happy")
				if("Neutral")
					set_picture("ai_neutral")
				if("Unsure")
					set_picture("ai_unsure")
				if("Confused")
					set_picture("ai_confused")
				if("Sad")
					set_picture("ai_sad")
				if("BSOD")
					set_picture("ai_bsod")
				if("Blank")
					set_picture("ai_off")
				if("Problems?")
					set_picture("ai_trollface")
				if("Awesome")
					set_picture("ai_awesome")
				if("Dorfy")
					set_picture("ai_urist")
				if("Facepalm")
					set_picture("ai_facepalm")
				if("Friend Computer")
					set_picture("ai_friend")

			return

		if(mode==2)	// BSOD
			set_picture("ai_bsod")
			return


	proc/set_picture(var/state)
		picture_state = state
		overlays = null
		overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)
