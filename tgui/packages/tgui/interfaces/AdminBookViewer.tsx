import { useBackend } from '../backend';
import { Window } from '../layouts';
import { MarkdownRenderer } from './MarkdownViewer';

type ViewerData = {
  title: string;
  content: string;
  author: string;
  view_raw: boolean;
};

export const AdminBookViewer = (_: any) => {
  const { data } = useBackend<ViewerData>();
  return (
    <Window title={'Reading: ' + data.title} height={400} width={400}>
      <Window.Content scrollable>
        {data.view_raw ? (
          data.content
        ) : (
          <MarkdownRenderer content={data.content} />
        )}
      </Window.Content>
    </Window>
  );
};
