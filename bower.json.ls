#!/usr/bin/env lsc -cj
angular-version = '1.3.x'

name: "angular-livescript-seed"
repo: "clkao/angular-livescript-seed"
version: "0.0.1"
main: "_public/js/app.js"
ignore: ["**/.*", "node_modules", "components"]
dependencies:
  "commonjs-require-definition": "~0.1.2"
  jquery: "~2.0.3"
  angular: angular-version
  "angular-animate": angular-version
  "angular-mocks": angular-version
  "angular-scenario": angular-version
  "angular-material": "^0.8.3"
  "angular-ui-router": "0.2.11"
  "angular-pdf": 'git://github.com/clkao/angularjs-pdf#page-fit'
  "angular-files-model": "^0.1.1"
  "angular-filereader": '1.0.4'
  "angular-ui-sortable": '^0.13.3'
  "ngstorage": "~0.3.0"

overrides:
  "angular":
    dependencies: jquery: "*"
  "angular-mocks":
    main: "README.md"
  "angular-scenario":
    main: "README.md"
  "angular-filereader"
    main: "angular-filereader.js"

resolutions:
  angular: angular-version
