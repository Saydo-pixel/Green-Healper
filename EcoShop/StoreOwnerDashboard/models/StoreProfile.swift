//
//  StoreProfile.swift
//  EcoShop
//
//  Created by user244986 on 12/26/24.
//

import Foundation
import FirebaseFirestore

struct StoreProfile: Identifiable {
   let id: String
   var name: String
   var email: String
   var description: String
   var profileImageURL: String
   
   // Initialize from Firestore document
   init?(document: DocumentSnapshot) {
       guard
           let data = document.data(),
           let name = data["name"] as? String,
           let email = data["email"] as? String else {
               return nil
       }
       
       self.id = document.documentID
       self.name = name
       self.email = email
       self.description = data["description"] as? String ?? ""
       self.profileImageURL = data["profileImageURL"] as? String ?? ""
   }
   
   // Regular initializer
   init(id: String = UUID().uuidString,
        name: String,
        email: String,
        description: String = "",
        profileImageURL: String = "") {
       self.id = id
       self.name = name
       self.email = email
       self.description = description
       self.profileImageURL = profileImageURL
   }
   
   // Save to Firestore
   func saveProfile() async throws {
       let db = Firestore.firestore()
       try await db.collection("storeProfiles").document(id).setData([
           "name": name,
           "email": email,
           "description": description,
           "profileImageURL": profileImageURL
       ])
   }
   
   // Fetch profile by ID
   static func fetchProfile(withId id: String) async throws -> StoreProfile? {
       let db = Firestore.firestore()
       let docSnapshot = try await db.collection("storeProfiles").document(id).getDocument()
       return StoreProfile(document: docSnapshot)
   }

   
   // Update profile
   func updateProfile() async throws {
       let db = Firestore.firestore()
       try await db.collection("storeProfiles").document(id).updateData([
           "name": name,
           "email": email,
           "description": description,
           "profileImageURL": profileImageURL
       ])
   }
}
