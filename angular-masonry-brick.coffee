"use strict"

angular.module "masonryLayoutBrick", []

.directive "masonryBrick", [->
	restrict: "EA"
	require: ['masonryBrick', '^^masonryWall']

	controller: ['$scope', '$attrs', class
		constructor: (@scope, @attrs) ->
	]

	link: (scope, element, attrs, controllers) ->
		brick = controllers[0]
		wall = controllers[1]
		scope.$on "$destroy", -> scope.$emit "brickLeave"
]
