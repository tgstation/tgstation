import { toFixed } from 'common/math';
import { Flex, Icon, Knob } from 'tgui/components';
import { useSettings } from '../settings';

export const NowPlayingWidget = (props, context) => {
  const settings = useSettings(context);
  return (
    <Flex align="center">
      <Flex.Item mr={2} color="label">
        Playing
      </Flex.Item>
      <Flex.Item>
        <Knob
          minValue={0}
          maxValue={1}
          value={settings.adminMusicVolume}
          size={0.85}
          step={0.0025}
          stepPixelSize={1}
          format={value => toFixed(value * 100) + '%'}
          onDrag={(e, value) => settings.update({
            adminMusicVolume: value,
          })} />
      </Flex.Item>
    </Flex>
  );
};
