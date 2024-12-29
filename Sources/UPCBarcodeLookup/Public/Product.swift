//
// UPCBarcodeLookup.swift - barcode lookup for UPC, GTIN, ISBN and EAN codes
//
// (c) 2024 Relaxed Communications GmbH <info@relaxedcommunications.com>
// https://www.ean-search.org/upc-barcode-lookup.html
//

public struct Product: Decodable, Sendable {
    public let ean: String
    public let name: String
    public let categoryId: String
    public let categoryName: String
    public let issuingCountry: String
}
