import {
  Box,
  Button,
  Dropdown,
  Input,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { NTOSData } from '../layouts/NtosWindow';
import { AccessList } from './common/AccessList';

type Data = {
  access_on_card: Array<string | number>;
  accessFlagNames: Record<string, string>;
  accessFlags: Record<string, number>;
  hasTrim: BooleanLike;
  id_age: number;
  id_owner: string;
  id_rank: string;
  regions: Region[];
  showBasic: BooleanLike;
  templates: Record<string, string>;
  trimAccess: string[];
  wildcardFlags: Record<string, number>;
  wildcardSlots: Record<string, Slot>;
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
    access_on_card = [],
    accessFlagNames,
    accessFlags,
    authenticatedUser,
    has_id,
    regions = [],
    showBasic,
    templates = {},
    trimAccess,
    wildcardFlags,
    wildcardSlots,
    hasTrim,
  } = data;

  return (
    <>
      <Stack>
        <Stack.Item width="100%">
          <IdCardPage />
        </Stack.Item>
      </Stack>
      {!!has_id && !!authenticatedUser && (
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
          {hasTrim ? (
            <TemplateDropdown templates={templates} />
          ) : (
            'Templates require a trim already applied to the card. Please use an ID Painter to apply a trim.'
          )}
        </Section>
      )}
      <Stack mt={1}>
        <Stack.Item grow>
          {!!has_id && !!authenticatedUser && (
            <Box>
              <AccessList
                accesses={regions}
                selectedList={access_on_card}
                wildcardFlags={wildcardFlags}
                wildcardSlots={wildcardSlots}
                trimAccess={trimAccess}
                accessFlags={accessFlags}
                accessFlagNames={accessFlagNames}
                showBasic={!!showBasic}
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
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </>
  );
};

const IdCardPage = (props) => {
  const { act, data } = useBackend<Data>();
  const { authenticatedUser, id_rank, id_owner, has_id, id_age, authIDName } =
    data;

  return (
    <Section
      title={authenticatedUser ? 'Modify ID' : 'Login'}
      buttons={
        <>
          <Button
            icon="print"
            content="Print"
            disabled={!has_id}
            onClick={() => act('PRG_print')}
          />
          <Button
            icon={authenticatedUser ? 'sign-out-alt' : 'sign-in-alt'}
            content={authenticatedUser ? 'Log Out' : 'Log In'}
            color={authenticatedUser ? 'bad' : 'good'}
            onClick={() => {
              act(authenticatedUser ? 'PRG_logout' : 'PRG_authenticate');
            }}
          />
        </>
      }
    >
      <Stack wrap="wrap">
        <Stack.Item width="100%">
          <Button
            fluid
            ellipsis
            icon="eject"
            onClick={() => act('PRG_eject_id')}
          >
            {authIDName}
          </Button>
        </Stack.Item>
        <Stack.Item width="100%" mt={1} ml={0}>
          Login: {authenticatedUser || '-----'}
        </Stack.Item>
      </Stack>
      {!!(has_id && authenticatedUser) && (
        <>
          <Stack mt={1}>
            <Stack.Item align="center">Details:</Stack.Item>
            <Stack.Item grow={1} mr={1} ml={1}>
              <Input
                width="100%"
                value={id_owner}
                onChange={(e, value) =>
                  act('PRG_edit', {
                    name: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                step={1}
                value={id_age || 0}
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
                value={id_rank}
                onChange={(e, value) =>
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

  if (!templateKeys.length) {
    return <> </>;
  }

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
