//
// UPCBarcodeLookup.swift - barcode lookup for UPC, GTIN, ISBN and EAN codes
//
// (c) 2024 Relaxed Communications GmbH <info@relaxedcommunications.com>
//          https://www.ean-search.org/upc-barcode-lookup.html
//

public struct BaseProduct: Decodable {
    let ean: String
    let issuingCountry: String
}

public struct BarcodeImage: Decodable {
    let ean: String
    let barcode: String
}

public struct VerifyChecksum: Decodable {
    let ean: String
    let valid: String
}

public struct ErrorMsg: Decodable {
    let error: String
}

public struct ProductList: Decodable {
    let page: Int
    let moreproducts: Bool
    let totalproducts: Int
    let productlist: [Product]
}

public struct AccountStatus: Decodable {
    let id: String
    let requests: Int
    let requestlimit: Int
}
