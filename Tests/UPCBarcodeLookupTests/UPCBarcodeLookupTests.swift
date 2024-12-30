import Testing
@testable import UPCBarcodeLookup

@Test func creditsUnknownBeforeFirstCall() async throws {
    let upcLookup = UPCBarcodeLookup(apiToken: "")
    #expect (upcLookup.creditsRemaining() == -1)
}
