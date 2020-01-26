import { multiline } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';

// This is more or less a direct port from old tgui, with some slight
// text cleanup. But yes, it actually worked like this.
export const CentcomPodLauncher = props => {
  const { act, data } = useBackend(props);
  return (
    <Fragment>
      <NoticeBox>
        To use this, simply spawn the atoms you want in one of the five
        Centcom Supplypod Bays. Items in the bay will then be launched inside
        your supplypod, one turf-full at a time! You can optionally use the
        following buttons to configure how the supplypod acts.
      </NoticeBox>
      <Section
        title="Centcom Pod Customization (To be used against Helen Weinstein)">
        <LabeledList>
          <LabeledList.Item label="Supply Bay">
            <Button
              content="Bay #1"
              selected={data.bayNumber === 1}
              onClick={() => act('bay1')} />
            <Button
              content="Bay #2"
              selected={data.bayNumber === 2}
              onClick={() => act('bay2')} />
            <Button
              content="Bay #3"
              selected={data.bayNumber === 3}
              onClick={() => act('bay3')} />
            <Button
              content="Bay #4"
              selected={data.bayNumber === 4}
              onClick={() => act('bay4')} />
            <Button
              content="ERT Bay"
              selected={data.bayNumber === 5}
              tooltip={multiline`
                This bay is located on the western edge of CentCom. Its the
                glass room directly west of where ERT spawn, and south of the
                CentCom ferry. Useful for launching ERT/Deathsquads/etc. onto
                the station via drop pods.
              `}
              onClick={() => act('bay5')} />
          </LabeledList.Item>
          <LabeledList.Item label="Teleport to">
            <Button
              content={data.bay}
              onClick={() => act('teleportCentcom')} />
            <Button
              content={data.oldArea ? data.oldArea : 'Where you were'}
              disabled={!data.oldArea}
              onClick={() => act('teleportBack')} />
          </LabeledList.Item>
          <LabeledList.Item label="Item Mode" >
            <Button
              content="Clone Items"
              selected={data.launchClone}
              tooltip={multiline`
                Choosing this will create a duplicate of the item to be
                launched in Centcom, allowing you to send one type of item
                multiple times. Either way, the atoms are forceMoved into
                the supplypod after it lands (but before it opens).
              `}
              onClick={() => act('launchClone')} />
            <Button
              content="Random Items"
              selected={data.launchRandomItem}
              tooltip={multiline`
                Choosing this will pick a random item from the selected turf
                instead of the entire turfs contents. Best combined with
                single/random turf.
              `}
              onClick={() => act('launchRandomItem')} />
          </LabeledList.Item>
          <LabeledList.Item label="Launch style">
            <Button
              content="Ordered"
              selected={data.launchChoice === 1}
              tooltip={multiline`
                Instead of launching everything in the bay at once, this
                will "scan" things (one turf-full at a time) in order, left
                to right and top to bottom. undoing will reset the "scanner"
                to the top-leftmost position.
              `}
              onClick={() => act('launchOrdered')} />
            <Button
              content="Random Turf"
              selected={data.launchChoice === 2}
              tooltip={multiline`
                Instead of launching everything in the bay at once, this
                will launch one random turf of items at a time.
              `}
              onClick={() => act('launchRandomTurf')} />
          </LabeledList.Item>
          <LabeledList.Item label="Explosion">
            <Button
              content="Custom Size"
              selected={data.explosionChoice === 1}
              tooltip={multiline`
                This will cause an explosion of whatever size you like
                (including flame range) to occur as soon as the supplypod
                lands. Dont worry, supply-pods are explosion-proof!
              `}
              onClick={() => act('explosionCustom')} />
            <Button
              content="Adminbus"
              selected={data.explosionChoice === 2}
              tooltip={multiline`
                This will cause a maxcap explosion (dependent on server
                config) to occur as soon as the supplypod lands. Dont worry,
                supply-pods are explosion-proof!
              `}
              onClick={() => act('explosionBus')} />
          </LabeledList.Item>
          <LabeledList.Item label="Damage">
            <Button
              content="Custom Damage"
              selected={data.damageChoice === 1}
              tooltip={multiline`
                Anyone caught under the pod when it lands will be dealt
                this amount of brute damage. Sucks to be them!
              `}
              onClick={() => act('damageCustom')} />
            <Button
              content="Gib"
              selected={data.damageChoice === 2}
              tooltip={multiline`
                This will attempt to gib any mob caught under the pod when
                it lands, as well as dealing a nice 5000 brute damage. Ya
                know, just to be sure!
              `}
              onClick={() => act('damageGib')} />
          </LabeledList.Item>
          <LabeledList.Item label="Effects">
            <Button
              content="Stun"
              selected={data.effectStun}
              tooltip={multiline`
                Anyone who is on the turf when the supplypod is launched
                will be stunned until the supplypod lands. They cant get
                away that easy!
              `}
              onClick={() => act('effectStun')} />
            <Button
              content="Delimb"
              selected={data.effectLimb}
              tooltip={multiline`
                This will cause anyone caught under the pod to lose a limb,
                excluding their head.
              `}
              onClick={() => act('effectLimb')} />
            <Button
              content="Yeet Organs"
              selected={data.effectOrgans}
              tooltip={multiline`
                This will cause anyone caught under the pod to lose all
                their limbs and organs in a spectacular fashion.
              `}
              onClick={() => act('effectOrgans')} />
          </LabeledList.Item>
          <LabeledList.Item label="Movement">
            <Button
              content="Bluespace"
              selected={data.effectBluespace}
              tooltip={multiline`
                Gives the supplypod an advanced Bluespace Recyling Device.
                After opening, the supplypod will be warped directly to the
                surface of a nearby NT-designated trash planet (/r/ss13).
              `}
              onClick={() => act('effectBluespace')} />
            <Button
              content="Stealth"
              selected={data.effectStealth}
              tooltip={multiline`
                This hides the red target icon from appearing when you
                launch the supplypod. Combos well with the "Invisible"
                style. Sneak attack, go!
              `}
              onClick={() => act('effectStealth')} />
            <Button
              content="Quiet"
              selected={data.effectQuiet}
              tooltip={multiline`
                This will keep the supplypod from making any sounds, except
                for those specifically set by admins in the Sound section.
              `}
              onClick={() => act('effectQuiet')} />
            <Button
              content="Reverse Mode"
              selected={data.effectReverse}
              tooltip={multiline`
                This pod will not send any items. Instead, after landing,
                the supplypod will close (similar to a normal closet closing),
                and then launch back to the right centcom bay to drop off any
                new contents.
              `}
              onClick={() => act('effectReverse')} />
            <Button
              content="Missile Mode"
              selected={data.effectMissile}
              tooltip={multiline`
                This pod will not send any items. Instead, it will immediately
                delete after landing (Similar visually to setting openDelay
                & departDelay to 0, but this looks nicer). Useful if you just
                wanna fuck some shit up. Combos well with the Missile style.
              `}
              onClick={() => act('effectMissile')} />
            <Button
              content="Any Descent Angle"
              selected={data.effectCircle}
              tooltip={multiline`
                This will make the supplypod come in from any angle. Im not
                sure why this feature exists, but here it is.
              `}
              onClick={() => act('effectCircle')} />
            <Button
              content="Machine Gun Mode"
              selected={data.effectBurst}
              tooltip={multiline`
                This will make each click launch 5 supplypods inaccuratly
                around the target turf (a 3x3 area). Combos well with the
                Missile Mode if you dont want shit lying everywhere after.
              `}
              onClick={() => act('effectBurst')} />
            <Button
              content="Specific Target"
              selected={data.effectTarget}
              tooltip={multiline`
                This will make the supplypod target a specific atom, instead
                of the mouses position. Smiting does this automatically!
              `}
              onClick={() => act('effectTarget')} />
          </LabeledList.Item>
          <LabeledList.Item label="Name/Desc">
            <Button
              content="Custom Name/Desc"
              selected={data.effectName}
              tooltip="Allows you to add a custom name and description."
              onClick={() => act('effectName')} />
            <Button
              content="Alert Ghosts"
              selected={data.effectAnnounce}
              tooltip={multiline`
                Alerts ghosts when a pod is launched. Useful if some dumb
                shit is aboutta come outta the pod.
              `}
              onClick={() => act('effectAnnounce')} />
          </LabeledList.Item>
          <LabeledList.Item label="Sound">
            <Button
              content="Custom Falling Sound"
              selected={data.fallingSound}
              tooltip={multiline`
                Choose a sound to play as the pod falls. Note that for this
                to work right you should know the exact length of the sound,
                in seconds.
              `}
              onClick={() => act('fallSound')} />
            <Button
              content="Custom Landing Sound"
              selected={data.landingSound}
              tooltip="Choose a sound to play when the pod lands."
              onClick={() => act('landingSound')} />
            <Button
              content="Custom Opening Sound"
              selected={data.openingSound}
              tooltip="Choose a sound to play when the pod opens."
              onClick={() => act('openingSound')} />
            <Button
              content="Custom Leaving Sound"
              selected={data.leavingSound}
              tooltip={multiline`
                Choose a sound to play when the pod departs (whether that be
                delection in the case of a bluespace pod, or leaving for
                centcom for a reversing pod).
              `}
              onClick={() => act('leavingSound')} />
            <Button
              content="Admin Sound Volume"
              selected={data.soundVolume}
              tooltip={multiline`
                Choose the volume for the sound to play at. Default values
                are between 1 and 100, but hey, do whatever. Im a tooltip,
                not a cop.
              `}
              onClick={() => act('soundVolume')} />
          </LabeledList.Item>
          <LabeledList.Item label="Timers">
            <Button
              content="Custom Falling Duration"
              selected={data.fallDuration !== 4}
              tooltip={multiline`
                Set how long the animation for the pod falling lasts. Create
                dramatic, slow falling pods!
              `}
              onClick={() => act('fallDuration')} />
            <Button
              content="Custom Landing Time"
              selected={data.landingDelay !== 20}
              tooltip={multiline`
                Choose the amount of time it takes for the supplypod to hit
                the station. By default this value is 0.5 seconds.
              `}
              onClick={() => act('landingDelay')} />
            <Button
              content="Custom Opening Time"
              selected={data.openingDelay !== 30}
              tooltip={multiline`
                Choose the amount of time it takes for the supplypod to open
                after landing. Useful for giving whatevers inside the pod a
                nice dramatic entrance! By default this value is 3 seconds.
              `}
              onClick={() => act('openingDelay')} />
            <Button
              content="Custom Leaving Time"
              selected={data.departureDelay !== 30}
              tooltip={multiline`
                Choose the amount of time it takes for the supplypod to leave
                after landing. By default this value is 3 seconds.
              `}
              onClick={() => act('departureDelay')} />
          </LabeledList.Item>
          <LabeledList.Item label="Style">
            <Button
              content="Standard"
              selected={data.styleChoice === 1}
              tooltip={multiline`
                Same color scheme as the normal station-used supplypods
              `}
              onClick={() => act('styleStandard')} />
            <Button
              content="Advanced"
              selected={data.styleChoice === 2}
              tooltip={multiline`
                The same as the stations upgraded blue-and-white
                Bluespace Supplypods
              `}
              onClick={() => act('styleBluespace')} />
            <Button
              content="Syndicate"
              selected={data.styleChoice === 4}
              tooltip={multiline`
                A menacing black and blood-red. Great for sending meme-ops
                in style!
              `}
              onClick={() => act('styleSyndie')} />
            <Button
              content="Deathsquad"
              selected={data.styleChoice === 5}
              tooltip={multiline`
                A menacing black and dark blue. Great for sending deathsquads
                in style!
              `}
              onClick={() => act('styleBlue')} />
            <Button
              content="Cult Pod"
              selected={data.styleChoice === 6}
              tooltip="A blood and rune covered cult pod!"
              onClick={() => act('styleCult')} />
            <Button
              content="Missile"
              selected={data.styleChoice === 7}
              tooltip={multiline`
                A large missile. Combos well with a missile mode, so the
                missile doesnt stick around after landing.
              `}
              onClick={() => act('styleMissile')} />
            <Button
              content="Syndicate Missile"
              selected={data.styleChoice === 8}
              tooltip={multiline`
                A large blood-red missile. Combos well with missile mode,
                so the missile doesnt stick around after landing.
              `}
              onClick={() => act('styleSMissile')} />
            <Button
              content="Supply Crate"
              selected={data.styleChoice === 9}
              tooltip="A large, dark-green military supply crate."
              onClick={() => act('styleBox')} />
            <Button
              content="HONK"
              selected={data.styleChoice === 10}
              tooltip="A colorful, clown inspired look."
              onClick={() => act('styleHONK')} />
            <Button
              content="~Fruit"
              selected={data.styleChoice === 11}
              tooltip="For when an orange is angry"
              onClick={() => act('styleFruit')} />
            <Button
              content="Invisible"
              selected={data.styleChoice === 12}
              tooltip={multiline`
                Makes the supplypod invisible! Useful for when you want to
                use this feature with a gateway or something. Combos well
                with the "Stealth" and "Quiet Landing" effects.
              `}
              onClick={() => act('styleInvisible')} />
            <Button
              content="Gondola"
              selected={data.styleChoice === 13}
              tooltip={multiline`
                This gondola can control when he wants to deliver his supplies
                if he has a smart enough mind, so offer up his body to ghosts
                for maximum enjoyment. (Make sure to turn off bluespace and
                set a arbitrarily high open-time if you do!
              `}
              onClick={() => act('styleGondola')} />
            <Button
              content="Show Contents (See Through Pod)"
              selected={data.styleChoice === 14}
              tooltip={multiline`
                By selecting this, the pod will instead look like whatevers
                inside it (as if it were the contents falling by themselves,
                without a pod). Useful for launching mechs at the station
                and standing tall as they soar in from the heavens.
              `}
              onClick={() => act('styleSeeThrough')} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section>
        <LabeledList>
          <LabeledList.Item
            label={data.numObjects + ' turfs in ' + data.bay}
            buttons={(
              <Fragment>
                <Button
                  content="undo Pody Bay"
                  tooltip={multiline`
                    Manually undoes the possible things to launch in the
                    pod bay.
                  `}
                  onClick={() => act('undo')} />
                <Button
                  content="Enter Launch Mode"
                  selected={data.giveLauncher}
                  tooltip="THE CODEX ASTARTES CALLS THIS MANEUVER: STEEL RAIN"
                  onClick={() => act('giveLauncher')} />
                <Button
                  content="Clear Selected Bay"
                  color="bad"
                  tooltip={multiline`
                    This will delete all objs and mobs from the selected bay.
                  `}
                  tooltipPosition="left"
                  onClick={() => act('clearBay')} />
              </Fragment>
            )} />
        </LabeledList>
      </Section>
    </Fragment>
  );
};
