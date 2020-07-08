//
//  ContentView.swift
//  ListViewInfiniteScroll
//
//  Created by Võ Thanh Sang on 7/7/20.
//  Copyright © 2020 Võ Thanh Sang. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Home()
            .navigationBarTitle("Home")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    
    @ObservedObject var listData = getData()
    
    var body: some View {
        
        List(0 ..< listData.data.count, id: \.self) { i in
            
            if i ==  self.listData.data.count - 1 {
                cellView(data: self.listData.data[i], isLast: true, lisData: self.listData)
            } else {
                cellView(data: self.listData.data[i], isLast: false, lisData: self.listData)

            }
            
        }
    }
}

struct cellView : View {
    
    var data: Doc
    var isLast: Bool
    @ObservedObject var lisData: getData
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            Text(data.id)
                .fontWeight(.bold)
            Text(data.eissn)
            Text(data.article_type)
            
            if self.isLast{
                
                Text(data.publication_date)
                    .font(.caption)
                    .onAppear{
                        
                        print("load data")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.lisData.data.count != 50 {
                                self.lisData.updateData()

                            }
                        }
                        
                    }
                
            } else {
                
                Text(data.publication_date)
                .font(.caption)
            }
            
        }
        .padding(.top, 10)
    }
}

class getData: ObservableObject {
    
    @Published var data = [Doc]()
    @Published var count = 1
    
    init() {
        updateData()
    }
    
    func updateData() {
        
        let url = "http://api.plos.org/search?q=title:%22Food%22&start=\(count)&row=10"
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: URL(string: url)!) {data, _, err in
            if err != nil {
                print(err?.localizedDescription)
                return
            }
            
            do {
                let json = try! JSONDecoder().decode(Detail.self, from: data!)
                let oldData = self.data
                
                DispatchQueue.main.async {
                    self.data = oldData + json.response.docs
                    self.count += 10
                    
                }
                
                
                
            } catch {
                
                print(error.localizedDescription)
            }
        }.resume()
        
    }
}

struct Detail: Decodable {
    var response: Response
    
}

struct Response: Decodable {
    var docs: [Doc]
    
}

struct Doc: Decodable {
    var id: String
    var eissn: String
    var publication_date: String
    var article_type: String
    
    
}
