// The Swift Programming Language
// https://docs.swift.org/swift-book


/*
 This is a modified version of https://github.com/apple/swift-async-dns-resolverhttps://github.com/apple/swift-async-dns-resolver
 
 That includes the changes from https://github.com/apple/swift-async-dns-resolver/pull/34
 merged with the up to date master branch.
 
 
 Waiting on Apple to approve that guys PR... In the mean time done this.
 
 If it gets merged, clean this up OR package it seperately to this.
 
 Causes test cases to go from 60 seconds to 3 :)
 
 */
import AsyncDNSResolver
import Foundation
import dnssd
import OAuth2

@available(macOS 12.0, *)
open class SwiftAtprotoOauth {
    
    public init(){
        
    }
    
    
    public func resolveEndpoint(handle: String) async throws -> URL {
        do{
            let did = try await resolveDID(handle: handle)
            print("DID retrieved")
            return try await getPDSUrl(did: did)
        }
        catch{
            print("I Errored here")
            throw error
        }
    }
    
    public func resolveDID(handle: String) async throws -> String{
        do{
            let did = try await AtprotoDNSResolver().resolve(handle: handle)
            print(did)
            
            return try validateDid(did)
        }
        catch {
            print(error)
            print("Falling back to http")
            do{
                let did = try await AtprotoHTTPResolver().resolve(handle: handle)
                return try validateDid(did)
            }
            catch {
                print(error)
                throw ResolverError.runtimeError("No valid DID found")
            }
        }
        
    }
    
    public func validateDid(_ did: String) throws -> String {
        if(did.hasPrefix("did:")){
            return did
        }
        else {
            throw ResolverError.runtimeError("No valid DID found")
        }
    }
    
    public func getPDSUrl(did: String) async throws -> URL {
        if(did.hasPrefix("did:plc:")){
            guard let plcService = try await retrievePLCDocument(did: did)["service"] as? [[String: String]]
            else {
                print("DID PLC LOOKUP ERR")
                throw ResolverError.runtimeError("DID PLC lookup error")
            }
            debugPrint(plcService)
            let plcServiceEndpoint=(plcService[0]["serviceEndpoint"])
            
            
            return URL(string: plcServiceEndpoint!)!
        }
        else if (did.hasPrefix("did:web:")){
            return URL(string: did.components(separatedBy: ":")[2])!
        }
        else{
            throw ResolverError.runtimeError("Not a blessed DID method")
        }
    }
    
    
    public func retrievePLCDocument(did: String) async throws -> [String : Any] {
        let url = URL(string: "https://plc.directory/\(did)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            return json!
        } catch {
            print("errorMsg")
            throw ResolverError.runtimeError("DID PLC lookup error")
        }
    }
    
    
    public func retrieveAuthServer(handle: String) async throws -> String {
        let metadataRetriever = AtprotoMetadataRetriever()
        let metadata = try await metadataRetriever.getResourceMetadata(handle: handle)
        print(metadata["authorization_endpoint"]!)
        return metadata["authorization_endpoint"] as! String
        
    }
}




