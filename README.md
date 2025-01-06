# UPCBarcodeLookup

Swift package for UPC, GTIN, ISBN and EAN barcode lookup using the API provided by [EAN-Search.org](https://www.ean-search.org/upc-barcode-lookup.html)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Feansearch%2FUPCBarcodeLookup%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/eansearch/UPCBarcodeLookup)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Feansearch%2FUPCBarcodeLookup%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/eansearch/UPCBarcodeLookup)
[![](https://img.shields.io/badge/language-swift-orange.svg)](https://swiftpackageindex.com/eansearch/UPCBarcodeLookup)

## Features

- lookup details for a specific GTIN, UPC or EAN barcode in our database: barcodeLookup(ean: )
- lookup details for a specific ISBN 10 in our database: isbnLookup(isbn: )
- just check the issuing country on any barcode: issuingCountryLookup(ean: )
- verify the checksum of a barcode verifyChecksum(ean: ean)
- get all products with a certain prefix: barcodePrefixSearch(prefix: )
- search products matching some keywords: keywordSearch(keywords: )
- restrict a keyword search to a product category: categorySearch(keywords: , category: )
- find products with similar names: similarProductSearch(keywords: )
- generate a PNG barcode image: generateBarcodeImage(ean: , width: , height: )

## Installation

Just add UPCBarcodeLookup as a dependency in your Product.swift.

```swift
dependencies: [
    .package(url: "https://github.com/eansearch/UPCBarcodeLookup.git", branch: "main")
]
```

## Usage

Initialize the API instance with your [API token](https://www.ean-search.org/ean-database-api.html).

With all methods returning a result list, you need to page through the results if there are more than 10.


## Example

```swift
import UPCBarcodeLookup

let token = ProcessInfo.processInfo.environment["EAN_SEARCH_API_TOKEN"]!
let ean = "5099750442227" // a GTIN, UPC or EAN code, eg from your barcode scanner

let upcLookup = UPCBarcodeLookup(apiToken: token)

do {
    let product = try await upcLookup.barcodeLookup(ean: ean)
    print ("EAN \(ean) is " + (product?.name ?? "not found"))

    let country = try await upcLookup.issuingCountryLookup(ean: ean)
    print ("EAN \(ean) was issued in " + (country))

    let ok = try await upcLookup.verifyChecksum(ean: ean)
    print ("EAN \(ean) checksum OK = \(ok)")

    let range = try await upcLookup.barcodePrefixSearch(prefix: "50997504422")
    print("Prefix range: 50997504422*")
    for product in range {
        print ("EAN \(product.ean) is \(product.name)")
    }

   let products = try await upcLookup.keywordSearch(keywords: "Bananaboat")
    print("Keyword: Bananaboat:")
    for product in products {
        print ("EAN \(product.ean) is \(product.name)")
    }

    let cat = try await upcLookup.categorySearch(keywords: "Thriller", category: 45)
    print("Keyword Thriller in category Music:")
    for product in cat {
        print ("EAN \(product.ean) is \(product.name)")
    }

    let similar = try await upcLookup.similarProductSearch(keywords: "Apple iPhone 16GB robust")
    print("Similar search:")
    for product in similar {
        print ("EAN \(product.ean) is \(product.name)")
    }

    let png = try await upcLookup.generateBarcodeImage(ean: ean, width: 400, height: 300)!

    let fileManager = FileManager.default
    var documentURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    documentURL = documentURL.appendingPathComponent("barcode.png")
    try! png.write(to: documentURL)

    print("Credits remaining: ", upcLookup.creditsRemaining())
} catch {
    print ("Error: \(error)")
}
```
