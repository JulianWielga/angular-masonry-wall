"use strict"

debounce = (func, threshold, execAsap) ->
  timeout = null
  (args...) ->
    obj = this
    delayed = ->
      func.apply(obj, args) unless execAsap
      timeout = null
    if timeout
      clearTimeout(timeout)
    else if (execAsap)
      func.apply(obj, args)
    timeout = setTimeout delayed, threshold || 100

angular.module "masonryLayout", []

.directive "masonry", [
  "$window", "$rootScope"
  ($window, $rootScope) ->
    class Wall
      constructor: (marginX, marginY, @imgWidth) ->
        @IMG_WIDTH = @imgWidth or 0
        @IMG_MARGIN_X = marginX or 0
        @IMG_MARGIN_Y = marginY or 0
        @imagesLoadCount = 0
        @totalItemCount = 0
        @resizing = false
        @windowWidth = $window.innerWidth
        @containers
        @containerWidth
        @marginWidth

      docHeight: -> $window.innerHeight * 2.5

      reset: ($element) ->
        @checkImgWidth $element[0].children[0].offsetWidth
        document.body.style.overflow = "scroll"
        @containerWidth = $element[0].clientWidth
        document.body.style.overflow = "auto"
        columns = Math.floor((@containerWidth + @IMG_MARGIN_X) / (@IMG_WIDTH + @IMG_MARGIN_X))
        @marginWidth = Math.abs((@containerWidth - @IMG_WIDTH * columns - @IMG_MARGIN_X * (columns - 1)) / 2)
        @containers = new Array columns
        @containers[i] = 0 for container, i in @containers

      checkImgWidth: (firstElWidth) ->
        return if @imgWidth > 0
        @IMG_WIDTH = firstElWidth if firstElWidth > 0

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

    restrict: "A"
    link: (scope, element, attrs, ctrl) ->
      wall = new Wall(+attrs.marginX, +attrs.marginY, +attrs.brickWidth)
      homeColumn = undefined
      newLeft = undefined
      newTop = undefined

      setNewCoordinates = (el) ->
        homeColumn = wall.shortest()
        newLeft = homeColumn * (wall.IMG_WIDTH + wall.IMG_MARGIN_X) + wall.marginWidth
        newTop = wall.containers[homeColumn]

        angular.element(el).css
          left: newLeft
          top: newTop

      repaint = debounce ->
          if wall.shouldResize()
            imageContainers = element[0].children
            wall.resizing = true
            wall.setWindowWidth()

            #Reset wall attributes
            wall.reset element
            for container in imageContainers
              setNewCoordinates container

              wall.update homeColumn, container.scrollHeight + wall.IMG_MARGIN_Y

            element.css height: wall.tallest() + "px"
            wall.resizing = false
        , 300

      fixBrick = (brick) ->
        setNewCoordinates brick
        wall.update homeColumn, brick.scrollHeight + wall.IMG_MARGIN_Y

        #this is the last image loaded
        #correct parent height
        if ++wall.imagesLoadCount is wall.totalItemCount
          element.css height: wall.tallest()

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
          wall.totalItemCount = 0
          wall.imagesLoadCount = 0

          #Reset wall attributes
          wall.reset element
        wall.totalItemCount = newCount
        element.css height: wall.tallest() + (wall.docHeight()) + "px"

        i = oldCount
        while i < newCount
          attachListener element[0].children[i]
          i++

      angular.element($window).on "resize", repaint

      scope.$on "$destroy", ->
        angular.element($window).off "resize", repaint

      element.css position: "relative"
]
