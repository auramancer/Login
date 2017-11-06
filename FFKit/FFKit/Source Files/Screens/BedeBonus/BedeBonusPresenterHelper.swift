//
//  BonusPresenterHelper.swift
//  FFKit
//
//  Created by Vinoth Palanisamy on 18/10/2016.
//  Copyright © 2016 mkodo. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
//private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
//// Consider refactoring the code to use the non-optional operators.
//private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l > r
//  default:
//    return rhs < lhs
//  }
//}


class BedeBonusPresenterHelper {
  
  // MARK: Helpers
  
  func bonusAmount(from bonus: Bonus) -> Amount {
    return Amount(inGBP: amountString(bonus.amount),
                  contributionsInGBP: bonus.status == .partQualified ? amountString(bonus.currentAccumulation) : amountString(bonus.currentContributions) ,
                  targetInGBP: targetAmount(from: bonus))
  }
  
  func amountString(_ amount: Double) -> String {
    return "£\(String(format: "%.2f", amount))"
  }
  
  func percentage(from bonus: Bonus) -> Percentage {
    let percentNumber = percentageNumber(from: bonus)
    return Percentage(number: percentNumber,
                      string: percentageString(percentNumber),
                      available: isPercentageAvailable(of: bonus.type))
  }
  
  func bonusTimer(from bonus: Bonus) -> BonusTimer? {
    if isDatesValid(bonus.activatedTime, and: bonus.qualificationEndDate) {
      return formatBonusTimer(from: dateComponent(from: bonus))
    }
    return nil
  }
  
  func isTimer(_ type: BonusType) -> Bool {
    return type == .cashbackOnNetLosses
  }
  
  func isWagering(_ type: BonusType) -> Bool {
    return type == .cashbackOnTotalStake || type == .depositOverPeriod
  }
  
  func format(_ expiry: String) -> String {
    return expiry.characters.count == 0 ? "None" : expiry
  }
  
  // MARK: Private Helpers
  
  private func isPercentageAvailable(of type: BonusType) -> Bool {
    return isWagering(type) || isTimer(type)
  }
  
  private func percentageNumber(from bonus: Bonus) -> Double {
    if isTimer(bonus.type) {
      return percent(from: bonus.activatedTime, and: bonus.qualificationEndDate)
    }
    let percentNumber = percent(from: bonus.currentAccumulation, and: bonus.targetAccumulation)
    return percentNumber.isNaN ? 0 : percentNumber
  }
  
  private func percentageString(_ number: Double) -> String {
    return "\(String(format: isInteger(number) ? "%.f" : "%.2f", number))%"
  }
  
  private func isInteger(_ number: Double) -> Bool {
    return floor(number) == number
  }
  
  private func percent(from current: Double, and target: Double) -> Double {
    guard current<=target else {
      return 100
    }
    return current / target * 100
  }
  
  private func percent(from active: String, and expiry: String) -> Double {
    guard isDatesValid(active, and: expiry) else {
      return 0
    }
    let activeDate = date(from: active)
    let expiryDate = date(from: expiry)
    
    let difference = expiryDate.timeIntervalSince(activeDate)
    let differenceFromNow = expiryDate.timeIntervalSinceNow
    return round((difference - differenceFromNow)/difference * 100)
  }
  
  private func dateComponent(from bonus: Bonus) -> DateComponents? {
    let today = Date()
    let expiryDay = date(from: bonus.qualificationEndDate)
    
    let calendar = Calendar(identifier: .gregorian)
    let dateComponents = calendar.dateComponents([.day, .hour, .minute], from: today, to: expiryDay)
    return dateComponents
  }
  
  private func formatBonusTimer(from dateComponents: DateComponents?) -> BonusTimer {
    if dateComponents!.day! > 0 {
      return BonusTimer(time: "\(dateComponents!.day!)", string: "DAYS")
    }
    if dateComponents!.hour! > 0 {
      return BonusTimer(time: "\(dateComponents!.hour!)", string: "HOURS")
    }
    return BonusTimer(time: "\(dateComponents!.minute!)", string: "MINS")
  }
  
  private func isDatesValid(_ active: String, and expiry: String) -> Bool {
    guard !active.isEmpty && !expiry.isEmpty else {
      return false
    }
    
    let expiryDate = date(from: expiry)
    let today = Date()
    
    guard today.compare(expiryDate) == .orderedAscending else {
      return false
    }
    return true
  }
  
  private func date(from dateString: String) -> Date {
    return dateFormatter().date(from: dateString) ?? Date()
  }
  
  private func format(_ date: Date) -> String {
    return dateFormatter().string(from: date)
  }
  
  private func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter
  }
  
  private func targetAmount(from bonus: Bonus) -> String {
    if bonus.status == .partQualified  {
      return bonus.targetAccumulation == 0 ? "None" : amountString(bonus.targetAccumulation)
    }
    return amountString(bonus.wageringTarget)
  }
  
  func icon(for type: BonusType) -> UIImage? {
    return UIImage(named: iconName(for: type))
  }
  
  func iconName(for type: BonusType) -> String {
    if type == .firstDeposit || type == .deposit {
      return "bonus_piggy"
    }
    
    if type == .depositOverPeriod {
      return "bonus_timer"
    }
    
    if type == .cashbackOnTotalStake || type == .cashbackOnNetLosses {
      return "bonus_coins"
    }
    
    return "bonus_star"
  }
}

