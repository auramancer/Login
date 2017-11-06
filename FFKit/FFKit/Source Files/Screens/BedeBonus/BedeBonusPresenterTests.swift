//
//  BedeBonusPresenterTests.swift
//  FFKit
//
//  Created by Vinoth Palanisamy on 18/10/2016.
//  Copyright © 2016 mkodo. All rights reserved.
//
@testable import FFKit
//@testable import FFKit
import XCTest

class BedeBonusInteractorSpy: BedeBonusInteractorInput {
  var wasInquiredProgressingBonuses = false
  var wasInquiredAvailableBonuses = false
  var codeOfBonusInquired: String?
  var idOfBonusInquired: String?
  var codeOfBonusOptedIn: String?
  var idOfBonusOptedOut: String?
  
  func inquireProgressingBonuses() {
    wasInquiredProgressingBonuses = true
  }
  
  func inquireAvailableBonuses() {
    wasInquiredAvailableBonuses = true
  }
  
  func inquireBonus(withCode code: String) {
    codeOfBonusInquired = code
  }
  
  func inquireBonus(withID id: String) {
    idOfBonusInquired = id
  }
  
  func optInBonus(withCode code: String) {
    codeOfBonusOptedIn = code
  }
  
  func optOutBonus(withID id: String) {
    idOfBonusOptedOut = id
  }
}

class BedeBonusUserInterfaceSpy: BedeBonusUserInterfaceInput {
  var refreshed = false
  var qualifiedBonuses = [PresentableBonus]()
  var availableBonuses = [PresentableBonus]()
  var singleBonus: PresentableBonus?
  var alertMessage: String?
  
  func refresh() {
    refreshed = true
  }
  
  func showQualifiedBonuses(_ bonuses: [PresentableBonus]) {
    qualifiedBonuses = bonuses
  }
  
  func showAvailableBonuses(_ bonuses: [PresentableBonus]) {
    availableBonuses = bonuses
  }
  
  func showSingleBonus(_ bonus: PresentableBonus) {
    singleBonus = bonus
  }
  
  func showAlert(withMessage message: String) {
    alertMessage = message
  }
}

class BedeBonusPresenterTests: XCTestCase {
  var presenter: BedeBonusPresenter!
  var interactor: BedeBonusInteractorSpy!
  var userInterface: BedeBonusUserInterfaceSpy!
  
  override func setUp() {
    super.setUp()
    
    interactor = BedeBonusInteractorSpy()
    userInterface = BedeBonusUserInterfaceSpy()
    
    presenter = BedeBonusPresenter()
    presenter.interactor = interactor
    presenter.userInterface = userInterface
  }
  
  // MARK: From UI
  
  func testInquireInitialData() {
    presenter.inquireInitialData()
    
    XCTAssertTrue(interactor.wasInquiredProgressingBonuses)
    XCTAssertTrue(interactor.wasInquiredAvailableBonuses)
  }
  
  func testInquireBonusWithCode() {
    let code = "QWERTY"
    
    presenter.inquireBonus(withCode: code)
    
    XCTAssertEqual(interactor.codeOfBonusInquired, code)
  }
  
  func testInquireBonusWithID() {
    let id = "123456"
    
    presenter.inquireBonus(withID: id)
    
    XCTAssertEqual(interactor.idOfBonusInquired, id)
  }
  
  func testOptInBonus() {
    let code = "QWERTY"
    
    presenter.optInBonus(withCode: code)
    
    XCTAssertEqual(interactor.codeOfBonusOptedIn, code)
  }
  
  func testOptOutBonus() {
    let id = "123456"
    
    presenter.optOutBonus(withID: id)
    
    XCTAssertEqual(interactor.idOfBonusOptedOut, id)
  }
  
  // MARK: From interactor
  
  func testShowProgressingBonuses() {
    presenter.showProgressingBonuses()
    
    
  }
  
  func testAvailableBonuses() {
    
  }
  
  func testBonusDetails() {
    
  }
}
