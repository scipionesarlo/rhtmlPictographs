import BaseImageType from './base.imagetype'

class EllipseType extends BaseImageType {
  calculateImageDimensions () {
    return this.imageDimensions
  }

  calculateDesiredAspectRatio () {
    return Promise.resolve(null)
  }

  appendToSvg () {
    this.imageHandle = this.d3Node.append('svg:ellipse')
      .classed('ellipse', true)
      .attr('cx', this.containerWidth / 2)
      .attr('cy', this.containerHeight / 2)
      .attr('rx', ((this.containerWidth * this.ratio) / 2) * this.baseShapeHiding)
      .attr('ry', ((this.containerHeight * this.ratio) / 2) * this.baseShapeHiding)
      .style('fill', this.color)
      .style('opacity', this.opacity)

    return this.imageHandle
  }
}

module.exports = EllipseType
