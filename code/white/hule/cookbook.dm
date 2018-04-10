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
	<img src=https://pp.userapi.com/c306902/v306902481/142e/YlRwVsqEQbY.jpg>
	</body>
	</html>"}