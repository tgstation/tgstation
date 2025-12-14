import { useState } from 'react';
import {
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ZLevel = {
  z: number;
  name: string;
  traits: string[];
  enabled: BooleanLike;
  disabled: BooleanLike;
  in_progress: BooleanLike;
  progress_percent: number;
  save_time_seconds: number;
  mobs_saved: number;
  objs_saved: number;
  turfs_saved: number;
  areas_saved: number;
};

type SaveFlags = {
  objects: BooleanLike;
  objects_variables: BooleanLike;
  objects_properties: BooleanLike;
  mobs: BooleanLike;
  turfs: BooleanLike;
  turfs_atmos: BooleanLike;
  turfs_space: BooleanLike;
  areas: BooleanLike;
  areas_default_shuttles: BooleanLike;
  areas_custom_shuttles: BooleanLike;
};

type MapSerializationData = {
  z_levels: ZLevel[];
  save_flags: SaveFlags;
  save_enabled: BooleanLike;
  is_saving: BooleanLike;
  total_save_time: number;
};

export function MapSerialization(props) {
  const { data } = useBackend<MapSerializationData>();
  const [selectedTab, setSelectedTab] = useState('z_levels');

  return (
    <Window theme="admin" title="Map Serialization" width={1000} height={650}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={selectedTab === 'z_levels'}
                onClick={() => setSelectedTab('z_levels')}
                icon="layer-group"
              >
                Z-Levels
              </Tabs.Tab>
              <Tabs.Tab
                selected={selectedTab === 'save_flags'}
                onClick={() => setSelectedTab('save_flags')}
                icon="cogs"
              >
                Save Options
              </Tabs.Tab>
              <Tabs.Tab
                selected={selectedTab === 'summary'}
                onClick={() => setSelectedTab('summary')}
                icon="chart-bar"
              >
                Summary
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {selectedTab === 'z_levels' && <ZLevelsSection />}
            {selectedTab === 'save_flags' && <SaveFlagsSection />}
            {selectedTab === 'summary' && <SummarySection />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function ZLevelsSection() {
  const { act, data } = useBackend<MapSerializationData>();
  const { z_levels, save_enabled, is_saving } = data;

  return (
    <Section
      fill
      scrollable
      title="Z-Level Configuration"
      buttons={
        <Stack>
          <Stack.Item>
            <Button
              icon={is_saving ? 'stop' : 'play'}
              color={is_saving ? 'red' : 'green'}
              disabled={!save_enabled}
              onClick={() => act(is_saving ? 'stop_save' : 'start_save')}
            >
              {is_saving ? 'Stop Save' : 'Start Save'}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="toggle-on"
              disabled={is_saving}
              onClick={() => act('toggle_all_z_levels')}
            >
              Toggle All
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      <Table>
        <Table.Row header>
          <Table.Cell>Z</Table.Cell>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Enabled</Table.Cell>
          <Table.Cell>Progress</Table.Cell>
          <Table.Cell>Time (s)</Table.Cell>
          <Table.Cell>Objects</Table.Cell>
          <Table.Cell>Mobs</Table.Cell>
          <Table.Cell>Turfs</Table.Cell>
          <Table.Cell>Areas</Table.Cell>
          <Table.Cell>Traits</Table.Cell>
        </Table.Row>
        {z_levels?.map((z_level) => (
          <Table.Row key={z_level.z}>
            <Table.Cell>{z_level.z}</Table.Cell>
            <Table.Cell>{z_level.name}</Table.Cell>
            <Table.Cell>
              <Button.Checkbox
                checked={z_level.enabled}
                disabled={z_level.disabled || is_saving}
                onClick={() => act('toggle_z_level', { z_level: z_level.z })}
              />
            </Table.Cell>
            <Table.Cell width="150px">
              {z_level.in_progress ? (
                <ProgressBar
                  value={z_level.progress_percent}
                  minValue={0}
                  maxValue={100}
                  color="blue"
                >
                  {z_level.progress_percent.toFixed(1)}%
                </ProgressBar>
              ) : z_level.enabled ? (
                <ProgressBar
                  value={z_level.save_time_seconds > 0 ? 100 : 0}
                  minValue={0}
                  maxValue={100}
                  color={z_level.save_time_seconds > 0 ? 'green' : 'grey'}
                >
                  {z_level.save_time_seconds > 0 ? 'Complete' : 'Pending'}
                </ProgressBar>
              ) : z_level.disabled ? (
                <ProgressBar
                  value={100}
                  minValue={0}
                  maxValue={100}
                  color="grey"
                >
                  Multi-Z
                </ProgressBar>
              ) : (
                <ProgressBar value={0} minValue={0} maxValue={100} color="red">
                  Disabled
                </ProgressBar>
              )}
            </Table.Cell>
            <Table.Cell>{z_level.save_time_seconds.toFixed(2)}</Table.Cell>
            <Table.Cell>{z_level.objs_saved.toLocaleString()}</Table.Cell>
            <Table.Cell>{z_level.mobs_saved.toLocaleString()}</Table.Cell>
            <Table.Cell>{z_level.turfs_saved.toLocaleString()}</Table.Cell>
            <Table.Cell>{z_level.areas_saved.toLocaleString()}</Table.Cell>
            <Table.Cell>{z_level.traits.join(', ')}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
}

function SaveFlagsSection() {
  const { act, data } = useBackend<MapSerializationData>();
  const { save_flags, is_saving } = data;

  return (
    <Section fill title="Save Configuration Options">
      <Stack vertical>
        <Stack.Item>
          <Section title="Objects">
            <LabeledList>
              <LabeledList.Item label="Save Objects">
                <Button.Checkbox
                  checked={save_flags.objects}
                  disabled={is_saving}
                  onClick={() => act('toggle_save_flag', { flag: 'objects' })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Save Object Variables">
                <Button.Checkbox
                  checked={save_flags.objects_variables}
                  disabled={is_saving || !save_flags.objects}
                  onClick={() =>
                    act('toggle_save_flag', { flag: 'objects_variables' })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Save Object Properties">
                <Button.Checkbox
                  checked={save_flags.objects_properties}
                  disabled={is_saving || !save_flags.objects}
                  onClick={() =>
                    act('toggle_save_flag', { flag: 'objects_properties' })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Mobs">
            <LabeledList>
              <LabeledList.Item label="Save Mobs">
                <Button.Checkbox
                  checked={save_flags.mobs}
                  disabled={is_saving}
                  onClick={() => act('toggle_save_flag', { flag: 'mobs' })}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Turfs">
            <LabeledList>
              <LabeledList.Item label="Save Turfs">
                <Button.Checkbox
                  checked={save_flags.turfs}
                  disabled={is_saving}
                  onClick={() => act('toggle_save_flag', { flag: 'turfs' })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Save Atmospheric Data">
                <Button.Checkbox
                  checked={save_flags.turfs_atmos}
                  disabled={is_saving || !save_flags.turfs}
                  onClick={() =>
                    act('toggle_save_flag', { flag: 'turfs_atmos' })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Save Space Turfs">
                <Button.Checkbox
                  checked={save_flags.turfs_space}
                  disabled={is_saving}
                  onClick={() =>
                    act('toggle_save_flag', { flag: 'turfs_space' })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Areas">
            <LabeledList>
              <LabeledList.Item label="Save Areas">
                <Button.Checkbox
                  checked={save_flags.areas}
                  disabled={is_saving}
                  onClick={() => act('toggle_save_flag', { flag: 'areas' })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Save Default Shuttle Areas">
                <Button.Checkbox
                  checked={save_flags.areas_default_shuttles}
                  disabled={is_saving || !save_flags.areas}
                  onClick={() =>
                    act('toggle_save_flag', { flag: 'areas_default_shuttles' })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Save Custom Shuttle Areas">
                <Button.Checkbox
                  checked={save_flags.areas_custom_shuttles}
                  disabled={is_saving || !save_flags.areas}
                  onClick={() =>
                    act('toggle_save_flag', { flag: 'areas_custom_shuttles' })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function SummarySection() {
  const { data } = useBackend<MapSerializationData>();
  const { z_levels, is_saving, total_save_time } = data;

  const enabled_z_levels = z_levels ? z_levels.filter((z) => z.enabled) : [];
  const completed_z_levels = enabled_z_levels.filter(
    (z) => z.save_time_seconds > 0,
  );
  const in_progress_z_levels = enabled_z_levels.filter((z) => z.in_progress);

  const total_objs = z_levels
    ? z_levels.reduce((sum, z) => sum + z.objs_saved, 0)
    : 0;
  const total_mobs = z_levels
    ? z_levels.reduce((sum, z) => sum + z.mobs_saved, 0)
    : 0;
  const total_turfs = z_levels
    ? z_levels.reduce((sum, z) => sum + z.turfs_saved, 0)
    : 0;
  const total_areas = z_levels
    ? z_levels.reduce((sum, z) => sum + z.areas_saved, 0)
    : 0;

  return (
    <Section fill title="Save Summary">
      <Stack vertical>
        <Stack.Item>
          <Section title="Progress Overview">
            <LabeledList>
              <LabeledList.Item label="Status">
                {is_saving ? (
                  <span style={{ color: 'orange' }}>Saving in Progress</span>
                ) : completed_z_levels.length === enabled_z_levels.length &&
                  enabled_z_levels.length > 0 ? (
                  <span style={{ color: 'green' }}>Save Complete</span>
                ) : (
                  <span style={{ color: 'grey' }}>Idle</span>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Total Save Time">
                {total_save_time.toFixed(2)} seconds
              </LabeledList.Item>
              <LabeledList.Item label="Z-Levels Enabled">
                {enabled_z_levels.length}
              </LabeledList.Item>
              <LabeledList.Item label="Z-Levels Completed">
                {completed_z_levels.length} / {enabled_z_levels.length}
              </LabeledList.Item>
              <LabeledList.Item label="Currently Processing">
                {in_progress_z_levels.length > 0
                  ? in_progress_z_levels
                      .map((z) => `Z-${z.z} (${z.name})`)
                      .join(', ')
                  : 'None'}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Total Statistics">
            <LabeledList>
              <LabeledList.Item label="Objects Saved">
                {total_objs.toLocaleString()}
              </LabeledList.Item>
              <LabeledList.Item label="Mobs Saved">
                {total_mobs.toLocaleString()}
              </LabeledList.Item>
              <LabeledList.Item label="Turfs Saved">
                {total_turfs.toLocaleString()}
              </LabeledList.Item>
              <LabeledList.Item label="Areas Saved">
                {total_areas.toLocaleString()}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>

        <Stack.Item>
          <Section title="Per-Level Details">
            <Table>
              <Table.Row header>
                <Table.Cell>Z-Level</Table.Cell>
                <Table.Cell>Time (s)</Table.Cell>
                <Table.Cell>Objects</Table.Cell>
                <Table.Cell>Mobs</Table.Cell>
                <Table.Cell>Turfs</Table.Cell>
                <Table.Cell>Areas</Table.Cell>
              </Table.Row>
              {enabled_z_levels.map((z_level) => (
                <Table.Row key={z_level.z}>
                  <Table.Cell>
                    Z-{z_level.z} ({z_level.name})
                  </Table.Cell>
                  <Table.Cell>
                    {z_level.save_time_seconds.toFixed(2)}
                  </Table.Cell>
                  <Table.Cell>{z_level.objs_saved.toLocaleString()}</Table.Cell>
                  <Table.Cell>{z_level.mobs_saved.toLocaleString()}</Table.Cell>
                  <Table.Cell>
                    {z_level.turfs_saved.toLocaleString()}
                  </Table.Cell>
                  <Table.Cell>
                    {z_level.areas_saved.toLocaleString()}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
