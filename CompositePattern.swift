//
//  CompositePattern.swift
//  BigB
//
//  Created by Rowin Shahi on 11/29/16.
//  Copyright © 2016 BigBSoft. All rights reserved.
//

/**
 
 What is the Composite Pattern?
 
 Composite pattern is used where we need to treat a group of objects in similar way as a single object. Composite pattern composes objects in term of a tree structure to represent part as well as whole hierarchy. This type of design pattern comes under structural pattern as this pattern creates a tree structure of group of objects.
 
 This pattern creates a class that contains group of its own objects. This class provides ways to modify its group of same objects.
 
 It provides a way to break up code into smaller, succinct units, and makes it simple to change code later.
 
 Validator Protocol
 Individual Validators
 Composite Validator
 Validator Configurator
 Example of it used
 
 */

import Foundation

// 1.  The result type that will be returned for each validator:
enum ValidatorResult {
  case valid
  case invalid(error: Error)
}

// 2. Validator Protocol
protocol Validator {
  func validateValue(_ value: String) -> ValidatorResult
}

// 3. Define Email Error Type
enum EmailValidatorError: Error {
  case empty
  case invalidFormat
}

// 3.1. Define Password Error Type
enum PasswordValidatorError: Error {
  case empty
  case tooShort
  case noUppercaseLetter
  case noLowercaseLetter
  case noNumber
}

// 4.0. Empty String Validator
struct EmptyStringValidator: Validator {
  
  private let invalidError: Error
  
  init(invalidError: Error) {
    self.invalidError = invalidError
  }
  
  func validateValue(_ value: String) -> ValidatorResult {
    if value.isEmpty {
      return .invalid(error: invalidError)
    } else {
      return .valid
    }
  }
}

// 4.1. Email Format Validator
struct EmailFormatValidator: Validator {
  func validateValue(_ value: String) -> ValidatorResult {
    let magicEmailRegexStolenFromTheInternet = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", magicEmailRegexStolenFromTheInternet)
    
    if emailTest.evaluate(with: value) {
      return .valid
    } else {
      return .invalid(error: EmailValidatorError.invalidFormat)
    }
  }
}

// 4.3. Password Length Validator
struct PasswordLengthValidator: Validator {
  
  func validateValue(_ value: String) -> ValidatorResult {
    if value.characters.count >= 8 {
      return .valid
    } else {
      return .invalid(error: PasswordValidatorError.tooShort)
    }
  }
}

// 4.4. Uppercase Letter Validator
struct UppercaseLetterValidator: Validator {
  
  func validateValue(_ value: String) -> ValidatorResult {
    let uppercaseLetterRegex = ".*[A-Z]+.*"
    
    let uppercaseLetterTest = NSPredicate(format:"SELF MATCHES %@", uppercaseLetterRegex)
    
    if uppercaseLetterTest.evaluate(with: value) {
      return .valid
    } else {
      return .invalid(error: PasswordValidatorError.noUppercaseLetter)
    }
  }
}

// 4.5. LowercaseLetterValidator
struct LowercaseLetterValidator: Validator {
  
  func validateValue(_ value: String) -> ValidatorResult {
    let uppercaseLetterRegex = "[a-z]"
    
    let uppercaseLetterTest = NSPredicate(format:"SELF MATCHES %@", uppercaseLetterRegex)
    
    if uppercaseLetterTest.evaluate(with: value) {
      return .valid
    } else {
      return .invalid(error: PasswordValidatorError.noLowercaseLetter)
    }
  }
}

// 4.6. ContainsNumberValidator
struct ContainsNumberValidator: Validator {
  
  func validateValue(_ value: String) -> ValidatorResult {
    let numberLetterRegex = "[0-9]"
    
    let numbercaseLetterTest = NSPredicate(format:"SELF MATCHES %@", numberLetterRegex)
    
    if numbercaseLetterTest.evaluate(with: value) {
      return .valid
    } else {
      return .invalid(error: PasswordValidatorError.noNumber)
    }
  }
}

// 5. Composite Validator
struct CompositeValidator: Validator {
  
  private let validators: [Validator]
  
  init(validators: Validator...) {
    self.validators = validators
  }
  
  func validateValue(_ value: String) -> ValidatorResult {
    
    for validator in validators {
      switch validator.validateValue(value) {
      case .valid:
        break
      case .invalid(let error):
        return .invalid(error: error)
      }
    }
    
    return .valid
  }
}

// 6. Validator Configurator
struct ValidatorConfigurator {
  
  // Interface
  
  static let sharedInstance = ValidatorConfigurator()
  
  func emailValidator() -> Validator {
    return CompositeValidator(validators: emptyEmailStringValidator(),
                              EmailFormatValidator())
  }
  
  func passwordValidator() -> Validator {
    return CompositeValidator(validators: emptyPasswordStringValidator(),
                              passwordStrengthValidator())
  }
  
  // Helper methods
  
  private func emptyEmailStringValidator() -> Validator {
    return EmptyStringValidator(invalidError: EmailValidatorError.empty)
  }
  
  private func emptyPasswordStringValidator() -> Validator {
    return EmptyStringValidator(invalidError: PasswordValidatorError.empty)
  }
  
  private func passwordStrengthValidator() -> CompositeValidator {
    return CompositeValidator(validators: PasswordLengthValidator(),
                              UppercaseLetterValidator(),
                              LowercaseLetterValidator(),
                              ContainsNumberValidator())
  }
}

// 7. Testing
class ValidatorTest {
  
  func tester(){
    let validatorConfigurator = ValidatorConfigurator.sharedInstance
    let emailValidator = validatorConfigurator.emailValidator()
    let passwordValidator = validatorConfigurator.passwordValidator()
    
    print(emailValidator.validateValue(""))
    print(emailValidator.validateValue("invalidEmail@"))
    print(emailValidator.validateValue("validEmail@validDomain.com"))
    
    print(passwordValidator.validateValue(""))
    print(passwordValidator.validateValue("psS$"))
    print(passwordValidator.validateValue("passw0rd"))
    print(passwordValidator.validateValue("paSSw0rd"))
    
  }
}
