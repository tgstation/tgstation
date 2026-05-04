import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const BorgPanel = (props) => {
  const { act, data } = useBackend();
  const borg = data.borg || {};
  const cell = data.cell || {};
  const cellPercent = cell.charge / cell.maxcharge;
  const channels = data.channels || [];
  const modules = data.modules || [];
  const upgrades = data.upgrades || [];
  const ais = data.ais || [];
  const laws = data.laws || [];
  return (
    <Window title="Borg Panel" theme="admin" width={700} height={700}>
      <Window.Content scrollable>
        <Section
          title={borg.name}
          buttons={
            <Button
              icon="pencil-alt"
              content="Rename"
              onClick={() => act('rename')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                icon={borg.emagged ? 'check-square-o' : 'square-o'}
                content="Emagged"
                selected={borg.emagged}
                onClick={() => act('toggle_emagged')}
              />
              <Button
                icon={borg.lockdown ? 'check-square-o' : 'square-o'}
                content="Locked Down"
                selected={borg.lockdown}
                onClick={() => act('toggle_lockdown')}
              />
              <Button
                icon={borg.scrambledcodes ? 'check-square-o' : 'square-o'}
                content="Scrambled Codes"
                selected={borg.scrambledcodes}
                onClick={() => act('toggle_scrambledcodes')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Charge">
              {!cell.missing ? (
                <ProgressBar value={cellPercent}>
                  {`${cell.charge} / ${cell.maxcharge}`}
                </ProgressBar>
              ) : (
                <span className="color-bad">No cell installed</span>
              )}
              <br />
              <Button
                icon="pencil-alt"
                content="Set"
                onClick={() => act('set_charge')}
              />
              <Button
                icon="eject"
                content="Change"
                onClick={() => act('change_cell')}
              />
              <Button
                icon="trash"
                content="Remove"
                color="bad"
                onClick={() => act('remove_cell')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Radio Channels">
              {channels.map((channel) => (
                <Button
                  key={channel.name}
                  icon={channel.installed ? 'check-square-o' : 'square-o'}
                  content={channel.name}
                  selected={channel.installed}
                  onClick={() =>
                    act('toggle_radio', {
                      channel: channel.name,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Model">
              {modules.map((module) => (
                <Button
                  key={module.type}
                  icon={
                    borg.active_module === module.type
                      ? 'check-square-o'
                      : 'square-o'
                  }
                  content={module.name}
                  selected={borg.active_module === module.type}
                  onClick={() =>
                    act('setmodule', {
                      module: module.type,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Upgrades">
              {upgrades.map((upgrade) => (
                <Button
                  key={upgrade.type}
                  icon={upgrade.installed ? 'check-square-o' : 'square-o'}
                  content={upgrade.name}
                  selected={upgrade.installed}
                  onClick={() =>
                    act('toggle_upgrade', {
                      upgrade: upgrade.type,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Master AI">
              {ais.map((ai) => (
                <Button
                  key={ai.ref}
                  icon={ai.connected ? 'check-square-o' : 'square-o'}
                  content={ai.name}
                  selected={ai.connected}
                  onClick={() =>
                    act('slavetoai', {
                      slavetoai: ai.ref,
                    })
                  }
                />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Laws"
          buttons={
            <Button
              icon={borg.lawupdate ? 'check-square-o' : 'square-o'}
              content="Lawsync"
              selected={borg.lawupdate}
              onClick={() => act('toggle_lawupdate')}
            />
          }
        >
          {laws.map((law) => (
            <Box key={law}>{law}</Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
