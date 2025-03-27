import { useBackend } from 'tgui/backend';
import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { Data } from './types';

/** Displays loaded container info, if it exists */
export const BeakerDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_beaker, beaker, has_blood } = data;
  const cant_empty = !has_beaker || !beaker?.volume;
  let content;
  if (!has_beaker) {
    content = <NoticeBox>No beaker loaded.</NoticeBox>;
  } else if (!beaker?.volume) {
    content = <NoticeBox>Beaker is empty.</NoticeBox>;
  } else if (!has_blood) {
    content = <NoticeBox>No blood sample loaded.</NoticeBox>;
  } else {
    content = (
      <Stack vertical>
        <Stack.Item>
          <Info />
        </Stack.Item>
        <Stack.Item>
          <Antibodies />
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Section
      title="Beaker"
      buttons={
        <>
          <Button
            icon="times"
            content="Empty and Eject"
            color="bad"
            disabled={cant_empty}
            onClick={() => act('empty_eject_beaker')}
          />
          <Button
            icon="trash"
            content="Empty"
            disabled={cant_empty}
            onClick={() => act('empty_beaker')}
          />
          <Button
            icon="eject"
            content="Eject"
            disabled={!has_beaker}
            onClick={() => act('eject_beaker')}
          />
        </>
      }
    >
      {content}
    </Section>
  );
};

/** Displays info about the blood type, beaker capacity - volume */
const Info = (props) => {
  const { data } = useBackend<Data>();
  const { beaker, blood } = data;
  if (!beaker || !blood) {
    return <NoticeBox>No beaker loaded</NoticeBox>;
  }

  return (
    <Stack>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label="DNA">
            {capitalizeFirst(blood.dna)}
          </LabeledList.Item>
          <LabeledList.Item label="Type">
            {capitalizeFirst(blood.type)}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item grow={2}>
        <LabeledList>
          <LabeledList.Item label="Container">
            <ProgressBar
              color="darkred"
              value={beaker.volume}
              minValue={0}
              maxValue={beaker.capacity}
              ranges={{
                good: [beaker.capacity * 0.85, beaker.capacity],
                average: [beaker.capacity * 0.25, beaker.capacity * 0.85],
                bad: [0, beaker.capacity * 0.25],
              }}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

/** If antibodies are present, returns buttons to create vaccines */
const Antibodies = (props) => {
  const { act, data } = useBackend<Data>();
  const { is_ready, resistances = [] } = data;
  if (!resistances) {
    return <NoticeBox>Nothing detected</NoticeBox>;
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Antibodies">
        {!resistances.length
          ? 'None'
          : resistances.map((resistance) => {
              return (
                <Button
                  key={resistance.name}
                  icon="eye-dropper"
                  disabled={!is_ready}
                  tooltip="Creates a vaccine bottle."
                  onClick={() =>
                    act('create_vaccine_bottle', {
                      index: resistance.id,
                    })
                  }
                >
                  {`${resistance.name}`}
                </Button>
              );
            })}
      </LabeledList.Item>
    </LabeledList>
  );
};
