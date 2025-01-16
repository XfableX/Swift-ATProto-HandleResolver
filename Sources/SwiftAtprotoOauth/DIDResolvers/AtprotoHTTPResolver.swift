//
//  AtprotoHTTPResolver.swift
//  SwiftAtprotoOauth
//
//  Created by Lachlan Maxwell on 16/1/2025.
//

import AsyncDNSResolver
import Alamofire
import Foundation
import dnssd

/*
 HTTP resolver.
 When DNS fails, we need to retrieve DID information from the PDS/Auth server.
 */
class AtprotoHTTPResolver {
    @available(macOS 12.0, *)
    public func resolve(handle: String) async throws -> String {
        print("Resolving through http...")
        print(handle)
        
        //By default, make it HTTPS and disallow http
        let HTTP_PROTO = "https://"
        let ALLOW_HTTP = false
        
        //This is the current PDS did lookup path.
        let PATH = "/.well-known/atproto-did"
        
        var handle_url = handle + PATH
        
        
        //Protocol fixerer
        if(!handle.hasPrefix(HTTP_PROTO)){ //If it doesnt match our expected proto
            if(handle.hasPrefix("http://")){ //And is http
                if (!ALLOW_HTTP) {throw ResolverError.runtimeError("Invalid protocol, Must use HTTPS")} //Throw error
            }
            else {
                handle_url = HTTP_PROTO + handle_url //Append the protocol
            }
        }
        
        
        let url = URL(string: handle_url)!
        
        let task = try await URLSession.shared.data(from: url)
        print(String(decoding: task.0, as: UTF8.self))
        return String(decoding: task.0, as: UTF8.self)
        
    }
}
