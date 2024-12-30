//
// UPCBarcodeLookup.swift - barcode lookup for UPC, GTIN, ISBN and EAN codes
//
// (c) 2024 Relaxed Communications GmbH <info@relaxedcommunications.com>
//          https://www.ean-search.org/upc-barcode-lookup.html
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class UPCBarcodeLookup {

    public init(apiToken: String) {
        self.apiToken = apiToken
    }

    @available(iOS 13, *)
    public func barcodeLookup(ean: String, language: Int = Languages.English) async throws -> Product? {
        guard let url = URL(string: self._baseURL() + "&op=barcode-lookup&ean=\(ean)&language=\(language)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let product = try? JSONDecoder().decode([Product].self, from: data) {
            return product[0]
        } else {
            try handleApiError(data: data)
            return nil
        }
    }

    @available(iOS 13, *)
    public func isbnLookup(isbn: String) async throws -> Product? {
        guard let url = URL(string: self._baseURL() + "&op=barcode-lookup&isbn=\(isbn)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let product = try? JSONDecoder().decode([Product].self, from: data) {
            return product[0]
        } else {
            try handleApiError(data: data)
            return nil
        }
    }

    @available(iOS 13, *)
    public func keywordSearch(keywords: String, language: Int = Languages.English, page: Int = 0) async throws -> [Product] {
        let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        guard let url = URL(string: self._baseURL() + "&op=product-search&name=\(keywords)&language=\(language)&page=\(page)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let result = try? JSONDecoder().decode(ProductList.self, from: data) {
            return result.productlist
        } else {
            try handleApiError(data: data)
            return []
        }
    }

    @available(iOS 13, *)
    public func categorySearch(keywords: String, category: Int, language: Int = Languages.English, page: Int = 0) async throws -> [Product] {
        let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        guard let url = URL(string: self._baseURL() + "&op=category-search&name=\(keywords)&category=\(category)&language=\(language)&page=\(page)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let result = try? JSONDecoder().decode(ProductList.self, from: data) {
            return result.productlist
        } else {
            try handleApiError(data: data)
            return []
        }
    }

    @available(iOS 13, *)
    public func similarProductSearch(keywords: String, language: Int = Languages.English, page: Int = 0) async throws -> [Product] {
        let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        guard let url = URL(string: self._baseURL() + "&op=similar-product-search&name=\(keywords)&language=\(language)&page=\(page)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let result = try? JSONDecoder().decode(ProductList.self, from: data) {
            return result.productlist
        } else {
            try handleApiError(data: data)
            return []
        }
    }

    @available(iOS 13, *)
    public func barcodePrefixSearch(prefix: String, language: Int = Languages.English, page: Int = 0) async throws -> [Product] {
        guard let url = URL(string: self._baseURL() + "&op=barcode-prefix-search&prefix=\(prefix)&language=\(language)&page=\(page)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let result = try? JSONDecoder().decode(ProductList.self, from: data) {
            return result.productlist
        } else {
            try handleApiError(data: data)
            return []
        }
    }

    @available(iOS 13, *)
    public func issuingCountryLookup(ean: String) async throws -> String {
        guard let url = URL(string: self._baseURL() + "&op=issuing-country&ean=\(ean)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let product = try? JSONDecoder().decode([BaseProduct].self, from: data) {
            return product[0].issuingCountry
        } else {
            try handleApiError(data: data)
            return ""
        }
    }

    @available(iOS 13, *)
    public func verifyChecksum(ean: String) async throws -> Bool {
        guard let url = URL(string: self._baseURL() + "&op=verify-checksum&ean=\(ean)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let product = try? JSONDecoder().decode([VerifyChecksum].self, from: data) {
            return (product[0].valid == "1")
        } else {
            try handleApiError(data: data)
            return false
        }
    }

    @available(iOS 13, *)
    public func generateBarcodeImage(ean: String, width: Int = 102, height: Int = 50) async throws -> Data? {
        guard let url = URL(string: self._baseURL() + "&op=barcode-image&ean=\(ean)&width=\(width)&height=\(height)") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let json = try? JSONDecoder().decode([BarcodeImage].self, from: data) {
            return Data(base64Encoded: json[0].barcode)
        } else {
            try handleApiError(data: data)
            return nil
        }
    }

    @available(*, deprecated)
    @available(iOS 13, *)
    public func accountStatus() async throws -> (Int, Int) {
        guard let url = URL(string: self._baseURL() + "&op=account-status") else {
            throw UPCLookupError.apiError("Invalid URL")
        }
        let data = try await apiCall(url: url)
        if let status = try? JSONDecoder().decode(AccountStatus.self, from: data) {
            remaining = (status.requestlimit - status.requests)
            return (status.requests, status.requestlimit)
        } else {
            try handleApiError(data: data)
            return (0, 0)
        }
    }

    public func creditsRemaining() -> Int {
//        if remaining == -1 {
//            let (_, _) = try await accountStatus()  // TODO would make this the function async throws
//        }
        return remaining
    }

    private func _baseURL() -> String {
        return self.baseURL + "&token=\(apiToken)"
    }

    @available(iOS 13, macOS 12, *)
    private func apiCall(url: URL, tries: Int = 1) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 429 && tries < self.MAX_API_TRIES {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                return try await apiCall(url: url, tries: tries+1)
            }
            if let rem = httpResponse.allHeaderFields["X-Credits-Remaining"] as? String {
                remaining = Int(rem)!
            }
        }
        return data
    }

    private func handleApiError(data: Data) throws { // TODO tell Swift this function _always_ throws...
        if let err = try? JSONDecoder().decode([ErrorMsg].self, from: data) {
            throw UPCLookupError.apiError(err[0].error)
        } else {
            let str = String(decoding: data, as: UTF8.self)
            throw UPCLookupError.apiError("Unknow error: \(str)")
        }
    }

    /// EAN-Search.org API token. See https://www.ean-search.org/ean-database-api.html
    private var apiToken: String
    private let baseURL = "https://api.ean-search.org/api?format=json"
    private var remaining: Int = -1
    private let MAX_API_TRIES: Int = 3
}
