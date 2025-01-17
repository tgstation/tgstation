import { useLocalState } from '../../backend';
import { TechwebDiskMenu } from './disks/DiskMenu';
import { TechwebNodeDetail } from './nodes/detail';
import { TechwebOverview } from './Overview';

export function TechwebRouter(props) {
  const [techwebRoute] = useLocalState('techwebRoute', null);

  const route = techwebRoute?.route;
  const RoutedComponent =
    (route === 'details' && TechwebNodeDetail) ||
    (route === 'disk' && TechwebDiskMenu) ||
    TechwebOverview;

  return <RoutedComponent {...techwebRoute} />;
}
