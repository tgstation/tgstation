import { useBackend } from '../backend';
import { Button, Section } from '../components';

export const AtmosAlertConsole = props => {
  const { act, data } = useBackend(props);
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
                onClick={() => act('clear', { zone: alert })} />
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
                onClick={() => act('clear', { zone: alert })} />
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
