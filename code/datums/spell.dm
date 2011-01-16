var/list/spells = list(/obj/spell/blind,/obj/spell/blink,/obj/spell/disintegrate,/obj/spell/ethereal_jaunt,/obj/spell/fireball,/obj/spell/forcewall,/obj/spell/knock,/obj/spell/magic_missile,/obj/spell/mutate,/obj/spell/teleport) //needed for the badmin verb for now

/obj/spell
	name = "Spell"
	desc = "A wizard spell"

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?
	var/recharge = 100 //recharge time in deciseconds
	var/clothes_req = 1 //see if it requires clothes
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_type = "none" //can be none, whisper and shout
	var/range = 7 //the range of the spell
	var/cast = 0 //the only way I could think of making it temporarily disable
	var/message = "derp herp" //whatever it says to the guy affected by it. not always needed

/obj/spell/proc/cast_check() //checks if the spell can be cast based on its settings, plus handles chanting and recharge
	if(!(src in usr.spell_list))
		usr << "\red You shouldn't have this spell! Something's wrong."
		return 0
	if(cast)
		usr << "[name] is still recharging."
		return 0
	if(usr.stat)
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

/obj/spell/proc/invocation() //spelling the spell out and setting it on recharge

	src.cast = 1
	var/old_name = src.name
	src.name += " (cast)"
	spawn(recharge)
		src.cast = 0
		src.name = old_name

	switch(invocation_type)
		if("shout")
			usr.say(invocation)
			if(usr.gender=="male")
				playsound(usr.loc, pick('vs_chant_conj_hm.wav','vs_chant_conj_lm.wav','vs_chant_ench_hm.wav','vs_chant_ench_lm.wav','vs_chant_evoc_hm.wav','vs_chant_evoc_lm.wav','vs_chant_illu_hm.wav','vs_chant_illu_lm.wav','vs_chant_necr_hm.wav','vs_chant_necr_lm.wav'), 100, 1)
			else
				playsound(usr.loc, pick('vs_chant_conj_hf.wav','vs_chant_conj_lf.wav','vs_chant_ench_hf.wav','vs_chant_ench_lf.wav','vs_chant_evoc_hf.wav','vs_chant_evoc_lf.wav','vs_chant_illu_hf.wav','vs_chant_illu_lf.wav','vs_chant_necr_hf.wav','vs_chant_necr_lf.wav'), 100, 1)
		if("whisper")
			usr.whisper(invocation)