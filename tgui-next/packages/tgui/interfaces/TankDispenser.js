import { act } from '../byond';
import { Button, LabeledList, Section } from '../components';

export const TankDispenser = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item
          label="Plasma"
          buttons={(
            <Button
              icon={data.plasma ? "square" : "square-o"}
              content="Dispense"
              disabled={!data.plasma}
              onClick={() => act(ref, "plasma")}
            />
          )}
        >
          {data.plasma}
        </LabeledList.Item>
        <LabeledList.Item
          label="Oxygen"
          buttons={(
            <Button
              icon={data.oxygen ? "square" : "square-o"}
              content="Dispense"
              disabled={!data.oxygen}
              onClick={() => act(ref, "oxygen")}
            />
          )}
        >
          {data.oxygen}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
