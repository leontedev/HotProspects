//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Mihai Leonte on 16/12/2019.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

enum FilterType {
    case none, contacted, uncontacted
}


struct ProspectsView: View {
    @EnvironmentObject var prospects: Prospects
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    @State private var isShowingScanner = false
    @State private var isShowingSortingActionSheet = false
    @State private var isSorted = false
    let filter: FilterType
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(isSorted ? filteredProspects.sorted() : filteredProspects) { prospect in
                    
                    HStack {
                        Image(systemName: prospect.isContacted ? "checkmark.circle" : "questionmark.diamond")
                        
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    }.contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted" ) {
                            //prospect.isContacted.toggle()
                            self.prospects.toggle(prospect)
                        }
                        
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                    
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(leading:
                                     Button(action: {
                                        self.isShowingSortingActionSheet = true
                                     }) {
                                         //Image(systemName: "")
                                         Text("Sort")
                                     },
                                trailing:
                                    Button(action: {
                                        self.isShowingScanner = true
                                    }) {
                                        Image(systemName: "qrcode.viewfinder")
                                        Text("Scan")
                                        })
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Mihai Leonte\nmihai@leonte.com", completion: self.handleScan)
            }
            .actionSheet(isPresented: $isShowingSortingActionSheet) {
                ActionSheet(title: Text("Sort by"), message: nil, buttons: [
                    .default(Text("Name"), action: {
                        self.isSorted = true
                    }),
                    .default(Text("Most Recent"), action: {
                        self.isSorted = false
                    })
                ])
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
        
       switch result {
       case .success(let code):
           let details = code.components(separatedBy: "\n")
           guard details.count == 2 else { return }

           let person = Prospect()
           person.name = details[0]
           person.emailAddress = details[1]
           //person.dateAdded = Date()
           self.prospects.add(person)
       case .failure(let error):
           print("Scanning failed")
       }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
            // it will trigger at 9 AM
            //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // testing - 5 seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
