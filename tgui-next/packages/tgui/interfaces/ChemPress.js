import { act } from '../byond';
import { Box, Button, LabeledList, Section } from '../components';
import { NumberInput } from '../components/NumberInput';

export const ChemPress = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    pill_size,
    pill_name,
    pill_style,
    pill_styles = [],
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Pill Volume">
          <NumberInput
            value={pill_size}
            unit="u"
            width="43px"
            minValue={5}
            maxValue={50}
            step={1}
            stepPixelSize={2}
            onChange={(e, value) => act(ref, 'change_pill_size', {volume: value})}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pill Name">
          <Button
            icon="pencil-alt"
            content={pill_name}
            onClick={() => act(ref, 'change_pill_name')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pill Style">
          {pill_styles.map(pill => (
            <Button
              key={pill.id}
              width={5}
              selected={pill.id === pill_style}
              textAlign="center"
              color="transparent"
              onClick={() => act(ref, 'change_pill_style', {id: pill.id})}
            >
              <Box mx={-1} className={pill.class_name} />
            </Button>
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
