<?php
class chkban_handler extends BaseHandler {
	public $parent = '';
	public $description = "Check for Bans";

	public function OnBody() {
		global $tpl, $db;
		//$db->debug=true;
		$ipsql='';
		$cidsql='';
		$args=array();
		
		$ckey=$_GET['ckey'];
		$args[]=$ckey;
		
		$ip=$_GET['ip'];
		if($ip!='')
		{
			$ipsql=' OR ip=?';
			$args[]=$ip;
		}
		
		$cid=$_GET['cid'];
		if($cid!='')
		{
			$cidsql=' OR computerid=?';
			$args[]=$cid;
		}
		$res = $db->Execute("
		SELECT
			ckey,
			ip,
			computerid,
			a_ckey,
			reason,
			expiration_time,
			duration,
			bantime,
			bantype
		FROM
			erro_ban
		WHERE
			(
				ckey = ?
				{$ipsql}
				{$cidsql}
			)
			AND
			(
				bantype = 'PERMABAN'
				OR
				(
					bantype = 'TEMPBAN'
					AND expiration_time > Now()
				)
				OR
				(
					bantype = 'CLUWNE'
					AND expiration_time > Now()
				)
			)
			AND isnull(unbanned)",
			$args);
		if(!$res)
		{
			header("HTTP/1.1 500 Internal Server Error");
			die('ERROR: '.$db->ErrorMsg());
		}
		
		foreach($res as $row) {
			$pckey = $row[0];
			$ip = $row[1];
			$pcid = $row[2];
			$ackey = $row[3];
			$reason = $row[4];
			$expiration = $row[5];
			$duration = $row[6];
			$bantime = $row[7];
			$bantype = $row[8];
	
			$expires = "";
			if(intval($duration) > 0)
				$expires = "  The ban is for {$duration} minutes and expires on {$expiration} (server time).";
	
			//header("HTTP/1.1 403 Access Denied");
			header('HTTP/1.1 302 Found');
			echo "Reason: You, or another user of this computer or connection ({$pckey}) are banned from playing here. The ban reason is:\n{$reason}\nThis ban was applied by {$ackey} on {$bantime}. {$expires}";
			exit();
		}
		echo 'OK';
		exit();
	}
}
$ACT_HANDLERS['api_chkban'] = new chkban_handler;