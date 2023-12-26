//
//  ContentView.swift
//  GithubUserApp
//
//  Created by Aman Gupta on 26/12/23.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GithubUser?
    var body: some View {
        VStack {
            AsyncImage(url: URL(string:user? .avatarUrl ?? "")){
                image in image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            } placeholder: {
                Circle()
                     .foregroundColor(.secondary)
                     
            }
            .frame(width:120, height: 120)
           
            Text(user? .login ?? "Login placeholder")
            Text(user? .bio ?? "Bio placeholder")
                .font(.system(size: 25))
                .padding(.top,50)
            Spacer()
        }
        .padding()
        .task{
            do{
                user = try await getUser()
            }catch GHError.invalidUrl{
                print("Invalid URl")
            }
            catch GHError.invalidData{
                print("Invalid Data")
            }
            catch GHError.invalidResponse{
                print("Invalid Response")
            }
            catch{
                print("Unexpected Error")
            }
        }
    }
    
    func getUser() async throws -> GithubUser{
        let endPoint = "https://api.github.com/users/Decoy101"
        
        guard let url = URL(string: endPoint) else{
            throw GHError.invalidUrl
        }
        
        let (data,response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw GHError.invalidResponse
        }
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GithubUser.self, from: data)
            
        } catch{
            throw GHError.invalidData
        }
        
    }
}

struct GithubUser: Codable{
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}


#Preview {
    ContentView()
}
