"use strict"

angular.module "angularMasonryBrick", []

.directive "masonryBrick", ['$animate', '$timeout', ($animate, $timeout) ->
	restrict: "EA"
	require: ['masonryBrick', '^^masonryWall']
	# scope: yes

	controller: ['$scope', '$element', '$attrs', class Brick
		constructor: (@scope, @el, @attrs) ->
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

			unless @el.hasClass 'loaded'
				$timeout => $animate.addClass @el, 'loaded'

			return this

	]

	link: (scope, element, attrs, controllers) ->
		brick = controllers[0]
		wall = controllers[1]

		imagesLoaded element, ->
			wall.debouncedRepaint()
			scope.$emit "brickLoaded"

		scope.$on "$destroy", ->
			wall.removeBrick brick
			scope.$emit "brickLeave"

		wall.addBrick brick
		scope.$emit "brickEnter"
]
