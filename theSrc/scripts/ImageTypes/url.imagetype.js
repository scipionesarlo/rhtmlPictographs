import BaseImageType from './base.imagetype';
import CacheService from '../CacheService';
import geometryUtils from '../utils/geometryUtils';

class UrlType extends BaseImageType {

  calculateImageDimensions() {
    const cacheKey = `dimensions-${this.config.url}-${this.containerWidth}-${this.containerHeight}`;
    if (!CacheService.get(cacheKey)) {
      const imageDimensionsPromise = new Promise((resolve, reject) => {
        const tmpImg = document.createElement('img');
        tmpImg.setAttribute('src', this.config.url);
        document.body.appendChild(tmpImg);

        tmpImg.onerror = () => {
          tmpImg.remove();
          return reject(new Error(`Image download fail: '${this.config.url}'`));
        };

        tmpImg.onload = () => {
          const imageWidth = tmpImg.getBoundingClientRect().width;
          const imageHeight = tmpImg.getBoundingClientRect().height;
          const containerAspectRatio = this.containerWidth / this.containerHeight;

          const imageDimensions = geometryUtils.computeImageDimensions(
            imageWidth / imageHeight,
            this.containerWidth,
            this.containerHeight
          );
          _.merge(this.imageDimensions, imageDimensions);

          tmpImg.remove();
          return resolve(imageDimensions);
        };
      });
      CacheService.put(cacheKey, imageDimensionsPromise, 10000);
    }

    return CacheService.get(cacheKey).then((imageDimensions) => {
      this.imageDimensions = imageDimensions;
      return this.imageDimensions;
    });
  }

  appendToSvg() {
    this.imageHandle = this.d3Node.append('svg:image')
      .attr('x', (this.containerWidth * (1 - this.ratio)) / 2)
      .attr('y', (this.containerHeight * (1 - this.ratio)) / 2)
      .attr('width', this.containerWidth * this.ratio)
      .attr('height', this.containerHeight * this.ratio)
      .attr('xlink:href', this.config.url);

    return this.imageHandle;
  }
}

module.exports = UrlType;
