import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Icon, LabeledList, Section } from '../components';

export const ImplantChair = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      <Section title="Occupant Information"
        textAlign="center">
        <LabeledList>
          <LabeledList.Item label="Name">
            {data.occupant.name ? data.occupant.name : "No Occupant"}
          </LabeledList.Item>
          {!!data.occupied && (
            <LabeledList.Item label="Status"
              color={(data.occupant.stat === 0) ? "good" : data.occupant.stat === 1 ? "average" : "bad"}>
              {data.occupant.stat === 0 ? "Conscious" : data.occupant.stat === 1 ? "Unconcious" : "Dead"}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
      <Section title="Operations"
        textAlign="center">
        <LabeledList>
          <LabeledList.Item label="Door">
            <Button
              icon={data.open ? "unlock" : "lock"}
              color={data.open ? "default" : "red"}
              onClick={() => act(ref, 'door')}
              content={data.open ? "Open" : "Closed"} />
          </LabeledList.Item>
          <LabeledList.Item label="Implant Occupant">
            <Button
              icon="code-branch"
              onClick={() => act(ref, 'implant')}
              content={data.ready ? (data.special_name ? data.special_name : "Implant") : "Recharging"} />
            {data.ready === 0 && (
              <Icon
                name="cog"
                color="orange"
                spin />
            )}
          </LabeledList.Item>
          <LabeledList.Item label="Implants Remaining">
            {data.ready_implants}
            {data.replenishing === 1 && (
              <Icon
                name="sync"
                color="red"
                spin />
            )}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
