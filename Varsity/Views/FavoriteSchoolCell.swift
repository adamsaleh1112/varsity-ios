import SwiftUI

struct FavoriteSchoolCell: View {
    let school: School
    
    private var logoURL: URL? {
        SportsDataService().publicImageURL(bucket: "school-assets", path: school.logoPath)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // School Logo
            AsyncImage(url: logoURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: school.primaryColor ?? "333333"))
                    .overlay(
                        Text(school.shortName ?? String(school.name.prefix(2)).uppercased())
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // School Abbreviation
            Text(school.shortName ?? school.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
            
            // State
            Text(school.state ?? "")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    // Preview requires actual School data from database
    FavoriteSchoolCell(school: School(
        id: UUID(),
        name: "",
        shortName: "",
        city: "",
        state: "",
        mascot: "",
        primaryColor: nil,
        secondaryColor: nil,
        logoPath: nil
    ))
}
