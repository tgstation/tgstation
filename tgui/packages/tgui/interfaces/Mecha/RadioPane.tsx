import { useBackend } from '../../backend';
import { Button, NumberInput, LabeledList } from '../../components';
import { OperatorData } from './data';
import { toFixed } from 'common/math';

export const RadioPane = (props, context) => {
  const { act, data } = useBackend<OperatorData>(context);
  const { microphone, speaker, minfreq, maxfreq, frequency } =
    data.mech_electronics;
  return (
    <LabeledList>
      <LabeledList.Item label="Microphone">
        <Button
          onClick={() => act('toggle_microphone')}
          selected={microphone}
          icon={microphone ? 'microphone' : 'microphone-slash'}>
          {(microphone ? 'En' : 'Dis') + 'abled'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Speaker">
        <Button
          onClick={() => act('toggle_speaker')}
          selected={speaker}
          icon={speaker ? 'volume-up' : 'volume-mute'}>
          {(speaker ? 'En' : 'Dis') + 'abled'}
        </Button>
      </LabeledList.Item>
      <LabeledList.Item label="Frequency">
        <NumberInput
          animate
          unit="kHz"
          step={0.2}
          stepPixelSize={6}
          minValue={minfreq / 10}
          maxValue={maxfreq / 10}
          value={frequency / 10}
          format={(value) => toFixed(value, 1)}
          width="80px"
          onDrag={(e, value) =>
            act('set_frequency', {
              new_frequency: value,
            })
          }
        />
      </LabeledList.Item>
    </LabeledList>
  );
};
