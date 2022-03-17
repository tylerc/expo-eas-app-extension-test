import Intents

class IntentHandler: INExtension {

  override func handler(for intent: INIntent) -> Any {
    if intent is TaskAddIntent {
      return TaskAddIntentHandler()
    }

    if intent is ClientAddIntent {
      return ClientAddIntentHandler()
    }

    if intent is LeadAddIntent {
      return LeadAddIntentHandler()
    }

    if intent is EventAddIntent {
      return EventAddIntentHandler()
    }

    if intent is ProjectAddIntent {
      return ProjectAddIntentHandler()
    }

    if intent is InvoiceAddIntent {
      return InvoiceAddIntentHandler()
    }

    if intent is MileageAddIntent {
      return MileageAddIntentHandler()
    }

    if intent is ExpenseAddIntent {
      return ExpenseAddIntentHandler()
    }

    if intent is ProductAddIntent {
      return ProductAddIntentHandler()
    }

    if intent is TimeAddIntent {
      return TimeAddIntentHandler()
    }

    if intent is VendorAddIntent {
      return VendorAddIntentHandler()
    }

    fatalError("Unhandled Intent error: \(intent)")
  }

}

class ClientAddIntentHandler : NSObject, ClientAddIntentHandling {
  func resolveName(for intent: ClientAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let name = intent.name else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: name))
  }

  func confirm(intent: ClientAddIntent, completion: (ClientAddIntentResponse) -> Void) {
    completion(ClientAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: ClientAddIntent, completion: (ClientAddIntentResponse) -> Void) {
    completion(ClientAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class LeadAddIntentHandler : NSObject, LeadAddIntentHandling {
  func resolveType(for intent: LeadAddIntent, with completion: @escaping (LeadTypeResolutionResult) -> Void) {
    if intent.type == .unknown {
      completion(LeadTypeResolutionResult.success(with: LeadType.event))
      return
    }
    completion(LeadTypeResolutionResult.success(with: intent.type))
  }

  func resolveEventName(for intent: LeadAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let eventName = intent.eventName else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: eventName))
  }

  func resolveLeadName(for intent: LeadAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let leadName = intent.leadName else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: leadName))
  }

  func confirm(intent: LeadAddIntent, completion: (LeadAddIntentResponse) -> Void) {
    completion(LeadAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: LeadAddIntent, completion: (LeadAddIntentResponse) -> Void) {
    completion(LeadAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class TaskAddIntentHandler : NSObject, TaskAddIntentHandling {
  func resolveDueDate(for intent: TaskAddIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
    guard let dueDate = intent.dueDate else {
      completion(INDateComponentsResolutionResult.needsValue())
      return
    }
    completion(INDateComponentsResolutionResult.success(with: dueDate))
  }

  func resolveTitle(for intent: TaskAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let title = intent.title else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: title))
  }

  func confirm(intent: TaskAddIntent, completion: (TaskAddIntentResponse) -> Void) {
    completion(TaskAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: TaskAddIntent, completion: (TaskAddIntentResponse) -> Void) {
    completion(TaskAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class EventAddIntentHandler : NSObject, EventAddIntentHandling {
  func resolveEventDate(for intent: EventAddIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
    guard let eventDate = intent.eventDate else {
      completion(INDateComponentsResolutionResult.needsValue())
      return
    }
    completion(INDateComponentsResolutionResult.success(with: eventDate))
  }

  func resolveEventName(for intent: EventAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let eventName = intent.eventName else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: eventName))
  }

  func confirm(intent: EventAddIntent, completion: (EventAddIntentResponse) -> Void) {
    completion(EventAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: EventAddIntent, completion: (EventAddIntentResponse) -> Void) {
    completion(EventAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class ProjectAddIntentHandler : NSObject, ProjectAddIntentHandling {
  func resolveTitle(for intent: ProjectAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let title = intent.title else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: title))
  }

  func confirm(intent: ProjectAddIntent, completion: (ProjectAddIntentResponse) -> Void) {
    completion(ProjectAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: ProjectAddIntent, completion: (ProjectAddIntentResponse) -> Void) {
    completion(ProjectAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class InvoiceAddIntentHandler : NSObject, InvoiceAddIntentHandling {
  func resolveDueDate(for intent: InvoiceAddIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
    guard let dueDate = intent.dueDate else {
      completion(INDateComponentsResolutionResult.needsValue())
      return
    }
    completion(INDateComponentsResolutionResult.success(with: dueDate))
  }

  func resolveSubject(for intent: InvoiceAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let subject = intent.subject else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: subject))
  }

  func confirm(intent: InvoiceAddIntent, completion: (InvoiceAddIntentResponse) -> Void) {
    completion(InvoiceAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: InvoiceAddIntent, completion: (InvoiceAddIntentResponse) -> Void) {
    completion(InvoiceAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class MileageAddIntentHandler : NSObject, MileageAddIntentHandling {
  func resolveTotalMiles(for intent: MileageAddIntent, with completion: @escaping (MileageAddTotalMilesResolutionResult) -> Void) {
    guard let totalMiles = intent.totalMiles else {
      completion(MileageAddTotalMilesResolutionResult.needsValue())
      return
    }
    completion(MileageAddTotalMilesResolutionResult.success(with: totalMiles.intValue))
  }

  func resolvePurpose(for intent: MileageAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let purpose = intent.purpose else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: purpose))
  }

  func confirm(intent: MileageAddIntent, completion: (MileageAddIntentResponse) -> Void) {
    completion(MileageAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: MileageAddIntent, completion: (MileageAddIntentResponse) -> Void) {
    completion(MileageAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class ExpenseAddIntentHandler : NSObject, ExpenseAddIntentHandling {
  func resolveAmount(for intent: ExpenseAddIntent, with completion: @escaping (ExpenseAddAmountResolutionResult) -> Void) {
    guard let amount = intent.amount  else {
      completion(ExpenseAddAmountResolutionResult.needsValue())
      return
    }

    completion(ExpenseAddAmountResolutionResult.success(with: amount))
  }

  func resolveDesc(for intent: ExpenseAddIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
    guard let desc = intent.desc else {
      completion(INStringResolutionResult.needsValue())
      return
    }
    completion(INStringResolutionResult.success(with: desc))
  }

  func confirm(intent: ExpenseAddIntent, completion: (ExpenseAddIntentResponse) -> Void) {
    completion(ExpenseAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: ExpenseAddIntent, completion: (ExpenseAddIntentResponse) -> Void) {
    completion(ExpenseAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class ProductAddIntentHandler : NSObject, ProductAddIntentHandling {
  func confirm(intent: ProductAddIntent, completion: (ProductAddIntentResponse) -> Void) {
    completion(ProductAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: ProductAddIntent, completion: (ProductAddIntentResponse) -> Void) {
    completion(ProductAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class TimeAddIntentHandler : NSObject, TimeAddIntentHandling {
  func confirm(intent: TimeAddIntent, completion: (TimeAddIntentResponse) -> Void) {
    completion(TimeAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: TimeAddIntent, completion: (TimeAddIntentResponse) -> Void) {
    completion(TimeAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}

class VendorAddIntentHandler : NSObject, VendorAddIntentHandling {
  func confirm(intent: VendorAddIntent, completion: (VendorAddIntentResponse) -> Void) {
    completion(VendorAddIntentResponse(code: .continueInApp, userActivity: nil))
  }

  func handle(intent: VendorAddIntent, completion: (VendorAddIntentResponse) -> Void) {
    completion(VendorAddIntentResponse(code: .continueInApp, userActivity: nil))
  }
}
