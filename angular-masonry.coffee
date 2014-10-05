"use strict"

debounce = (func, threshold) ->
  timeout = null
  (args...) ->
    obj = this
    delayed = ->
      func.apply(obj, args)
      timeout = null
    if timeout
      clearTimeout(timeout)
    timeout = setTimeout delayed, threshold || 100


angular.module "angularMasonryWall", [
  'angularMasonryBrick'
]

.directive "masonryWall", ["$window", ($window) ->
  restrict: "EA"
  scope: yes

  controller: ['$scope', '$element', '$attrs', class Wall
    debounce: (threshold) => (func) => debounce func, threshold

    constructor: (@scope, @el, @attrs) ->
      @BRICK_WIDTH = +@attrs.brickWidth or 0
      @BRICK_MARGIN_X = +@attrs.marginX or 0
      @BRICK_MARGIN_Y = +@attrs.marginY or 0

      @containers = []
      @bricks = []

      @debouncedRepaint = @debounce(300) @repaint

      @el.css
        position: 'relative'

      @init()

    init: =>
      @debouncedRepaint()

    addBrick: (brick) =>
      @bricks.push brick if brick?
      return this

    removeBrick: (brick) =>
      if brick?
        index = @bricks.indexOf brick
        @bricks.splice index, 1
        @debouncedRepaint()
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
      width = @el[0].children[0].offsetWidth
      @BRICK_WIDTH = width if width > 0
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
    angular.element($window).on "resize", wall.debouncedRepaint
    scope.$on "$destroy", ->
      angular.element($window).off "resize", wall.debouncedRepaint

]
