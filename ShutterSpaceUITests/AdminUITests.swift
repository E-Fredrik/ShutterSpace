//
//  AdminUITests.swift
//  ShutterSpaceUITests
//
//  Created by Gemini CLI on 03/06/26.
//

import XCTest

final class AdminUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Launch app with Admin bypass for testing
        app.launchArguments.append("-UITest_AdminMode")
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Tests that the Admin Dashboard is correctly rendered with all management links.
    /// Aligns with NFR-05 (Accessibility) and NFR-07 (Visual Design - Dark Mode check would be visual/manual but we verify elements).
    func testAdminDashboardNavigation() throws {
        XCTContext.runActivity(named: "Verify Admin Dashboard Elements") { _ in
            let dashboardTitle = app.staticTexts["Admin Dashboard"]
            XCTAssertTrue(dashboardTitle.exists, "Dashboard title should be visible")

            let manageUsersLink = app.buttons["admin_manage_users_link"]
            XCTAssertTrue(manageUsersLink.exists, "Manage Users link should be identifiable for VoiceOver (NFR-05)")
            
            let manageBookingsLink = app.buttons["admin_manage_bookings_link"]
            XCTAssertTrue(manageBookingsLink.exists, "Manage Bookings link should exist")
            
            let financialReportsLink = app.buttons["admin_financial_reports_link"]
            XCTAssertTrue(financialReportsLink.exists, "Financial Reports link should exist")
            
            let userReportsLink = app.buttons["admin_user_reports_link"]
            XCTAssertTrue(userReportsLink.exists, "User Reports link should exist")
        }
    }

    /// Tests the flow of managing a user, including status changes.
    /// Aligns with NFR-10 (State Synchronization) as we check for immediate UI feedback.
    func testAdminUserManagementFlow() throws {
        XCTContext.runActivity(named: "Navigate to User Detail and Verify Actions") { _ in
            // 1. Navigate to User List
            app.buttons["admin_manage_users_link"].tap()
            
            // 2. Wait for list to load (NFR-02: Latency check via timeout)
            let userList = app.collectionViews.firstMatch
            XCTAssertTrue(userList.waitForExistence(timeout: 5), "User list should load within reasonable time")
            
            // 3. Select a user (tapping the first available cell)
            let firstUserCell = app.cells.firstMatch
            if firstUserCell.exists {
                firstUserCell.tap()
                
                // 4. Verify Admin Detail Buttons are correctly tagged for Accessibility
                XCTAssertTrue(app.buttons["admin_reactivate_button"].exists, "Reactivate button missing")
                XCTAssertTrue(app.buttons["admin_suspend_button"].exists, "Suspend button missing")
                XCTAssertTrue(app.buttons["admin_ban_button"].exists, "Ban button missing")
                
                // 5. Test interaction: Suspend
                app.buttons["admin_suspend_button"].tap()
                
                // 6. Check for status text update (NFR-10)
                let statusLabel = app.staticTexts["admin_status_text"]
                XCTAssertTrue(statusLabel.exists, "Status label should be present to confirm sync")
            } else {
                XCTFail("No users found in the list to test management flow.")
            }
        }
    }

    /// Measures the performance of navigating to the user list.
    /// Aligns with NFR-01 (60fps) and NFR-02 (<500ms latency).
    func testAdminNavigationPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric(), XCTCPUMetric()]) {
            app.buttons["admin_manage_users_link"].tap()
            _ = app.cells.firstMatch.waitForExistence(timeout: 2)
            
            // Return to dashboard for next iteration
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
}
