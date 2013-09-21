<?php

class homepage_handler extends BaseHandler {
	public $parent = '/';
	public $description = "Home page";
	public $image = "/img/home.png";

	public function OnBody() {
		global $tpl, $db, $ALLOWED_TAGS;
		return $tpl->fetch('web/home.tpl.php');
	}

}

$ACT_HANDLERS['web_home'] = new homepage_handler;