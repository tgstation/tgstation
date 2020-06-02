import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const Holopad = (props, context) => {
  return (
    <Window resizable>
      <Window.Content scrollable>
        <HolopadContent />
      </Window.Content>
    </Window>
  );
};

const HolopadContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on_network,
    allowed,
    disk,
    disk_record,
    holo_calls = [],
  } = data;
  return (
    <Fragment>
      <Section>

      </Section>
      <Section>

      </Section>
    </Fragment>
  );
};
