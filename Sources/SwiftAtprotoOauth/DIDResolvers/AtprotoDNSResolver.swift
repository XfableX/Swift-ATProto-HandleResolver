//
//  AtprotoDNSResolver.swift
//  SwiftAtprotoOauth
//
//  Created by Lachlan Maxwell on 16/1/2025.
//

/*
 The DNS Resolver class. In theory this could be 1 method but making it an Actor seems to fix some issues with async that xcode didnt like.
 
 Plus extra error handling and can be expanded later.
 */

import AsyncDNSResolver

@available(macOS 10.15, *)
actor AtprotoDNSResolver{
    public func checkDIDTxtRecord(handle: String) async throws -> String {
        var did = ""
        let resolver = try AsyncDNSResolver()
        var handleProto = "_atproto." + handle
        let txtRecords = try await resolver.queryTXT(name: handleProto)

        for record in txtRecords {
            if(record.txt.hasPrefix("did=")){
                if(!did.isEmpty){
                    throw ResolverError.runtimeError("Multiple did found")
                }
                else {
                    did = String(record.txt.split(separator: "=")[1])
                }
            }
        }
        
        if(did.isEmpty){
            throw ResolverError.dnsError("No DID record found");
        }
        return did
    }
    
    
    public func resolve(handle: String, timeout: Int = 1) async throws -> String {
        
        //Run the dns txt record check as a task so it can happen in a seperate thread to our timeout check
        let dnsTask = Task {
            do {
                let didDns = try await checkDIDTxtRecord(handle: handle)
                return didDns

            } catch {
                throw ResolverError.dnsError("DNS Error, no record?")
                
            }
        }
        
        //Sleep method to check for timeout. This is necessary because dnssd's default timeout is 30 seconds... ouch
        let timeoutTask = Task{
            do{
                try await Task.sleep(nanoseconds: UInt64(timeout * 1000000000))
                dnsTask.cancel()
            }
            catch{
                
            }
        }
        

        //Return the result or catch any errors.
        do{
            let result = try await dnsTask.value
            timeoutTask.cancel()
            return result
        }
        catch ResolverError.dnsError{
            return "Dns Error"
        }
        catch ResolverError.timeoutError{
            return "Dns timed out"
        }
        catch{
            throw ResolverError.runtimeError("Unexpected Error Occured")
        }
        
    }
    
}


