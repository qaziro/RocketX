import XCTest

final class SettingsUITest: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws { }

    func testSettingsUI() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launchArguments += ["-AppleLocale", "en_US"]
        app.launch()
        
        let rocketInfoScrollView = app.scrollViews["scroll.info.id"]

        app.buttons["button.settings.id"].firstMatch.forceTap()
        
        app.segmentedControls["picker.height.id"].buttons["m"].tap()
        app.segmentedControls["picker.diameter.id"].buttons["m"].tap()
        app.segmentedControls["picker.mass.id"].buttons["kg"].tap()
        app.segmentedControls["picker.payload.id"].buttons["kg"].tap()
        
        app.buttons["button.close.id"].tap()
        
        XCTAssertTrue(rocketInfoScrollView.staticTexts["Height, m"].exists)
        XCTAssertTrue(rocketInfoScrollView.staticTexts["Diameter, m"].exists)
        XCTAssertTrue(rocketInfoScrollView.staticTexts["Mass, kg"].exists)
        XCTAssertTrue(rocketInfoScrollView.staticTexts["Payload, kg"].exists)
        
        app.buttons["button.settings.id"].firstMatch.forceTap()
        
        app.segmentedControls["picker.height.id"].buttons["ft"].tap()
        app.segmentedControls["picker.diameter.id"].buttons["ft"].tap()
        app.segmentedControls["picker.mass.id"].buttons["lb"].tap()
        app.segmentedControls["picker.payload.id"].buttons["lb"].tap()
        
        app.buttons["button.close.id"].tap()
        
        XCTAssertTrue(rocketInfoScrollView.staticTexts["Height, ft"].exists)
        XCTAssertTrue(rocketInfoScrollView.staticTexts["Diameter, ft"].exists)
        XCTAssertTrue(rocketInfoScrollView.staticTexts["Mass, lb"].exists)
        XCTAssertTrue(rocketInfoScrollView.staticTexts["Payload, lb"].exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension XCUIElement {
    func forceTap() {
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVectorMake(0.0, 0.0))
            coordinate.tap()
        }
    }
}
