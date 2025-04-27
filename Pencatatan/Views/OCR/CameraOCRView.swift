//
//  CameraOCRView.swift
//  Pencatatan
//
//  Created by Reza Juliandri on 27/04/25.
//
import SwiftUI

struct CameraOCRView: View {
    @State private var storeName: String = ""
    @State private var address: String = ""
    @State private var date: Date = Date()
    @State private var items: [Item] = [
        Item(name: "", quantity: 1, price: 0)
    ]

    var body: some View {
        Form {
            Section(header: Text("Store Info")) {
                TextField("Store Name", text: $storeName)
                TextField("Address", text: $address)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            
            Section(header: Text("Items")) {
                ForEach(items.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        TextField("Item Name", text: $items[index].name)
                        HStack {
                            Stepper("Quantity: \(items[index].quantity)", value: $items[index].quantity, in: 1...99)
                            Spacer()
                            TextField("Price", value: $items[index].price, formatter: NumberFormatter.currency)
                                .keyboardType(.decimalPad)
                                .frame(width: 100)
                        }
                    }
                }
                Button(action: {
                    items.append(Item(name: "", quantity: 1, price: 0))
                }) {
                    Label("Add Item", systemImage: "plus.circle")
                }
            }
            
            Section {
                Button("Save Receipt") {
                    // Save logic here
                }
            }
        }
        .navigationTitle("Input Receipt")
    }
}

// Support Models
struct Item: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
    var price: Double
}

// Currency Formatter
extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter
    }
}
