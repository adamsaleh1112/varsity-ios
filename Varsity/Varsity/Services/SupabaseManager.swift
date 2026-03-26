import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://hpfxonowaopgclnujptn.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwZnhvbm93YW9wZ2NsbnVqcHRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0OTA5MjMsImV4cCI6MjA5MDA2NjkyM30.NWhMSfJdh2VyjbOVAnxUMpC4NBgPvcBCG2zkTt7ZD2c"
        )
    }
}
