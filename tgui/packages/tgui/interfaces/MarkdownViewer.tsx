/**
 * @file MarkdownViewer.tsx
 * @author ZephyrTFA
 * @license MIT
 */

import { Component } from 'inferno';
import { marked } from 'marked';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type MarkdownViewerData = {
  title: string;
  content: string;
  author: string;
};

export const MarkdownViewer = (props: any, context: any) => {
  let { data } = useBackend<MarkdownViewerData>(context);
  return (
    <MarkdownViewerImpl
      title={data.title || 'No Title'}
      content={data.content || 'No Content'}
      author={data.author || 'Unknown Author'}
    />
  );
};

export class MarkdownViewerImpl extends Component<MarkdownViewerData> {
  render() {
    return (
      <Window title={this.props.title}>
        <Window.Content>
          <div id="markdown-viewer-content" />
        </Window.Content>
      </Window>
    );
  }

  componentDidMount() {
    let render_target = document.getElementById('markdown-viewer-content');
    if (render_target) {
      render_target.innerHTML = marked(this.props.content);
    } else {
      throw new Error('Unable to find render target');
    }
  }
}
