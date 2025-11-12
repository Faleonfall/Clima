//
//  WeatherManager.swift
//  Clima
//
//  Created by Volodymyr Kryvytskyi on 09.08.2023.
//

import Foundation
import CoreLocation

enum WeatherError: Error, LocalizedError {
    case invalidURL
    case missingAPIKey
    case httpStatus(Int)
    case noData
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to build a valid URL."
        case .missingAPIKey:
            return "Missing OpenWeather API key."
        case .httpStatus(let code):
            return "Server returned status code \(code)."
        case .noData:
            return "No data received from server."
        case .decoding(let error):
            return "Failed to parse weather data: \(error.localizedDescription)"
        }
    }
}

final class WeatherManager: @unchecked Sendable {

    private let session: URLSession
    private let baseURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")!

    private var apiKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String) ?? ""
    }

    init(session: URLSession = .shared) {
        self.session = session
    }

    // Run on the caller's actor to avoid cross-actor sends.
    nonisolated(nonsending)
    func weather(for city: String) async throws -> WeatherModel {
        let url = try buildURL(queryItems: [URLQueryItem(name: "q", value: city)])
        return try await fetchWeather(from: url)
    }

    nonisolated(nonsending)
    func weather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> WeatherModel {
        let url = try buildURL(queryItems: [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude))
        ])
        return try await fetchWeather(from: url)
    }

    private func buildURL(queryItems extra: [URLQueryItem]) throws -> URL {
        guard apiKey.isEmpty == false else { throw WeatherError.missingAPIKey }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var items: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        items.append(contentsOf: extra)
        components?.queryItems = items
        guard let url = components?.url else { throw WeatherError.invalidURL }
        return url
    }

    private func fetchWeather(from url: URL) async throws -> WeatherModel {
        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse else {
            throw WeatherError.noData
        }
        guard (200...299).contains(http.statusCode) else {
            throw WeatherError.httpStatus(http.statusCode)
        }

        do {
            let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
            return WeatherModel(
                conditionId: decoded.weather.first?.id ?? 800,
                cityName: decoded.name,
                temperature: decoded.main.temp
            )
        } catch {
            throw WeatherError.decoding(error)
        }
    }
}
