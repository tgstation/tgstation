import { Fragment } from 'inferno';
import { act } from '../byond';
import { Section, Button, LabeledList } from '../components';
import { LabeledListItem } from '../components/LabeledList';

export const TurbineComputer = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section
      title="Status"
      buttons={(
        <Fragment>
          <Button
            icon={data.online ? 'power-off' : 'times'}
            content={data.online ? 'Online' : 'Offline'}
            selected={data.online}
            disabled={!data.compressor || data.compressor_broke || !data.turbine || data.turbine_broke}
            onClick={() => act(ref, 'toggle_power')} />
          <Button
            icon="sync"
            content="Reconnect"
            onClick={() => act(ref, 'reconnect')} />
        </Fragment>
      )}>
      {(!data.compressor || data.compressor_broke || !data.turbine || data.turbine_broke) ? (
        <LabeledList>
          <LabeledListItem
            label="Compressor Status"
            color={!data.compressor || data.compressor_broke ? "bad" : "good"}>
            {data.compressor_broke ? data.compressor ? "Offline" : "Missing" : "Online"}
          </LabeledListItem>
          <LabeledListItem
            label="Turbine Status"
            color={!data.turbine || data.turbine_broke ? "bad" : "good"}>
            {data.turbine_broke ? data.turbine ? "Offline" : "Missing" : "Online"}
          </LabeledListItem>
        </LabeledList>
      ):(
        <LabeledList>
          <LabeledListItem label="Turbine Speed">
            {data.rpm} RPM
          </LabeledListItem>
          <LabeledListItem label="Internal Temp">
            {data.temp} K
          </LabeledListItem>
          <LabeledListItem label="Generated Power">
            {data.power}
          </LabeledListItem>
        </LabeledList>
      )}
    </Section>
  );
};
