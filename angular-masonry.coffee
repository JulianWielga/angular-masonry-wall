"use strict"

angular.module "angularMasonryWall", [
  'angularMasonryBrick'
]

.directive "masonryWall", ["$window", ($window) ->
  restrict: "EA"
  scope: yes

  controller: ['$scope', '$element', '$attrs', class Wall
    throttle: (threshold) => (func) => _.throttle func, threshold

    constructor: (@scope, @el, @attrs) ->
      @BRICK_WIDTH = +@attrs.brickWidth or 0
      @BRICK_MARGIN_X = +@attrs.marginX or 0
      @BRICK_MARGIN_Y = +@attrs.marginY or 0

      @containers = []
      @bricks = []

      @throttledRepaint = @throttle(300) @repaint

      @el.css
        position: 'relative'

      @init()

    init: =>
      @throttledRepaint()

    addBrick: (brick, index) =>
      index ?= _.indexOf @el[0].children, brick.el[0]
      @bricks.splice index, 0, brick
      return this

    removeBrick: (brick) =>
      if brick?
        index = _.indexOf @bricks, brick
        @bricks.splice index, 1
        @throttledRepaint()
      return this

    fixBrick: (brick) =>
      column = @getShortestColumn()
      brick.setColumn column
      brick.reposition @getColumnPosition column
      if h = brick.getHeight()
        @update column, h + @BRICK_MARGIN_Y
      return this

    calcColumns: =>
      @checkBrickWidth()
      document.body.style.overflow = "scroll"
      @containerWidth = @el[0].clientWidth
      document.body.style.overflow = "auto"
      columns = Math.floor((@containerWidth + @BRICK_MARGIN_X) / (@BRICK_WIDTH + @BRICK_MARGIN_X))
      @marginWidth = Math.abs((@containerWidth - @BRICK_WIDTH * columns - @BRICK_MARGIN_X * (columns - 1)) / 2)
      @containers = new Array columns
      @containers[i] = 0 for container, i in @containers
      return this

    checkBrickWidth: =>
      return if @attrs.brickWidth > 0
      width = @el[0].children[0]?.offsetWidth
      @BRICK_WIDTH = width or 100
      return this

    getShortestColumn: =>
      @containers.indexOf @containers.slice().sort((a, b) ->
        a - b
      )[0]

    getTallestColumn: =>
      @containers.slice().sort((a, b) ->
        b - a
      )[0]

    getColumnPosition: (column) =>
      left: column * (@BRICK_WIDTH + @BRICK_MARGIN_X) + @marginWidth
      top: @containers[column]

    update: (column, height) ->
      @containers[column] += height
      return this

    repaint: (fromBrick) =>
      @calcColumns()
      @fixBrick brick for brick in @bricks

      @el.css height: @getTallestColumn()

      return this
  ]

  link: (scope, element, attrs, wall) ->
    angular.element($window).on "resize", wall.throttledRepaint
    scope.$on "$destroy", ->
      angular.element($window).off "resize", wall.throttledRepaint

]
