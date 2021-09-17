/*This is the sound_player component. It can be attached to any datum and register any signal to play the sound(s) you want, when you want. Used for the honk virus as an example
	Usage :
		target.AddComponent(/datum/component/sound_player, args)
	Arguments :
		custom_volume : Used to define a custom volume. Default : 30
		custom_sounds : Used to define a list of custom sounds that will be picked at random when play_sound() is triggered. Default : list('sound/items/bikehorn.ogg')
		amount : Used to define an amount of time the component will work before deleting itself. Default : -1
		signal_or_sig_list : Used to register the signal(s) you want to play the sound when they are sent. Default : None
*/
/datum/component/sound_player
	var/volume = 30
	var/list/sounds = list('sound/items/bikehorn.ogg')
	var/amount_left = -1

/datum/component/sound_player/Initialize(custom_volume, custom_sounds, amount, signal_or_sig_list)
	if(!isnull(custom_volume))
		volume = custom_volume

	if(!isnull(custom_sounds))
		sounds = custom_sounds

	if(!isnull(amount))
		amount_left = amount

	RegisterSignal(parent, signal_or_sig_list, .proc/play_sound) //Registers all the signals in signal_or_sig_list.



/*play_sound() os the proc that actually plays the sound.
	If amount_left is equal to -1, the component is infinite and will never delete itself.
*/
/datum/component/sound_player/proc/play_sound()
	SIGNAL_HANDLER
	playsound(parent, pickweight(sounds), volume, TRUE)
	switch(amount_left)
		if(-1)
			return
		if(1) //Last use.
			qdel(src)
			return
		else
			amount_left --
