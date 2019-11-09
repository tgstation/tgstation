import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section } from '../components';

export const AtmosAlertConsole = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const priorityAlerts = data.priority || [];
  const minorAlerts = data.minor || [];
  return (
    <Section title="Alarms">
      <ul>
        {priorityAlerts.length > 0 ? (
          priorityAlerts.map(alert => (
            <li key={alert}>
              <Button
                icon="times"
                content={alert}
                color="bad"
                onClick={() => act(ref, 'clear', { zone: alert })} />
            </li>
          ))
        ) : (
          <li className="color-good">
            No Priority Alerts
          </li>
        )}
        {minorAlerts.length > 0 ? (
          minorAlerts.map(alert => (
            <li key={alert}>
              <Button
                icon="times"
                content={alert}
                color="average"
                onClick={() => act(ref, 'clear', { zone: alert })} />
            </li>
          ))
        ) : (
          <li className="color-good">
            No Minor Alerts
          </li>
        )}
      </ul>
    </Section>
  );
};
