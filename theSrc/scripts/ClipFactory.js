class ClipFactory {

  static addClipPath(clipType, d3Node, imageDimensions) {
    const clipMaker = (() => {
      switch (true) {
        case clipType === 'fromleft': return this.addClipFromLeft;
        case clipType === 'fromright': return this.addClipFromRight;
        case clipType === 'fromtop': return this.addClipFromTop;
        case clipType === 'frombottom': return this.addClipFromBottom;
        case clipType === 'radial': return this.addRadialClip;
        default: throw new Error(`Invalid clip type '${clipType}'`);
      }
    })();

    const newClipId = clipMaker(d3Node, imageDimensions);
    return newClipId;
  }

  static addClipFromBottom(d3Node, imageBox) {
    const uniqueId = `clip-id-${Math.random()}`.replace(/\./g, '');
    d3Node.append('clipPath')
      .attr('id', uniqueId)
      .append('rect')
      .attr('x', imageBox.x)
      .attr('y', d => imageBox.y + (imageBox.height * (1 - d.proportion)))
      .attr('width', imageBox.width)
      .attr('height', d => imageBox.height * d.proportion);
    return uniqueId;
  }

  static addClipFromTop(d3Node, imageBox) {
    const uniqueId = `clip-id-${Math.random()}`.replace(/\./g, '');
    d3Node.append('clipPath')
      .attr('id', uniqueId)
      .append('rect')
      .attr('x', imageBox.x)
      .attr('y', imageBox.y)
      .attr('width', imageBox.width)
      .attr('height', d => imageBox.height * d.proportion);
    return uniqueId;
  }

  static addClipFromLeft(d3Node, imageBox) {
    const uniqueId = `clip-id-${Math.random()}`.replace(/\./g, '');
    d3Node.append('clipPath')
      .attr('id', uniqueId)
      .append('rect')
      .attr('x', imageBox.x)
      .attr('y', imageBox.y)
      .attr('width', d => imageBox.width * d.proportion)
      .attr('height', imageBox.height);
    return uniqueId;
  }

  static addClipFromRight(d3Node, imageBox) {
    const uniqueId = `clip-id-${Math.random()}`.replace(/\./g, '');
    d3Node.append('clipPath')
      .attr('id', uniqueId)
      .append('rect')
      .attr('x', d => imageBox.x + (imageBox.width * (1 - d.proportion)))
      .attr('y', imageBox.y)
      .attr('width', d => imageBox.width * d.proportion)
      .attr('height', imageBox.height);
    return uniqueId;
  }

  static addRadialClip(d3Node, imageBox) {
    const { x, y, width, height } = imageBox;

    const uniqueId = `clip-id-${Math.random()}`.replace(/\./g, '');
    d3Node.append('clipPath')
      .attr('id', uniqueId)
      .append('path')
      .attr('d', function (d) {
        const p = d.proportion;
        const degrees = p * 360;
        const w2 = width / 2;
        const h2 = height / 2;

        // start in the centre, then go straight up, then ...
        const pathParts = [`M${x + w2},${y + h2} l0,-${h2}`];

        // trace the edges of the rectangle, returning to the centre once we have "used up" all the proportion
        // probably can be optimized or expressed better ...

        if (p >= 1 / 8) {
          pathParts.push(`l${w2},0`);
        } else {
          pathParts.push(`l${h2 * Math.tan((degrees * Math.PI) / 180)},0`);
        }

        if (p >= 2 / 8) {
          pathParts.push(`l0,${h2}`);
        } else if (p > 1 / 8) {
          pathParts.push(`l0,${h2 - (w2 * Math.tan(((90 - degrees) * Math.PI) / 180))}`);
        }

        if (p >= 3 / 8) {
          pathParts.push(`l0,${h2}`);
        } else if (p > 2 / 8) {
          pathParts.push(`l0,${w2 * Math.tan(((degrees - 90) * Math.PI) / 180)}`);
        }

        if (p >= 4 / 8) {
          pathParts.push(`l-${w2},0`);
        } else if (p > 3 / 8) {
          pathParts.push(`l-${w2 - (h2 * Math.tan(((180 - degrees) * Math.PI) / 180))},0`);
        }

        if (p >= 5 / 8) {
          pathParts.push(`l-${w2},0`);
        } else if (p > 4 / 8) {
          pathParts.push(`l-${h2 * Math.tan(((degrees - 180) * Math.PI) / 180)},0`);
        }

        if (p >= 6 / 8) {
          pathParts.push(`l0,-${h2}`);
        } else if (p > 5 / 8) {
          pathParts.push(`l0,-${h2 - (w2 * Math.tan(((270 - degrees) * Math.PI) / 180))}`);
        }

        if (p >= 7 / 8) {
          pathParts.push(`l0,-${h2}`);
        } else if (p > 6 / 8) {
          pathParts.push(`l0,-${w2 * Math.tan(((degrees - 270) * Math.PI) / 180)}`);
        }

        if (p >= 8 / 8) {
          pathParts.push(`l${w2},0`);
        } else if (p > 7 / 8) {
          pathParts.push(`l${w2 - (h2 * Math.tan(((360 - degrees) * Math.PI) / 180))},0`);
        }

        pathParts.push('z');
        return pathParts.join(' ');
      });

    return uniqueId;
  }
}

module.exports = ClipFactory;
