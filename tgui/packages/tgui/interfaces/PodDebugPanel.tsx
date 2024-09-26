import {
  Button,
  Divider,
  Icon,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Pod = {
  name: string;
  has_cell: BooleanLike;
  charge: number;
  maxcharge: number;
};
type Part = {
  ref: string;
  name: string;
  slot: string;
};
type Data = {
  pod: Pod;
  parts: Part[];
};

export const PodDebugPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { pod, parts } = data;

  return (
    <Window title="Pod Equipment Panel" theme="admin" width={500} height={700}>
      <Window.Content scrollable>
        <Section
          title={pod.name}
          buttons={
            <Button icon="pencil-alt" onClick={() => act('rename')}>
              Rename
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Charge">
              {pod.has_cell ? (
                <ProgressBar
                  value={pod.charge}
                  minValue={0}
                  maxValue={pod.maxcharge}
                >
                  {pod.charge + ' / ' + pod.maxcharge}
                </ProgressBar>
              ) : (
                <NoticeBox danger>No cell</NoticeBox>
              )}
              <Divider />
              <Button icon="pencil-alt" onClick={() => act('set_charge')}>
                Set
              </Button>
              <Button icon="eject" onClick={() => act('change_cell')}>
                Change
              </Button>
              <Button
                icon="trash"
                color="bad"
                onClick={() => act('remove_cell')}
              >
                Remove
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Current Equipment"
          buttons={
            <Button
              color="green"
              tooltip="Add a new part"
              onClick={() => act('add_part')}
            >
              <Icon name="plus" />
            </Button>
          }
        >
          <LabeledList>
            {parts.map((part) => (
              <LabeledList.Item label={part.slot} key={part.ref}>
                {part.name}
                <Button
                  tooltip="Detach this part"
                  onClick={() => act('detach_part', { partRef: part.ref })}
                >
                  <Icon name="eject" />
                </Button>
                <Button
                  tooltip="Delete this part"
                  color="bad"
                  onClick={() => act('delete_part', { partRef: part.ref })}
                >
                  <Icon name="trash" />
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
