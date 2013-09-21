<?php

class admins_handler extends BaseHandler {
	public $parent = '/';
	public $description = "Admins";
	public $image = "/img/admins.png";

	public function OnBody() {
		global $tpl, $db,$ADMIN_FLAGS;
		//$db->debug=true;
		$res = $db->Execute("SELECT * FROM erro_admin ORDER BY rank,ckey");
		$tpl->assign('admins',$res);
		$tpl->assign('ADMIN_FLAGS',$ADMIN_FLAGS);
		return $tpl->fetch('web/admins.tpl.php');
	}
}
$ACT_HANDLERS['web_admins'] = new admins_handler;