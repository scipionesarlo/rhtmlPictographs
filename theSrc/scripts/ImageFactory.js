import CircleType from './imageTypes/circle.imagetype';
import EllipseType from './imageTypes/ellipse.imagetype';
import SquareType from './imageTypes/square.imagetype';
import RectangleType from './imageTypes/rectangle.imagetype';
import RecoloredExternalSvg from './imageTypes/recoloredExternalSvg.imagetype';
import UrlType from './imageTypes/url.imagetype';

import ClipFactory from './ClipFactory';

class ImageFactory {

  static get types() {
    return {
      circle: CircleType,
      square: SquareType,
      url: UrlType,
      rect: RectangleType,
      ellipse: EllipseType,
      data: UrlType,
      recoloredExternalSvg: RecoloredExternalSvg,
    };
  }

  static get basicShapes() {
    return ['circle', 'ellipse', 'square', 'rect'];
  }

  static get scalingStrategies() {
    return {
      vertical: { clip: 'fromBottom' },
      horizontal: { clip: 'fromLeft' },
      fromleft: { clip: 'fromLeft' },
      fromright: { clip: 'fromRight' },
      frombottom: { clip: 'fromBottom' },
      fromtop: { clip: 'fromTop' },
      scale: 'scale',
      radialclip: { clip: 'radial' },
      radial: { clip: 'radial' },
      pie: { clip: 'radial' },
    };
  }

  static get validScalingStrategyStrings() {
    return _.keys(ImageFactory.scalingStrategies);
  }

  static get validScalingStrategyKeys() {
    return ['clip', 'scale'];
  }

  static addBaseImageTo(d3Node, config, width, height, dataAttributes) {
    config = ImageFactory.parseConfigString(config);
    // VIS-121 - Prevent base svgs from peeking out over the variable images (only for basic shapes)
    if (_.includes(ImageFactory.basicShapes, config.type) && this.isInternetExplorer()) {
      config.baseShapeScale = 0.98;
    }
    return ImageFactory.addImageTo(d3Node, config, width, height, dataAttributes);
  }

  static addVarImageTo(d3Node, config, width, height, dataAttributes) {
    config = ImageFactory.parseConfigString(config);
    return ImageFactory.addImageTo(d3Node, config, width, height, dataAttributes);
  }

  static addImageTo(d3Node, config, width, height, dataAttributes) {
    const imageInstance = ImageFactory.createInstance(d3Node, config, width, height, dataAttributes);

    return Promise.resolve()
      .then(imageInstance.calculateImageDimensions.bind(imageInstance))
      .then((imageDimensions) => {
        if (config.clip) {
          const newClipId = ClipFactory.addClipPath(config.clip, d3Node, imageDimensions);
          return newClipId;
        } else {
          return null;
        }
      })
      .then((clipId) => {
        const imageHandle = imageInstance.appendToSvg();
        if (clipId) {
          imageHandle.attr('clip-path', `url(#${clipId})`);
        }
      });
  }

  static createInstance(d3Node, config, width, height, dataAttributes) {
    if (!_.has(ImageFactory.types, config.type)) {
      throw new Error(`Invalid image type '${config.type}'`);
    }

    return new this.types[config.type](d3Node, config, width, height, dataAttributes);
  }

  static parseConfigString(configString) {
    if (!_.isString(configString)) {
      if (!(configString.type in ImageFactory.types)) {
        throw new Error(`Invalid image creation config : unknown image type ${configString.type}`);
      }
      return configString;
    }

    if (configString.length <= 0) {
      throw new Error("Invalid image creation configString '' : empty string");
    }

    const config = {};
    let configParts = [];

    const httpRegex = new RegExp('^(.*?):?(https?://.*)$');
    const matchesHttp = configString.match(httpRegex);
    if (matchesHttp) {
      configParts = _.without(matchesHttp[1].split(':'), 'url');
      config.type = 'url';
      config.url = matchesHttp[2];
    } else {
      configParts = configString.split(':');

      // NB TODO ! converting to const breaks flow !
      config.type = configParts.shift();
      if (!(config.type in ImageFactory.types)) {
        throw new Error(`Invalid image creation configString '${configString}' : unknown image type ${config.type}`);
      }
    }

    if (['url'].includes(config.type) && (config.url == null)) {
      config.url = configParts.pop();
      const hasDot = new RegExp(/\./);
      if (!config.url || !config.url.match(hasDot)) {
        throw new Error(`Invalid image creation configString '${configString}' : url string must end with a url`);
      }
    }

    if (['data'].includes(config.type)) {
      config.url = `data:${configParts.pop()}`;
      // TODO this logic needs to check there is something after data:
      if (!config.url) {
        throw new Error(`Invalid image creation configString '${configString}' : data string must have a data url as last string part`);
      }
    }

    const unknownParts = [];
    let part = configParts.shift();
    while (part) {
      if (part in ImageFactory.scalingStrategies) {
        const handler = ImageFactory.scalingStrategies[part];
        if (_.isString(handler)) {
          config[handler] = true;
        } else {
          _.extend(config, handler);
        }
      } else {
        unknownParts.push(part);
      }
      part = configParts.shift();
    }

    if (unknownParts.length > 1) {
      throw new Error(`Invalid image creation configString '${configString}' : too many unknown parts: [${unknownParts.join(',')}]`);
    }
    if (unknownParts.length === 1) {
      config.color = unknownParts[0];
    }

    if (config.color && config.url) {
      if (config.url.match(/\.svg$/)) {
        config.type = 'recoloredExternalSvg';
      } else {
        throw new Error(`Cannot recolor ${config.url}: unsupported image type for recoloring`);
      }
    }

    return config;
  }

  static isInternetExplorer() {
    const userAgentString = window.navigator.userAgent;
    const oldIe = userAgentString.indexOf('MSIE ');
    const newIe = userAgentString.indexOf('Trident/');

    if ((oldIe > -1) || (newIe > -1)) {
      return true;
    }

    return false;
  }
}

module.exports = ImageFactory;
