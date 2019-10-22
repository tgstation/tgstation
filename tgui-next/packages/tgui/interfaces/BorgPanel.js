import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';

export const BorgPanel = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const borg = data.borg || {};
  const cell = data.cell || {};
  const cellPercent = cell.charge / cell.maxcharge;
  const channels = data.channels || [];
  const modules = data.modules || [];
  const upgrades = data.upgrades || [];
  const ais = data.ais || [];
  const laws = data.laws || [];
  return (
    <Fragment>
      <Section
        title={borg.name}
        buttons={(
          <Button
            icon="pencil-alt"
            content="Rename"
            onClick={() => act(ref, 'rename')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Status">
            <Button
              icon={borg.emagged ? 'check-square-o' : 'square-o'}
              content="Emagged"
              selected={borg.emagged}
              onClick={() => act(ref, 'toggle_emagged')} />
            <Button
              icon={borg.lockdown ? 'check-square-o' : 'square-o'}
              content="Locked Down"
              selected={borg.lockdown}
              onClick={() => act(ref, 'toggle_lockdown')} />
            <Button
              icon={borg.scrambledcodes ? 'check-square-o' : 'square-o'}
              content="Scrambled Codes"
              selected={borg.scrambledcodes}
              onClick={() => act(ref, 'toggle_scrambledcodes')} />
          </LabeledList.Item>
          <LabeledList.Item label="Charge">
            {!cell.missing ? (
              <ProgressBar
                value={cellPercent}
                content={cell.charge + ' / ' + cell.maxcharge} />
            ) : (
              <span className="color-bad">No cell installed</span>
            ) }
            <br />
            <Button
              icon="pencil-alt"
              content="Set"
              onClick={() => act(ref, 'set_charge')} />
            <Button
              icon="eject"
              content="Change"
              onClick={() => act(ref, 'change_cell')} />
            <Button
              icon="trash"
              content="Remove"
              color="bad"
              onClick={() => act(ref, 'remove_cell')} />
          </LabeledList.Item>
          <LabeledList.Item label="Radio Channels">
            {channels.map(channel => (
              <Button
                key={channel.name}
                icon={channel.installed ? 'check-square-o' : 'square-o'}
                content={channel.name}
                selected={channel.installed}
                onClick={() => act(ref, 'toggle_radio', {
                  channel: channel.name,
                })} />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Module">
            {modules.map(module => (
              <Button
                key={module.type}
                icon={borg.active_module === module.type
                  ? 'check-square-o'
                  : 'square-o'}
                content={module.name}
                selected={borg.active_module === module.type}
                onClick={() => act(ref, 'setmodule', {
                  module: module.type,
                })} />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Upgrades">
            {upgrades.map(upgrade => (
              <Button
                key={upgrade.type}
                icon={upgrade.installed ? 'check-square-o' : 'square-o'}
                content={upgrade.name}
                selected={upgrade.installed}
                onClick={() => act(ref, 'toggle_upgrade', {
                  upgrade: upgrade.type,
                })} />
            ))}
          </LabeledList.Item>
          <LabeledList.Item label="Master AI">
            {ais.map(ai => (
              <Button
                key={ai.ref}
                icon={ai.connected ? 'check-square-o' : 'square-o'}
                content={ai.name}
                selected={ai.connected}
                onClick={() => act(ref, 'slavetoai', {
                  slavetoai: ai.ref,
                })} />
            ))}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Laws"
        buttons={(
          <Button
            icon={borg.lawupdate ? 'check-square-o' : 'square-o'}
            content="Lawsync"
            selected={borg.lawupdate}
            onClick={() => act(ref, 'toggle_lawupdate')} />
        )}>
        {laws.map(law => (
          <Box key={law}>
            {law}
          </Box>
        ))}
      </Section>
    </Fragment>
  );
};
