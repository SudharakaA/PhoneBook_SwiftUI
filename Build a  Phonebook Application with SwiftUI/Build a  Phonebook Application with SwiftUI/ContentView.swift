import SwiftUI

struct Contact: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var number: String
}

class ContactStore: ObservableObject {
    @Published var contacts: [Contact] = []
    
    func addContact(name: String, number: String) {
        let newContact = Contact(name: name, number: number)
        contacts.append(newContact)
    }
    
    func removeContact(contact: Contact) {
        contacts.removeAll { $0 == contact }
    }
    
    func searchContacts(query: String) -> [Contact] {
        contacts.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.number.localizedCaseInsensitiveContains(query)
        }
    }
}

struct ContentView: View {
    @StateObject private var store = ContactStore()
    @State private var name = ""
    @State private var number = ""
    @State private var searchQuery = ""
    @State private var showAddAlert = false
    @State private var showDeleteAlert = false
    @State private var contactToDelete: Contact?
    
    var filteredContacts: [Contact] {
        searchQuery.isEmpty ? store.contacts : store.searchContacts(query: searchQuery)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Number", text: $number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        store.addContact(name: name, number: number)
                        name = ""
                        number = ""
                        showAddAlert = true
                    }
                    .disabled(name.isEmpty || number.isEmpty)
                    .alert(isPresented: $showAddAlert) {
                        Alert(title: Text("Contact Added"), message: Text("Successfully added!"), dismissButton: .default(Text("OK")))
                    }
                }.padding()
                
                HStack {
                    TextField("Search by name or number", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if !searchQuery.isEmpty {
                        Button(action: { searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding([.leading, .trailing])
                
                if filteredContacts.isEmpty {
                    Spacer()
                    Text("No contacts found.")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredContacts) { contact in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(contact.name).font(.headline)
                                    Text(contact.number).font(.subheadline)
                                }
                                Spacer()
                                Button(action: {
                                    contactToDelete = contact
                                    showDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Phonebook")
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Contact"),
                    message: Text("Are you sure you want to delete this contact?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let contact = contactToDelete {
                            store.removeContact(contact: contact)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
