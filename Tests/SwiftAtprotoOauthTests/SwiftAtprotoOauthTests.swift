import Testing
import Foundation
@testable import SwiftAtprotoOauth

@Test func mainMethodCheck() async throws {
    let oauthManager = SwiftAtprotoOauth();
    do {await #expect(try oauthManager.resolveEndpoint(handle: "fable.lachlanmaxwell.com.au") == URL(string: "https://lachlanmaxwell.com.au"))
    }
    catch {
        Issue.record("Failed to resolve")
    }
    //This is the first persons domain i found who used the _atproto dns method so shoutouts to Luke for being my test case.
    do {await #expect(try oauthManager.resolveEndpoint(handle: "lukeplunkett.com") == URL(string: "https://amanita.us-east.host.bsky.network"))
    }
    catch {
        Issue.record("Failed to resolve")
    }
}

@Test func metadataResourceCheck() async throws {
    let metadataRetriever = AtprotoMetadataRetriever();
    var metadata = try await metadataRetriever.getResourceMetadata(url: "https://fable.lachlanmaxwell.com.au")
    
    print(metadata)
}


@Test func authTest() async throws {
    let oauthManager = SwiftAtprotoOauth();
  //  oauthManager.OAuthRequest(authServer: "https://lachlanmaxwell.com.au", user: "fable")
}
@Test func subMethodChecks() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let oauthManager = SwiftAtprotoOauth();
    await #expect(try oauthManager.resolveDID(handle: "lukeplunkett.com") == "did:plc:nhqvuggd6ebasluetrqfab6n")
    
    do {await #expect(try oauthManager.resolveDID(handle: "https://fable.lachlanmaxwell.com.au") == "did:plc:a4oidso5ovyo3ei7sdwhpu3j")
    }
    catch {
        Issue.record("Failed to resolve")
    }
    
    do {await #expect(try oauthManager.resolveDID(handle: "fable.lachlanmaxwell.com.au") == "did:plc:a4oidso5ovyo3ei7sdwhpu3j")
    }
    catch {
        Issue.record("Failed to resolve")
    }
    
    
    var failed = false
    
    
    let oauthErrManager = SwiftAtprotoOauth();
    do{
        _ = try await oauthErrManager.resolveDID(handle: "google.com.au")
    }
    catch is ResolverError{
        failed = true
    }
    #expect(failed)
    
    failed = false
    do{
        _ = try await oauthErrManager.resolveDID(handle: "http://fable.lachlanmaxwell.com.au")
    }
    catch is ResolverError{
        failed = true
    }
    #expect(failed)
    
}


@Test func authServerCheck() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    let oauthManager = SwiftAtprotoOauth();
    await #expect(try oauthManager.retrieveAuthServer(handle: "lukeplunkett.com") == "https://bsky.social/oauth/authorize")
    
}
