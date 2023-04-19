/// Collect user input for the scroll and feed it to Assemble()
/mob/verb/Create_Scroll()

	//Background to construct the scrolling image from
	var/background_dmi = input("Pick background DMI:", "Icon") as null|icon

	//Is background a DMI?
	if(!(isfile(background_dmi) && (copytext("[background_dmi]",-4) == ".dmi")))
		world << "\red Bad background DMI file '[background_dmi]'"
		return


	//Icon to apply the scrolling animation to
	var/foreground_dmi = input("Pick foreground DMI:", "Icon") as null|icon

	//Is foreground a DMI?
	if(!(isfile(foreground_dmi) && (copytext("[foreground_dmi]",-4) == ".dmi")))
		world << "\red Bad foreground DMI file '[foreground_dmi]'"
		return


	//Mask icon to define the area of the background to use
	var/mask_dmi = input("Pick mask DMI:", "Icon") as null|icon

	//Is mask a DMI?
	if(!(isfile(mask_dmi) && (copytext("[mask_dmi]",-4) == ".dmi")))
		world << "\red Bad mask DMI file '[mask_dmi]'"
		return


	//Number of frames
	var/frames = input("Number of frames:", "Number") as null|num

	//Is frames an int?
	if(!isnum(frames))
		world << "\red Bad frames number '[frames]'"
		return
	else
		if(round(frames) != frames)
			world << "\red Non-integer frames number '[frames]'"
			return


	//Duration of each frame
	var/duration = input("Frame duration:", "Number") as null|num

	//Is duration a number?
	if(!isnum(duration))
		world << "\red Bad frame duration '[duration]'"
		return


	//Inputs look good, proceed
	Assemble(background_dmi, foreground_dmi, mask_dmi, frames, duration)
