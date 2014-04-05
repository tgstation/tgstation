<?php
/**
 *
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `polltype` varchar(16) NOT NULL DEFAULT 'OPTION',
 `starttime` datetime NOT NULL,
 `endtime` datetime NOT NULL,
 `question` varchar(255) NOT NULL,
 `adminonly` tinyint(1) DEFAULT '0',
 */
class Poll {
	// erro_poll_question
	public $ID = -1;
	public $question = '';
	public $type = '';
	public $start = 0;
	public $end = 0;

	// erro_poll_options
	public $options = array();

	public function __construct($row = null) {
		if (is_array($row)) {
			$this->ID = intval($row['id']);
			$this->question = $row['question'];
			$this->type = $row['polltype'];
			$this->start = $row['starttime'];
			$this->end = $row['endtime'];
			$this->adminonly = $row['adminonly'];
		}
	}

	public function Save() {
		global $db;
		$row = array();
		if ($this->ID > -1)
			$row['id'] = $this->ID;
		$row['question'] = $this->question;
		$row['polltype'] = $this->type;
		$row['starttime'] = $this->start;
		$row['endtime'] = $this->end;
		$row['adminonly'] = intval($this->adminonly);
		if ($this->ID == -1)
			doInsertSQL('erro_poll_question', $row);
		else
			doUpdateSQL('erro_poll_question', $row, 'id=' . intval($this->ID));
	}

	public static function GetByID($id) {
		global $db;
		$res = $db->Execute('SELECT * FROM erro_poll_question WHERE id=?', array($id));
		if (!$res)
			return null;
		foreach ($res as $row) {
			return new Poll($row);
		}
		return null;
	}

	public function GetVotes() {
		/*
		 `id` int(11) NOT NULL AUTO_INCREMENT,
		 `datetime` datetime NOT NULL,
		 `pollid` int(11) NOT NULL,
		 `optionid` int(11) NOT NULL,
		 `ckey` varchar(255) NOT NULL,
		 `ip` varchar(16) NOT NULL,
		 `adminrank` varchar(32) NOT NULL,
		 `rating` int(2) DEFAULT NULL,
		 */
		switch($this->type) {
			//Polls that have enumerated options
			case "OPTION" :
			case "MULTICHOICE": // I think
				return $this->GetVotesForOption();
			case "NUMVAL" :
				return $this->GetVotesForNumVal();
			case "TEXT" :
				return $this->GetVotesForText();
		}
		return null;
	}

	public function LoadOptions() {
		global $db;
		$res = $db->Execute('SELECT * FROM erro_poll_option WHERE pollid=?', array($this->ID));
		foreach ($res as $row) {
			$opt = new PollOption($row);
			$this->options[$opt->ID] = $opt;
		}
	}

	public function GetVotesForOption() {
		global $db;
		$_res = $db->Execute('SELECT id FROM erro_poll_option WHERE pollid=?', array($this->ID));
		if(!$_res)
			return null;
		$results = array();
		$results['total'] = 0;
		$results['winner'] = 0;
		$res = $db->Execute('SELECT COUNT(*) as count, optionid FROM erro_poll_vote WHERE pollid=? GROUP BY optionid', array($this->ID));
		if (!$res)
			return null;
		foreach ($_res as $_row)
		{
			$optID = intval($_row['id']);
			foreach ($res as $row) {
				if($optID != intval($row['optionid']))
					continue;
				$optCount = intval($row['count']);
				if ($optCount > $results['winner'])
					$results['winner'] = $optCount;
				$results[$optID] = $optCount;
				$results['total'] += $optCount;
			}
			if(!array_key_exists($optID, $results))
				$results[$optID] = 0;
		}
		return $results;
	}

	public function GetVotesForNumVal() {
		global $db;
		$res = $db->Execute('SELECT COUNT(*) as count, optionid, rating FROM erro_poll_vote WHERE pollid=? GROUP BY optionid, rating', array($this->ID));
		if (!$res)
			return null;
		$results = array();
		foreach ($res as $row) {
			$optID = intval($row['optionid']);
			$opt = $this->options[$optID];
			$optCount = intval($row['count']);
			$rating = intval($row['rating']);
			if ($opt->maxVal >= $rating && $opt->minVal <= $rating) {
				if (!array_key_exists($optID, $results)) {
					$results[$optID] = array('total' => 0, 'winner' => 0);
				}
				if ($optCount > $results[$optID]['winner'])
					$results[$optID]['winner'] = $optCount;
				$results[$optID][$rating] = $optCount;
				$results[$optID]['total'] += $optCount;
			}
		}
		return $results;
	}

	public function GetVotesForText() {
		global $db;
		/*
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` varchar(18) NOT NULL,
  `replytext` text NOT NULL,
  `adminrank` varchar(32) NOT NULL DEFAULT 'Player',
		 */
		$res = $db->Execute('SELECT replytext,ckey FROM erro_poll_textreply WHERE pollid=?', array($this->ID));
		if (!$res)
			return null;
		$results = array();
		foreach ($res as $row) {
			$results[$row['ckey']]=$row['replytext'];
		}
		return $results;
	}

}

/*
 *
 `id` int(11) NOT NULL AUTO_INCREMENT,
 `pollid` int(11) NOT NULL,
 `text` varchar(255) NOT NULL,
 `percentagecalc` tinyint(1) NOT NULL DEFAULT '1',
 `minval` int(3) DEFAULT NULL,
 `maxval` int(3) DEFAULT NULL,
 `descmin` varchar(32) DEFAULT NULL,
 `descmid` varchar(32) DEFAULT NULL,
 `descmax` varchar(32) DEFAULT NULL,
 */
class PollOption {
	// erro_poll_options
	public $ID = 0;
	public $pollID = 0;
	public $text = '';
	public $calculated = 1;
	// ?
	public $minVal = 0;
	public $maxVal = 0;

	// WHAT
	public $descMin = '';
	public $descMid = '';
	public $descMax = '';

	public function __construct($row = null) {
		if (is_array($row)) {
			$this->ID = intval($row['id']);
			$this->pollID = intval($row['pollid']);
			$this->text = $row['text'];
			$this->calculated = intval($row['percentagecalc']);

			$this->minVal = $row['minval'];
			$this->maxVal = $row['maxval'];

			$this->descMin = $row['descmin'];
			$this->descMid = $row['descmid'];
			$this->descMax = $row['descmax'];
		}
	}

	public function Save() {
		global $db;
		$row = array();
		if ($this->ID > -1)
			$row['id'] = $this->ID;
		$row['pollid'] = $this->pollID;
		$row['text'] = $this->text;
		$row['percentagecalc'] = intval($this->calculated);

		$row['minval'] = $this->minVal;
		$row['maxval'] = $this->maxVal;

		$row['descmin'] = $this->descMin;
		$row['descmid'] = $this->descMid;
		$row['descmax'] = $this->descMax;
		if ($this->ID == -1)
			doInsertSQL('erro_poll_option', $row);
		else
			doUpdateSQL('erro_poll_option', $row, 'id=' . intval($this->ID));
	}

	public static function GetByID($id) {
		global $db;
		$res = $db->Execute('SELECT * FROM erro_poll_option WHERE id=?', array($id));
		if (!$res)
			return null;
		foreach ($res as $row) {
			return new Poll($row);
		}
		return null;
	}

}
