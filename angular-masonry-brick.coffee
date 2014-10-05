"use strict"

angular.module "angularMasonryBrick", []

.directive "masonryBrick", ['$animate', ($animate) ->
	restrict: "EA"
	require: ['masonryBrick', '^^masonryWall']
	# scope: yes

	controller: ['$scope', '$element', '$attrs', class Brick
		constructor: (@scope, @el, @attrs) ->
			@animation = null

			@el.css
				position: 'absolute'

		setColumn: (column) =>
			return if not column? or column is @column
			@column = column
			return this

		getHeight: =>
			@height = @el[0].scrollHeight

		reposition: (position) =>
			@el.css position
			return this

	]

	link: (scope, element, attrs, controllers) ->
		brick = controllers[0]
		wall = controllers[1]

		element.css display: 'none'

		imagesLoaded element, =>
			element.css display: 'block'
			brick.animation = $animate.addClass element, 'loaded'
			.then =>
				wall.debouncedRepaint brick
				scope.$emit "brickLoaded"

		scope.$on "$destroy", =>
			wall.removeBrick brick
			scope.$emit "brickLeave"

		wall.addBrick brick
		scope.$emit "brickEnter"
]
