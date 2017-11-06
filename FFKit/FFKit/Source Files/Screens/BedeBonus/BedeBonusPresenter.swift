//
//  BedeBonusPresenter.swift
//  FFKit
//
//  Created by Vinoth Palanisamy on 14/10/2016.
//  Copyright (c) 2016 mkodo. All rights reserved.
//

import UIKit

struct ProgressingBonusOutline {
  let name: String
  let icon: UIImage?
}

protocol BedeBonusUserInterfaceInput: class {
//  func refresh()
//  
//  func showQualifiedBonuses(_: [PresentableBonus])
//  func showAvailableBonuses(_: [PresentableBonus])
//  func showSingleBonus(_: PresentableBonus)
//  
//  func showAlert(withMessage message: String)
  
  func showProgressingBonuses(_ bonuses: [ProgressingBonusOutline])
}

protocol BedeBonusInteractorInput: class {
  func inquireProgressingBonuses()
  func inquireAvailableBonuses()
  func inquireBonus(withCode: String)
  func inquireBonus(withID: String)
  func optInBonus(withCode: String)
  func optOutBonus(withID: String)
}

class BedeBonusPresenter: BedeBonusPresenterHelper {
  var interactor: BedeBonusInteractorInput?
  weak var userInterface: BedeBonusUserInterfaceInput?
  
  // MARK: From UI
  func inquireInitialData() {
    interactor?.inquireProgressingBonuses()
    interactor?.inquireAvailableBonuses()
  }
  
  func inquireBonus(withCode code: String) {
    interactor?.inquireBonus(withCode: code)
  }
  
  func inquireBonus(withID id: String) {
    interactor?.inquireBonus(withID: id)
  }
  
  func optInBonus(withCode code: String) {
    interactor?.optInBonus(withCode: code)
  }
  
  func optOutBonus(withID id: String) {
    interactor?.optOutBonus(withID: id)
  }

  // MARK: From interactor
  
  func showProgressingBonuses(_ bonuses: [Bonus]) {
    
  }
  
  func showAvailableBonuses(_ bonuses: [Bonus]) {
    
  }
  
  func showBonus(_ bonus: Bonus) {
    
  }
  
//  func didFetchQualifiedBonuses(_ bonuses: [Bonus]) {
//    let presentableBonuses = bonuses.flatMap( { bonus in
//      PresentableBonus(promoId: bonus.bonusId,
//                       promoName: bonus.name,
//                       description: bonus.description,
//                       promoCode:  bonus.promoCode,
//                       promoStatus: BonusStatus.partQualified.description,
//                       promoType: bonus.type.description,
//                       optInDate: bonus.activatedTime,
//                       expiryDate: bonus.qualificationEndDate,
//                       termsAndConditions: bonus.termsAndConditions,
//                       canOptOut: true,
//                       isTimeBonus: isTimer(bonus.type),
//                       isWagering: isWagering(bonus.type),
//                       amount: bonusAmount(from: bonus) ,
//                       percentage: percentage(from: bonus),
//                       bonusTimer: bonusTimer(from: bonus),
//                       icon: icon(for: bonus.type))
//    })
//    userInterface?.showQualifiedBonuses(presentableBonuses)
//  }
//  
//  func didFetchAvailableBonuses(_ bonuses: [Bonus]) {
//    let presentableBonuses = bonuses.flatMap { bonus in
//      PresentableBonus(promoId: bonus.bonusId,
//                       promoName: bonus.name,
//                       description: bonus.description,
//                       promoCode:  bonus.promoCode,
//                       promoStatus: bonus.status.description,
//                       promoType: bonus.type.description,
//                       optInDate: bonus.activatedTime,
//                       expiryDate: bonus.expiryTime,
//                       termsAndConditions: bonus.termsAndConditions,
//                       canOptOut: true,
//                       isTimeBonus: isTimer(bonus.type),
//                       isWagering: isWagering(bonus.type),
//                       amount: bonusAmount(from: bonus) ,
//                       percentage: percentage(from: bonus),
//                       bonusTimer: bonusTimer(from: bonus),
//                       icon: icon(for: bonus.type))
//    }
//    userInterface?.showAvailableBonuses(presentableBonuses)
//  }
//  
//  func didFetchSingleBonus(_ bonus: Bonus) {
//    let presentableBonus = PresentableBonus(promoId: String(bonus.id),
//                                       promoName: bonus.name,
//                                       description: bonus.description,
//                                       promoCode:  bonus.promoCode,
//                                       promoStatus: bonus.status.description,
//                                       promoType: bonus.type.description,
//                                       optInDate: bonus.startTime,
//                                       expiryDate: bonus.endTime,
//                                       termsAndConditions: bonus.termsAndConditions,
//                                       canOptOut: false,
//                                       isTimeBonus: isTimer(bonus.type),
//                                       isWagering: isWagering(bonus.type),
//                                       amount: bonusAmount(from: bonus) ,
//                                       percentage: percentage(from: bonus),
//                                       bonusTimer: bonusTimer(from: bonus),
//                                       icon: icon(for: bonus.type))
//    userInterface?.showSingleBonus(presentableBonus)
//  }
//  
//  func didFailToFindBonus() {
//    let message = "Bonus code not recognised. Please try again."
//    showAlert(withMessage: message)
//    
////    trackError(message: message)
//  }
//  
//  func didOptInBonus(withCode bonusCode: String) {
////    guard let bonus = bonusManaged else { return }
////    
////    let message = "Great - you’ve successfully opted in to \(bonus.promoName)"
////    showAlert(withMessage: message)
////    
////    trackButton("PromoOptIn-\(bonus.promoName)")
//  }
//  
//  func didOptOutBonus(withID bonusID: String) {
////    guard let bonus = bonusManaged else { return }
////    
////    userInterface?.refresh()
////    
////    trackButton("PromoOptOut-\(bonus.promoName)")
//  }
//  
//  func didEnconterError(_ error: Error) {
//    showAlert(withMessage: error.localizedDescription)
//  }
//  
//  private func showAlert(withMessage message: String) {
//    userInterface?.showAlert(withMessage: message)
//    userInterface?.refresh()
//  }
//  
//  private func trackButton(_ label: String) {
////    TrackingManager.gaTrackButtonWhenLoggedIn(label: label)
//  }
}
