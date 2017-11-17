//
//  Compliance.swift
//  LiveCasino
//
//  Created by Vinoth Palanisamy on 25/04/2017.
//  Copyright © 2017 Grosvenor. All rights reserved.
//

import Foundation

enum Compliance {
 
  case contactUs, faqs, aboutUs, terms, privacy, alderneyGambling, gameCareCertified, problemGambling, ukGambling, keepItFun, rankLeisure, gambleAware
  
  var url: String {
    switch self {
    case .contactUs:
      return "livecasino://help"
    case .faqs:
      return "https://www.grosvenorcasinos.com/faqs"
    case .aboutUs:
      return "https://www.grosvenorcasinos.com/about-us"
    case .terms:
      return termsUrL
    case .privacy:
      return termsPrivacyUrL
    case .alderneyGambling:
      return "http://www.gamblingcontrol.org"
    case .ukGambling:
      return "https://secure.gamblingcommission.gov.uk/gccustomweb/PublicRegister/PRSearch.aspx?ExternalAccountId=38750"
    case .keepItFun:
      return "https://keepitfun.rank.com"
    case .rankLeisure:
      return "http://www.rank.com"
    case .gambleAware:
      return "https://www.begambleaware.org/"
    case .gameCareCertified:
      return "https://www.grosvenorcasinos.com/Static/GamCare"
    case .problemGambling:
      return "http://www.gamcare.org.uk/"
    }
  }
  
  var rangeValue: String {
    switch self {
    case .contactUs:
      return "Contact Us"
    case .faqs:
      return "FAQs"
    case .aboutUs:
      return "About Us"
    case .privacy:
      return "Privacy & Cookie Policy"
    case .terms:
      return "Terms & Conditions"
    case .alderneyGambling:
      return "Alderney Gambling Control Commission"
    case .ukGambling:
      return "UK Gambling Commission"
    case .keepItFun:
      return "Keep it Fun!"
    case .rankLeisure:
      return "Rank Leisure Holdings Ltd"
    case .gambleAware:
      return "BeGambleAware.org"
    default:
      return ""
    }
  }
  
  
  private var termsUrL: String {
//    if let configResponse = BGOAccountManager.shared().depositLimitsURLsResponse , configResponse.termsConditionsUrl != .none {
//      return configResponse.termsConditionsUrl
//    }
    return "https://www.grosvenorcasinos.com/static/termsandconditions"
  }
  
  private var termsPrivacyUrL: String {
//    if let configResponse = BGOAccountManager.shared().depositLimitsURLsResponse , configResponse.termsConditionsUrl != .none {
//      return configResponse.termsConditionsUrl
//    }
    return "https://www.grosvenorcasinos.com/static/termsandconditions#privacy"
  }

}
