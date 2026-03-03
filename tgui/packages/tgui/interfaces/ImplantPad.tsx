import {
  Button,
  Collapsible,
  Divider,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  has_case: BooleanLike;
  has_implant: BooleanLike;
  case_information: string;
  case_lore: string;
  saved_deathrattle_group?: string;
  current_deathrattle_group?: string;
};

export const ImplantPad = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    has_case,
    has_implant,
    case_information,
    case_lore,
    saved_deathrattle_group,
    current_deathrattle_group,
  } = data;
  return (
    <Window width={300} height={350}>
      <Window.Content scrollable>
        <Stack bold>
          <Stack.Item grow color="good" align="center">
            Implant Mini-Computer
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="eject"
              disabled={!has_case}
              onClick={() => act('eject_implant')}
            >
              Eject Case
            </Button>
          </Stack.Item>
        </Stack>
        <Divider />
        <Section>
          Saved Deathrattle Group: {saved_deathrattle_group || 'None'}
          <br />
          Current Deathrattle Group: {current_deathrattle_group || 'None'}
        </Section>
        <Stack>
          <Stack.Item>
            <Button
              disabled={!current_deathrattle_group}
              onClick={() => act('save_deathrattle_group')}
            >
              Save Group
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!!current_deathrattle_group || !has_case}
              onClick={() => act('set_deathrattle_group')}
            >
              Set Group
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!!current_deathrattle_group || !has_case}
              // in case you want to start a new deathrattle group
              onClick={() => act('init_deathrattle_group')}
            >
              Initialize Group
            </Button>
          </Stack.Item>
        </Stack>
        <Divider />
        <Collapsible open={true} title="Implant Information">
          {!has_case && (
            <Section>
              No implant case detected. Please insert one to see its contents.
            </Section>
          )}
          {!!has_case && !has_implant && (
            <Section>
              Implant case does not have an implant. Please insert an implant to
              continue.
            </Section>
          )}
          {!!has_case && !!has_implant && <Section>{case_information}</Section>}
        </Collapsible>
        <Collapsible title="Implant Extended Information">
          {!has_case && (
            <Section>
              No implant case detected. Please insert one to see its contents.
            </Section>
          )}
          {!!has_case && !has_implant && (
            <Section>
              Implant case does not have an implant. Please insert an implant to
              continue.
            </Section>
          )}
          {!!has_case && !!has_implant && <Section>{case_lore}</Section>}
        </Collapsible>
      </Window.Content>
    </Window>
  );
};
