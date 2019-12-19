import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Tabs } from '../components';

export const AirlockElectronics = props => {
  const { act, data } = useBackend(props);
  const regions = data.regions || [];

  const diffMap = {
    0: {
      icon: 'times-circle',
    },
    1: {
      icon: 'stop-circle',
    },
    2: {
      icon: 'check-circle',
    },
  };

  const checkAccessIcon = accesses => {
    let oneAccess = false;
    let oneInaccess = false;

    accesses.forEach(element => {
      if (element.req) {
        oneAccess = true;
      }
      else {
        oneInaccess = true;
      }
    });

    if (!oneAccess && oneInaccess) {
      return 0;
    }
    else if (oneAccess && oneInaccess) {
      return 1;
    }
    else {
      return 2;
    }
  };

  return (
    <Fragment>
      <Section title="Main">
        <LabeledList>
          <LabeledList.Item
            label="Access Required">
            <Button
              icon={data.oneAccess ? 'unlock' : 'lock'}
              content={data.oneAccess ? 'One' : 'All'}
              onClick={() => act('one_access')}
            />
          </LabeledList.Item>
          <LabeledList.Item
            label="Mass Modify">
            <Button
              icon="check-double"
              content="Grant All"
              onClick={() => act('grant_all')}
            />
            <Button
              icon="undo"
              content="Clear All"
              onClick={() => act('clear_all')}
            />
          </LabeledList.Item>
          <LabeledList.Item
            label="Unrestricted Access">
            <Button
              icon={data.unres_direction & 1 ? 'check-square-o' : 'square-o'}
              content="North"
              selected={data.unres_direction & 1}
              onClick={() => act('direc_set', {
                unres_direction: '1',
              })}
            />
            <Button
              icon={data.unres_direction & 2 ? 'check-square-o' : 'square-o'}
              content="East"
              selected={data.unres_direction & 2}
              onClick={() => act('direc_set', {
                unres_direction: '2',
              })}
            />
            <Button
              icon={data.unres_direction & 4 ? 'check-square-o' : 'square-o'}
              content="South"
              selected={data.unres_direction & 4}
              onClick={() => act('direc_set', {
                unres_direction: '4',
              })}
            />
            <Button
              icon={data.unres_direction & 8 ? 'check-square-o' : 'square-o'}
              content="West"
              selected={data.unres_direction & 8}
              onClick={() => act('direc_set', {
                unres_direction: '8',
              })}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Access">
        <Box height="261px">
          <Tabs vertical>
            {regions.map(region => {
              const { name } = region;
              const accesses = region.accesses || [];
              const icon = diffMap[checkAccessIcon(accesses)].icon;
              return (
                <Tabs.Tab
                  key={name}
                  icon={icon}
                  label={name}>
                  {() => accesses.map(access => (
                    <Box key={access.id}>
                      <Button
                        icon={access.req ? 'check-square-o' : 'square-o'}
                        content={access.name}
                        selected={access.req}
                        onClick={() => act('set', {
                          access: access.id,
                        })} />
                    </Box>
                  ))}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Box>
      </Section>
    </Fragment>
  );
};
