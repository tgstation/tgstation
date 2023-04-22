import { useBackend, useSharedState } from '../../backend';
import { Section } from '../../components';
import { RequestsData } from './Types';

export const AnnouncementTab = (props, context) => {
  const { act, data } = useBackend<RequestsData>(context);
  return <Section>Announcement</Section>;
};
