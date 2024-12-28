//
// UPCBarcodeLookup.swift - barcode lookup for UPC, GTIN, ISBN and EAN codes
//
// (c) 2024 Relaxed Communications GmbH <info@relaxedcommunications.com>
// https://www.ean-search.org/upc-barcode-lookup.html
//

public struct Product: Decodable, Sendable {
    let ean: String
    let name: String
    let categoryId: String
    let categoryName: String
    let issuingCountry: String
}
