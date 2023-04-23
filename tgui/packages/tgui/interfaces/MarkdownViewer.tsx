import { Component } from 'inferno';
import { marked } from 'marked';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type MarkdownViewerData = {
  title: string;
  content: string;
  author: string;
};

export const MarkdownViewer = (_: any, context: any) => {
  let { data } = useBackend<MarkdownViewerData>(context);
  return (
    <Window theme="paper" title={data.title}>
      <Window.Content scrollable backgroundColor={'#FFFFFF'}>
        <MarkdownRenderer content={data.content} />
      </Window.Content>
    </Window>
  );
};

type MarkdownRendererProps = {
  content: string;
  sanitize?: boolean;
};

export class MarkdownRenderer extends Component<MarkdownRendererProps> {
  render() {
    return <div id="markdown-viewer-content" />;
  }

  renderMarkdown() {
    let rendered_content = marked(this.props.content);
    if (this.props.sanitize === undefined || this.props.sanitize) {
      rendered_content = sanitizeText(rendered_content, false);
    }

    let render_target = document.getElementById('markdown-viewer-content');
    if (render_target) {
      render_target.innerHTML = rendered_content;
    } else {
      throw new Error('Unable to find render target');
    }
  }

  componentDidMount() {
    this.renderMarkdown();
  }

  componentDidUpdate() {
    this.renderMarkdown();
  }
}
