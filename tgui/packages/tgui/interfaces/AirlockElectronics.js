import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';

export const AirlockElectronics = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    oneAccess,
    unres_direction,
  } = data;
  const regions = data.regions || [];
  const accesses = data.accesses || [];
  return (
    <Window
      width={420}
      height={485}>
      <Window.Content>
        <Section title="Main">
          <LabeledList>
            <LabeledList.Item
              label="Access Required">
              <Button
                icon={oneAccess ? 'unlock' : 'lock'}
                content={oneAccess ? 'One' : 'All'}
                onClick={() => act('one_access')} />
            </LabeledList.Item>
            <LabeledList.Item
              label="Unrestricted Access">
              <Button
                icon={unres_direction & 1 ? 'check-square-o' : 'square-o'}
                content="North"
                selected={unres_direction & 1}
                onClick={() => act('direc_set', {
                  unres_direction: '1',
                })} />
              <Button
                icon={unres_direction & 2 ? 'check-square-o' : 'square-o'}
                content="South"
                selected={unres_direction & 2}
                onClick={() => act('direc_set', {
                  unres_direction: '2',
                })} />
              <Button
                icon={unres_direction & 4 ? 'check-square-o' : 'square-o'}
                content="East"
                selected={unres_direction & 4}
                onClick={() => act('direc_set', {
                  unres_direction: '4',
                })} />
              <Button
                icon={unres_direction & 8 ? 'check-square-o' : 'square-o'}
                content="West"
                selected={unres_direction & 8}
                onClick={() => act('direc_set', {
                  unres_direction: '8',
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <AccessList
          accesses={regions}
          selectedList={accesses}
          accessMod={ref => act('set', {
            access: ref,
          })}
          grantAll={() => act('grant_all')}
          denyAll={() => act('clear_all')}
          grantDep={ref => act('grant_region', {
            region: ref,
          })}
          denyDep={ref => act('deny_region', {
            region: ref,
          })} />
      </Window.Content>
    </Window>
  );
};
