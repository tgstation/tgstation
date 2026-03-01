import { Button, Flex, Tabs } from 'tgui-core/components';

import { useRemappedBackend } from '../helpers';
import { useTechWebRoute } from '../hooks';
import { TechwebDesignDisk, TechwebTechDisk } from './disks';

type Props = {
  diskType: string;
};

export function TechwebDiskMenu(props: Props) {
  const { act, data } = useRemappedBackend();
  const { diskType } = props;
  const { t_disk, d_disk } = data;
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  // Check for the disk actually being inserted
  if ((diskType === 'design' && !d_disk) || (diskType === 'tech' && !t_disk)) {
    return null;
  }

  const DiskContent =
    (diskType === 'design' && TechwebDesignDisk) || TechwebTechDisk;

  return (
    <Flex direction="column" height="100%">
      <Flex.Item>
        <Flex justify="space-between" className="Techweb__HeaderSectionTabs">
          <Flex.Item align="center" className="Techweb__HeaderTabTitle">
            {diskType.charAt(0).toUpperCase() + diskType.slice(1)} Disk
          </Flex.Item>
          <Flex.Item grow>
            <Tabs>
              <Tabs.Tab selected>Stored Data</Tabs.Tab>
            </Tabs>
          </Flex.Item>
          <Flex.Item align="center">
            {diskType === 'tech' && (
              <Button icon="save" onClick={() => act('loadTech')}>
                Web &rarr; Disk
              </Button>
            )}
            <Button
              icon="upload"
              onClick={() => act('uploadDisk', { type: diskType })}
            >
              Disk &rarr; Web
            </Button>
            <Button
              icon="eject"
              onClick={() => {
                act('ejectDisk', { type: diskType });
                setTechwebRoute({ route: '' });
              }}
            >
              Eject
            </Button>
            <Button icon="home" onClick={() => setTechwebRoute({ route: '' })}>
              Home
            </Button>
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item grow className="Techweb__OverviewNodes">
        <DiskContent />
      </Flex.Item>
    </Flex>
  );
}
