<?php

class poll_handler extends BaseHandler {
	public $parent = '';
	public $description = "Bans";
	public $image = "/img/admins.png";

	// /poll == list of polls
	// /poll/1 == Poll details
	public function OnBody() {
		global $tpl, $db, $ADMIN_FLAGS;
		$validPollTypes = array('OPTION','NUMVAL','TEXT','MULTICHOICE');
/*
		if (count($_POST) > 0 && $this->sess != false) {
			if (array_key_exists('unban', $_POST)) {
				foreach (explode(',',$_POST['unban']) as $id)
					$db->Execute('DELETE FROM erro_ban WHERE id=?', array(intval($id)));

			}
			if (array_key_exists('banType', $_POST)) {
				$ban = array();
				$ban['type'] = $types[intval($_POST['banType'])];
				$ban['ckey'] = $_POST['banCKey'];
				$ban['reason'] = $_POST['banReason'];
				$ban['ip'] = $_POST['banIP'];
				$ban['cid'] = intval($_POST['banCID']);
				$ban['duration'] = intval($_POST['banDuration']);
				$ban['job'] = $_POST['jobs'];
				$sql = <<<SQL
INSERT INTO 
	erro_ban 
SET 
	bantime=NOW(),
	serverip='[Website Panel]',
	bantype=?,
	reason=?,
	job=?,
	duration=?,
	rounds=1,
	expiration_time=DATE_ADD(NOW(), INTERVAL ? MINUTE),
	ckey=?,
	computerid=?,
	ip=?,
	a_ckey=?,
	a_computerid=?,
	a_ip=?,
	who='LOLIDK',
	adminwho='LOLIDK'
SQL;
				if ($ban['type'] == 'JOB_TEMPBAN' || $ban['type'] == 'JOB_PERMABAN') {
					//var_dump($ban['job']);
					//exit();
					foreach ($ban['job'] as $job) {
						$args = array($ban['type'], $ban['reason'], $job, $ban['duration'], $ban['duration'], $ban['ckey'], $ban['cid'], $ban['ip'], $this->sess->ckey, '', $_SERVER['REMOTE_ADDR'], );

						//$db->debug=true;
						$db->Execute($sql, $args);
						//$db->debug=false;
					}
				} else {
					$args = array($ban['type'], $ban['reason'], '', $ban['duration'], $ban['duration'], $ban['ckey'], $ban['cid'], $ban['ip'], $this->sess->ckey, '', $_SERVER['REMOTE_ADDR'], );

					$db->Execute($sql, $args);
				}
			}
		}
*/
		//$db->debug=true;
		if(count($this->path)==1){
			$res = $db->Execute("SELECT * FROM erro_poll_question ORDER BY id DESC");
			if (!$res)
				die('MySQL Error: ' . $db->ErrorMsg());
			$tpl->assign('polls', $res);
			$tpl->assign('validPollTypes', $validPollTypes);
			return $tpl->fetch('web/polls/list.tpl.php');
		}
		else if(count($this->path)>1){
			$pollID=intval($this->path[1]);
			$poll = Poll::GetByID($pollID);
			if (!$poll)
				die('Unable to find poll ' .$pollID);
			$tpl->assign('poll', $poll);
			return $tpl->fetch('web/polls/'.strtolower($poll->type).'.tpl.php');
		}
	}

	public function OnHeader() {
		return '';
	}

}

$ACT_HANDLERS['web_poll'] = new poll_handler;
