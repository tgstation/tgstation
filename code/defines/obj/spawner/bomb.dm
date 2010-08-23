/obj/spawner/bomb
	name = "bomb"
	icon = 'screen1.dmi'
	icon_state = "x"
	var/btype = 0  //0 = radio, 1= prox, 2=time
	var/explosive = 1	// 0= firebomb
	var/btemp = 500	// bomb temperature (degC)
	var/active = 0

/obj/spawner/bomb/radio
	btype = 0

/obj/spawner/bomb/proximity
	btype = 1

/obj/spawner/bomb/timer
	btype = 2

/obj/spawner/bomb/timer/syndicate
	btemp = 450

/obj/spawner/bomb/suicide
	btype = 3

/obj/spawner/newbomb
	name = "bomb"
	icon = 'screen1.dmi'
	icon_state = "x"
	var/btype = 0 // 0=radio, 1=prox, 2=time
	var/btemp1 = 1500
	var/btemp2 = 1000	// tank temperatures

	timer
		btype = 2

		syndicate
			btemp1 = 150
			btemp2 = 20

	proximity
		btype = 1

	radio
		btype = 0