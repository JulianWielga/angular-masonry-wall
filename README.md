angular-masonry-fly
-------------------
####Generates masonry layout image by image without knowing their height or waiting for all images to load.

+ Works with infinite scroll and window resizing.
+ No need to know images height or wait for all images to download.
+ Can be used on same page on different containers(***new***)

#####DEMO
http://bimal1331.github.io/angular-masonry-fly

#####REQUIREMENTS
+ Angularjs 1.2+ only
+ imagesloaded

#####INSTALLATION
+ Download angular-masonry.coffee, compile and include with your JS files.
+ Include module ***masonryLayout*** in your main app module.

or

use [Bower](http://bower.io/) to install `bower install https://github.com/JulianWielga/angular-masonry-fly.git`

#####USAGE

+ Use directive ***masonry*** like below -

	```html
	<div masonry margin-x="20" margin-y="30" brick-width="250" class="wall">
		<div ng-repeat="image in images" class="brick">
			<img ng-src="http://lorempixel.com/{{image.src}}">
		</div>
	</div>
	```
	+ margin-x - Horizontal gap between image containers (default: 0)
	+ margin-y - Vertical gap between image containers (default: 0)
	+ brick-width - Image width you'll be using for the layout, ideally should be image's natural width (if not set or 0: width of first element)

That's it!
