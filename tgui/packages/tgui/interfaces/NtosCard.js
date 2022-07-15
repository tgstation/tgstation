import { useBackend, useSharedState } from '../backend';
import { Box, Button, Dropdown, Input, NoticeBox, NumberInput, Section, Stack, Tabs } from '../components';
import { NtosWindow } from '../layouts';
import { AccessList } from './common/AccessList';

export const NtosCard = (props, context) => {
  return (
    <NtosWindow width={500} height={670}>
      <NtosWindow.Content scrollable>
        <NtosCardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCardContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authenticatedUser,
    regions = [],
    access_on_card = [],
    has_id,
    have_id_slot,
    wildcardSlots,
    wildcardFlags,
    trimAccess,
    accessFlags,
    accessFlagNames,
    showBasic,
    templates = {},
  } = data;

  if (!have_id_slot) {
    return (
      <NoticeBox>
        This program requires an ID slot in order to function
      </NoticeBox>
    );
  }

  const [selectedTab] = useSharedState(context, 'selectedTab', 'login');

  return (
    <>
      <Stack>
        <Stack.Item>
          <IDCardTabs />
        </Stack.Item>
        <Stack.Item width="100%">
          {(selectedTab === 'login' && <IDCardLogin />) ||
            (selectedTab === 'modify' && <IDCardTarget />)}
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
          }>
          <TemplateDropdown templates={templates} />
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

const IDCardTabs = (props, context) => {
  const [selectedTab, setSelectedTab] = useSharedState(
    context,
    'selectedTab',
    'login'
  );

  return (
    <Tabs vertical fill>
      <Tabs.Tab
        minWidth={'100%'}
        altSelection
        selected={'login' === selectedTab}
        color={'login' === selectedTab ? 'green' : 'default'}
        onClick={() => setSelectedTab('login')}>
        Login ID
      </Tabs.Tab>
      <Tabs.Tab
        minWidth={'100%'}
        altSelection
        selected={'modify' === selectedTab}
        color={'modify' === selectedTab ? 'green' : 'default'}
        onClick={() => setSelectedTab('modify')}>
        Target ID
      </Tabs.Tab>
    </Tabs>
  );
};

export const IDCardLogin = (props, context) => {
  const { act, data } = useBackend(context);
  const { authenticatedUser, has_id, have_printer, authIDName } = data;

  return (
    <Section
      title="Login"
      buttons={
        <>
          <Button
            icon="print"
            content="Print"
            disabled={!have_printer || !has_id}
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
      }>
      <Stack wrap="wrap">
        <Stack.Item width="100%">
          <Button
            fluid
            ellipsis
            icon="eject"
            content={authIDName}
            onClick={() => act('PRG_ejectauthid')}
          />
        </Stack.Item>
        <Stack.Item width="100%" mt={1} ml={0}>
          Login: {authenticatedUser || '-----'}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const IDCardTarget = (props, context) => {
  const { act, data } = useBackend(context);
  const { authenticatedUser, id_rank, id_owner, has_id, id_name, id_age } =
    data;

  return (
    <Section title="Modify ID">
      <Button
        width="100%"
        ellipsis
        icon="eject"
        content={id_name}
        onClick={() => act('PRG_ejectmodid')}
      />
      {!!(has_id && authenticatedUser) && (
        <>
          <Stack mt={1}>
            <Stack.Item align="center">Details:</Stack.Item>
            <Stack.Item grow={1} mr={1} ml={1}>
              <Input
                width="100%"
                value={id_owner}
                onInput={(e, value) =>
                  act('PRG_edit', {
                    name: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                value={id_age || 0}
                unit="Years"
                minValue={17}
                maxValue={85}
                onChange={(e, value) => {
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
                onInput={(e, value) =>
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

const TemplateDropdown = (props, context) => {
  const { act } = useBackend(context);
  const { templates } = props;

  const templateKeys = Object.keys(templates);

  if (!templateKeys.length) {
    return;
  }

  return (
    <Stack>
      <Stack.Item grow>
        <Dropdown
          width="100%"
          displayText={'Select a template...'}
          options={templateKeys.map((path) => {
            return templates[path];
          })}
          onSelected={(sel) =>
            act('PRG_template', {
              name: sel,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
};
