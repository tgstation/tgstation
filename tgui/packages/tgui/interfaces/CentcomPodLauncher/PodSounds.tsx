import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SOUNDS } from './constants';
import type { PodLauncherData } from './types';

export function PodSounds(props) {
  const { act, data } = useBackend<PodLauncherData>();
  const { defaultSoundVolume, soundVolume } = data;

  return (
    <Section
      buttons={
        <Button
          color="transparent"
          icon="volume-up"
          onClick={() => act('soundVolume')}
          selected={soundVolume !== defaultSoundVolume}
          tooltip={`Sound Volume:${soundVolume}`}
          tooltipPosition="top-start"
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
          tooltipPosition="top-start"
        >
          {sound.title}
        </Button>
      ))}
    </Section>
  );
}
