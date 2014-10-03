"use strict"

angular.module "masonryLayout", []

.directive "masonryBrick", [->
  controller: class
    constructor: () ->
      @column = null

  restrict: "EA"
  link: (scope, element, attrs, ctrl) ->
    scope.$on "$destroy", ->
]

.directive "masonryWall", [
  "$window"
  ($window) ->

    controller: class
      constructor: ->
        @imagesLoadCount = 0
        @totalItemCount = 0
        @resizing = false
        @windowWidth = $window.innerWidth
        @containers
        @containerWidth
        @marginWidth

      readAttrs: (marginX, marginY, @brickWidth) ->
        @BRICK_WIDTH = @brickWidth or 0
        @BRICK_MARGIN_X = marginX or 0
        @BRICK_MARGIN_Y = marginY or 0

      docHeight: -> $window.innerHeight * 2.5

      reset: ($element) ->
        @checkbrickWidth $element[0].children[0].offsetWidth
        document.body.style.overflow = "scroll"
        @containerWidth = $element[0].clientWidth
        document.body.style.overflow = "auto"
        columns = Math.floor((@containerWidth + @BRICK_MARGIN_X) / (@BRICK_WIDTH + @BRICK_MARGIN_X))
        @marginWidth = Math.abs((@containerWidth - @BRICK_WIDTH * columns - @BRICK_MARGIN_X * (columns - 1)) / 2)
        @containers = new Array columns
        @containers[i] = 0 for container, i in @containers

      checkbrickWidth: (firstElWidth) ->
        return if @brickWidth > 0
        @BRICK_WIDTH = firstElWidth if firstElWidth > 0

      setWindowWidth: ->
        @windowWidth = $window.innerWidth

      shortest: ->
        @containers.indexOf @containers.slice().sort((a, b) ->
          a - b
        )[0]

      shouldResize: -> not @resizing

      tallest: ->
        @containers.slice().sort((a, b) ->
          b - a
        )[0]

      update: (column, height) ->
        @containers[column] += height

    restrict: "EA"
    link: (scope, element, attrs, ctrl) ->
      ctrl.readAttrs(+attrs.marginX, +attrs.marginY, +attrs.brickWidth)
      homeColumn = undefined

      setNewCoordinates = (el) ->
        homeColumn = ctrl.shortest()
        newLeft = homeColumn * (ctrl.BRICK_WIDTH + ctrl.BRICK_MARGIN_X) + ctrl.marginWidth
        newTop = ctrl.containers[homeColumn]

        angular.element(el).css
          left: newLeft
          top: newTop

      repaint = _.debounce ->
          if ctrl.shouldResize()
            imageContainers = element[0].children
            ctrl.resizing = true
            ctrl.setWindowWidth()

            #Reset wall attributes
            ctrl.reset element
            for container in imageContainers
              setNewCoordinates container

              ctrl.update homeColumn, container.scrollHeight + ctrl.BRICK_MARGIN_Y

            element.css height: ctrl.tallest() + "px"
            ctrl.resizing = false
        , 300

      fixBrick = (brick) ->
        setNewCoordinates brick
        ctrl.update homeColumn, brick.scrollHeight + ctrl.BRICK_MARGIN_Y

        #this is the last image loaded
        #correct parent height
        if ++ctrl.imagesLoadCount is ctrl.totalItemCount
          element.css height: ctrl.tallest()

      attachListener = (brick) ->

        angular.element(brick).css
          position: 'absolute'
          # visibility: 'hidden'

        imagesLoaded brick, -> fixBrick brick

      # wall.imagesLoadCount++;
      scope.$watch ->
        element[0].children.length
      , (newCount, oldCount) ->
        return if newCount is oldCount
        if oldCount is 0
          element.css height: 0
          ctrl.totalItemCount = 0
          ctrl.imagesLoadCount = 0

          #Reset wall attributes
          ctrl.reset element
        ctrl.totalItemCount = newCount
        element.css height: ctrl.tallest() + (ctrl.docHeight()) + "px"

        i = oldCount
        while i < newCount
          attachListener element[0].children[i]
          i++

      angular.element($window).on "resize", repaint

      scope.$on "$destroy", ->
        angular.element($window).off "resize", repaint

      element.css position: "relative"
]
