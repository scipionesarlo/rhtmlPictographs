# Control Flow through ImageFactory

Called from GraphicCell.coffee:
    
    * ImageFactory.addBaseImageTo
    * ImageFactory.addVarImageTo
    
1. Initialize imageBoxDim to 0, 0, width, height

2. getImageDimensions
    * Use the initial imageBoxDim unless the image is a URL
    * If the image is a URL, then lookup  the dimensions in the cache
    * If there are no cached dimensions for the image, then create a hidden image tag, and when it loads recod the image height/width to calculate image dimensions

3. add Image to SVG via D3 and return the getImageData
    * This is the call to the ImageType, where the steps depend on the image type:
    * circle/square/ellipse/rect : 
         * simple call to d3Node.append and setting some dimension params. 
         * Return image, and position of the element relative to the container (i.e. the unscaledBox)
    * If the image is a recolored SVG:
         * check cache, if missing then download the image via AJAX request
         * modify the image source to apply the recoloring
         * modify the image source to apply sizing
         * add the new image source to a newly appended SVG g via D3
         * return image only
         
    * If the image is SVG with no recoloring:
         * check cache, if missing then download the image via AJAX request
         * modify the image source to apply sizing
         * add the new image source to a newly appended SVG g via D3
         * return image only
                 
    * If the image is a recolored any other format:
        * Throw error we cannot recolor other format:
         * return image only    
    
    * If the image any other format with no recoloring:
        * Add image via d3Node.append("svg:image")
         * return image only     
         
4. If a clip (left,right,top,bottom,radial) is required then add the clip via `d3Node.append('clipPath')`
         
         
 Proposed Changes
