import { useBackend } from '../backend';
import { Box, Button, Flex, Input, NoticeBox, NumberInput, Section, Table } from '../components';
import { NtosWindow } from '../layouts';
import { AccessList } from './common/AccessList';

export const NtosCard = (props, context) => {
  return (
    <NtosWindow
      width={500}
      height={620}>
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
    id_rank,
    id_owner,
    has_id,
    have_printer,
    have_id_slot,
    id_name,
    id_age,
    authIDName,
    hasAuthID,
    wildcardSlots,
    wildcardFlags,
    trimAccess,
    accessFlags,
    accessFlagNames,
  } = data;
  if (!have_id_slot) {
    return (
      <NoticeBox>
        This program requires an ID slot in order to function
      </NoticeBox>
    );
  }
  return (
    <>
      <Section
        title="Authentication"
        buttons={(
          <>
            <Button
              icon="print"
              content="Print"
              disabled={!have_printer || !has_id}
              onClick={() => act('PRG_print')} />
            <Button
              icon={authenticatedUser ? "sign-out-alt" : "sign-in-alt"}
              content={authenticatedUser ? "Log Out" : "Log In"}
              color={authenticatedUser ? "bad" : "good"}
              onClick={() => {
                act(authenticatedUser ? 'PRG_logout' : 'PRG_authenticate');
              }} />
          </>
        )}>
        <Flex wrap="wrap">
          <Flex.Item width="100%">
            Authorisation: {authenticatedUser || "-----"}
          </Flex.Item>
          <Flex.Item width="100%">
            <Button
              mt={1}
              fluid
              icon="eject"
              content={authIDName}
              onClick={() => act('PRG_ejectauthid')} />
          </Flex.Item>
        </Flex>
      </Section>
      <Section title="Modify ID">
        <Button
          fluid
          icon="eject"
          content={id_name}
          onClick={() => act('PRG_ejectmodid')} />
        {(has_id && authenticatedUser) && (
          <>
            <Flex mt={1}>
              <Flex.Item align="center">
                Details:
              </Flex.Item>
              <Flex.Item grow={1} mr={1} ml={1}>
                <Input
                  width="100%"
                  value={id_owner}
                  onInput={(e, value) => act('PRG_edit', {
                    name: value,
                  })} />
              </Flex.Item>
              <Flex.Item>
              <NumberInput
                value={id_age}
                unit="Years"
                minValue={17}
                maxValue={85}
                onChange={(e, value) => { act('PRG_age', {
                  id_age: value,
                });
                }} />
              </Flex.Item>
            </Flex>
            <Flex>
              <Flex.Item align="center">
                Assignment:
              </Flex.Item>
              <Flex.Item grow={1} ml={1}>
                <Input
                  fluid
                  mt={1}
                  value={id_rank}
                  onInput={(e, value) => act('PRG_assign', {
                    assignment: value,
                  })} />
              </Flex.Item>
            </Flex>
          </>
        ) || false}
      </Section>
      {(!!has_id && !!authenticatedUser) && (
        <Box>
          <AccessList
            accesses={regions}
            selectedList={access_on_card}
            wildcardFlags={wildcardFlags}
            wildcardSlots={wildcardSlots}
            trimAccess={trimAccess}
            accessFlags={accessFlags}
            accessFlagNames={accessFlagNames}
            terminateEmployment={() => act('PRG_terminate')}
            accessMod={ref => act('PRG_access', {
              access_target: ref,
            })} />
        </Box>
      )}
    </>
  );
};
