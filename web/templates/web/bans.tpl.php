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
<fieldset>
	<legend>New Ban</legend>
	<p>Add a new ban.</p>
<?
	$form = new Form(fmtURL('bans'),'post','banform');
	$form->addHidden('s', $this->session->id);
	$table = new Table();
	$row = $table->createRow();
		$row->createCell()->addLabel('Type:','banType');
		$row->createCell()->addSelect('banType',$this->bantypes);
	$row = $table->createRow();
		$row->createCell()->addLabel('Ckey:','banCKey');
		$row->createCell()->addTextbox('banCKey',$_GET['ckey'],array('id'=>'banCKey'))
		 				  ->addButton('button','getlast','Find Last CID/IP',null,array('id'=>'getlast'));
	$row = $table->createRow();
		$row->createCell()->addLabel('IP:','banIP');
		$row->createCell()->addTextbox('banIP',$_GET['ip'],array('id'=>'banIP'));
	$row = $table->createRow();
		$row->createCell()->addLabel('CID:','banCID');
		$row->createCell()->addTextbox('banCID',$_GET['cid'],array('id'=>'banCID'));
	$row = $table->createRow();
		$row->createCell()->addLabel('Reason:','banReason');
		$row->createCell()->addTextarea('banReason');
	$row = $table->createRow();
		$row->createCell()->addLabel('Jobs:', 'banJobs');
		$tagitCell = $row->createCell();
			$tagitCell->addBreak();
			$tagitCell->addChild(new Element('b',array(),'Presets:'));
			$tagitCell->addChild(' ');
			foreach(Jobs::$Categories as $name=>$jobs) {
				$js='';
				foreach($jobs as $job)
					$js.="$('#banJobs').tagit('createTag','{$job}');";
				$tagitCell->addBookmarklet($name,$js);
				$tagitCell->addChild(' ');
			}
			$tagitCell->addBookmarklet('Clear','$(\'#banJobs\').tagit(\'removeAll\');');
			$ul=new Element('ul',array('class'=>'jobs','id'=>'banJobs'));
			$tagitCell->addChild($ul);
	$row = $table->createRow();
		$row->createCell()->addLabel('Duration (minutes):','banDuration');
		$row->createCell()->addTextbox('banDuration','0')
		 	->addPlus('banform', 'banDuration',60,			'+1h',array('class'=>'buttstyle'))
		 	->addPlus('banform', 'banDuration',60*24,		'+1d',array('class'=>'buttstyle'))
		 	->addPlus('banform', 'banDuration',60*24*7,	    '+1w',array('class'=>'buttstyle'))
		 	->addPlus('banform', 'banDuration',60*24*30,	'+1M',array('class'=>'buttstyle'));
	$table->createRow()
		->createCell('',array('colspan'=>2))
			->addSubmit('');
	echo $form->addChild($table);
	/*
	echo $form->addHidden('s', $this->session->id)
		 ->addLabel('Type:','banType')->addSelect('banType',$types)->addBreak()
		 ->addLabel('Ckey:','banCKey')->addTextbox('banCKey',$_GET['ckey'],array('id'=>'banCKey'))
		 	->addButton('button','getlast','Find Last CID/IP',null,array('id'=>'getlast'))->addBreak()
		 ->addLabel('IP:','banIP')->addTextbox('banIP',$_GET['ip'],array('id'=>'banIP'))
		 	->addLabel('CID:','banCID')->addTextbox('banCID',$_GET['cid'],array('id'=>'banCID'))->addBreak()
		 ->addLabel('Reason:','banReason')->addTextarea('banReason')->addBreak()
		 ->addLabel('Duration (minutes):','banDuration')->addTextbox('banDuration','0')
		 	->addPlus('banDuration',60,			'+1h')
		 	->addPlus('banDuration',60*24,		'+1d')
		 	->addPlus('banDuration',60*24*7,	'+1w')
		 	->addPlus('banDuration',60*24*30,	'+1M')
		 	->addBreak()
		 ->addSubmit('');
	*/
?>
</fieldset>
<?endif;?>
<h1>Bans</h1>
<form action="<?=fmtURL('bans')?>" method="post">
	<?if($this->session):?>
	<input type="hidden" name="s" value="<?=$this->session->id?>" />
	<?endif;?>
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