import { useBackend } from '../backend';
import { Button, Dropdown, Flex, Input, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const Mule = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    cell,
    cellPercent,
    load,
    mode,
    modeStatus,
    haspai,
    autoReturn,
    autoPickup,
    reportDelivery,
    destination,
    home,
    id,
    destinations = [],
  } = data;
  const locked = data.locked && !data.siliconUser;
  return (
    <Window width={350} height={425}>
      <Window.Content>
        <InterfaceLockNoticeBox />
        <Section
          title="Status"
          minHeight="110px"
          buttons={
            !locked && (
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                selected={on}
                onClick={() => act('on')}
              />
            )
          }>
          <ProgressBar
            value={cell ? cellPercent / 100 : 0}
            color={cell ? 'good' : 'bad'}
          />
          <Flex mt={1}>
            <Flex.Item grow={1} basis={0}>
              <LabeledList>
                <LabeledList.Item label="Mode" color={modeStatus}>
                  {mode}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
            <Flex.Item grow={1} basis={0}>
              <LabeledList>
                <LabeledList.Item
                  label="Load"
                  color={load ? 'good' : 'average'}>
                  {load || 'None'}
                </LabeledList.Item>
              </LabeledList>
            </Flex.Item>
          </Flex>
        </Section>
        {!locked && (
          <Section
            title="Controls"
            buttons={
              <>
                {!!load && (
                  <Button
                    icon="eject"
                    content="Unload"
                    onClick={() => act('unload')}
                  />
                )}
                {!!haspai && (
                  <Button
                    icon="eject"
                    content="Eject PAI"
                    onClick={() => act('ejectpai')}
                  />
                )}
              </>
            }>
            <LabeledList>
              <LabeledList.Item label="ID">
                <Input
                  value={id}
                  onChange={(e, value) => act('setid', { value })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Destination">
                <Dropdown
                  over
                  selected={destination || 'None'}
                  options={destinations}
                  width="150px"
                  onSelected={(value) => act('destination', { value })}
                />
                <Button
                  icon="stop"
                  content="Stop"
                  onClick={() => act('stop')}
                />
                <Button icon="play" content="Go" onClick={() => act('go')} />
              </LabeledList.Item>
              <LabeledList.Item label="Home">
                <Dropdown
                  over
                  selected={home}
                  options={destinations}
                  width="150px"
                  onSelected={(value) => act('destination', { value })}
                />
                <Button
                  icon="home"
                  content="Go Home"
                  onClick={() => act('home')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Settings">
                <Button.Checkbox
                  checked={autoReturn}
                  content="Auto-Return"
                  onClick={() => act('autored')}
                />
                <br />
                <Button.Checkbox
                  checked={autoPickup}
                  content="Auto-Pickup"
                  onClick={() => act('autopick')}
                />
                <br />
                <Button.Checkbox
                  checked={reportDelivery}
                  content="Report Delivery"
                  onClick={() => act('report')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
