import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Section, Icon, ProgressBar } from '../components';
import { Fragment } from 'inferno';

export const Gateway = props => {
  const { act, data } = useBackend(props);
  const {
    gateway_present = false,
    gateway_status = false,
    current_target = null,
    destinations = [],
  } = data;

  if (!gateway_present) {
    return (
      <Section>
        <NoticeBox textAlign="center">
          No linked gateway
        </NoticeBox>
        <Button fluid onClick={() => act("linkup")}>Linkup</Button>
      </Section>
    );
  }

  if (current_target)
  {
    return (
      <Section title={current_target.name} textAlign="center">
        <Icon name="rainbow" size={4} color="green" />
        <Button
          fluid
          onClick={() => act("deactivate")}>
          Deactivate
        </Button>
      </Section>
    );
  }

  if (!destinations.length) {
    return (<Section>No gateway nodes detected.</Section>);
  }

  const GatewayDest = dest => {
    if (dest.availible)
    {
      return (
        <Section
          key={dest.ref}
          title={dest.name}
          textAlign="center">
          <Button
            fluid
            onClick={() => act("activate", { "destination": dest.ref })}>
            Activate
          </Button>
        </Section>);
    }
    else
    {
      return (
        <Section
          textAlign="center"
          key={dest.ref}
          title={dest.name}>
          <Box m={1} textColor="bad">{dest.reason}</Box>
          {!!dest.timeout && (<ProgressBar
            value={dest.timeout}
            content="Calibrating..." />)}
        </Section>);
    }
  };

  return (
    <Fragment>
      {!gateway_status && (<NoticeBox>Gateway Unpowered</NoticeBox>)}
      {destinations.map(GatewayDest)}
    </Fragment>);
};
