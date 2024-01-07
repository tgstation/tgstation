import { multiline } from 'common/string';

import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { SOUNDS } from './constants';
import { PodLauncherData } from './types';

export function PodSounds(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { defaultSoundVolume, soundVolume } = data;

  return (
    <Section
      fill
      title="Sounds"
      buttons={
        <Button
          icon="volume-up"
          color="transparent"
          selected={soundVolume !== defaultSoundVolume}
          tooltip={
            multiline`
            Sound Volume:` + soundVolume
          }
          onClick={() => act('soundVolume')}
        />
      }
    >
      {SOUNDS.map((sound, i) => (
        <Button
          key={i}
          tooltip={sound.tooltip}
          tooltipPosition="top-end"
          selected={data[sound.act]}
          onClick={() => act(sound.act)}
        >
          {sound.title}
        </Button>
      ))}
    </Section>
  );
}
