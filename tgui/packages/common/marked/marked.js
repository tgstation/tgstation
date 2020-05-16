/**
 * @copyright 2011-2020
 * @author Original Author Christopher Jeffrey (https://github.com/chjj/)
 * @author Changes Author WarlockD (https://github.com/warlockd)
 * @license MIT
 */

import { Lexer } from './Lexer';
import { Parser } from './Parser';
import { Tokenizer } from './Tokenizer';
import { Renderer } from './Renderer';
import { TextRenderer } from './TextRenderer';
import { Slugger } from './Slugger';
import {
  merge,
  checkSanitizeDeprecation,
  escape,
} from './helpers';
import {
  getDefaults,
  changeDefaults,
  defaults,
} from './defaults';

/**
 * Marked
 */
export const marked = (src, opt, callback) => {
  // throw error in case of non string input
  if (typeof src === 'undefined' || src === null) {
    throw new Error('marked(): input parameter is undefined or null');
  }
  if (typeof src !== 'string') {
    throw new Error('marked(): input parameter is of type '
      + Object.prototype.toString.call(src) + ', string expected');
  }

  if (callback || typeof opt === 'function') {
    if (!callback) {
      callback = opt;
      opt = null;
    }

    opt = merge({}, marked.defaults, opt || {});
    checkSanitizeDeprecation(opt);
    const highlight = opt.highlight;
    let tokens,
      pending,
      i = 0;

    try {
      tokens = Lexer.lex(src, opt);
    } catch (e) {
      return callback(e);
    }

    pending = tokens.length;

    const done = err => {
      if (err) {
        opt.highlight = highlight;
        return callback(err);
      }

      let out;

      try {
        out = Parser.parse(tokens, opt);
      } catch (e) {
        err = e;
      }

      opt.highlight = highlight;

      return err
        ? callback(err)
        : callback(null, out);
    };

    if (!highlight || highlight.length < 3) {
      return done();
    }

    delete opt.highlight;

    if (!pending) { return done(); }

    for (; i < tokens.length; i++) {
      (function (token) {
        if (token.type !== 'code') {
          return --pending || done();
        }
        return highlight(token.text, token.lang, (err, code) => {
          if (err) { return done(err); }
          if (code === null || code === token.text) {
            return --pending || done();
          }
          token.text = code;
          token.escaped = true;
          --pending || done();
        });
      })(tokens[i]);
    }

    return;
  }
  try {
    opt = { ...marked.defaults, ...(opt || {}) };
    checkSanitizeDeprecation(opt);
    return Parser.parse(Lexer.lex(src, opt), opt);
  } catch (e) {
    e.message += '\nPlease report this to https://github.com/markedjs/marked.';
    if ((opt || marked.defaults).silent) {
      return (
        <p>
          <pre>
            {"An error occurred: "+ escape(e.message + '', true)}
          </pre>
        </p>
      );
    }
    throw e;
  }
};

/**
 * Options
 */

marked.options
= marked.setOptions = function (opt) {
    merge(marked.defaults, opt);
    changeDefaults(marked.defaults);
    return marked;
  };

marked.getDefaults = getDefaults;

marked.defaults = defaults;

/**
 * Use Extension
 */

marked.use = function (extension) {
  const opts = merge({}, extension);
  if (extension.renderer) {
    const renderer = marked.defaults.renderer || new Renderer();
    for (const prop in extension.renderer) {
      const prevRenderer = renderer[prop];
      renderer[prop] = (...args) => {
        let ret = extension.renderer[prop].apply(renderer, args);
        if (ret === false) {
          ret = prevRenderer.apply(renderer, args);
        }
        return ret;
      };
    }
    opts.renderer = renderer;
  }
  if (extension.tokenizer) {
    const tokenizer = marked.defaults.tokenizer || new Tokenizer();
    for (const prop in extension.tokenizer) {
      const prevTokenizer = tokenizer[prop];
      tokenizer[prop] = (...args) => {
        let ret = extension.tokenizer[prop].apply(tokenizer, args);
        if (ret === false) {
          ret = prevTokenizer.apply(tokenizer, args);
        }
        return ret;
      };
    }
    opts.tokenizer = tokenizer;
  }
  marked.setOptions(opts);
};

/**
 * Expose
 */

marked.Parser = Parser;
marked.parser = Parser.parse;

marked.Renderer = Renderer;
marked.TextRenderer = TextRenderer;

marked.Lexer = Lexer;
marked.lexer = Lexer.lex;

marked.Tokenizer = Tokenizer;

marked.Slugger = Slugger;

marked.parse = marked;



