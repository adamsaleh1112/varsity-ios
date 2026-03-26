import Foundation
import Combine

@MainActor
final class SchoolsViewModel: ObservableObject {
    @Published var schools: [School] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = SportsDataService()

    func loadSchools() async {
        isLoading = true
        errorMessage = nil

        do {
            schools = try await service.fetchSchools()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logoURL(for school: School) -> URL? {
        service.publicImageURL(bucket: "school-assets", path: school.logoPath)
    }
}
