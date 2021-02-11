import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, NoticeBox, NumberInput, Section, Tabs } from '../components';
import { NtosWindow } from '../layouts';
import { AccessList } from './common/AccessList';

export const NtosCard = (props, context) => {
  return (
    <NtosWindow
      width={500}
      height={520}>
      <NtosWindow.Content scrollable>
        <NtosCardContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosCardContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  const {
    authenticated,
    regions = [],
    access_on_card = [],
    jobs = {},
    id_rank,
    id_owner,
    has_id,
    have_printer,
    have_id_slot,
    id_name,
    id_age,
  } = data;
  const [
    selectedDepartment,
    setSelectedDepartment,
  ] = useLocalState(context, 'department', Object.keys(jobs)[0]);
  if (!have_id_slot) {
    return (
      <NoticeBox>
        This program requires an ID slot in order to function
      </NoticeBox>
    );
  }
  const departmentJobs = jobs[selectedDepartment] || [];
  return (
    <>
      <Section
        title={has_id && authenticated
          ? (
            <>
              <Input
                value={id_owner}
                width="200px"
                onInput={(e, value) => act('PRG_edit', {
                  name: value,
                })} />
              <NumberInput
                value={id_age}
                unit="Years"
                minValue={17}
                maxValue={85}
                onChange={(e, value) => { act('PRG_age', {
                  id_age: value,
                });
                }} />
            </>
          )
          : (id_owner || 'No Card Inserted')}
        buttons={(
          <>
            <Button
              icon="print"
              content="Print"
              disabled={!have_printer || !has_id}
              onClick={() => act('PRG_print')} />
            <Button
              icon={authenticated ? "sign-out-alt" : "sign-in-alt"}
              content={authenticated ? "Log Out" : "Log In"}
              color={authenticated ? "bad" : "good"}
              onClick={() => {
                act(authenticated ? 'PRG_logout' : 'PRG_authenticate');
              }} />
          </>
        )}>
        <Button
          fluid
          icon="eject"
          content={id_name}
          onClick={() => act('PRG_eject')} />
        <Input
          fluid
          mt={1}
          value={id_rank}
          onInput={(e, value) => act('PRG_assign', {
            assignment: value,
          })} />
      </Section>
      {(!!has_id && !!authenticated) && (
        <Box>
          <AccessList
            accesses={regions}
            selectedList={access_on_card}
            accessMod={ref => act('PRG_access', {
              access_target: ref,
            })}
            grantAll={() => act('PRG_grantall')}
            denyAll={() => act('PRG_denyall')}
            grantDep={dep => act('PRG_grantregion', {
              region: dep,
            })}
            denyDep={dep => act('PRG_denyregion', {
              region: dep,
            })} />
        </Box>
      )}
    </>
  );
};
