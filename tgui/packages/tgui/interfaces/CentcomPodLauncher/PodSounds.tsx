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
      fill
      title="Sounds"
    >
      {SOUNDS.map((sound, i) => (
        <Button
          key={i}
          onClick={() => act(sound.act)}
          selected={data[sound.act]}
          tooltip={sound.tooltip}
          tooltipPosition="top-end"
        >
          {sound.title}
        </Button>
      ))}
    </Section>
  );
}
