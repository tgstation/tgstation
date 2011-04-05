var/list/spells = list(/obj/spell/blind,/obj/spell/blink,/obj/spell/conjure,/obj/spell/disable_tech,/obj/spell/disintegrate,/obj/spell/ethereal_jaunt,/obj/spell/fireball,/obj/spell/forcewall,/obj/spell/knock,/obj/spell/magic_missile,/obj/spell/mind_transfer,/obj/spell/mutate,/obj/spell/smoke,/obj/spell/teleport) //needed for the badmin verb for now

/obj/spell
	name = "Spell"
	desc = "A wizard spell"

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?
	var/charge_type = "recharge" //can be recharge or charges, see charge_max and charge_counter descriptions
	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"
	var/clothes_req = 1 //see if it requires clothes
	var/stat_allowed = 0 //see if it requires being conscious
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_type = "none" //can be none, whisper and shout
	var/range = 7 //the range of the spell
	var/message = "derp herp" //whatever it says to the guy affected by it. not always needed

/obj/spell/proc/cast_check() //checks if the spell can be cast based on its settings

	if(!(src in usr.spell_list))
		usr << "\red You shouldn't have this spell! Something's wrong."
		return 0

	switch(charge_type)
		if("recharge")
			if(charge_counter != charge_max)
				usr << "[name] is still recharging."
				return 0
		if("charges")
			if(!charge_counter)
				usr << "[name] has no charges left."
				return 0

	if(usr.stat && !stat_allowed)
		usr << "Not when you're incapacitated."
		return 0

	if(clothes_req) //clothes check
		if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
			usr << "I don't feel strong enough without my robe."
			return 0
		if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
			usr << "I don't feel strong enough without my sandals."
			return 0
		if(!istype(usr:head, /obj/item/clothing/head/wizard))
			usr << "I don't feel strong enough without my hat."
			return 0

	return 1

/obj/spell/proc/invocation() //spelling the spell out and setting it on recharge/reducing charges amount

	switch(invocation_type)
		if("shout")
			usr.say(invocation)
			if(usr.gender=="male")
				playsound(usr.loc, pick('vs_chant_conj_hm.wav','vs_chant_conj_lm.wav','vs_chant_ench_hm.wav','vs_chant_ench_lm.wav','vs_chant_evoc_hm.wav','vs_chant_evoc_lm.wav','vs_chant_illu_hm.wav','vs_chant_illu_lm.wav','vs_chant_necr_hm.wav','vs_chant_necr_lm.wav'), 100, 1)
			else
				playsound(usr.loc, pick('vs_chant_conj_hf.wav','vs_chant_conj_lf.wav','vs_chant_ench_hf.wav','vs_chant_ench_lf.wav','vs_chant_evoc_hf.wav','vs_chant_evoc_lf.wav','vs_chant_illu_hf.wav','vs_chant_illu_lf.wav','vs_chant_necr_hf.wav','vs_chant_necr_lf.wav'), 100, 1)
		if("whisper")
			usr.whisper(invocation)

	switch(charge_type)
		if("recharge")
			charge_counter = 0

			spawn(0)
				while(charge_counter < charge_max)
					sleep(1)
					charge_counter++
		if("charges")
			charge_counter--

/obj/spell/New()
	..()

	charge_counter = charge_max