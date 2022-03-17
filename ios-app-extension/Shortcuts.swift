import Foundation
import UIKit
import Intents
import IntentsUI
import CoreSpotlight

enum VoiceShortcutMutationStatus: String {
  case cancelled = "cancelled"
  case added = "added"
  case updated = "updated"
  case deleted = "deleted"
}

@objc(Shortcuts)
public class Shortcuts: RCTEventEmitter, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
  private var hasListeners = false
  private var voiceShortcuts: Array<NSObject> = []
  private var presenterViewController: UIViewController?
  private var presentShortcutCallback: RCTResponseSenderBlock?
  @objc public static var initialUserActivity: NSUserActivity?
  @objc public static var launchedFromShortcut = false
  
  @objc
  public static func requestPermissions() -> Void {
    INPreferences.requestSiriAuthorization
    {
      (authStatus: INSiriAuthorizationStatus) in
      
    }
  }

  @objc
  public static func onShortcutReceived(userActivity: NSUserActivity) -> Void {
    let userInfo = userActivity.userInfo;
    let activityType = userActivity.activityType;
    var hash: NSDictionary = [:]

    if let interaction =  userActivity.interaction {
      if let intent = interaction.intent as? TaskAddIntent {
        var dueDateString = ""

        if #available(iOS 13.0, *) {
          if let dueDateComponents = intent.dueDate {
            let calendar = Calendar.current
            let dueDateOptional = calendar.date(from: dueDateComponents)

            if let dueDate = dueDateOptional {
              let dateFormatter = ISO8601DateFormatter()
              dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
              dueDateString = dateFormatter.string(from: dueDate)
            }
          }
        }

        hash = [
          "title": intent.title,
          "dueDate": dueDateString
        ]
      }

      if let intent = interaction.intent as? ClientAddIntent {
        hash = [
          "name": intent.name
        ]
      }

      if let intent = interaction.intent as? LeadAddIntent {
        hash = [
          "type": intent.type == LeadType.project ? "project" : "event",
          "eventName": intent.eventName,
          "leadName": intent.leadName
        ]
      }

      if let intent = interaction.intent as? EventAddIntent {
        var eventDateString = ""

        if #available(iOS 13.0, *) {
          if let eventDateComponents = intent.eventDate {
            let calendar = Calendar.current
            let eventDateOptional = calendar.date(from: eventDateComponents)

            if let eventDate = eventDateOptional {
              let dateFormatter = ISO8601DateFormatter()
              dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
              eventDateString = dateFormatter.string(from: eventDate)
            }
          }
        }

        hash = [
          "eventName": intent.eventName,
          "eventDate": eventDateString
        ]
      }

      if let intent = interaction.intent as? ProjectAddIntent {
        hash = [
          "title": intent.title,
        ]
      }

      if let intent = interaction.intent as? InvoiceAddIntent {
        var dueDateString = ""

        if #available(iOS 13.0, *) {
          if let dueDateComponents = intent.dueDate {
            let calendar = Calendar.current
            let dueDateOptional = calendar.date(from: dueDateComponents)

            if let dueDate = dueDateOptional {
              let dateFormatter = ISO8601DateFormatter()
              dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
              dueDateString = dateFormatter.string(from: dueDate)
            }
          }
        }

        hash = [
          "subject": intent.subject,
          "dueDate": dueDateString
        ]
      }

      if let intent = interaction.intent as? MileageAddIntent {
        hash = [
          "purpose": intent.purpose,
          "totalMiles": intent.totalMiles
        ]
      }

      if let intent = interaction.intent as? ExpenseAddIntent {
        if #available(iOS 13.0, *) {
          hash = [
            "desc": intent.desc,
            "amount": intent.amount?.amount
          ]
        } else {
          hash = [:]
        }
      }

      if interaction.intent is ProductAddIntent {
        hash = [:]
      }

      if interaction.intent is TimeAddIntent {
        hash = [:]
      }

      if interaction.intent is VendorAddIntent {
        hash = [:]
      }
    }

    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "InitialUserActivity"),
      object: nil,
      userInfo: [
        "userInfo": userInfo as Any,
        "activityType": activityType,
        "hash": hash
      ]
    )
  }

  @objc
  override public static func requiresMainQueueSetup() -> Bool {
    return true
  }

  override init() {
    super.init()
    syncVoiceShortcuts()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(startedFromShortcut(notification:)),
      name: NSNotification.Name(rawValue: "InitialUserActivity"),
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appMovedToForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }

  func syncVoiceShortcuts() {
    if #available(iOS 12.0, *) {
      INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcutsFromCenter, error) in
        guard let voiceShortcutsFromCenter = voiceShortcutsFromCenter else {
          if let error = error as NSError? {
            NSLog("Failed to fetch voice shortcuts with error: \(error.userInfo)")
          }
          return
        }
        self.voiceShortcuts = voiceShortcutsFromCenter
      }
    }
  }

  @objc
  func appMovedToForeground() {
    syncVoiceShortcuts()
  }

  @objc
  func startedFromShortcut(notification: NSNotification) {
    let userInfo = notification.userInfo?["userInfo"]
    let activityType = notification.userInfo?["activityType"]
    let hash = notification.userInfo?["hash"]

    if hasListeners {
      sendEvent(withName: "shortcut", body: ["userInfo": userInfo, "activityType": activityType, "hash": hash])
    }
  }

  static func generateUserActivity(_ jsonOptions: Dictionary<String, Any>) -> NSUserActivity {
    let options = ShortcutOptions(jsonOptions)

    let activity = NSUserActivity(activityType: options.activityType)
    activity.title = options.title
    activity.requiredUserInfoKeys = options.requiredUserInfoKeys
    activity.userInfo = options.userInfo
    activity.needsSave = options.needsSave
    activity.keywords = Set(options.keywords ?? [])
    activity.isEligibleForHandoff = options.isEligibleForHandoff
    activity.isEligibleForSearch = options.isEligibleForSearch
    activity.isEligibleForPublicIndexing = options.isEligibleForPublicIndexing
    activity.expirationDate = options.expirationDate

    if let urlString = options.webpageURL {
      activity.webpageURL = URL(string: urlString)
    }

    if #available(iOS 12.0, *) {
      activity.isEligibleForPrediction = options.isEligibleForPrediction
      activity.suggestedInvocationPhrase = options.suggestedInvocationPhrase
      if let identifier = options.persistentIdentifier {
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(identifier)
      }
    }

    let attributes = CSSearchableItemAttributeSet(itemContentType: options.contentType as String)
    if let description = options.contentDescription {
      attributes.contentDescription = description
    }
    activity.contentAttributeSet = attributes

    return activity
  }

  @objc
  func donateShortcut(_ type: String, options: Dictionary<String, Any>) {
    var intent: INIntent? = nil

    if type == "task" {
      let taskAddIntent = TaskAddIntent()

      if let title = options["title"] as? String {
        taskAddIntent.title = title
      } else {
        taskAddIntent.title = "New Task"
      }

      if #available(iOS 13.0, *) {
        var date = Date()

        if let dueDate = options["dueDate"] as? String {
          let dateFormatter = ISO8601DateFormatter()
          dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

          if let dueDate = dateFormatter.date(from: dueDate) {
            date = dueDate
          }
        }

        let calendar = Calendar.current
        taskAddIntent.dueDate = calendar.dateComponents(in: TimeZone.current, from: date)
      }

      taskAddIntent.suggestedInvocationPhrase = "Add Task to App Extension Test"
      intent = taskAddIntent
    }

    if type == "client" {
      let clientAddIntent = ClientAddIntent()

      if let name = options["name"] as? String {
        clientAddIntent.name = name
      } else {
        clientAddIntent.name = "New Client"
      }

      clientAddIntent.suggestedInvocationPhrase = "Add Client to App Extension Test"
      intent = clientAddIntent
    }

    if type == "lead" {
      let leadAddIntent = LeadAddIntent()

      if let type = options["type"] as? String {
        if type == "project" {
          leadAddIntent.type = LeadType.project
        } else {
          leadAddIntent.type = LeadType.event
        }
      } else {
        leadAddIntent.type = LeadType.event
      }

      if let eventName = options["eventName"] as? String {
        leadAddIntent.eventName = eventName
      } else {
        leadAddIntent.eventName = "New Event"
      }

      if let leadName = options["leadName"] as? String {
        leadAddIntent.leadName = leadName
      } else {
        leadAddIntent.leadName = "New Lead"
      }

      leadAddIntent.suggestedInvocationPhrase = "Add Lead to App Extension Test"
      intent = leadAddIntent
    }

    if type == "event" {
      let eventAddIntent = EventAddIntent()

      if let eventName = options["eventName"] as? String {
        eventAddIntent.eventName = eventName
      } else {
        eventAddIntent.eventName = "New Event"
      }

      if #available(iOS 13.0, *) {
        var date = Date()

        if let eventDate = options["date"] as? String {
          let dateFormatter = ISO8601DateFormatter()
          dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

          if let eventDate = dateFormatter.date(from: eventDate) {
            date = eventDate
          }
        }

        let calendar = Calendar.current
        eventAddIntent.eventDate = calendar.dateComponents(in: TimeZone.current, from: date)
      }

      eventAddIntent.suggestedInvocationPhrase = "Add Event to App Extension Test"
      intent = eventAddIntent
    }

    if type == "project" {
      let projectAddIntent = ProjectAddIntent()

      if let title = options["title"] as? String {
        projectAddIntent.title = title
      } else {
        projectAddIntent.title = "New Project"
      }

      projectAddIntent.suggestedInvocationPhrase = "Add Project to App Extension Test"
      intent = projectAddIntent
    }

    if type == "invoice" {
      let invoiceAddIntent = InvoiceAddIntent()

      if let subject = options["subject"] as? String {
        invoiceAddIntent.subject = subject
      } else {
        invoiceAddIntent.subject = "New Invoice"
      }

      if #available(iOS 13.0, *) {
        var date = Date()

        if let dueDate = options["dueDate"] as? String {
          let dateFormatter = ISO8601DateFormatter()
          dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

          if let dueDate = dateFormatter.date(from: dueDate) {
            date = dueDate
          }
        }

        let calendar = Calendar.current
        invoiceAddIntent.dueDate = calendar.dateComponents(in: TimeZone.current, from: date)
      }

      invoiceAddIntent.suggestedInvocationPhrase = "Add Invoice to App Extension Test"
      intent = invoiceAddIntent
    }

    if type == "mileage" {
      let mileageAddIntent = MileageAddIntent()

      if let purpose = options["purpose"] as? String {
        mileageAddIntent.purpose = purpose;
      } else {
        mileageAddIntent.purpose = "Travel"
      }

      if let totalMiles = options["totalMiles"] as? String {
        if let totalMiles = Int(totalMiles) {
          mileageAddIntent.totalMiles = NSNumber(value: totalMiles)
        } else {
          mileageAddIntent.totalMiles = 1
        }
      } else {
        mileageAddIntent.totalMiles = 1
      }

      mileageAddIntent.suggestedInvocationPhrase = "Add Mileage to App Extension Test"
      intent = mileageAddIntent
    }

    if type == "expense" {
      let expenseAddIntent = ExpenseAddIntent()

      if let desc = options["desc"] as? String {
        expenseAddIntent.desc = desc
      } else {
        expenseAddIntent.desc = ""
      }

      if #available(iOS 13.0, *) {
        if let amount = options["amount"] as? String {
          expenseAddIntent.amount = INCurrencyAmount(amount: NSDecimalNumber(string: amount), currencyCode: "USD")
        } else {
          expenseAddIntent.amount = INCurrencyAmount(amount: NSDecimalNumber(integerLiteral: 1), currencyCode: "USD")
        }
      }

      expenseAddIntent.suggestedInvocationPhrase = "Add Expense to App Extension Test"
      intent = expenseAddIntent
    }

    if type == "product" {
      let productAddIntent = ProductAddIntent()
      productAddIntent.suggestedInvocationPhrase = "Add Product to App Extension Test"
      intent = productAddIntent
    }

    if type == "time" {
      let timeAddIntent = TimeAddIntent()
      timeAddIntent.suggestedInvocationPhrase = "Log Time in App Extension Test"
      intent = timeAddIntent
    }

    if type == "vendor" {
      let vendorAddIntent = VendorAddIntent()
      vendorAddIntent.suggestedInvocationPhrase = "Add Vendor to App Extension Test"
      intent = vendorAddIntent
    }

    if let intent = intent {
      INInteraction(intent: intent, response: nil).donate { (e: Error?) in
        if let e = e {
          debugPrint("Error with donation:")
          debugPrint(e)
        }
      }
    }
  }

  @available(iOS 12.0, *)
  @objc
  func suggestShortcuts() {
    var suggestions: [INShortcut] = []

    if let taskShortcut = INShortcut(intent: TaskAddIntent()) {
      suggestions.append(taskShortcut)
    }

    if let clientShortcut = INShortcut(intent: ClientAddIntent()) {
      suggestions.append(clientShortcut)
    }

    if let leadShortcut = INShortcut(intent: LeadAddIntent()) {
      suggestions.append(leadShortcut)
    }

    if let eventShortcut = INShortcut(intent: EventAddIntent()) {
      suggestions.append(eventShortcut)
    }

    if let projectShortcut = INShortcut(intent: ProjectAddIntent()) {
      suggestions.append(projectShortcut)
    }

    if let invoiceShortcut = INShortcut(intent: InvoiceAddIntent()) {
      suggestions.append(invoiceShortcut)
    }

    if let mileageShortcut = INShortcut(intent: MileageAddIntent()) {
      suggestions.append(mileageShortcut)
    }

    if let expenseShortcut = INShortcut(intent: ExpenseAddIntent()) {
      suggestions.append(expenseShortcut)
    }

    if let productShortcut = INShortcut(intent: ProductAddIntent()) {
      suggestions.append(productShortcut)
    }

    if let timeShortcut = INShortcut(intent: TimeAddIntent()) {
      suggestions.append(timeShortcut)
    }

    if let vendorShortcut = INShortcut(intent: VendorAddIntent()) {
      suggestions.append(vendorShortcut)
    }

    INVoiceShortcutCenter.shared.setShortcutSuggestions(suggestions)
  }

  @objc
  func clearAllShortcuts(_ resolve: @escaping RCTPromiseResolveBlock,
                         rejecter reject: RCTPromiseRejectBlock) -> Void {
    if #available(iOS 12.0, *) {
      NSUserActivity.deleteAllSavedUserActivities {
        resolve(nil)
      }
    } else {
      reject("below_ios_12", "Your device needs to be running iOS 12+ for this", nil)
    }
  }

  @objc
  func clearShortcutsWithIdentifiers(_ persistentIdentifiers: Array<String>,
                                     resolver resolve: @escaping RCTPromiseResolveBlock,
                                     rejecter reject: RCTPromiseRejectBlock) -> Void {
    if #available(iOS 12.0, *) {
      let persistentIdentifierArr = persistentIdentifiers.map {
        NSUserActivityPersistentIdentifier($0)
      }

      NSUserActivity.deleteSavedUserActivities(withPersistentIdentifiers: persistentIdentifierArr, completionHandler: { resolve(nil) })
    }
  }

  @objc
  @available(iOS 12.0, *)
  func getShortcuts(_ resolve: @escaping RCTPromiseResolveBlock,
                    rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve((voiceShortcuts as! Array<INVoiceShortcut>).map({ (voiceShortcut) -> [String: Any?] in
      var options: [String: Any?]? = nil
      if let userActivity = voiceShortcut.shortcut.userActivity {
        options = [
          "activityType": userActivity.activityType,
          "title": userActivity.title,
          "requiredUserInfoKeys": userActivity.requiredUserInfoKeys,
          "userInfo": userActivity.userInfo,
          "needsSave": userActivity.needsSave,
          "keywords": userActivity.keywords,
          "persistentIdentifier": userActivity.persistentIdentifier,
          "isEligibleForHandoff": userActivity.isEligibleForHandoff,
          "isEligibleForSearch": userActivity.isEligibleForSearch,
          "isEligibleForPublicIndexing": userActivity.isEligibleForPublicIndexing,
          "expirationDate": userActivity.expirationDate,
          "webpageURL": userActivity.webpageURL,
          "isEligibleForPrediction": userActivity.isEligibleForPrediction,
          "suggestedInvocationPhrase": userActivity.suggestedInvocationPhrase
        ]
      }

      return [
        "identifier": voiceShortcut.identifier.uuidString,
        "phrase": voiceShortcut.invocationPhrase,
        "options": options
      ]
    }))
  }

  @objc
  @available(iOS 12.0, *)
  func presentShortcut(_ jsonOptions: Dictionary<String, Any>, callback: @escaping RCTResponseSenderBlock) {
    self.presentShortcutCallback = callback;
    let activity = Shortcuts.generateUserActivity(jsonOptions)

    let shortcut = INShortcut(userActivity: activity)

    let addedVoiceShortcut = (self.voiceShortcuts as! Array<INVoiceShortcut>).first { (voiceShortcut) -> Bool in
      if let userActivity = voiceShortcut.shortcut.userActivity, userActivity.activityType == activity.activityType {
        return true
      }
      return false
    }

    DispatchQueue.main.async {
      // The shortcut was not added yet, so show a form to add it:
      if (addedVoiceShortcut == nil) {
        self.presenterViewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        self.presenterViewController!.modalPresentationStyle = .formSheet
        (self.presenterViewController as! INUIAddVoiceShortcutViewController).delegate = self
      } else {
        // Shortcut was already added, so present a form to edit it:
        self.presenterViewController = INUIEditVoiceShortcutViewController(voiceShortcut: addedVoiceShortcut!)
        self.presenterViewController!.modalPresentationStyle = .formSheet
        (self.presenterViewController as! INUIEditVoiceShortcutViewController).delegate = self
      }

      UIApplication.shared.keyWindow!.rootViewController!.present(self.presenterViewController!, animated: true, completion: nil)
    }
  }

  @objc
  @available(iOS 12.0, *)
  func presentIntentShortcut(_ type: String, callback: @escaping RCTResponseSenderBlock) {
    var shortcut: INShortcut? = nil
    if type == "task" {
      let intent = TaskAddIntent()
      intent.suggestedInvocationPhrase = "Add a Task to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "client" {
      let intent = ClientAddIntent()
      intent.suggestedInvocationPhrase = "Add a Client to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "lead" {
      let intent = LeadAddIntent()
      intent.suggestedInvocationPhrase = "Add a Lead to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "event" {
      let intent = EventAddIntent()
      intent.suggestedInvocationPhrase = "Add an Event to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "project" {
      let intent = ProjectAddIntent()
      intent.suggestedInvocationPhrase = "Add a Project to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "invoice" {
      let intent = InvoiceAddIntent()
      intent.suggestedInvocationPhrase = "Add an Invoice to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "mileage" {
      let intent = MileageAddIntent()
      intent.suggestedInvocationPhrase = "Add Mileage to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "expense" {
      let intent = ExpenseAddIntent()
      intent.suggestedInvocationPhrase = "Add an Expense to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "product" {
      let intent = ProductAddIntent()
      intent.suggestedInvocationPhrase = "Add a Product to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "time" {
      let intent = TimeAddIntent()
      intent.suggestedInvocationPhrase = "Log Time in App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if type == "vendor" {
      let intent = VendorAddIntent()
      intent.suggestedInvocationPhrase = "Add Vendor to App Extension Test"
      shortcut = INShortcut(intent: intent)
    }

    if (shortcut == nil) {
      return
    }

    self.presentShortcutCallback = callback

    DispatchQueue.main.async {
      self.presenterViewController = INUIAddVoiceShortcutViewController(shortcut: shortcut!)
      self.presenterViewController!.modalPresentationStyle = .formSheet
      (self.presenterViewController as! INUIAddVoiceShortcutViewController).delegate = self

      UIApplication.shared.keyWindow!.rootViewController!.present(self.presenterViewController!, animated: true, completion: nil)
    }
  }

  @available(iOS 12.0, *)
  func dismissPresenter(_ status: VoiceShortcutMutationStatus, withShortcut voiceShortcut: INVoiceShortcut?) {
    DispatchQueue.main.async {
      self.presenterViewController?.dismiss(animated: true, completion: nil)
      self.presenterViewController = nil
      self.presentShortcutCallback?([
        ["status": status.rawValue, "phrase": voiceShortcut?.invocationPhrase]
      ])
      self.presentShortcutCallback = nil
    }
  }

  @available(iOS 12.0, *)
  public func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
    if (voiceShortcut != nil) {
      voiceShortcuts.append(voiceShortcut!)
    }
    dismissPresenter(.added, withShortcut: voiceShortcut)
  }

  @available(iOS 12.0, *)
  public func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
    dismissPresenter(.cancelled, withShortcut: nil)
  }

  @available(iOS 12.0, *)
  public func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
    if (voiceShortcut != nil) {
      let indexOfUpdatedShortcut = (voiceShortcuts as! Array<INVoiceShortcut>).firstIndex { (shortcut) -> Bool in
        return shortcut.identifier == voiceShortcut!.identifier
      }

      if (indexOfUpdatedShortcut != nil) {
        voiceShortcuts[indexOfUpdatedShortcut!] = voiceShortcut!
      }
    }

    dismissPresenter(.updated, withShortcut: voiceShortcut)
  }

  @available(iOS 12.0, *)
  public func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
    var deletedShortcut: INVoiceShortcut? = nil

    let indexOfDeletedShortcut = (voiceShortcuts as! Array<INVoiceShortcut>).firstIndex { (shortcut) -> Bool in
      return shortcut.identifier == deletedVoiceShortcutIdentifier
    }

    if (indexOfDeletedShortcut != nil) {
      deletedShortcut = voiceShortcuts[indexOfDeletedShortcut!] as? INVoiceShortcut
      voiceShortcuts.remove(at: indexOfDeletedShortcut!)
    }

    dismissPresenter(.deleted, withShortcut: deletedShortcut)
  }

  @available(iOS 12.0, *)
  public func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
    dismissPresenter(.cancelled, withShortcut: nil)
  }

  @objc
  override public func supportedEvents() -> [String]! {
    return ["shortcut"]
  }

  @objc
  override public func startObserving() {
    hasListeners = true

    if let userActivity = Shortcuts.initialUserActivity {
      Shortcuts.onShortcutReceived(userActivity: userActivity)
      Shortcuts.initialUserActivity = nil
    }
  }

  @objc
  override public func stopObserving() {
    hasListeners = false
  }
}
