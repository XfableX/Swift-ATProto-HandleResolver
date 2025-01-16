//
//  ResolverErros.swift
//  SwiftAtprotoOauth
//
//  Created by Lachlan Maxwell on 16/1/2025.
//





enum ResolverError: Error {
    case runtimeError(String)
    case timeoutError(String)
    case dnsError(String)
    case success(String)
}
