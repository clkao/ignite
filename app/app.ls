# Declare app level module which depends on filters, and services
PDFJS.workerSrc = '/pdf.worker.js'

angular.module "App" <[app.templates ngMaterial ui.router pdf angular-files-model filereader ngStorage ui.sortable ngAnimate]>

.config <[$stateProvider $urlRouterProvider $locationProvider]> ++ ($stateProvider, $urlRouterProvider, $locationProvider) ->
  $stateProvider
    .state 'about' do
      url: '/about'
      templateUrl: 'app/partials/about.html'
      controller: "About"
    # Catch all
  $urlRouterProvider
    .otherwise('/about')

  # Without serve side support html5 must be disabled.
  $locationProvider.html5Mode true

.run <[$rootScope $state $stateParams $location $window $anchorScroll]> ++ ($rootScope, $state, $stateParams, $location, $window, $anchorScroll) ->
  $rootScope.$state = $state
  $rootScope.$stateParam = $stateParams
  $rootScope.config_build = require 'config.jsenv' .BUILD
  $rootScope.$on '$stateChangeSuccess' (e, {name}) ->
    window?ga? 'send' 'pageview' page: $location.$$path, title: name

.controller AppCtrl: <[$scope $location $rootScope $sce $mdSidenav]> ++ (s, $location, $rootScope, $sce, $mdSidenav) ->
  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''

  s.hover = ->
    $mdSidenav 'left' .open!

.controller About: <[$rootScope $http $scope $mdSidenav $localStorage]> ++ ($rootScope, $http, $scope, $mdSidenav, $localStorage) ->
    $rootScope.files = $scope.files = $localStorage.files || []
    $rootScope.activeTab = 'about'
    $rootScope.pdfUrl = '/'
    $scope.toggleLeft = -> $mdSidenav('left').toggle!

.controller PDFPlayerCtrl: <[$rootScope $scope $interval]> ++ ($rootScope, $scope, $interval) ->
  per-page = 15000
  $scope.$parent.ready = false
  $rootScope.started = false
  $rootScope.pageProgress = 0
  $rootScope.slideProgress = 5
  $scope.$parent.onLoad = ->
    # ready
    $scope.$parent.ready = true
    #start!
  $scope.start = ->
    $scope.page = 1
    $rootScope.started = true
    $rootScope.pageProgress = 0
    $interval (->
      $('.md-bar2').css transition: "all #{per-page / 1000}s linear"
      $rootScope.pageProgress = 100
    ), 100, 1
    $rootScope.stop = $interval (->
      $scope.page += 1
      if $scope.page > $scope.pageCount
        $rootScope.started = false
        $scope.$parent.ready = false
        return $interval.cancel $rootScope.stop
      $scope.goNext!
      $rootScope.slideProgress += 100 / $scope.pageCount
      $('.md-bar2').css transition: ''
      $rootScope.pageProgress = 0
      $interval (->
        $('.md-bar2').css transition: "all #{per-page / 1000}s linear"
        $rootScope.pageProgress = 100
      ), 100, 1
    ), per-page, $scope.pageCount
  $scope.end = ->
    $rootScope.hasPDF = false
  $scope.$watch "page > pageCount" -> if it
    $scope.end!

.controller LeftCtrl: <[$rootScope $scope $timeout $interval $mdSidenav $log FileReader $localStorage]> ++ ($rootScope, $scope, $timeout, $interval, $mdSidenav, $log, FileReader, $localStorage) ->
  # sample dropbox response:
  # $scope.files = [{"bytes":2772798,"link":"https://dl.dropboxusercontent.com/1/view/2lv9585lhj8hnv0/ignite-od/au_Sandstorm-and-OpenDocument.pdf","name":"au_Sandstorm-and-OpenDocument.pdf","icon":"https://www.dropbox.com/static/images/icons64/page_white_acrobat.png"},{"bytes":2270164,"link":"https://dl.dropboxusercontent.com/1/view/nmoi7kfx3r2fynj/ignite-od/ianmakgill-what-happens-when-you-use-open-data-a-story-from-the-uk.pdf","name":"ianmakgill-what-happens-when-you-use-open-data-a-story-from-the-uk.pdf","icon":"https://www.dropbox.com/static/images/icons64/page_white_acrobat.png"}]
  $scope.files = $localStorage.files || []
  $scope.trigger = (file) ->
    $scope.close!
    $scope.reset!
    <- $timeout _, 200ms
    console.log it
    if 'File' is typeof! file
      FileReader.readAsDataURL(file, $scope)
      .then (resp) ->
        $rootScope.pdfUrl = resp
        $rootScope.hasPDF = true
      return

    $rootScope.pdfUrl = file.link
    $rootScope.hasPDF = true

  $scope.dropbox = -> Dropbox.choose do
    success: (files) ->
      console.log JSON.stringify files
      $scope.$apply -> $localStorage.files = $rootScope.files = $scope.files = files
    link-type: 'direct'
    multiselect: true
    extensions: ['.pdf']

  $scope.$watch 'localFiles' (files) -> if files?length
    $localStorage.files = []
    $scope.files = [file for file in files]
    $rootScope.files = $scope.files

  $scope.reset = ->
    $rootScope.hasPDF = false
    if $rootScope.stop
      $interval.cancel $rootScope.stop

  $scope.close = ->
    $mdSidenav 'left' .close!
