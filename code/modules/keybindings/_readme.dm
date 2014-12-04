/*
	This whole system is heavily based off of forum_account's keyboard library. As in I copied and
	pasted it and then tweaked it to fit our needs. So thanks to forum_account for saving the day.

	.dmf macros have some very serious shortcomings. For example, they do not allow reusing parts
	of one macro in another, so giving cyborgs their own shortcuts to swap active module couldn't
	inherit the movement that all mobs should have anyways. The webclient only supports one macro,
	so having more than one was problematic. Additionally each keybind has to call an actual
	verb, which meant a lot of hidden verbs that just call one other proc. Also our existing
	macro was really bad and tied unrelated behavior into Northeast(), Southeast(), Northwest(),
	and Southwest().

	The basic premise of this system is to not screw with .dmf macros at all
	and handle pressing those keys in the code instead. We automatically have every key
	call client.key_down() or client.key_up() with the pressed key as an argument. Certain keys get
	processed directly by the client because they should be doable at any time, then we call
	key_down() or key_up() on the client's holder and the client's mob's focus.
	By default mob.focus is the mob itself, but you can set it to any datum to give control of a
	client's keypresses to another object. This would be a good way to handle a menu or driving
	a mech. We can also set client.focus = null to disregard the client's keypresses, removing
	the need for hacky solutions like buckling people into a chair in the gameticker while a nuke
	explosion goes off.

	Movement is handled by having each client make a ticker that calls client.key_loop() every game tick.
	As above, this calls holder and focus.key_loop(). This loop handles movement and should
	handle anything else that needs to repeat, although try to keep the calculations in this
	proc light. It runs every tick for every client, after all!

	You can also tell which keys are being held down now. Each client has two lists, keys_held
	and keys_active. keys_held has all the keys currently being held while keys_active has any
	that were held down for any length of time in the current tick. Normally these two will be
	the same list but generally speaking use keys_active so short keypresses don't get discarded.

	I didn't do client-set keybindings at this time, but it shouldn't be too hard if someone wants.
	Also on the docket is improving client-initiated movement a lot better to get all the logic
	out of Client/Move() and into key_loop().
*/