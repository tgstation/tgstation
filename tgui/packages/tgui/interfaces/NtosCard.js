import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, NoticeBox, Section, Tabs, Input } from '../components';
import { AccessList } from './common/AccessList';
import { map } from 'common/collections';

export const NtosCard = props => {
  const { act, data } = useBackend(props);

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
  } = data;

  if (!have_id_slot) {
    return (
      <NoticeBox>
        This program requires an ID slot in order to function
      </NoticeBox>
    );
  }

  return (
    <Fragment>
      <Section
        title={has_id && authenticated
          ? (
            <Input
              value={id_owner}
              width="250px"
              onInput={(e, value) => act('PRG_edit', {
                name: value,
              })} />
          )
          : (id_owner || 'No Card Inserted')}
        buttons={(
          <Fragment>
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
          </Fragment>
        )}>
        <Button
          fluid
          icon="eject"
          content={id_name}
          onClick={() => act('PRG_eject')} />
      </Section>
      {(!!has_id && !!authenticated) && (
        <Tabs>
          <Tabs.Tab label="Access">
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
          </Tabs.Tab>
          <Tabs.Tab label="Jobs">
            <Section
              title={id_rank}
              buttons={(
                <Button.Confirm
                  icon="exclamation-triangle"
                  content="Terminate"
                  color="bad"
                  onClick={() => act('PRG_terminate')} />
              )}>
              <Button.Input
                fluid
                content="Custom..."
                onCommit={(e, value) => act('PRG_assign', {
                  assign_target: 'Custom',
                  custom_name: value,
                })} />
              <Tabs vertical>
                {map((jobs_param, department) => {
                  const jobs = jobs_param || [];
                  return (
                    <Tabs.Tab
                      key={department}
                      label={department}>
                      {jobs.map(job => (
                        <Button
                          fluid
                          key={job.job}
                          content={job.display_name}
                          onClick={() => act('PRG_assign', {
                            assign_target: job.job,
                          })} />
                      ))}
                    </Tabs.Tab>
                  );
                })(jobs)}
              </Tabs>
            </Section>
          </Tabs.Tab>
        </Tabs>
      )}
    </Fragment>
  );
};
