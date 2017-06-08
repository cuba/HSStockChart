# StockChart

[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5939a9e8591e9900016b0839&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5939a9e8591e9900016b0839/build/latest?branch=master)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg?style=flat)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg?style=flat)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Original code by [Hanson Zhang](https://github.com/zyphs21/HSStockChart)

![](https://github.com/cuba/HSStockChart/blob/master/DemoScreenshot/screenshot_landscape.jpg)

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Credits](#credits)
- [License](#license)

## Features
- [x] Candlestick Graph
- [x] Scrollable chart
- [x] Hold to see details

## Requirements

- iOS 8.0+
- Swift 3

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate StockChart into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "cuba/StockChart" ~> 1.1
```

Run `carthage update` to build the framework and drag the built `StockChart.framework` into your Xcode project.

## Usage
See the included example [ViewController](https://github.com/cuba/StockChart/blob/master/HSStockChartDemo/StockChartDemo/ViewController.swift)

## Credits
Original code by [Hanson Zhang](https://github.com/zyphs21/HSStockChart).  
Awesome work, but not a framework and non-customizable :(

The original code was heavily modified by Jacob Sikorski

## License

Released under the MIT license. [See LICENSE](https://github.com/cuba/StockChart/blob/master/LICENSE) for details
