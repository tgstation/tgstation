/obj/spell/blind
	name = "Blind"
	desc = "This spell temporarly blinds a single person and does not require wizard garb."

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "\blue Your eyes cry out in pain!"
	var/blind_time = 300 //in deciseconds
	var/eye_blind = 10   //I have no idea what these two do
	var/eye_blurry = 20  //but eh, they're in the code
	//I would add the ability to choose different disabilities (do ho ho), but I have no idea which bit corresponds to which disability

/obj/spell/blind/Click()
	..()

	if(!cast_check())
		return

	var/mob/M = input("Choose whom to blind", "ABRAKADABRA") as mob in oview(usr,range)

	if(!M)
		return

	invocation()

	var/obj/overlay/B = new /obj/overlay( M.loc )
	B.icon_state = "blspell"
	B.icon = 'wizard.dmi'
	B.name = "spell"
	B.anchored = 1
	B.density = 0
	B.layer = 4
	M.canmove = 0
	spawn(5)
		del(B)
		M.canmove = 1
	M << text("[message]")
	M.disabilities |= 1
	spawn(blind_time)
		M.disabilities &= ~1
	M.eye_blind = eye_blind
	M.eye_blurry = eye_blurry
	return