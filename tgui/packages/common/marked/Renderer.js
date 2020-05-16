/**
 * @copyright 2011-2020
 * @author Original Author Christopher Jeffrey (https://github.com/chjj/)
 * @author Changes Author WarlockD (https://github.com/warlockd)
 * @license MIT
 */

import { defaults } from './defaults';
import { pureComponentHooks } from 'common/react';
import { createVNode } from 'inferno';
import { cleanUrl, escape } from './helpers';

/**
 * Renderer
 */
export class Renderer {
  constructor(options) {
    this.options = options || defaults;
  }

  code(code, infostring, escaped) {
    const lang = (infostring || '').match(/\S*/)[0];
    if (this.options.highlight) {
      const out = this.options.highlight(code, lang);
      if (out !== null && out !== code) {
        escaped = true;
        code = out;
      }
    }

    if (!lang) {
      return (
        <pre>
          <code>
            {escaped || typeof code === 'string'? code : escape(code, true) }
          </code>
        </pre>
      );
    }

    return (
      <pre>
        <code class={'' + this.options.langPrefix + escape(lang, true)}>
          {escaped || typeof code === 'string'? code : escape(code, true) }
        </code>
      </pre>
    );
  }

  blockquote(quote) {
    return (
      <blockquote>
        {quote}
      </blockquote>
    );
  }

  html(html) {
    return html;
  }

  heading(text, level, raw, slugger) {
    // have to use create node here, how high do header levels go anyway?
    /*
    const props = {};
    if (this.options.headerIds) {
      props.id = '' + this.options.headerPrefix + slugger.slug(raw);
    }
    return createElement('h' + level, props,text);
    */
    // do it this way or import inferno-create-element
    switch (level) {
      case 1: return (
        <h1 id={
          this.options.headerIds && ''
          + this.options.headerPrefix + slugger.slug(raw)
        }>
          {text}
        </h1>
      );
      case 2: return (
        <h2 id={
          this.options.headerIds && ''
          + this.options.headerPrefix + slugger.slug(raw)
        }>
          {text}
        </h2>
      );
      case 3: return (
        <h3 id={
          this.options.headerIds && ''
          + this.options.headerPrefix + slugger.slug(raw)
        }>
          {text}
        </h3>
      );
      case 4: return (
        <h4 id={
          this.options.headerIds && ''
          + this.options.headerPrefix + slugger.slug(raw)
        }>
          {text}
        </h4>
      );
      case 5: return (
        <h5 id={
          this.options.headerIds && ''
          + this.options.headerPrefix + slugger.slug(raw)
        }>
          {text}
        </h5>
      );
      case 6: return (
        <h6 id={
          this.options.headerIds && ''
          + this.options.headerPrefix + slugger.slug(raw)
        }>
          {text}
        </h6>
      );
      default:
        // should we throw an error here?
        return (
          <h1 id={
            this.options.headerIds && ''
            + this.options.headerPrefix + slugger.slug(raw)
          }>
            {text}
          </h1>
        );
    }
  }

  hr() {
    // this.options.xhtml ? <hr/> : <hr>; // old code
    return <hr />;
  }

  list(body, ordered, start) {
    if (ordered) {
      return (<ol start={start !== 1 && '' + start}>{body}</ol>);
    } else {
      return (<ul>{body}</ul>);
    }
  }

  listitem(text) {
    return <li>{text}</li>;
  }

  checkbox(checked) {
    return <input type="checkbox" disabled checked={checked || null} />;
  }

  paragraph(text) {
    return <p>{ text }</p>;
  }

  table(header, body) {
    if (body) {
      body = <tbody>{body}</tbody>;
    }

    return <table><thead>{header}</thead>{body}</table>;
  }

  tablerow(content) {
    return <tr>{content}</tr>;
  }

  tablecell(content, flags) {
    if (flags.header) {
      return <th align={flags.align}>{content}</th>;
    } else {
      return <td align={flags.align}>{content}</td>;
    }
  }

  // span level renderer
  strong(text) {
    return <strong>{text}</strong>;
  }

  em(text) {
    return <em>{text}</em>;
  }

  codespan(text) {
    return <code>{text}</code>;
  }

  br() {
    return <br />;
  }

  del(text) {
    return <del>{text}</del>;
  }

  link(href, title, text) {
    href = cleanUrl(this.options.sanitize, this.options.baseUrl, href);
    if (href === null) {
      return text;
    }
    return <a href={escape(href)} title={title && title + ''}>{text}</a>;
  }

  image(href, title, text) {
    href = cleanUrl(this.options.sanitize, this.options.baseUrl, href);
    if (href === null) {
      return text;
    }
    return (<a href={escape(href)} alt={text && text + ''}
      title={title && title + ''} />);
  }

  text(text) {
    return escape(text);
  }
}
