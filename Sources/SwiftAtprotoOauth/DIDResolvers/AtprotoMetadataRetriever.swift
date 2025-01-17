//
//  AtprotoResourceMetadata.swift
//  SwiftAtprotoOauth
//
//  Created by Lachlan Maxwell on 16/1/2025.
//

import Foundation

// /.well-known/oauth-protected-resource


@available(macOS 12.0, *)
class AtprotoMetadataRetriever: Codable {
    
    public func getResourceMetadata(handle: String) async throws  -> [String: Any]{
        let oauthManager = SwiftAtprotoOauth()
        var did = try await oauthManager.resolveDID(handle: handle)
        return try await getResourceMetadata(did: did)
    }
    public func getResourceMetadata(did: String) async throws  -> [String: Any]{
        let oauthManager = SwiftAtprotoOauth()
        var url = try await oauthManager.getPDSUrl(did: did).absoluteString
        return try await getResourceMetadata(url: url)
    }
    public func getResourceMetadata(url: String) async throws  -> [String: Any]{
        
        let path = "/.well-known/oauth-protected-resource"
        let urlString = url + path
        let urlReq = URL(string: urlString)!
        
        let (data, _) = try await URLSession.shared.data(from: urlReq)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            
            
            
            
            var authorizationServer = ((json!["authorization_servers"] as! [String])[0])
            
            var metadata = try await getAuthorizationMetadata(url: authorizationServer)
            return metadata
        } catch {
            print("errorMsg")
            throw ResolverError.runtimeError("DID PLC lookup error")
        }
    }
    
    public func getAuthorizationMetadata(url: String) async throws -> [String: Any]{
        
        let path = "/.well-known/oauth-authorization-server"
        let urlString = url + path
        let urlReq = URL(string: urlString)!
        
        let (data, _) = try await URLSession.shared.data(from: urlReq)
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            return json!
        }
        catch{
            throw error
        }
    }
    
}
