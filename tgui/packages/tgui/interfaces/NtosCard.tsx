import {
  Button,
  Dropdown,
  Flex,
  Input,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import type { NTOSData } from '../layouts/NtosWindow';
import { AccessList } from './common/AccessList';

type CardData = {
  has_trim: BooleanLike;
  id_age: number;
  id_owner: string;
  id_rank: string;
  trim_access: string[];
  access_on_card: Array<string | number>;
  trim_assignment: string | null;
  wildcard_slots: Record<string, Slot>;
};

type Data = {
  modified_card: CardData | null;
  auth_card: CardData | null;
  authed_user: string | null;
  is_holding_id: BooleanLike;
  // static data
  access_flag_names: Record<string, string>;
  access_flags: Record<string, number>;
  regions: Region[];
  show_basic: BooleanLike;
  templates: Record<string, string>;
  wildcard_flags: Record<string, number>;
} & NTOSData;

type Region = {
  name: string;
  accesses: Access[];
};

type Access = {
  desc: string;
  ref: string;
};

type Slot = {
  limit: number;
  usage: any[];
};

export const NtosCard = (props) => {
  return (
    <NtosWindow width={500} height={670}>
      <NtosWindow.Content scrollable>
        <NtosCardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCardContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    authed_user,
    modified_card,
    templates,
    regions,
    wildcard_flags,
    access_flags,
    access_flag_names,
    show_basic,
  } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item width="100%">
            <LoginPage />
          </Stack.Item>
          <Stack.Item width="100%">
            <IdCardPage />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {!!modified_card && !!authed_user && (
        <Stack.Item>
          <Section
            title="Templates"
            mt={1}
            buttons={
              <Button
                icon="question-circle"
                tooltip={
                  'Will attempt to apply all access for the template to the ID card.\n' +
                  'Does not use wildcards unless the template specifies them.'
                }
                tooltipPosition="left"
              />
            }
          >
            {modified_card.has_trim ? (
              <TemplateDropdown templates={templates} />
            ) : (
              'Templates require a trim already applied to the card. Please use an ID Painter to apply a trim.'
            )}
          </Section>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <Stack mt={1} fill>
          <Stack.Item grow>
            {!!modified_card && !!authed_user && (
              <AccessList
                accesses={regions}
                selectedList={modified_card.access_on_card}
                wildcardFlags={wildcard_flags}
                wildcardSlots={modified_card.wildcard_slots}
                trim_access={modified_card.trim_access}
                accessFlags={access_flags}
                accessFlagNames={access_flag_names}
                showBasic={!!show_basic}
                extraButtons={
                  <Button.Confirm
                    content="Terminate Employment"
                    confirmContent="Fire Employee?"
                    color="bad"
                    onClick={() => act('PRG_terminate')}
                  />
                }
                accessMod={(ref, wildcard) =>
                  act('PRG_access', {
                    access_target: ref,
                    access_wildcard: wildcard,
                  })
                }
              />
            )}
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const LoginPage = () => {
  const { act, data } = useBackend<Data>();
  const { authed_user, auth_card, is_holding_id } = data;

  return (
    <Section>
      <Stack wrap="wrap">
        <Stack.Item grow>
          <NoticeBox info={!!authed_user}>
            {authed_user
              ? `Login: ${authed_user}`
              : 'Please log in to continue.'}
          </NoticeBox>
        </Stack.Item>
        <Stack.Item width="100%">
          <Flex>
            <Flex.Item grow mr={1}>
              <Button
                fluid
                ellipsis
                icon="eject"
                onClick={() =>
                  act(auth_card ? 'PRG_remove_main_id' : 'PRG_insert_main_id')
                }
                disabled={!auth_card && !is_holding_id}
              >
                {auth_card
                  ? `${auth_card.id_owner} (${auth_card.id_rank})`
                  : 'Insert ID'}
              </Button>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="sign-in-alt"
                color={authed_user ? 'bad' : 'good'}
                onClick={() => {
                  act(authed_user ? 'PRG_logout' : 'PRG_authenticate');
                }}
              >
                {authed_user ? 'Log Out' : 'Log In'}
              </Button>
            </Flex.Item>
          </Flex>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const IdCardPage = (props) => {
  const { act, data } = useBackend<Data>();
  const { authed_user, auth_card, modified_card, is_holding_id } = data;

  return (
    <Section>
      <Stack wrap="wrap">
        <Stack.Item width="100%">
          <Flex>
            <Flex.Item grow mr={1}>
              <Button
                fluid
                ellipsis
                icon="eject"
                onClick={() =>
                  act(modified_card ? 'PRG_remove_alt_id' : 'PRG_insert_alt_id')
                }
                disabled={!modified_card && !is_holding_id}
              >
                {modified_card
                  ? `${modified_card.id_owner} (${modified_card.id_rank})`
                  : 'Insert ID'}
              </Button>
            </Flex.Item>
            <Flex.Item>
              <Button
                icon="print"
                disabled={!modified_card || !authed_user}
                onClick={() => act('PRG_print')}
              >
                Print Report
              </Button>
            </Flex.Item>
          </Flex>
        </Stack.Item>
      </Stack>
      {!!(modified_card && authed_user) && (
        <>
          <Stack mt={1}>
            <Stack.Item align="center">Details:</Stack.Item>
            <Stack.Item grow={1} mr={1} ml={1}>
              <Input
                width="100%"
                value={modified_card.id_owner}
                onBlur={(value) =>
                  act('PRG_edit', {
                    name: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                step={1}
                value={modified_card.id_age || 0}
                unit="Years"
                minValue={17}
                maxValue={85}
                onChange={(value) => {
                  act('PRG_age', {
                    id_age: value,
                  });
                }}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item align="center">Assignment:</Stack.Item>
            <Stack.Item grow={1} ml={1}>
              <Input
                fluid
                mt={1}
                value={modified_card.id_rank}
                onBlur={(value) =>
                  act('PRG_assign', {
                    assignment: value,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </>
      )}
    </Section>
  );
};

const TemplateDropdown = (props) => {
  const { act } = useBackend<Data>();
  const { templates } = props;

  const templateKeys = Object.keys(templates);

  if (!templateKeys.length) return;

  return (
    <Stack>
      <Stack.Item grow>
        <Dropdown
          width="100%"
          placeholder="Select a template..."
          options={templateKeys.map((path) => {
            return templates[path];
          })}
          onSelected={(sel) =>
            act('PRG_template', {
              name: sel,
            })
          }
          selected="None"
        />
      </Stack.Item>
    </Stack>
  );
};
