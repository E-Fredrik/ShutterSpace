//
//  CloudinaryManager.swift
//  ShutterSpace
//
//  Created by Elifele Fredrik on 29/05/26.
//

import Cloudinary
import Foundation

class CloudinaryManager {

    static let shared = CloudinaryManager()

    private init() {}

    func uploadImage(data: Data) async throws -> String {

        //        guard let cloudName = Bundle.main.object(forInfoDictionaryKey: "CloudinaryCloudName") as? String,
        //              let uploadPreset = Bundle.main.object(forInfoDictionaryKey: "CloudinaryUploadPreset") as? String,
        //              let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload") else {
        //
        //            throw URLError(.badURL)
        //        }

        let rawCloudName = Bundle.main.object(
            forInfoDictionaryKey: "CloudinaryCloudName"
        )
        let rawPreset = Bundle.main.object(
            forInfoDictionaryKey: "CloudinaryUploadPreset"
        )

        print(
            "DEBUG - Raw Cloud Name from plist: \(String(describing: rawCloudName))"
        )
        print("DEBUG - Raw Preset from plist: \(String(describing: rawPreset))")

        guard let cloudName = rawCloudName as? String, !cloudName.isEmpty,
            let uploadPreset = rawPreset as? String, !uploadPreset.isEmpty,
            let url = URL(
                string:
                    "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload"
            )
        else {

            print(
                "DEBUG - Failed to construct Cloudinary URL. Throwing -1000 Error."
            )
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n"
                .data(using: .utf8)!
        )
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"upload.jpg\"\r\n"
                .data(using: .utf8)!
        )
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let (responseData, response) = try await URLSession.shared.upload(
            for: request,
            from: body
        )

        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200,
            let jsonResponse = try JSONSerialization.jsonObject(
                with: responseData
            ) as? [String: Any],
            let secureUrl = jsonResponse["secure_url"] as? String
        else {

            throw URLError(.badServerResponse)
        }

        return secureUrl
    }

    func getOptimizedUrl(from originalUrl: String, width: Int) -> String {

        return originalUrl.replacingOccurrences(
            of: "/upload/",
            with: "/upload/w_\(width),c_scale,q_auto,f_auto/"
        )
    }
}
