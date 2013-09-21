<?php
/*
  0 => string 'id' (length=2)
  1 => string 'bantime' (length=7)
  2 => string 'serverip' (length=8)
  3 => string 'bantype' (length=7)
  4 => string 'reason' (length=6)
  5 => string 'job' (length=3)
  6 => string 'duration' (length=8)
  7 => string 'rounds' (length=6)
  8 => string 'expiration_time' (length=15)
  9 => string 'ckey' (length=4)
  10 => string 'computerid' (length=10)
  11 => string 'ip' (length=2)
  12 => string 'a_ckey' (length=6)
  13 => string 'a_computerid' (length=12)
  14 => string 'a_ip' (length=4)
  15 => string 'who' (length=3)
  16 => string 'adminwho' (length=8)
  17 => string 'edits' (length=5)
  18 => string 'unbanned' (length=8)
  19 => string 'unbanned_datetime' (length=17)
  20 => string 'unbanned_ckey' (length=13)
  21 => string 'unbanned_computerid' (length=19)
  22 => string 'unbanned_ip' (length=11)
 */
$jbans=array();
$bans=array();
foreach($this->bans as $row) {
	$key=md5($row['ckey'].$row['reason']);
	switch($row['bantype']) {
		case 'JOB_TEMPBAN':
		case 'TEMPBAN':
		case 'CLUWNE':
			$row['expiration_time_php']=strtotime($row['expiration_time']);
			break;
		default:
			$row['expiration_time'] = 'PERMANENT';
			break;
	}
	if($row['expiration_time']=='PERMANENT' || $row['expiration_time_php']>time())
	{
		switch($row['bantype']) {
			case 'JOB_PERMABAN':
			case 'JOB_TEMPBAN':
				if(!array_key_exists($key, $jbans)) {
					$jbans[$key]=$row;
					$jbans[$key]['job']=array($row['job']);
					$jbans[$key]['id']=array($row['id']);
				} else {
					$jbans[$key]['job'][]=$row['job'];
					$jbans[$key]['id'][]=$row['id'];
				}
				break;
			case 'PERMABAN':
			case 'TEMPBAN':
			case 'CLUWNE':
				if(!array_key_exists($key, $bans)) {
					$bans[$key]=$row;
					$bans[$key]['job']=array($row['job']);
				} else {
					$bans[$key][]=$row['job'];
				}
				break;
		}
	}
}
?>
<?if($this->session!=false):?>
<h1>Rapsheet for <?=$this->ckey?></h1>
<form action="<?=fmtURL('bans')?>" method="post">
	<input type="hidden" name="s" value="<?=$this->session->id?>" />
<table class="fancy">
	<tr>
		<th>
			CKey
		</th>
		<th>
			Why
		</th>
		<th>
			Banning Admin
		</th>
		<th>
			Expires
		</th>
		<?if($this->session!=false):?>
		<th>
			Controls
		</th>
		<?endif;?>
	</tr>
	
<?foreach($bans as $row):
	$hasIP=!empty($row['ip']);
	$hasCID=!empty($row['computerid']);
	$hasUnbanned=!empty($row['unbanned']);
	?>
	<tr<?=($hasUnbanned?' class="unbanned"':'')?>>
		<td class="clmName">
			<span class="ckey"><?=$row['ckey']?></span>
			<?if($hasIP||$hasCID):?>
			<table class="details">
			<?if($hasIP):?>
				<tr>
					<th>IP:</th><td><?=$row['ip']?></td>
				</tr>
			<?endif;?>
			<?if($hasCID):?>
				<tr>
					<th><abbr title="Computer ID">CID</abbr>:</th><td><?=$row['computerid']?></td>
				</tr>
			<?endif;?>
			</table>
			<?endif;?>
		</td>
		<td>
			<?=nl2br($row['reason'])?>
		</td>
		<td class="clmName">
			<?=$row['a_ckey']?>
		</td>
		<td class="clmExpires">
			<?=$row['expiration_time']?>
		</td>
		<?if($this->session!=false):?>
		<td class="clmControls">
			<button name="unban" value="<?=$row['id']?>" type="submit">
				Unban
			</button>
		</td>
		<?endif;?>
	</tr>
<?endforeach;?>
</table>

<h1>Job Bans</h1>
<table>
	<tr>
		<th>
			CKey
		</th>
		<th>
			Job(s)
		</th>
		<th>
			Why
		</th>
		<th>
			Banning Admin
		</th>
		<th>
			Expires
		</th>
		<th>
			Controls
		</th>
	</tr>
<?foreach($jbans as $row):
	$hasIP=!empty($row['ip']);
	$hasCID=!empty($row['computerid']);
	?>
	<tr>
		<td class="clmName">
			<span class="ckey"><?=$row['ckey']?></span>
			<?if($hasIP||$hasCID):?>
			<table class="details">
			<?if($hasIP):?>
				<tr>
					<th>IP:</th><td><?=$row['ip']?></td>
				</tr>
			<?endif;?>
			<?if($hasCID):?>
				<tr>
					<th><abbr title="Computer ID">CID</abbr>:</th><td><?=$row['computerid']?></td>
				</tr>
			<?endif;?>
			</table>
			<?endif;?>
		</td>
		<td class="clmJobs">
			<ul>
				<?foreach($row['job'] as $job):?>
				<li>
					<a href="#"><?=$job?></a>
				</li>
				<?endforeach;?>
			</ul>
		</td>
		<td>
			<?=$row['reason']?>
		</td>
		<td class="clmName">
			<?=$row['a_ckey']?>
		</td>
		<td class="clmExpires">
			<?=$row['expiration_time']?>
		</td>
		<?if($this->session!=false):?>
		<td class="clmControls">
			<button name="unban" value="<?=implode(',',$row['id'])?>" type="submit">
				Unban
			</button>
		</td>
		<?endif;?>
	</tr>
<?endforeach;?>
</table>
</form>
<?else:?>
<h1>Access denied</h1>
<?endif;?>