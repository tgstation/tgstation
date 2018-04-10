#define TOOL_COOKBOOK 		"cookbook"

/obj/item/book/cookbook
	name = "generic russian cookbook"
	desc = "Обычная книга с надписью <<Русская кухня>> - Содержит пошаговые инструкции сборки различного самодельного снаряжения из металла, клея и бутылки водки."
	icon_state ="demonomicon"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Forces beyond your comprehension"
	unique = 1
	title = "the Russian Cookbook"
	tool_behaviour = TOOL_COOKBOOK
	dat = {"<html><body>
	<img src=https://pp.userapi.com/c306902/v306902481/11e6/7YOW5xnctHU.jpg>
	<br>
	<img src=https://pp.userapi.com/c306902/v306902481/1257/5swZEHEzVCs.jpg>
	<br>
	<img src=https://pp.userapi.com/c306902/v306902481/142e/YlRwVsqEQbY.jpg>
	<br>
	<img src=https://pp.userapi.com/c306902/v306902481/1480/6oFGL30v8DA.jpg>
	<br>
	<img src=https://pp.userapi.com/c306903/v306903481/2a80/074GF0u69Bo.jpg>
	<br>
	<img src=https://pp.userapi.com/c306903/v306903481/2cad/0TMt0vRWFEk.jpg>
	<br>
	<img src=https://pp.userapi.com/c319529/v319529481/227a/g0QZqwKnwIM.jpg>
	</body>
	</html>"}

/datum/uplink_item/cookbook
	name = "Cookbook"
	category = "Devices and Tools"
	desc = "Очень интересная и познавательная книга."
	item = /obj/item/book/cookbook
	cost = 5
	surplus = 10