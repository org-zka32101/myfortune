import Foundation
import FirebaseAuth
import FirebaseFunctions

enum FortuneServiceError: Error {
    case invalidResponse
}

class FortuneService {
    static let shared = FortuneService()

    private let functions = Functions.functions()

    private init() {}

    /// Fetches today's fortune from the `analyzeFortune` Cloud Function.
    ///
    /// The backend generates it from the user's recorded history (or
    /// returns today's cached result if one already exists) and persists it
    /// server-side — there is no separate save step on the client.
    func fetchFortune(completion: @escaping (Result<Fortune, Error>) -> Void) {
        ensureSignedIn { [weak self] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                self?.callAnalyzeFortune(completion: completion)
            }
        }
    }

    /// The backend only needs a stable caller identity for per-user
    /// caching/history, so anonymous auth is enough — no sign-in UI.
    private func ensureSignedIn(completion: @escaping (Result<Void, Error>) -> Void) {
        if Auth.auth().currentUser != nil {
            completion(.success(()))
            return
        }

        Auth.auth().signInAnonymously { _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    private func callAnalyzeFortune(completion: @escaping (Result<Fortune, Error>) -> Void) {
        functions.httpsCallable("analyzeFortune").call { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let data = result?.data as? [String: Any],
                  let text = data["text"] as? String,
                  let category = data["category"] as? String else {
                completion(.failure(FortuneServiceError.invalidResponse))
                return
            }

            let fortune = Fortune(id: UUID().uuidString, text: text, date: Date(), category: category)
            completion(.success(fortune))
        }
    }
}
